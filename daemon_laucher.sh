
daemon_name=mock_daemon.sh
daemonPID=0

start_daemon() {
  get_proc
  if [ ! -z "$daemonPID" ]
  then
    echo " Daemon: $mock_daemon is already running with PID: $daemonPID" 
  else  
    echo "Starting Daemon: $daemon_name ..."
    (sh $daemon_name &) &
    get_proc
    echo "Successfully started with PID: $daemonPID" 
  fi
}

stop_daemon() {
  echo "Stopping Daemon"
  pkill -f $daemon_name
}

restart_daemon() {
  echo "Restarting Mock Daemon"
  stop_daemon
  run_daemon
}

daemon_status() {
  get_proc
  echo "Daemon $daemon_name is running with PID $daemonPID"
}

get_proc(){
  daemonPID=$(pgrep -f $daemon_name)
}


action="$1" # Action to execute

case "$action" in
  start)
    start_daemon
    ;;
  stop)
    stop_daemon
    ;;
  restart)
    restart_daemon
    ;;
  status)
    daemon_status
    ;;
  *)
    echo "Actions: [start|stop|restart|status|run]"
    exit 1
    ;;
esac
