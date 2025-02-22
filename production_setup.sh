#!/bin/bash

# Get into upto-date master site (cloning it first if necessary)
{ # try
  cd master-site
  git pull
} || { # except
  git clone --branch main --depth 1 --single-branch https://www.github.com/jiversivers/master-site.git
  cd master-site
}

# Install conda if not already
command -v conda > /dev/null 2>&1
if [ $? -ne 0 ]; then
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
fi

# Install nginx if not
command -v nginx > /dev/null 2>&1
if [$? -ne 0]; then
  sudo apt install nginx -y
fi

# Run nginx
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

# Create fresh environment and activate
conda env create -f environment.yml
conda activate your_env_name

# Install gunicorn
conda install gunicorn  # In case it wasn't installed on dev machine and thus not in reqs
gunicorn --workers 3 master-site.wsgi:application

# Install pip reqs
pip install -r requirements.txt
pip install strivers/strava_swagger   # In case reqs file fails to point to it correctly

# Prep django
python manage.py migrate
pyhton manage.py collectstatic

sudo certbot --nginx -d jivers.me -d www.jivers.me
sudo systemctl restart gunicorn
sudo systemctl restart nginx