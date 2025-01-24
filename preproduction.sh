conda env export --name jiversivers_env > environment.yml
pip freeze
git push -m 'preproduction push'
scp -i ~/jivers.pem .env ubunt fu@ec2-3-145-158-153.us-east-2.compute.amazonaws.com:~/master-site
