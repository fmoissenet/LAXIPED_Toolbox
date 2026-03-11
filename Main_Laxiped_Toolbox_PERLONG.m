% Author     :   F. Moissenet
%                Biomechanics Laboratory (B-LAB)
%                University of Geneva
% License    :   Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code:   To be defined
% Reference  :   To be defined
% Date       :   October 2025
% -------------------------------------------------------------------------
% Description:   Part of the LAXIPED project
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% INIT WORKSPACE
% -------------------------------------------------------------------------
clearvars;
% close all; 
clc;
warning off;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
Folder.toolbox       = 'C:\Users\Florent\OneDrive - Université de Genève\_PROJETS\LAXIPED\WP1\Toolbox\LAXIPED_Toolbox\';
Folder.dependencies  = 'C:\Users\Florent\OneDrive - Université de Genève\_PROJETS\LAXIPED\WP1\Toolbox\LAXIPED_Toolbox\dependencies\';
Folder.data          = 'C:\Users\Florent\OneDrive - Université de Genève\_PROJETS\LAXIPED\WP1\Dataset\LAXIPED\Data\';
addpath(genpath(Folder.toolbox));

% -------------------------------------------------------------------------
% SET SPECIMEN
% -------------------------------------------------------------------------
specimenList = {'LAX-EX-A1','LAX-EX-A2','LAX-EX-A3','LAX-EX-A4','LAX-EX-A5', ...
                'LAX-EX-S1','LAX-EX-S2','LAX-EX-S3','LAX-EX-S4','LAX-EX-S5'};
sideList     = {'Right','Left','Right','Right','Left', ...
                'Right','Right','Left','Right','Left'};
dofLabelList = {'Anterior (+) / Posterior (-) translation', ...
                'Superior (+) / Inferior (-) translation', ...
                'Lateral (+) / Medial (-) translation', ...
                'Inversion (+) / Eversion (-)', ...
                'Adduction (+) / Abduction (-)', ...
                'Dorsiflexion (+) / Plantarflexion (-)', ...
                '3D translation'};
for ispecimen = 10%1:size(specimenList,2)
clearvars -except Folder specimenList sideList ispecimen;

