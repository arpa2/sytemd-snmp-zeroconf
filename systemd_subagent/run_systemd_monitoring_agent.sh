#
# python-netsnmpagent example agent with threading
#
# Copyright (c) 2013 Pieter Hollants <pieter@hollants.com>
# Licensed under the GNU Public License (GPL) version 3
#

#
# This script makes running threading_agent.py easier for you because it takes
# care of setting everything up so that the example agent can be run
# successfully.
#

set -u
set -e

# Find path to snmpd executable
SNMPD_BIN=""
for DIR in /usr/local/sbin /usr/sbin
do
	if [ -x $DIR/snmpd ] ; then
		SNMPD_BIN=$DIR/snmpd
		break
	fi
done
if [ -z "$SNMPD_BIN" ] ; then
	echo "snmpd executable not found -- net-snmp not installed?"
	exit 1
fi

# Make sure we leave a clean system upon exit
cleanup() {
	if [ -n "$TMPDIR" -a -d "$TMPDIR" ] ; then
		# Terminate snmpd, if running
		if [ -n "$SNMPD_PIDFILE" -a -e "$SNMPD_PIDFILE" ] ; then
			PID="$(cat $SNMPD_PIDFILE)"
			if [ -n "$PID" ] ; then
				kill -TERM "$PID"
			fi
		fi

		echo "* Cleaning up..."

		# Clean up temporary directory
		rm -rf "$TMPDIR"
	fi

	# Make sure echo is back on
	stty echo
}
trap cleanup EXIT QUIT TERM INT HUP

echo "* Preparing snmpd environment..."

# Create a temporary directory
TMPDIR="$(mktemp --directory --tmpdir threading_agent.XXXXXXXXXX)"
SNMPD_CONFFILE=$TMPDIR/snmpd.conf
SNMPD_PIDFILE=$TMPDIR/snmpd.pid

# Create a minimal snmpd configuration for our purposes
cat <<EOF >>$SNMPD_CONFFILE
[snmpd]
rocommunity public
rwcommunity simple 0.0.0.0/0
agentaddress 192.168.122.149:5555
informsink localhost:5556
smuxsocket localhost:5557
master agentx
agentXSocket $TMPDIR/snmpd-agentx.sock

[snmp]
persistentDir $TMPDIR/state
EOF
touch $TMPDIR/mib_indexes

# Start a snmpd instance for testing purposes, run as the current user and
# and independent from any other running snmpd instance
$SNMPD_BIN -r -LE warning -C -c$SNMPD_CONFFILE -p$SNMPD_PIDFILE

# Give the user guidance
echo "* Our snmpd instance is now listening on localhost, port 5555."
echo "  From a second console, use the net-snmp command line utilities like this:"
echo ""
echo "    cd `pwd`"
echo "    snmpwalk -v 2c -c public -M+. localhost:5555 NETWORK-SERVICES-MIB::applTable"
echo ""

# Workaround to have CTRL-C not generate any visual feedback (we don't do any
# input anyway)
stty -echo

# Now start the threading agent
echo "* Starting the systemd monitoring agent..."
python systemd_monitoring_agent.py -m $TMPDIR/snmpd-agentx.sock -p $TMPDIR/
