function [outlierMask, devPerMarker, devEdges, L_ref] = detect_cluster_outliers_meanRef(X_seg, tol)
% Détecte les marqueurs outliers dans un cluster (forme de ref = moyenne trial)
%
% INPUT
%   X_seg : 3x1xT×4 (trajectoires)
%   tol   : seuil absolu (même unité que X_seg, ex: mm si mm)
%
% OUTPUT
%   outlierMask  : 4xT logique
%   devPerMarker : 4xT (max écart par marqueur)
%   devEdges     : 6xT (écart arêtes vs ref)
%   L_ref        : 6x1 longueurs de référence moyennes

[d,one,T,m] = size(X_seg);
assert(d==3 && one==1 && m==4,'X_seg doit être 3x1xTx4');

% Reformat en 3x4xT
X = squeeze(permute(X_seg,[1 4 3 2]));

% Edges du tétraèdre
edges = [1 2; 2 3; 3 4; 4 1; 1 3; 2 4];

% 1) Longueurs par frame
L_all = nan(6,T);
for t=1:T
    Xt = X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    L_all(:,t) = sqrt(sum((Xt(:,edges(:,1)) - Xt(:,edges(:,2))).^2,1))';
end

% 2) Longueurs de ref = moyennes
L_ref = mean(L_all,2,'omitnan');

% 3) Déviation par frame
devEdges = nan(6,T);
devPerMarker = nan(4,T);
outlierMask = false(4,T);

for t=1:T
    if any(isnan(L_all(:,t))), continue; end
    dL = abs(L_all(:,t) - L_ref);  % 6x1
    devEdges(:,t) = dL;
    for j=1:4
        involved = any(edges==j,2);           % arêtes connectées à j
        devPerMarker(j,t) = max(dL(involved));
        if devPerMarker(j,t) > tol
            outlierMask(j,t) = true;
        end
    end
end
end
