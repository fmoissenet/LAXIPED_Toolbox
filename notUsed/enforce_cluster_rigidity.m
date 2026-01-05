function out = enforce_cluster_rigidity(X_seg, opts)
% ENFORCE_CLUSTER_RIGIDITY (trimmed GPA + contrôle cinématique)
% Impose une forme constante (moyenne) à un cluster de 4 marqueurs et
% contrôle les sauts de Translation/Rotation frame->frame dans le repère du cluster.
%
% INPUT
%   X_seg : 3x1xT×4  (trajectoires des 4 marqueurs)
%   opts.trimFrac      : fraction de frames gardées (def=0.8)
%   opts.maxIter       : itérations GPA (def=10)
%   opts.tol           : tolérance convergence (def=1e-8)
%   ---- Contrôle de mouvement (dans le repère propre du cluster) ----
%   opts.motion.ref    : 'prev' (def) ou 'first'
%   opts.motion.maxRot : rotation max par frame (degrés, def=5)
%   opts.motion.maxTr  : translation max par frame (mm, def=2)
%   opts.motion.smoothWin : fenêtre médiane sur poses (impairs, ex 5) [optionnel]
%
% OUTPUT
%   out.Xrigid : 3x1xT×4 trajectoires corrigées (rigides)
%   out.Smean  : 3x4 forme moyenne
%   out.R, out.t : 3x3xT et 3xT (poses par frame, après contrôle)
%   out.usedIdx : indices des frames retenues par trimming

if nargin<2, opts = struct(); end
trimFrac = get_opt(opts,'trimFrac',0.8);
maxIter  = get_opt(opts,'maxIter',10);
tol      = get_opt(opts,'tol',1e-8);

% Contrôle de mouvement
mref      = get_opt_sub(opts,'motion','ref','prev');       % 'prev'|'first'
maxRotDeg = get_opt_sub(opts,'motion','maxRot',0.1);         % deg / frame
maxTr     = get_opt_sub(opts,'motion','maxTr',0.1);          % mm / frame
smoothWin = get_opt_sub(opts,'motion','smoothWin',[]);     % ex 5 (option)

[d,one,T,m] = size(X_seg);
assert(d==3 && one==1 && m==4,'X_seg doit être 3x1xT×4');

% ---- reformater en 3x4xT
X = squeeze(permute(X_seg,[1 4 3 2]));  % 3x4xT

% ---- 1) Estimation forme moyenne par trimmed GPA
[Smean, usedIdx] = mean_shape_trimmed(X, maxIter, trimFrac, tol);

% ---- 2) Projection rigide frame-by-frame
R = nan(3,3,T); t = nan(3,T); Xrig = nan(3,4,T);
for k=1:T
    Xt = X(:,:,k);
    valid = find(~any(isnan(Xt),1));
    if numel(valid) < 3, continue; end
    [Rk, tk] = kabsch_fit(Smean(:,valid), Xt(:,valid));
    R(:,:,k) = Rk;
    t(:,k)   = tk;
    Xrig(:,:,k) = Rk*Smean + tk;
end

% % ---- 3) Contrôle des translations/rotations dans le repère propre
% % Mesure des incréments dans le repère du cluster (body frame)
% [Rc,tc] = clamp_poses_bodywise(R, t, mref, maxRotDeg, maxTr);
% 
% % ---- 4) Lissage optionnel des poses (médiane sur quaternions et translations)
% if ~isempty(smoothWin) && smoothWin>=3 && mod(smoothWin,2)==1
%     [Rc,tc] = smooth_poses_quat_median(Rc, tc, smoothWin);
% end

