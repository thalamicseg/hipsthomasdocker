#!/bin/bash
# Wrapper for running HIPS THOMAS with Apptainer container for WMn MPRAGE or FGATIR files.
#
function Usage () {
  echo "Usage: $0 /path/to/sthomas.sif WMn-input-image"
  echo "where:"
  echo "   /path/to/sthomas.sif = full path to location of HIPS-THOMAS .sif file"
  echo "   WMn-input-image = an WMn MPRAGE or FGATIR NIfTI file in the current directory"
  echo "   (for T1 MPRAGE/SPGR files, please use thomas_t1_apptainer.sh)"
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
  echo "ERROR: Unable to find the WMn input image at specified location: '$INPUT_IMAGE'"
  Usage
  echo
  exit 3
fi

echo "Running container ${STHOMAS_SIF} on ${INPUT_IMAGE}..."
time apptainer exec --cleanenv --bind ${PWD}:/data ${STHOMAS_SIF} /thomas/src/hipsthomas.sh -i ${INPUT_IMAGE}