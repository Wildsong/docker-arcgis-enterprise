#!/bin/bash
#
#  Brute force remove the directories used to persist data
#  and re-create them. A hack I need until I learn why
#  ArcGIS refuses to re-use the folders.
#
d=`dirname $0`
p=`pwd`/$d
for i in config-store directories; do
    target=$p/$i
    if [ -d $target ]; then echo rm $target; rm -rf $target; fi
    echo mkdir $target
    mkdir $target
done
