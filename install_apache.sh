#! /bin/bash
touch /tmp/foo.txt
echo "Jorge was here!!!" > /tmp/foo.txt
sudo apt-get update
sudo apt-get install -y apache2
sudo apt-get -y install stress
sudo systemctl start apache2
sudo systemctl enable apache2
HOSTNAME=`hostname`
echo "<center><h1>Deployed via Terraform</h1><center><hr><br><center><i>Powered by AWS ($HOSTNAME)</i></center>" | sudo tee /var/www/html/index.html
