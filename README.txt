mashpodder

podcatching client based on BashPodder

Starting in 2005, I have maintained a 'user-contributed' version of
BashPodder, the great podcatcher originally written by Linc Fessenden. My
mashup has become pretty popular, and I have maintained five separate releases
since that time.

I ended up rewriting much of my original mashup and so when version 0.6 was
ready, I decided to rename my version 'mashpodder' (as it is a mashup of
BashPodder and other stuff) and put it on Google Code.  I eventually moved it
to GitHub.

Mashpodder allows the user to download podcast episodes. The user can choose
to save these episodes in a named directory (i.e. separate directory per feed)
or in a date-based directory, so the most recent episodes are in one folder.
Or, the user can combine this by having some podcasts in a named directory and
others in the date-based directory. The user can choose to download all, none,
or a set number of episodes per feed. The user can also choose to mark the
episodes as downloaded (without actually downloading them) which can be used
to 'catch up' to a podcast.

Three files are needed: mashpodder.sh, mp.conf, and parse-enclosure.xsl. All
three of these files are available here in the mashpodder repository. You can
also browse through the source tree and download the files directly. There is
also a sample cron wrapper script that folks can use and modify. I will
occasionally package up a simple tarball of these files to make it easier for
folks to download.

Note, you also need wget, curl, and xsltproc installed. They are usually
included in most default distro installs or you can get them from your
distro's repositories.

Enjoy!
