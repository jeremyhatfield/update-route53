#!/bin/bash

### BEGIN INIT INFO
# Provides:             update-route53.sh
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    Update Route 53 record set
# Description:          At boot time, change AWS Route 53 record to reflect new IP address
### END INIT INFO

# troubleshooting file
exec > /tmp/debug-my-script.txt 2>&1

echo Path is: $PATH
echo User is: $USER

# AWS Hosted Zone ID
ZONEID="XXXXXXXXXXXXXX"
echo Zone Id: $ZONEID

# The CNAME you want to update e.g. hello.example.com
RECORDSET="xxx.example.com"
echo Record Set: $RECORDSET

# More advanced options below
# The Time-To-Live of this recordset
TTL=60
# Change this if you want
COMMENT="Auto updating @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"

# Get the external IP address
IP=$(curl http://checkip.amazonaws.com/)
echo Got IP address: $IP

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Get current dir (stolen from http://stackoverflow.com/a/246128/920350)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo Current directory is: $DIR

LOGFILE="$DIR/update-route53.log"
IPFILE="$DIR/update-route53.ip"
#LOGFILE="$HOME/update-route53.log"
#IPFILE="$HOME/update-route53.ip"

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP" >> "$LOGFILE"
    exit 1
fi
echo Valid IP address.

# Check if the IP has changed
if [ ! -f "$IPFILE" ]
    then
    touch "$IPFILE"
fi

if grep -Fxq "$IP" "$IPFILE"; then
    # code if found
    echo "IP is still $IP. Exiting" >> "$LOGFILE"
    exit 0
else
    echo "IP has changed to $IP" >> "$LOGFILE"
    # Fill a temp file with valid JSON
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > ${TMPFILE} << EOF
    {
      "Comment":"$COMMENT",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$RECORDSET",
            "Type":"$TYPE",
            "TTL":$TTL
          }
        }
      ]
    }
EOF

    # Update the Hosted Zone record
    aws route53 change-resource-record-sets --hosted-zone-id $ZONEID --change-batch file://"$TMPFILE" >> "$LOGFILE"
    echo "" >> "$LOGFILE"

    # Clean up
    rm $TMPFILE
fi

# All Done - cache the IP address for next time
echo "$IP" > "$IPFILE"

echo Route53 update finished
