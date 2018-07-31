# Since there will be no Nexus installed,
# it needs to refer origin package repositories when running on actually desktop
#
# a_dev_user.rb and a_prod_user.rb will be evaluated first.

if default['init_desktop']['prod'].empty?
  the_env = 'dev'
else
  the_env = 'prod'
end

case the_env
when 'dev'
  default['init_desktop']['google']['apt'] = {
    'url' => 'https://def-nexus.default.don/repository/google/chrome/deb/'
  }
  default['init_desktop']['chef']['apt'] = {
    'url' => 'https://def-nexus.default.don/repository/chef-apt/repos/apt/stable'
  }
when 'prod'
  default['init_desktop']['google']['apt'] = {
    'url' => 'http://dl.google.com/linux/chrome/deb/'
  }
  default['init_desktop']['chef']['apt'] = {
    'url' => 'http://packages.chef.io/repos/apt/stable'
  }
end

default['init_desktop']['users'] = default['init_desktop'][the_env]['users']
default['init_desktop']['main_user'] = default['init_desktop']['users'][0]['id']

default['init_desktop']['golang']['projects'] = [
  'github.com/motemen/gore',
  'github.com/d4l3k/go-pry',
  'github.com/nsf/gocode',
  'github.com/itisnotdone/easeovs',
  'github.com/itisnotdone/gostudy',
]

default['init_desktop']['zpool'] = [
  {
    'name' => 'p1',
    'volume' => 'sdb',
    'zfs' => [
      {
        'name' => 'lxc',
        'compression' => 'lz4'
      },
      {
        'name' => 'kvm',
        'compression' => 'lz4'
      }
    ],
    'restore' => true,
  }
]

default['init_desktop']['lxd'] = {
  'name' => 'dev-lxd',
  'network_address' => '0.0.0.0',
  'network_port' => '8443',
  'storage_backend' => 'zfs',
  'storage_pool' => 'pssd/lxc',
  'password' => 'password',
}

default['init_desktop']['lxd_images'] = [
  {
    'remote' => 'ubuntu',
    'name' => '16.04',
    'local_alias' => 'ubuntu-16.04'
  }
]

default['init_desktop']['network_config'] = {
  'gate_dev' => 'eno1',
  'dns' => '8.8.8.8'
}
