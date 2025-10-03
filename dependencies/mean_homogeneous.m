function Tmean = mean_homogeneous(Tall)
% MEAN_HOMOGENEOUS  Moyenne d'un ensemble de matrices homogènes
% INPUT
%   Tall : 4x4xN
% OUTPUT
%   Tmean : 4x4

N = size(Tall,3);
Rall = zeros(3,3,N);
Oall = zeros(3,N);

for i=1:N
    Rall(:,:,i) = Tall(1:3,1:3,i);
    Oall(:,i)   = Tall(1:3,4,i);
end

% --- moyenne rotation par méthode SVD (Markley)
M = zeros(4,4);
for i=1:N
    q = rotm2quat(Rall(:,:,i));
    M = M + q'*q;
end
[~,~,V] = svd(M);
qmean = V(:,1)';
Rmean = quat2rotm(qmean);

% --- moyenne translation
Omean = mean(Oall,2);

% --- reconstruction homogène
Tmean = eye(4);
Tmean(1:3,1:3) = Rmean;
Tmean(1:3,4)   = Omean;
end
