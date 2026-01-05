function explore_clusters_slider(MarkerR, T_a, meshList, segments, step, meshes, dorsPt11, dorsPt12)
% EXPLORE_CLUSTERS_SLIDER + MESH ANIME
% - Slider + Play/Pause pour explorer les frames
% - Affiche marqueurs, repères anatomiques, et (optionnel) un mesh STL animé
%
% INPUTS
%   MarkerR   : struct de marqueurs rigides (3x1xT) par champ
%   T_a       : struct de repères anatomiques (4x4xT) par champ (segments)
%   segments  : cellstr des noms de segments (champs de T_a)
%   step      : pas d'incrément slider (def 1)
%   faces     : (optionnel) indices triangles STL (Nx3) [0- or 1-based]
%   verticesT : (optionnel) sommets du mesh au cours du temps, format 3 x N x T
%
% Exemple d'appel :
%   explore_clusters_slider(MarkerR, T_a, segments, 1, faces, verticesT)

if nargin < 4 || isempty(step), step = 1; end
hasMesh = (nargin >= 5) && ~isempty(meshes(1).faces) && ~isempty(meshes(1).verticesT);

names = fieldnames(MarkerR);
Ttot  = inferTotalFrames(MarkerR, T_a, hasMesh, meshes(1).verticesT);

% bornes fixes incluant markers (+ mesh si fourni)
lims = computeBoundsAll(MarkerR, hasMesh, meshes(1).verticesT);

% --- Figure et Axes
f = figure('Name','Clusters explorer','Color','w');
ax = axes('Parent',f); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
xlabel(ax,'X'); ylabel(ax,'Y'); zlabel(ax,'Z'); view(ax,3);
xlim([-150, 120]); ylim([0, 200]); zlim([100, 300]);%xlim(ax, lims.x); ylim(ax, lims.y); zlim(ax, lims.z);

% --- (Optionnel) MESH : préparation et 1er affichage
pMesh = [];
N = numel(meshList);
palette = bonePalette(N, [0 0 1], 0.1, 0.8, 0.7); % tons osseux + distincts
% for imesh = meshList
%     if hasMesh
%         facesLocal = meshes(imesh).faces;
%         if min(facesLocal(:)) == 0
%             facesLocal = facesLocal + 1;  % STL 0-based -> 1-based
%         end
%         V0 = getMeshVerticesAt(meshes(imesh).verticesT, 1); % Nx3 depuis 3xNxT
%         color = palette(imesh,:);
%         pMesh = patch('Faces',facesLocal,'Vertices',V0, ...
%                       'FaceColor',color, ... % couleur os mat
%                       'EdgeColor','none', ...   % contours gris foncé
%                       'LineWidth',0.1, ...
%                       'FaceAlpha',1, ...
%                       'Parent',ax,'DisplayName','Bone','Tag','bone');
%         lighting(ax,'gouraud'); material(ax,'default'); % camlight(ax,'infinite');
%     end
% end

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

% --- Premier affichage (sans claquer la scène)
updateFrame(1);

% ---- Callbacks ----
    function kq = roundToStep(v)
        v = max(1, min(Ttot, v));
        kq = 1 + step * round((v-1)/step);
        if kq > Ttot, kq = Ttot; end
        set(slider,'Value',kq);
    end

    function setStep(s)
        if ~isscalar(s) || ~isfinite(s) || s < 1, s = 1; end
        s = round(s); if s > Ttot, s = Ttot; end
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
                pause(0.05); % vitesse d’animation
                k = k + step;
                playing = get(btnPlay,'Value');
            end
            set(btnPlay,'String','Play','Value',0);
        end
    end

    function updateFrame(k)
        delete(findobj(ax,'Tag','marker'));
        delete(findobj(ax,'Tag','framevec'));
        delete(findobj(ax,'Tag','frametxt'));
        delete(findobj(ax,'Tag','mesh'));
