#!/bin/sh

# https://docs.travis-ci.com/user/multi-os/
# https://docs.travis-ci.com/user/osx-ci-environment/

# http://apple.stackexchange.com/questions/72226/installing-pkg-with-terminal

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
	# In /Users/travis/build/bolav/fuse-travis
	echo "Installing latest Fuse beta version"
	wget https://www.fusetools.com/downloads/latest/beta/osx -O fuse_osx.pkg
	sudo installer -pkg fuse_osx.pkg -target /
	echo "Installed Fuse"
	fuse --version
	mkdir -p $HOME/.fuse
fi
