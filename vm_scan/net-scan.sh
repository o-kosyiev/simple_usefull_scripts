#!/bin/bash
all_ip=$(sed ':a;N;$!ba;s/\n/ /g' $@)
touch logfile
printf "Please wait for result... \n \tIP \t    STATUS\n"
for ip in $all_ip
do
nc -vz -w 2 $ip 22 1>logfile 2>&1
result1=$(awk '{ print $NF }' logfile)
#echo $result1
result1=$(echo $result1 | cut -d' ' -f1)
if [[ $result1 != 'succeeded!' ]]
then
echo $ip - unavailable
fi

done

rm logfile
