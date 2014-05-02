#!/bin/bash
count=1
cat abc | while read line 
do
   echo "Line $count:$line"
   wget $line
done
echo "finish"
exit 0
