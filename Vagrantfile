Vagrant.configure(2) do |config|
  config.vm.box = "fgrehm/trusty64-lxc"
  config.vm.provision :chef_zero do |chef|
   chef.log_level = :info
   chef.cookbooks_path = "cookbooks"
   chef.encrypted_data_bag_secret_key_path = ".chef/encrypted_data_bag_secret"
   chef.roles_path = "roles"
   chef.data_bags_path = "data_bags"
   chef.environments_path = "environments"
   chef.environment = "development"
   chef.add_recipe "hosts_shop"
   chef.add_role "db_server"
  end
end
