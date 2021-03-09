#!/bin/sh

# Nmap slow scan helper
# Results dumped to a timestamped file in /netscans in the user's home directory

# Timestamp
DATE=`date +%Y-%m-%d-%H-%M-%S`

# Current user's home
HOME=$( getent passwd "$USER" | cut -d: -f6 )

mkdir -p $HOME/netscans

# Init
nmap -T2 192.168.1.0/24 > $HOME/netscans/netscan-$DATE

