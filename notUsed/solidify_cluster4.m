function out = solidify_cluster4(X, opts)
% SOLIDIFY_CLUSTER4  Solidifie les trajectoires d'un cluster rigide de 4 marqueurs
% selon la procédure "forme rigide moyenne" + ajustement SVD (Kabsch).
%
% INPUT
%   X    : T x 3 x 4  (T images, 4 marqueurs)
%   opts : struct optionnel :
%          .retain_fraction  (par défaut 0.75)
%          .max_iter         (par défaut 20)
%          .tol              (par défaut 1e-8)
%
% OUTPUT
%   out.S              : 3 x 4  -> forme rigide moyenne (centrée)
%   out.X_solid        : T x 3 x 4 -> trajectoires solidifiées
%   out.R              : 3 x 3 x T -> rotation par image
%   out.t              : 3 x T     -> translation par image
%   out.deformScore    : T x 1     -> score de déformation relatif
%   out.used_idx       : indices des images retenues
%
% Adapté pour ignorer les frames où des marqueurs sont à [0;0;0].

if nargin < 2, opts = struct(); end
retain_fraction = get_opt(opts, 'retain_fraction', 0.75);
max_iter        = get_opt(opts, 'max_iter', 20);
tol             = get_opt(opts, 'tol', 1e-8);

[T, d, m] = size(X);
assert(d==3 && m==4, 'X doit être T x 3 x 4');

% -------- Nettoyage : remplacer (0,0,0) par NaN --------
for t = 1:T
    for j = 1:m
        if all(X(t,:,j) == 0)
            X(t,:,j) = NaN;
        end
    end
end

% -------- 0) Préparation : masques de validité par image --------
valid = squeeze(all(all(~isnan(X),2),3));   % image valide si 4 marqueurs définis
idx_all = find(valid);
if numel(idx_all) < 4
    error('Pas assez d’images valides pour estimer une forme rigide fiable (>=4).');
end

% -------- 1) Estimation initiale d’une forme moyenne (GPA) --------
S = initial_template(X, idx_all);  % 3x4
S = refine_template_gpa(S, X, idx_all, max_iter, tol);

% -------- 2) Sélection des images "peu déformées" --------
edge_idx = nchoosek(1:4,2);  
L_S = edge_lengths(S, edge_idx);

deformScore = nan(T,1);
for t = idx_all'
    Xt = squeeze(X(t,:,:));               
    L_t = edge_lengths(center_cols(Xt), edge_idx);
    deformScore(t) = rms(L_t - L_S) / max(1e-12, rms(L_S));
end

[~, order] = sort(deformScore(idx_all), 'ascend');
k_keep = max(4, round(retain_fraction * numel(idx_all)));
used_idx = idx_all(order(1:k_keep));

% -------- 3) Recalcule la forme moyenne sur les images retenues --------
S = initial_template(X, used_idx);
S = refine_template_gpa(S, X, used_idx, max_iter, tol);

% -------- 4) Ajustement rigide SVD sur chaque image --------
X_solid = nan(T,3,4);
Rall = nan(3,3,T);
tall = nan(3,T);

for t = 1:T
    Xt = squeeze(X(t,:,:));   
    if any(isnan(Xt),'all'), continue; end
    [R,tvec] = kabsch_fit(S, Xt);
    Rall(:,:,t) = R;
    tall(:,t)   = tvec;
    X_solid(t,:,:) = (R*S + tvec);   
end

% -------- 5) Sortie --------
out.S           = S;
out.X_solid     = X_solid;
out.R           = Rall;
out.t           = tall;
out.deformScore = deformScore;
out.used_idx    = used_idx;
end

% =================== Helpers ===================
function val = get_opt(s, fld, def)
    if isfield(s, fld) && ~isempty(s.(fld)), val = s.(fld); else, val = def; end
end
function C = center_cols(A), C = A - mean(A,2); end
function S0 = initial_template(X, idx)
    M = zeros(3,4); n = 0;
    for t = idx(:)'
        Xt = squeeze(X(t,:,:));
        if any(isnan(Xt),'all'), continue; end
        M = M + center_cols(Xt); n = n + 1;
    end
    S0 = center_cols(M/n);
end
function S = refine_template_gpa(Sinit, X, idx, max_iter, tol)
    S = Sinit;
    for it = 1:max_iter
        A = zeros(3,4); n=0;
        for t = idx(:)'
            Xt = squeeze(X(t,:,:));
            if any(isnan(Xt),'all'), continue; end
            Xt_c = center_cols(Xt);
            [R,~] = kabsch_fit(S, Xt_c);
            A = A + R*S; n = n+1;
        end
        S_new = center_cols(A/n);
        if norm(S_new-S,'fro') < tol, break; end
        S = S_new;
    end
end
function [R,t] = kabsch_fit(A,B)
    Ac = center_cols(A); Bc = center_cols(B);
    H = Ac * Bc.'; [U,~,V] = svd(H);
    R = V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
    t = mean(B,2) - R*mean(A,2);
end
function L = edge_lengths(P, edge_idx)
    L = zeros(size(edge_idx,1),1);
    for i = 1:size(edge_idx,1)
        L(i) = norm(P(:,edge_idx(i,2)) - P(:,edge_idx(i,1)));
    end
end
