#!/usr/local/bin/bash
# Créer le vagrantfile
# Demander infos 1.Choisir l'adresseIp / 2.Nom du dossier partagé à créer
# Remplir le vagrantfile
# Vagrant up
# Vagrant ssh
echo "Création du fichier vagrant"
touch Vagrantfile
echo "Choisssez la fin de votre adresse ip :"
read -p "192.168.33." ip
echo "Choisissez votre nom de dossier partagé"
read -p "./" dir
echo "Voulez-vous installer WordPress en Français (y/N)"
read response
if [ $response == "y" ];
then
  var=true
else
  var=false
fi

cat > vagrantfile << eof
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
config.vm.box = "ubuntu/xenial64"
config.vm.network "private_network", ip: "192.168.33.$ip"
config.vm.synced_folder "./$dir", "/var/www/html"
end
eof

mkdir $dir

cd $dir

cat > lamp_install.sh << eof
#!/bin/bash
sudo apt install apache2 -y
sudo apt install php7.0 -y
sudo apt install php7.0-cli
sudo apt install libapache2-mod-php7.0 -y
sudo apt install mysql-server -y
sudo apt install php7.0-mysql -y
sudo apt update
rm index.html
sudo apt install zip -y
sudo sed -i "477s/display_errors = Off/display_errors = On/g" /etc/php/7.0/apache2/php.ini
sudo sed -i "488s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php/7.0/apache2/php.ini
sudo sed -i "16s/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=vagrant/g" /etc/apache2/envvars
sudo sed -i "17s/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=vagrant/g" /etc/apache2/envvars
sudo a2enmod rewrite
sudo sed -i "12s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html/g" /etc/apache2/sites-available/000-default.conf
sudo sed -i "13c\ \t<Directory /var/www/html>\n\t\tOptions Indexes FollowSymLinks MultiViews\n\t\tAllowOverride All\n\t\tOrder allow,deny\n\t\tallow from all\n\\t<\/Directory\>" /etc/apache2/sites-available/000-default.conf
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info
  if [[ $var ]]; then
    wp core download --force --locale=fr_FR
  fi
sudo service apache2 restart
eof

cd ../
vagrant up
vagrant ssh
