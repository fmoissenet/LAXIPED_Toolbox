function [outlierIdx, devPerMarker, devEdges] = detect_cluster_outliers(X_seg, L_ref, tol)
% DETECT_CLUSTER_OUTLIERS
% Détecte les marqueurs qui déforment un cluster 4 marqueurs
%
% INPUT
%   X_seg : 3x1xT×4  (trajectoires du cluster)
%   L_ref : 6x1      (longueurs de référence des 6 arêtes)
%   tol   : double   (seuil de tolérance, même unité que X_seg)
%
% OUTPUT
%   outlierIdx   : indices des marqueurs suspects [1..4] par frame (cell array T)
%   devPerMarker : 4xT, max écart d'arête par marqueur
%   devEdges     : 6xT, écart de chaque arête

edge_idx = nchoosek(1:4,2); % 6x2
[~,~,T,~] = size(X_seg);

devPerMarker = nan(4,T);
devEdges = nan(6,T);
outlierIdx = cell(T,1);

for t = 1:T
    % positions des 4 marqueurs à la frame t
    Xt = squeeze(X_seg(:,:,t,:)); % 3x4
    if any(all(isnan(Xt),1))
        continue;
    end
    
    % longueurs des arêtes
    L_t = nan(6,1);
    for e = 1:6
        a = edge_idx(e,1); b = edge_idx(e,2);
        if any(isnan(Xt(:,a))) || any(isnan(Xt(:,b)))
            continue;
        end
        L_t(e) = norm(Xt(:,a)-Xt(:,b));
    end
    devEdges(:,t) = abs(L_t - L_ref);
    
    % contribution par marqueur
    for j = 1:4
        edges_j = any(edge_idx==j,2); % quelles arêtes impliquent j
        devPerMarker(j,t) = max(devEdges(edges_j,t),[],'omitnan');
    end
    
    % outliers = marqueurs dont l’écart max dépasse le seuil
    outlierIdx{t} = find(devPerMarker(:,t) > tol);
end
end
