function ps_process_UNI(in_path,in_file)
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Start Pre-processing UNI']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
%% Check if SPM Directory exists on path
if exist('spm')==0
    disp('++++ SPM directory not found in path.');
    disp(' ');
    spm_directory=uigetdir('/home','Select directory with SPM 12');
    addpath(spm_directory);
    disp(['> ',spm_directory]);
    disp(['> Added to path']);
else
    spm_directory=which('spm');
    spm_directory=spm_directory(1:end-6);
    disp('++++ SPM directory exists in path.');
    disp(['> ',spm_directory]);
    
end

%% Select Data Directory
if exist('in_path','var')==1
    disp(' ');
    disp('++++ Input Directory Selected.');
    disp(['> ',in_path]);
else
    in_path=uigetdir(pwd,'Select Input Directory');
    disp(' ');
    disp('++++ Input Directory Selected.');
    disp(['> ',in_path]);
end

% make outpath directory
out_path=[in_path,'/','ps_UNI_segmentation'];
mkdir(out_path);
disp(' ');
disp('++++ Output Directory Created.');
disp(['> ',out_path]);

%% Load file
if exist('in_file','var')==1
    disp(' ');
    disp('++++ Input File Selected.');
    disp(['> ',in_file]);
else
    in_file=uigetfile([pwd,'/','*.nii'],'Select Input File');
    disp(' ');
    disp('++++ Input File Selected.');
    disp(['> ',in_file]);
end

% Check extension
[~,~,in_file_ext]=fileparts(in_file);

if in_file_ext == ".gz"
    disp(' ');
    disp('++++ Unzipping Input file');
    gunzip([in_path,'/',in_file]);
    disp(['> ',in_path,'/',in_file(1:end-3)]);
    delete([in_path,'/',in_file]);
end


%% Prepare for Bias-correction
copyfile([in_path,'/',in_file],...
    [out_path,'/',in_file]);

%% Setup SPM Batch
clear matlabbatch;
matlabbatch{1}.spm.spatial.preproc.channel.vols = {[out_path,'/',in_file,',1']};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 30;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_directory,'/tpm/TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_directory,'/tpm/TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_directory,'/tpm/TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_directory,'/tpm/TPM.nii,4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_directory,'/tpm/TPM.nii,5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_directory,'/tpm/TPM.nii,6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni'; %'eastern'
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 2;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
    NaN NaN NaN];
%% Start SPM Job
disp(' ');
disp('++++ Starting Unified Segmentation');
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

%% Rename output file
% Bias corrected file
copyfile([out_path,'/m',in_file],[out_path,'/',in_file(1:end-4),'_biascorrected.nii']);
delete([out_path,'/m',in_file]);
% Bias field file
copyfile([out_path,'/BiasField_',in_file],[out_path,'/',in_file(1:end-4),'_biasfield.nii']);
delete([out_path,'/BiasField_',in_file]);
% mat file
delete([out_path,'/',in_file(1:end-4),'_seg8.mat']);
% Rename C1
copyfile([out_path,'/c1',in_file],[out_path,'/',in_file(1:end-4),'_class1.nii']);
delete([out_path,'/c1',in_file]);
% Rename C2
copyfile([out_path,'/c2',in_file],[out_path,'/',in_file(1:end-4),'_class2.nii']);
delete([out_path,'/c2',in_file]);
% Rename C3
copyfile([out_path,'/c3',in_file],[out_path,'/',in_file(1:end-4),'_class3.nii']);
delete([out_path,'/c3',in_file]);
%% Combine masks
clear matlabbatch;
matlabbatch{1}.spm.util.imcalc.input = {
    [out_path,'/',in_file(1:end-4),'_class1.nii']
    [out_path,'/',in_file(1:end-4),'_class2.nii']
    [out_path,'/',in_file(1:end-4),'_class3.nii']
    };
matlabbatch{1}.spm.util.imcalc.output = [out_path,'/',in_file(1:end-4),'_brainmask.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3)>0.3'; % more liberal than typically required
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = -7;
matlabbatch{1}.spm.util.imcalc.options.dtype = 2;
%% Start SPM Job
disp(' ');
disp('++++ Preparing Brainmask');
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
%% Output WM Mask
clear matlabbatch;
matlabbatch{1}.spm.util.imcalc.input = {
    [out_path,'/',in_file(1:end-4),'_class2.nii']
    };
matlabbatch{1}.spm.util.imcalc.output = [out_path,'/',in_file(1:end-4),'_WMmask.nii'];
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = '(i1)>0.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = -7;
matlabbatch{1}.spm.util.imcalc.options.dtype = 2;
%% Start SPM Job
disp(' ');
disp('++++ Preparing WMmask');
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);
%% Fin
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Completed Pre-processing UNI']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
