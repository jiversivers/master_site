#!/bin/bash

{ # try
  cd master-site
} || { # except
  git clone --branch production --depth 1 --single-branch https://www.github.com/jiversivers/master-site.git
  cd master-site
}

# Install conda if not already
command -v conda > /dev/null 2>&1
if [$? -ne 0]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
  bash Miniconda3-latest-Linux-x86_64.sh
fi

# Install nginx if not
command -v nginx > /dev/null 2>&1
if [$? -ne 0]; then
  sudo apt install nginx -y
fi
sudo systemctl start nginx
sudo systemctl enable nginx

# Install to read yaml
sudo apt install yq

# Get linux up-to-date
sudo apt update && sudo apt upgrade -y

# Delete environment if exists
ENV_NAME=$(yq -r .name environment.yml)
conda env list | grep "$ENV_NAME" >/dev/null 2>&1
if [$? -ne 0]
  conda remove -n "$ENV_NAME" --all
fi

# Create fresh environment
conda env create -f environment.yml
conda activate your_env_name
conda install gunicorn  # In case its never installed on dev machine environment
pip install -r requirements.txt
pip install strivers/strava_swagger   # In case reqs file fails to point to it correctly

# Prep django
python manage.py migrate
pyhton manage.py collectstatic