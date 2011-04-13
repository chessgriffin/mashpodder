#!/bin/bash
#
# $Id$
#
# Mashpodder by Chess Griffin <chess@chessgriffin.com>
# Copyright 2009-2011
# Licensed under the GPLv3
#
# Originally based on BashPodder by Linc Fessenden 12/1/2004

### START USER CONFIGURATION
# Default values can be set here. Command-line flags override some of these.

# BASEDIR: Location of podcast directories
BASEDIR="$HOME/my podcasts"

# DATESTRING: Valid date format for date-based archiving.  Default is
# '%Y%m%d'.  Can be changed to other valid formats.  See man date.
DATESTRING='%Y%m%d'

#RSSFILE: Default is 'mp.conf.'  Can be changed to another file name.
RSSFILE="$BASEDIR/mp.conf"

#PARSE_ENCLOSURE: Location of parse_enclosure.xsl file.
PARSE_ENCLOSURE="$BASEDIR/parse_enclosure.xsl"

# FIRST_ONLY: Default '' means look to mp.conf on whether to download or
# update; 1 will override mp.conf and download the newest episode
FIRST_ONLY=''

# M3U: Default '' means no m3u playlist created; 1 will create m3u playlist
M3U=''

# UPDATE: Default '' means look to mp.conf on whether to download or update; 1
# will override mp.conf and cause all feeds to be updated (meaning episodes
# will be marked as downloaded but not actually downloaded).
UPDATE=''

# VERBOSE: Default '' is quiet output; 1 is verbose
VERBOSE=''

# WGET_QUIET: Default is '-q' for quiet wget output; change to '' for wget output
WGET_QUIET='-q'

# WGET_TIMEOUT: Default is 30 seconds; can decrease or increase if some files
# are cut short. Thanks to Phil Smith for the bug report.
WGET_TIMEOUT='30'

### END USER CONFIGURATION

### No changes should be necessary below this line