% -------------------------------------------------------------------------
% LOAD DYNAMIC TRIAL
% -------------------------------------------------------------------------
% Load c3d file
cd([Folder.data,specimenList{ispecimen},'\']);
c3dFile = uigetfile('*.c3d','MultiSelect','on');
% Load laxiped files
laxipedFileList = uigetfile('*.txt','MultiSelect','on');
kcycle  = 1;
if iscell(c3dFile) == 0
    nfile = 1;
else
    nfile = size(c3dFile,2);
end
for ifile = 1:nfile
if iscell(c3dFile) == 0
    btkFile = btkReadAcquisition(c3dFile);
else
    btkFile = btkReadAcquisition(c3dFile{ifile});
end
tMarker = btkGetMarkers(btkFile);
nmarker = fieldnames(tMarker);
fmarker = btkGetPointFrequency(btkFile);
Event   = btkGetEvents(btkFile);
start   = ceil(Event.start*fmarker);
stop    = ceil(Event.stop*fmarker);
% Set bony segments
segments  = {'TIBIA','FIBUL','META1','META2','META3','META4','META5', ...
             'CUMED','CUINT','CULAT','CUBOI','NAVIC','TALUS','CALCA','LAXIP'};

for icycle = 1:size(start,2)

    % ---------------------------------------------------------------------
    % PROCESS MARKER TRAJECTORIES
    % ---------------------------------------------------------------------
    % Initialise marker trajectories
    Marker.Cycle(kcycle).TIBIA_c1 = []; Marker.Cycle(kcycle).TIBIA_c2 = []; Marker.Cycle(kcycle).TIBIA_c3 = []; Marker.Cycle(kcycle).TIBIA_c4 = [];
    Marker.Cycle(kcycle).FIBUL_c1 = []; Marker.Cycle(kcycle).FIBUL_c2 = []; Marker.Cycle(kcycle).FIBUL_c3 = []; Marker.Cycle(kcycle).FIBUL_c4 = [];
    Marker.Cycle(kcycle).META1_c1 = []; Marker.Cycle(kcycle).META1_c2 = []; Marker.Cycle(kcycle).META1_c3 = []; Marker.Cycle(kcycle).META1_c4 = [];
    Marker.Cycle(kcycle).META2_c1 = []; Marker.Cycle(kcycle).META2_c2 = []; Marker.Cycle(kcycle).META2_c3 = []; Marker.Cycle(kcycle).META2_c4 = [];
    Marker.Cycle(kcycle).META3_c1 = []; Marker.Cycle(kcycle).META3_c2 = []; Marker.Cycle(kcycle).META3_c3 = []; Marker.Cycle(kcycle).META3_c4 = [];
    Marker.Cycle(kcycle).META4_c1 = []; Marker.Cycle(kcycle).META4_c2 = []; Marker.Cycle(kcycle).META4_c3 = []; Marker.Cycle(kcycle).META4_c4 = [];
    Marker.Cycle(kcycle).META5_c1 = []; Marker.Cycle(kcycle).META5_c2 = []; Marker.Cycle(kcycle).META5_c3 = []; Marker.Cycle(kcycle).META5_c4 = [];
    Marker.Cycle(kcycle).CUMED_c1 = []; Marker.Cycle(kcycle).CUMED_c2 = []; Marker.Cycle(kcycle).CUMED_c3 = []; Marker.Cycle(kcycle).CUMED_c4 = [];
    Marker.Cycle(kcycle).CUINT_c1 = []; Marker.Cycle(kcycle).CUINT_c2 = []; Marker.Cycle(kcycle).CUINT_c3 = []; Marker.Cycle(kcycle).CUINT_c4 = [];
    Marker.Cycle(kcycle).CULAT_c1 = []; Marker.Cycle(kcycle).CULAT_c2 = []; Marker.Cycle(kcycle).CULAT_c3 = []; Marker.Cycle(kcycle).CULAT_c4 = [];
    Marker.Cycle(kcycle).CUBOI_c1 = []; Marker.Cycle(kcycle).CUBOI_c2 = []; Marker.Cycle(kcycle).CUBOI_c3 = []; Marker.Cycle(kcycle).CUBOI_c4 = [];
    Marker.Cycle(kcycle).NAVIC_c1 = []; Marker.Cycle(kcycle).NAVIC_c2 = []; Marker.Cycle(kcycle).NAVIC_c3 = []; Marker.Cycle(kcycle).NAVIC_c4 = [];
    Marker.Cycle(kcycle).TALUS_c1 = []; Marker.Cycle(kcycle).TALUS_c2 = []; Marker.Cycle(kcycle).TALUS_c3 = []; Marker.Cycle(kcycle).TALUS_c4 = [];
    Marker.Cycle(kcycle).CALCA_c1 = []; Marker.Cycle(kcycle).CALCA_c2 = []; Marker.Cycle(kcycle).CALCA_c3 = []; Marker.Cycle(kcycle).CALCA_c4 = [];
    Marker.Cycle(kcycle).LAXIP_c1 = []; Marker.Cycle(kcycle).LAXIP_c2 = []; Marker.Cycle(kcycle).LAXIP_c3 = []; Marker.Cycle(kcycle).LAXIP_c4 = [];
    % Process trajectories
    for imarker = 1:size(nmarker,1)
        data  = permute(tMarker.(nmarker{imarker})(start(icycle):stop(icycle),:), [2,3,1]);
        data  = zerosToNaN_array3(data);
        kplot = 0;
        type  = 'poly8';
        data  = permute(polyfit_array3(permute(data,[3,1,2]),(1:size(data,3))',(1:size(data,3))',type,nmarker{imarker},kplot),[2,3,1]);
        Marker.Cycle(kcycle).(nmarker{imarker})(:,:,1:(stop(icycle)-start(icycle)+1)) = data;
    end

    % ---------------------------------------------------------------------
    % CLUSTER RIGIDIFICATION
    % ---------------------------------------------------------------------
    % Complete empty markers in clusters
    for isegment = [3,8,12]%1:size(segments,2)
        clear X_seg;
        seg = segments{isegment};
        if isnan(mean(mean(Marker.Cycle(kcycle).([seg '_c1']))))
            Marker.Cycle(kcycle).([seg '_c1']) = mean(cat(4,Marker.Cycle(kcycle).([seg '_c2']),Marker.Cycle(kcycle).([seg '_c4'])),4,'omitnan'); 
            tMarker.([seg '_c1'])              = mean(cat(3,tMarker.([seg '_c2']),tMarker.([seg '_c4'])),3,'omitnan');
        elseif isnan(mean(mean(Marker.Cycle(kcycle).([seg '_c2']))))
            Marker.Cycle(kcycle).([seg '_c2']) = mean(cat(4,Marker.Cycle(kcycle).([seg '_c1']),Marker.Cycle(kcycle).([seg '_c3'])),4,'omitnan');  
            tMarker.([seg '_c2'])              = mean(cat(3,tMarker.([seg '_c1']),tMarker.([seg '_c3'])),3,'omitnan');
        elseif isnan(mean(mean(Marker.Cycle(kcycle).([seg '_c3']))))
            Marker.Cycle(kcycle).([seg '_c3']) = mean(cat(4,Marker.Cycle(kcycle).([seg '_c2']),Marker.Cycle(kcycle).([seg '_c4'])),4,'omitnan');  
            tMarker.([seg '_c3'])              = mean(cat(3,tMarker.([seg '_c2']),tMarker.([seg '_c4'])),3,'omitnan');
        elseif isnan(mean(mean(Marker.Cycle(kcycle).([seg '_c4']))))  
            Marker.Cycle(kcycle).([seg '_c4']) = mean(cat(4,Marker.Cycle(kcycle).([seg '_c1']),Marker.Cycle(kcycle).([seg '_c3'])),4,'omitnan'); 
            tMarker.([seg '_c4'])              = mean(cat(3,tMarker.([seg '_c1']),tMarker.([seg '_c3'])),3,'omitnan');   
        end
    end
    % Rigidify clusters and update markers
    for isegment = [3,8,12]%1:size(segments,2)
        clear X_seg;
        seg     = segments{isegment};
        X_seg   = cat(4,Marker.Cycle(kcycle).([seg '_c1']), ...
                        Marker.Cycle(kcycle).([seg '_c2']), ...
                        Marker.Cycle(kcycle).([seg '_c3']), ...
                        Marker.Cycle(kcycle).([seg '_c4']));
%         X_seg   = rigidCluster(X_seg,'Mean'); % <<<<< Cluster rigidification currently not applied 
        markers = rigidMarkersFromCluster(X_seg);
        for imarker = 1:4
            MarkerR.Cycle(kcycle).([segments{isegment},'_c',num2str(imarker)]) = markers{imarker};
        end
    end
    MarkerR.Cycle(kcycle).FME      = Marker.Cycle(kcycle).FME;
    MarkerR.Cycle(kcycle).FLE      = Marker.Cycle(kcycle).FLE;
    MarkerR.Cycle(kcycle).TAM      = Marker.Cycle(kcycle).TAM;
    MarkerR.Cycle(kcycle).FAL      = Marker.Cycle(kcycle).FAL;
    MarkerR.Cycle(kcycle).LAXIP_m1 = Marker.Cycle(kcycle).LAXIP_m1;
    MarkerR.Cycle(kcycle).LAXIP_m2 = Marker.Cycle(kcycle).LAXIP_m2;

    % ---------------------------------------------------------------------
    % SET LAXIPED COORDINATE SYSTEMS (MEAN FRAME rframe, FULL RECORD)
    % ---------------------------------------------------------------------
    rframe = 500:600; % A1: 5000:5100, A2: 500:600, A3: 8000:8100, A4: 1000:1100, A5: 1500:1600, S1: 500:600, S2: 500:600, S3: 1800:1900, S4: 500:600, S5: 500:600
    X = Vnorm_array3(mean(permute(tMarker.LAXIP_c4(rframe,:),[2,3,1]),3,'omitnan')-mean(permute(tMarker.LAXIP_c1(rframe,:),[2,3,1]),3,'omitnan'));
    Z = Vnorm_array3(mean(permute(tMarker.LAXIP_c4(rframe,:),[2,3,1]),3,'omitnan')-mean(permute(tMarker.LAXIP_c3(rframe,:),[2,3,1]),3,'omitnan'));
    Y = cross(Z,X);
    Z = cross(X,Y);
    O = mean(permute(tMarker.LAXIP_c4(rframe,:),[2,3,1]),3,'omitnan')-9.5/2*Y; % 9.5 mm diameter markers on Laxiped base
    MarkerR.Cycle(kcycle).LAXIP_m1 = MarkerR.Cycle(kcycle).LAXIP_m1-9.5/2*Y; % 9.5 mm diameter markers on Laxiped base
    MarkerR.Cycle(kcycle).LAXIP_m2 = MarkerR.Cycle(kcycle).LAXIP_m2-9.5/2*Y; % 9.5 mm diameter markers on Laxiped base
    T_a.Cycle(kcycle).LAXIPED = [X Y Z O; 0 0 0 1];
    clear X Y Z O;

    % ---------------------------------------------------------------------
    % SET TIBIA/FIBULA ANATOMICAL COORDINATE SYSTEMS (FRAME rframe, FULL RECORD)
    % ---------------------------------------------------------------------
    Z = Vnorm_array3(mean(permute(tMarker.FAL(rframe,:),[2,3,1]),3,'omitnan')-mean(permute(tMarker.TAM(rframe,:),[2,3,1]),3,'omitnan'));
    X = Vnorm_array3(cross((mean(permute(tMarker.FME(rframe,:),[2,3,1]),3,'omitnan')+mean(permute(tMarker.FLE(rframe,:),[2,3,1]),3,'omitnan'))/2-mean(permute(tMarker.FAL(rframe,:),[2,3,1]),3,'omitnan'), ...
                           (mean(permute(tMarker.FME(rframe,:),[2,3,1]),3,'omitnan')+mean(permute(tMarker.FLE(rframe,:),[2,3,1]),3,'omitnan'))/2-mean(permute(tMarker.TAM(rframe,:),[2,3,1]),3,'omitnan')));
    Y = cross(Z,X);
    O = (mean(permute(tMarker.FAL(rframe,:),[2,3,1]),3,'omitnan')+mean(permute(tMarker.TAM(rframe,:),[2,3,1]),3,'omitnan'))/2;
    T_a.Cycle(kcycle).TIBIA = [X Y Z O; 0 0 0 1];
    clear X Y Z O;

    % ---------------------------------------------------------------------
    % COMPUTE RIGID TRANSFORMATION BETWEEN TECHNICAL AND ANATOMICAL FRAMES 
    % (FRAME rframe, FULL RECORD)
    % ---------------------------------------------------------------------
    for isegment = [3,8,12]%1:size(segments,2)
        X = Vnorm_array3(mean(permute(tMarker.([segments{isegment},'_c3'])(rframe,:),[2,3,1]),3,'omitnan') - mean(permute(tMarker.([segments{isegment},'_c1'])(rframe,:),[2,3,1]),3,'omitnan'));
        Y = Vnorm_array3(mean(permute(tMarker.([segments{isegment},'_c2'])(rframe,:),[2,3,1]),3,'omitnan') - mean(permute(tMarker.([segments{isegment},'_c4'])(rframe,:),[2,3,1]),3,'omitnan'));
        Z = cross(X,Y); 
        X = cross(Z,Y);
        O = (mean(permute(tMarker.([segments{isegment},'_c1'])(rframe,:),[2,3,1]),3,'omitnan') + ...
             mean(permute(tMarker.([segments{isegment},'_c2'])(rframe,:),[2,3,1]),3,'omitnan') + ...
             mean(permute(tMarker.([segments{isegment},'_c3'])(rframe,:),[2,3,1]),3,'omitnan') + ...
             mean(permute(tMarker.([segments{isegment},'_c4'])(rframe,:),[2,3,1]),3,'omitnan'))/4; % Cluster centroid
        T_t.Cycle(kcycle).(segments{isegment}) = [X Y Z O; 0 0 0 1];
        % Set rigid transformation between technical and anatomical CS
        T_ta.Cycle(kcycle).(segments{isegment}) = Mprod_array3(Minv_array3(T_t.Cycle(kcycle).(segments{isegment})), ...
                                                               [T_a.Cycle(kcycle).LAXIPED(1:4,1:3,:) T_t.Cycle(kcycle).(segments{isegment})(1:4,4,:)]);
        clear X Y Z O T_t;
    end

    % ---------------------------------------------------------------------
    % COMPUTE TECHNICAL COORDINATE SYSTEMS
    % ---------------------------------------------------------------------
    for isegment = [3,8,12]%1:size(segments,2)
        X = Vnorm_array3(MarkerR.Cycle(kcycle).([segments{isegment},'_c3']) - MarkerR.Cycle(kcycle).([segments{isegment},'_c1']));
        Y = Vnorm_array3(MarkerR.Cycle(kcycle).([segments{isegment},'_c2']) - MarkerR.Cycle(kcycle).([segments{isegment},'_c4']));
        Z = cross(X,Y); 
        X = cross(Z,Y);
        O = (MarkerR.Cycle(kcycle).([segments{isegment},'_c1']) + ...
             MarkerR.Cycle(kcycle).([segments{isegment},'_c2']) + ...
             MarkerR.Cycle(kcycle).([segments{isegment},'_c3']) + ...
             MarkerR.Cycle(kcycle).([segments{isegment},'_c4']))/4; % Cluster centroid
        for iframe = 1:size(X,3)
            T_t.Cycle(kcycle).(segments{isegment})(:,:,iframe) = [X(:,:,iframe) Y(:,:,iframe) Z(:,:,iframe) O(:,:,iframe); 0 0 0 1];
        end
        clear X Y Z O;
    end

    % ---------------------------------------------------------------------
    % COMPUTE ANATOMICAL COORDINATE SYSTEMS
    % ---------------------------------------------------------------------
    for isegment = [3,8,12]%1:size(segments,2)
        T_a.Cycle(kcycle).(segments{isegment}) = ...
            Mprod_array3(T_t.Cycle(kcycle).(segments{isegment}), ...
                         repmat(T_ta.Cycle(kcycle).(segments{isegment}),[1,1,size(T_t.Cycle(kcycle).(segments{isegment}),3)]));
    end

%     % ---------------------------------------------------------------------
%     % PLOT COORDINATE SYSTEMS
%     % ---------------------------------------------------------------------
%     figure; hold on; axis equal;
%     % Markers
%     for imarker = 1:size(nmarker,1)
%         P = MarkerR.Cycle(kcycle).(nmarker{imarker});
%         x = P(1,1,1);
%         y = P(2,1,1);
%         z = P(3,1,1);
%         if ~any(isnan([x y z]))
%             plot3(x,y,z,'o','MarkerSize',5,'Color','black','MarkerFaceColor','black');
%         end
%     end
%     % Frames    
%     for isegment = [3,8,12]%1:size(segments,2)
%         seg = segments{isegment};
%         if ~any(isnan(T_a.Cycle(kcycle).(seg)(:,:,1)),'all')
%             plot_frame(T_a.Cycle(kcycle).(seg)(:,:,1),20,'','-');
%         end
%     end
%     plot_frame(T_a.Cycle(kcycle).LAXIPED(:,:,1),50,'','-');

    kcycle = kcycle+1;
end
end

% -------------------------------------------------------------------------
% COMPUTE KINEMATICS AND STORE RESULTS
% -------------------------------------------------------------------------
step        = 5; % Step used to compute offset
Measurement = []; % Initialisation
lcycle      = 1;

for icycle = 1:kcycle-1

    % ---------------------------------------------------------------------
    % LAXIPED TIPS TRANSLATIONS
    % ---------------------------------------------------------------------
    out = readLaxipedFile(laxipedFileList{icycle});
    if strcmp(sideList{ispecimen},'Right')
        T      = table2array(out.data(:,8))*fmarker;
        F      = table2array(out.data(:,2));
        D1l    = table2array(out.data(:,3));
        D2l    = table2array(out.data(:,5));
        Ddl    = table2array(out.data(:,6));
        temp   = Mprod_array3(repmat(Minv_array3(T_a.Cycle(icycle).LAXIPED(1:3,1:3,:)),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]), ...
                              (MarkerR.Cycle(icycle).LAXIP_m2)-repmat(T_a.Cycle(icycle).LAXIPED(1:3,4,:),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]));
        D1     = permute(temp(2,:,:),[3,1,2]);
        offset = D1(ceil(table2array(out.data(step,8))*fmarker))-table2array(out.data(step,3));
        D1     = D1-offset;
        tidx   = ceil(table2array(out.data(:,8))*fmarker);
        if tidx(end) > size(D1,1)
            tidx(end) = size(D1,1);
        end
        D1m    = D1(tidx);
        temp   = Mprod_array3(repmat(Minv_array3(T_a.Cycle(icycle).LAXIPED(1:3,1:3,:)),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]), ...
                              (MarkerR.Cycle(icycle).LAXIP_m1)-repmat(T_a.Cycle(icycle).LAXIPED(1:3,4,:),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]));
        D2     = permute(temp(2,:,:),[3,1,2]);
        offset = D2(ceil(table2array(out.data(step,8))*fmarker))-table2array(out.data(step,5));
        D2     = D2-offset;
        D2m    = D2(tidx);
        Ddm    = D1m-D2m;
        clear D1 D2 offset idx;
    elseif strcmp(sideList{ispecimen},'Left')
        T      = table2array(out.data(:,8))*fmarker;
        F      = table2array(out.data(:,4));
        D1l    = table2array(out.data(:,5));
        D2l    = table2array(out.data(:,3));
        Ddl    = table2array(out.data(:,6));
        temp   = Mprod_array3(repmat(Minv_array3(T_a.Cycle(icycle).LAXIPED(1:3,1:3,:)),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]), ...
                              (MarkerR.Cycle(icycle).LAXIP_m1)-repmat(T_a.Cycle(icycle).LAXIPED(1:3,4,:),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]));
        D1     = permute(temp(2,:,:),[3,1,2]);
        tidx   = ceil(table2array(out.data(:,8))*fmarker);
        if tidx(end) > size(D1,1)
            tidx(end) = size(D1,1);
        end
        offset = D1(ceil(table2array(out.data(step,8))*fmarker))-table2array(out.data(step,5));
        D1     = D1-offset;
        D1m    = D1(tidx);
        temp   = Mprod_array3(repmat(Minv_array3(T_a.Cycle(icycle).LAXIPED(1:3,1:3,:)),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]), ...
                              (MarkerR.Cycle(icycle).LAXIP_m2)-repmat(T_a.Cycle(icycle).LAXIPED(1:3,4,:),[1,1,size(T_a.Cycle(icycle).META1(1:3,4,:),3)]));
        D2     = permute(temp(2,:,:),[3,1,2]);
        offset = D2(ceil(table2array(out.data(step,8))*fmarker))-table2array(out.data(step,3));
        D2     = D2-offset;
        D2m    = D2(tidx);
        Ddm    = D2m-D1m;
        clear D1 D2 offset idx;
    end
