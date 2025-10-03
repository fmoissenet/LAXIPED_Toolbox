function data = smooth_array3(data, fmarker, fc, method, win)
% SMOOTH_ARRAY3  Lissage d'une trajectoire 3x1xT
%
% INPUT
%   data    : 3x1xT (trajectoire)
%   fmarker : fréquence d'échantillonnage (Hz)
%   fc      : paramètre principal du filtre (Hz si Butterworth, ordre poly si SavGol)
%   method  : 'butter' (def), 'movmean', 'movmedian', 'sgolay'
%   win     : fenêtre en nombre d'échantillons (def calculé automatiquement)
%
% OUTPUT
%   data    : trajectoire lissée (même format)

if nargin < 4 || isempty(method), method = 'butter'; end
if nargin < 3 || isempty(fc), fc = 6; end
[d,one,T] = size(data);
assert(d==3 && one==1, 'Format attendu 3x1xT');

if nargin < 5 || isempty(win)
    % fenêtre par défaut ~0.1s
    win = round(0.1 * fmarker);
    if mod(win,2)==0, win=win+1; end % impair
end

switch lower(method)
    case 'butter'
        Wn = fc/(fmarker/2);
        [b,a] = butter(2, Wn, 'low');
        filterfun = @(y) filtfilt(b,a,y);

    case 'movmean'
        filterfun = @(y) movmean(y, win, 'omitnan');

    case 'movmedian'
        filterfun = @(y) movmedian(y, win, 'omitnan');

    case 'sgolay'
        % fc=ordre polynôme, win=taille fenêtre
        if fc>=win, fc = win-1; end
        filterfun = @(y) sgolayfilt(y, fc, win);

    otherwise
        error('Méthode "%s" inconnue.', method);
end

% Appliquer méthode coordonnée par coordonnée
for k = 1:3
    y = squeeze(data(k,1,:));
    nanmask = isnan(y);
    if all(nanmask), continue; end
    
    % interpolation temporaire des NaN
    t = (1:T)';
    y(nanmask) = interp1(t(~nanmask), y(~nanmask), t(nanmask), 'pchip','extrap');
    
    % filtrage
    y_filt = filterfun(y);
    
    % remettre NaN
    y_filt(nanmask) = NaN;
    data(k,1,:) = y_filt;
end
end
