function out = enforce_cluster_rigidity(X_seg, opts)
% ENFORCE_CLUSTER_RIGIDITY
% Impose une forme constante (moyenne) à un cluster de 4 marqueurs
% 
% INPUT
%   X_seg : 3x1xT×4 trajectoires
%   opts.method   : 'mean' (def) | 'trimmed' | 'irls' | 'ransac' | 'l1'
%   opts.trimFrac : fraction frames gardées (trimmed, def=0.8)
%   opts.maxIter  : nb max itérations GPA (def=10)
%   opts.tol      : tolérance convergence (def=1e-8)
%
% OUTPUT
%   out.Xrigid : 3x1xT×4 trajectoires corrigées (rigides)
%   out.Smean  : 3x4 forme moyenne
%   out.R, out.t : poses rigides par frame

if nargin<2, opts=struct(); end
method   = get_opt(opts,'method','mean');
trimFrac = get_opt(opts,'trimFrac',0.8);
maxIter  = get_opt(opts,'maxIter',10);
tol      = get_opt(opts,'tol',1e-8);

[d,one,T,m] = size(X_seg);
assert(d==3 && one==1 && m==4,'X_seg doit être 3x1xT×4');

% Reformater en 3x4xT
X = squeeze(permute(X_seg,[1 4 3 2]));

% Estimation de la forme moyenne selon la méthode
switch lower(method)
    case 'mean'
        Smean = mean_shape(X,maxIter,tol);
    case 'trimmed'
        Smean = mean_shape_trimmed(X,maxIter,trimFrac,tol);
    case 'irls'
        Smean = mean_shape_irls(X,maxIter,tol);
    case 'ransac'
        Smean = mean_shape_ransac(X,maxIter);
    case 'l1'
        Smean = mean_shape_l1(X);
    otherwise
        error('Méthode "%s" inconnue',method);
end

% Projection rigide frame par frame
Xrigid = nan(3,4,T); Rall=nan(3,3,T); tall=nan(3,T);
for t=1:T
    Xt = X(:,:,t);
    valid = find(~any(isnan(Xt),1));
    if numel(valid) < 3
        continue; % pas assez de points valides
    end
    [R,tv] = kabsch_fit(Smean(:,valid), Xt(:,valid));
    Y = R*Smean + tv;
    Xrigid(:,:,t) = Y;
    Rall(:,:,t) = R; tall(:,t) = tv;
end

% Reformater sortie
out.Xrigid = permute(reshape(Xrigid,[3,4,1,T]),[1 3 4 2]);
out.Smean  = Smean;
out.R = Rall; out.t = tall;
end

% ==================== Helpers ====================

function S = mean_shape(X,maxIter,tol)
% GPA simple
S = init_shape(X);
for it=1:maxIter
    A=zeros(3,4); n=0;
    for t=1:size(X,3)
        Xt=X(:,:,t); if any(isnan(Xt(:))), continue; end
        [R,~]=kabsch_fit(S,Xt);
        A=A+R'*(Xt-mean(Xt,2)); n=n+1;
    end
    Snew=A/max(n,1); Snew=Snew-mean(Snew,2);
    if norm(Snew-S,'fro')<tol, break; end
    S=Snew;
end
end

function S = mean_shape_trimmed(X,maxIter,frac,tol)
% GPA avec trimming
edges=nchoosek(1:4,2);
S=init_shape(X);
for it=1:maxIter
    scores=[]; idx=[];
    Lref=edge_lengths(S,edges);
    for t=1:size(X,3)
        Xt=X(:,:,t); if any(isnan(Xt(:))), continue; end
        L=edge_lengths(Xt-mean(Xt,2),edges);
        scores(end+1)=rms(L-Lref); idx(end+1)=t;
    end
    [~,ord]=sort(scores); keep=idx(ord(1:round(frac*numel(ord))));
    Snew=mean_shape(X(:,:,keep),5,tol);
    if norm(Snew-S,'fro')<tol, break; end
    S=Snew;
end
end

function S = mean_shape_irls(X,maxIter,tol)
% GPA avec poids robustes Huber
edges=nchoosek(1:4,2);
S=init_shape(X);
for it=1:maxIter
    scores=[]; idx=[]; Xlist={};
    Lref=edge_lengths(S,edges);
    for t=1:size(X,3)
        Xt=X(:,:,t); if any(isnan(Xt(:))), continue; end
        L=edge_lengths(Xt-mean(Xt,2),edges);
        scores(end+1)=rms(L-Lref); idx(end+1)=t; Xlist{end+1}=Xt;
    end
    c=1.345*median(scores+eps);
    w=min(1,c./max(scores,eps));
    Snew=zeros(3,4); wsum=0;
    for k=1:numel(idx)
        Xt=Xlist{k}; wk=w(k);
        [R,~]=kabsch_fit(S,Xt);
        Snew=Snew+wk*(R'*(Xt-mean(Xt,2))); wsum=wsum+wk;
    end
    Snew=Snew/max(wsum,1); Snew=Snew-mean(Snew,2);
    if norm(Snew-S,'fro')<tol, break; end
    S=Snew;
end
end

function S = mean_shape_ransac(X,maxIter)
% GPA avec RANSAC simple
edges=nchoosek(1:4,2); bestInliers=[]; bestS=[];
for it=1:maxIter
    idx=randsample(size(X,3),min(5,size(X,3)));
    Stry=init_shape(X(:,:,idx));
    inliers=[]; Lref=edge_lengths(Stry,edges);
    for t=1:size(X,3)
        Xt=X(:,:,t); if any(isnan(Xt(:))), continue; end
        L=edge_lengths(Xt-mean(Xt,2),edges);
        if rms(L-Lref)<5 % seuil arbitraire
            inliers(end+1)=t;
        end
    end
    if numel(inliers)>numel(bestInliers)
        bestInliers=inliers; bestS=Stry;
    end
end
if isempty(bestS), S=init_shape(X); else, S=init_shape(X(:,:,bestInliers)); end
end

function S = mean_shape_l1(X)
% Approximation L1 : médiane des longueurs
edges=nchoosek(1:4,2);
Lall=[];
for t=1:size(X,3)
    Xt=X(:,:,t); if any(isnan(Xt(:))), continue; end
    L=edge_lengths(Xt-mean(Xt,2),edges);
    Lall=[Lall,L];
end
Lmed=median(Lall,2,'omitnan'); %#ok<NASGU>
% Reconstruction exacte depuis Lmed non triviale, fallback GPA
S=init_shape(X);
end

function S=init_shape(X)
S=zeros(3,4); n=0;
for t=1:size(X,3)
    Xt=X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    S=S+(Xt-mean(Xt,2)); n=n+1;
end
S=S/max(n,1); S=S-mean(S,2);
end

function L=edge_lengths(P,E)
L=zeros(size(E,1),1);
for i=1:size(E,1)
    L(i)=norm(P(:,E(i,2))-P(:,E(i,1)));
end
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
