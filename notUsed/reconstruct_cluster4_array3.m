function X_out = reconstruct_cluster4_array3_robust(X, S, opts)
% RECONSTRUCT_CLUSTER4_ARRAY3_ROBUST
% Reconstruction robuste d'un cluster 3x1xTx4 à partir d'une forme S (3x4).
% - Détecte les outliers par résidus robustes (MAD) + seuil absolu (mm)
% - Refit sur les inliers, reconstruit les outliers/manquants.
%
% INPUT
%   X    : 3x1xTx4 (mesures; (0,0,0) traité comme NaN)
%   S    : 3x4     (forme rigide moyenne)
%   opts : struct (facultatif)
%          .th_mm          (double)  seuil absolu en mm (def = 2)
%          .k_mad          (double)  facteur MAD (def = 2.5)
%          .replace_mode   (char)    'all' (def) ou 'outlier_only'
%
% OUTPUT
%   X_out : 3x1xTx4 (trajectoires reconstruites)

    if nargin < 3, opts = struct(); end
    th_mm        = get_opt(opts,'th_mm',2);      % mm
    k_mad        = get_opt(opts,'k_mad',2.5);
    replace_mode = get_opt(opts,'replace_mode','all'); % 'all' | 'outlier_only'

    [d,one,T,m] = size(X);
    assert(d==3 && one==1 && m==4, 'X doit être 3x1xTx4');

    % -> 3x4xT
    Xmat = squeeze(permute(X,[1 4 3 2]));
    % (0,0,0) -> NaN
    for t=1:T
        for j=1:4
            if all(Xmat(:,j,t)==0), Xmat(:,j,t)=NaN; end
        end
    end

    Xrec = Xmat;

    for t = 1:T
        Xt = Xmat(:,:,t);
        valid = find(~any(isnan(Xt),1));
        if numel(valid) < 3
            % Pas assez de points -> on laisse tel quel
            continue;
        end

        % --- Fit initial sur tous les valides ---
        [R0,t0] = kabsch_fit(S(:,valid), Xt(:,valid));
        Y0 = R0*S + t0;  % projection rigide
        % Résidus euclidiens par marqueur (mm)
        res = vecnorm(Y0 - Xt);
        res_mm = res(:)*1000;

        % --- Seuil robuste par MAD ---
        med  = median(res_mm(~isnan(res_mm)));
        madv = 1.4826*median(abs(res_mm(~isnan(res_mm))-med)+eps);
        thr  = max(th_mm, k_mad*madv);

        % Outliers = résidu > thr (uniquement parmi les valides)
        outliers = (res_mm(:) > thr) & ~any(isnan(Xt),1)';

        % Inliers = valides et non outliers
        inliers = setdiff(valid, find(outliers));

        if numel(inliers) >= 3
            % Refit sur inliers
            [R,tv] = kabsch_fit(S(:,inliers), Xt(:,inliers));
            Y = R*S + tv;

            switch replace_mode
                case 'all'
                    % On impose la rigidité sur tous (sortie = Y)
                    Xt_hat = Y;
                case 'outlier_only'
                    % On garde les mesurés pour inliers, on remplace outliers/manquants par Y
                    Xt_hat = Xt;
                    miss = find(any(isnan(Xt_hat),1));
                    rep_idx = union(find(outliers)', miss);
                    for jj = rep_idx
                        Xt_hat(:,jj) = Y(:,jj);
                    end
            end

            Xrec(:,:,t) = Xt_hat;

        else
            % Pas assez d'inliers -> on garde fit initial, et on reconstruit juste les manquants
            miss = find(any(isnan(Xt),1));
            Y = Y0;
            Xt_hat = Xt;
            for jj = miss
                Xt_hat(:,jj) = Y(:,jj);
            end

            % Optionnel : si replace_mode='all', impose la rigidité totale
            if strcmpi(replace_mode,'all')
                Xt_hat = Y;
            end
            Xrec(:,:,t) = Xt_hat;
        end
    end

    % -> 3x1xTx4
    X_out = permute(reshape(Xrec,[3,4,1,T]),[1 3 4 2]);
end

% ===== Helpers =====
function val = get_opt(s, fld, def)
    if isfield(s,fld) && ~isempty(s.(fld)), val = s.(fld); else, val = def; end
end

function [R,t] = kabsch_fit(A,B)
% A,B: 3xN
    Ac = A - mean(A,2); Bc = B - mean(B,2);
    H  = Ac*Bc.'; [U,~,V] = svd(H);
    R  = V*U.'; if det(R)<0, V(:,3)=-V(:,3); R=V*U.'; end
    t  = mean(B,2) - R*mean(A,2);
end
