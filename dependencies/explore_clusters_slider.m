function explore_clusters_slider(MarkerR, T_a, segments, step)
% EXPLORE_CLUSTERS_SLIDER
% Interface interactive avec slider, sélection de vue, step réglable et
% bouton Play/Pause pour explorer les clusters
%
% INPUTS
%   MarkerR : struct de marqueurs rigides (3x1xT)
%   T_a     : struct de repères anatomiques (4x4xT)
%   segments: cell array des noms de segments
%   step    : pas d'incrément (ex: 200). Défaut = 1

if nargin < 4 || isempty(step), step = 1; end

Ttot  = size(T_a.TIBIA,3);
names = fieldnames(MarkerR);

% bornes fixes pour l'affichage
lims = computeBounds(MarkerR);

% --- Figure et Axes
f = figure('Name','Clusters explorer','Color','w');
ax = axes('Parent',f); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
xlabel(ax,'X'); ylabel(ax,'Y'); zlabel(ax,'Z'); view(ax,3);
xlim(ax, lims.x); ylim(ax, lims.y); zlim(ax, lims.z);

% --- Slider
slider = uicontrol('Style','slider','Units','normalized',...
    'Position',[0.2 0.01 0.6 0.05],...
    'Min',1,'Max',Ttot,'Value',1,...
    'SliderStep',[max(step/(Ttot-1),eps) min(10*step/(Ttot-1),1)],...
    'Callback',@(src,~) updateFrame(roundToStep(get(src,'Value'))));

% --- Menu vue
popup = uicontrol('Style','popupmenu','Units','normalized',...
    'Position',[0.01 0.01 0.12 0.05],...
    'String',{'3D','Front','Side','Top'},...
    'Callback',@(src,~) changeView(get(src,'Value')));

% --- Champ step
uicontrol('Style','text','Units','normalized','Position',[0.82 0.055 0.06 0.02],...
    'String','step:','BackgroundColor','w');
editStep = uicontrol('Style','edit','Units','normalized','Position',[0.88 0.05 0.1 0.03],...
    'String',num2str(step),...
    'Callback',@(src,~) setStep(str2double(get(src,'String'))));

% --- Boutons Préc./Suiv.
uicontrol('Style','pushbutton','Units','normalized','Position',[0.01 0.07 0.06 0.04],...
    'String','<<','Callback',@(~,~) jump(-1));
uicontrol('Style','pushbutton','Units','normalized','Position',[0.08 0.07 0.06 0.04],...
    'String','>>','Callback',@(~,~) jump(+1));

% --- Bouton Play/Pause
btnPlay = uicontrol('Style','togglebutton','Units','normalized',...
    'Position',[0.15 0.07 0.06 0.04],'String','Play',...
    'Callback',@(~,~) togglePlay());

% --- Premier affichage
updateFrame(1);

% ---- Callbacks ----
    function kq = roundToStep(v)
        v = max(1, min(Ttot, v));
        kq = 1 + step * round((v-1)/step);
        if kq > Ttot, kq = Ttot; end
        set(slider,'Value',kq);
    end

    function setStep(s)
        if ~isscalar(s) || ~isfinite(s) || s < 1
            s = 1;
        end
        s = round(s);
        if s > Ttot, s = Ttot; end
        step = s;
        set(editStep,'String',num2str(step));
        set(slider,'SliderStep',[max(step/(Ttot-1),eps) min(10*step/(Ttot-1),1)]);
        updateFrame(roundToStep(get(slider,'Value')));
    end

    function jump(dir)
        k = round(get(slider,'Value')) + dir*step;
        k = max(1, min(Ttot, k));
        set(slider,'Value',k);
        updateFrame(k);
    end

    function changeView(val)
        switch val
            case 1, view(ax,3);
            case 2, view(ax,[0 0]);   % Front
            case 3, view(ax,[90 0]);  % Side
            case 4, view(ax,[0 90]);  % Top
        end
    end

    function togglePlay()
        playing = get(btnPlay,'Value');
        if playing
            set(btnPlay,'String','Pause');
            k = round(get(slider,'Value'));
            while playing && k <= Ttot && ishandle(f)
                slider.Value = k;
                updateFrame(k);
                drawnow;
                pause(0.05); % vitesse d'animation (ajuste si tu veux)
                k = k + step;
                playing = get(btnPlay,'Value');
            end
            set(btnPlay,'String','Play','Value',0);
        end
    end

    function updateFrame(k)
        cla(ax);
        % markers
        for im = 1:numel(names)
            P = MarkerR.(names{im});
            x = P(1,1,k); y = P(2,1,k); z = P(3,1,k);
            if ~any(isnan([x y z]))
                plot3(ax, x, y, z, 'o', 'MarkerSize',5,...
                    'Color','k','MarkerFaceColor','k');
            end
        end
        % frames
        for is = 1:numel(segments)
            seg = segments{is};
            if size(T_a.(seg),3) >= k && ~any(isnan(T_a.(seg)(:,:,k)),'all')
                plot_frame(T_a.(seg)(:,:,k),20,'','-');
            end
        end
        xlim(ax,lims.x); ylim(ax,lims.y); zlim(ax,lims.z);
        title(ax,sprintf('Frame %d / %d',k,Ttot));
        drawnow limitrate;
    end
end

% ---- helper ----
function lims = computeBounds(MarkerR)
names = fieldnames(MarkerR);
xmin=+inf; xmax=-inf; ymin=+inf; ymax=-inf; zmin=+inf; zmax=-inf;
for i=1:numel(names)
    P = MarkerR.(names{i});
    x = squeeze(P(1,1,:)); y = squeeze(P(2,1,:)); z = squeeze(P(3,1,:));
    xmin = min(xmin, min(x,[],'omitnan')); xmax = max(xmax, max(x,[],'omitnan'));
    ymin = min(ymin, min(y,[],'omitnan')); ymax = max(ymax, max(y,[],'omitnan'));
    zmin = min(zmin, min(z,[],'omitnan')); zmax = max(zmax, max(z,[],'omitnan'));
end
m = 0.05*max([xmax-xmin, ymax-ymin, zmax-zmin]);
lims.x = [xmin-m, xmax+m];
lims.y = [ymin-m, ymax+m];
lims.z = [zmin-m, zmax+m];
if ~all(isfinite([lims.x lims.y lims.z]))
    lims.x = [-100 100]; lims.y = [-100 100]; lims.z = [-100 100];
end
end
