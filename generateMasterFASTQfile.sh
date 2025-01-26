#!/bin/bash 

# Check if an argument is provided 
if [ -z "$1" ]; then 
    echo "Usage: $0 needs to be given a <parent_dir>" 
    exit 1 
fi

if [ -z "$2" ]; then 
    echo "Usage: $0 needs to be given a <master_filenmae>" 
    exit 1 
fi

# Parent directory (change this to your folder path) 
PARENT_DIR="$1"
MASTER_FASTQ="$2"
touch "$MASTER_FASTQ.fastq"
chmod +w "$MASTER_FASTQ.fastq"
# Loop through each subfolder in the parent directory 
for SUBFOLDER in "$PARENT_DIR"/*/; do 
    # Check if it is a directory 
    if [ -d "$SUBFOLDER" ]; then 
        echo "Processing folder: $SUBFOLDER"
        for ITEM in "$SUBFOLDER"*.fastq; do
            echo "adding: $ITEM"
            cat "$ITEM" >> "$MASTER_FASTQ.fastq"
        done
    fi
done