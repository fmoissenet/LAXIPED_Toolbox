function [T_a, T_t, T_ta] = make_segment_frames(Marker, refAnatFrame, clusterNames, static)
% MAKE_SEGMENT_FRAMES Construit les repères anatomique, technique et
% transformation pour un segment osseux.
%
% INPUT
%   Marker       : struct contenant les coordonnées (3x1) de tous les marqueurs
%   refAnatFrame : 4x4 matrice homogène (repère anatomique de référence, ex tibia)
%   clusterNames : cell array de 4 noms de marqueurs du cluster technique
%
% OUTPUT
%   T_a   : repère anatomique (4x4 homogène)
%   T_t   : repère technique (4x4 homogène)
%   T_ta  : transformation T_ta = inv(T_t)*T_a

    T_a  = [];
    T_t  = [];
    T_ta = [];

    % --- Repère anatomique : reprend X,Y,Z du tibia, change juste l'origine ---
    if static == 1
        O = mean([Marker.(clusterNames{1}), Marker.(clusterNames{2}), ...
                  Marker.(clusterNames{3}), Marker.(clusterNames{4})], 2);
        T_a = [refAnatFrame(1:3,1:3) O; 0 0 0 1];
    end

    % --- Repère technique basé sur 4 marqueurs ---
    X = Vnorm_array3(Marker.(clusterNames{3}) - Marker.(clusterNames{1}));
    Y = Vnorm_array3(Marker.(clusterNames{2}) - Marker.(clusterNames{4}));
    Z = cross(X,Y); 
    X = cross(Z,Y);
    O = Marker.(clusterNames{1});
    for iframe = 1:size(X,3)
        T_t(:,:,iframe) = [X(:,:,iframe) Y(:,:,iframe) Z(:,:,iframe) O(:,:,iframe); 0 0 0 1];
    end

    % --- Transformation rigide technique → anatomique ---
    if static == 1
        T_ta = Mprod_array3(Minv_array3(T_t), T_a);
    end
end
