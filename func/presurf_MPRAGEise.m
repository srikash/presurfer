function full_path_to_output = presurf_MPRAGEise(full_path_to_inv2,full_path_to_uni)
spm_directory="/opt/spm12/spm12_mcr/spm/spm12";
addpath(spm_directory);
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')), '        Start MPRAGEising']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
%% Check if SPM Directory exists on path
if exist('spm') == 0
    disp('++++ SPM directory not found in path.');
    disp(' ');
    spm_directory = uigetdir(pwd, 'Select directory with SPM 12');
    addpath(spm_directory);
    disp(['> ', spm_directory]);
    disp(['> Added to path']);
else
    spm_directory = which('spm');
    spm_directory = spm_directory(1:end - 6);
    disp('++++ SPM directory exists in path.');
    disp(['> ', spm_directory]);
    
end
%% Select Data
if exist('full_path_to_inv2', 'var') == 1
    disp(' ');
    disp('++++ Input File Provided.');
    disp(['> ', full_path_to_inv2]);
else
    [inv2_file_name,inv2_file_path] = uigetfile('*.nii;*.nii.gz', 'Select INV2');
    disp(' ');
    disp('++++ Input INV2 Selected.');
    full_path_to_inv2=fullfile(inv2_file_path,inv2_file_name);
    disp(['> ', full_path_to_inv2]);
end

if exist('full_path_to_uni', 'var') == 1
    disp(' ');
    disp('++++ Input File Provided.');
    disp(['> ', full_path_to_uni]);
else
    [uni_file_name,uni_file_path] = uigetfile('*.nii;*.nii.gz', 'Select UNI image');
    disp(' ');
    disp('++++ Input UNI Selected.');
    full_path_to_uni=fullfile(uni_file_path,uni_file_name);
    disp(['> ', full_path_to_uni]);
end

% make outpath directory
[inv2_file_path, inv2_file_prefix, inv2_file_ext] = fileparts(full_path_to_inv2);
[uni_file_path, uni_file_prefix, uni_file_ext] = fileparts(full_path_to_uni);
full_path_to_out = fullfile(uni_file_path, 'presurf_MPRAGEise');
mkdir(full_path_to_out);
disp(' ');
disp('++++ Output Directory Created.');
disp(['> ', full_path_to_out]);

if uni_file_ext == ".gz"
    disp(' ');
    disp('++++ Unzipping Input file');
    disp(['> ', full_path_to_uni]);
    gunzip(full_path_to_uni);
    delete(full_path_to_uni);
    full_path_to_uni=fullfile(uni_file_path,uni_file_prefix);
    uni_file_name=uni_file_prefix;
    [~, uni_file_prefix, ~] = fileparts(full_path_to_uni);
    disp('++++ Unzipped Input file');
    disp(['> ', full_path_to_uni]);
else
	disp('++++ Input UNI is unzipped');
	uni_file_name=uni_file_prefix;
    disp(['> ', full_path_to_uni]);
end

if inv2_file_ext == ".gz"
    disp(' ');
    disp('++++ Unzipping Input file');
    disp(['> ', full_path_to_inv2]);
    gunzip(full_path_to_inv2);
    delete(full_path_to_inv2);
    full_path_to_inv2=fullfile(inv2_file_path,inv2_file_prefix);
    inv2_file_name=inv2_file_prefix;
    [~, inv2_file_prefix, ~] = fileparts(full_path_to_inv2);
    disp('++++ Unzipped Input file');
    disp(['> ', full_path_to_inv2]);
else
	disp('++++ Input INV2 is unzipped');
    inv2_file_name=inv2_file_prefix;
    disp(['> ', full_path_to_inv2]);
end
%% Bias-correct INV2
presurf_biascorrect(full_path_to_inv2);
full_path_to_inv2=fullfile(inv2_file_path,'presurf_biascorrect',[inv2_file_prefix,'_biascorrected.nii']);

%% Start MPRAGEising
uni_nii=spm_vol(full_path_to_uni);
uni_img = spm_read_vols(uni_nii);

inv2_img = spm_read_vols(spm_vol(full_path_to_inv2));
inv2_img_norm = mat2gray(inv2_img);

uni_img_clean = uni_img.*inv2_img_norm;

uni_nii.fname=fullfile(full_path_to_out,[uni_file_prefix,'_MPRAGEised.nii']);
spm_write_vol(uni_nii,uni_img_clean);

full_path_to_output = uni_nii.fname;

% Clean Up
rmdir(fullfile(inv2_file_path,'presurf_biascorrect'),'s');
%% Fin
disp(' ');
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp([datestr(datetime('now')), '        Completed MPRAGEising']);
disp('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
disp(' ');