% % ---- 4bis) Option d’amortissement progressif des rotations parasites ----
% alpha = get_opt_sub(opts,'motion','dampRot',[]); % 0 < alpha <= 1 (optionnel)
% if ~isempty(alpha) && alpha < 1 && alpha > 0
%     fprintf('[Rigidify] Damping rotations with alpha = %.2f\n', alpha);
%     T = size(Rc,3);
%     for k = 2:T
%         if any(isnan(Rc(:,:,k)),'all') || any(isnan(Rc(:,:,k-1)),'all')
%             continue;
%         end
%         % Rotation relative
%         R_rel = Rc(:,:,k-1)' * Rc(:,:,k);
%         % SLERP vers identité
%         R_rel_damped = slerp_rotm(eye(3), R_rel, alpha);
%         % Nouvelle orientation amortie
%         Rc(:,:,k) = Rc(:,:,k-1) * R_rel_damped;
%         % Translation correspondante (optionnel : amortir aussi)
%         t_rel = Rc(:,:,k-1)' * (tc(:,k) - tc(:,k-1));
%         tc(:,k) = tc(:,k-1) + Rc(:,:,k-1) * (alpha * t_rel);
%     end
% end
% 
% % ---- 5) Reprojection finale des marqueurs avec poses contrôlées
% Xrig2 = nan(3,4,T);
% for k=1:T
%     if any(isnan(Rc(:,:,k)),'all') || any(isnan(tc(:,k)))
%         continue
%     end
%     Xrig2(:,:,k) = Rc(:,:,k)*Smean + tc(:,k);
% end

% % ---- 5bis) Filtrage temporel quaternion pour supprimer rotations parasites ----
% Rsm = R; q = zeros(T,4);
% for k = 1:T
%     if any(isnan(Rc(:,:,k)),'all')
%         q(k,:) = [1 0 0 0];
%     else
%         q(k,:) = rotm2quat(Rc(:,:,k));
%     end
% end
% % Continuité des quaternions
% for k = 2:T
%     if dot(q(k-1,:),q(k,:)) < 0, q(k,:) = -q(k,:); end
% end
% % Filtrage temporel (moyenne glissante sur N=5 par défaut)
% N = 5;
% qf = q;
% for k = 1:T
%     a = max(1,k-floor(N/2)); b = min(T,k+floor(N/2));
%     qf(k,:) = mean(q(a:b,:),1,'omitnan');
%     qf(k,:) = qf(k,:)./norm(qf(k,:)+eps);
% end
% for k = 1:T
%     Rsm(:,:,k) = quat2rotm(qf(k,:));
% end
% 
% Rc = Rsm; % remplace orientations par version filtrée

% ---- sorties au format demandé
out.Xrigid  = permute(reshape(Xrig,[3,4,1,T]),[1 3 4 2]); % 3x1xT×4
% out.Xrigid  = permute(reshape(Xrig2,[3,4,1,T]),[1 3 4 2]); % 3x1xT×4
out.Smean   = Smean;
out.R       = R;
out.t       = t;
% out.R       = Rc;
% out.t       = tc;
out.usedIdx = usedIdx;
end

% ==================== Helpers ====================

function [S, usedIdx] = mean_shape_trimmed(X, maxIter, frac, tol)
% GPA avec trimming basé sur les longueurs intra-cluster
edges = nchoosek(1:4,2);
S = init_shape(X); usedIdx = 1:size(X,3);
for it=1:maxIter
    scores = []; idx = [];
    Lref = edge_lengths(S,edges);
    for k=1:size(X,3)
        Xt=X(:,:,k); if any(isnan(Xt(:))), continue; end
        L=edge_lengths(Xt-mean(Xt,2),edges);
        scores(end+1)=rms(L-Lref); idx(end+1)=k; %#ok<AGROW>
    end
    if isempty(scores), break; end
    [~,ord] = sort(scores,'ascend');
    nkeep = max(4, round(frac*numel(ord)));
    usedIdx = idx(ord(1:nkeep));

    % GPA (moyenne rigide) sur les frames gardées
    Snew = mean_shape_basic(X(:,:,usedIdx), 5, tol);
    if norm(Snew-S,'fro')<tol, S=Snew; break; end
    S=Snew;
end
end

