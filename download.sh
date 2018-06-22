#!/bin/bash
wget 'https://www.dropbox.com/s/5xtzkb22d0wk2ok/download.tar.bz?dl=0' -O download.tar.bz
tar xvf download.tar.bz
mv download/* $PWD/
rm -r download
rm download.tar.bz
