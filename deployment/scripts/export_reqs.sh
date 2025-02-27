#!/bin/bash

echo "Updating package requirements..."

# Prep requirements and push current hash
conda env export --name jiversivers_env > environment.yml # export environment for easy re-creation on EC2
pip list --format=freeze > requirments.txt  # capture pip reqs in the case that they are not properly handled by conda