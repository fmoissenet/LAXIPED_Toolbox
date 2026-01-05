function illustrate_GPA()
% Simulation GPA sur un cluster 3D de 4 points
close all; figure('Color','w'); hold on; grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');

% Forme de référence
Smean = [0 30 30 0; 0 0 20 20; 0 0 0 0];

% Simuler 4 observations bruitées
colors = lines(4);
for i = 1:4
    % rotation et translation aléatoires
    R = axang2rotm([rand(1,3) rand(1,1)*pi/6]);
    t = randn(3,1)*5;
    noise = randn(3,4)*1.5;
    X = R*Smean + t + noise;
    plot3(X(1,:),X(2,:),X(3,:),'o-','Color',colors(i,:),'LineWidth',1.5);
end

% Forme moyenne
plot3(Smean(1,:),Smean(2,:),Smean(3,:),'ko-','LineWidth',2,'MarkerFaceColor','k');
title('GPA : alignement des clusters vers la forme moyenne rigide');
legend({'S(t1)','S(t2)','S(t3)','S(t4)','Forme moyenne Smean'},'Location','best');
view(30,30);
end
