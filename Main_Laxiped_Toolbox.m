% Author     :   F. Moissenet
%                Biomechanics Laboratory (B-LAB)
%                University of Geneva
% License    :   Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code:   To be defined
% Reference  :   To be defined
% Date       :   October 2025
% -------------------------------------------------------------------------
% Description:   To be defined
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
close all;
warning off;
clc;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
Folder.toolbox       = 'C:\Users\Florent\OneDrive - Université de Genève\_PROJETS\LAXIPED\WP1\Toolbox\LAXIPED_Toolbox\';
Folder.data          = uigetdir(); % Patient folder defined by GUI
Folder.dependencies  = [MainFolder,'_CLINIQUE\Matlab\KLAB_ShoulderAnalysis_Toolbox\1-Processing\dependencies\'];
addpath(genpath(Folder.dependencies));

