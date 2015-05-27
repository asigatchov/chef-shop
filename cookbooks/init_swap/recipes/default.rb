#
# Cookbook Name:: init_swap
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

swap_file '/swapfile' do
  size      2048    # MBs
end