%         % markers
%         for im = 1:numel(names)
%             P = MarkerR.(names{im});
%             x = P(1,1,k); y = P(2,1,k); z = P(3,1,k);
%             if ~any(isnan([x y z]))
%                 plot3(ax, x, y, z, 'o', 'MarkerSize',5,'Color','k','MarkerFaceColor','k','Tag','marker');
%             end
%         end
%         % frames
%         for is = 1:numel(segments)
%             seg = segments{is};
%             if size(T_a.(seg),3) >= k && ~any(isnan(T_a.(seg)(:,:,k)),'all')
%                 plot_frame(T_a.(seg)(:,:,k),20,'','-');
%             end
%         end
        % Dorsal point META1/CUMED
        xD1 = dorsPt11(1,1,k); yD1 = dorsPt11(2,1,k); zD1 = dorsPt11(3,1,k);
        plot3(ax, xD1, yD1, zD1, 'o', 'MarkerSize',5,'Color','r','MarkerFaceColor','r','Tag','marker');
        xD2 = dorsPt12(1,1,k); yD2 = dorsPt12(2,1,k); zD2 = dorsPt12(3,1,k);
        plot3(ax, xD2, yD2, zD2, 'o', 'MarkerSize',5,'Color','g','MarkerFaceColor','g','Tag','marker');
        % mesh animé
        for imesh = meshList
            if hasMesh
                pMesh = [];
                facesLocal = meshes(imesh).faces;
                if min(facesLocal(:)) == 0
                    facesLocal = facesLocal + 1;  % STL 0-based -> 1-based
                end
                Vt = getMeshVerticesAt(meshes(imesh).verticesT, k); % Nx3 depuis 3xNxT
                color = palette(imesh,:);
                pMesh = patch('Faces',facesLocal,'Vertices',Vt, ...
                              'FaceColor',color, 'EdgeColor','none', 'FaceAlpha',1, ...
                              'Parent',ax,'DisplayName','Mesh','Tag','mesh');
                lighting(ax,'gouraud'); material(ax,'default'); % camlight(ax,'infinite');
            end
            xlim([-150, 100]); ylim([0, 200]); zlim([100, 300]);%xlim(ax,lims.x); ylim(ax,lims.y); zlim(ax,lims.z);
            title(ax,sprintf('Frame %d / %d',k,Ttot));
        end
        drawnow limitrate;
    end
end

% ---------- helpers ----------
function Ttot = inferTotalFrames(MarkerR, T_a, hasMesh, verticesT)
Ttot = 1;
if ~isempty(MarkerR)
    fn = fieldnames(MarkerR);
    if ~isempty(fn), Ttot = max(Ttot, size(MarkerR.(fn{1}),3)); end
end
if ~isempty(T_a)
    fs = fieldnames(T_a);
    for i=1:numel(fs)
        Ttot = max(Ttot, size(T_a.(fs{i}),3));
    end
end
if hasMesh
    Ttot = max(Ttot, size(verticesT,3));
end
end

function lims = computeBoundsAll(MarkerR, hasMesh, verticesT)
% bornes markers
limsM = computeBounds(MarkerR);
if hasMesh
    % bornes mesh (sur toutes les frames)
    [xmin,xmax,ymin,ymax,zmin,zmax] = meshBounds(verticesT);
    span = max([xmax-xmin, ymax-ymin, zmax-zmin]);
    m = 0.05*span;
    lims.x = [min(limsM.x(1), xmin-m), max(limsM.x(2), xmax+m)];
    lims.y = [min(limsM.y(1), ymin-m), max(limsM.y(2), ymax+m)];
    lims.z = [min(limsM.z(1), zmin-m), max(limsM.z(2), zmax+m)];
else
    lims = limsM;
end
% valeurs fallback
if ~all(isfinite([lims.x lims.y lims.z]))
    lims.x = [-100 100]; lims.y = [-100 100]; lims.z = [-100 100];
end
end

function [xmin,xmax,ymin,ymax,zmin,zmax] = meshBounds(verticesT)
% verticesT: 3 x N x T
V = reshape(verticesT, 3, []); % 3 x (N*T)
xmin = min(V(1,:)); xmax = max(V(1,:));
ymin = min(V(2,:)); ymax = max(V(2,:));
zmin = min(V(3,:)); zmax = max(V(3,:));
end

function V = getMeshVerticesAt(verticesT, k)
% retourne Nx3 pour la frame k, à partir d'un 3 x N x T
V = squeeze(verticesT(:,:,k))'; % (3xN)' -> Nx3
end

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
span = max([xmax-xmin, ymax-ymin, zmax-zmin]);
m = 0.05*span;
lims.x = [xmin-m, xmax+m];
lims.y = [ymin-m, ymax+m];
lims.z = [zmin-m, zmax+m];
if ~all(isfinite([lims.x lims.y lims.z]))
    lims.x = [-100 100]; lims.y = [-100 100]; lims.z = [-100 100];
end
end


function C = bonePalette(N, baseColor, mix, S, V)
% N : nombre de meshes
% baseColor : teinte os (par ex. [0.78 0.73 0.60])
% mix : part de baseColor dans le mix (0–1), typiquement 0.6
% S,V : saturation et value pour la composante HSV (0–1)
    if nargin<2, baseColor = [0.78 0.73 0.60]; end
    if nargin<3, mix = 0.6; end
    if nargin<4, S = 0.15; end
    if nargin<5, V = 0.85; end

    phi = (sqrt(5)-1)/2;              % ≈ 0.618, bon pour écarter les teintes
    H = mod((0:N-1)*phi, 1);          % teintes réparties
    hsv = [H(:), repmat(S,N,1), repmat(V,N,1)];
    rgb = hsv2rgb(hsv);               % couleurs pastels distinctes

    C = mix*baseColor + (1-mix)*rgb;  % osseux + distinct
    C = min(max(C,0),1);              % clamp

    % petite sécurité anti-coïncidences exactes
    for k = 2:N
        if any(all(abs(C(1:k-1,:)-C(k,:)) < 1e-6, 2))
            C(k,:) = min(1, C(k,:) + [0.02 0 -0.02]);
        end
    end
end
