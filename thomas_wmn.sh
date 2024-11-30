#!/bin/bash
#Wrapper for running docker THOMAS hipsthomas_csh script for WMN
if [ $# -lt 3 ]
then
echo "running thomasmerged docker on $1"
docker run -v ${PWD}:${PWD} -w ${PWD} --user $(id -u):$(id -g) --rm -t anagrammarian/thomasmerged bash -c "hipsthomas_csh -i $1"
else
	echo "Usage: thomaswmn WMnMPRAGE/FGATIR filename"
echo "please use thomast1_hips for T1MPRAGE/SPGR files"
fi
