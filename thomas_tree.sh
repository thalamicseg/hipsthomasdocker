#!/bin/bash
# Wrapper for running HIPS THOMAS in docker container for a filetree of T1 MPRAGE/SPGR or WMn MPRAGE/FGATIR files.
#
DK_IMG=anagrammarian/sthomas

function Usage () {
  echo ""
  echo "Usage: $0 root_dir T1|WMn [--overwrite]"
  echo ""
  echo "where: root_dir = Root directory of filetree containing the input images to be processed."
  echo "       image_type = T1 or WMn (for MPRAGE/SPGR NIfTI or WMn MPRAGE/FGATIR, respectively)"
  echo "                    NOTE: All image files in the filetree must be of the same image type."
  echo "      --overwrite = Optional flag to force overwriting of any previous THOMAS results."
  echo "                    WARNING: this will DELETE any previous THOMAS result directories in the filetree!"
  echo ""
}

function get_abs_path () {
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

if [ $# -lt 1 ]; then
  Usage
  exit 1
fi

RD=$(get_abs_path "$1")
if [ -n "$RD" -a -d "$RD" -a -r "$RD" -a -w "$RD" -a -x "$RD" ]; then
  ROOT_DIR=$RD
else
  echo "ERROR: the required root directory must exist and have read, write, and execute permissions."
  Usage
  exit 1
fi

if [ "$2" == "t1" -o "$2" == "T1" -o "$2" == "wmn" -o "$2" == "WMn" ]; then
  IMAGE_TYPE=$2
else
  echo "ERROR: the required image type must be one of t1, T1, wmn, or WMn."
  Usage
  exit 2
fi

OVERWRITE=
if [ "$3" == "--overwrite" -o "$3" == "-overwrite" ]; then
  OVERWRITE=$3
fi

OSNAME=$(uname -s)
if [ "$OSNAME" == "Linux" ]; then
  GID=$(id -g)
  USER_IDS="--user ${UID}:${GID}"
fi

cd $ROOT_DIR
echo "Running container ${DK_IMG} on images in directory ${ROOT_DIR}..."
time docker run -it --rm --name thomast -v ${ROOT_DIR}:/data -w /data ${USER_IDS} ${DK_IMG} thomas_tree.py -v ${IMAGE_TYPE} ${OVERWRITE}
