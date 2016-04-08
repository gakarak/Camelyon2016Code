#!/bin/bash

fout="idx.txt"

echo "path,label" > $fout

find $PWD -name '*.png' | while read ll
do
    dirName=`basename $(dirname $ll)`
    echo "$dirName : [$ll]"
    echo "${ll},${dirName}" >> $fout
done