%     figure(1);
%     set(gcf,'Color','white'); set(gcf,'Position',[50 50 1200 600]);
%     hold on; box on; grid on; title('Tip translations');
%     xlabel('Force (N)'); ylabel('Translation (mm)');
%     p1l = plot(F,D1l,'Marker','x','Markersize',6,'Linestyle','none','Linewidth',1,'Color','red');
%     p2l = plot(F,D2l,'Marker','x','Markersize',6,'Linestyle','none','Linewidth',1,'Color','blue');
%     pdl = plot(F,Ddl,'Marker','x','Markersize',6,'Linestyle','none','Linewidth',1,'Color','green');
%     p1m = plot(F,D1m,'Marker','o','Markersize',6,'Linestyle','none','Linewidth',1,'Color','red');
%     p2m = plot(F,D2m,'Marker','o','Markersize',6,'Linestyle','none','Linewidth',1,'Color','blue');
%     pdm = plot(F,Ddm,'Marker','o','Markersize',6,'Linestyle','none','Linewidth',1,'Color','green');
%     legend({'D1 - Laxiped','D2 - Laxiped','Diff - Laxiped','D1 - Mocap','D2 - Mocap','Diff - Mocap'});

    % ---------------------------------------------------------------------
    % INTERPOLATE DATA 10:5:50N
    % ---------------------------------------------------------------------
    kplot                   = 0;
    type                    = 'poly4'; %smoothingspline
    Measurement(lcycle).T   = polyfit_array3(T,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).F   = [10:5:50]';
    Measurement(lcycle).D1l = polyfit_array3(D1l,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).D2l = polyfit_array3(D2l,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).Ddl = polyfit_array3(Ddl,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).D1m = polyfit_array3(D1m,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).D2m = polyfit_array3(D2m,F,[10:5:50],type,'',kplot);
    Measurement(lcycle).Ddm = polyfit_array3(Ddm,F,[10:5:50],type,'',kplot);

    % ---------------------------------------------------------------------
    % UPDATE META1/CUMED RIGID TRANSFORMATION CENTERED ON JOINT CENTER
    % ---------------------------------------------------------------------
    % Get the distal point on META1
