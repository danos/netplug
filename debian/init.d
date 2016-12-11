#! /bin/sh
### BEGIN INIT INFO
# Provides:          netplug
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Should-Start:      $network $syslog
# Should-Stop:       $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Brings up/down network automatically
# Description:       Brings networks interfaces up and down automatically when
#                    the cable is removed / inserted
### END INIT INFO

PATH=/sbin:/bin
DAEMON=/sbin/netplugd
NAME=netplugd
DESC="network plug daemon"
PIDFILE=/var/run/$NAME.pid

test -x "$DAEMON" || exit 0

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

do_start () {
	# Return
	#   0 if daemon has been started
	#   1 if daemon was already running
	#   2 if daemon could not be started
	start-stop-daemon --start --quiet --pidfile "$PIDFILE" \
		--exec "$DAEMON" --test >/dev/null || return 1
	start-stop-daemon --start --quiet --pidfile "$PIDFILE" \
		--exec "$DAEMON" -- -p "$PIDFILE" >/dev/null || return 2
}

do_stop () {
	# Return
	#   0 if daemon has been stopped
	#   1 if daemon was already stopped
	#   2 if daemon could not be stopped
	#   other if a failure occurred
	local RETVAL
	start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile "$PIDFILE" --name "$NAME"
	RETVAL="$?"
	[ "$RETVAL" = 2 ] && return 2
	start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec "$DAEMON"
	[ "$?" = 2 ] && return 2
	return "$RETVAL"
}


case "$1" in
start)
	[ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC " "$NAME"
	do_start
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
stop)
	[ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
	do_stop
	case "$?" in
		0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
		2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
	esac
	;;
status)
	status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
	;;
restart|force-reload)
	log_daemon_msg "Restarting $DESC" "$NAME"
	do_stop
	case "$?" in
	0|1)
		sleep 1
		do_start
		case "$?" in
			0) log_end_msg 0 ;;
			1) log_end_msg 1 ;; # Old process is still running
			*) log_end_msg 1 ;; # Failed to start
		esac
		;;
	*)
		# Failed to stop
		log_end_msg 1
		;;
	esac
	;;
*)
	N=/etc/init.d/"$NAME"
	echo "Usage: $N {start|stop|status|restart|force-reload}" >&2
	exit 3
	;;
esac

exit 0
# vim:set ft=sh sw=4 ts=4:
