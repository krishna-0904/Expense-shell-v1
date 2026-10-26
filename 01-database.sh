#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/expense"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


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
        echo -e"${2} ${G}successful${N}" | tee -a $logs_file
    fi
}

dnf install mysql-server -y
validate $? "Installing mysql-server"

systemctl enable mysqld
systemctl start mysqld
validate $? "Starting mysql-server"

mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "Setting root password for mysql-server"