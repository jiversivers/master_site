# Deployment Guide
## Moving from a local dev machine to an AWS hosted EC2 with separate AWS RDS
## A Step-by-step guide

### Instantiate RDS


### Instantiate EC2
On AWS open an EC2 instance, making sure to create it in the same VPC as the RDS.
Copy the public DNS and set up an SSH connection into it.

### Create production settings
Determine which files are necessary on the EC2 to run project that are _not_ tracked by git. (Files tracked by git will be cloned in.)
Add a static and media root (if needed) to `settings.py`.

Test on dev machine!

### Build-out EC2

Clone git repo from remote using `git clone <repo_url>`.
Install python, anaconda, or miniconda. For miniconda use the following:
```shell
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh  # Download miniconda
bash Miniconda3-latest-Linux-x86_64.sh  # Install
source ~/.bashrc  # Restart terminal
```
and follow the prompts.


Copy files from dev machine ont EC2 if not already there using `scp -i <.pem key> <file> ubunutu@<EC2_DNS>:<location>`
Create and activate environment (can be done using a .yml with conda) 
```shell
conda env create -f environment.yml
conda activate <env_name>
conda env update --file environment.yml
```

Go ahead and get everything updated and fresh:
```shell
sudo apt update && sudo apt upgrade -y
```

Install all the dependencies for your project. Make sure to install any built in dev (like a swagger module).

Migrate databases and collect static files using 
```shell
python manage.py migrate
python manage.py collectstatic --noinput
```

Install appropriate **DBMS**: 
```shell
sudo apt install postgresql
```

Install and bind **gunicorn**: 
```shell
conda install gunicorn
gunicorn --workers 1 --bind 0.0.0.0:8000 <your_project_name>.wsgi:application &
```
If this works with no errors, kill it with ^C and move on to setting up Nginx.

Install and start nginx:
```shell
sudo apt update 
sudo apt install nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

Configure nginx (or create with configurator script) in `/etc/nginx/sites-availabe/<project_name>`
```shell
sudo nano /etc/nginx/sites-available/master_site
```sud
    NOTE: The file is `<project_name>` with not extension. It is _not_ a directory with a configuration file inside 
it. 
#### Set up SSL certification
Install a certification system for nginx 
    `sudo apt install certbot python3-certbot-nginx`

Obtain a certificate
    `sudo certbot --nginx`
and follow the prompts.

#### Set up Gunicorn as a system service
Add content to gunicorn service file (or created with configurator script)
and place in `/etc/systemd/system/gunicorn.service`
Start gunicorn
```shell
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
```

## Troubleshooting
Check Nginx and Gunicorn logs with 
`sudo journalctl -u gunicorn`
`sudo tail -f /var/log/nginx/error.log`