function S = mean_shape_basic(X, maxIter, tol)
S = init_shape(X);
for it=1:maxIter
    A=zeros(3,4); n=0;
    for k=1:size(X,3)
        Xt=X(:,:,k); if any(isnan(Xt(:))), continue; end
        [R,~]=kabsch_fit(S,Xt);
        A = A + R'*(Xt-mean(Xt,2)); n=n+1;
    end
    if n==0, break; end
    Snew = A/n; Snew = Snew - mean(Snew,2);
    if norm(Snew-S,'fro')<tol, S=Snew; break; end
    S=Snew;
end
end

function S=init_shape(X)
S=zeros(3,4); n=0;
for k=1:size(X,3)
    Xt=X(:,:,k);
    if any(isnan(Xt(:))), continue; end
    S=S+(Xt-mean(Xt,2)); n=n+1;
end
if n>0, S=S/n; end
S=S-mean(S,2);
end

function L=edge_lengths(P,E)
L=zeros(size(E,1),1);
for i=1:size(E,1)
    L(i)=norm(P(:,E(i,2))-P(:,E(i,1)));
end
end

function [R,t]=kabsch_fit(A,B)
Ac=A-mean(A,2); Bc=B-mean(B,2);
H=Ac*Bc.'; [U,~,V]=svd(H);
R=V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
t=mean(B,2)-R*mean(A,2);
end

% ---------- contrôle de mouvement (repère propre) ----------
function [Rout,tout] = clamp_poses_bodywise(R,t, refMode, maxRotDeg, maxTr)
T = size(R,3);
Rout = R; tout = t;

% trouver première frame valide
k0 = find(~any(isnan(t),1) & all(isfinite(reshape(R,9,[])),1), 1, 'first');
if isempty(k0), return; end

for k = k0+1:T
    if any(isnan(t(:,k))) || any(isnan(t(:,k-1))), continue; end
    if any(isnan(R(:,:,k)),'all') || any(isnan(R(:,:,k-1)),'all'), continue; end

    switch lower(refMode)
        case 'prev'
            R_ref = Rout(:,:,k-1); t_ref = tout(:,k-1);
        case 'first'
            R_ref = Rout(:,:,k0);  t_ref = tout(:,k0);
        otherwise
            R_ref = Rout(:,:,k-1); t_ref = tout(:,k-1);
    end

    % incrément dans le repère "propre" (body frame du ref)
    R_inc = R_ref' * Rout(:,:,k);
    t_inc = R_ref' * (tout(:,k) - t_ref);

    ang = rotm_angle_deg(R_inc);          % deg
    trn = norm(t_inc);                    % mm

    % clamp si dépassement
    if ang > maxRotDeg || trn > maxTr
        % limiter rotation via slerp vers l'identité dans le body frame
        a = max(1e-6, ang);
        alpha = min(1, maxRotDeg / a);    % fraction gardée
        R_inc_clamped = slerp_rotm(eye(3), R_inc, alpha);

        % limiter translation par échelle
        if trn > 0
            beta = min(1, maxTr / trn);
        else
            beta = 1;
        end
        t_inc_clamped = t_inc * beta;

        % reconstruire la pose clampée
        Rout(:,:,k) = R_ref * R_inc_clamped;
        tout(:,k)   = t_ref + R_ref * t_inc_clamped;
    end
end
end

function ang = rotm_angle_deg(R)
% angle de rotation équivalent en degrés
c = (trace(R)-1)/2;
c = max(-1,min(1,c));
ang = acosd(c);
end

function R = slerp_rotm(Ra,Rb,alpha)
% SLERP sur SO(3) via quaternions
qa = rotm2quat(Ra); qb = rotm2quat(Rb);
q  = quat_slerp(qa,qb,alpha);
R  = quat2rotm(q);
end

