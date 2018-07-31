# Copy this file, rename as 'a_prod_user.rb' and run following command on vim
# %s/\['dev'\]/\['prod'\]/g

# to generate encrypted password
# mkpasswd -m sha-512 -S ohmysalt

default['init_desktop']['dev']['users'] = [
  {
    'id' => 'ubuntu',
    'first_name' => 'Ubuntu',
    'last_name' => 'Canonical',
    'password' => '$6$onmysalt$y/9vmzHgyQkqViUjVlBI5Y5gRHoC9ejfwrhUEJl3Uy87FB8ahYvM5Hmtw/iv3Lur3RzDJHwIUnchJws0ypWsF1',
    'email' => 'hireme@gmail.com'
  },
  {
    'id' => 'don',
    'first_name' => 'Don',
    'last_name' => 'Draper',
    'password' => '$6$onmysalt$y/9vmzHgyQkqViUjVlBI5Y5gRHoC9ejfwrhUEJl3Uy87FB8ahYvM5Hmtw/iv3Lur3RzDJHwIUnchJws0ypWsF1',
    'email' => 'donoldfashioned@gmail.com'
  },
  {
    'id' => 'roger',
    'first_name' => 'Roger',
    'last_name' => 'Sterling',
    'password' => '$6$onmysalt$y/9vmzHgyQkqViUjVlBI5Y5gRHoC9ejfwrhUEJl3Uy87FB8ahYvM5Hmtw/iv3Lur3RzDJHwIUnchJws0ypWsF1',
    'email' => 'itwasnteasy@gmail.com'
  },
]
