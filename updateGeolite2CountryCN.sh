#!/bin/bash

IPURL="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country-CSV&license_key=${GEOLITE2_LICENSE_KEY}&suffix=zip"

CURL=/usr/bin/curl

SETNAME=chnip
IPSETCONF=ipset_chnip.conf
CHNIPCONF=chnip.txt

TMPFILE=/tmp/geolite2.zip
TMPFILE2=/tmp/chnip.txt

$CURL --retry 5 --retry-delay 3600  --connect-timeout 10 --max-time 20 -sL "$IPURL" > $TMPFILE
if [ `file $TMPFILE | grep Zip | wc -l` = "0" ]
then
        echo "update failed"
        exit 1
fi

cd /tmp
rm -rf GeoLite2-Country-CSV_*
unzip $TMPFILE
cat GeoLite2-Country-CSV_*/GeoLite2-Country-Blocks-IPv4.csv | grep ',1814991,' | awk -F',' '{print $1}' > $TMPFILE2
cd -

cp ${TMPFILE2} ${CHNIPCONF}

echo -e "#`date`\ncreate ${SETNAME} hash:net family inet hashsize 2048 maxelem 65536" > $IPSETCONF
for i in `cat ${TMPFILE2}`
do
        echo "add ${SETNAME} ${i}" >> $IPSETCONF
done

echo "update successful!"