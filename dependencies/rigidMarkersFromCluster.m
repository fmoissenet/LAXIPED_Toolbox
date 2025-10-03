function markers = rigidMarkersFromCluster(Xrigid)
% RIGIDMARKERSFROMCLUSTER
% Extrait les 4 marqueurs rigides d'un cluster 3x1xT×4
% 
% INPUT
%   Xrigid : 3x1xT×4 (trajectoires rigidifiées d’un cluster)
%
% OUTPUT
%   markers : cell array {M1,M2,M3,M4}, chaque M est 3x1xT

[d,one,T,m] = size(Xrigid);
assert(d==3 && one==1 && m==4, 'Format attendu: 3x1xT×4');

markers = cell(1,4);
for j = 1:4
    markers{j} = Xrigid(:,:,:,j); % 3x1xT
end
end
