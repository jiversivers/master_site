#!/bin/bash

source .env
echo ""
echo "Copying to $EC2:"
echo "${files[*]}"
echo "Update files in .env to add or remove."

# Prep requirements and push current hash
conda env export --name jiversivers_env > environment.yml # export environment for easy re-creation on EC2
pip list --format=freeze > requirments.txt  # capture pip reqs in the case that they are not properly handled by conda
git push -m 'preproduction push'  # getting production onto git hub for easy access on EC2

# Copy each file to remote
for file in "${files[@]}"
do
  scp -i ~/jivers.pem "$file" "$EC2":~/master-site #pushing .env to remote
done

echo "Running production_setup.sh on $EC2"
ssh ~/jivers.pem "$EC2" 'bash -s' < production_setup.sh # Run production_setup on EC2 instance