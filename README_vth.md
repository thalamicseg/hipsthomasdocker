# HIPS-THOMAS

>[!WARNING]
>This Software has been designed for research purposes only and has not been reviewed or approved by the Food and Drug Administration or by any other agency. YOU ACKNOWLEDGE AND AGREE THAT CLINICAL APPLICATIONS ARE NEITHER RECOMMENDED NOR ADVISED. Any use of the Software is at the sole risk of the party or parties engaged in such use.


## Introduction
This is the repository for HIPS-THOMAS, a Docker-based pipeline for accurate segmentation of thalamic and several other deep grey nuclei using the THOMAS segmentation program. HIPS-THOMAS processes both White-matter-nulled (WMn aka FGATIR) and standard T1-weighted (3D SPGR,MPRAGE, IR-SPGR) images. For standard T1 MRI, it synthesizes WMn-like images prior to segmentation resulting in much improved performance compared to majority voting and mutual-information based registration approaches previously proposed.

The HIPS-THOMAS workflow is illustrated here:

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/rev2/HIPSTHOMAS.jpg)


## Features
This container-based version for THOMAS has a number of new features:
1. It is based on Python 3.12 and uses a minimal number of modules from FSL, making it much smaller than previous versions (16G vs 41G).
2. It now also segments the basal ganglia, claustrum, red nucleus with hippocampus, amygdala, and the ventricles coming very soon. 
3. It generates a quality control file called `stlabels_LR.png` and a composite label file with contiguous left and right labels (for deep learning training) called `stlabels_LR.nii.gz`. Both files are produced at the top level of output results: parallel with the `left` and `right` directories.
4. Centrolateral (CL) nucleus is also generated but using a different provenance so is not fused in the thomas/thomasfull files but available as 18-CL and 18-CL_full 

