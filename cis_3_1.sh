#!/usr/bin/env bash

#Read the log group from cloudtrail into var1
var1=$(aws cloudtrail describe-trails | grep -Po ':log-group:\K[^:]+')

#creating support data
aws logs describe-metric-filters --log-group-name "$var1" > logsMetricsFilter.json

#output the data
cat logsMetricsFilter.json