function boundaryEdges = findArticularContour(Mesh1,Mesh2,threshold)

% Get vertices and faces
V1    = Mesh1.vertices(:,:,1)';
F1    = Mesh1.faces;
V2    = Mesh2.vertices(:,:,1)';
F2    = Mesh2.faces;

% Compute distance between meshes
D     = pdist2(V1',V2');
d_min = min(D,[],2);

% Define articular surface
isArticularVertex = d_min < threshold;
articularFaceMask = all(isArticularVertex(F1),2);
F_art             = F1(articularFaceMask,:);
TR_art            = triangulation(F_art,V1');

% Define articular surface contour
boundaryEdges = freeBoundary(TR_art);