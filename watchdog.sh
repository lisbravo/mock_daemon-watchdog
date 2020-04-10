
log_dir=/tmp/
daemon_log="${log_dir}daemon.log"
watchdog_log="${log_dir}scheduler.log"
check_process_interval=10
rotate_log_interval=300
daemon_name=mock_daemon.sh
daemon_launcher_command="./daemon_laucher.sh start"
daemonPID=0
max_restart_attempts=3
start_time=0
old_logs="*.log.*"
max_log_size=1000


get_proc(){
  daemonPID=$(pgrep -f $daemon_name)
}

touch $watchdog_log
echo "Watchdog started" >> $watchdog_log

start_time="$(date -u +%s)"

while true
do

  #Check every X secconds that daemon is running, restart if not
  get_proc
  
  if [ -z "$daemonPID" ]
  then
    attempt=0
    while [[ -z "$daemonPID" && "$attempt" -le "$max_restart_attempts" ]] 
    do
      $daemon_launcher_command
      attempt=$((attempt + 1))
      sleep 2
      get_proc
    done
    
    if [ -z "$daemonPID" ]
    then
      fatal= "FATAL: Daemon: $daemon_name could not be launched"  
      echo $fatal
      echo $fatal >> watchdog_log
      exit 1
    else
       now=$(date +"%Y-%m-%d %T")
       echo "Daemon restarted at:$now" >> $watchdog_log
    fi
  fi       
  
  #Rotate log every 5 minutes if size > 1000 bytes 
  current_time=$(date -u +%s)
  elapsed=$((current_time - start_time))  
  if [ $elapsed -ge $rotate_log_interval ]
  then
    start_time="$(date -u +%s)"
    
    log_size=$(ls -nl $daemon_log  | awk '{print $5}') 
    
    if [ $log_size -ge $max_log_size ]
    then
      rm_files="$log_dir$old_logs"
      rm $rm_files
      mv "${daemon_log}"  "${daemon_log}.$(date +"%Y-%m-%d_%T")"
      touch $daemon_log
    fi 
  fi
 
  sleep $check_process_interval
done 
