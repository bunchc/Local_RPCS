#!/bin/bash
# chef.sh

# Take care of some details
export DEBIAN_FRONTEND=noninteractive
MY_IP=$(ifconfig eth1 | awk '/inet addr/ {split ($2,A,":"); print A[2]}')

sudo apt-get update
sudo apt-get install -y git curl wget vim

sudo cat > /etc/hosts <<EOF
127.0.0.1	chef.cook.book localhost rpcs-chef

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
${MY_IP}         chef.cook.book rpcs-chef.cook.book rpcs-chef
EOF

###############
# Install chef server
echo "Installing Chef Server..."

wget --quiet https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef-server_11.0.8-1.ubuntu.12.04_amd64.deb -O /tmp/chef-server-11.deb

sudo dpkg -i /tmp/chef-server-11.deb
sudo chef-server-ctl reconfigure
sudo chef-server-ctl test

sudo mkdir -p /root/.chef/
sudo cp /etc/chef-server/admin.pem /root/.chef
sudo cp /etc/chef-server/chef-validator.pem /root/.chef
sudo cp /etc/chef-server/chef-validator.pem /vagrant/validation.pem

# Install chef client
curl -L https://www.opscode.com/chef/install.sh | sudo bash

# Make knife.rb
sudo cat > ~/.chef/knife.rb <<EOF
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '~/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '~/.chef/chef-validator.pem'
chef_server_url          'https://chef.cook.book'
cookbook_path            '/root/cookbooks/'
syntax_check_cache_path  '~/.chef/syntax_check_cache'
EOF

# Install the cookbooks
git clone https://github.com/rcbops/chef-cookbooks.git
cd chef-cookbooks
git checkout v4.2.1rc
git submodule init
git submodule sync
git submodule update

knife cookbook upload -a -o cookbooks
knife role from file roles/*rb
knife environment from file /vagrant/openstack.json
