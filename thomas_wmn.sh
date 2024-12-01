#!/bin/bash
# Wrapper for running HIPS THOMAS in docker container for WMn MPRAGE or FGATIR files.
#
DK_IMG=anagrammarian/sthomas

if [ $# -lt 1 ]; then
  echo "Usage: $0 WMn-input-image"
  echo "where: WMn-input-image = an WMn MPRAGE or FGATIR NIfTI file in the current directory"
  echo "       (for T1 MPRAGE/SPGR files, please use thomas_t1.sh)"
  exit 1
fi

INPUT_IMAGE=${1}

OSNAME=$(uname -s)
if [ "$OSNAME" == "Linux" ]; then
  GID=$(id -g)
  USER_IDS="--user ${UID}:${GID}"
fi

echo "Running container ${DK_IMG} on ${INPUT_IMAGE}..."
time docker run -it --rm --name sthomas -v ${PWD}:/data -w /data ${USER_IDS} ${DK_IMG} hipsthomas.sh -v -i ${INPUT_IMAGE} "${@:2}"
