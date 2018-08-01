#
# Cookbook:: init_desktop
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# google apt repo
apt_repository 'google' do
  uri node['init_desktop']['google']['apt']['url']
  arch 'amd64'
  distribution 'stable'
  components ['main']
  key 'https://dl-ssl.google.com/linux/linux_signing_key.pub'
  action :add
end

#	# chef apt repo
#	apt_repository 'chef' do
#	  uri node['init_desktop']['chef']['apt']['url']
#	  arch 'amd64'
#	  distribution 'bionic'
#	  components ['main']
#	  key 'https://packages.chef.io/chef.asc'
#	  action :add
#	end

apt_update 'update'

#	# for development
#	apt_package 'chefdk'

apt_package [
  'git',
  'vim',
  'golang-1.10-go',
  'libvirt-dev',  # to be able to install 'gogetit'
]

# necessary utilities
apt_package [
  'vlc',
  'tree',
  'byobu',
  'fcitx-hangul', # this contains an awesome clipboard manager
  'google-chrome-stable',
  'mysql-workbench',
  'unity-tweak-tool',
  'openjdk-8-jdk',
  'indicator-multiload',
  'dconf-editor',
]

file '/etc/apt/sources.list.d/google.list' do
  action :delete
end

# for virtual network
apt_package [
  'bridge-utils',
  'openvswitch-switch'
]

# for libvirt/kvm
apt_package [
  'cpu-checker',
  'virt-manager',
  'qemu-kvm',
  'libvirt-bin',
  'ubuntu-vm-builder',
  'bridge-utils'
]

# for lxd
apt_package [
  'zfsutils-linux',
  'lxd',
  'lxd-client'
]

node['init_desktop']['users'].each do |u|
  user u['id'] do
    manage_home true
    shell '/bin/bash'
    password u['password']
  end

  directory "/home/#{u['id']}/.byobu" do
    owner u['id']
    group u['id']
    mode '0750'
    action :create
  end

  directory "/home/#{u['id']}/development" do
    owner u['id']
    group u['id']
    mode '0755'
    recursive true
    action :create
  end

  directory "/home/#{u['id']}/.vim" do
    owner u['id']
    group u['id']
    mode '0755'
    action :create
  end

  directory "/home/#{u['id']}/.vim/bundle" do
    owner u['id']
    group u['id']
    mode '0755'
    action :create
  end

  directory "/home/#{u['id']}/.vim/sessions" do
    owner u['id']
    group u['id']
    mode '0755'
    action :create
  end

  # https://git-scm.com/docs/git-config
  bash "git_config_for_#{u['id']}" do
    code <<-EOH
			su - #{u['id']} -c "git config --global user.name \
      '#{u['first_name']} #{u['last_name']}'"
      su - #{u['id']} -c "git config --global user.email \
      '#{u['email']}'"
      EOH
  end

  git "/home/#{u['id']}/.vim/bundle/Vundle.vim" do
    repository 'https://github.com/VundleVim/Vundle.vim.git'
  end

  git "/home/#{u['id']}/.vim/bundle/mydotfile" do
    repository 'https://github.com/itisnotdone/mydotfile.git'
  end

  link "/home/#{u['id']}/.vimrc" do
    owner u['id']
    group u['id']
    to "/home/#{u['id']}/.vim/bundle/mydotfile/.vimrc"
  end

  bash "vim_config_for_#{u['id']}" do
    cwd "/home/#{u['id']}"
    user u['id']
    group u['id']
    code <<-EOH
      vim +PluginInstall +qall
      EOH
  end

  file "/home/#{u['id']}/.byobu/.tmux.conf" do
    content "set-option -g history-limit 100000"
    owner u['id']
    group u['id']
    mode '0640'
  end

  template "/home/#{u['id']}/.bash_aliases" do
    source 'bash_aliases.erb'
    owner u['id']
    group u['id']
    mode '0644'
  end

  sudo u['id'] do
    user u['id']
    commands ['ALL']
    runas 'ALL'
    nopasswd true
  end
end

template "/root/.bash_aliases" do
  source 'bash_aliases.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# 
main_user = node['init_desktop']['main_user']

bash 'chef_gem_install_gogetit' do
  user main_user
  group main_user
  cwd "/home/#{main_user}"
  environment 'PKG_CONFIG_PATH' => '/usr/lib/x86_64-linux-gnu/pkgconfig'
  code <<-EOH
    /opt/chefdk/embedded/bin/gem install gogetit
    EOH
  not_if '/opt/chefdk/embedded/bin/gem list gogetit -i | grep true'
end


