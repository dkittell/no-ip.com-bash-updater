#!/bin/sh

#  NoIPUpdate.sh

clear

LOGFILE=~/noip.log

if [ -f $LOGFILE ]; then
    #echo "File $NOIP_Config exists."

    NOIP_Config=~/NOIP_Config.txt
    NOIP_Config_Encrypted=~/NOIP_Config_Encrypted.txt

    if [ -f $NOIP_Config ]; then
        #echo "File $NOIP_Config exists."
        #USERNAME=$(cat  $NOIP_Config | grep USERNAME | cut -d "=" -f2)
        #PASSWORD=$(cat  $NOIP_Config | grep PASSWORD | cut -d "=" -f2)
        decryptedConfig=$(openssl aes-256-cbc -d -in NOIP_Config.txt)
        USERNAME=$(echo $decryptedConfig | grep USERNAME | cut -d "=" -f2)
        PASSWORD=$(echo $decryptedConfig | grep PASSWORD | cut -d "=" -f2)
        echo "Username: $USERNAME"
    else
        #echo "File $NOIP_Config does not exist."
        echo "Type your username for no-ip.com, followed by [ENTER]:"
        read noipUser
        echo "USERNAME=$noipUser" > $NOIP_Config
        USERNAME=$noipUser

        echo "Type your password for no-ip.com, followed by [ENTER]:"
        read -s noipPass
        PASSWORD=$noipPass
        echo "PASSWORD=$noipPass" >> $NOIP_Config

        clear

        echo "Type an encryption password for no-ip.com congfig file, followed by [ENTER]:"
        openssl aes-256-cbc -in $NOIP_Config -out $NOIP_Config_Encrypted
        mv $NOIP_Config_Encrypted $NOIP_Config
        chmod 0400 $NOIP_Config
    fi

    # No-IP uses emails as passwords, so make sure that you encode the @ as %40
    #USERNAME=
    #PASSWORD=
    HOST=hostsite
    STOREDIPFILE=~/current_ip
    USERAGENT="Simple Bash No-IP Updater/0.4"

    if [ ! -e $STOREDIPFILE ]; then
        touch $STOREDIPFILE
    fi

    NEWIP=$(wget -O - http://dns.kittell.net/ip.php -o /dev/null)
    STOREDIP=$(cat $STOREDIPFILE)

    if [ "$NEWIP" != "$STOREDIP" ]; then
        RESULT=$(wget -O "$LOGFILE" -q --user-agent="$USERAGENT" --no-check-certificate "https://$USERNAME:$PASSWORD@dynupdate.no-ip.com/nic/update?hostname=$HOST&myip=$NEWIP")

        LOGLINE="[$(date +"%Y-%m-%d %H:%M:%S")] $RESULT"
        echo $NEWIP > $STOREDIPFILE
        echo "IP Changed"
    else
        LOGLINE="[$(date +"%Y-%m-%d %H:%M:%S")] No IP change"
        echo "No IP Change"
    fi

    echo $LOGLINE >> $LOGFILE

fi

exit 0
