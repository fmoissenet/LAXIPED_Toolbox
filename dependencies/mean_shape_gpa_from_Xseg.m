function S = mean_shape_gpa_from_Xseg(X_seg)
% GPA basique pour obtenir une forme moyenne 3x4
X = squeeze(permute(X_seg,[1 4 3 2])); % 3x4xT
S=zeros(3,4); n=0;
for t=1:size(X,3)
    Xt=X(:,:,t);
    if any(isnan(Xt(:))), continue; end
    S=S+(Xt-mean(Xt,2)); n=n+1;
end
S=S/max(n,1); S=S-mean(S,2);
end
