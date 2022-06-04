#!/bin/bash
sudo yum update -y

# Set up the server application
sudo mkdir /home/ec2-user/server-application
sudo aws s3 cp s3://server-application-image-delivery-service /home/ec2-user/server-application --recursive
cd /home/ec2-user/server-application
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 5000
