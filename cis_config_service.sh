#!/usr/bin/env bash
#ensure config service is enabled in all regions
region_list=("us-east-1" "us-west-2" "us-west-1" "eu-west-1" "eu-central-1" "ap-southeast-1" "ap-northeast-1" "ap-southeast-2" "ap-northeast-2" "ap-south-1" "sa-east-1")
arr_len=${#region_list[@]}
#echo '"Region","Recorder_status"' > config_list.csv
rm config_list.csv
touch config_list.csv
for (( i=1; i<${arr_len}+1; i++ ));
do
  res=$(aws configservice get-status --region ${region_list[i-1]})
  region=${region_list[i-1]}
  echo $res | grep -q "default recorder: ON"
  res=$(echo $?)
   if [ "$res" -eq 1 ]
     then
       echo "cis_2_5,'$region',false" >> config_list.csv
   else
      echo "cis_2_5,'$region',true" >> config_list.csv
   fi
done
cat config_list.csv

#'"Region": "'$region'","Recorder": false' >> config_list.csv