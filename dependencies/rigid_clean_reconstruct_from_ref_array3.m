function out = rigid_clean_reconstruct_from_ref_array3(X, Sref, opts)
% X : 3x1xT×4 (dynamique)
% Sref : 3x4 (statique, centré)
% opts : .tol_edge     (seuil d'écart de longueur d'arête, même unité que X)
%        .replace_mode ('all' (def) | 'inliers_keep')
%        .verbose      (false def)

if nargin<3, opts=struct(); end
tol_edge     = get_opt(opts,'tol_edge',2);     % <= en mm SI tes C3D sont en mm
replace_mode = get_opt(opts,'replace_mode','all');
verbose      = get_opt(opts,'verbose',false);

[d,one,T,m] = size(X); assert(d==3 && one==1 && m==4, 'X doit être 3x1xTx4');

% -> 3x4xT
Xmat = squeeze(permute(X,[1 4 3 2]));
% (0,0,0) -> NaN
for t=1:T, for j=1:4, if all(Xmat(:,j,t)==0), Xmat(:,j,t)=NaN; end, end, end

edge_idx = nchoosek(1:4,2); 
L_ref = edge_lengths(Sref, edge_idx);   % mêmes unités que X (mm si mm)

Xcorr = Xmat; outlier_mask=false(4,T);
Rall=nan(3,3,T); tall=nan(3,T); edge_dev=nan(T,1); used_inliers=cell(T,1);

for t=1:T
    Xt = Xcorr(:,:,t);
    valid = find(~any(isnan(Xt),1));
    if numel(valid)<3, continue; end

    % -- écart par marqueur basé UNIQUEMENT sur les longueurs d'arêtes --
    dev_per_marker = nan(1,4);
    for j=1:4
        if any(isnan(Xt(:,j))), continue; end
        devs=[];
        for e=1:size(edge_idx,1)
            a=edge_idx(e,1); b=edge_idx(e,2);
            if j~=a && j~=b, continue; end
            if ~any(isnan(Xt(:,a))) && ~any(isnan(Xt(:,b)))
                L_xt = norm(Xt(:,b)-Xt(:,a));   % même unité que X
                devs(end+1) = abs(L_xt - L_ref(e));
            end
        end
        if ~isempty(devs), dev_per_marker(j)=max(devs); end
    end
    edge_dev(t) = max(dev_per_marker,[],'omitnan');

    % -- outliers: écart > tol_edge (même unité) --
    mark_as_out = find(~isnan(dev_per_marker) & (dev_per_marker > tol_edge));
    if ~isempty(mark_as_out)
        Xt(:,mark_as_out) = NaN;
        outlier_mask(mark_as_out,t) = true;
    end

    valid = find(~any(isnan(Xt),1));
    if numel(valid)<3, continue; end

    % -- fit rigide sur inliers --
    [R,tvec] = kabsch_fit(Sref(:,valid), Xt(:,valid));
    Y = R*Sref + tvec;           % projection rigide (mêmes unités)
    miss = find(any(isnan(Xt),1));

    switch lower(replace_mode)
        case 'all'
            Xt_hat = Y;                          % rigidité parfaite (anti-jitter)
        case 'inliers_keep'
            Xt_hat = Xt; for jj=miss, Xt_hat(:,jj) = Y(:,jj); end
        otherwise
            error('replace_mode invalide');
    end

    Xcorr(:,:,t) = Xt_hat;
    Rall(:,:,t) = R; tall(:,t) = tvec; used_inliers{t} = valid;

    if verbose
        fprintf('Frame %d: outliers=%s, maxEdgeDev=%.3f (unités X)\n', ...
                t, mat2str(mark_as_out), edge_dev(t));
    end
end

out.X            = permute(reshape(Xcorr,[3,4,1,T]),[1 3 4 2]); % 3x1xT×4
out.outlier_mask = outlier_mask;
out.R = Rall; out.t = tall; out.edge_dev = edge_dev; out.used_inliers = used_inliers;

% Résumé global (affiché dans les mêmes unités que X)
out.summary.nFrames = T;
out.summary.nOutlierFrames = nnz(any(outlier_mask,1));
out.summary.percOutlierFrames = 100*out.summary.nOutlierFrames/T;
out.summary.maxDev = max(edge_dev,[],'omitnan');
out.summary.meanDev = mean(edge_dev,'omitnan');
end

% --- helpers ---
function L=edge_lengths(P,edge_idx)
L=zeros(size(edge_idx,1),1);
for i=1:size(edge_idx,1), L(i)=norm(P(:,edge_idx(i,2))-P(:,edge_idx(i,1))); end
end
function [R,t]=kabsch_fit(A,B)
Ac=A-mean(A,2); Bc=B-mean(B,2);
H=Ac*Bc.'; [U,~,V]=svd(H);
R=V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
t=mean(B,2)-R*mean(A,2);
end
function val=get_opt(s,f,d)
if isfield(s,f)&&~isempty(s.(f)), val=s.(f); else, val=d; end
end
