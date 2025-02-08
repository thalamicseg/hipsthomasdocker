# HIPS-THOMAS

>[!WARNING]
>This Software has been designed for research purposes only and has not been reviewed or approved by the Food and Drug Administration or by any other agency. YOU ACKNOWLEDGE AND AGREE THAT CLINICAL APPLICATIONS ARE NEITHER RECOMMENDED NOR ADVISED. Any use of the Software is at the sole risk of the party or parties engaged in such use.


## Introduction
This is the repository for HIPS-THOMAS, a Docker-based pipeline for accurate segmentation of the Thalamus and several other sub-cortical nuclei using the THOMAS segmentation program. HIPS-THOMAS processes both WMn (white matter nulled) and T1w (SPGR,MPRAGE) images but performs much better than THOMAS for T1w data as it synthesizes WMn-like images from T1s prior to running THOMAS.

The HIPS-THOMAS workflow is illustrated here:

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/main/HIPSTHOMAS.jpg)


## Features
This container-based version for THOMAS has a number of new features:
1. It is based on Python 3.12 and uses a minimal number of modules from FSL, making it much smaller than previous versions (16G vs 41G).
2. It now also segments the basal ganglia, claustrum, and red nucleus!!
3. It generates a quality control file called `stlabels_LR.png` and a composite label file with contiguous labels (for deep learning training) called `stlabels_LR.nii.gz`. Both files are produced at the top level of output results: parallel with the `left` and `right` directories.

