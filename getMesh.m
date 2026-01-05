function [faces2,verticesT,vertices2,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile,Marker1,Marker2,Marker3,Marker4,distalPoint)

distalPointT = [];

% --- Lecture STL ---
[v,f,n]    = stlRead(meshFile);
vertices   = permute(v,[2,1,3])';
faces      = permute(f,[2,1,3])';
[v2,f2,n2] = stlRead(meshFile2);
vertices2  = permute(v2,[2,1,3])';
faces2     = permute(f2,[2,1,3])';

% --- Lecture FCSV (ignore les #, ne garde que x,y,z = colonnes 2..4) ---
fid = fopen(fcsvFile,'r');
if fid < 0, error('Impossible d''ouvrir %s', fcsvFile); end
lines = textscan(fid,'%s','Delimiter','\n','Whitespace','');
fclose(fid);
lines = lines{1};

xyz = [];   % on empile ici
for k = 4:numel(lines)
    s = strtrim(lines{k});
    if isempty(s) || startsWith(s,'#')
        continue
    end
    parts = strsplit(s, ',');  % CSV
    if numel(parts) < 4
        continue
    end
    xyz(k-3,1) = str2double(parts{2}); %#ok<SAGROW>  % x
    xyz(k-3,2) = str2double(parts{3}); %#ok<SAGROW>  % y
    xyz(k-3,3) = str2double(parts{4}); %#ok<SAGROW>  % z
end
landmarks = xyz;                 % unités du FCSV (ici mm: LPS)

% ⚠️ Unités : vérifie que ton STL est dans la même unité que le FCSV.
% Si le mesh est en mètres et le FCSV en mm, convertis: landmarks = landmarks * 1e-3;

nLm = size(landmarks,1);
if nLm ~= 4
    warning('Nombre de landmarks lu = %d (attendu = 4).', nLm);
end

% --- Connectivité du mesh (composantes connexes) ---
edges = [faces(:,[1 2]); faces(:,[2 3]); faces(:,[3 1])];
edges = sort(edges,2);
edges = unique(edges,'rows');
G = graph(edges(:,1), edges(:,2));
componentIdx = conncomp(G);   % taille = nbVertices

% --- Associer chaque landmark au noeud le plus proche et calculer centroïdes ---
lmNodes  = zeros(nLm,1);
centroid = zeros(nLm,3);      % <-- ta variable finale (4 x 3)

for i = 1:nLm
    % nœud du mesh le plus proche du landmark
    [~, lmNodes(i)] = min(vecnorm(vertices - landmarks(i,:), 2, 2));
    % tous les nœuds de la même composante connexe
    compNodes = find(componentIdx == componentIdx(lmNodes(i)));
    % centroïde de cette composante
    centroid(i,:) = mean(vertices(compNodes,:), 1);
end

if isempty(Marker1) % Only for LAX-EX-A3_Klaue
    for t = 1:size(Marker2,3)
        x = centroid([2,3,4],:);
        y = [Marker2(1,:,t) Marker2(2,:,t) Marker2(3,:,t); ...
             Marker3(1,:,t) Marker3(2,:,t) Marker3(3,:,t); ...
             Marker4(1,:,t) Marker4(2,:,t) Marker4(3,:,t)];
        [R,d,rms(t)] = soder(x,y);
        verticesT(:,:,t) = R*vertices2'+d;
        if ~isempty(distalPoint)
            distalPointT(:,:,t) = R*distalPoint+d;
        end
    end
elseif isempty(Marker2) % Only for LAX-EX-A4, LAX-EX-A4_Klaue
    for t = 1:size(Marker1,3)
        x = centroid([1,3,4],:);
        y = [Marker1(1,:,t) Marker1(2,:,t) Marker1(3,:,t); ...
             Marker3(1,:,t) Marker3(2,:,t) Marker3(3,:,t); ...
             Marker4(1,:,t) Marker4(2,:,t) Marker4(3,:,t)];
        [R,d,rms(t)] = soder(x,y);
        verticesT(:,:,t) = R*vertices2'+d;
        if ~isempty(distalPoint)
            distalPointT(:,:,t) = R*distalPoint+d;
        end
    end
elseif isempty(Marker3) % Only for LAX-EX-A3, LAX-EX-S1, LAX-EX-S2, LAX-EX-A1, LAX-EX-A3_Klaue
    for t = 1:size(Marker1,3)
        x = centroid([1,2,4],:);
        y = [Marker1(1,:,t) Marker1(2,:,t) Marker1(3,:,t); ...
             Marker2(1,:,t) Marker2(2,:,t) Marker2(3,:,t); ...
             Marker4(1,:,t) Marker4(2,:,t) Marker4(3,:,t)];
        [R,d,rms(t)] = soder(x,y);
        verticesT(:,:,t) = R*vertices2'+d;
        if ~isempty(distalPoint)
            distalPointT(:,:,t) = R*distalPoint+d;
        end
    end
elseif isempty(Marker4) % Only for LAX-EX-S3, LAX-EX-S5, LAX-EX-A2_Klaue
    for t = 1:size(Marker1,3)
        x = centroid([1,2,3],:);
        y = [Marker1(1,:,t) Marker1(2,:,t) Marker1(3,:,t); ...
             Marker2(1,:,t) Marker2(2,:,t) Marker2(3,:,t); ...
             Marker3(1,:,t) Marker3(2,:,t) Marker3(3,:,t)];
        [R,d,rms(t)] = soder(x,y);
        verticesT(:,:,t) = R*vertices2'+d;
        if ~isempty(distalPoint)
            distalPointT(:,:,t) = R*distalPoint+d;
        end
    end
else
    for t = 1:size(Marker1,3)
        x = centroid;
        y = [Marker1(1,:,t) Marker1(2,:,t) Marker1(3,:,t); ...
             Marker2(1,:,t) Marker2(2,:,t) Marker2(3,:,t); ...
             Marker3(1,:,t) Marker3(2,:,t) Marker3(3,:,t); ...
             Marker4(1,:,t) Marker4(2,:,t) Marker4(3,:,t)];
        [R,d,rms(t)] = soder(x,y);
        verticesT(:,:,t) = R*vertices2'+d;
        if ~isempty(distalPoint)
            distalPointT(:,:,t) = R*distalPoint+d;
        end
    end
end
% figure;
% plot(rms);