%     fcsvFile = 'Landmarks_META1_distal.fcsv';
%     temp = readmatrix(fcsvFile,'Filetype','text','NumHeaderLines',3,'Delimiter',',');
%     distalPoint = temp(1,2:4)'; % m
    % Get meshes
    imesh = 1;
    for isegment = [3,8,12] % META1, CUMED, NAVIC
        meshFile  = ['Mesh_',segments{isegment},'.stl'];
        meshFile2 = ['Mesh_',segments{isegment},'_clean.stl'];
        fcsvFile  = ['Landmarks_',segments{isegment},'.fcsv'];
%         if isegment == 8 % Only for LAX-EX-A3, LAX-EX-S2, LAX-EX-A3_Klaue, LAX-EX-S2_Klaue
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
%         if isegment == 8 % Only for LAX-EX-A4_Klaue
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
%         elseif isegment == 12 % Only for LAX-EX-A3_Klaue, LAX-EX-A5_Klaue
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
        if isegment == 12 % Only for LAX-EX-S3, LAX-EX-S5, LAX-EX-A2_Klaue, LAX-EX-S3_Klaue
            [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
                                                 [], ...
                                                 []);
%         elseif isegment == 12 % Only for LAX-EX-A4_Klaue
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
%         elseif isegment == 12 % Only for LAX-EX-S1, LAX-EX-S2, LAX-EX-A1, LAX-EX-S1_Klaue, LAX-EX-S5_Klaue
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
%         if isegment == 12 % Only for LAX-EX-A4
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  [], ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  []);
%         elseif isegment == 3 % Use distalPoint of META1
%             [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
%                                                  eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
%                                                  distalPoint);
        else
            [faces,verticesT,vertices,distalPointT] = getMesh(meshFile,meshFile2,fcsvFile, ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c1(:,:,:)']), ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c2(:,:,:)']), ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c3(:,:,:)']), ...
                                                 eval(['MarkerR.Cycle(',num2str(icycle),').',segments{isegment},'_c4(:,:,:)']), ...
                                                 []);
        end
        Mesh(imesh).faces     = faces;
        Mesh(imesh).vertices  = vertices;
        Mesh(imesh).verticesT = verticesT;
