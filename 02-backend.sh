#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/expense"
logs_file="${logs_folder}/${0}.log"
domain_name="depops.online"
scripts_dir=$(dirname "$(realpath "$0")")
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


timestamp(){
    date "+%F %T" 
}

if [ $user_id -ne 0 ]; then 
    echo "Please run this script with sudo access..."
    exit 1
fi

mkdir -p $logs_folder
echo "Script execution started at $(date +"%F %T")" &>> $logs_file

validate() {
    if [ $1 -ne 0 ]; then 
        echo -e "${2} ${R}failed${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2} ${G}successful${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file


dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Installing nodejs"

mkdir -p /app

useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>> $logs_file
validate $? "Creating expense system user"

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-backend-v5.tar.gz
validate $? "Downloading backend artifacts"

cd /app
tar -xzf /tmp/backend.tar.gz &>> $logs_file
validate $? "Extracting backend artifacts"

cd /app
npm install &>> $logs_file
validate $? "Installing backend dependencies"


sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/backend.service"
cp "$scripts_dir/backend.service" /etc/systemd/system/backend.service

dnf install mysql -y &>> $logs_file
mysql -h "mysql.$domain_name" -u root -pExpenseApp@1 < /app/schema/backend.sql 
validate $? "Creating backend database"

systemctl daemon-reload &>> $logs_file
systemctl enable backend &>> $logs_file
systemctl start backend &>> $logs_file
validate $? "Starting backend service"


echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file