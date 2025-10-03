function plot_cluster_lengths(Xrigid, segName)
% PLOT_CLUSTER_LENGTH_DEV : Vérifie la rigidité d'un cluster
% en affichant (longueur - moyenne) pour chaque arête.
%
% INPUT
%   Xrigid  : 3x1xT×4 (trajectoires rigidifiées d’un cluster)
%   segName : nom du segment (string)

% Reformater en 3x4xT
X = squeeze(permute(Xrigid,[1 4 3 2]));
edges = [1 2; 2 3; 3 4; 4 1; 1 3; 2 4];

% Longueurs par frame
T = size(X,3);
L = nan(6,T);
for t=1:T
    if any(isnan(X(:,:,t))), continue; end
    for e=1:6
        a=edges(e,1); b=edges(e,2);
        L(e,t) = norm(X(:,a,t)-X(:,b,t));
    end
end

% Déviation par rapport à la moyenne
Lmean = mean(L,2,'omitnan');
Ldev  = L - Lmean;

% Plot
figure('Name',['Cluster length deviations ' segName],'Color','w');
for e=1:6
    subplot(2,3,e); hold on; grid on;
    plot(Ldev(e,:),'k');
    title(sprintf('Edge %d-%d',edges(e,1),edges(e,2)));
    xlabel('Frame'); ylabel('ΔL');
end
sgtitle(['Deviation from mean lengths: ' segName]);