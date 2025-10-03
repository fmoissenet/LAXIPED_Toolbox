function Xcells = build_Xcells_from_recon_Sref(segments, recon, Sref)
% Construit Xcells pour l’animation à partir de recon et Sref
% Xcells{i}.X : 3x1xT×4
% Xcells{i}.S : 3x4
Xcells = cell(numel(segments),1);
for i = 1:numel(segments)
    seg = segments{i};
    assert(isfield(recon,seg), 'recon.%s manquant', seg);
    assert(isfield(Sref,seg),  'Sref.%s manquant (ajoute-le dans la phase statique)', seg);
    X = recon.(seg);
    assert(ndims(X)==4 && size(X,1)==3 && size(X,2)==1 && size(X,4)==4, ...
        'recon.%s doit être 3x1xT×4', seg);
    Xcells{i}.X = double(X);
    Xcells{i}.S = double(Sref.(seg));
end
end
