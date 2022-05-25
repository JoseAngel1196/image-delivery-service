#!/bin/bash
sudo yum update
sudo yum search docker
sudo yum search docker
sudo yum install docker
sudo usermod -a -G docker ec2-user
sudo systemctl start docker.service
sudo systemctl status docker.service