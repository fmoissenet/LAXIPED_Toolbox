function animate_clusters_slider(Xcells, time, ax)
% ANIMATE_CLUSTERS_SLIDER
% Animation interactive de plusieurs clusters
% INPUT
%   Xcells : cell array, chaque élément est 3x1xTx4 (coords x 1 x frames x markers)
%   time   : vecteur temps (T x 1)
%   ax     : axes où tracer

nClust = numel(Xcells);
T = size(Xcells{1},3);

colors = lines(nClust*4);

pts = cell(nClust,1);

% --- Initialisation ---
for c = 1:nClust
    % convertir 3x1xTx4 → 3x4xT
    Xmat = squeeze(permute(Xcells{c}, [1 4 3 2])); % 3x4xT
    
    [~,m,~] = size(Xmat);
    pts{c} = gobjects(m,1);
    
    for j=1:m
        pts{c}(j) = plot3(ax, Xmat(1,j,1), Xmat(2,j,1), Xmat(3,j,1), 'o', ...
            'MarkerFaceColor', colors((c-1)*m+j,:), ...
            'MarkerEdgeColor', 'k', ...
            'MarkerSize', 6, ...
            'DisplayName', sprintf('C%d-M%d',c,j));
    end
    
    % stocker les données converties pour mise à jour
    Xcells{c} = Xmat;
end

xlabel(ax,'X'); ylabel(ax,'Y'); zlabel(ax,'Z');
axis(ax,'equal'); legend(ax,'show');
title(ax,sprintf('t = %.3f',time(1)));

% --- Limites globales ---
allPts = [];
for c = 1:nClust
    allPts = [allPts, reshape(Xcells{c},3,[])];
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

% --- Fonction de mise à jour ---
    function updateFrame(k)
        for c = 1:nClust
            Xmat = Xcells{c};
            [~,m,~] = size(Xmat);
            for j = 1:m
                set(pts{c}(j),'XData',Xmat(1,j,k), ...
                               'YData',Xmat(2,j,k), ...
                               'ZData',Xmat(3,j,k));
            end
        end
        title(ax,sprintf('t = %.3f',time(k)));
        drawnow;
    end
end
