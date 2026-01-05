function [R,P,ax] = computeCorrelation(construct,reference,correlationType,titleStr,yLabelStr,color,ax,iplot)

% Check normality
% The assumption of normality required for Pearson correlation was evaluated 
% using Shapiro–Wilk tests applied to the residuals of the linear regression 
% model, as recommended. When residuals were not normally distributed or 
% when the relationship was not strictly linear, Spearman rank correlations were used.
x          = median(construct,1);
y          = median(reference,1);
[r,p]      = corr(x',y','type',correlationType);
mdl        = fitlm(x, y);
res        = mdl.Residuals.Raw;
[H,pVal,W] = swtest(res,0.05);
if H == 0
    disp("construct: Résidus ~ normaux → Pearson valide");
else
    disp("construct: Résidus NON normaux → Pearson invalide → Spearman");
end

% Compute correlation
[R,P]       = corr(x',y','Type',correlationType);  
disp(['p value: ',num2str(P)]);

% Compute CI 95% using a bootstrap resampling
nspecimen   = size(construct,2);
nBoot       = 10000;
bootR       = zeros(nBoot,1);    
for b = 1:nBoot
    idx     = randi(nspecimen,nspecimen,1);
    bR(b)   = corr(x(idx)',y(idx)','Type',correlationType);
end
CI95        = prctile(bR,[2.5 97.5]);    
fprintf('Pearson r = %.3f (95%% CI [%.3f, %.3f])\n',R,CI95(1),CI95(2));

% Initialise figure
% figure(iplot);
% set(gcf,'Color','white');
% sgtitle(['Pearson correlation: R = ',num2str(round(R,2)),', p = ',num2str(round(P,3))],'FontSize',14);

% Plot construct
% subplot(1,5,1);
% grid on; box on; hold on;
% boxplot(construct);
% boxes = findobj(gca,'Tag','Box');
% boxes = flipud(boxes);
% for i = 1:length(boxes)
%     xBox = get(boxes(i),'XData');
%     yBox = get(boxes(i),'YData');
%     patch(xBox, yBox, colorList(i,:), ...
%           'FaceAlpha', 0.4, 'EdgeColor', colorList(i,:), 'LineWidth', 1.5);
% end     
% ylabel('construct');
% xlabel('Specimen');
% xticks(1:1:10);
% xticklabels({'A1','A2','A3','A4','A5','S1','S2','S3','S4','S5'});

% Plot boxplot
% subplot(1,5,2);
% boxplot(reference);
% boxes = findobj(gca,'Tag','Box');   % un objet par colonne
% boxes = flipud(boxes);
% for i = 1:length(boxes)
%     xBox = get(boxes(i),'XData');
%     yBox = get(boxes(i),'YData');
%     patch(xBox, yBox, colorList(i,:), ...
%           'FaceAlpha', 0.4, 'EdgeColor', colorList(i,:), 'LineWidth', 1.5);
% end  
% grid on; box on; hold on;
% if ~isempty(yLabelStr)
%     ylabel(yLabelStr);
% end        
% xlabel('Specimen');
% xticks(1:1:10);
% xticklabels({'A1','A2','A3','A4','A5','S1','S2','S3','S4','S5'});

% Plot data scatter
% subplot(1,5,3);
% [~,idx] = sort(y,'ascend');
% for k = 1:numel(idx)
%     col = idx(k);
% %     scatter(reference(:,col),construct(:,col), ...
% %             40, ...
% %             colorList(col,:), ...
% %             'filled', ...
% %             'MarkerFaceAlpha', 0.2);
%     scatter(y(:,col),x(:,col), ...
%             80, ...
%             [0.1 0.5 1], ... %colorList(col,:), ...
%             'filled', ...
%             'MarkerFaceAlpha', 0.8);
%     grid on; box on; hold on;
% end

% Plot relationship
% p            = polyfit(y(:,idx),x(:,idx),1);
% xFit         = y(:);
% yFit         = x(:);
% mdl          = fitlm(xFit,yFit); 
% xLine        = linspace(min(xFit),max(xFit),100)';
% [yLine,yCI] = predict(mdl,xLine);
% patch([xLine; flipud(xLine)], ...
%       [yCI(:,1); flipud(yCI(:,2))], ...
%       [0.1 0.5 1], ...                % couleur (noir)
%       'FaceAlpha', 0.1, ...       % transparence
%       'EdgeColor', 'none');       % pas de bord
% hold on;
% plot(xLine,yLine,'Linestyle','-','LineWidth',2,'Color',[0.1 0.5 1]);
% xlabel('Reference construct (mm)','FontSize',14);   % adapte le texte
% ylabel('Construct (mm)','FontSize',14);
% set(gca,'FontSize',14);
% grid on; box on;

% Check each specimen reference impact on computed correlation
% (leave-one-out process)
[rho_loo,p_loo,R_min,R_max,ax] = leaveOneOut(x,y,R,P,correlationType,titleStr,color,ax,iplot);
disp(['Leave-one-out analysis: [',num2str(R_min),'-',num2str(R_max),']']);