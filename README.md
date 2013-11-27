mashpodder
==========

podcatching client based on BashPodder

Starting in 2005, I have maintained a 'user-contributed' version of BashPodder, the great podcatcher originally written by Linc Fessenden. My mashup has become pretty popular, and I have maintained five separate releases since that time.

I ended up rewriting much of my original mashup and so when version 0.6 was ready, I decided to rename my version 'mashpodder' (as it is a mashup of BashPodder? and other stuff) and put it here on Google Code.

Mashpodder allows the user to download podcast episodes. The user can choose to save these episodes in a named directory (i.e. separate directory per feed) or in a date-based directory, so the most recent episodes are in one folder. Or, the user can combine this by having some podcasts in a named directory and others in the date-based directory. The user can choose to download all, none, or a set number of episodes per feed. The user can also choose to mark the episodes as downloaded (without actually downloading them) which can be used to 'catch up' to a podcast.

Three files are needed: mashpodder.sh, mp.conf, and parse-enclosure.xsl. All three of these files are available here in the mashpodder SVN repository. You can also browse through the SVN tree and download the files directly. There is also a sample cron wrapper script that folks can use and modify. I will occasionally package up a simple tarball of these files to make it easier for folks to download.

Note, you also need wget, curl, and xsltproc installed. They are usually included in most default distro installs or you can get them from your distro's repositories. If you want to use the "beta" sync feature, then you need rsync too.

Update January 2013: Several enhancements and improvements were committed to the SVN repository. If mashpodder is working just fine for you, there is no need to upgrade. But, if you'd like to test out the lastest script with your setup, I'd appreciate the feedback. Please backup your podcast.log file first. A new svn49 tarball has been uploaded with all the latest changes but I've kept the svn37 tarball on the downloads page as well. (The svn44 tarball has been deprecated - there was a stupid bug introduced which has been fixed).

Also, big thanks to Steve for contributing the IdiotsGuide for Mashpodder. It's awesome and walks through the configuration.

Update April 2012: If you are getting a 'unary operator expected' error, please pull from SVN or download the latest svn37 tarball and try that. There was a fix committed in December, 2011 that should address this error.

Update May 2011: I've committed a few things to the SVN repository and rolled a new tarball snapshot based on SVN 34. This should work fine for most folks, but please let me know if you run into issues. This includes the ability to have space-separated directories (i.e. for /home/user/media/MY DEVICE) as the podcast directory. It also has a "beta" feature where the podcast directory can by synced to another directory -- i.e. rather than saving directly onto your device's mountpoint, you can save to a local directory and then mashpodder can optionally sync to your device. This is very basic "sync" support and lightly tested. If you don't need the space-separated directories or the sync feature, you can try the last tarball based on SVN 25.

Update March 2011: I'm still around and going to start hacking on mashpodder a bit. There have been a few issues reported in the Issue Tracker that I'm going to look into. Thanks for all the emails telling me you like mashpodder, I really appreciate that.

Update April 2010: A new svn tarball snapshot is available. This includes a minor bugfix and a new sample wrapper script to run mashpodder from a cron job and create a daily and permanent log of what files were downloaded. Thanks to everyone who has sent me an email or found me in IRC to let me know that mashpodder is working well for you. I still use it every day myself and run it from cron.

Update June 2009: I have packed up a simple tarball of all three files that you need. Check the downloads tab or see the link in the right column on this main page. Anyway, mashpodder has been working flawlessly for me and my scores of podcast feeds, and based on the feedback I have received, it is working great for tons of other folks too. Let me know if you find mashpodder useful or whether you encounter any issues. I'll be happy to try and fix any bugs that might exist.

Enjoy!
