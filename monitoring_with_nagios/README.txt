#################################################
# systemd units monitoring with Nagios via SNMP #
#################################################


# Follow Nagios Installation instructions as described here: https://assets.nagios.com/downloads/nagioscore/docs/Installing_Nagios_Core_From_Source.pdf

# Add those lines in the /usr/local/nagios/etc/nagios.cfg file (depending on how many machines you wish to monitor, one cfg file per host)
cfg_file=/usr/local/nagios/etc/objects/ubuntu_RP2.cfg
cfg_file=/usr/local/nagios/etc/objects/fedora_RP2.cfg


# Add this command in the /usr/local/nagios/etc/objects/commands.cfg file:
define command {
        command_name check_snmp_systemd
        command_line $USER1$/check_snmp_table.pl -H $HOSTADDRESS$ -C public -P 5555 -2 -N 1.3.6.1.2.1.27.1.1.2 -D 1.3.6.1.2.1.27.1.1.6 -C $ARG1$ -a $ARG2$ -w $ARG3$ -c $ARG4$
        }


# Copy the check_snmp_table.pl script in /usr/local/nagios/libexec/
sudo cp check_snmp_table.pl /usr/local/nagios/libexec/

# Configure the nagios_restart.sh script according to your configuration and run it (the script lacks exceptions, so make sure beforehand that your monitored hosts are reachable, and that the systemd snmp agent is running well).
vi nagios_restart.sh
./nagios_restart.sh


# Run the nagios_restart.sh script each time you perform a change on the files used by the agent on a monitored host (i.e. to_be_down_units, not_monitored_units, enabled_units) in order to make sure Nagios is reporting correct data. Run it at least 30 seconds after you made a change (frequency with which the agent performs updates).
