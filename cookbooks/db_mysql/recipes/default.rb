#
# Cookbook Name:: db_mysql
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


percona = node["percona"]
server  = percona["server"]
conf    = percona["conf"]
mysqld  = (conf && conf["mysqld"]) || {}

datadir           = mysqld["datadir"] || server["datadir"]
passwords = EncryptedPasswords.new(node, node["percona"]["encrypted_data_bag"])

node.set["percona"]["use_chef_vault"] = false

include_recipe "percona::server"

execute "prepare_sql_dump" do
  cwd '/usr/local/src/' 
 #command "zcat  /usr/local/src/partner.sql.gz  >  /usr/local/src/partner.sql && sed -i  's/TYPE=MyISAM//g' /usr/local/src/partner.sql && iconv -f cp1251 -t utf8 -c /usr/local/src/partner.sql > /usr/local/src/partner_utf8.sql"
  command "zcat  /usr/local/src/partner.sql.gz  >  /usr/local/src/partner_utf8.sql"
  action :nothing
end

remote_file "/usr/local/src/partner.sql.gz" do
#  source "http://my-shop.ru/_files/prices/partner.sql.gz"
  source "http://www.fkis.ru/system/myshop_dump.sql.gz"
  not_if { File.exists?("/usr/local/src/partner.sql.gz") }
  notifies :run, 'execute[prepare_sql_dump]', :immediately
end

template "/usr/local/src/myshop.sql" do
  owner "root"
  group "root"
  mode "0600"
  source "myshop_db.sql.erb"
  sensitive true
end

execute "mysql-add-shopuser" do
    command "/usr/bin/mysql -uroot -p'#{passwords.root_password}' -e 'SOURCE  /usr/local/src/myshop.sql; use myshop; SOURCE /usr/local/src/partner_utf8.sql;' && rm /usr/local/src/partner_utf8.sql"
    subscribes :run, resources("template[/usr/local/src/myshop.sql]"), :immediately
    only_if { File.exists?("/usr/local/src/partner_utf8.sql") }
end

