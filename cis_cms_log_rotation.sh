#!/bin/bash
#Ensure rotation for customer created CMKs is enabled
key_count=$(aws kms list-keys | grep -o KeyId | wc -l)
#echo '"KeyId","KeyRotationEnabled"' > cis_cms_rotation.csv
touch cis_cms_rotation.csv
for (( i=1; i<${key_count}+1; i++ ));
do
  id=$(($i-1))
  key_id=$(aws kms list-keys | jq '.Keys['$id'] .KeyId' | tr -d '"')
  key_rotation=$(aws kms get-key-rotation-status  --key-id $key_id | jq ".KeyRotationEnabled")
  echo "'$key_id',$key_rotation" >> cis_cms_rotation.csv
done
cat cis_cms_rotation.csv

aws logs describe-metric-filters --log-group-name