#!/bin/bash 

# Check if an argument is provided 
if [ -z "$1" ]; then 
    echo "Usage: $0 needs to be given a <parent_directory>" 
    exit 1 
fi

# Parent directory (change this to your folder path) 
PARENT_DIR="$1" 
# Loop through each subfolder in the parent directory 
for SUBFOLDER in "$PARENT_DIR"/*/; do 
    # Check if it is a directory 
    if [ -d "$SUBFOLDER" ]; then 
        echo "Processing folder: $SUBFOLDER"
        for ITEM in "$SUBFOLDER"*.fastq.gz; do
            echo "gunzipping: $ITEM"
            gunzip "$ITEM"
        done
    fi
done