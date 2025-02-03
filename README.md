# HIPS-THOMAS docker version 
This is a docker container for HIPS-THOMAS, a new modified pipeline for accurate segmentation of T1w (SPGR,MPRAGE) data based on THOMAS. Note that HIPS-THOMAS performs much better than THOMAS for T1w data as it synthesizes WMn-like images from T1 prior to running THOMAS. The WMn-MPRAGE segmentation is unchanged and this container can be used on both T1w and WMn data by choosing the right wrapper script. 

**Update** 12/26/2023- a new container was uploaded to dockerhub ~ Dec 11 2023 which fixes some cropping errors for low quality T1 images. Please erase and redownload the docker image to avail of this enhancement. This is critical for analysis of ADNI HCP etc.

The HIPS-THOMAS workflow is shown below:-

![HIPS-THOMAS workflow](https://github.com/thalamicseg/hipsthomasdocker/blob/main/hipsthomas.JPG)


## Installation instructions (see key notes below for MAC and for SINGULARITY)
- Make sure docker is installed already on your machine or install it from here https://docs.docker.com/get-docker/.  

- Download the HIPS-THOMAS container from dockerhub ```docker pull anagrammarian/thomasmerged```

- When the long 41Gb download finishes, type ```docker images``` to check if anagrammarian/thomasmerged is listed. You are good to go. 

- To get the example files, colortables, wrapper scripts etc, download the HIPS-THOMAS files using ```git clone https://github.com/thalamicseg/hipsthomasdocker.git``` which will create a **hipsthomasdocker** directory

- Copy the wrapper scripts thomaswmn and thomast1_hips to ~/bin and do a ```chmod +x thomas*``` to make the scripts executable prior to running
- If you already have a thomas docker container and want to install a patch (300MB vs 41GB so much faster), see the 1.0 branch of hipsthomasdocker but is not recommended as that branch will not be maintained
- **MAC USERS TAKE NOTE** Apple Silicon is not compatible with a lot of docker containers. So follow these steps-
  
	-Install Docker Desktop for Apple Silicon (make sure the space allocated for docker is 80GB or so as the container is 41GB)
	
	-Enable Rosetta in the operating system
	
	-Enable Rosetta in Docker Desktop
	
	-Enabling Rosetta in Docker Desktop requires OS 13 Ventura or greater

This will significantly reduce the run time (which in some cases does not finish). Intel chip based Macs should work fine but this needs to be validated more thoroughly. We have anecodal evidence of no issues with Macs with Intel based processors.  Thanks to **Dianne Patterson** for investigating and finding this fix.

## SINGULARITY
- You can directly pull from dockerhub and save as an sif file
- First install apptainer from here https://apptainer.org/docs/user/main/quick_start.html
- Then run  ```singularity pull thomas.sif docker://anagrammarian/thomasmerged```
- You can store the thomas.sif in your favourite location say /home/username/bin along with your scripts. Note that this path has to be specified while using the singualrity (see usage below Docker usage)

##  Docker usage
- To use the provided example files, copy example.tgz from hipsthomasdocker to ~/testdata and run ```tar -xvzf example.tgz``` inside ~/testdata
- To run HIPS-THOMAS, **each anatomical T1 or WMn MPRAGE file should be in a separate directory**. You can launch the container from the command line by running the following command inside the directory containing the T1.nii.gz file:
 ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t anagrammarian/thomasmerged bash -c "hipsthomas_csh -i T1.nii.gz -t1 -big" ```. Change the T1.nii.gz to your desired filename. 
- For WMn/FGATIR files, use the following command: ```docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t anagrammarian/thomasmerged bash -c "hipsthomas_csh -i WMn.nii.gz" ```.
- You can also use the two wrapper bash scripts thomaswmn.txt and thomast1_hips.txt (see last 2 steps of Install)
- Note that you cannot use thomast1_hips.txt for WMn/FGATIR or thomaswmn for T1.
- Note also the -t1 and -big arguments for **T1 alone**. THe -big helps with patients with large ventricles (older population). The -t1 triggers the HIPS WMn synthesis.

## Singularity usage
- You need to tweak the calls slightly from docker usage above but briefly for T1 run the following:
- Change the /path/to to path you have stored your thomas.sif file e.g. /home/username/bin
- For T1,  ```singularity run -B ${PWD}:${PWD} -W ${PWD} -u --cleanenv /path/to/thomas.sif bash -c "hipsthomas_csh -i T1.nii.gz -t1 -big" ```
- For WMn/FGATIR,  ```singularity run -B ${PWD}:${PWD} -W ${PWD} -u --cleanenv /path/to/thomas.sif bash -c "hipsthomas_csh -i WMn.nii.gz" ```
- I will upload wrappers shortly (Dec 13 2023)

## Common issues
- The first cropping step of THOMAS occasionally fails in older patients due to presence of neck tissue. If you are seeing failures (abormally small or large values of 1-THALAMUS typically 3000-6000 is normal, anything outside is suspect, any 0s in nuclei typically 2-AV or 9-LGN or 10-MGN are also indicative of crop failures albeit more subtle asymmetric crop than complete failure) view crop_T1.nii.gz from left and the central slice should have both thalami.
  
- In case of a crop failure, try running ```bet``` and then run thomas on brain extracted data. The bet command we recommend is ```bet input output -B -R``` where input is your T1 image. Note that ```bet``` is available inside the docker container which can be entered using ```docker run -v ${PWD}:${PWD} -w ${PWD} --rm -it thomasmerged``` and you can simply run bet here on a case by case basis or write a batch script. This is useful if bet is not installed locally

- Caveat re the above step: Cropping step sometimes fails for skull stripped data. I am working on a fix for this (need to upload) but for now DO NOT supply skull stripped data to THOMAS

- 7T MP2RAGE ratio normalized images is scaled from -0.5 to 0.5 sometimes. In that case, scale it up to a big integer before using THOMAS. You can scale this using ```fslmaths T1.nii.gz -mul -16384 T1s.nii.gz``` for example.
- Occasionally, the name of the input file can cause some issues, if it starts with a **number**. Avoid using numbers as starting for your filenames
- Denoising can help if very noisy. We recommend ```DenoiseImage 3 -i input -o output -n Rician``` of ANTs also accessible within the container (see point 2 for bet above for access)
- Wrapper scripts need to have exec permissions or won't run. Do a ```chmod +x thomas*``` on those before running
- Make sure ~/bin is in your PATH or call the wrappers explicitly like ~/bin/thomast1_hips 
- Docker needs ~90Gb free space to install properly via building. Make sure the partitions have enough free space
- thomas has to be run in the directory where the T1 or WMn file is located and cannot accept path arguments in filename. This will be fixed in future versions D.V.


## Outputs
The directories named **left** and **right** contain the outputs which are individual nuclei labels (e.g. 2-AV.nii.gz for anteroventral and so on), nonlinear warp files, and also the following files:
- **thomas.nii.gz** is all labels fused into one file (same size as the cropped anatomical file)
- **thomasfull.nii.gz** is also fused labels but same size as the input file (i.e. full size as opposed to cropped)
- **nucleiVols.txt** contains the nuclei volumes in mm^3 
- **regn.nii.gz** is the custom template registered to the input image. This file is critical for debugging. Make sure this file and cropped input file are well aligned. For the right side, do this comparison for crop_<input file> and regn.nii.gz inside the tempr directory as there is a flip operation performed for the right.
- For right side, the labels are called **thomasr.nii.gz** and **thomasrfull.nii.gz**
- **temp** and **tempr** directories contain intermediate step files which sometimes can help debugging esp for right side registration but can be safely deleted to save space
- A reminder that outputs will be overwritten if run again in the same directory. So if you want to process multiple files, put them in separate directories and run a simple shell script to loop through all the folders. 
- The nuclei are all cropped but can be uncropped using uncrop.py found here https://github.com/thalamicseg/thomas_new/blob/master/uncrop.py You will need the crop mask mask_inp.nii.gz which you will find in left and right folders for each side. Or you can extract the individual full labels from the thomasfull.nii.gz using mri_extract_label of Freesurfer like here https://surfer.nmr.mgh.harvard.edu/fswiki/mri_extract_label 

## Thalamic nuclei expansions and label definitions
THOMAS outputs the mammillothalamic tract (14-MTT) and the eleven delineated nuclei grouped as follows (Note that 6-VLP is further split into 6_VLPv and 6_VLPd. 6_VLPv is roughly concordant with VIM used for targeting in DBS applications although differences seem to exist between Morel and Schaltenbrand atlases)-

	(a) medial group: habenula (13-Hb), mediodorsal (12-MD), centromedian (11-CM) 
	(b) posterior group: medial geniculate nucleus (10-MGN), lateral geniculate nucleus (9-LGN),  pulvinar (8-Pul),
	(c) lateral group: ventral posterolateral (7-VPL), ventral lateral posterior (6-VLp), ventral lateral anterior (5-VLa), ventral anterior nucleus (4-VA)
	(d) anterior group: anteroventral (2-AV)
A colortable file (CustomAtlas.ctbl) for 3D Slicer and an FSL compatible lookup table (Thomas.lut) is also provided. When you use these, Slicer or fsleyes will label appropriately.

## Future enhancements (watch this space, coming soon !)
- Batch script which runs on all folders/files and creates a volume CSV file for left and right hemispheres
- Quality control ![qc-example](https://github.com/thalamicseg/hipsthomasdocker/blob/main/qcexample.png)


## Citation

HIPS-THOMAS is in press in Brain Structure and Function. The medRxiv preprint can be found here [https://www.medrxiv.org/content/10.1101/2024.01.30.24301606v1]

	Vidal JP, Danet L, Péran P, Pariente J, Bach Cuadra M, Zahr NM, Barbeau EJ, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI using polynomial intensity transformation. *Brain Structure and Function*; 2024 

The original Neuroimage paper on THOMAS can be found here https://pubmed.ncbi.nlm.nih.gov/30894331/

	Su J, Thomas FT, Kasoff WS, Tourdias T, Choi EY, Rutt BK, Saranathan M. Robust thalamic nuclei segmentation from T1-weighted MRI. *NeuroImage*; 194:272-282 (2019)



## Contact
Please contact Manoj Saranathan manojkumar.saranathan@umassmed.edu in case you have any questions or difficulties in installation/running or to report bugs/issues. 

© Copyright Julie Vidal Manoj Saranathan 2023


