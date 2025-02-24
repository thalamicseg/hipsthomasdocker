#!/bin/bash
# Wrapper for running HIPS THOMAS with Apptainer container for T1 MPRAGE or SPGR files.
#
function Usage () {
  echo "Usage: $0 /path/to/sthomas.sif T1-input-image"
  echo "where:"
  echo "   /path/to/sthomas.sif = full path to location of HIPS-THOMAS .sif file"
  echo "   T1-input-image = an T1 MPRAGE or SPGR NIfTI file in the current directory"
  echo "   (for WMn MPRAGE/FGATIR files, please use thomas_wmn_apptainer.sh)"
}

if [ $# -lt 2 ]; then
  Usage
  exit 1
fi

STHOMAS_SIF=${1}
INPUT_IMAGE=${2}

if [ ! -f "$STHOMAS_SIF" ]; then
  echo
  echo "ERROR: Unable to find the HIPS_THOMAS .sif file at specified location: '$STHOMAS_SIF'"
  Usage
  echo
  exit 2
fi

if [ ! -f "$INPUT_IMAGE" ]; then
  echo
  echo "ERROR: Unable to find the T1 input image at specified location: '$INPUT_IMAGE'"
  Usage
  echo
  exit 3
fi

echo "Running container ${STHOMAS_SIF} on ${INPUT_IMAGE}..."
time apptainer exec --cleanenv --bind ${PWD}:/data ${STHOMAS_SIF} /thomas/src/hipsthomas.sh -t1 -i ${INPUT_IMAGE}