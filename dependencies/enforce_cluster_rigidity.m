function out = enforce_cluster_rigidity(X_seg, maxIter, tol)
% Impose rigidité d'un cluster par GPA simple
%
% INPUT
%   X_seg : 3x1xT×4 trajectoires
%   maxIter : itérations GPA (def=10)
%   tol     : tolérance convergence (def=1e-8)
%
% OUTPUT
%   out.Xrigid : 3x1xT×4 (trajectoires rigides)
%   out.Smean  : 3x4 forme moyenne
%   out.R, out.t : poses rigides par frame

if nargin<2, maxIter=10; end
if nargin<3, tol=1e-8; end

[d,one,T,m] = size(X_seg);
assert(d==3 && one==1 && m==4,'X_seg doit être 3x1xT×4');

% --- Reformater en 3x4xT
X = squeeze(permute(X_seg,[1 4 3 2]));

% --- Initialisation : moyenne centrée
S = zeros(3,4); n=0;
for t=1:T
    Xt = X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    S = S + (Xt - mean(Xt,2));
    n = n+1;
end
S = S / max(n,1);

% --- GPA itératif ---
for it=1:maxIter
    A = zeros(3,4); n=0;
    for t=1:T
        Xt = X(:,:,t);
        if any(isnan(Xt(:))), continue; end
        [R,~] = kabsch_fit(S, Xt);
        A = A + R'* (Xt - mean(Xt,2)); 
        n = n+1;
    end
    Snew = A / max(n,1);
    Snew = Snew - mean(Snew,2); % recentrage
    if norm(Snew-S,'fro') < tol
        break;
    end
    S = Snew;
end
Smean = S;

% --- Projection rigide frame-by-frame ---
Xrigid = nan(3,4,T); Rall=nan(3,3,T); tall=nan(3,T);
for t=1:T
    Xt = X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    [R,tv] = kabsch_fit(Smean, Xt);
    Xrigid(:,:,t) = R*Smean + tv;
    Rall(:,:,t) = R; tall(:,t) = tv;
end

% --- Reformater sortie ---
out.Xrigid = permute(reshape(Xrigid,[3,4,1,T]),[1 3 4 2]);
out.Smean  = Smean;
out.R = Rall; out.t = tall;
end

% --- Kabsch pour fit rigide ---
function [R,t]=kabsch_fit(A,B)
% A,B: 3xN
Ac=A-mean(A,2); Bc=B-mean(B,2);
H=Ac*Bc.'; [U,~,V]=svd(H);
R=V*U.'; 
if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
t=mean(B,2)-R*mean(A,2);
end