name 'init_desktop'
default_source :supermarket
default_source :chef_repo, '../' do |s|
  s.preferred_for 'init_desktop'
end

run_list 'init_desktop'

