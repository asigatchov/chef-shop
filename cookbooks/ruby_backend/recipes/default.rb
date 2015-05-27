#
# Cookbook Name:: ruby_backend
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


puts "#"*40
puts "ruby_backend"
puts "#"*40


%w(libpcre++-dev libcurl4-openssl-dev curl git-core libmysqlclient-dev).each do |pkg|
  package  pkg
end
#include_recipe "nginx_passenger"

user "myshop" do
 home "/home/myshop"
 shell "/bin/bash"
 uid 2000
# gid 2000
end

%w(/home/myshop /home/myshop/shared).each do |dir|
  directory dir do
    owner "myshop"
    group "myshop"
    mode 0755
    recursive true
    action :create
  end
end
directory "/home/myshop/.ssh" do
  owner "myshop"
  group "myshop"
  mode 0750
  recursive true
  action :create
end


directory "/home/myshop/releases" do
  owner "myshop"
  group "myshop"
  mode 0755
  recursive true
  action :create
end

execute "ssh-keygen -N '' -f /home/myshop/.ssh/id_rsa" do
  user "myshop"
  not_if "test -f /home/myshop/.ssh/id_rsa"
end


cookbook_file "/home/myshop/.ssh/authorized_keys" do 
  user "myshop"
  group "myshop"
  source "authorized_keys"
end

git "/home/myshop/shared/cached-copy" do
   repository "https://github.com/asigatchov/devops_ror_lab2.git"
   revision 'master'
   action :sync
   user "myshop"
   group "myshop"
end


execute "rvm gpg" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
end

execute "rvm install ruby 2.1.6" do 
  command "curl -sSL https://get.rvm.io | bash -s stable --ruby=2.1.6"
end


#execute "rvm default" do 
#  command "source /etc/profile.d/rvm.sh ; rvm use 2.1.6 --default"
#end


execute "add_init_rvm" do 
  command "echo 'export RAILS_ENV=production' >> /etc/bash.bashrc &&  echo 'source /etc/profile.d/rvm.sh' >> /etc/bash.bashrc"
  not_if { "grep -q 'source /etc/profile.d/rvm.sh' /etc/bash.bashrc"}
end

execute "gem passenger" do
  command "/bin/bash -c -l 'source /etc/profile.d/rvm.sh ; gem install passenger -v4.0.41 ; gem install bundler -v1.7.2'"
#  not_if { "gem list passenger -v4.0.41 | grep -q 'passenger (4.0.41)'" }
end




execute "bundle install" do 
  user 'myshop'
  cwd '/home/myshop/shared/cached-copy'
  not_if 'source /etc/profile.d/rvm.sh && bundle check'
  only_if 'gem list bundle | grep -q "bundle (1.7.2)"'
  command "/bin/bash  -c 'source /etc/profile.d/rvm.sh && bundle install --gemfile /home/myshop/shared/cached-copy/Gemfile --path /home/myshop/shared/bundle --deployment --quiet --without development test'"
  environment   "GEM_HOME" => "/usr/local/rvm/gems/ruby-2.1.6", "GEM_PATH" => "/usr/local/rvm/gems/ruby-2.1.6:/usr/local/rvm/gems/ruby-2.1.6@global",      "PATH" => "/usr/local/rvm/gems/ruby-2.1.6/bin:/usr/local/rvm/gems/ruby-2.1.6@global/bin:/usr/local/rvm/rubies/ruby-2.1.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/rvm/bin"
end


execute "init release" do 
  releases_dir =  Time.now.strftime("%Y%m%d%H%M%S")
  command "cp -r /home/myshop/shared/cached-copy /home/myshop/releases/#{releases_dir} && ln -s /home/myshop/releases/#{releases_dir}  /home/myshop/current"
  only_if "ls home/myshop/releases/ | wc -l | grep -q -P '^0$'"
end

execute 'nginx untar' do
  cwd '/usr/local/src/'
  command "tar -xzf /usr/local/src/nginx-1.6.3.tar.gz"
  only_if {File.exists?("/usr/local/src/nginx-1.6.3.tar.gz")}
  action :nothing
end

remote_file "/usr/local/src/nginx-1.6.3.tar.gz" do
  source "http://nginx.org/download/nginx-1.6.3.tar.gz"
  not_if { File.exists?("/usr/local/src/nginx-1.6.3.tar.gz") }
  notifies :run, 'execute[nginx untar]', :immediately
end

execute "install nginx" do
#  command  "/usr/local/rvm/gems/ruby-2.1.6/wrappers/passenger-install-nginx-module --auto --prefix=/opt/nginx/ --languages=ruby --nginx-source-dir=/usr/local/src/nginx-1.8.0 --extra-configure-flags=--with-http_secure_link_module"
 command   "/bin/bash  -l -i -c 'source /etc/profile.d/rvm.sh && passenger-install-nginx-module --auto --nginx-source-dir=/usr/local/src/nginx-1.6.3 --prefix=/opt/nginx/ --languages=ruby --extra-configure-flags=--with-http_secure_link_module'"
 environment   'PATH'  => "/usr/local/rvm/gems/ruby-2.1.6/bin:/usr/local/rvm/gems/ruby-2.1.6@global/bin:/usr/local/rvm/rubies/ruby-2.1.6/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/rvm/bin", "GEM_HOME" => "/usr/local/rvm/gems/ruby-2.1.6", "GEM_PATH" => "/usr/local/rvm/gems/ruby-2.1.6:/usr/local/rvm/gems/ruby-2.1.6@global"

  not_if {File.exists?("/opt/nginx/conf/nginx.conf")}
end



template "/opt/nginx/conf/nginx.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "nginx.conf.erb"
  sensitive true
end




