#!/bin/bash

category="Cloud-Trail"
cis_2_1=0
cis_2_2=0
cis_2_3=0
cis_2_4=0
cis_2_5=0
cis_2_7=0
max_score=8
cat_total=
percent=0

#generate the cloudtrail list and save it into a  json.
aws cloudtrail describe-trails > ../data/traillist.json &&

#Ensure cloudtrail with IsMultiRegionTrail: true
if grep -q '"IsMultiRegionTrail": true' ../data/traillist.json; then
	cis_2_1=1
fi

#Esure Logfile validation enabled for the cloudtrail
if grep -q '"LogFileValidationEnabled": true' ../data/traillist.json; then
	cis_2_2=1
fi

#Ensure Cloudwatchlogsgropusarn is not empty it the value is empty this will not showup in the policy of trail
if grep -q '"CloudWatchLogsLogGroupArn"' ../data/traillist.json; then
	cis_2_4=1
fi

#Ensure that each trail has KMS property defined
if grep -q '"KmsKeyID"' ../data/traillist.json; then
	cis_2_7=1
fi

#ensure bucket attached to cloud trail is not plublicly accesible
trail_bucket=$(cat ../data/traillist.json | jq '.trailList[0] .S3BucketName' | tr -d '"')
buc_usr=$(aws s3api get-bucket-acl --bucket $trail_bucket --query 'Grants[?Grantee.URI==`http://acs.amazonaws.com/groups/global/AllUsers`]'| tr -d "[,]")
buc_auth_usr=$(aws s3api get-bucket-acl --bucket $trail_bucket --query 'Grants[?Grantee.URI==`http://acs.amazonaws.com/groups/global/Authenticated Users`]' | tr -d "[,]")

if [ -z "$buc_auth_usr" ] 
  then
    if [ -z "$buv_auth_usr" ]
    then
    cis_2_3=1
    fi
fi

#ensure loggin enabled for cloudtrail bucket
buc_log=$(aws s3api get-bucket-logging --bucket $trail_bucket)
echo $buc_log | grep -q "LoggingEnabled"
if [ "$?" -eq 0 ]
  then
  cis_2_6=1
fi
 
#ensure config service is enabled in all regions
region_list=("us-east-1" "us-west-2" "us-west-1" "eu-west-1" "eu-central-1" "ap-southeast-1" "ap-northeast-1" "ap-southeast-2" "ap-northeast-2" "ap-south-1" "sa-east-1")
arr_len=${#region_list[@]}

for (( i=1; i<${arr_len}+1; i++ ));
do
  res=$(aws configservice get-status --region ${region_list[i-1]})
  echo $res | grep -q "default recorder: ON"
  res=$(echo $?)
   if [ "$res" -eq 1 ]
     then
       if [ "$cis_2_5" -eq 1 ]
          then
           cis_2_5=0
        fi
   else
     cis_2_5=1
   fi
done 

#Ensure rotation for customer created CMKs is enabled
key_count=$(aws kms list-keys | grep -o KeyId | wc -l)
for (( i=1; i<${key_count}+1; i++ ));
do
  id=$(($i-1))
  key_id=$(aws kms list-keys | jq '.Keys['$id'] .KeyId' | tr -d '"')
  aws kms get-key-rotation-status  --key-id $key_id | grep -q '"KeyRotationEnabled": false'
  if [ "$?" -eq 0 ]
    then
    cis_2_8=0
  else
    cis_2_8=1
  fi
done
#scores
#echo 'cis_2_1='$cis_2_1 
#echo 'cis_2_2='$cis_2_2
#echo 'cis_2_3='$cis_2_3
#echo 'cis_2_4='$cis_2_4
#echo 'cis_2_5='$cis_2_5
#echo 'cis_2_6='$cis_2_6
#echo 'cis_2_7='$cis_2_7 
#echo 'cis_2_8='$cis_2_8
cat_total=$(($cis_2_1+$cis_2_2+$cis_2_3+$cis_2_4+$cis_2_5+$cis_2_6+$cis_2_7+$cis_2_8))
#echo 'section total='$cat_total
#echo 'section max='$max_score

#generation of csv file with results
echo '"control_name","category","subcategory","description","status","max","total"' > ../data/test.csv
echo '"cis_2_1","cloud_trail","ensure cloudtrail enabled in all regions",'$cis_2_1','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_2","cloudtrail", "ensure cloud trail logfile validation is enabled",'$cis_2_2','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_3","s3", "ensure s3 bucket cloudtrail logs is not publicaly accesible",'$cis_2_3','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_4","cloud_trail", "Ensure CloudTrail logs are integrated with cloud watch logs",'$cis_2_4','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_5","log", "Ensure AWS Config is enabled in all regions",'$cis_2_5','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_6","s3", "Ensure s3 bucket access logging is enabled on cloudtrail s3 bucket",'$cis_2_6','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_7","encryption","Ensure Cloud trail logs are encrypted at rest using KMS CMKs",'$cis_2_7','$max_score','$cat_total'' >> ../data/test.csv
echo '"cis_2_8","encryption","Ensure rotation for cutomer created CMKs is enabled",'$cis_2_8','$max_score','$cat_total'' >> ../data/test.csv
