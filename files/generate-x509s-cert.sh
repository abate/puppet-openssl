#!/bin/bash
# file managed by puppet

set -x
if [ $# -ne 5 ]; then
  echo "Usage: $0 hostname template outputdir days"
  exit 1
fi

hostname=$1
template=$2
outputdir=$3
days=$4
password=$5

export RANDFILE=/dev/random

if [ ! -e $outputdir/$hostname.req ] || [ ! -e $outputdir/$hostname.key ]; then
  # we create the cert request and key
  echo "openssl req -config $template -new -nodes -days $days -out $outputdir/$hostname.req -keyout $outputdir/$hostname.key" > /tmp/cmd
  openssl req -config $template -new -nodes -days $days -out $outputdir/$hostname.req -keyout $outputdir/$hostname.key &> /tmp/zz
#  chmod 600 $outputdir/$hostname.key
  # we sign the key
  openssl ca -batch -passin file:$password -config $template -out $outputdir/$hostname.cert -infiles $outputdir/$hostname.req 
fi