#### Differences from previous versions:
1. The main script is now Bash shell based and is called `hipsthomas.sh`,
2. The result files (`thomas`, `thomas_R`, `thomasfull_L`, and `thomasfull_R` now have both thalami and other deep grey structures,
3. The `nuclei_vols*.txt` files have volumes of both thalami and other deep grey structures,
4. The right side processing uses the same crop as the left side, so it is faster and you can combine L and R easily (e.g., using fslmaths).

## Repository Resources

-  **thomas_t1.sh**: is the main script to call to process T1 MPRAGE or SPGR files.
-  **thomas_wmn.sh**: is the main script to call to process WMn MPRAGE/FGATIR files.
-  **thomas_batch.sh**: <mark>TODO</mark>
-  **example.tgz**: a gzipped tar file containing sample T1 and WMn images.
-  **CustomAtlas.ctbl**: is a color table, provided for visualization.
-  **thomas.lut**: another color table, used for <mark>TODO</mark>.


## Installation
>[!NOTE]
>To run the HIPS_THOMAS program you must have a working installation of the [Docker platform software](https://www.docker.com/get-started) on your local computer. Installation instructions vary by OS, so please see this ["Getting Started with Docker"](https://www.docker.com/get-started) page for simple instructions on how to download and install Docker.

#### Get HIPS-THOMAS

The HIPS-THOMAS program is packaged as a Docker container. As the container is fairly large (~17G), we recommend that you download it to your local machine before first use. Once Docker is installed on your computer, you may download the HIPS-THOMAS container via the Docker Desktop GUI (if you installed it) or via this command line instruction:
```
docker pull anagrammarian/sthomas
```

## Running
To run HIPS-THOMAS, each anatomical file should be in a separate directory and the results are placed in that same directory. You can launch the container from the command line by running the provided shell scripts inside the directory containing the input image file.

For example, given an input image 'T1.nii.gz', in the current working directory, the container would be run by the following command:
```
thomas_t1.sh T1.nii.gz
```

For T1 MPRAGE and SPGR images, HIPS synthesizes WMn-MPRAGE like images, improving thalamic contrast and also allowing standard THOMAS to be run (which then uses CC metric for nonlinear registration and joint fusion). This is not possible with direct T1 as the contrast is different from the template, thus forcing MI metric (which is less accurate) and majority voting for label fusion (which is also suboptimal).

THOMAS processing works even better on WMn MPRAGE (FGATIR) data, due to the better intra-thalamic contrast. In the following example, WMn.nii.gz is the white matter nulled MPRAGE file (or FGATIR if you will/must).
```
thomas_wmn.sh WMn.nii.gz
```


### Apptainer (nee Singularity):

You can directly pull the Docker container image from dockerhub and save it as an Apptainer (Singularity) '.sif' file.

First, install Apptainer using the instructions found here https://apptainer.org/docs/admin/main/installation.html. Once installed, run:
```
apptainer build sthomas.sif docker://anagrammarian/sthomas
```

<mark>TODO: check</mark>
The Apptainer instantiation is a little bit different than Docker. For example, to run on a T1 image, call Apptainer like this:
```
thomas_t1_apptainer.sh T1.nii.gz
```

For a WMn/FGATIR image run the following:
```
thomas_wmn_apptainer.sh WMn.nii.gz
```

>[!NOTE]
>That the `sthomas.sif` container can be saved and run from anywhere (illustrated in the above example by 'path/to/sthomas.sif'). For example, if you save the container in your home bin directory (~/bin), you would specify the path as `/home/yourusername/bin/sthomas.sif`


## Outputs
The directories named **left** and **right** contain the outputs, which include:
- The individual label files for each nucleus (e.g. 2-AV.nii.gz for Anteroventral and so on)
- **thomas_L.nii.gz** (or **thomas_R.nii.gz**): a single file with all nucleus labels, cropped to the region of interest.
- **thomasfull_L.nii.gz** (or **thomasfull_R.nii.gz**): which is the same size as the input file (i.e. full size as opposed to the **thomas_{L/R}.nii.gz** files which are cropped).
- **nucleiVols.txt** and **nucleiVolsMV.txt**: contains the nuclei volume statistics for joint fusion and majority voting, respectively.
- **regn.nii.gz**: is the custom template registered to the input image. This file is critical for debugging. Make sure this file and **crop_**\<inputfilename\> are well aligned. Note that this is for left side. The right regn.nii.gz needs to be swapped LR before it will align to **crop_**\<inputfilename\>. 


## Citation
HIPS-THOMAS is in press in *Brain Structure and Function*. The *medRxiv* preprint can be found at https://www.medrxiv.org/content/10.1101/2024.01.30.24301606v1

	Vidal JP, Danet L, Péran P, Pariente J, Bach Cuadra M, Zahr NM, Barbeau EJ, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI using polynomial intensity transformation. Brain Structure and Function; 2024

The original *Neuroimage* paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Thalamus Optimized Multi-atlas Segmentation (THOMAS): fast, fully automated segmentation of thalamic nuclei from anatomical MRI. NeuroImage; 194:272-282 (2019)


## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu if you have any questions or difficulties in installing or using THOMAS.


## License

>[!WARNING]
>This Software is provided "AS IS" and neither University of Arizona (UofAZ) nor any contributor to the software (each a "Contributor") shall have any obligation to provide maintenance, support, updates, enhancements or modifications thereto. UofAZ AND ALL CONTRIBUTORS SPECIFICALLY DISCLAIM ALL EXPRESS AND IMPLIED WARRANTIES OF ANY KIND INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL UofAZ OR ANY CONTRIBUTOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ARISING IN ANY WAY RELATED TO THE SOFTWARE, EVEN IF UofAZ OR ANY CONTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. TO THE MAXIMUM EXTENT NOT PROHIBITED BY LAW OR REGULATION, YOU FURTHER ASSUME ALL LIABILITY FOR YOUR USE, REPRODUCTION, MAKING OF DERIVATIVE WORKS, DISPLAY, LICENSE OR DISTRIBUTION OF THE SOFTWARE AND AGREE TO INDEMNIFY AND HOLD HARMLESS UofAZ AND ALL CONTRIBUTORS FROM AND AGAINST ANY AND ALL CLAIMS, SUITS, ACTIONS, DEMANDS AND JUDGMENTS ARISING THEREFROM.

© Copyright Manoj Saranathan 2023. All rights reserved.
