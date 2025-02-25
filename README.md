# HIPS-THOMAS

>[!WARNING]
>This Software has been designed for research purposes only and has not been reviewed or approved by the Food and Drug Administration or by any other agency. YOU ACKNOWLEDGE AND AGREE THAT CLINICAL APPLICATIONS ARE NEITHER RECOMMENDED NOR ADVISED. Any use of the Software is at the sole risk of the party or parties engaged in such use.


## Introduction
This is the repository for HIPS-THOMAS, a Docker-based pipeline for accurate segmentation of thalamic and several other deep grey nuclei using the THOMAS segmentation program. HIPS-THOMAS processes both white-matter-nulled (WMn aka FGATIR) and standard T1-weighted (3D SPGR, MPRAGE, IR-SPGR) images. For standard T1 MRI it synthesizes WMn-like images prior to segmentation, resulting in much improved performance compared to majority voting and mutual information based registration approaches previously proposed. Specifically, for T1 images HIPS synthesizes WMn-MPRAGE-like images, improving thalamic contrast and also allowing standard THOMAS to be run (which then uses CC metric for nonlinear registration and joint fusion). This processing is not possible with T1 as the contrast is different from the template, thus forcing a mutual information metric (which is less accurate) and majority voting for label fusion (which is also suboptimal).