% ---------- lissage médian sur poses (quaternions + translations) ----------
function [Rout,tout] = smooth_poses_quat_median(R,t,w)
T=size(R,3); Rout=R; tout=t;
q = zeros(T,4);
for k=1:T
    if any(isnan(R(:,:,k)),'all'), q(k,:) = [1 0 0 0]; else, q(k,:) = rotm2quat(R(:,:,k)); end
end
% unwrap quaternions (continuité de signe)
for k=2:T
    if dot(q(k-1,:),q(k,:))<0, q(k,:)=-q(k,:); end
end
% median filter (naïf) sur chaque composante
qf = q;
hf = floor(w/2);
for k=1:T
    a=max(1,k-hf); b=min(T,k+hf);
    qwin = q(a:b,:);
    qf(k,:) = median(qwin,1,'omitnan');
    qf(k,:) = qf(k,:)./norm(qf(k,:)+eps);
end
for k=1:T, Rout(:,:,k)=quat2rotm(qf(k,:)); end
% translations
for i=1:3
    tout(i,:) = medfilt1_omitnan(t(i,:), w);
end
end

function y = medfilt1_omitnan(x,w)
% médiane glissante simple (ignorer NaN)
T=numel(x); y=x; h=floor(w/2);
for k=1:T
    a=max(1,k-h); b=min(T,k+h);
    win=x(a:b); y(k)=median(win,'omitnan');
end
end

% ---------- outils quaternions (compatibles base MATLAB) ----------
function q = rotm2quat(R)
% [w x y z]
tr = trace(R);
if tr>0
    S = sqrt(tr+1.0)*2; % S=4w
    w = 0.25*S;
    x = (R(3,2)-R(2,3))/S;
    y = (R(1,3)-R(3,1))/S;
    z = (R(2,1)-R(1,2))/S;
else
    if R(1,1)>R(2,2) && R(1,1)>R(3,3)
        S = sqrt(1.0+R(1,1)-R(2,2)-R(3,3))*2;
        w = (R(3,2)-R(2,3))/S; x = 0.25*S;
        y = (R(1,2)+R(2,1))/S; z = (R(1,3)+R(3,1))/S;
    elseif R(2,2)>R(3,3)
        S = sqrt(1.0+R(2,2)-R(1,1)-R(3,3))*2;
        w = (R(1,3)-R(3,1))/S; x = (R(1,2)+R(2,1))/S;
        y = 0.25*S; z = (R(2,3)+R(3,2))/S;
    else
        S = sqrt(1.0+R(3,3)-R(1,1)-R(2,2))*2;
        w = (R(2,1)-R(1,2))/S; x = (R(1,3)+R(3,1))/S;
        y = (R(2,3)+R(3,2))/S; z = 0.25*S;
    end
end
q = [w x y z];
q = q ./ norm(q+eps);
end

function R = quat2rotm(q)
q = q ./ (norm(q)+eps);
w=q(1); x=q(2); y=q(3); z=q(4);
R = [1-2*(y^2+z^2)  2*(x*y - z*w)  2*(x*z + y*w);
     2*(x*y + z*w)  1-2*(x^2+z^2)  2*(y*z - x*w);
     2*(x*z - y*w)  2*(y*z + x*w)  1-2*(x^2+y^2)];
end

function q = quat_slerp(q0,q1,alpha)
% SLERP basique, alpha in [0,1]
if dot(q0,q1)<0, q1=-q1; end
omega = acos(max(-1,min(1,dot(q0,q1))));
if omega<1e-8
    q = q0;
else
    q = (sin((1-alpha)*omega)/sin(omega))*q0 + (sin(alpha*omega)/sin(omega))*q1;
end
q = q./(norm(q)+eps);
end

function val = get_opt(s,f,def)
if isfield(s,f) && ~isempty(s.(f)), val=s.(f); else, val=def; end
end
function val = get_opt_sub(s,root,f,def)
if isfield(s,root) && isstruct(s.(root)) && isfield(s.(root),f) && ~isempty(s.(root).(f))
    val = s.(root).(f);
else
    val = def;
end
end
