#!/bin/bash
# This script restarts the nagios service.
# But first of all, it creates dynamically Nagios files necessary for Nagios to monitor systemd units of monitored hosts.
# The script lacks exceptions, so make sure your hosts are properly configured before running it.

# Defining variables
hostname1="ubuntu_RP2"
hostname2="fedora_RP2"
host1="192.168.122.149"
host2="192.168.122.184"
snmp_port1="5555"
snmp_port2="5555"
nagios_file_host1="/usr/local/nagios/etc/objects/ubuntu_RP2.cfg"
nagios_file_host2="/usr/local/nagios/etc/objects/fedora_RP2.cfg"

# Querying SNMP to retrieve all monitored systemd units
units_host1=`sudo snmpwalk -v 2c -c public -M+. $host1:$snmp_port1 NETWORK-SERVICES-MIB::applTable | awk '/applName/ {print $4}'`
units_host2=`sudo snmpwalk -v 2c -c public -M+. $host2:$snmp_port2 NETWORK-SERVICES-MIB::applTable | awk '/applName/ {print $4}'`



# Updating the nagios file for host1
sudo cat > $nagios_file_host1 << EOF
define host{
        use                     linux-server
        host_name               $hostname1
        alias                   $hostname1
        address                 $host1
        }
EOF

for i in $units_host1; do
sudo cat >> $nagios_file_host1 << EOF
define service{
        use                             local-service
        host_name                       $hostname1
        service_description             $i
        check_command                   check_snmp_systemd!public!'$i'!'>2'!'=2'
}

EOF
done


# Updating the nagios file for host2
sudo cat > $nagios_file_host2 << EOF
define host{
        use                     linux-server
        host_name               $hostname2
        alias                   $hostname2
        address                 $host2
        }
EOF

for i in $units_host2; do
sudo cat >> $nagios_file_host2 << EOF
define service{
        use                             local-service
        host_name                       $hostname2
        service_description             $i
        check_command                   check_snmp_systemd!public!'$i'!'>2'!'=2'
}

EOF
done


# Making sure that the owner of the files is the nagios user 
sudo chown nagios:nagios $nagios_file_host1
sudo chown nagios:nagios $nagios_file_host2


# Restarting the Nagios service
sudo /usr/bin/service nagios restart
