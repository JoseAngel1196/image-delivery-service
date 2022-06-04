#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Download web-application files from s3
sudo mkdir /home/ec2-user/www
sudo aws s3 cp s3://web-application-image-delivery-service/ /home/ec2-user/www --recursive
sudo chmod 0755 /home/ec2-user/www

# Move the www/ to NGINX
sudo mv /home/ec2-user/www /usr/share/nginx/
sudo mv /usr/share/nginx/html /usr/share/nginx/html-old
sudo mv /usr/share/nginx/www /usr/share/nginx/html

# NGINX Conf adjusment
sudo aws s3 cp s3://nginx-conf-image-delivery-service /home/ec2-user/
sudo cp /home/ec2-user/nginx.conf /etc/nginx/
sudo systemctl restart nginx