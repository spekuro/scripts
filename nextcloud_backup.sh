#!/bin/bash
#
# Dependencies:
#
#  no dependencies
#
# Info :
#
#  You must have a ~/.my.cnf file with good credentials for using mysqldump !
#  You must inquire contact with your adress mail
#  You can use this line with crontab :
#  0 2 * * * /path_to_script/nextcloud_backup.sh > /var/log/nextcloud_backup.log ; /usr/sbin/ssmtp john@doe.com < /var/log/nextcloud_backup.log
#
# Usage:
#
#  ./nextcloud_backup.sh
#

# Variables
contact="john@doe.com"
date=`date +%d%m%Y`
days_to_keep="1"

function usage(){
	printf "
Usage: ./nextcloud_backup.sh

"
}

function print_alert(){
if [ -t 1 ]
then
	case "$2" in
		OK)
			printf "$1 [\e[32;1m$2\e[0m]\n"
		;;
		NOK)
			printf "$1 [\e[31;1m$2\e[0m]\n"
		;;
		WARNING)
			printf "$1 [\e[33;1m$2\e[0m]\n"
		;;
		*)
			printf "$1 [\e[37;1m$2\e[0m]\n"
	
		;;
	esac
else
	case "$2" in
		OK)
			printf "$1 [$2]\n"
		;;
		NOK)
			printf "$1 [$2]\n"
		;;
		WARNING)
			printf "$1 [$2]\n"
		;;
		*)
			printf "$1 [$2]\n"
	
		;;
	esac
fi
}

function test_cmd(){
	if [ $? -eq 0 ]
	then
		print_alert "$1" OK
	else
		print_alert "$1" NOK
		echo "Program aborted..."
		exit 0
	fi
}

case "$1" in
	-h | --help)
		usage
		exit 0
	;;
esac

# Mail Headers
if [ ! -t 1 ]
then
	printf "To:$contact\nFrom:$contact\nSubject: Nextcloud Backup Report\n"
fi

now=`date`
printf "\n--\nStarting backup at $now\n--\n\n"

# Mode maintenance ON
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on  > /dev/null 2>&1
test_cmd "Activation of the Nextcloud maintenance mode"

# Backup folder
if [ ! -d $HOME/backup ]
then
	mkdir $HOME/backup
	test_cmd "Creating $HOME/backup folder"
fi
if [ ! -d $HOME/backup/$date\_nextcloud ]
then
	mkdir $HOME/backup/$date\_nextcloud
	test_cmd "Creating $HOME/backup/$date""_nextcloud folder"
fi

# Rotating
find $HOME/backup/ -mtime +$days_to_keep -type d | while read line
do
	rm -rf $line
	test_cmd "Deleting $line"
done

# Backup Nextcloud
tar -cpzf $HOME/backup/$date\_nextcloud/nextcloud.tar.gz -C /var/www/html/nextcloud .
test_cmd "Backing up main directory /var/www/html/nextcloud/"

# Backup Nextcloud Database
mysqldump --single_transaction -h localhost -u nextcloud nextcloud > $HOME/backup/$date\_nextcloud/nextcloud.sql
test_cmd "Backing up nextcloud Database"

# Backup nginx folder
tar -cpzf $HOME/backup/$date\_nextcloud/nginx.tar.gz -C /etc/nginx .
test_cmd "Backing up nginx directory /etc/nginx/"

# Backup letsencrypt folder
tar -cpzf $HOME/backup/$date\_nextcloud/letsencrypt.tar.gz -C /etc/letsencrypt .
test_cmd "Backing up letsencrypt directory /etc/letsencrypt/"

# Mode maintenance OFF
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off  > /dev/null 2>&1
test_cmd "Deactivation of the Nextcloud maintenance mode"

now=`date`
printf "\n--\nEnding backup at $now\n--\n\n"
