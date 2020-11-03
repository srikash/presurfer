%% This is the main workflow script

% Load data
[INV2file,INV2path]=uigetfile('*INV2*.*','Select INV2');
[UNIfile,UNIpath]=uigetfile('*UNI*.*','Select UNI');

% Segment INV2
ps_process_INV2(INV2path,INV2file);

% Segment UNI
ps_process_UNI(UNIpath,UNIfile);

