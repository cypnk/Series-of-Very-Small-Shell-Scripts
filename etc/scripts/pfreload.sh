#!/bin/sh

# Reload PF if config has no errors

/sbin/pfctl -nf /etc/pf.conf
if [ $? -eq 0 ]; then
	/sbin/pfctl -f /etc/pf.conf
fi

