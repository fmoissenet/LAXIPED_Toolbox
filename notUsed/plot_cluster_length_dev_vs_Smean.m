function plot_cluster_length_dev_vs_Smean(Xrigid, Smean, segName)
% Compare les longueurs aux longueurs de la forme moyenne (Smean)

X = squeeze(permute(Xrigid,[1 4 3 2])); % 3x4xT
edges = [1 2; 2 3; 3 4; 4 1; 1 3; 2 4];

% Longueurs de la forme moyenne (constantes)
Ls = zeros(6,1);
for e=1:6, a=edges(e,1); b=edges(e,2);
    Ls(e) = norm(Smean(:,b)-Smean(:,a));
end

% Longueurs par frame
T = size(X,3); L = nan(6,T);
for t=1:T
    Xt = X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    for e=1:6
        a=edges(e,1); b=edges(e,2);
        L(e,t) = norm(Xt(:,b) - Xt(:,a));
    end
end

Ldev = L - Ls;  % ΔL(t) = L(t) - L_Smean

figure('Name',['ΔL vs Smean - ' segName],'Color','w');
for e=1:6
    subplot(2,3,e); hold on; grid on;
    plot(Ldev(e,:),'k');
    yline(0,'r--','LineWidth',1.2);
    title(sprintf('Edge %d-%d',edges(e,1),edges(e,2)));
    xlabel('Frame'); ylabel('ΔL (unités des données)');
end
sgtitle(['Deviation from Smean lengths: ' segName]);

% Sanity check console
mx = max(abs(Ldev),[],'all','omitnan');
fprintf('[%s] max|ΔL| = %.6g (doit être ~0)\n', segName, mx);
end
