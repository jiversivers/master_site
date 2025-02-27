#!/bin/bash

source .env
echo ""
echo "Copying to $EC2_DNS:22"
echo "${files[*]}"
echo "Update files in .env to add or remove."

# Prep requirements and push current hash
conda env export --name jiversivers_env > environment.yml # export environment for easy re-creation on EC2
pip list --format=freeze > requirments.txt  # capture pip reqs in the case that they are not properly handled by conda
git push -m 'preproduction push'  # getting production onto git hub for easy access on EC2

# Create production .env
#!/bin/bash

# Define paths
MASTER_ENV_FILE=".env"
PROD_ENV_FILE=".env.production"

echo "Setting up production environment..."

# Extract all uncommented lines (common settings)
grep -v '^#' "$MASTER_ENV_FILE" > "$PROD_ENV_FILE"

# Extract uncommented production settings and append them
grep '^## Production settings' -A 1000 "$MASTER_ENV_FILE" | sed 's/^# //' >> "$PROD_ENV_FILE"

echo "Production .env file created. Copying to $EC2_DNS"
scp -i ~/jivers.pem .env.production ubuntu@"$EC2_DNS":~/master-site/.env

echo "Running production_setup.sh on $EC2_DNS"
ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" 'chmod +x production_setup.sh' # Ensure production_setup is executable
ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" 'bash -s' < production_setup.sh # Run production_setup on EC2 instance

# Copy non-cloned files into the project
ssh -i ~jivers.pem ubuntu@"$EC2_DNS" < 'mv .env.production .env'

# Copy each file to remote
ssh -i ~/jivers.pem ubuntu@"$EC2_DNS" < 'mkdir -p master-site'
for file in "${files[@]}"
do
  echo "copying $file to $EC2_DNS..."
  scp -i ~/jivers.pem "$file" ubuntu@"$EC2_DNS":~/master-site #pushing .env to remote
done