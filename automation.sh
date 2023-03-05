
myname="rishabh"
s3_bucket="upgrad-rishabh"
timestamp=$(date '+%d%m%Y-%H%M%S')
apache_logs_dir="/var/log/apache2/"
tar_file_name="${myname}-httpd-logs-${timestamp}.tar"
tar_file_path="/tmp/${tar_file_name}"

sudo apt update -y

if ! dpkg -s apache2 &> /dev/null
then
    sudo apt install apache2 -y
fi

if ! systemctl status apache2 | grep running &> /dev/null
then
    sudo systemctl start apache2
fi

sudo systemctl enable apache2

sudo tar -cvf ${tar_file_path} ${apache_logs_dir}*.log --exclude "*.tar" --exclude "*.zip" &> /dev/null

aws s3 cp ${tar_file_path} s3://${s3_bucket}/${tar_file_name}
