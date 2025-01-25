#!/bin/bash
EC2=ubuntu@ec2-3-145-158-153.us-east-2.compute.amazonaws.com
conda env export --name jiversivers_env > environment.yml # export environment for easy re-creation on EC2
pip list --format=freeze > requirments.txt  # capture pip reqs in the case that they are not properly handled by conda
git push -m 'preproduction push'  # getting production onto git hub for easy access on EC2
scp -i ~/jivers.pem .env "$EC2":~/master-site #pushing .env to remote
ssh ~/jivers.pem "$EC2" 'bash -s' < production_setup.sh # Run production_setup on EC2 instance