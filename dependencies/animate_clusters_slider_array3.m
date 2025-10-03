function animate_clusters_slider_array3(Xcells, time, ax, opts)
% ANIMATE_CLUSTERS_SLIDER
% Animation interactive de clusters rigides (3x1xTx4)
% avec slider + bouton Play/Pause
%
% INPUT
%   Xcells : cell array, chaque élément = struct avec :
%            .X : 3x1xTx4  (trajectoires corrigées ou brutes)
%            .S : 3x4      (forme rigide moyenne du cluster)
%   time   : vecteur temps (T)
%   ax     : axes
%   opts   : struct optionnel
%            .showMarkers (default=true)
%            .showFrames  (default=false)
%            .frameScale  (default=20)

if nargin < 4, opts = struct(); end
showMarkers = get_opt(opts,'showMarkers',true);
showFrames  = get_opt(opts,'showFrames',false);
frameScale  = get_opt(opts,'frameScale',20);

nClust = numel(Xcells);
T = size(Xcells{1}.X,3);

colors = lines(nClust*4);
pts = cell(nClust,1);
frames = cell(nClust,1);

% --- Conversion interne et init ---
for c = 1:nClust
    Xcells{c}.Xmat = squeeze(permute(Xcells{c}.X,[1 4 3 2])); % 3x4xT
    if showMarkers
        Xmat = Xcells{c}.Xmat;
        [~,m,~] = size(Xmat);
        pts{c} = gobjects(m,1);
        for j=1:m
            pts{c}(j) = plot3(ax, Xmat(1,j,1), Xmat(2,j,1), Xmat(3,j,1), 'o', ...
                'MarkerFaceColor', colors((c-1)*m+j,:), ...
                'MarkerEdgeColor', 'k', ...
                'MarkerSize', 6, ...
                'DisplayName', sprintf('C%d-M%d',c,j));
        end
    end
    if showFrames
        frames{c} = plot_frame_obj(ax, eye(4), frameScale); % placeholder
    end
end

xlabel(ax,'X'); ylabel(ax,'Y'); zlabel(ax,'Z');
axis(ax,'equal'); legend(ax,'show');
title(ax,sprintf('t = %.3f',time(1)));

% --- Limites globales ---
allPts = [];
for c = 1:nClust
    allPts = [allPts, reshape(Xcells{c}.Xmat,3,[])];
end
axis(ax, [min(allPts(1,:)) max(allPts(1,:)) ...
          min(allPts(2,:)) max(allPts(2,:)) ...
          min(allPts(3,:)) max(allPts(3,:))]);

% --- Slider ---
f = ancestor(ax,'figure');
sld = uicontrol('Style','slider','Parent',f,...
    'Min',1,'Max',T,'Value',1,...
    'SliderStep',[1/(T-1), 10/(T-1)],...
    'Units','normalized','Position',[0.25 0.02 0.5 0.05],...
    'Callback',@(src,~) updateFrame(round(src.Value)));

% --- Bouton Play/Pause ---
btn = uicontrol('Style','togglebutton','Parent',f,...
    'String','Play','Units','normalized',...
    'Position',[0.8 0.02 0.15 0.05],...
    'Callback',@togglePlay);

playing = false;
k = 1;

% --- Update frame ---
    function updateFrame(kNew)
        k = max(1,min(T,kNew));
        for c = 1:nClust
            Xmat = Xcells{c}.Xmat;
            if showMarkers
                [~,m,~] = size(Xmat);
                for j=1:m
                    set(pts{c}(j),'XData',Xmat(1,j,k), ...
                                   'YData',Xmat(2,j,k), ...
                                   'ZData',Xmat(3,j,k));
                end
            end
            if showFrames
                % calculer la pose rigide frame k
                [R,t] = kabsch_fit(Xcells{c}.S, Xmat(:,:,k));
                Tmat = [R t; 0 0 0 1];
                update_frame_obj(frames{c}, Tmat, frameScale);
            end
        end
        title(ax,sprintf('t = %.3f',time(k)));
        set(sld,'Value',k);
        drawnow;
    end

    function togglePlay(src,~)
        playing = get(src,'Value');
        if playing
            set(src,'String','Pause');
            while playing && k<T && ishandle(src)
                k = k+1;
                updateFrame(k);
                pause(0.02);
                playing = get(src,'Value');
            end
            if k>=T
                set(src,'Value',0,'String','Play');
                playing=false;
            end
        else
            set(src,'String','Play');
        end
    end
end

% ========== Helpers pour frames ==========
function h = plot_frame_obj(ax,T,scale)
O = T(1:3,4);
X = T(1:3,1)*scale;
Y = T(1:3,2)*scale;
Z = T(1:3,3)*scale;
hx = quiver3(ax,O(1),O(2),O(3),X(1),X(2),X(3),'r','LineWidth',2);
hy = quiver3(ax,O(1),O(2),O(3),Y(1),Y(2),Y(3),'g','LineWidth',2);
hz = quiver3(ax,O(1),O(2),O(3),Z(1),Z(2),Z(3),'b','LineWidth',2);
h = {hx,hy,hz};
end

function update_frame_obj(h,T,scale)
O = T(1:3,4);
X = T(1:3,1)*scale;
Y = T(1:3,2)*scale;
Z = T(1:3,3)*scale;
set(h{1},'XData',O(1),'YData',O(2),'ZData',O(3),...
         'UData',X(1),'VData',X(2),'WData',X(3));
set(h{2},'XData',O(1),'YData',O(2),'ZData',O(3),...
         'UData',Y(1),'VData',Y(2),'WData',Y(3));
set(h{3},'XData',O(1),'YData',O(2),'ZData',O(3),...
         'UData',Z(1),'VData',Z(2),'WData',Z(3));
end

function [R,t]=kabsch_fit(A,B)
Ac=A-mean(A,2); Bc=B-mean(B,2);
H=Ac*Bc.'; [U,~,V]=svd(H);
R=V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
t=mean(B,2)-R*mean(A,2);
end

function val = get_opt(s,fld,def)
if isfield(s,fld)&&~isempty(s.(fld)), val=s.(fld); else, val=def; end
end
