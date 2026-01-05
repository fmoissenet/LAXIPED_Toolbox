function jointCentre = findJointCentre(Mesh1,Mesh2,boundaryEdges,iplot)

% Get vertices and faces
V1    = Mesh1.verticesT(:,:,1)';
F1    = Mesh1.faces;
V2    = Mesh2.verticesT(:,:,1)';
F2    = Mesh2.faces;

% Define contour points
contourPts   = V1(boundaryEdges(:),:);
contourVerts = unique(boundaryEdges(:));
contourPts   = V1(contourVerts,:);

% Set the joint centre as the centre of the contour points
jointCentre = mean(contourPts);

% Plot
if iplot == 1
    figure(500); axis equal; hold on;
    patch('Faces',F1,...
          'Vertices',V1,...
          'FaceColor',[0.5,0.5,0.5],...
          'EdgeColor','none',...
          'FaceLighting','Gouraud',...
          'FaceAlpha',1);
    patch('Faces',F2,...
          'Vertices',V2,...
          'FaceColor',[0.5,0.5,0.5],...
          'EdgeColor','none',...
          'FaceLighting','Gouraud',...
          'FaceAlpha',1);
    for k = 1:size(boundaryEdges,1)
        P = V1(boundaryEdges(k,:),:);
        plot3(P(:,1),P(:,2),P(:,3),'r-','LineWidth',2);
    end
    plot3(jointCentre(1),jointCentre(2),jointCentre(3), ...
          'Marker','o','Color','green','MarkerSize',10,'LineWidth',2);
    lighting(gca,'gouraud'); material(gca,'metal');
    light('Position',[1 0 1],'Style','infinite');
end