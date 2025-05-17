#!/bin/bash

# Git clone 
git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
cd /home/ubuntu/nodejs-mysql

# install nodejs
sudo apt update -y
sudo apt install -y nodejs npm

# edit env vars
echo "DB_HOST=" | sudo tee -a .env
echo "DB_USER=" | sudo tee -a .env
sudo echo "DB_PASS=" | sudo tee -a .env
echo "DB_NAME=" | sudo tee -a .env
echo "TABLE_NAME=users" | sudo tee -a .env
echo "PORT=3000" | sudo tee -a .env

# start server
npm install
                                
                                