>[!IMPORTANT]
The HIPS-THOMAS docker container documented here is brand-new (as of 2/23/2025). You should delete any older `anagrammarian/thomasmerged` containers on your computer and download the new one (see [Installation section](#installation) below).

### The HIPS-THOMAS workflow is illustrated here:

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/main/HIPSTHOMAS.jpg)


## Features
This container-based version for THOMAS has a number of new features:
1. It is based on Python 3.12 and uses a minimal number of modules from FSL, making it much smaller than previous versions (16G vs 41G).
2. It now also segments the basal ganglia, claustrum, and red nucleus (with amygdala/hippocampus/ventricles coming very soon).
3. It generates a quality control file called `sthomas_LR_labels.png` and a composite label file with contiguous left and right labels (for deep learning training) called `sthomas_LR_labels.nii.gz`. Both files are produced at the top level of output results: parallel with the `left` and `right` results directories.
4. The Centrolateral (CL) nucleus is also generated, but with a different provenance so it is not fused in the thomas or thomasfull files but is available as `CL_L.nii.gz` and `CL_R.nii.gz` files for reference. It will overlap with other nuclei so use with judgment and caution.

#### Differences from previous versions:
1. The main script is now bash shell based and is called `hipsthomas.sh` (replacing hipsthomas_csh),
2. The result files (`thomas_L`, `thomas_R`, `thomasfull_L`, and `thomasfull_R` now have both thalami and deep grey nuclei.
3. The `nuclei_vols*.txt` files have volumes of both thalami and deep grey nuclei.
4. The right side processing uses the same crop as the left side, so it is faster and you can combine L and R easily (e.g., using fslmaths).
5. All outputs in the main left and right directories are full-size (and match the input T1 or WMn size exactly). Cropped outputs and other accessory files for debugging are now in EXTRAS folder.
6. The temporary directories, `temp` and `tempr`, are deleted automatically to save space unless the debug flag (-d) is used.

## Repository Resources

-  **thomas_t1.sh**: is the main script to call to process T1 MPRAGE or SPGR files.
-  **thomas_wmn.sh**: is the main script to call to process WMn MPRAGE/FGATIR files.
-  **thomas_batch.sh**: Bash script to process multiple image files.
-  **thomas_tree.sh**: Supplemental script to process multiple image files within a directory tree.
-  **example.tgz**: a gzipped tar file containing sample T1 and WMn images.


## Installation
>[!IMPORTANT]
To run the HIPS_THOMAS program you must have a working installation of the [Docker platform software](https://www.docker.com/get-started) on your local computer. Installation instructions vary by OS, so please see this ["Getting Started with Docker"](https://www.docker.com/get-started) page for simple instructions on how to download and install Docker.

#### Get HIPS-THOMAS

The HIPS-THOMAS program is packaged as a Docker container. As the container is fairly large (~17G), you should download it to your local machine before first use. Once Docker software is installed on your computer, you may download the HIPS-THOMAS container via the Docker Desktop GUI (if you installed it) or via this command line instruction:
```bash
# first, remove the old thomasmerged container (if you downloaded or used it before)
docker image rm anagrammarian/thomasmerged
docker pull anagrammarian/sthomas
```

#### Get the Support Files (optional)

To use HIPS-THOMAS, you issue Docker commands from the command line **OR** use one of several shell scripts provided in this [support repository](https://github.com/thalamicseg/hipsthomasdocker). If you have Git installed on your computer, the following command will download this support files into a directory named `hipsthomasdocker`:
```
git clone https://github.com/thalamicseg/hipsthomasdocker.git
```
In addition to convenient run scripts, this support repository also includes example T1 and WMn images.

## Running

Each anatomical image file to be processed should be in a separate directory and the results are placed in that same directory. You can launch the HIPS-THOMAS container from the command line by running the relevant Docker command (or relevant shell script) inside the directory containing the input image file.

### Running with Docker from the Command Line

Once you have downloaded the HIPS-THOMAS Docker container, you may start processing an image by moving to the directory containing the image and invoking Docker from the command line. Results will be placed in the image directory and two subdirectories (named `left` and `right`).

>[!NOTE]
The following example Docker command lines assume `bash` as the shell. Also, running Docker on Linux requires a slightly different command line than on macOS or Windows, so please select the appropriate command for your operating system.

**T1 on Linux or Windows Ubuntu WSL**: Given a T1 input image (T1.nii.gz) in the current working directory, processing can be initiated by the following Docker command:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data --user ${UID}:${GID} anagrammarian/sthomas hipsthomas.sh -v -t1 -i T1.nii.gz
```

**T1 on macOS or Windows Docker Desktop**: In these environments, you should omit the `--user` flag and the user ID (`UID`) and group ID (`GID`) arguments. So, for a T1 image (subj1.nii.gz) in the current working directory:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data anagrammarian/sthomas hipsthomas.sh -v -t1 -i subj1.nii.gz
```

**FGATIR/WMn on Linux or Windows Ubuntu WSL**: Given a WMn input image (WMn.nii.gz) in the current working directory, processing can be initiated by the following Docker command:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data --user ${UID}:${GID} anagrammarian/sthomas hipsthomas.sh -v -i WMn.nii.gz
```

**FGATIR/WMn on macOS or Windows Docker Desktop**: In these environments, you should omit the `--user` flag and the user ID (`UID`) and group ID (`GID`) arguments. So, for a WMn image (CAM003_WMn.nii.gz) in the current working directory:
```
docker run -it --rm --name sthomas -v ${PWD}:/data -w /data anagrammarian/sthomas hipsthomas.sh -v -i CAM003_WMn.nii.gz
```


### or Running with the Support Scripts

[As mentioned above](#get-the-support-files-optional), this support repository provides several "wrapper" scripts which can be used to process one (or more) structural images. For example, given an input image 'T1.nii.gz', in the current working directory, processing can be initiated by using the relevant T1 script from this support repository:
```
/path/to/thomas_t1.sh T1.nii.gz
```

For WMn (FGATIR, if you will) images, THOMAS processing works better, due to the better intra-thalamic contrast. In the following example, the white matter nulled MPRAGE file (WMN.nii.gz) in the current directory, is processed using the relevant WMn script from this support repository:
```
/path/to/thomas_wmn.sh WMn.nii.gz
```

### or Running with Apptainer (nee Singularity):

Linux users who use Apptainer instead of Docker (e.g., HPC users) can pull the HIP-THOMAS Docker container directly from DockerHub and build an Apptainer (.sif) container from it.

>[!TIP]
Users who have sufficient permissions on their machine can install Apptainer using the instructions found here https://apptainer.org/docs/admin/main/installation.html.

#### Building the Apptainer Container

**Please be patient** when building the container, as Apptainer must download and convert the entire HIPS-THOMAS Docker container.
```
apptainer build sthomas.sif docker://anagrammarian/sthomas
```

#### Using Apptainer at the Command Line
>[!NOTE]
>The container (`sthomas.sif`) can be saved and run from any convenient directory and, therefore, must be explicitly specified in the Apptainer command. For example, if you save the container in your home bin directory (~/bin), you would specify the path to it as `~/bin/sthomas.sif`. (In the examples below, the path is specified as `/path/to/sthomas.sif`)

Once you have built the Apptainer container, you can start the container from the command line. For example, to process a T1 image (CAM003.nii.gz) in the current directory:
```
apptainer exec --cleanenv --bind ${PWD}:/data /path/to/sthomas.sif /thomas/src/hipsthomas.sh -t1 -i CAM003.nii.gz
```
To process a WMn image (subj3_WMn.nii.gz) in the current directory:
```
apptainer exec --cleanenv --bind ${PWD}:/data /path/to/sthomas.sif /thomas/src/hipsthomas.sh -i subj3_WMn.nii.gz
```

#### Using Apptainer via Support Scripts

Once you have built the Apptainer container, you can use an appropriate support script from this repository. For example, to run on a T1 image, in the current directory, run the T1 script:
```
/path/to/thomas_t1_apptainer.sh /path/to/sthomas.sif subj2_T1.nii.gz
```

For a WMn/FGATIR image, in the current directory, run the WMn script:
```
/path/to/thomas_wmn_apptainer.sh /path/to/sthomas.sif subj2_WMn.nii.gz
```

### Additional Arguments (for Advanced User Scenarios)

Several additional, optional arguments for the program are available to users to modify the scripts or to use on the command line:

```
Optional Arguments:

[-xf fixedImageMask] [-xm movingImageMask] [-co] [-d] [-dm] [-oldt1] [-sc] [-um] [-v]

where:
    -co = crop only.
    -d  = turn on Debugging mode (forces serial processing, retains temp directories).
    -dm = use the denoise mask.
    -oldt1 = process a T1 image but don't do HIPS white matter null synthesis. Uses majority voting.
             WARNING: use this flag OR the -t1 flag, not both.
    -sc = Use smaller crop.
          WARNING: this will not produce reliable results for non-Thalamic structures.
    -um = use mask.
    -v = run in Verbose mode (included in the wrapper scripts by default).
    -xf fixedImageMask
    -xm movingImageMask
```

## Outputs
The directories named **left** and **right** contain the outputs, which include:
- The individual full-sized label files for each nucleus (e.g. 2-AV.nii.gz for Anteroventral and so on)
- **thomas_L.nii.gz** (or **thomas_R.nii.gz**): a single file with all nucleus labels, cropped to the region of interest.
- **thomasfull_L.nii.gz** (or **thomasfull_R.nii.gz**): which is the same size as the input file (i.e. full size as opposed to the **thomas_{L/R}.nii.gz** files which are cropped).
- **nucleiVols.txt**: contains the nuclei volume statistics for joint label fusion labels
- **regn.nii.gz**: is the custom template registered to the input image. This file is critical for debugging and is shown in the lower panel of the quality control image. Make sure this file and **crop_**\<inputfilename\> are well aligned. Note that this is separate for left and right sides.
- **EXTRAS**: Additional processing files are saved in both the `left` and `right` subdirectories.
- **EXTRAS/MV**: Directory containing the ROIs processed using Majority Voting algorithm and  **nucleiVolsMV.txt** volumes from majority voting labels

### List of Output ROIs
| Region | Label | Region of Interest |
| :------|:------|:-------------------|
| Thalamus | 1-THALAMUS | Thalamus (whole) |
| Thalamus | 2-AV | Antero-Ventral Nucleus |
| Thalamus | 4-VA | Ventral Anterior Nucleus |
| Thalamus | 5-VLa | Ventral Lateral Nucleus (anterior) |
| Thalamus | 6-VLP | Ventral Lateral Nucleus (posterior) |
| Thalamus | 7-VPL | Ventral Posterior Lateral |
| Thalamus | 4567-VL | Ventral Lateral |
| Thalamus | 8-Pul | Pulvinar |
| Thalamus | 9-LGN | Lateral Geniculate Nucleus |
| Thalamus | 10-MGN | Medial Geniculate Nucleus |
| Thalamus | 11-CM | Centromedian Nucleus |
| Thalamus | 12-MD-Pf | Mediodorsal Nucleus |
| Thalamus | CL | Central Lateral Nucleus |
| Other | 13-Hb | Habanula |
| Other | 14-MTT | Mammillothalamic Tract |
| Other | 28-Cla | Claustrum |
| Other | 32-RN | Red Nucleus |
| Other | 34-Amy | Amygdala |
| Basal Ganglia | 26-Acc | Nucleus Accumbens |
| Basal Ganglia | 27-Cau | Caudate |
| Basal Ganglia | 29-GPe | Globus Pallidus External |
| Basal Ganglia | 30-GPi | Globus Pallidus Internal |
| Basal Ganglia | 31-Put | Putamen |
| Basal Ganglia | 33-GP | Globus Pallidus (GPe+GPi) |

>[!NOTE]
Note that the label numbers in the `thomas_L`, `thomas_R`, `thomasfull_L`, and `thomasfull_R` correspond to these labels (e.g., Pulvinar is 8, Claustrum is 28 and so on) and the label numbers are the same for the left and right sides. However, the `sthomas_LR_labels.nii.gz` file follows a very different numbering scheme (no gaps in numbers, left and right have different label numbers, etc). We will upload a LUT file in the near future.

## Citation
The HIPS-THOMAS paper published in *Brain Structure and Function* can be found here: https://pubmed.ncbi.nlm.nih.gov/38546872/

 The *medRxiv* preprint can be found at https://www.medrxiv.org/content/10.1101/2024.01.30.24301606v1

	Vidal JP, Danet L, Péran P, Pariente J, Bach Cuadra M, Zahr NM, Barbeau EJ, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI using polynomial intensity transformation. Brain Structure and Function; 229(5):1087-1101 (2024)

The original *Neuroimage* paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Thalamus Optimized Multi-atlas Segmentation (THOMAS): fast, fully automated segmentation of thalamic nuclei from anatomical MRI. NeuroImage; 194:272-282 (2019)


## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu if you have any questions or difficulties in installing or using THOMAS, or to report bugs or issues.

## Contributors
Thomas Hicks and Dianne Patterson (University of Arizona, Tucson) - design discussions and software engineering.

Thomas Tourdias (Bordeaux University Hospital) and Alberto Cacciola (University of Messina)- manual labeling of thalamic nuclei and deep grey nuclei.

Julie Vidal (CNRS Toulouse) and Manoj Saranathan (UMass Chan Medical School, Worcester)- design, basic implementation, algorithms.

Brian Rutt and Jason Su (Stanford University)- original WMn THOMAS implementation.


## License

>[!WARNING]
>This Software is provided "AS IS" and neither University of Arizona (UofAZ) nor any contributor to the software (each a "Contributor") shall have any obligation to provide maintenance, support, updates, enhancements or modifications thereto. UofAZ AND ALL CONTRIBUTORS SPECIFICALLY DISCLAIM ALL EXPRESS AND IMPLIED WARRANTIES OF ANY KIND INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL UofAZ OR ANY CONTRIBUTOR BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY ARISING IN ANY WAY RELATED TO THE SOFTWARE, EVEN IF UofAZ OR ANY CONTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. TO THE MAXIMUM EXTENT NOT PROHIBITED BY LAW OR REGULATION, YOU FURTHER ASSUME ALL LIABILITY FOR YOUR USE, REPRODUCTION, MAKING OF DERIVATIVE WORKS, DISPLAY, LICENSE OR DISTRIBUTION OF THE SOFTWARE AND AGREE TO INDEMNIFY AND HOLD HARMLESS UofAZ AND ALL CONTRIBUTORS FROM AND AGAINST ANY AND ALL CLAIMS, SUITS, ACTIONS, DEMANDS AND JUDGMENTS ARISING THEREFROM.

© Copyright Manoj Saranathan, Julie Vidal 2023 2024 2025. All rights reserved.
