function Xcells = build_clusters(Marker, segments)
% BUILDS_CLUSTERS Construit les clusters 3x1xTx4 pour une liste de segments
%
% INPUT
%   Marker   : struct avec les champs SEG_c1..c4 (chacun 3x1xT)
%   segments : cell array de noms de segments (ex: {'TIBIA','META1',...})
%
% OUTPUT
%   Xcells   : cell array de clusters (chaque élément 3x1xTx4)

Xcells = cell(numel(segments),1);
for i = 1:numel(segments)
    seg = segments{i};
    % concatène les 4 marqueurs en 4D: 3x1xT x4
    Xcells{i} = cat(4, Marker.([seg '_c1']), ...
                       Marker.([seg '_c2']), ...
                       Marker.([seg '_c3']), ...
                       Marker.([seg '_c4']));
end
end
