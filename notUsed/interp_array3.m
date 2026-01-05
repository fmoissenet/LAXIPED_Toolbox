function [Xout, t_out] = interp_array3(X, method, maxGap, nFrames)
% INTERP_ARRAY3  Interpole les NaN le long du temps pour une trajectoire 3x1xT
% puis ré-échantillonne sur nFrames frames sans extrapoler, en respectant maxGap.
%
% - Pas d'extrapolation : NaN en dehors des zones observées
% - method: 'pchip' (défaut) ou 'spline'/'linear'...
% - maxGap (entier) : n'interpole que les trous <= maxGap (défaut: Inf)
% - nFrames : nombre de frames en sortie (défaut: T d'entrée)
%
% Entrée :  X (3x1xT) double
% Sortie :  Xout (3x1xnFrames), t_out (nFramesx1)

    if nargin < 2 || isempty(method), method = 'pchip'; end
    if nargin < 3 || isempty(maxGap), maxGap = Inf; end

    [d, one, T] = size(X); %#ok<ASGLU>
    if nargin < 4 || isempty(nFrames), nFrames = T; end
    t      = (1:T)';                     % grille d'origine
    t_out  = linspace(1, T, nFrames)';   % grille de sortie

    % Pré-allocation
    Xout = nan(d,1,nFrames);

    for k = 1:d
        y = squeeze(X(k,1,:));  % Tx1
        idx = ~isnan(y);

        % rien à faire si < 2 valeurs valides
        if sum(idx) < 2
            continue;
        end

        % ---- remplir uniquement les trous internes courts (<= maxGap) ----
        x  = find(idx);            % indices valides
        xv = t(idx);
        yv = y(idx);

        % indices NaN internes (dans [min(x) max(x)])
        xqAll = find(~idx);
        inside = ~isempty(xqAll) && (xqAll >= x(1) & xqAll <= x(end));
        if any(inside)
            xq = xqAll(inside);
            yq = interp1(xv, yv, t(xq), method);  % hors plage -> NaN

            if isfinite(maxGap)
                % ne remplir que les runs <= maxGap
                fillMask = true(size(xq));
                nanRunInside = false(T,1); nanRunInside(xq) = true;
                dRun = diff([0; nanRunInside; 0]);
                runStarts = find(dRun == 1);
                runEnds   = find(dRun == -1) - 1;
                ptr = 1;
                for r = 1:numel(runStarts)
                    thisIdx = runStarts(r):runEnds(r);
                    len = numel(thisIdx);
                    if len > maxGap
                        fillMask(ptr:ptr+len-1) = false;
                    end
                    ptr = ptr + len;
                end
                yq(~fillMask) = NaN;
            end

            y(xq) = yq;  % ne remplace que les trous courts
        end
        % A ce stade :
        % - début/fin restent NaN
        % - trous longs (> maxGap) restent NaN
        % - trous courts comblés par "method"

        % ---- ré-échantillonnage sur t_out sans extrapolation ----
        % On interpole uniquement par segments contigus non-NaN (>=2 points)
        y_res = nan(size(t_out));
        isValid = ~isnan(y);
        if any(isValid)
            dRun = diff([0; isValid; 0]);
            segStarts = find(dRun == 1);
            segEnds   = find(dRun == -1) - 1;
            for s = 1:numel(segStarts)
                i1 = segStarts(s);
                i2 = segEnds(s);
                if (i2 - i1 + 1) < 2
                    continue; % besoin d'au moins 2 points pour interp1
                end
                tseg = t(i1:i2);
                yseg = y(i1:i2);
                mask = (t_out >= tseg(1)) & (t_out <= tseg(end));
                y_res(mask) = interp1(tseg, yseg, t_out(mask), method);
            end
        end

        Xout(k,1,:) = y_res;
    end
end
