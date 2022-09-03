#! /bin/sh -f
for host in $LSB_HOSTS
	do
		rcalibre "/tmp" 0 -mtflex $CALIBRE_REMOTE_CONNECTION -64 -f &
	done
	wait
