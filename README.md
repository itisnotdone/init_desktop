# init_desktop
A Chef cookbook to initialize desktop

## How to use

### Edit `attributes/default.rb` to configure attribues

### Run chef-client
```bash
# Download latest chef-client
# https://downloads.chef.io/chef
wget https://packages.chef.io/files/stable/chef/14.3.37/ubuntu/16.04/chef_14.3.37-1_amd64.deb
sudo dpkg -i chef_14.3.37-1_amd64.deb

mkdir -p chef-run/cookbooks
cd Chef-run/cookbooks

git clone https://github.com/itisnotdone/init_desktop.git

# Modify attributes/default.rb

chef-client -z

knife node list -z

knife node show -z `hostname -f`

knife node run_list add -z `hostname -f` init_desktop

sudo chef-client -z
```
