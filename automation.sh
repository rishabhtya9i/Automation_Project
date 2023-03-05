
myname="rishabh"
s3_bucket="upgrad-rishabh"
timestamp=$(date '+%d%m%Y-%H%M%S')
apache_logs_dir="/var/log/apache2/"
tar_file_name="${myname}-httpd-logs-${timestamp}.tar"
tar_file_path="/tmp/${tar_file_name}"
inventory_file="/var/www/html/inventory.html"


sudo apt update -y

if ! dpkg -s apache2 &> /dev/null
then
    sudo apt install apache2 -y
fi

if ! systemctl status apache2 | grep running &> /dev/null
then
    sudo systemctl start apache2
fi

# create inventory file if it does not exist
if [ ! -f $inventory_file ]; then
    echo -e "Log Type\tDate Created\tType\tSize" > $inventory_file
fi

sudo systemctl enable apache2

sudo tar -cvf ${tar_file_path} ${apache_logs_dir}*.log &> /dev/null

backup_size=$(du -h ${tar_file_path} | awk '{print $1}')

echo -e "httpd-logs\t$timestamp\ttar\t$backup_size" >> $inventory_file


aws s3 cp ${tar_file_path} s3://${s3_bucket}/${tar_file_name}

if [ ! -f /etc/cron.d/automation ]; then
    echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
fi
