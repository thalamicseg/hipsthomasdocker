#!/bin/bash

# Check if the directory and t1/wmn choice is provided

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <Base directory> <t1|wmn>"
    exit 1
fi

#Assign input arguments to variables
BASEDIR="$1"
CTYPE="$2"

# Function to process .nii and .nii.gz files
process_files() {
    local dir="$1"
#    echo "Processing directory: $dir"

    # Find and process .nii and .nii.gz files
    for file in "$dir"/*.nii "$dir"/*.nii.gz; do
        # Check if the file exists (to handle empty directories)
        if [ -e "$file" ]; then
            # Get the relative path to the file
            relative_path="${file#./}"           # Remove the leading './' if present
            fileb=`basename $relative_path`
            
            # Change to the directory and execute the user command
#            (cd "$dir" && eval "$USER_COMMAND \"$relative_path\"")
            cd $dir
            if [ "$CTYPE" == "t1" ] || [ "$CTYPE" == "T1" ]; then 
                echo "Running thomast1 in ${dir#./} on $fileb"
            else
                echo "Running thomaswmn in ${dir#./} on $fileb"
            fi
        fi
    done
}

CPWD=$PWD

# Change to the specified directory
cd "$BASEDIR" || { echo "Directory not found."; exit 1; }

# Check if local nii or nii.gz files found

NIC=$(find . -maxdepth 1 -type f -name "*.nii" | wc -l)
NIZC=$(find . -maxdepth 1  -type f -name "*.nii.gz" | wc -l)
echo "$NIC nii files, $NIZC nii.gz found locally"

# Loop through all .nii and .nii.gz files in the directory
for file in *.nii.gz *.nii; do
    # Check if there are no matching files
    if [ ! -e "$file" ]; then
         echo "No isolated files"
#        exit 1
    else 
        echo "nizc $NIZC"
        # If just 1 file, don't bother creating dirs
        if [ $NIZC -gt 1 ]; then
            # Remove the extension to get the basename
            basename="${file%%.*}"

            # Create a directory named after the basename
            mkdir -p "$basename"

            # Move the file into the created directory
            mv "$file" "$basename/"

            echo "Moved $file to $basename/"
        fi
    fi
done

# Export the function to be used in find command
export -f process_files
export CTYPE

# Use find to traverse directories and call the process_files function
find . -type d -exec bash -c 'process_files "$0"' {} \;

cd $CPWD