%         Mesh(imesh).distalPointT = distalPointT;
        imesh                 = imesh+1;
        clear faces verticesT distalPointT;
    end
    % Identify joint centre of the META1/CUMED joint
    threshold = 3; % mm, arbitrary
    kplot     = 1;
    artSurf1  = findArticularContour(Mesh(1),Mesh(2),threshold);
    JC1_local = findJointCentre(Mesh(1),Mesh(2),artSurf1,kplot)';
    % Express it in META1 and CUMED SCS
    temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).META1(:,:,1)),[JC1_local;1]);
    JC1_dyn1  = Mprod_array3(T_a.Cycle(icycle).META1,repmat(temp,[1,1,size(T_a.Cycle(icycle).META1,3)]));
    % For LAX-EX-A5 only
%     temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).CUMED(:,:,1)),[JC1_local;1]); % Express in MOCAP space using CUMED instead META1 at frame 1
%     JC1_dyn1  = Mprod_array3(T_a.Cycle(icycle).META1,repmat(temp,[1,1,size(T_a.Cycle(icycle).META1,3)]));
    JC1_dyn1  = JC1_dyn1(1:3,:,:); clear temp;
    temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).CUMED(:,:,1)),[JC1_local;1]);
    JC1_dyn2  = Mprod_array3(T_a.Cycle(icycle).CUMED,repmat(temp,[1,1,size(T_a.Cycle(icycle).CUMED,3)]));
    JC1_dyn2  = JC1_dyn2(1:3,:,:); clear temp;
