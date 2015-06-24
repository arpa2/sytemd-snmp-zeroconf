##############
# For Ubuntu #
##############
# Install snmpd, snmp, snmp-mibs-downloader
sudo apt-get install snmpd snmp snmp-mibs-downloader

# Download and install python-netsnmpagent 
wget https://pypi.python.org/packages/source/n/netsnmpagent/netsnmpagent-0.5.1.tar.gz
tar -zxf netsnmpagent-0.5.1.tar.gz
cd netsnmpagent-0.5.1/
python setup.py install

# Go to the systemd agent directory and configure the enabled_units, not_monitored_units and to_be_down_units files as wished

# Start the systemd agent
./run_systemd_monitoring_agent.sh




##############
# For Fedora #
##############
# Install net-snmp, net-snmp-libs, net-snmp-utils
yum install net-snmp net-snmp-libs net-snmp-utils

# Download and install python-netsnmpagent 
wget https://pypi.python.org/packages/source/n/netsnmpagent/netsnmpagent-0.5.1.tar.gz
tar -zxf netsnmpagent-0.5.1.tar.gz
cd netsnmpagent-0.5.1/
python setup.py install

# Go to the systemd agent directory and configure the enabled_units, not_monitored_units and to_be_down_units files as wished

# Start the systemd agent
./run_systemd_monitoring_agent.sh

