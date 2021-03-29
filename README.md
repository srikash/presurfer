# presurfer [![DOI](https://zenodo.org/badge/307506444.svg)](https://zenodo.org/badge/latestdoi/307506444)

## Example
### Step-0 : MPRAGEise UNI
Run `presurf_MPRAGEise` <br>

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/presurfer_step0.gif" width="400">

[MPRAGEising is better than background removal ('denoising')](https://github.com/srikash/3dMPRAGEise)
<br>

Optional: \
Strip dielectric pads if used now (see [PadsOff](https://github.com/srikash/faceoff/blob/master/PadsOff), needs [ANTs](https://github.com/srikash/TheBeesKnees/wiki/Installing-Advanced-Normalization-Tools-(ANTs)))

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/presurfer_step0b.gif" width="400">

### Step-1 : Get a stripMask from INV2
Run `presurf_INV2` <br>

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/presurf_INV2_output.png" width="400">

### Step-2 : Get a brainMask from UNI
Run `presurf_UNI` <br>

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/presurf_UNI_output.png" width="400">

### Step-3 : Freesurfer
Use the INV2 stripMask to clean up the non-brain parts of the MPRAGEised UNI image.

e.g. `fslmaths MPRAGEised.nii -mul stripMask.nii MPRAGEised_stripped.nii`

Run `recon-all` using the MPRAGEised_stripped image <br>

Here is an example of a fully automated segmentation using presurfer + Freesurfer and laminar surfaces: 

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/freesurfer_seg.png" width="1200">

<br>

<img src="https://github.com/srikash/TheBeesKnees/blob/main/imgs/drake_presurfer.jpg" width="400">

### Misc. note
Run `presurf_biascorrect` to do just do SPM bias-correction.
<br>

Every step produces a sub-directory in the working directory containing all relevant segmentations and masks.
<br>

e.g. running `presurf_INV2` creates a presurf_INV2 sub-directory