%     % Plot JC1 trajectory on CUMED (test)
%     temp     = [Mesh(2).verticesT;ones(1,size(Mesh(2).verticesT,2),size(Mesh(2).verticesT,3))];
%     temp     = Mprod_array3(Minv_array3(T_a.Cycle(icycle).CUMED),temp);
%     verticeS = temp(1:3,:,:); clear temp;
%     O        = permute(Mprod_array3(Minv_array3(T_a.Cycle(icycle).CUMED),[JC1_dyn1;ones(1,1,size(JC1_dyn1,3))]),[1,3,2]);   
%     figure(400);
%     patch('Faces',Mesh(2).faces,...
%           'Vertices',verticeS(:,:,1)',...
%           'FaceColor',[0.5,0.5,0.5],...
%           'EdgeColor','none',...
%           'FaceLighting','Gouraud',...
%           'FaceAlpha',0.2);
%     hold on; axis equal;
%     lighting(gca,'gouraud'); material(gca,'metal');
%     light('Position',[1 0 1],'Style','infinite'); 
%     plot3(O(1,:),O(2,:),O(3,:),'Linestyle','-','Linewidth',4,'Color','red','Marker','none');
    % Update META1 and CUMED SCS
    T_a.Cycle(icycle).META1(1:3,4,:) = JC1_dyn1;
    T_a.Cycle(icycle).CUMED(1:3,4,:) = JC1_dyn2;

    % ---------------------------------------------------------------------
    % COMPUTE AND PLOT JOINT DOFs
    % ---------------------------------------------------------------------    
    % Joint mobilities META1/CUMED (joint 1)
    bone1 = 'META1';
    bone2 = 'CUMED';
    iplot = 2;
    figure(iplot); 
    set(gcf,'Color','white'); set(gcf,'Position',[50 50 1200 600]);
    sgtitle(['Mobilities of ',bone1,' relative to ',bone2]);
    Measurement = plotDOF(sideList{ispecimen},Measurement,T_a,out,F,bone1,bone2,fmarker,lcycle,1,tidx,iplot,type);

    % ---------------------------------------------------------------------
    % UPDATE CUMED/NAVIC RIGID TRANSFORMATION CENTERED ON JOINT CENTER
    % ---------------------------------------------------------------------
    % Get meshes
    % Already done
    % Identify joint centre of the CUMED/NAVIC joint
    threshold = 3; % mm, arbitrary
    kplot     = 1;
    artSurf2  = findArticularContour(Mesh(2),Mesh(3),threshold);
    JC2_local = findJointCentre(Mesh(2),Mesh(3),artSurf2,kplot)';
    % Express it in CUMED and NAVIC SCS
    temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).CUMED(:,:,1)),[JC2_local;1]);
    JC2_dyn1  = Mprod_array3(T_a.Cycle(icycle).CUMED,repmat(temp,[1,1,size(T_a.Cycle(icycle).CUMED,3)]));
    % For LAX-EX-S1 and LAX-EX-A1 only
%     temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).NAVIC(:,:,1)),[JC2_local;1]); % Express in MOCAP space using NAVIC instead CUMED at frame 1
%     JC2_dyn1  = Mprod_array3(T_a.Cycle(icycle).CUMED,repmat(temp,[1,1,size(T_a.Cycle(icycle).CUMED,3)]));    
    JC2_dyn1  = JC2_dyn1(1:3,:,:); clear temp;
    temp      = Mprod_array3(Minv_array3(T_a.Cycle(icycle).NAVIC(:,:,1)),[JC2_local;1]);
    JC2_dyn2  = Mprod_array3(T_a.Cycle(icycle).NAVIC,repmat(temp,[1,1,size(T_a.Cycle(icycle).NAVIC,3)]));
    JC2_dyn2  = JC2_dyn2(1:3,:,:); clear temp;
