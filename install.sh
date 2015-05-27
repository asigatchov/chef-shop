wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.5.1-1_amd64.deb
apt-get update && apt-get install build-essential lxc git-core vim -y
dpkg -i *.deb
dd if=/dev/zero of=/swapfile bs=512M count=4
chown root:root /swapfile
chmod 0600 /swapfile
mkswap /swapfile
swapon /swapfile
vagrant plugin install vagrant-lxc
vagrant plugin install vagrant-berkshelf
git clone repo@git.fkis.ru:/home/repo/devops.git

