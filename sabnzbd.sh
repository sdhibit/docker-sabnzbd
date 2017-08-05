#! /bin/sh

# Start Sabnzbd+
/sbin/su-exec sabnzbd /usr/bin/python /opt/sabnzbd/SABnzbd.py \
	--config-file /config \
	--server :8080 \
	--browser 0