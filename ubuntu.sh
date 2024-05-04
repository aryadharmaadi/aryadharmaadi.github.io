#!/bin/bash  -v

sudo apt update
sudo apt --yes --force-yes install python3-pip python3.11-venv git wget software-properties-common python3-launchpadlib snapd
cd /home
git clone https://github.com/ovanr/webFuzz.git
chmod +x -R webFuzz
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux64.tar.gz
tar -xzvf geckodriver-v0.34.0-linux64.tar.gz
chmod +x geckodriver
mv geckodriver /usr/local/bin/
wget https://wordpress.org/wordpress-6.5.2.tar.gz
tar -xzvf wordpress-6.5.2.tar.gz -C /var/www/html/ --strip-components=1

cd /home/webFuzz
python3 -m venv /home/venv
. /home/venv/bin/activate
apt-get install -y libxml2-dev libxslt1-dev zlib1g-dev python3-pip
apt-get -y install python3-lxml
pip3 install --upgrade -r webFuzz/requirements.txt

cd instrumentor
composer install
php src/instrumentor.php --verbose --method file --policy node --exclude exclude.txt --dir /var/www/html/
mv /var/www/html_instrumented/ /var/www/html/instrumented/
mkdir /var/instr
chmod o+rwx /var/instr
cd ../webFuzz
pip install --upgrade urllib3==1.26.16
./webFuzz.py -vv --driver /usr/local/bin/geckodriver -m /var/www/html/instrumented/instr.meta -w 8 -b 'wp-login|action|logout|' -b 'settings|||POST' -p -s -r simple http://localhost:80/instrumented