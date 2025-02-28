#!/bin/bash

source .env

# Create production .env
bash scripts/create_production_env.sh

# Update reqs and push
bash scripts/export_reqs.sh

# Push to github
git push

echo "Production .env file created. Copying to $EC2_DNS"
scp -i ~/jivers.pem .env.production ubuntu@"$EC2_DNS":~/master-site/.env

echo "Running production_setup.sh on $EC2_DNS"

ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" 'chmod +x production_setup.sh' # Ensure production_setup is executable
ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" 'bash -s' < production_setup.sh # Run production_setup on EC2 instance

# Copy non-cloned files into the project
ssh -i ~jivers.pem ubuntu@"$EC2_DNS" < 'mv .env.production .env'

# Copy each file to remote
echo ""
echo "Copying to $EC2_DNS:22"
echo "${files[*]}"
echo "Update files in .env to add or remove."
ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" < 'mkdir -p master-site'
for file in "${files[@]}"
do
  echo "copying $file to $EC2_DNS..."
  scp -i ~/jivers.pem "$file" ubuntu@"$EC2_DNS":~/master-site
done