#!/bin/bash
'''
Create Mikrotik routers backups and download them over scp
'''

# Define the array of items
items=("r1" "r2" "r11" "r12" "r13" "r14")

# Get the current date in YYMMDD format
current_date=$(date +%y%m%d)

# Loop through each item and execute the ssh/scp command
for item in "${items[@]}"; do

    echo "Backup ${item}..."
    cmd="${item} /export file=${item}-${current_date}.rsc"
    ssh ${cmd}

    echo "Copying from ${item}..."
    scp "${item}:${item}-${current_date}.rsc" ./
done

echo "All transfers completed!"