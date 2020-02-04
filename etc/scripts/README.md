This folder contains the scripts and templates used by them.

Remember to set `chmod +x script.sh` on these.

Files:
* domains.conf - The list of domains hosted by this server
* hosting.sh - Creates configuration settings for new domains in domains.conf, including email
* acme.sh - Updates or creates TLS certificates using Let's Encrypt (using domains.conf)
* abuse.sh - Updates PF block tables using publicly available lists
* spamhaus.sh - Download blocklists from Spamhaus
* pfreload.sh - Refresh the PF firewall configuration if there are no errors
* logrotate.sh - Roll over the old access/error logs
* mail.sh - Sort received mail into domain folders
* usbcopy.sh - A backup script to collect and copy important files/folders to a USB drive
