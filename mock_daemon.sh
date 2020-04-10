
daemon_log_path="/tmp/daemon.log"
log_interval=30

while true
do 
	now=$(date +"%Y-%m-%d %T"); printf "Mock daemon is still running $now \n" >> $daemon_log_path;  
	sleep $log_interval; 
done
