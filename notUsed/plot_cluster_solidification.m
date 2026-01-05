function plot_cluster_solidification(X, X_solid, time, clusterName)
% PLOT_CLUSTER_SOLIDIFICATION  Compare trajectoires avant/après solidification
%
% INPUT
%   X         : T x 3 x Nmarkers  -> données originales
%   X_solid   : T x 3 x Nmarkers  -> données solidifiées
%   time      : T x 1  -> vecteur temps (s ou ms)
%   clusterName : string (nom du cluster, ex. 'TIB')
%
% Exemple :
%   plot_cluster_solidification(TIB, out_TIB.X_solid, time, 'TIB');

    if nargin < 4
        clusterName = '';
    end
    if nargin < 3 || isempty(time)
        time = (0:size(X,1)-1)';
    end

    [T,d,m] = size(X);
    assert(all(size(X_solid)==[T,d,m]), 'X et X_solid doivent avoir la même taille');

    colors = lines(m);

    figure('Name',['Solidification ' clusterName],'Color','w');

    coordNames = {'X','Y','Z'};
    for coord = 1:3
        subplot(3,1,coord); hold on; grid on;
        for j=1:m
            % Original
            plot(time, X(:,coord,j), '-', 'Color', colors(j,:), ...
                 'LineWidth', 1.0, 'DisplayName', sprintf('M%d avant',j));
            % Solidifié
            plot(time, X_solid(:,coord,j), '--', 'Color', colors(j,:), ...
                 'LineWidth', 1.8, 'DisplayName', sprintf('M%d après',j));
        end
        xlabel('Temps');
        ylabel(coordNames{coord});
        title([clusterName ' - Coordonnée ' coordNames{coord}]);
    end
    legend('show');
end