#### Differences from previous versions:
1. The main script is now bash shell based and is called `hipsthomas.sh` (replacing hipsthomas_csh)
2. The result files (`thomas`, `thomas_R`, `thomasfull_L`, and `thomasfull_R` now have both thalami and deep grey nuclei,
3. The `nuclei_vols*.txt` files have volumes of both thalami and deep grey nuclei,
4. The right side processing uses the same crop as the left side, so it is faster and you can combine L and R easily (e.g., using fslmaths).

## Repository Resources

-  **thomas_t1.sh**: is the main script to call to process T1 MPRAGE or SPGR files.
-  **thomas_wmn.sh**: is the main script to call to process WMn MPRAGE/FGATIR files.
-  **thomas_batch.sh**: <mark>TODO</mark>
-  **example.tgz**: a gzipped tar file containing sample T1 and WMn images.
-  **CustomAtlas.ctbl**: is a color table, provided for visualization.
-  **thomas.lut**: another color table, used for <mark>TODO</mark>.


## Running
Make sure docker is installed already on your machine or install it from here https://docs.docker.com/get-docker/.  

Download the HIPS-THOMAS container from dockerhub ```docker pull anagrammarian/sthomas```. You can paste this command on the docker shell or in a Terminal if the docker desktop is running.

To run HIPS-THOMAS, each anatomical file should be in a separate directory and the results are placed in that same directory. You can launch the container from the command line by running the provided shell scripts inside the directory containing the input image file.

For example, given an input image 'T1.nii.gz', in the current working directory, the container would be run by the following command:
```
thomas_t1.sh T1.nii.gz
```

For T1 MPRAGE/SPGR images, HIPS synthesizes WMn-MPRAGE like images, improving thalamic contrast and also allowing standard THOMAS to be run (which then uses CC metric for nonlinear registration and joint fusion). This is not possible with direct T1 as the contrast is different from the template, thus forcing MI metric (which is less accurate) and majority voting for label fusion (which is also suboptimal).

THOMAS processing works even better on WMn MPRAGE (FGATIR) data, due to the better intra-thalamic contrast. In the following example, WMn.nii.gz is the white matter nulled MPRAGE file (or FGATIR if you will/must).
```
thomas_wmn.sh WMn.nii.gz
```
TODO- need to tell users how to clone repository or at least download scripts/example

Still think having a script free copy paste from here docker run bla blal is useful. 

### Apptainer (nee Singularity):

You can directly pull the Docker container image from dockerhub and save it as an Apptainer (Singularity) '.sif' file.

First, install Apptainer using the instructions found here https://apptainer.org/docs/admin/main/installation.html. Once installed, run:
```
apptainer build sthomas.sif docker://anagrammarian/sthomas
```

<mark>TODO: check</mark>
The Apptainer instantiation is a little bit different than Docker. For example, to run on a T1 image, call Apptainer like this:
```
apptainer run -B ${PWD}:${PWD} -W ${PWD} -u --cleanenv path/to/thomas3.sif bash -c "hipsthomas.sh -i T1.nii.gz - big"
```

For a WMn/FGATIR image run the following:
```
apptainer run -B ${PWD}:${PWD} -W ${PWD} -u --cleanenv path/to/thomas3.sif bash -c "hipsthomas.sh -i WMn.nii.gz"
```

>[!NOTE]
>That the `sthomas.sif` container can be saved and run from anywhere (illustrated in the above example by 'path/to/sthomas.sif'). For example, if you save the container in your home bin directory (~/bin), you would specify the path as `/home/yourusername/bin/sthomas.sif`


## Outputs
The directories named **left** and **right** contain the outputs, which include:
- The individual label files for each nucleus (e.g. 2-AV.nii.gz for Anteroventral and so on)
- **thomas_L.nii.gz** (or **thomas_R.nii.gz**): a single file with all nucleus labels, cropped to the region of interest.
- **thomasfull_L.nii.gz** (or **thomasfull_R.nii.gz**): which is the same size as the input file (i.e. full size as opposed to the **thomas_{L/R}.nii.gz** files which are cropped).
- **nucleiVols.txt** and **nucleiVolsMV.txt**: contains the nuclei volume statistics for joint fusion and majority voting, respectively.
- **regn.nii.gz**: is the custom template registered to the input image. This file is critical for debugging and is the lower panel of the qc image. Make sure this file and **crop_**\<inputfilename\> are well aligned. Note that this is separate for left and right sides. 


## Citation
The HIPS-THOMAS paper published in Brain Structure and Function can be found here https://pubmed.ncbi.nlm.nih.gov/38546872/ 

The *medRxiv* preprint can be found at https://www.medrxiv.org/content/10.1101/2024.01.30.24301606v1

	Vidal JP, Danet L, Péran P, Pariente J, Bach Cuadra M, Zahr NM, Barbeau EJ, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI using polynomial intensity transformation. Brain Structure and Function; 229(5):1087-1101 (2024)

The original *Neuroimage* paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Thalamus Optimized Multi-atlas Segmentation (THOMAS): fast, fully automated segmentation of thalamic nuclei from anatomical MRI. NeuroImage; 194:272-282 (2019)


## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu if you have any questions or difficulties in installing or using THOMAS.


## License

>[!WARNING]
>This Software is provided "AS IS" and neither University of Arizona (UofAZ) nor any contributor to the software (each a "Contributor") shall have any obligation to provide maintenance, support, updates, enhancements or modifications thereto. UofAZ AND ALL CONTRIBUTORS SPECIFICALLY DISCLAIM ALL EXPRESS AND IMPLIED WARRANTIES OF ANY KIND INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL UofAZ OR ANY CONTRIBUTOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ARISING IN ANY WAY RELATED TO THE SOFTWARE, EVEN IF UofAZ OR ANY CONTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. TO THE MAXIMUM EXTENT NOT PROHIBITED BY LAW OR REGULATION, YOU FURTHER ASSUME ALL LIABILITY FOR YOUR USE, REPRODUCTION, MAKING OF DERIVATIVE WORKS, DISPLAY, LICENSE OR DISTRIBUTION OF THE SOFTWARE AND AGREE TO INDEMNIFY AND HOLD HARMLESS UofAZ AND ALL CONTRIBUTORS FROM AND AGAINST ANY AND ALL CLAIMS, SUITS, ACTIONS, DEMANDS AND JUDGMENTS ARISING THEREFROM.

© Copyright Manoj Saranathan Julie Vidal 2023 2024 2025. All rights reserved.
