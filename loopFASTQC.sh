#!/bin/bash 

# Check if an argument is provided 
if [ -z "$1" ]; then 
    echo "Usage: $0 needs to be given a <parent_dir>" 
    exit 1 
fi

# Set heap size
export JAVA_OPTS="-Xmx32G"

# Parent directory (change this to your folder path) 
PARENT_DIR="$1"
# Loop through each subfolder in the parent directory 
for ITEM in "$PARENT_DIR"/*.fastq; do 
    echo "Running fastqc on: $ITEM"
    # Run fastqc on fastq file
    fastqc "$ITEM"
done