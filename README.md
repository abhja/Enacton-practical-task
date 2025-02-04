# Enacton-practical-task
step-1:update and upgrade the console.
by using the command: sudo apt update && sudo apt upgrade-y
step-2: then install the requirement pakages.
the pakages are zip,curl,rclone,cron.
the command is sudo apt install zip curl rclone cron -y
after installing the package.
step-2: configure rclone.
command: rclone config
in config choose the gdrive and set the connection between rclonr and gdrive to automatically push our backup to google drive.
step-1:we check our connection is successfully done or not we run rclone listremotes
and rclone lsd gdrive:
after set up the connection.
now write backup shell script file
go to webhook.site and copy the url and check the connection using curl
give permission of execution to backup.sh using chmod +x backup.sh
then go and run the file.
step-1:use cron job to set the retention period of backup and deletion of older files automatically
to see that use crontab -e
then set the timming when to run the job.
so you can see the backup is store in google drive.

