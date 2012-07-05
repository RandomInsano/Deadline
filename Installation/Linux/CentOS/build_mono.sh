#!/bin/sh

# This is a simple build script I use to get Mono 2.10.2 onto CentOS.
# It'll install to /opt/mono so that it's modular and off to the side
# making it easy to delete or uninstall

# I've now gone and overcomplicated the whole thing by putting up guards
# and my own output. Look at older revisions to find a much simpler script

# Pre-flight stuff
yum -d 0 install automake libtool autoconf gcc-c++ bison gettext make # Mono deps
yum -d 0 install glib2-devel libpng-devel libX11-devel fontconfig-devel freetype-devel #libgdiplus deps

echo "==============================================="

if [[ ! -e /opt/mono/bin/mono ]]; then

	# Download and extract mono
	curl -L http://download.mono-project.com/sources/mono/mono-2.10.8.tar.bz2 | tar jx

	cd mono*

	# Build it
	echo "Building and installing Mono."
	echo "  Log output is being saved to 'build-log-mono.txt'"
	echo
	./autogen.sh --prefix=/opt/mono > ../build-log-mono.txt
	make all install >> ../build-log-mono.txt
	if [[ $? -ne 0 ]]; then
		echo "There was a problem building mono";
		echo "View the log for more details";
		echo
	fi

	cd ..
else
	echo "Mono seems to already exist in /opt/mono."
	echo "If you want to re-install, please remove /opt/mono/bin/mono"
	echo
fi

echo "==============================================="

if [[ ! -e /opt/mono/lib/libgdiplus.so ]]; then
	# Download and extract libgdi plus
	curl -L http://download.mono-project.com/sources/libgdiplus/libgdiplus-2.10.tar.bz2 | tar jx
	cd libgdi*

	# Build that too
	echo "Building and installing libGDIPlus."
	echo "  Log output is being saved to 'build-log-libgdiplus.txt'"
	echo
	./configure --prefix=/opt/mono > ../build-log-libgdiplus.txt
	make all install >> ../build-log-libgdiplus.txt
	if [[ $? -ne 0 ]]; then
		echo "There was a problem building libGDIPlus";
		echo "View the log for more details";
		echo
	fi

	cd ..
else
	echo "libGDIPlus seems to already exist in /opt/mono."
	echo "If you want to re-install, please remove /opt/mono/lib/libgdiplus.so"
	echo
fi

echo "==============================================="

# Post-flight goodies
echo 'export PATH=/opt/mono/bin:$PATH' > /etc/profile.d/deadline-path.sh
echo "/opt/mono/lib" > /etc/ld.so.conf.d/deadline-mono.conf
ldconfig

echo "If this was a new install, you'll need to log out and back in for the"
echo "PATH changes to take effect"
echo
echo "You'll also likely want to remove the temporary build folders"
