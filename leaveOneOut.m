function [rho_loo,p_loo,R_min,R_max,ax] = leaveOneOut(FRRM_median,data_median,R,P,correlationType,paramLabel,color,ax,iplot)

% Count specimens
nSpecimen = size(FRRM_median,2);

% Leave-one-out
rho_loo   = nan(1,nSpecimen);
p_loo     = nan(1,nSpecimen);
for i = 1:nSpecimen
    idx         = setdiff(1:nSpecimen,i);
    [Rtmp,Ptmp] = corr(FRRM_median(idx)',data_median(idx)','Type',correlationType);
    rho_loo(i)  = Rtmp(1,1);
    p_loo(i)    = Ptmp(1,1);
end    

R_min = min(rho_loo);
R_max = max(rho_loo);

% Plot results
ax(iplot) = subplot(1,3,iplot); 
% figure;
b1 = bar(1:nSpecimen,rho_loo); hold on; box on; grid on;
set(b1,'FaceColor','flat');
b1.CData = color;
yline(R,'Linestyle','--','LineWidth',2,'Color','black');
xlabel('Specimen');
xticks(1:1:10);
xticklabels({'S1','S2','S3','S4','S5','S6','S7','S8','S9','S10'});
ylabel('Pearson correlation');
% % subplot(1,5,5);
% figure;
% b2 = bar(1:nSpecimen,p_loo); hold on; box on; grid on;
% set(b2,'FaceColor','flat');
% b2.CData = colorList(1:nSpecimen,:);
% yline(P,'Linestyle','--','LineWidth',2,'Color','black');
% xlabel('Specimen');
% xticks(1:1:10);
% xticklabels({'A1','A2','A3','A4','A5','S1','S2','S3','S4','S5'});
% ylabel('p-value');