node['init_desktop']['golang']['projects'].each do |pjt|
  bash "go_get_#{pjt}" do
    user main_user
    group main_user
    cwd "/home/#{main_user}"
    code <<-EOH
      source /home/#{main_user}/.bashrc
      /usr/lib/go-1.10/bin/go get -u #{pjt}
      EOH
    not_if { ::File.exist?("/home/#{main_user}/go/src/#{pjt}") }
  end
end

#	node['init_desktop']['zpool'].each do |pool|
#	  bash 'configure_zpool' do
#	    code <<-EOH
#	      zpool create -f -o ashift=12 #{pool['name']} #{pool['volume']}
#	      EOH
#	    not_if "zpool list | egrep '^#{pool['name']}'"
#	    not_if "zpool import | egrep '^#{pool['name']}'"
#	  end
#	
#	  pool['zfs'].each do |zfs|
#	    bash 'configure_zfs' do
#	      code <<-EOH
#	        zfs create #{pool['name']}/#{zfs['name']}
#	        zfs set compression=#{zfs['compression']} #{pool['name']}/#{zfs['name']}
#	        EOH
#	      not_if "zfs list | egrep '^#{pool['name']}/#{zfs['name']}'"
#	    end
#	  end
#	end

bash 'configure_lxd' do
  cwd "/home/#{main_user}"
  user main_user
  group main_user
  code <<-EOH
    sudo lxd init \
      --auto \
      --network-address #{node['init_desktop']['lxd']['network_address']} \
      --network-port #{node['init_desktop']['lxd']['network_port']} \
      --storage-backend #{node['init_desktop']['lxd']['storage_backend']} \
      --storage-pool #{node['init_desktop']['lxd']['storage_pool']}
    EOH
  not_if 'lxc config show | grep 0.0.0.0:8443'
end

bash 'configure_lxd' do
  cwd "/home/#{main_user}"
  user main_user
  group main_user
  code <<-EOH
    sudo lxc config set core.trust_password #{node['init_desktop']['lxd']['password']}
    EOH
  not_if 'lxc config show | grep true'
end

bash 'add_localhost_as_a_remote' do
  cwd "/home/#{main_user}"
  user main_user
  group main_user
  code <<-EOH
    sudo lxc remote add #{node['init_desktop']['lxd']['name']} localhost \
    --accept-certificate \
    --password=#{node['init_desktop']['lxd']['password']}
    EOH
  not_if "lxc remote list | grep #{node['init_desktop']['lxd']['name']}"
end

node['init_desktop']['lxd_images'].each do |image|
bash "download_image_of_#{image['local_alias']}" do
    cwd "/home/#{main_user}"
    user main_user
    group main_user
    code <<-EOH
      sudo lxc image --debug --verbose copy #{image['remote']}:#{image['name']} \
      local: --alias #{image['local_alias']} --public --auto-update
      EOH
    not_if "lxc image list | grep #{image['local_alias']}"
  end
end

# bash 'configure_ovs' do
#   user main_user
#   group main_user
#   code <<-EOH
#     EOH
#   not_if ''
# end

directory "/home/#{main_user}/Downloads" do
  owner main_user
  group main_user
  mode '0755'
  action :create
end

remote_file "/home/#{main_user}/Downloads/ads.tar.gz" do
  source 'http://mirror.apache-kr.org/directory/studio/2.0.0.v20170904-M13/ApacheDirectoryStudio-2.0.0.v20170904-M13-linux.gtk.x86_64.tar.gz'
  owner main_user
  group main_user
  action :create
end

bash 'extract_tar_gz' do
  cwd "/home/#{main_user}"
  user main_user
  group main_user
  code <<-EOH
    tar zxvf /home/#{main_user}/Downloads/ads.tar.gz \
    -C /home/#{main_user}/Downloads
    EOH
  not_if { ::File.exist?("/home/#{main_user}/Downloads/ApacheDirectoryStudio") }
end


template '/etc/network/interfaces' do
  source 'interfaces.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

bash 'disable_network_manager' do
  code <<-EOH
    systemctl stop NetworkManager.service
    systemctl disable NetworkManager.service
    EOH
end

apt_package 'dnsmasq'

#   bash 'configure_ip_forward' do
#     code <<-EOH
#       sed -i 's #\(net.ipv4.ip_forward=1\) \1 ' /etc/sysctl.conf
#       sysctl -p
#       EOH
#   end

template '/etc/rc.local' do
  source 'rc.local.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/sysctl.conf' do
  source 'sysctl.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/ssh/ssh_config' do
  source 'ssh_config.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

# sometimes, things get messy
node['init_desktop']['users'].each do |u|
  bash "chown_for_#{u['id']}" do
    cwd "/home/#{u['id']}"
    code <<-EOH
      chown -R #{u['id']}.#{u['id']} .
      EOH
  end
end