%     % Plot JC2 trajectory on NAVIC (test)
%     temp     = [Mesh(3).verticesT;ones(1,size(Mesh(3).verticesT,2),size(Mesh(3).verticesT,3))];
%     temp     = Mprod_array3(Minv_array3(T_a.Cycle(icycle).NAVIC),temp);
%     verticeS = temp(1:3,:,:); clear temp;
%     O        = permute(Mprod_array3(Minv_array3(T_a.Cycle(icycle).NAVIC),[JC2_dyn1;ones(1,1,size(JC2_dyn1,3))]),[1,3,2]);   
%     figure(400);
%     patch('Faces',Mesh(3).faces,...
%           'Vertices',verticeS(:,:,1)',...
%           'FaceColor',[0.5,0.5,0.5],...
%           'EdgeColor','none',...
%           'FaceLighting','Gouraud',...
%           'FaceAlpha',0.2);
%     hold on; axis equal;
%     lighting(gca,'gouraud'); material(gca,'metal');
%     light('Position',[1 0 1],'Style','infinite'); 
%     plot3(O(1,:),O(2,:),O(3,:),'Linestyle','-','Linewidth',4,'Color','red','Marker','none');
    % Update CUMED and NAVIC SCS
    T_a.Cycle(icycle).CUMED(1:3,4,:) = JC2_dyn1;
    T_a.Cycle(icycle).NAVIC(1:3,4,:) = JC2_dyn2;

    % ---------------------------------------------------------------------
    % COMPUTE AND PLOT JOINT DOFs
    % ---------------------------------------------------------------------
    % Joint mobilities CUMED/NAVIC (joint 2)
    bone1 = 'CUMED';
    bone2 = 'NAVIC';
    iplot = 3;
    figure(iplot); 
    set(gcf,'Color','white'); set(gcf,'Position',[50 50 1200 600]);
    sgtitle(['Mobilities of ',bone1,' relative to ',bone2]);
    Measurement = plotDOF(sideList{ispecimen},Measurement,T_a,out,F,bone1,bone2,fmarker,lcycle,2,tidx,iplot,type);


