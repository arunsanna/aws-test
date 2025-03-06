# AWS CloudTrail CIS Benchmarks Assessment Tool

This tool performs security assessments of AWS CloudTrail configurations based on the CIS (Center for Internet Security) AWS Benchmarks.

## Overview

The scripts in this repository evaluate your AWS environment against CIS benchmarks, specifically focusing on CloudTrail configurations and related security settings. The primary script generates a CSV report with compliance status for each control.

## Prerequisites

- AWS CLI installed and configured with appropriate permissions
- `jq` command-line JSON processor
- Bash shell environment
- AWS credentials with permissions to:
  - Read CloudTrail configurations
  - Access S3 bucket information
  - Query CloudWatch logs
  - Check AWS Config status
  - Access KMS key information

## Scripts

### cis_cloudtrail.sh

The main script that performs CIS benchmark assessments for AWS CloudTrail. It checks the following controls:

| Control ID | Category     | Description |
|------------|--------------|-------------|
| CIS 2.1    | Cloud_Trail  | Ensure CloudTrail is enabled in all regions |
| CIS 2.2    | CloudTrail   | Ensure CloudTrail log file validation is enabled |
| CIS 2.3    | S3           | Ensure S3 bucket CloudTrail logs are not publicly accessible |
| CIS 2.4    | Cloud_Trail  | Ensure CloudTrail logs are integrated with CloudWatch logs |
| CIS 2.5    | Log          | Ensure AWS Config is enabled in all regions |
| CIS 2.6    | S3           | Ensure S3 bucket access logging is enabled on CloudTrail S3 bucket |
| CIS 2.7    | Encryption   | Ensure CloudTrail logs are encrypted at rest using KMS CMKs |
| CIS 2.8    | Encryption   | Ensure rotation for customer created CMKs is enabled |

### test1.sh

A helper script for testing the region detection functionality.

## Usage

1. Ensure you have the prerequisites installed and AWS CLI configured
2. Run the main script:

```bash
./cis_cloudtrail.sh
```

3. Review the generated `test.csv` file for compliance results

## Output

The tool generates a CSV file (`test.csv`) with the following columns:
- control_name: The CIS control identifier
- category: The security category of the control
- subcategory: More specific categorization
- description: What the control is checking
- status: Compliance status (0 = non-compliant, 1 = compliant)
- max: Maximum possible score
- total: Total score achieved

## Files

- `cis_cloudtrail.sh`: Main assessment script
- `test1.sh`: Helper script for testing functionality
- `traillist.json`: Generated file containing CloudTrail configuration details
- `test.csv`: Output report with compliance status

## Troubleshooting

If you encounter errors:
1. Ensure AWS CLI is properly configured
2. Verify you have sufficient permissions
3. Check that `jq` is installed and accessible
4. Validate that the AWS services being checked are provisioned in your account

## License

[Specify license information here]

## Author

[Your name or organization]