#!/bin/bash

# Update system packages
sudo yum update -y

# Install required dependencies
sudo yum install -y python3 python3-pip nginx

# Navigate to home directory
cd /home/ec2-user/

# Clone the GitHub repository (replace with your repository URL)
git clone https://github.com/vidya1002/flask-ci-cd-demo.git

# Navigate into the project directory
cd flask-ci-cd-demo

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install required Python packages
pip install --upgrade pip
pip install -r requirements.txt

# Configure Gunicorn
sudo cp deployment/gunicorn.service /etc/systemd/system/gunicorn.service
sudo systemctl daemon-reload
sudo systemctl enable gunicorn
sudo systemctl start gunicorn

# Configure Nginx
sudo cp deployment/nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx

# Allow HTTP and HTTPS traffic
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Print completion message
echo "🚀 Deployment successful!"