SCRIPT=${0##*/}
#VER=svn_r$(cat ${0} | grep '$Id: ' | head -1 | \
#sed -e 's/^.*Id: mashpodder.sh \([0-9.]*\) .*$/\1/')
#VER=svn
REV="$Revision$"
VER=svn_r$(cut -d' ' -f2 <<< "$REV")
CWD=$(pwd)
INCOMING="$BASEDIR/incoming"
TEMPLOG="$BASEDIR/temp.log"
PODLOG="$BASEDIR/podcast.log"
SUMMARYLOG="$BASEDIR/summary.log"
TEMPRSSFILE="$BASEDIR/mp.conf.temp"
OLDIFS=$IFS
IFS=$'\n'

crunch () {
    echo -e "$@" | tr -s ' ' | fmt -78
}

verbose () {
    if [ "$VERBOSE" = "1" ]; then
        return 0
    else
        return 1
    fi
}

sanity_checks () {
    # Perform some basic checks
    local FEED ARCHIVETYPE DLNUM DATADIR

    rm -f $TEMPRSSFILE
    touch $TEMPRSSFILE

    # Make sure the mp.conf file or the file passed with -c switch exists
    if [ ! -e "$RSSFILE" ]; then
        crunch "The file $RSSFILE does not exist in $BASEDIR.  Run $0 -h \
            for usage. Exiting."
        exit 0
    fi

    # Check the mp.conf and do some basic error checking
    while read LINE; do
        DLNUM="none"
        FEED=$(echo $LINE | cut -f1 -d ' ')
        ARCHIVETYPE=$(echo $LINE | cut -f2 -d ' ')
        DLNUM=$(echo $LINE | cut -f3 -d ' ')

        # Skip blank lines and lines beginning with '#'
        if echo $LINE | grep -E '^#|^$' > /dev/null
                then
                continue
        fi

        if [[ "$DLNUM" != "none" && "$DLNUM" != "all" && \
            "$DLNUM" != "update" && $DLNUM -lt 1 ]]; then
            crunch "Something is wrong with the download type for $FEED. \
                According to $RSSFILE, it is set to $DLNUM. \
                It should be set to 'none', 'all', 'update', or a number \
                greater than zero.  Please check $RSSFILE.  Exiting"
            exit 0
        fi

        # Check type of archiving for each feed
        if [ "$DLNUM" = "update" ]; then
            DATADIR=$ARCHIVETYPE
        else
            if [ ! "$ARCHIVETYPE" = "date" ]; then
                DATADIR=$ARCHIVETYPE
            elif [ "$ARCHIVETYPE" = "date" ]; then
                DATADIR=$(date +$DATESTRING)
            else
                crunch "Error in archive type for $FEED.  It should be set \
                    to 'date' for date-based archiving, or to a directory \
                    name for directory-based archiving.  Exiting."
                exit 0
            fi
        fi

        if [ "$FIRST_ONLY" = "1" ]; then
            DLNUM="1"
        fi
        if [ "$UPDATE" = "1" ]; then
            DLNUM="update"
        fi
        echo "$FEED $DATADIR $DLNUM" >> $TEMPRSSFILE
    done < $RSSFILE
}

initial_setup () {
    # Get some things ready first

    # Print the date
    if verbose; then
        echo
        echo "################################"
        echo "Starting mashpodder on"
        date
        echo
    fi

    # Make incoming temp folder if necessary
    if [ ! -e $INCOMING ]; then
        if verbose; then
            echo "Creating temp folders."
        fi
    mkdir -p $INCOMING
    fi

    # Delete the temp log:
    rm -f $TEMPLOG
    touch $TEMPLOG

    # Create podcast log if necessary
    if [ ! -e $PODLOG ]; then
        if verbose; then
            echo "Creating $PODLOG file."
        fi
        touch $PODLOG
    fi
}

fix_url () {
    # Take a url embedded in a feed and perform some fixes; also
    # get the filename
    local FIXURL

    FIXURL=$1

    # Get the filename
    FIRSTFILENAME=$(echo $FIXURL|awk -F / '{print $NF}')
    FILENAME=$(echo $FIRSTFILENAME|awk -F ? '{print $1}')

    # Remove parentheses in filenames
    FILENAME=$(echo $FILENAME | tr -d "()")

    # Replace URL hex sequences in filename (like %20 for ' ' and %2B for '+')
    FILENAME=$(echo "echo $FILENAME" \
        |sed "s/%\(..\)/\$(printf \"\\\\x\\1\")/g" |bash)

    # Replace spaces in filename with underscore
    FILENAME=$(echo $FILENAME | sed -e 's/ /_/g')

    # Fix Podshow.com numbers that keep changing
    FILENAME=$(echo $FILENAME | sed -e 's/_pshow_[0-9]*//')

    # Fix MSNBC podcast names for audio feeds from Brian Reichart
    if echo $FIXURL | grep -q "msnbc.*pd_.*mp3$"; then
        FILENAME=$(echo $FIRSTFILENAME | sed -e 's/.*\(pd_.*mp3$\)/\1/')
        return
    fi
    if echo $FIXURL | grep -q "msnbc.*pdm_.*mp3$"; then
        FILENAME=$(echo $FIRSTFILENAME | sed -e 's/.*\(pdm_.*mp3$\)/\1/')
        return
    fi
    if echo $FIXURL | grep -q "msnbc.*vh-.*mp3$"; then
        FILENAME=$(echo $FIRSTFILENAME | sed -e 's/.*\(vh-.*mp3$\)/\1/')
        return
    fi
    if echo $FIXURL | grep -q "msnbc.*zeit.*m4v$"; then
        FILENAME=$(echo $FIRSTFILENAME | sed -e 's/.*\(a_zeit.*m4v$\)/\1/')
    fi

    # Fix MSNBC podcast names for video feeds
    if echo $FIXURL | grep -q "msnbc.*pdv_.*m4v$"; then
        FILENAME=$(echo $FIRSTFILENAME | sed -e 's/.*\(pdv_.*m4v$\)/\1/')
        return
    fi

    # Remove question marks at end
    FILENAME=$(echo $FILENAME | sed -e 's/?.*$//')
}

check_directory () {
    # Check to see if DATADIR exists and if not, create it
    if [ ! -e $DATADIR ]; then
        crunch "The directory $DATADIR for $FEED does not exist. Creating \
            now..."
        mkdir -p $DATADIR
    fi
    return 0
}

fetch_podcasts () {
    # This is the main loop
    local LINE FEED DATADIR DLNUM COUNTER FILE URL FILENAME DLURL

    # Read the mp.conf file and wget any url not already in the
    # podcast.log file:
    while read LINE; do
        FEED=$(echo $LINE | cut -f1 -d ' ')
        DATADIR=$(echo $LINE | cut -f2 -d ' ')
        DLNUM=$(echo $LINE | cut -f3 -d ' ')
        COUNTER=0

        if verbose; then
            if [ "$DLNUM" = "all" ]; then
                crunch "Checking $FEED -- all episodes."
            elif [ "$DLNUM" = "none" ]; then
                crunch "No downloads selected for $FEED."
                echo
                continue
            elif [ "$DLNUM" = "update" ]; then
                crunch "Catching $FEED up in logs."
            else
                crunch "Checking $FEED -- last $DLNUM episodes."
            fi
        fi

        FILE=$(wget -q $FEED -O - | \
            xsltproc $PARSE_ENCLOSURE - 2> /dev/null) || \
            FILE=$(wget -q $FEED -O - | tr '\r' '\n' | tr \' \" | \
            sed -n 's/.*url="\([^"]*\)".*/\1/p')

        for URL in $FILE; do
            FILENAME=''
            if [ "$DLNUM" = "$COUNTER" ]; then
                break
            fi
            DLURL=$(curl -s -I -L -w %{url_effective} --url $URL | tail -n 1)
            fix_url $DLURL
            echo $FILENAME >> $TEMPLOG

            if ! grep -x "^$FILENAME" $PODLOG > /dev/null; then
                if [ "$DLNUM" = "update" ]; then
                    if verbose; then
                        crunch "Adding $FILENAME to log."
                        echo "$FILENAME added to log" >> $SUMMARYLOG
                    fi
                    continue
                fi
                check_directory $DATADIR
                if [ ! -e $DATADIR/"$FILENAME" ]; then
                    if verbose; then
                        crunch "NEW:  Fetching $FILENAME and saving in \
                            directory $DATADIR."
                        echo "$FILENAME downloaded to $DATADIR" >> $SUMMARYLOG
                    fi
                    cd $INCOMING
                    wget $WGET_QUIET -c -T $WGET_TIMEOUT -O "$FILENAME" \
                        "$DLURL"
                    mv "$FILENAME" $BASEDIR/$DATADIR/"$FILENAME"
                    cd $BASEDIR
                fi
            fi
            ((COUNTER=COUNTER+1))
        done
        # Create an m3u playlist:
        if [ "$DLNUM" != "update" ]; then
            if [ -n "$M3U" ]; then
                if verbose; then
                    crunch "Creating $datadir m3u playlist."
                fi
                ls $DATADIR | grep -v m3u > $DATADIR/podcast.m3u
            fi
        fi
        if verbose; then
            crunch "Done.  Continuing to next feed."
            echo
        fi
    done < $TEMPRSSFILE
    if [ ! -f $TEMPLOG ]; then
        if verbose; then
            crunch "Nothing to download."
        fi
    fi
}

