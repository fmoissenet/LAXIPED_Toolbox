function Xcells = build_Xcells(segments, solid, recon, mode)
% BUILD_XCELLS Assemble Xcells pour l'animation sans recalcul
%
% INPUT
%   segments : cell array de noms de segments {'TIBIA','META1',...}
%   solid    : struct issu de solidify_cluster4_array3 (solid.(seg).S etc.)
%   recon    : struct issu de reconstruct_cluster4_array3(_robust)
%   mode     : 'raw' | 'solid' | 'recon'
%
% OUTPUT
%   Xcells{i}.X : trajectoires 3x1xT×4 (double)
%   Xcells{i}.S : forme rigide moyenne 3x4 (double)

if nargin < 4
    mode = 'recon'; % par défaut
end

Xcells = cell(numel(segments),1);

for i = 1:numel(segments)
    seg = segments{i};
    
    switch lower(mode)
        case 'solid'
            Xcells{i}.X = double(solid.(seg).X_solid); % 3x1xT×4
        case 'recon'
            Xcells{i}.X = double(recon.(seg));         % 3x1xT×4
        case 'raw'
            error('Mode "raw" : fournir Marker ou une struct équivalente'); 
        otherwise
            error('Mode inconnu. Utiliser ''raw'', ''solid'' ou ''recon''.');
    end
    
    Xcells{i}.S = double(solid.(seg).S); % forme rigide moyenne (3x4)
end
end
