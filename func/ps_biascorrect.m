function ps_biascorrect(in_path,in_file)
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Starting SPM Bias-correction']);
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
out_path=[in_path,'ps_biascorrected/'];
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
    in_file=uigetfile([pwd,'*.nii'],'Select Input File');
    disp(' ');
    disp('++++ Input File Selected.');
    disp(['> ',in_file]);
end

% Check extension
[~,~,in_file_ext]=fileparts(in_file);

if in_file_ext == ".gz"
    disp(' ');
    disp('++++ Unzipping Input file');
    gunzip([in_path,in_file]);
    disp(['> ',in_path,in_file(1:end-3)]);
    delete([in_path,in_file]);
end


%% Prepare for Bias-correction
copyfile([in_path,in_file],...
    [out_path,in_file]);


%% Setup SPM Batch
clear matlabbatch;

matlabbatch{1}.spm.spatial.preproc.channel.vols = {[out_path,in_file,',1']};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 30;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_directory,'/tpm/TPM.nii,1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_directory,'/tpm/TPM.nii,2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_directory,'/tpm/TPM.nii,3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [0 0];
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
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
%% Start SPM Job
disp(' ');
disp('++++ Starting Bias-correction');
spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

%% Rename output file
% Bias corrected file
copyfile([out_path,'/m',in_file],[out_path,in_file(1:end-4),'_biascorrected.nii']);
delete([out_path,'/m',in_file]);
% Bias field file
copyfile([out_path,'/BiasField_',in_file],[out_path,in_file(1:end-4),'_biasfield.nii']);
delete([out_path,'/BiasField_',in_file]);
% mat file
delete([out_path,in_file(1:end-4),'_seg8.mat']);

%% Fin
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Completed SPM Bias-correction']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
