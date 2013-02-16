#!/bin/bash
#
# This is a sample script to run mashpodder from a cron job.  There are many
# better ways to do this; this is just an example.  This script will capture
# the mashpodder output into a dailypodcastlog.txt file, which is overwritten
# each day, and will then append this daily log into the permpodcastlog.txt to
# create a permanent record.
#
# USAGE: save this script somewhere convenient, e.g. $HOME/bin, make it
# executable, change the necessary settings, and set a cron job, e.g.:
# 02 01 * * * /home/user/bin/sample-wrapper-for-cron.sh

# BASEDIR: Location of mashpodder and related files are located
BASEDIR=$HOME/mashpodder

# DAILYLOG/PERMLOG: Location and name of daily and permanent log files
DAILYLOG=$BASEDIR/dailypodcastlog.txt
PERMLOG=$BASEDIR/permpodcastlog.txt

# Now, the actual wrapper part.  First, run mashpodder and send output to
# the $DAILYLOG:
$BASEDIR/mashpodder.sh -v > $DAILYLOG

# Next, concatenate this to the $PERMLOG.
cat $DAILYLOG >> $PERMLOG
exit 0
