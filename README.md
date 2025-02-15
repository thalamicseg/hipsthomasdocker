# HIPS-THOMAS

>[!WARNING]
>This Software has been designed for research purposes only and has not been reviewed or approved by the Food and Drug Administration or by any other agency. YOU ACKNOWLEDGE AND AGREE THAT CLINICAL APPLICATIONS ARE NEITHER RECOMMENDED NOR ADVISED. Any use of the Software is at the sole risk of the party or parties engaged in such use.


## Introduction
This is the repository for HIPS-THOMAS, a Docker-based pipeline for accurate segmentation of thalamic and several other deep grey nuclei using the THOMAS segmentation program. HIPS-THOMAS processes both white-matter-nulled (WMn aka FGATIR) and standard T1-weighted (3D SPGR, MPRAGE, IR-SPGR) images. For standard T1 MRI it synthesizes WMn-like images prior to segmentation, resulting in much improved performance compared to majority voting and mutual information based registration approaches previously proposed. Specifically, for T1 images HIPS synthesizes WMn-MPRAGE-like images, improving thalamic contrast and also allowing standard THOMAS to be run (which then uses CC metric for nonlinear registration and joint fusion). This processing is not possible with T1 as the contrast is different from the template, thus forcing a mutual information metric (which is less accurate) and majority voting for label fusion (which is also suboptimal).

The HIPS-THOMAS workflow is illustrated here:

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/main/HIPSTHOMAS.jpg)


## Features
This container-based version for THOMAS has a number of new features:
1. It is based on Python 3.12 and uses a minimal number of modules from FSL, making it much smaller than previous versions (16G vs 41G).
2. It now also segments the basal ganglia, claustrum, red nucleus with hippocampus, and amydala (with ventricles coming soon).
3. It generates a quality control file called `stlabels_LR.png` and a composite label file with contiguous left and right labels (for deep learning training) called `stlabels_LR.nii.gz`. Both files are produced at the top level of output results: parallel with the `left` and `right` results directories.
4. The Centrolateral (CL) nucleus is also generated, but with a different provenance so it is not fused in the thomas or thomasfull files but is available in the `CL_L.nii.gz` and `CL_R.nii.gz` files.