% figure(4);
% hold on; box on; grid on; title('TEST');
% xlabel('Force (N)'); ylabel('Translation (mm)');
% d = Mprod_array3(Tinv_array3(T_a.Cycle(lcycle).NAVIC),[Mesh(1).distalPointT;ones(1,1,size(Mesh(1).distalPointT,3))]);
% d = d(1:3,1,:);
% d = permute(d,[3,1,2]);
% d = d-d(1);
% d = d(tidx);
% d1 = polyfit_array3(d,F,[10:5:50],type,'',kplot);
% plot([10:5:50]',d1,'Marker','+','Markersize',6,'Linestyle','none','Linewidth',1,'Color','black');

    % ---------------------------------------------------------------------
    % WORKSPACE MANAGEMENT
    % ---------------------------------------------------------------------
    lcycle = lcycle+1;
    clear out;
end
% close all;

% Save
cd(Folder.data);
save([specimenList{ispecimen},'_PL.mat']);
end

% figure(500);
% for icycle = 1:3
%     [rC,rCsi,rCsj,Residual] = SCoRE_array3(T_a.Cycle(icycle).META1,T_a.Cycle(icycle).NAVIC);
%     rC3 = permute(rC,[3,1,2]);
%     plot3(rC3(:,1),rC3(:,2),rC3(:,3),'Marker','.','Color','red','Markersize',10)
% end

%% ------------------------------------------------------------------------
% ANALYSE DATASET
% -------------------------------------------------------------------------

% Load MAT files
clearvars -except Folder;
close all;
clc;
cd(Folder.data);
matFiles  = dir('*_PL.mat'); %_Laxiped _Klaue
jointList = {'META1/CUMED','CUMED/NAVIC'};

% Initialisation
Joint = []; 
for ijoint = 1:numel(jointList)
    Joint1(ijoint).F_all  = [];
    Joint1(ijoint).T1_all = []; Joint1(ijoint).T2_all = []; Joint1(ijoint).T3_all = [];
    Joint1(ijoint).R1_all = []; Joint1(ijoint).R2_all = []; Joint1(ijoint).R3_all = [];
    Joint3(ijoint).T2_all = [];
end
dofList   = {'T1_all','T2_all','T3_all','R1_all','R2_all','R3_all'};
colorList = [0.894, 0.102, 0.110;   % red
             0.216, 0.494, 0.722;   % blue
             0.302, 0.686, 0.290;   % green
             0.596, 0.306, 0.639;   % purple
             1.000, 0.498, 0.000;   % orange
             1.000, 0.882, 0.098;   % yellow
             0.651, 0.337, 0.157;   % brown
             0.969, 0.506, 0.749;   % pink
             0.600, 0.600, 0.600;   % grey
             0.121, 0.470, 0.705;   % deep blue
            ];

% Merge specimen records
kfile1 = 1;
kfile2 = 1;
for ifile2 = 1:numel(matFiles)
    clearvars -except Folder ifile2 kcycle kfile1 kfile2 matFiles Measurement ...
                      LAXIPED1 LAXIPED2 FRRM2 FRRM3 FRRM4 FRRM5 FRRM6 FRRM7 FRRM8 FRRM9 ...
                      FRM2 FRM3 FRM4 FRM5 FRM6 FRM7 FRM8 FRM9 Joint1 Joint2 Joint3 ...
                      Joint4 dofList jointList colorList correlationType;
    matFile = matFiles(ifile2).name;
    load(matFile);    
    ncycle  = size(Measurement,2);
    kcycle  = 1;
    for icycle = 1:8 % 0 kg to 3.5 kg
        LAXIPED1(kfile1).values(kcycle,:) = abs(Measurement(icycle).D1l-Measurement(icycle).D2l)';
        FRRM2(kcycle,kfile1)               = (Measurement(icycle).D1l(2)-Measurement(icycle).D2l(2)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM3(kcycle,kfile1)               = (Measurement(icycle).D1l(3)-Measurement(icycle).D2l(3)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM4(kcycle,kfile1)               = (Measurement(icycle).D1l(4)-Measurement(icycle).D2l(4)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM5(kcycle,kfile1)               = (Measurement(icycle).D1l(5)-Measurement(icycle).D2l(5)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM6(kcycle,kfile1)               = (Measurement(icycle).D1l(6)-Measurement(icycle).D2l(6)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM7(kcycle,kfile1)               = (Measurement(icycle).D1l(7)-Measurement(icycle).D2l(7)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM8(kcycle,kfile1)               = (Measurement(icycle).D1l(8)-Measurement(icycle).D2l(8)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        FRRM9(kcycle,kfile1)               = (Measurement(icycle).D1l(9)-Measurement(icycle).D2l(9)) - ...
                                            (Measurement(icycle).D1l(1)-Measurement(icycle).D2l(1));
        for ijoint = 1:numel(Measurement(icycle).Joint)
            Joint1(ijoint).F_all          = [Joint1(ijoint).F_all  Measurement(icycle).F];
            Joint1(ijoint).T1_all         = [Joint1(ijoint).T1_all Measurement(icycle).Joint(ijoint).T1];
            Joint1(ijoint).T2_all         = [Joint1(ijoint).T2_all Measurement(icycle).Joint(ijoint).T2];
            Joint1(ijoint).T3_all         = [Joint1(ijoint).T3_all Measurement(icycle).Joint(ijoint).T3];
            Joint1(ijoint).R1_all         = [Joint1(ijoint).R1_all Measurement(icycle).Joint(ijoint).R1];
            Joint1(ijoint).R2_all         = [Joint1(ijoint).R2_all Measurement(icycle).Joint(ijoint).R2];
            Joint1(ijoint).R3_all         = [Joint1(ijoint).R3_all Measurement(icycle).Joint(ijoint).R3];
        end
        Joint3(1).T2_all                  = [Joint3(1).T2_all abs(Measurement(icycle).Joint(1).T2)+abs(Measurement(icycle).Joint(2).T2)];
        if icycle == 8
            kfile1                        = kfile1+1;
        end
        kcycle                            = kcycle+1;
    end
end 

%%
% Plot specimen measurements
figure(11); set(gcf,'Color','white');
sgtitle('Superior-inferior translations at 45 N (blue: META1/CUMED, orange: NAVIC/CUMED');
clear data dataplot;

nspecimen = 10;
ncycle    = 8; % Different tendon tension levels

ijoint    = 1;
idof      = 2;
H         = 0.6;                    % teinte (bleu)
S         = 0.7;                    % saturation modérée
V         = linspace(0.1,1,ncycle); % foncé → très clair
test = [];
for iforce = 1:9
    data = reshape(Joint1(ijoint).(dofList{idof})(iforce,:),[ncycle,nspecimen]);
    for ispecimen = 1:nspecimen
        dataplot(ispecimen).values(:,iforce) = data(:,ispecimen);
    end
    for icycle = 1:ncycle
        test = [test (dataplot(ispecimen).values(icycle,end)-dataplot(ispecimen).values(icycle,1)) - ...
                     (dataplot(ispecimen).values(1,end)-dataplot(ispecimen).values(1,1))];
    end
end
for ispecimen = 1:nspecimen
    subplot(2,5,ispecimen); hold on; box on; grid on;
    for icycle = 1:ncycle
        rgb = hsv2rgb([H S V(icycle)]);
        plot(icycle, ...
             (dataplot(ispecimen).values(icycle,9) - ...
             (dataplot(ispecimen).values(1,9))), ...            
             'Color',rgb,'LineWidth',2,'Marker','o');
%              (dataplot(ispecimen).values(icycle,1)-dataplot(ispecimen).values(icycle,1)) - ...
%              (dataplot(ispecimen).values(1,1)-dataplot(ispecimen).values(1,1)), ...
    end
    xlabel('Mass (kg)'); xticks([1:1:8]); xticklabels([0:0.5:3.5]);
    ylabel('Translation (mm)');
    ylim([-10,15]);
    title(specimenList{ispecimen});
end

ijoint    = 2;
idof      = 2;
H         = 0.1;                    % teinte (bleu)
S         = 0.7;                    % saturation modérée
V         = linspace(0.1,1,ncycle); % foncé → très clair
for iforce = 1:9
    data = reshape(Joint1(ijoint).(dofList{idof})(iforce,:),[ncycle,nspecimen]);
    for ispecimen = 1:nspecimen
        dataplot(ispecimen).values(:,iforce) = data(:,ispecimen);
    end
end
for ispecimen = 1:nspecimen
    subplot(2,5,ispecimen); hold on; box on; grid on;
    for icycle = 1:ncycle
        rgb = hsv2rgb([H S V(icycle)]);
        plot(icycle, ...
             (dataplot(ispecimen).values(icycle,9) - ...
             (dataplot(ispecimen).values(1,9))), ...            
             'Color',rgb,'LineWidth',2,'Marker','o');
%              (dataplot(ispecimen).values(icycle,1)-dataplot(ispecimen).values(icycle,1)) - ...
%              (dataplot(ispecimen).values(1,1)-dataplot(ispecimen).values(1,1)), ...
    end
    xlabel('Mass (kg)'); xticks([1:1:8]); xticklabels([0:0.5:3.5]);
    ylabel('Translation (mm)');
    ylim([-10,15]);
    title(specimenList{ispecimen});
end