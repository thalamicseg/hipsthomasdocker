#!/bin/sh
#
# Run the sthomas container to print the version number and exit.
#
DK_IMG=anagrammarian/sthomas

docker run -it --platform linux/amd64 --rm ${DK_IMG} hipsthomas.sh --version
