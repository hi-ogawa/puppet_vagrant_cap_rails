#!/bin/bash

# https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/nginx/oss/trusty/install_passenger.html#step-1:-install-passenger-packages

# Install our PGP key and add HTTPS support for APT
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates

# Add our APT repository
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
apt-get update

# Install Passenger + Nginx
apt-get install -y nginx-extras passenger
