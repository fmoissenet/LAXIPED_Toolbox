function Measurement = plotDOF(side,Measurement,T_a,out,F,bone1,bone2,fmarker,lcycle,ijoint,tidx,iplot,type)

kplot = 0;

figure(iplot);
subplot(2,3,1); hold on; box on; grid on; title('Anterior (+) / Posterior (-) translation');
xlabel('Force (N)'); ylabel('Translation (mm)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
if strcmp(side,'Right')
    JT = permute(T_rel(1,4,:),[3,1,2]); 
elseif strcmp(side,'Left')
    JT = -permute(T_rel(1,4,:),[3,1,2]); 
end 
JT    = JT-JT(1);
JT    = JT(tidx);
Measurement(lcycle).Joint(ijoint).T1 = polyfit_array3(JT,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).T1,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).T1 = JT;
% plot(F,Measurement(lcycle).Joint(ijoint).T1,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

figure(iplot);
subplot(2,3,2); hold on; box on; grid on; title('Superior (+) / Inferior (-) translation');
xlabel('Force (N)'); ylabel('Translation (mm)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
JT    = permute(T_rel(2,4,:),[3,1,2]); 
JT    = JT-JT(1);
JT    = JT(tidx);
Measurement(lcycle).Joint(ijoint).T2 = polyfit_array3(JT,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).T2,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).T2 = JT;
% plot(F,Measurement(lcycle).Joint(ijoint).T2,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

figure(iplot);
subplot(2,3,3); hold on; box on; grid on; title('Lateral (+) / Medial (-) translation');
xlabel('Force (N)'); ylabel('Translation (mm)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
if strcmp(side,'Right')
    JT = permute(T_rel(3,4,:),[3,1,2]); 
elseif strcmp(side,'Left')
    JT = -permute(T_rel(3,4,:),[3,1,2]); 
end 
JT    = JT-JT(1);
JT    = JT(tidx);
Measurement(lcycle).Joint(ijoint).T3 = polyfit_array3(JT,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).T3,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).T3 = JT;
% plot(F,Measurement(lcycle).Joint(ijoint).T3,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

figure(iplot);
subplot(2,3,4); hold on; box on; grid on; title('Inversion (+) / Eversion (-)');
xlabel('Force (N)'); ylabel('Rotation (°)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
Euler = rad2deg(R2mobileYXZ_array3(T_rel(1:3,1:3,:))); % As for carpal bones
if strcmp(side,'Right')
    JR = permute(Euler(:,2,:),[3,1,2]); 
elseif strcmp(side,'Left')
    JR = -permute(Euler(:,2,:),[3,1,2]); 
end
JR    = JR-JR(1);
JR    = JR(tidx);
Measurement(lcycle).Joint(ijoint).R1 = polyfit_array3(JR,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).R1,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).R1 = JR;
% plot(F,Measurement(lcycle).Joint(ijoint).R1,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

figure(iplot);
subplot(2,3,5); hold on; box on; grid on; title('Internal (+) / External (-) rotation');
xlabel('Force (N)'); ylabel('Rotation (°)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
Euler = rad2deg(R2mobileYXZ_array3(T_rel(1:3,1:3,:))); % As for carpal bones
if strcmp(side,'Right')
    JR = permute(Euler(:,1,:),[3,1,2]); 
elseif strcmp(side,'Left')
    JR = -permute(Euler(:,1,:),[3,1,2]); 
end
JR    = JR-JR(1);
JR    = JR(tidx);
Measurement(lcycle).Joint(ijoint).R2 = polyfit_array3(JR,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).R2,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).R2 = JR;
% plot(F,Measurement(lcycle).Joint(ijoint).R2,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

figure(iplot);
subplot(2,3,6); hold on; box on; grid on; title('Dorsiflexion (+) / Plantarflexion (-)');
xlabel('Force (N)'); ylabel('Rotation (°)');
T_rel = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).(bone2)),T_a.Cycle(lcycle).(bone1));
Euler = rad2deg(R2mobileYXZ_array3(T_rel(1:3,1:3,:))); % As for carpal bones
JR    = permute(Euler(:,3,:),[3,1,2]);
JR    = JR-JR(1);
JR    = JR(tidx);
Measurement(lcycle).Joint(ijoint).R3 = polyfit_array3(JR,F,[10:5:50],type,'',kplot);
plot([10:5:50]',Measurement(lcycle).Joint(ijoint).R3,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');
% Measurement(lcycle).Joint(ijoint).R3 = JR;
% plot(F,Measurement(lcycle).Joint(ijoint).R3,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');