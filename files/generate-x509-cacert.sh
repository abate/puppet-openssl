#!/bin/sh
# file managed by puppet

if [ $# -ne 5 ]; then
  echo "Usage: $0 hostname template outputdir days passwordfile"
  exit 1
fi

hostname=$1
template=$2
outputdir=$3
days=$4
password=$5

export RANDFILE=/dev/random

if [ ! -e $outputdir/serial ]; then
  echo 01 > $outputdir/serial
fi

touch $outputdir/index.txt

if [ ! -e $outputdir/$hostname.cert ] || [ ! -e $outputdir/private/$hostname.key ]; then
  openssl req -config $template -new -x509 -days $days -extensions v3_ca \
	  -passout file:$password \
	  -out $outputdir/$hostname.cert \
	  -keyout $outputdir/private/$hostname.key || exit 1
  chmod 600 $outputdir/private/$hostname.key
fi

exit 0
