function yN = resample_to_N(y, N)
    % y : vecteur original
    % N : nombre de points désirés
    x  = linspace(1, numel(y), numel(y)); % grille d'origine
    xN = linspace(1, numel(y), N);        % nouvelle grille
    yN = interp1(x, y, xN, 'linear');     % interpolation linéaire
end
