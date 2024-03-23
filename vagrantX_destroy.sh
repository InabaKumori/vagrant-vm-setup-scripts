#!/bin/bash

# Check if a project name argument was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <vagrant_project_directory>"
    exit 1
fi

PROJECT_DIR=$1

# Check if the directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "The specified project directory does not exist: $PROJECT_DIR"
    exit 1
fi

# Navigate to the Vagrant project directory
cd "$PROJECT_DIR"

# Halt the VM (if running) and destroy all resources created by Vagrant
vagrant halt
vagrant destroy -f

# Navigate back to the parent directory
cd ..

# Remove the Vagrant project directory completely
rm -rf "$PROJECT_DIR"

# Optional: Clean up any Vagrant boxes that are no longer in use
vagrant box prune

echo "The VM and all related files in '$PROJECT_DIR' have been removed. Resources are now freed."
