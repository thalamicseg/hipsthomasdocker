# HIPS-THOMAS docker version
This is a docker container for HIPS-THOMAS, a modified pipeline for accurate segmentation of T1w (SPGR,MPRAGE) data based on THOMAS. Note that HIPS-THOMAS performs much better than THOMAS for T1w data as it synthesizes WMn-like images from T1 prior to running THOMAS. The WMn-MPRAGE segmentation is unchanged and this container can be used on both T1w and WMn data by choosing the right wrapper script. The HIPS-THOMAS workflow is shown below:-

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/main/hipsthomas.JPG)


## Installation instructions (for users who have **NOT** installed thomas docker container previously)
- Make sure docker is installed already on your machine or install it from here https://docs.docker.com/get-docker/.  

- Download the HIPS-THOMAS container from dockerhub ```docker pull anagrammarian/thomasmerged```

- When the long 40Gb download finishes, type ```docker images``` to check if anagrammarian/thomasmerged is listed. You are good to go. 

##  Usage
- To run HIPS-THOMAS, **each anatomical T1 or WMn MPRAGE file should be in a separate directory**. You can launch the container from the command line by running the following command inside the directory containing the T1.nii.gz file:
 ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t anagrammarian/thomasmerged bash -c "hipsthomas_csh -i T1.nii.gz -t1" ```. Change the T1.nii.gz to your desired filename. 
- For WMn/FGATIR, use the following command: ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t anagrammarian/thomasmerged bash -c "hipsthomas_csh -i WMn.nii.gz" ```.
- Two wrapper bash scripts thomaswmn and thomast1_hips are also supplied. You can put them in ~/bin (and add ~/bin to your path to easily access it from anywhere or call ~/bin/thomaswmn or ~/bin/thomast1_hips ). Make sure the name of the container is anagrammarian/thomasmerged in the 2 scripts before running


## Installation instructions (for users who have installed the older thomas docker container)

- If you have already built a THOMAS container or downloaded it from dockerhub, then the following steps will save you a lot of time as you are downloading 200Mb vs. 40Gb ! 

- Download the HIPS-THOMAS files using ```git clone https://github.com/thalamicseg/hipsthomasdocker.git``` which will create a **hipsthomasdocker** directory

- Note: if you had previously built the THOMAS docker directly from a Dockerfile instead of downloading from dockerhub, use thomas instead of anagrammarian/thomas in the Dockerfile line which says FROM. If you are unsure, run ``docker images`` to see if it says thomas or anagrammarian/thomas

- Run the following command inside the hipsthomasdocker directory to combine the pieces of a large template file (github only allows 25Mb) ```cat origtemplate_mni.nii.gz.parta* > origtemplate_mni.nii.gz```

- Run ```docker build -t thomasmerged .``` inside the hipsthomasdocker directory to create a new container named thomasmerged. Note the period at the end of the command which is critical.

- When the build finishes in a few seconds, type ```docker images``` to see thomasmerged listed as a repository. If you see it, you are good to go !
  
## Usage
- To run THOMAS, **each anatomical T1 or WMn MPRAGE file should be in a separate directory**. You can launch the container from the command line by running the following command inside the directory containing the T1.nii.gz file:
 ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t thomasmerged bash -c "hipsthomas_csh -i T1.nii.gz -t1" ```. Change the T1.nii.gz to your desired filename. 
- For WMn/FGATIR, use the following command: ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t thomasmerged bash -c "hipsthomas_csh -i WMn.nii.gz" ```.
-  Two wrapper bash scripts thomaswmn and thomast1_hips are also supplied. You can put them in ~/bin (and add ~/bin to your path to easily access it from anywhere or call ~/bin/thomaswmn or ~/bin/thomast1_hips )

## Running the provided test data 
-  First extract the test data by running ```tar -xvzf example.tgz``` inside a clean test directory
-  If using wrapper scripts, move thomaswmn and thomast1_hips from inside thomasdocker to ~/bin
-  For the WMn MPRAGE data, you can run ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t thomasmerged bash -c "hipsthomas_csh -i WMn.nii.gz" ```  or ```~/bin/thomaswmn WMn.nii.gz``` 
-  For the T1 MPRAGE data, you can run ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t thomasmerged bash -c "hipsthomas_csh -i T1.nii.gz -t1" ``` or ```~/bin/thomast1_hips T1.nii.gz```
-  Note: you need to create separate subdirectories ideally outside thomasdocker to run WMn and T1 test data or they will get overwritten
-  If you downloaded HIPS-THOMAS from dockerhub, then change thomasmerged to anagrammarian/thomasmerged

## Outputs
The directories named **left** and **right** contain the outputs which are individual nuclei labels (e.g. 2-AV.nii.gz for anteroventral and so on), nonlinear warp files, and also the following files:
- **thomas.nii.gz** is all labels fused into one file (same size as the cropped anatomical file)
- **thomasfull.nii.gz** is also fused labels but same size as the input file (i.e. full size as opposed to cropped)
- **nucVols.txt** contains the nuclei volumes in mm^3 
- **regn.nii.gz** is the custom template registered to the input image. This file is critical for debugging. Make sure this file and cropped input file are well aligned. For the right side, do this comparison for crop_<input file> and regn.nii.gz inside the tempr directory as there is a flip operation performed for the right.
- For right side, the labels are called **thomasr.nii.gz** and **thomasrfull.nii.gz**
- **temp** and **tempr** directories contain intermediate step files which sometimes can help debugging esp for right side registration
- A reminder that outputs will be overwritten if run again in the same directory. So if you want to process multiple files, put them in separate directories and run a simple shell script to loop through all the folders. 

## Thalamic nuclei expansions and label definitions
THOMAS outputs the mammillothalamic tract (14-MTT) and the eleven delineated nuclei grouped as follows (Note that 6-VLP is further split into 6_VLPv and 6_VLPd. 6_VLPv is roughly concordant with VIM used for targeting in DBS applications although differences seem to exist between Morel and Schaltenbrand atlases)-

	(a) medial group: habenula (13-Hb), mediodorsal (12-MD), centromedian (11-CM) 
	(b) posterior group: medial geniculate nucleus (10-MGN), lateral geniculate nucleus (9-LGN),  pulvinar (8-Pul),
	(c) lateral group: ventral posterolateral (7-VPL), ventral lateral posterior (6-VLp), ventral lateral anterior (5-VLa), ventral anterior nucleus (4-VA)
	(d) anterior group: anteroventral (2-AV)


## Citation
The original Neuroimage paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Thalamus Optimized Multi-atlas Segmentation (THOMAS):
	fast, fully automated segmentation of thalamic nuclei from anatomical MRI. _NeuroImage_; 194:272-282 (2019)

HIPS-THOMAS is under review in Scientific Methods and the citation will be available once it is accepted.


## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu in case you have any questions or difficulties in installation/running or to report bugs/issues. 

© Copyright Julie Vidal Manoj Saranathan 2023

