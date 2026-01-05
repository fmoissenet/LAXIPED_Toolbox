function out = solidify_cluster4_array3(X, opts)
% SOLIDIFY_CLUSTER4_ARRAY3
% Solidifie un cluster rigide de 4 marqueurs au format 3x1xT x4
% Convention: X est 3 x 1 x T x 4
%   - 3 : coordonnées
%   - 1 : dummy dimension
%   - T : nombre d'images
%   - 4 : nombre de marqueurs

if nargin < 2, opts = struct(); end
retain_fraction = get_opt(opts, 'retain_fraction', 0.75);
max_iter        = get_opt(opts, 'max_iter', 20);
tol             = get_opt(opts, 'tol', 1e-8);

[d,one,T,m] = size(X);
assert(d==3 && one==1 && m==4, 'X doit être 3x1xTx4');

% --- Conversion en 3x4xT ---
Xmat = squeeze(permute(X,[1 4 3 2])); % 3x4xT

% --- Nettoyage ---
for t = 1:T
    for j = 1:m
        if all(Xmat(:,j,t) == 0)
            Xmat(:,j,t) = NaN;
        end
    end
end

% --- Frames valides ---
valid = squeeze(all(all(~isnan(Xmat),1),2));
idx_all = find(valid);
if numel(idx_all) < 4
    error('Pas assez d’images valides pour estimer une forme rigide fiable (>=4).');
end

% --- Forme moyenne initiale ---
S = initial_template(Xmat, idx_all);
S = refine_template_gpa(S,Xmat,idx_all,max_iter,tol);

% --- Score de déformation ---
edge_idx = nchoosek(1:4,2);
L_S = edge_lengths(S, edge_idx);
deformScore = nan(T,1);
for t = idx_all'
    Xt = Xmat(:,:,t);
    L_t = edge_lengths(center_cols(Xt), edge_idx);
    deformScore(t) = rms(L_t - L_S) / max(1e-12, rms(L_S));
end

[~, order] = sort(deformScore(idx_all),'ascend');
k_keep = max(4, round(retain_fraction*numel(idx_all)));
used_idx = idx_all(order(1:k_keep));

% --- Recalcule forme moyenne ---
S = initial_template(Xmat, used_idx);
S = refine_template_gpa(S,Xmat,used_idx,max_iter,tol);

% --- Ajustement rigide ---
X_solid = nan(3,4,T);
Rall = nan(3,3,T);
tall = nan(3,T);
for t=1:T
    Xt = Xmat(:,:,t);
    if any(isnan(Xt(:))), continue; end
    [R,tvec] = kabsch_fit(S,Xt);
    Rall(:,:,t) = R;
    tall(:,t)   = tvec;
    X_solid(:,:,t) = R*S + tvec;
end

% --- Retour au format 3x1xTx4 ---
X_solid_out = permute(reshape(X_solid,[3,4,1,T]),[1 3 4 2]);

% --- Sortie ---
out.S           = S;
out.X_solid     = X_solid_out;
out.R           = Rall;
out.t           = tall;
out.deformScore = deformScore;
out.used_idx    = used_idx;
end

% =================== Helpers ===================
function val = get_opt(s, fld, def)
    if isfield(s,fld) && ~isempty(s.(fld))
        val = s.(fld);
    else
        val = def;
    end
end

function C = center_cols(A)
    C = A - mean(A,2);
end

function S0 = initial_template(X, idx)
    M = zeros(3,4); n=0;
    for t=idx(:)'
        Xt = X(:,:,t);
        if any(isnan(Xt(:))), continue; end
        M = M + center_cols(Xt); n=n+1;
    end
    S0 = center_cols(M/n);
end

function S = refine_template_gpa(Sinit, X, idx, max_iter, tol)
    S=Sinit;
    for it=1:max_iter
        A=zeros(3,4); n=0;
        for t=idx(:)'
            Xt = X(:,:,t);
            if any(isnan(Xt(:))), continue; end
            Xt_c = center_cols(Xt);
            [R,~]=kabsch_fit(S, Xt_c);
            A=A+R*S; n=n+1;
        end
        S_new=center_cols(A/n);
        if norm(S_new-S,'fro')<tol, break; end
        S=S_new;
    end
end

function [R,t]=kabsch_fit(A,B)
    Ac=center_cols(A); Bc=center_cols(B);
    H=Ac*Bc.'; [U,~,V]=svd(H);
    R=V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
    t=mean(B,2)-R*mean(A,2);
end

function L=edge_lengths(P,edge_idx)
    L=zeros(size(edge_idx,1),1);
    for i=1:size(edge_idx,1)
        L(i)=norm(P(:,edge_idx(i,2))-P(:,edge_idx(i,1)));
    end
end
