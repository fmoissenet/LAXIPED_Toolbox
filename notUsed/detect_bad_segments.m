function bad = detect_bad_segments(x, y, varargin)
% bad(i)=true si l'échantillon i appartient à une zone à retirer
% Paramètres (name/value) :
%  'Pct'     : pourcentage de l'amplitude totale pour le seuil (par défaut 5 -> 5%)
%  'Pad'     : dilatation autour des points détectés (en échantillons, def 5)
%  'MinLen'  : longueur min d'un segment 'bad' à garder (def 3)
%  'Denoise' : taille de fenêtre médiane pour débruiter y avant Δy (0 = off, def 0)

p = inputParser;
addParameter(p, 'Pct', 5);         % %
addParameter(p, 'Pad', 5);
addParameter(p, 'MinLen', 3);
addParameter(p, 'Denoise', 0);
parse(p, varargin{:});
Pct    = p.Results.Pct/100;        % 0..1
pad    = p.Results.Pad;
minlen = p.Results.MinLen;
den    = p.Results.Denoise;

v = isfinite(x) & isfinite(y);
x = x(v); y = y(v);

if den>0
    y2 = medfilt1(y, den, 'omitnan', 'truncate');   % petit débruitage
else
    y2 = y;
end

% amplitude globale
A = max(y2) - min(y2);
if ~isfinite(A) || A==0
    bad = false(size(v)); return;
end

% sauts instantanés (Δy entre échantillons contigus)
dy = [0; diff(y2)];
% if A <= 3 % mm
    jump = abs(dy) > 0.5; % mm
% else
%     jump = abs(dy) > Pct * A;
% end

% dilatation
jump = movmax(jump, [pad pad]);

% supprimer les segments trop courts
bad_local = jump(:);
edges = find(diff([false; bad_local; false])~=0);
segs = reshape(edges,2,[])';
keep = false(size(bad_local));
for k=1:size(segs,1)
    a = segs(k,1); b = segs(k,2)-1;
    if (b-a+1) >= minlen
        keep(a:b) = true;
    end
end

% remettre à la taille d'origine (si NaN/Inf au départ)
bad = false(size(v));
bad(v) = keep;
end