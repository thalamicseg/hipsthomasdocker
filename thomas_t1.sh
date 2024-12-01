#!/bin/bash
# Wrapper for running HIPS THOMAS in docker container for T1 MPRAGE or SPGR files.
#
DK_IMG=anagrammarian/sthomas

if [ $# -lt 1 ]; then
  echo "Usage: $0 T1-input-image"
  echo "where: T1-input-image = an T1 MPRAGE or SPGR NIfTI file in the current directory"
  echo "       (for WMn MPRAGE/FGATIR files, please use thomas_wmn.sh)"
  exit 1
fi

INPUT_IMAGE=${1}

OSNAME=$(uname -s)
if [ "$OSNAME" == "Linux" ]; then
  GID=$(id -g)
  USER_IDS="--user ${UID}:${GID}"
fi

echo "Running container ${DK_IMG} on ${INPUT_IMAGE}..."
time docker run -it --rm --name sthomas -v ${PWD}:/data -w /data ${USER_IDS} ${DK_IMG} hipsthomas.sh -v -i ${INPUT_IMAGE} -t1 "${@:2}"