#### Differences from previous versions:
1. The main script is now Bash shell based and is called `hipsthomas.sh` (replacing hipsthomas_csh),
2. The result files (`thomas_L`, `thomas_R`, `thomasfull_L`, and `thomasfull_R` now have both thalami and deep grey nuclei,
3. The `nuclei_vols*.txt` files have volumes of both thalami and deep grey nuclei,
4. The right side processing uses the same crop as the left side, so it is faster and you can combine L and R easily (e.g., using fslmaths).

## Repository Resources

-  **thomas_t1.sh**: is the main script to call to process T1 MPRAGE or SPGR files.
-  **thomas_wmn.sh**: is the main script to call to process WMn MPRAGE/FGATIR files.
-  **thomas_batch.sh**: <mark>TODO</mark>
-  **thomas_tree.sh**: <mark>TODO</mark>
-  **example.tgz**: a gzipped tar file containing sample T1 and WMn images.
-  **CustomAtlas.ctbl**: is a color table, provided for visualization.
-  **Thomas.lut**: another color table, used for <mark>TODO</mark>.


## Installation
>[!NOTE]
To run the HIPS_THOMAS program you must have a working installation of the [Docker platform software](https://www.docker.com/get-started) on your local computer. Installation instructions vary by OS, so please see this ["Getting Started with Docker"](https://www.docker.com/get-started) page for simple instructions on how to download and install Docker.

#### Get HIPS-THOMAS

The HIPS-THOMAS program is packaged as a Docker container. As the container is fairly large (~17G), you should download it to your local machine before first use. Once Docker software is installed on your computer, you may download the HIPS-THOMAS container via the Docker Desktop GUI (if you installed it) or via this command line instruction:
```
docker pull anagrammarian/sthomas
```

#### Get the Support Files (optional)

To use HIPS-THOMAS, you issue Docker commands from the command line **OR** use one of several shell scripts provided in this [support repository](https://github.com/thalamicseg/hipsthomasdocker). If you have Git installed on your computer, the following command will download the support files into a directory named `hipsthomasdocker`:
```
git clone https://github.com/thalamicseg/hipsthomasdocker.git
```
In addition to convenient run scripts, the support repository also includes example T1 and WMn images and some color lookup tables.

## Running

Each anatomical image file to be processed should be in a separate directory and the results are placed in that same directory. You can launch the HIPS-THOMAS container from the command line by running the relevant Docker command (or relevant shell script) inside the directory containing the input image file.

### Running with Docker from the Command Line

Once you have downloaded the HIPS-THOMAS Docker container, you may start processing an image by moving to the directory containing the image and invoking Docker from the command line. Results will be placed in the image directory and two subdirectories (named `left` and `right`).

>[!NOTE]
The following example Docker command lines assume `bash` as the shell. Also, running Docker on Linux requires a slightly different command line than on macOS or Windows, so please select the appropriate command for your operating system.

**T1 on Linux**: Given a T1 input image, 'T1.nii.gz', in the current working directory, processing can be initiated by the following Docker command:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data --user ${UID}:${GID} anagrammarian/sthomas hipsthomas.sh -v -i T1.nii.gz -t1
```

**T1 on macOS**: On macOS you should omit the `--user` flag and the user ID (`UID`) and group ID (`GID`) arguments. So, for a T1 image, 'T1.nii.gz', in the current working directory:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data anagrammarian/sthomas hipsthomas.sh -v -i T1.nii.gz -t1
```

**WMn on Linux**: Given a WMn input image, 'WMn.nii.gz', in the current working directory, processing can be initiated by the following Docker command:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data --user ${UID}:${GID} anagrammarian/sthomas hipsthomas.sh -v -i WMn.nii.gz
```

**WMn on macOS**: On macOS you should omit the `--user` flag and the user ID (`UID`) and group ID (`GID`) arguments. So, for a WMn image, 'WMn.nii.gz', in the current working directory:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data anagrammarian/sthomas hipsthomas.sh -v -i WMn.nii.gz
```


### Running with the Support Scripts

[As mentioned above](#get-the-support-files-optional), this support repository provides several "wrapper" scripts which can be used to process one (or more) structural images. For example, given an input image 'T1.nii.gz', in the current working directory, processing can be initiated by using the relevant T1 script from the support repository:
```
thomas_t1.sh T1.nii.gz
```

For WMn (FGATIR, if you will) images, THOMAS processing works better, due to the better intra-thalamic contrast. In the following example, the white matter nulled MPRAGE file (WMN.nii.gz) in the current directory, is processed using the relevant WMn script from the support repository:
```
thomas_wmn.sh WMn.nii.gz
```

### Running with Apptainer (nee Singularity):

You can pull the Docker container image directly from DockerHub and save it as an Apptainer (Singularity) '.sif' file.

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
- **regn.nii.gz**: is the custom template registered to the input image. This file is critical for debugging and is shown in the lower panel of the quality control image. Make sure this file and **crop_**\<inputfilename\> are well aligned. Note that this is separate for left and right sides.
- **EXTRAS**: Additional processing artifacts are saved in both the `left` and `right` subdirectories.
- **EXTRAS/MV**: <mark>TODO: explain</mark>

### List of Output ROIs
| Label | Region of Interest |
|:------|:-------------------|
|  1-THALAMUS | Thalamus (whole) |
|  2-AV | Antero-Ventral Nucleus |
|  4-VA | Ventral Anterior Nucleus |
|  5-VLa | Ventral Lateral Nucleus (anterior) |
|  6-VLP | Ventral Lateral Nucleus (posterior) |
|  7-VPL | Ventral Posterior Lateral |
|  4567-VL | Ventral Lateral |
|  8-Pul | Pulvinar |
|  9-LGN | Lateral Geniculate Nucleus |
| 10-MGN | Medial Geniculate Nucleus |
| 11-CM | Centromedian Nucleus |
| 12-MD-Pf | Mediodorsal Nucleus |
| 13-Hb | Habanula |
| 14-MTT | Mammillothalamic Tract |
| 26-Acc | Accumbens |
| 27-Cau | Caudate |
| 28-Cla | Claustrum |
| 29-GPe | Globus Pallidus External |
| 30-GPi | Globus Pallidus Internal |
| 31-Put | Putamen |
| 32-RN | Red Nucleus |
| 33-GP | Globus Pallidus |
| 34-Amy | Amygdala |
| CL | Central Lateral Nucleus |


## Citation
The HIPS-THOMAS paper published in *Brain Structure and Function* can be found here: https://pubmed.ncbi.nlm.nih.gov/38546872/

 The *medRxiv* preprint can be found at https://www.medrxiv.org/content/10.1101/2024.01.30.24301606v1

	Vidal JP, Danet L, Péran P, Pariente J, Bach Cuadra M, Zahr NM, Barbeau EJ, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI using polynomial intensity transformation. Brain Structure and Function; 229(5):1087-1101 (2024)

The original *Neuroimage* paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Thalamus Optimized Multi-atlas Segmentation (THOMAS): fast, fully automated segmentation of thalamic nuclei from anatomical MRI. NeuroImage; 194:272-282 (2019)


## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu if you have any questions or difficulties in installing or using THOMAS, or to report bugs or issues.


## License

>[!WARNING]
>This Software is provided "AS IS" and neither University of Arizona (UofAZ) nor any contributor to the software (each a "Contributor") shall have any obligation to provide maintenance, support, updates, enhancements or modifications thereto. UofAZ AND ALL CONTRIBUTORS SPECIFICALLY DISCLAIM ALL EXPRESS AND IMPLIED WARRANTIES OF ANY KIND INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL UofAZ OR ANY CONTRIBUTOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ARISING IN ANY WAY RELATED TO THE SOFTWARE, EVEN IF UofAZ OR ANY CONTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. TO THE MAXIMUM EXTENT NOT PROHIBITED BY LAW OR REGULATION, YOU FURTHER ASSUME ALL LIABILITY FOR YOUR USE, REPRODUCTION, MAKING OF DERIVATIVE WORKS, DISPLAY, LICENSE OR DISTRIBUTION OF THE SOFTWARE AND AGREE TO INDEMNIFY AND HOLD HARMLESS UofAZ AND ALL CONTRIBUTORS FROM AND AGAINST ANY AND ALL CLAIMS, SUITS, ACTIONS, DEMANDS AND JUDGMENTS ARISING THEREFROM.

© Copyright Manoj Saranathan, Julie Vidal 2023. All rights reserved.
