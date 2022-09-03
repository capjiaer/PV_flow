#! /bin/sh -f
c=0
while [ $c -lt $1]; do
	rcalibre "/tmp" 0 -mtflex $CALIBRE_REMOTE_CONNECTION -64 
	c=$((c + 1))
done
