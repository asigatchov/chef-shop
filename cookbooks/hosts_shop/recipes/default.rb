#
# Cookbook Name:: hosts_shop
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#



template "/etc/hosts" do
variables( hosts: node['shop_hosts']['hosts'])

  owner "root"
  group "root"
  mode "0644"
  source "hosts.erb"
  sensitive true
end