final_cleanup () {
    # Delete temp files, create the log files and clean up
    if verbose; then
        crunch "Cleaning up."
    fi
    cat $PODLOG >> $TEMPLOG
    sort $TEMPLOG | uniq > $PODLOG
    rm -f $TEMPLOG
    rm -f $TEMPRSSFILE
    if verbose; then
        echo "All done."
        if [ -e $SUMMARYLOG ]; then
            echo
            echo "++SUMMARY++"
            cat $SUMMARYLOG
            rm -f $SUMMARYLOG
        fi
        echo "################################"
    fi
}

# THIS IS THE ACTUAL START OF SCRIPT
# Here are the command line switches
while getopts ":c:d:fmuvh" OPT ;do
    case $OPT in
        c )         RSSFILE="$OPTARG"
                    ;;
        d )         DATESTRING="$OPTARG"
                    ;;
        f )         FIRST_ONLY=1
                    ;;
        m )         M3U=1
                    ;;
        u )         UPDATE=1
                    ;;
        v )         VERBOSE=1
                    ;;
        h|* )       cat << EOF
$SCRIPT $VER
Usage: $0 [OPTIONS] <arguments>
Options are:

-c <filename>   Use a different config file other than mp.conf.

-d <date>       Valid date string for date-based archiving.

-f              Override mp.conf and download the first newest episode.

-h              Display this help message.

-m              Create m3u playlists.

-u              Override mp.conf and only update (mark downloaded).

-v              Display verbose messages.

mp.conf is the standard configuration file.  Please see the sample mp.conf for
how this file is to be configured.

Some of the default settings can be set permanently at the top of the script
in the 'USER CONFIGURATION' section or temporarily by passing a command
line switch.

EOF
                    exit 0
                    ;;
    esac
done

# End of option parsing
shift $(($OPTIND - 1))

cd $BASEDIR
sanity_checks
initial_setup
fetch_podcasts
final_cleanup
cd $CWD
IFS=$OLDIFS
exit 0
