function presurf_UNI(full_path_to_file)
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Start Pre-processing UNI']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
%% Check if SPM Directory exists on path
if exist('spm') == 0
    disp('++++ SPM directory not found in path.');
    disp(' ');
    spm_directory = uigetdir(pwd, 'Select directory with SPM 12');
    addpath(spm_directory);
    disp(['> ', spm_directory]);
    disp('> Added to path');
else
    spm_directory = which('spm');
    spm_directory = spm_directory(1:end - 6);
    disp('++++ SPM directory exists in path.');
    disp(['> ', spm_directory]);
end
%% Select Data
if exist('full_path_to_file', 'var') == 1
    disp(' ');
    disp('++++ Input File Provided.');
    disp(['> ', full_path_to_file]);
else
    [in_file_name,in_file_path] = uigetfile('*.nii;*.nii.gz', 'Select Input File');
    disp(' ');
    disp('++++ Input File Selected.');
    full_path_to_file=fullfile(in_file_path,in_file_name);
    disp(['> ', full_path_to_file]);
end

% make outpath directory
[in_file_path, in_file_prefix, in_file_ext] = fileparts(full_path_to_file);
full_path_to_out = fullfile(in_file_path, 'presurf_UNI');
mkdir(full_path_to_out);
disp(' ');
disp('++++ Output Directory Created.');
disp(['> ', full_path_to_out]);

if in_file_ext == ".gz"
    disp(' ');
    disp('++++ Unzipping Input file');
    disp(['> ', full_path_to_file]);
    gunzip(full_path_to_file);
    delete(full_path_to_file);
    in_file_name=[in_file_prefix,'.nii'];
    disp('++++ Unzipped Input file');
    full_path_to_file=fullfile(in_file_path,in_file_name);
    disp(['> ', full_path_to_file]);
else
    disp('++++ Input file is unzipped');
    in_file_name=[in_file_prefix,'.nii'];
    disp(['> ', full_path_to_file]);
end

%% Make copy
copyfile(full_path_to_file, ...
    fullfile(full_path_to_out, in_file_name));

%% Setup SPM Batch
clear matlabbatch;
matlabbatch{1}.spm.spatial.preproc.channel.vols = {[fullfile(full_path_to_out,in_file_name),',1']};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 30;
matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[fullfile(spm_directory, 'tpm','TPM.nii'),',6']};
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
% Remove mat file
delete(fullfile(full_path_to_out,[in_file_prefix,'_seg8.mat']));
save(fullfile(full_path_to_out,[in_file_prefix,'_presurfSegBatch.mat']),'matlabbatch');


% Bias corrected file
copyfile(fullfile(full_path_to_out,['m',in_file_name]), fullfile(full_path_to_out,[in_file_prefix,'_biascorrected.nii']));
delete(fullfile(full_path_to_out,['m',in_file_name]));

% Bias field file
copyfile(fullfile(full_path_to_out,['BiasField_',in_file_name]), fullfile(full_path_to_out,[in_file_prefix,'_biasfield.nii']));
delete(fullfile(full_path_to_out,['BiasField_',in_file_name]));

% Rename C3
copyfile(fullfile(full_path_to_out,['c1',in_file_name]), fullfile(full_path_to_out,[in_file_prefix,'_class1.nii']));
delete(fullfile(full_path_to_out,['c1',in_file_name]));
% Rename C4
copyfile(fullfile(full_path_to_out,['c2',in_file_name]), fullfile(full_path_to_out,[in_file_prefix,'_class2.nii']));
delete(fullfile(full_path_to_out,['c2',in_file_name]));
% Rename C5
copyfile(fullfile(full_path_to_out,['c3',in_file_name]), fullfile(full_path_to_out,[in_file_prefix,'_class3.nii']));
delete(fullfile(full_path_to_out,['c3',in_file_name]));

%% Combine masks
clear matlabbatch;
matlabbatch{1}.spm.util.imcalc.input = {
    fullfile(full_path_to_out,[in_file_prefix,'_class1.nii'])
    fullfile(full_path_to_out,[in_file_prefix,'_class2.nii'])
    fullfile(full_path_to_out,[in_file_prefix,'_class3.nii'])
    };
matlabbatch{1}.spm.util.imcalc.output = fullfile(full_path_to_out,[in_file_prefix,'_brainmask.nii']);
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
save(fullfile(full_path_to_out,[in_file_prefix,'_presurfStripBatch.mat']),'matlabbatch');
%% Output WM Mask
clear matlabbatch;
matlabbatch{1}.spm.util.imcalc.input = {
    fullfile(full_path_to_out,[in_file_prefix,'_class2.nii'])
    };
matlabbatch{1}.spm.util.imcalc.output = [out_path,in_file(1:end-4),'_WMmask.nii'];
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
save(fullfile(full_path_to_out,[in_file_prefix,'_presurfWMBatch.mat']),'matlabbatch');

%% Fin
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')),'        Completed Pre-processing UNI']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
