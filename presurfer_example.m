%% MP2RAGE pre-processing Start-to-finish
UNI=fullfile(pwd,'sub-42_mp2rage_0p7mm_iso_p3_UNI_Images.nii.gz');
INV2=fullfile(pwd,'sub-42_mp2rage_0p7mm_iso_p3_INV2.nii.gz');
% ########################################################################
% STEP - 0 : (optional) MP2RAGEise UNI
% ########################################################################
presurf_MPRAGEise(INV2,UNI); % Outputs presurf_MPRAGEise directory

% ########################################################################
% STEP - 1 : Pre-process INV2 to get STRIPMASK
% ########################################################################
presurf_INV2(INV2); % Outputs presurf_INV2 directory

% ########################################################################
% STEP - 3 : Pre-process UNI to get BRAINMASK
% ########################################################################
% Change UNI path to that of the MPRAGEised UNI if Step-0 was done
UNI = '/path/to/UNI.nii';
presurf_UNI(UNI); % Outputs presurf_UNI directory

% ########################################################################
% STEP - 4 : Prepare for Freesurfer
% ########################################################################

% Load the MPRAGEised UNI image and STRIPMASK in ITK-SNAP
% Clean the mask in the regions-of-interest and save
% Multiply the MPRAGEised UNI with the manually edited STRIPMASK
% Supply to recon-all
