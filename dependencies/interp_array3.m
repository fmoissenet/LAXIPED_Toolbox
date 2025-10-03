function X = interp_array3(X, method, maxGap)
% INTERPNAN3X1XT  Interpole les NaN le long du temps pour une trajectoire 3x1xT
% - Pas d'extrapolation : les NaN au début/à la fin restent NaN
% - Par défaut: method = 'pchip' (ou 'spline' si tu veux)
% - Option maxGap (entier) : n'interpole que les trous <= maxGap frames
%
% X : 3x1xT (double)

    if nargin < 2 || isempty(method), method = 'pchip'; end
    if nargin < 3, maxGap = Inf; end  % par défaut on comble tous les trous internes

    [d,one,T] = size(X);
    assert(d==3 && one==1, 'Format attendu: 3x1xT');

    t = (1:T)';

    for k = 1:d
        y = squeeze(X(k,1,:));  % Tx1
        % indices valides
        idx = ~isnan(y);

        % rien à faire si < 2 valeurs valides
        if sum(idx) < 2
            continue;
        end

        % --- option maxGap : ne combler que les trous courts ---
        if isfinite(maxGap)
            nanRun = isnan(y);
            if any(nanRun)
                % détecte début/fin de chaque run de NaN
                dRun = diff([0; nanRun; 0]);
                runStarts = find(dRun == 1);
                runEnds   = find(dRun == -1) - 1;
                for r = 1:numel(runStarts)
                    len = runEnds(r) - runStarts(r) + 1;
                    if len > maxGap
                        % on "gèle" ces NaN longs : on ne les comblera pas
                        % (en les marquant comme ininterpolables via un masque)
                        % rien à faire: on les laisse NaN et on n'appellera
                        % pas interp1 dessus en dehors de la plage valide
                    end
                end
            end
        end

        % positions valides et à combler
        x  = find(idx);        % indices de samples valides
        xv = t(idx);
        yv = y(idx);

        % indices NaN internes (dans l’enveloppe [min(x) max(x)])
        xqAll = find(~idx);
        if isempty(xqAll)
            X(k,1,:) = y;  %#ok<AGROW>
            continue;
        end
        inside = xqAll >= x(1) & xqAll <= x(end);
        xq = xqAll(inside);

        if isempty(xq)
            X(k,1,:) = y;  %#ok<AGROW>
            continue;
        end

        % --- interpolation SANS extrapolation (interp1 sans 5e argument) ---
        yq = interp1(xv, yv, t(xq), method);  % hors plage -> NaN automatiquement

        % si maxGap est fixé, ne remplit que les runs <= maxGap
        if isfinite(maxGap)
            fillMask = true(size(xq));
            % re-scan des runs internes seulement
            nanRunInside = false(T,1);
            nanRunInside(xq) = true;
            dRun = diff([0; nanRunInside; 0]);
            runStarts = find(dRun == 1);
            runEnds   = find(dRun == -1) - 1;
            ptr = 1;
            for r = 1:numel(runStarts)
                thisIdx = runStarts(r):runEnds(r);
                len = numel(thisIdx);
                if len > maxGap
                    fillMask(ptr:ptr+len-1) = false; % ne pas remplir ces NaN longs
                end
                ptr = ptr + len;
            end
            yq(~fillMask) = NaN;
        end

        y(xq) = yq;            % remplace uniquement les trous internes courts
        % les NaN hors de la plage (début/fin) restent NaN

        X(k,1,:) = y;
    end
end
