
git clone --branch production --depth 1 --single-branch https://www.github.com/jiversivers/master-site.git
sudo apt update && sudo apt upgrade -y
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh

sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx



conda env create -f environment.yml
pip install -r requirements.txt
conda activate your_env_name

python manage.py migrate
