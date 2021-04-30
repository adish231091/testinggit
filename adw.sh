#!/bin/sh +x



IsTenantExist()
{
	while [ true ] 
	do

		RANDOM=$$
		Id=$RANDOM
        echo $Id
		IsObjectExist="http://${Host}:${Port}/api-metadata/v1/metadata/tenants/${Id}"
		echo $IsObjectExist

		IsObjectExistOutput=$(curl -o ${WORKSPACE}sanity/adw/IsTenantExists.txt -w '%{http_code}' -X GET ${IsObjectExist} -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM" -H "Content-type: application/json")

		echo $IsObjectExistOutput

		if [ $IsObjectExistOutput -eq 200 ]; then
			echo "Tenant Already Exist with ID : " $Id
			#IsTenantExist
            continue
	
		else 

			echo "Tenant Not Present with this Tenant Id : " $Id
			break
		fi
	done	
}


ValidateCommand()
{
	if [ $ExitCode -eq 0 ]; then
		exit 0
	else
		exit 1
	fi
}




CreateTenant()
{

	echo "Id is : " $1
	TenantId=$1
	while [ true ]
	do

		
		TenantCreateCall="http://${Host}:${Port}/api-metadata/v1/metadata/tenants"

		TenantCreateOutput=$(curl -o ${WORKSPACE}sanity/adw/TenantDetails.txt -w '%{http_code}' -X POST ${TenantCreateCall} -d '{
	"id" : '"${TenantId}"',
	"parentTenantID" : 0,
	"abbreviation" : "testing Jira",
	"displayName" : "Testingtenantsanity"}' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM"  -H "Content-type: application/json")
		echo "Tenant Create API Status Code is : " $TenantCreateOutput


		if [ $TenantCreateOutput -eq 201 ]; then
			echo "Tenant Creates Successfully..." $TenantCreateOutput
			
			break
		else
			ExitCode=$?
			ValidateCommand
		fi
	done

}

CreateSourceInstance()
{
	
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${WORKSPACE}sanity/adw/TenantDetails.txt)
	echo "Tenant Access Key : " $TenantAccessKey
	SourceInstanceCreateCall="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sourceinstances"
	
	TenantId=$1
	echo $SourceInstanceCreateCall
        SourceInstanceCreateOutput=$(curl -o ${WORKSPACE}sanity/adw/SourceInstance.txt -w '%{http_code}' -X POST ${SourceInstanceCreateCall} -d '{
  	"tenantId": '"${TenantId}"',
  	"name": "SanityCheckCSV_SOURCE",
  	"versionTS": 1614319146240,
  	"description": "SanityCheckCSV",
  	"active": true,
  	"lastModifiedBy": "mcps",
  	"createdBy": "mcps",
  	"createdTS": 1614319146240,
  	"componentDefinitionId": "FTPCustom",
  	"uniqueInstanceId": "SanityCheckPostDeployment1",
  	"parameters": {
    		"path": "sftp://alex@100.104.146.182/home/alex/data/mcps/SanityADW/*[0-9]{1,}.csv",
    		"referenceName": "SanityCheckPostDeployment",
    		"pem": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAKCAQEAv3m59IwCnl+6Vt71lgjX1QNTC8/7OPKGRu4rGcAgkKXUa97g\n4jgFJcaclggiKAz3rSRQ0hxSt2GO2tjGVmmOYdovi6vE5zSQyv4tg6lsK4MTOYy5\n2VwnTUxoaF3m3Nv0aCrur3N9Y2k5BpfFthVoeTTsY/NXowqZxfzrtmmpGtViOcxM\nS1H/3sUyjPK6jyOy19UJb2HsCh2LBDaUA6ufNi9hmnuPHOharmFDpf3DMaBwIsG5\nXKTqdDiWrFLzA90EnECF0m4lnxiHUcZLmljImteG73xt7Y9EBUE6H000M4EG2Tt0\nEamA5a35muzpkHUx4YfFI7dgzcC/XI/UfVyqowIDAQABAoIBAQClH09a8icL9xfV\n9J6rTWL7wssqQ6itmpBruNaYdVRgCXIfuGwNCix+QEInLEpwaYZp3QiJuX0nwc0V\nM54PRSZRgnxAIdhDXtSDCiGsCj5LY9T/azmWld8azQq4/kmqK1EhR+zgh2MZiNNx\nuQ76kImxBQ/avi7UXr7vu8Z2X7ZCeUYsQVHfxPEeheT2Jcs0A5NMNAlvYgvxrAY8\n5pGt9K61Q12E6U0+44fQ8fQ6X7gr6B7y7ILlR+FNldB/8vxjl4k1ZShM0LefP/ip\nwAY1fWavxbD4EBelSiU2uEcVgAFai5uZh/dz+Xgx5ln9crmrwjBxwp+axpvN4r0R\n9KYVTsLBAoGBAOLIbrfLL1AKzRoiYLEeDeuqqWH1X/E+Zu/hWLbGgECe+iDNNaKk\nwmK6oivhDrYf2TmFebq1QBHY7+6U+T1ZodKQNEQb+eEkRKNPBFUKVS3bdoApqurL\nQ8Lr3zyugkD08VnYfh1dquHHo2+3EuuiY1K6ROdUASy45c+9EheegcUDAoGBANgk\n0BoE+xJElrmEJ6FVg6tkj8YZcXz25hTNR9F3+J8K8HHer47cCnPYCQwJPZU9g8gc\nG7WlhQo58kyYGjdviXDeWNOckT73qBN9zSpAjGE608ozCT3J1k2I4H1EaB6ICBzq\nVDz6zm4lY+dgqWXQe6fBpxUaPtmgn3ndE7ewWIHhAoGBAMCo/kZt+xfI1U2qfvJ5\nUeIv7g4mYweTt+d6Td+Y60P6ywwqybIOvoUZgMQ+Qj0++VAAsNWJPZDr94l8TfFs\nwCkeEQj7q2E1aopCiq+kQ5DdrOJcg7NMU5i4wcHPjyCX9qIZZaqU9KMy8wnpQc2k\n+zRAwmCz4PuZaML/IOun4R75AoGBAMOlfuEuhP1iLHS8lQrKVyb7HdEZEsskydsm\nfc2zpM6BnmfURGEx+Bwn/vhwHNhMGE84cjSYILbDAPon7AMl6OjLuufBHxA6KF+M\nTfvi9a7FCxRJ4iGV42/HaDy7gOuyAnX5/ko8VEMLgUTdEDji4CtXdR/6480mQXST\nkteAvnzBAoGABH+t2TQbDhEIz0reNvKZlVhk61EdJjYgB7GEZaAO/5MoSrIZDjcv\n94FJDbbXqFpwM8c27YojSqO2Z03wgdD2xFy+DMCVz88FAFeNurizbPUdn6QaExWn\nDS2wrdlqpCWh/NcbvQkJ43ZSsbbSGqTc3CArFnHmnGLU3RyaMHmT+d0=\n-----END RSA PRIVATE KEY-----"
  			}
}' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM"  -H "Content-type: application/json")


	echo "SourceInstance Status Code:" $SourceInstanceCreateOutput

	if [ $SourceInstanceCreateOutput -eq 201 ]; then
		echo "Source Instance created successfully with status code :" $SourceInstanceCreateOutput
	else
		ExitCode=$?
		echo "Source Instance not created successfully..."
		ValidateCommand
	fi
}

CreateSinkInstance()
{
	 
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${WORKSPACE}sanity/adw/TenantDetails.txt)
    	echo "Tenant Access Key : " $TenantAccessKey

	SinkInstanceCreateCall="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sinkinstances"
	
	TenantId=$1
    	SinkInstanceOutput=$(curl -o ${WORKSPACE}sanity/adw/SinkInstance.txt -w '%{http_code}' -X POST ${SinkInstanceCreateCall} -d '{
  "tenantId": '"${TenantId}"',
  "name": "FTPSink",
  "versionTS": 1617782336314,
  "description": "CSV Sink for FTP",
  "active": true,
  "lastModifiedBy": "mcps",
  "createdBy": "mcps",
  "createdTS": 1615357203381,
  "componentDefinitionId": "FTPSink",
  "uniqueInstanceId": "FTPCSVSink",
  "parameters": {
    "referenceName": "FTPCSVSink",
    "path": "sftp://alex@100.104.146.182/home/alex/data/mcps/SanityADW/export",
    "fileFormat": "json",
    "isConcurrent": "FALSE",
    "fileCompressionFormat": "none",
    "fileDateFormat": "yyyy-MM-dd hh-mm-ss",
    "pem": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAKCAQEAv3m59IwCnl+6Vt71lgjX1QNTC8/7OPKGRu4rGcAgkKXUa97g\n4jgFJcaclggiKAz3rSRQ0hxSt2GO2tjGVmmOYdovi6vE5zSQyv4tg6lsK4MTOYy5\n2VwnTUxoaF3m3Nv0aCrur3N9Y2k5BpfFthVoeTTsY/NXowqZxfzrtmmpGtViOcxM\nS1H/3sUyjPK6jyOy19UJb2HsCh2LBDaUA6ufNi9hmnuPHOharmFDpf3DMaBwIsG5\nXKTqdDiWrFLzA90EnECF0m4lnxiHUcZLmljImteG73xt7Y9EBUE6H000M4EG2Tt0\nEamA5a35muzpkHUx4YfFI7dgzcC/XI/UfVyqowIDAQABAoIBAQClH09a8icL9xfV\n9J6rTWL7wssqQ6itmpBruNaYdVRgCXIfuGwNCix+QEInLEpwaYZp3QiJuX0nwc0V\nM54PRSZRgnxAIdhDXtSDCiGsCj5LY9T/azmWld8azQq4/kmqK1EhR+zgh2MZiNNx\nuQ76kImxBQ/avi7UXr7vu8Z2X7ZCeUYsQVHfxPEeheT2Jcs0A5NMNAlvYgvxrAY8\n5pGt9K61Q12E6U0+44fQ8fQ6X7gr6B7y7ILlR+FNldB/8vxjl4k1ZShM0LefP/ip\nwAY1fWavxbD4EBelSiU2uEcVgAFai5uZh/dz+Xgx5ln9crmrwjBxwp+axpvN4r0R\n9KYVTsLBAoGBAOLIbrfLL1AKzRoiYLEeDeuqqWH1X/E+Zu/hWLbGgECe+iDNNaKk\nwmK6oivhDrYf2TmFebq1QBHY7+6U+T1ZodKQNEQb+eEkRKNPBFUKVS3bdoApqurL\nQ8Lr3zyugkD08VnYfh1dquHHo2+3EuuiY1K6ROdUASy45c+9EheegcUDAoGBANgk\n0BoE+xJElrmEJ6FVg6tkj8YZcXz25hTNR9F3+J8K8HHer47cCnPYCQwJPZU9g8gc\nG7WlhQo58kyYGjdviXDeWNOckT73qBN9zSpAjGE608ozCT3J1k2I4H1EaB6ICBzq\nVDz6zm4lY+dgqWXQe6fBpxUaPtmgn3ndE7ewWIHhAoGBAMCo/kZt+xfI1U2qfvJ5\nUeIv7g4mYweTt+d6Td+Y60P6ywwqybIOvoUZgMQ+Qj0++VAAsNWJPZDr94l8TfFs\nwCkeEQj7q2E1aopCiq+kQ5DdrOJcg7NMU5i4wcHPjyCX9qIZZaqU9KMy8wnpQc2k\n+zRAwmCz4PuZaML/IOun4R75AoGBAMOlfuEuhP1iLHS8lQrKVyb7HdEZEsskydsm\nfc2zpM6BnmfURGEx+Bwn/vhwHNhMGE84cjSYILbDAPon7AMl6OjLuufBHxA6KF+M\nTfvi9a7FCxRJ4iGV42/HaDy7gOuyAnX5/ko8VEMLgUTdEDji4CtXdR/6480mQXST\nkteAvnzBAoGABH+t2TQbDhEIz0reNvKZlVhk61EdJjYgB7GEZaAO/5MoSrIZDjcv\n94FJDbbXqFpwM8c27YojSqO2Z03wgdD2xFy+DMCVz88FAFeNurizbPUdn6QaExWn\nDS2wrdlqpCWh/NcbvQkJ43ZSsbbSGqTc3CArFnHmnGLU3RyaMHmT+d0=\n-----END RSA PRIVATE KEY-----"
                }
}' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM" -H "Content-Type: application/json")

    	echo "Sink Instance Status Code : " $SinkInstanceOutput


	if [ $SinkInstanceOutput -eq 201 ]; then
		echo "Sink Instance created successfully with status code :" $SinkInstanceOutput
	else
		ExitCode=$?
		echo "Sink Instance not created successfully.."
		ValidateCommmand
	fi
}

IngestFlow()
{

        echo "Creating Ingest Job...."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${WORKSPACE}sanity/adw/TenantDetails.txt)
	
	TenantId=$1

        IngestJobCreate="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs"
        
	IngestJobCreateOutput=$(curl -o ${WORKSPACE}sanity/adw/IngestCreate.txt -w '%{http_code}' -X POST ${IngestJobCreate} -d '{
  "tenantId": '"${TenantId}"',
  "name": "Batch_Ingest_Test",
  "versionTS": 1614324857721,
  "description": "Test IngestBatchCSV",
  "active": true,
  "lastModifiedBy": "mcps",
  "createdBy": "mcps",
  "createdTS": 1614319834153,
  "jobId": "IngestSanityCheck",
  "jobData": {
    "ctype": ".IngestJobData",
    "templateInfo": {
      "workflowComponents": [
        {
          "left": "SOURCE",
          "right": "SanityCheckPostDeployment1"
        }
      ]
    },
    "mapping": {
      "SanityCheckPostDeployment1": {
        "mapping": [
          [
            {
              "table": "Currency",
              "column": "BaseCurrency"
            },
            [
              {
                "table": "Currency",
                "column": "BaseCurrency"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "RegularPrice"
            },
            [
              {
                "table": "Product",
                "column": "RegularPrice"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Subscription",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceUserID"
            },
            [
              {
                "table": "Event",
                "column": "SourceUserID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level4CategoryID"
            },
            [
              {
                "table": "Category",
                "column": "Level4CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ExchangeDate"
            },
            [
              {
                "table": "Currency",
                "column": "ExchangeDate"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "TenantID"
            },
            [
              {
                "table": "Product_Category",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Product",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "DisplayName"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "DisplayName"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "Type"
            },
            [
              {
                "table": "Campaign",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Age"
            },
            [
              {
                "table": "Customer",
                "column": "Age"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Type"
            },
            [
              {
                "table": "OrderItem",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CampaignID"
            },
            [
              {
                "table": "Event",
                "column": "CampaignID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "TenantID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Associate",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "CustomerID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Event",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Size"
            },
            [
              {
                "table": "Product",
                "column": "Size"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "State"
            },
            [
              {
                "table": "Address",
                "column": "State"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "State"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "State"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Event",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CompanyName"
            },
            [
              {
                "table": "Address",
                "column": "CompanyName"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "Type"
            },
            [
              {
                "table": "Promotion",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceMessageID"
            },
            [
              {
                "table": "Event",
                "column": "SourceMessageID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Cookie"
            },
            [
              {
                "table": "Event",
                "column": "Cookie"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "PromoCodes"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "PromoCodes"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ActivityTS"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "ActivityTS"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "ProductID"
            },
            [
              {
                "table": "Product_Category",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Address",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "CancelTS"
            },
            [
              {
                "table": "Subscription",
                "column": "CancelTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "SourceID"
            },
            [
              {
                "table": "Organization",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourcePushID"
            },
            [
              {
                "table": "Event",
                "column": "SourcePushID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceListID"
            },
            [
              {
                "table": "Event",
                "column": "SourceListID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CampaignCreatedTS"
            },
            [
              {
                "table": "Event",
                "column": "CampaignCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "CustomerID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Tax"
            },
            [
              {
                "table": "OrderItem",
                "column": "Tax"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "ModifiedDateTS"
            },
            [
              {
                "table": "Customer",
                "column": "ModifiedDateTS"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "TenantID"
            },
            [
              {
                "table": "Group",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "TenantID"
            },
            [
              {
                "table": "Category",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Subscription",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "Role"
            },
            [
              {
                "table": "Associate",
                "column": "Role"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceSocialEngagementID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Organization",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "Status"
            },
            [
              {
                "table": "Launch",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MobileKeyword"
            },
            [
              {
                "table": "Event",
                "column": "MobileKeyword"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Territory"
            },
            [
              {
                "table": "Organization",
                "column": "Territory"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Event",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceLaunchID"
            },
            [
              {
                "table": "Event",
                "column": "SourceLaunchID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceShippingAddressID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceShippingAddressID"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Subscription",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Product",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "TaxTotal"
            },
            [
              {
                "table": "Order",
                "column": "TaxTotal"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "UnitPrice"
            },
            [
              {
                "table": "OrderItem",
                "column": "UnitPrice"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SubType"
            },
            [
              {
                "table": "Event",
                "column": "SubType"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "ID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "SourceSocialIdentityID"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "OrderEntryTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "OrderEntryTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "Country"
            },
            [
              {
                "table": "Address",
                "column": "Country"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "LaunchTS"
            },
            [
              {
                "table": "Event",
                "column": "LaunchTS"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "Name"
            },
            [
              {
                "table": "Subscription",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "SourceCampaignID"
            },
            [
              {
                "table": "Launch",
                "column": "SourceCampaignID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Category",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "OrderItem",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "ID"
            },
            [
              {
                "table": "Product_Category",
                "column": "SourceProduct_CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Order",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "Status"
            },
            [
              {
                "table": "Order",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Launch",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Title"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Title"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Address",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "SourceID"
            },
            [
              {
                "table": "Campaign",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ProductID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "EndDate"
            },
            [
              {
                "table": "Campaign",
                "column": "EndDate"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "SourceID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ExtendedPrice"
            },
            [
              {
                "table": "OrderItem",
                "column": "ExtendedPrice"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Color"
            },
            [
              {
                "table": "Product",
                "column": "Color"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "ParentOrganization"
            },
            [
              {
                "table": "Organization",
                "column": "ParentOrganization"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Cost"
            },
            [
              {
                "table": "OrderItem",
                "column": "Cost"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "OrderTotal"
            },
            [
              {
                "table": "Event",
                "column": "OrderTotal"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "SourceID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Group",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Currency",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ID"
            },
            [
              {
                "table": "Currency",
                "column": "SourceCurrencyID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "OrderID"
            },
            [
              {
                "table": "Event",
                "column": "OrderID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Customer_Group",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "AlternatePhones"
            },
            [
              {
                "table": "Customer",
                "column": "AlternatePhones"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceOrderID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceOrderID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "ID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceIncidentID"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceOrderLineItemID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceOrderItemID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "ID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "SourceCustomer_GroupID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "IsConverted"
            },
            [
              {
                "table": "Event",
                "column": "IsConverted"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Source"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Source"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SubscriptionID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SubscriptionID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Incident",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "Country"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "Country"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Incident",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Product_Category",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "EventTS"
            },
            [
              {
                "table": "Event",
                "column": "EventTS"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "ID"
            },
            [
              {
                "table": "Category",
                "column": "SourceCategoryID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Order",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "SalePrice"
            },
            [
              {
                "table": "Product",
                "column": "SalePrice"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level2CategoryID"
            },
            [
              {
                "table": "Category",
                "column": "Level2CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Launch",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Event",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Associate",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Launch",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MobileCode"
            },
            [
              {
                "table": "Event",
                "column": "MobileCode"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "CostTotal"
            },
            [
              {
                "table": "Order",
                "column": "CostTotal"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceEventID"
            },
            [
              {
                "table": "Event",
                "column": "SourceEventID"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "Name"
            },
            [
              {
                "table": "Message",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Brand"
            },
            [
              {
                "table": "Product",
                "column": "Brand"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "AssociateID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "AssociateID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "IsActive"
            },
            [
              {
                "table": "Event",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceProgramID"
            },
            [
              {
                "table": "Event",
                "column": "SourceProgramID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "CreatedTS"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "TenantID"
            },
            [
              {
                "table": "Subscription",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Message",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Associate",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "SourceMessageID"
            },
            [
              {
                "table": "Message",
                "column": "SourceMessageID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "okToCall"
            },
            [
              {
                "table": "Customer",
                "column": "okToCall"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Subscription",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "SourceCampaignID"
            },
            [
              {
                "table": "Campaign",
                "column": "SourceCampaignID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "ID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "OriginalPrice"
            },
            [
              {
                "table": "OrderItem",
                "column": "OriginalPrice"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "OriginalChannel"
            },
            [
              {
                "table": "Customer",
                "column": "OriginalChannel"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "OrderLevelDiscount"
            },
            [
              {
                "table": "OrderItem",
                "column": "OrderLevelDiscount"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "TenantID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "Description"
            },
            [
              {
                "table": "Address",
                "column": "Description"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Product_Category",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "SubDistrict"
            },
            [
              {
                "table": "Organization",
                "column": "SubDistrict"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Address",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "TenantID"
            },
            [
              {
                "table": "Currency",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Customer",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Promotion",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Campaign",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "ID"
            },
            [
              {
                "table": "Associate",
                "column": "SourceAssociateID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MobileNumber"
            },
            [
              {
                "table": "Event",
                "column": "MobileNumber"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Name"
            },
            [
              {
                "table": "Organization",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "SourceLaunchID"
            },
            [
              {
                "table": "Message",
                "column": "SourceLaunchID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CountryCode_ISOAlpha3"
            },
            [
              {
                "table": "Address",
                "column": "CountryCode_ISOAlpha3"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CountryCode_ISOAlpha2"
            },
            [
              {
                "table": "Address",
                "column": "CountryCode_ISOAlpha2"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Name"
            },
            [
              {
                "table": "Category",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Quantity"
            },
            [
              {
                "table": "Event",
                "column": "Quantity"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "CampaignID"
            },
            [
              {
                "table": "Message",
                "column": "CampaignID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Properties"
            },
            [
              {
                "table": "Customer",
                "column": "Properties"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MobileCarrier"
            },
            [
              {
                "table": "Event",
                "column": "MobileCarrier"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Type"
            },
            [
              {
                "table": "Product",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Incident",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "District"
            },
            [
              {
                "table": "Organization",
                "column": "District"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "PaymentType"
            },
            [
              {
                "table": "OrderItem",
                "column": "PaymentType"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceOwnerID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceOwnerID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Campaign",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Event",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Incident",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_NCOA_MoveType"
            },
            [
              {
                "table": "Address",
                "column": "AV_NCOA_MoveType"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "MiddleName"
            },
            [
              {
                "table": "Customer",
                "column": "MiddleName"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "TargetName"
            },
            [
              {
                "table": "Promotion",
                "column": "TargetName"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "IsActive"
            },
            [
              {
                "table": "Customer",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Promotion",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "SourcePromotionID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourcePromotionID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "TenantID"
            },
            [
              {
                "table": "Incident",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "SourceID"
            },
            [
              {
                "table": "Launch",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Handle"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Handle"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Address",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "FirstName"
            },
            [
              {
                "table": "Customer",
                "column": "FirstName"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "CustomerID"
            },
            [
              {
                "table": "Subscription",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "CouponCode"
            },
            [
              {
                "table": "Promotion",
                "column": "CouponCode"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Product",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "Handle"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "Handle"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Message",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_DPV"
            },
            [
              {
                "table": "Address",
                "column": "AV_DPV"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Award"
            },
            [
              {
                "table": "OrderItem",
                "column": "Award"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Status"
            },
            [
              {
                "table": "Customer",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Browser"
            },
            [
              {
                "table": "Event",
                "column": "Browser"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "BirthMonth"
            },
            [
              {
                "table": "Customer",
                "column": "BirthMonth"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Cookie"
            },
            [
              {
                "table": "Customer",
                "column": "Cookie"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Zone"
            },
            [
              {
                "table": "Organization",
                "column": "Zone"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CustomerID"
            },
            [
              {
                "table": "Event",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourceProductID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "Name"
            },
            [
              {
                "table": "Group",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Sentiment"
            },
            [
              {
                "table": "Incident",
                "column": "Sentiment"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "ID"
            },
            [
              {
                "table": "Order",
                "column": "SourceOrderID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Comment"
            },
            [
              {
                "table": "OrderItem",
                "column": "Comment"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Description"
            },
            [
              {
                "table": "Organization",
                "column": "Description"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourceSocialEngagementID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceSocialEngagementID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "DiscountTotal"
            },
            [
              {
                "table": "Order",
                "column": "DiscountTotal"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "ID"
            },
            [
              {
                "table": "Message",
                "column": "SourceMessageID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "LastName"
            },
            [
              {
                "table": "Customer",
                "column": "LastName"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "ID"
            },
            [
              {
                "table": "Product",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Campaign",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SocialIdentityID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SocialIdentityID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Group",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "County"
            },
            [
              {
                "table": "Address",
                "column": "County"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SourceSignUpOrganizationID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceSignUpOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "ListName"
            },
            [
              {
                "table": "Campaign",
                "column": "ListName"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "CurrencyCode"
            },
            [
              {
                "table": "OrderItem",
                "column": "CurrencyCode"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "TenantID"
            },
            [
              {
                "table": "Associate",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ExchangeRate"
            },
            [
              {
                "table": "Currency",
                "column": "ExchangeRate"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "Medium"
            },
            [
              {
                "table": "Campaign",
                "column": "Medium"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Type"
            },
            [
              {
                "table": "Event",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "Subject"
            },
            [
              {
                "table": "Message",
                "column": "Subject"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceIncidentID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceIncidentID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceID"
            },
            [
              {
                "table": "Event",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "BrowserType"
            },
            [
              {
                "table": "Event",
                "column": "BrowserType"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "SourceOrderID"
            },
            [
              {
                "table": "Order",
                "column": "SourceOrderID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Target"
            },
            [
              {
                "table": "Event",
                "column": "Target"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Customer",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "SourceGroupID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "SourceGroupID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "TenantID"
            },
            [
              {
                "table": "Order",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourcePromotionID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourcePromotionID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "CreatedTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Hashtags"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Hashtags"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "UPC"
            },
            [
              {
                "table": "Product",
                "column": "UPC"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "SourceID"
            },
            [
              {
                "table": "Group",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "PromoID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "PromoID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Status"
            },
            [
              {
                "table": "Organization",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourceSocialIdentityID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceSocialIdentityID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "IsDefaultAddress"
            },
            [
              {
                "table": "Address",
                "column": "IsDefaultAddress"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "ProductID"
            },
            [
              {
                "table": "Subscription",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Email"
            },
            [
              {
                "table": "Customer",
                "column": "Email"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Category",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "SourceGeoDemographicsID"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "SourceGeoDemographicsID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Order",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "SKU"
            },
            [
              {
                "table": "Product",
                "column": "SKU"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "CustomerID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_IsMailReturn"
            },
            [
              {
                "table": "Address",
                "column": "AV_IsMailReturn"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "Type"
            },
            [
              {
                "table": "Group",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Product_Category",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "CustomerID"
            },
            [
              {
                "table": "Incident",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Associate",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Organization",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Weight"
            },
            [
              {
                "table": "Product",
                "column": "Weight"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceProductID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "Duration"
            },
            [
              {
                "table": "Subscription",
                "column": "Duration"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Organization",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level1CategoryID"
            },
            [
              {
                "table": "Category",
                "column": "Level1CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "Name"
            },
            [
              {
                "table": "Promotion",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Incident",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Currency",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "SourceID"
            },
            [
              {
                "table": "Subscription",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "OrganizationID"
            },
            [
              {
                "table": "OrderItem",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceOrderID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceOrderID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "Longitude"
            },
            [
              {
                "table": "Address",
                "column": "Longitude"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Subscription",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_DPVDesc"
            },
            [
              {
                "table": "Address",
                "column": "AV_DPVDesc"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "TenantID"
            },
            [
              {
                "table": "Message",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "ProductID"
            },
            [
              {
                "table": "Promotion",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "okToMail"
            },
            [
              {
                "table": "Customer",
                "column": "okToMail"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "AlternateEmails"
            },
            [
              {
                "table": "Customer",
                "column": "AlternateEmails"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "WeightUnit"
            },
            [
              {
                "table": "Product",
                "column": "WeightUnit"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Launch",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "PromotionID"
            },
            [
              {
                "table": "Message",
                "column": "PromotionID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SalesChannel"
            },
            [
              {
                "table": "OrderItem",
                "column": "SalesChannel"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Suffix"
            },
            [
              {
                "table": "Customer",
                "column": "Suffix"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Carrier"
            },
            [
              {
                "table": "OrderItem",
                "column": "Carrier"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Event",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "ID"
            },
            [
              {
                "table": "Address",
                "column": "SourceAddressID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Inventory"
            },
            [
              {
                "table": "Product",
                "column": "Inventory"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceBillingAddressID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceBillingAddressID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Type"
            },
            [
              {
                "table": "Organization",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Type"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "TenantID"
            },
            [
              {
                "table": "Campaign",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Associate",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_TimeZone"
            },
            [
              {
                "table": "Address",
                "column": "AV_TimeZone"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "IsAuthor"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "IsAuthor"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Product",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CategoryID"
            },
            [
              {
                "table": "Event",
                "column": "CategoryID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "SourceID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "CurrencyID"
            },
            [
              {
                "table": "OrderItem",
                "column": "CurrencyID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Promotion",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "SourceID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "CreatedTS"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Customer_Group",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Order",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ForeignCurrency"
            },
            [
              {
                "table": "Currency",
                "column": "ForeignCurrency"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "CreatedBy"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "AssociateID"
            },
            [
              {
                "table": "OrderItem",
                "column": "AssociateID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ProductID"
            },
            [
              {
                "table": "OrderItem",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Address",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "ProductID"
            },
            [
              {
                "table": "Event",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Subscription",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Description"
            },
            [
              {
                "table": "Product",
                "column": "Description"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "TenantID"
            },
            [
              {
                "table": "Address",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Product",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "Currency"
            },
            [
              {
                "table": "Order",
                "column": "Currency"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "okToText"
            },
            [
              {
                "table": "Customer",
                "column": "okToText"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Product_Category",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "ID"
            },
            [
              {
                "table": "Campaign",
                "column": "SourceCampaignID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "BillingAddressID"
            },
            [
              {
                "table": "OrderItem",
                "column": "BillingAddressID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_IsAddressChanged"
            },
            [
              {
                "table": "Address",
                "column": "AV_IsAddressChanged"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Currency",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Event",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "OwnerID"
            },
            [
              {
                "table": "Incident",
                "column": "OwnerID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceCategoryID"
            },
            [
              {
                "table": "Event",
                "column": "SourceCategoryID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "AccountID"
            },
            [
              {
                "table": "OrderItem",
                "column": "AccountID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Discount"
            },
            [
              {
                "table": "OrderItem",
                "column": "Discount"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "LoyaltyNumber"
            },
            [
              {
                "table": "Customer",
                "column": "LoyaltyNumber"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Customer_Group",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level3Name"
            },
            [
              {
                "table": "Category",
                "column": "Level3Name"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Promotion",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "ID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourcePromotionID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "CustomerID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "SourceSubscriptionID"
            },
            [
              {
                "table": "Subscription",
                "column": "SourceSubscriptionID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "okToEmail"
            },
            [
              {
                "table": "Customer",
                "column": "okToEmail"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "City"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "City"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SpamType"
            },
            [
              {
                "table": "Event",
                "column": "SpamType"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CommerceAddressType"
            },
            [
              {
                "table": "Address",
                "column": "CommerceAddressType"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Status"
            },
            [
              {
                "table": "Event",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Customer",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Campaign",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "City"
            },
            [
              {
                "table": "Address",
                "column": "City"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Message",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "ID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceCustomer_AssociateID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "TargetName"
            },
            [
              {
                "table": "Event",
                "column": "TargetName"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "Name"
            },
            [
              {
                "table": "Associate",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "TenantID"
            },
            [
              {
                "table": "Launch",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceOrderItemID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SignUpOrganizationID"
            },
            [
              {
                "table": "Customer",
                "column": "SignUpOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Category"
            },
            [
              {
                "table": "Incident",
                "column": "Category"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Subscription",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "TenantID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Category",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Event",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_IsValid"
            },
            [
              {
                "table": "Address",
                "column": "AV_IsValid"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "CustomerID"
            },
            [
              {
                "table": "OrderItem",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "SourceCategoryID"
            },
            [
              {
                "table": "Category",
                "column": "SourceCategoryID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "ImageURLs"
            },
            [
              {
                "table": "Product",
                "column": "ImageURLs"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourcePromotionID"
            },
            [
              {
                "table": "Event",
                "column": "SourcePromotionID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Organization",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "Team"
            },
            [
              {
                "table": "Associate",
                "column": "Team"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Currency",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "LaunchID"
            },
            [
              {
                "table": "Message",
                "column": "LaunchID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "Sentiments"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "Sentiments"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "SourceCampaignID"
            },
            [
              {
                "table": "Message",
                "column": "SourceCampaignID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Type"
            },
            [
              {
                "table": "Customer",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "RegistrationTS"
            },
            [
              {
                "table": "Customer",
                "column": "RegistrationTS"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SourceID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Message",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "SourceProgramID"
            },
            [
              {
                "table": "Launch",
                "column": "SourceProgramID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Promotion",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Order",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "SubTotal"
            },
            [
              {
                "table": "Order",
                "column": "SubTotal"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "SourceID"
            },
            [
              {
                "table": "Associate",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SubType"
            },
            [
              {
                "table": "OrderItem",
                "column": "SubType"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "ID"
            },
            [
              {
                "table": "Launch",
                "column": "SourceLaunchID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "CompletedTS"
            },
            [
              {
                "table": "Order",
                "column": "CompletedTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "TenantID"
            },
            [
              {
                "table": "OrderItem",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Order",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceAccountID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceAccountID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceCampaignID"
            },
            [
              {
                "table": "Event",
                "column": "SourceCampaignID"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "CampaignID"
            },
            [
              {
                "table": "Launch",
                "column": "CampaignID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Email"
            },
            [
              {
                "table": "Event",
                "column": "Email"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level4Name"
            },
            [
              {
                "table": "Category",
                "column": "Level4Name"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Event",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CustomerID"
            },
            [
              {
                "table": "Address",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "URL"
            },
            [
              {
                "table": "Product",
                "column": "URL"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "ID"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "SourceGeoDemographicsID"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Category",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Content"
            },
            [
              {
                "table": "Event",
                "column": "Content"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Group",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "OpenedTS"
            },
            [
              {
                "table": "Incident",
                "column": "OpenedTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "TenantID"
            },
            [
              {
                "table": "Product",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Organization",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Incident",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "AssociateID"
            },
            [
              {
                "table": "Customer",
                "column": "AssociateID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SourceAssociateID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceAssociateID"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Currency",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Customer_Group",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Product_Category",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "Content"
            },
            [
              {
                "table": "Message",
                "column": "Content"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "SourceCategoryID"
            },
            [
              {
                "table": "Product_Category",
                "column": "SourceCategoryID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Source"
            },
            [
              {
                "table": "Event",
                "column": "Source"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Associate",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Launch",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Product_Category",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "SourceProduct_CategoryID"
            },
            [
              {
                "table": "Product_Category",
                "column": "SourceProduct_CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Description"
            },
            [
              {
                "table": "Incident",
                "column": "Description"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ShippingRevenue"
            },
            [
              {
                "table": "OrderItem",
                "column": "ShippingRevenue"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "Longitude"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "Longitude"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "SourceCustomer_GroupID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "SourceCustomer_GroupID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "SourceAssociateID"
            },
            [
              {
                "table": "Associate",
                "column": "SourceAssociateID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Model"
            },
            [
              {
                "table": "Product",
                "column": "Model"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "OrderItemID"
            },
            [
              {
                "table": "Event",
                "column": "OrderItemID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Associate",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "LaunchID"
            },
            [
              {
                "table": "Event",
                "column": "LaunchID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "okToNotify"
            },
            [
              {
                "table": "Customer",
                "column": "okToNotify"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "Total"
            },
            [
              {
                "table": "Order",
                "column": "Total"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "SourceAccountID"
            },
            [
              {
                "table": "Address",
                "column": "SourceAccountID"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "SourceLaunchID"
            },
            [
              {
                "table": "Launch",
                "column": "SourceLaunchID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "OrderID"
            },
            [
              {
                "table": "OrderItem",
                "column": "OrderID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "CreatedBy"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Category",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Message",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "SourceGroupID"
            },
            [
              {
                "table": "Group",
                "column": "SourceGroupID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AccountID"
            },
            [
              {
                "table": "Address",
                "column": "AccountID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Group",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level3CategoryID"
            },
            [
              {
                "table": "Category",
                "column": "Level3CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "SourceID"
            },
            [
              {
                "table": "Product_Category",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "BirthYear"
            },
            [
              {
                "table": "Customer",
                "column": "BirthYear"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "UserAgent"
            },
            [
              {
                "table": "Event",
                "column": "UserAgent"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Quantity"
            },
            [
              {
                "table": "OrderItem",
                "column": "Quantity"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Order",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "Source"
            },
            [
              {
                "table": "Campaign",
                "column": "Source"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Subscription",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "TenantID"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "IsActive"
            },
            [
              {
                "table": "Promotion",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceProductID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceProductID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "CountryCode"
            },
            [
              {
                "table": "Event",
                "column": "CountryCode"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "CustomerID"
            },
            [
              {
                "table": "Promotion",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "AwardTotal"
            },
            [
              {
                "table": "Order",
                "column": "AwardTotal"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourcePromoID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourcePromoID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "Type"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Address",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Region"
            },
            [
              {
                "table": "Organization",
                "column": "Region"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourceID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_NCOA_MoveDate"
            },
            [
              {
                "table": "Address",
                "column": "AV_NCOA_MoveDate"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "IsActive"
            },
            [
              {
                "table": "Campaign",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "Latitude"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "Latitude"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "Latitude"
            },
            [
              {
                "table": "Address",
                "column": "Latitude"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "Name"
            },
            [
              {
                "table": "Currency",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SourceAccountID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceAccountID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "CustomerID"
            },
            [
              {
                "table": "Order",
                "column": "CustomerID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "OrderID"
            },
            [
              {
                "table": "Incident",
                "column": "OrderID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "IsActive"
            },
            [
              {
                "table": "Associate",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "SourceAssociateID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceAssociateID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "StartTS"
            },
            [
              {
                "table": "Promotion",
                "column": "StartTS"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "ID"
            },
            [
              {
                "table": "Subscription",
                "column": "SourceSubscriptionID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "IsActive"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "IsActive"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ShipTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "ShipTS"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "Name"
            },
            [
              {
                "table": "Launch",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "ReactionCounts"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "ReactionCounts"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "CreatedDateTS"
            },
            [
              {
                "table": "Customer",
                "column": "CreatedDateTS"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "Type"
            },
            [
              {
                "table": "Subscription",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "BirthDate_Date"
            },
            [
              {
                "table": "Customer",
                "column": "BirthDate"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "StatusReason"
            },
            [
              {
                "table": "Event",
                "column": "StatusReason"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MessageSentTS"
            },
            [
              {
                "table": "Event",
                "column": "MessageSentTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "SourceId"
            },
            [
              {
                "table": "Message",
                "column": "SourceId"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Promotion",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "TenantID"
            },
            [
              {
                "table": "Organization",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Available"
            },
            [
              {
                "table": "Product",
                "column": "Available"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Event",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "Name"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Organization",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "ID"
            },
            [
              {
                "table": "Event",
                "column": "SourceEventID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Address",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "CategoryID"
            },
            [
              {
                "table": "Product_Category",
                "column": "CategoryID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "SourceID"
            },
            [
              {
                "table": "Address",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "ProductID"
            },
            [
              {
                "table": "Incident",
                "column": "ProductID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "Type"
            },
            [
              {
                "table": "Order",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Product",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Prefix"
            },
            [
              {
                "table": "Customer",
                "column": "Prefix"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level1Name"
            },
            [
              {
                "table": "Category",
                "column": "Level1Name"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "SourceID"
            },
            [
              {
                "table": "Category",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Campaign",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceAppID"
            },
            [
              {
                "table": "Event",
                "column": "SourceAppID"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Message",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "Division"
            },
            [
              {
                "table": "Organization",
                "column": "Division"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AddressLine2"
            },
            [
              {
                "table": "Address",
                "column": "AddressLine2"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AddressLine1"
            },
            [
              {
                "table": "Address",
                "column": "AddressLine1"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Complaint"
            },
            [
              {
                "table": "Event",
                "column": "Complaint"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Category",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceSubscriptionID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceSubscriptionID"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "SourceListID"
            },
            [
              {
                "table": "Campaign",
                "column": "SourceListID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "Region"
            },
            [
              {
                "table": "Associate",
                "column": "Region"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "SourceCustomer_AssociateID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceCustomer_AssociateID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Group",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "SubType"
            },
            [
              {
                "table": "Organization",
                "column": "SubType"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Promotion",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "SourceSocialIdentityID"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "SourceSocialIdentityID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "URL"
            },
            [
              {
                "table": "Event",
                "column": "URL"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "ID"
            },
            [
              {
                "table": "Organization",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Severity"
            },
            [
              {
                "table": "Incident",
                "column": "Severity"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "ZipCode"
            },
            [
              {
                "table": "Address",
                "column": "ZipCode"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "TenantID"
            },
            [
              {
                "table": "Customer",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "OrderEntryTS"
            },
            [
              {
                "table": "Order",
                "column": "OrderEntryTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Order",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "SourceOrderID"
            },
            [
              {
                "table": "Event",
                "column": "SourceOrderID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Associate",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Customer_Associate",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Status"
            },
            [
              {
                "table": "OrderItem",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "PlatformType"
            },
            [
              {
                "table": "Event",
                "column": "PlatformType"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Status"
            },
            [
              {
                "table": "Incident",
                "column": "Status"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Channel"
            },
            [
              {
                "table": "Incident",
                "column": "Channel"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "TargetType"
            },
            [
              {
                "table": "OrderItem",
                "column": "TargetType"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "AccountID"
            },
            [
              {
                "table": "Customer",
                "column": "AccountID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "CreatedBy"
            },
            [
              {
                "table": "OrderItem",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "TargetName"
            },
            [
              {
                "table": "Campaign",
                "column": "TargetName"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "PromotionID"
            },
            [
              {
                "table": "OrderItem",
                "column": "PromotionID"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Promotion",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "GroupID"
            },
            [
              {
                "table": "Customer_Group",
                "column": "GroupID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Incident",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "Medium"
            },
            [
              {
                "table": "Event",
                "column": "Medium"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "PrimaryLanguage"
            },
            [
              {
                "table": "Customer",
                "column": "PrimaryLanguage"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "EmailFrequency"
            },
            [
              {
                "table": "Customer",
                "column": "EmailFrequency"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "TenantID"
            },
            [
              {
                "table": "Event",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Summary"
            },
            [
              {
                "table": "Incident",
                "column": "Summary"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "TenantID"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Incident",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ShippingCost"
            },
            [
              {
                "table": "OrderItem",
                "column": "ShippingCost"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "ApartmentNo"
            },
            [
              {
                "table": "Address",
                "column": "ApartmentNo"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "PromotionID"
            },
            [
              {
                "table": "Event",
                "column": "PromotionID"
              }
            ]
          ],
          [
            {
              "table": "Organization",
              "column": "ModifiedTS"
            },
            [
              {
                "table": "Organization",
                "column": "ModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "StartDate"
            },
            [
              {
                "table": "Campaign",
                "column": "StartDate"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "ResolvedTS"
            },
            [
              {
                "table": "Incident",
                "column": "ResolvedTS"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Product_Category",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "ExecutionTS"
            },
            [
              {
                "table": "Launch",
                "column": "ExecutionTS"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "OrganizationID"
            },
            [
              {
                "table": "Order",
                "column": "OrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Customer_Group",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer_Group",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Customer_Group",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "SocialEngagement",
              "column": "URL"
            },
            [
              {
                "table": "SocialEngagement",
                "column": "URL"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "Name"
            },
            [
              {
                "table": "Campaign",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "SourceID"
            },
            [
              {
                "table": "Order",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Category",
              "column": "Level2Name"
            },
            [
              {
                "table": "Category",
                "column": "Level2Name"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Launch",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Name"
            },
            [
              {
                "table": "Product",
                "column": "Name"
              }
            ]
          ],
          [
            {
              "table": "Incident",
              "column": "Type"
            },
            [
              {
                "table": "Incident",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "SourcePromotionID"
            },
            [
              {
                "table": "Message",
                "column": "SourcePromotionID"
              }
            ]
          ],
          [
            {
              "table": "Associate",
              "column": "CreatedBy"
            },
            [
              {
                "table": "Associate",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "IsGift"
            },
            [
              {
                "table": "OrderItem",
                "column": "IsGift"
              }
            ]
          ],
          [
            {
              "table": "Order",
              "column": "Qty"
            },
            [
              {
                "table": "Order",
                "column": "Qty"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "Period"
            },
            [
              {
                "table": "Subscription",
                "column": "Period"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "SourceCustomerID"
            },
            [
              {
                "table": "Customer",
                "column": "SourceCustomerID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "MobilePhone"
            },
            [
              {
                "table": "Customer",
                "column": "MobilePhone"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "Subtype"
            },
            [
              {
                "table": "Group",
                "column": "Subtype"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "SourceAddressID"
            },
            [
              {
                "table": "Address",
                "column": "SourceAddressID"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "EmailDomain"
            },
            [
              {
                "table": "Event",
                "column": "EmailDomain"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ListPrice"
            },
            [
              {
                "table": "OrderItem",
                "column": "ListPrice"
              }
            ]
          ],
          [
            {
              "table": "Product_Category",
              "column": "Type"
            },
            [
              {
                "table": "Product_Category",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "OperatingSystem"
            },
            [
              {
                "table": "Event",
                "column": "OperatingSystem"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "AV_NCOA_MailTo"
            },
            [
              {
                "table": "Address",
                "column": "AV_NCOA_MailTo"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "ExpirationTS"
            },
            [
              {
                "table": "Promotion",
                "column": "ExpirationTS"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Product",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Event",
              "column": "MessageID"
            },
            [
              {
                "table": "Event",
                "column": "MessageID"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Gender"
            },
            [
              {
                "table": "Customer",
                "column": "Gender"
              }
            ]
          ],
          [
            {
              "table": "Campaign",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Campaign",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "RowCreatedTS"
            },
            [
              {
                "table": "Customer",
                "column": "RowCreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "Group",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "URL"
            },
            [
              {
                "table": "Promotion",
                "column": "URL"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "Type"
            },
            [
              {
                "table": "Address",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Promotion",
              "column": "TenantID"
            },
            [
              {
                "table": "Promotion",
                "column": "TenantID"
              }
            ]
          ],
          [
            {
              "table": "SocialIdentity",
              "column": "CreatedBy"
            },
            [
              {
                "table": "SocialIdentity",
                "column": "CreatedBy"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "RowModifiedTS"
            },
            [
              {
                "table": "OrderItem",
                "column": "RowModifiedTS"
              }
            ]
          ],
          [
            {
              "table": "Launch",
              "column": "Type"
            },
            [
              {
                "table": "Launch",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "CreatedTS"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "CreatedTS"
            },
            [
              {
                "table": "Currency",
                "column": "CreatedTS"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "BirthDay"
            },
            [
              {
                "table": "Customer",
                "column": "BirthDay"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "SourceAssociateID"
            },
            [
              {
                "table": "OrderItem",
                "column": "SourceAssociateID"
              }
            ]
          ],
          [
            {
              "table": "GeoDemographics",
              "column": "SourceID"
            },
            [
              {
                "table": "GeoDemographics",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "ShippingAddressID"
            },
            [
              {
                "table": "OrderItem",
                "column": "ShippingAddressID"
              }
            ]
          ],
          [
            {
              "table": "Group",
              "column": "ID"
            },
            [
              {
                "table": "Group",
                "column": "SourceGroupID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "ModifiedBy"
            },
            [
              {
                "table": "Address",
                "column": "ModifiedBy"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "EndTS"
            },
            [
              {
                "table": "Subscription",
                "column": "EndTS"
              }
            ]
          ],
          [
            {
              "table": "Message",
              "column": "Type"
            },
            [
              {
                "table": "Message",
                "column": "Type"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "GeoDemographicsID"
            },
            [
              {
                "table": "Address",
                "column": "GeoDemographicsID"
              }
            ]
          ],
          [
            {
              "table": "OrderItem",
              "column": "Weight"
            },
            [
              {
                "table": "OrderItem",
                "column": "Weight"
              }
            ]
          ],
          [
            {
              "table": "Customer",
              "column": "Phone"
            },
            [
              {
                "table": "Customer",
                "column": "Phone"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "SourceID"
            },
            [
              {
                "table": "Currency",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "SourceID"
            },
            [
              {
                "table": "Product",
                "column": "SourceID"
              }
            ]
          ],
          [
            {
              "table": "Address",
              "column": "SourceOrganizationID"
            },
            [
              {
                "table": "Address",
                "column": "SourceOrganizationID"
              }
            ]
          ],
          [
            {
              "table": "Product",
              "column": "Group"
            },
            [
              {
                "table": "Product",
                "column": "Group"
              }
            ]
          ],
          [
            {
              "table": "Subscription",
              "column": "StartTS"
            },
            [
              {
                "table": "Subscription",
                "column": "StartTS"
              }
            ]
          ],
          [
            {
              "table": "Currency",
              "column": "SourceCurrencyID"
            },
            [
              {
                "table": "Currency",
                "column": "SourceCurrencyID"
              }
            ]
          ]
        ],
        "transforms": [
          [
            {
              "table": "Customer",
              "column": "Properties"
            },
            {
              "transform": "KEY_VALUE_MAP"
            }
          ]
        ]
      }
    }
  }
}' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM"  -H "Content-type: application/json")



        echo "INGEST Job Create Output :" $IngestJobCreateOutput


        if [ $IngestJobCreateOutput -eq 201 ] ; then
                echo "Ingest Job Created Successfully......"
        else
                ExitCode=$?
                echo "Ingest Job Not created successfullyyy..."
                ValidateCommand
        fi


}


ExportFlow()
{       
        
        echo "##### Creating Export Job for Sanity #######"
        
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${WORKSPACE}sanity/adw/TenantDetails.txt)
        echo $TenantAccessKey
     	TenantId=$1
	   
        ExportJobCreate="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs"
        ExportJobCreateOutput=$(curl -o ${WORKSPACE}sanity/adw/ExportJobCreate.txt -w '%{http_code}' -X POST ${ExportJobCreate} -d '{
  "tenantId": '"${TenantId}"',
  "name": "ExportJobForQuery",
  "versionTS": 1617782395128,
  "active": true,
  "createdTS": 1617780464829,
  "jobId": "C1234567890",
  "jobData": {
    "ctype": ".ExportJobData",
    "templateInfo": {
      "workflowComponents": [
        {
          "left": "SINK",
          "right": "FTPCSVSink"
        }
      ]
    },
    "mcpsQuery": {
      "MCPSQuery": {
        "tenantId": '"${TenantId}"',
        "name": "OMC_SIMPLE_1",
        "versionTS": 1538176987922,
        "active": true,
        "createdTS": 1538176987922,
        "uniqueId": "OMC_SIMPLE_1",
        "operation": {
          "ctype": ".SetOperation",
          "name": "TopOp",
          "tenantId": '"${TenantId}"',
          "uniqueId": "simple1",
          "operands": [
            {
              "ctype": ".ObjectSet",
              "tenantId": '"${TenantId}"',
              "name": "C1",
              "objectName": "Customer",
              "uniqueId": "simple_c1_customer",
              "outputAttributes": [
                {
                  "atype": ".ReferenceAttribute",
                  "tableName": "C1",
                  "attributeName": "ID"
                },
                {
                  "atype": ".ReferenceAttribute",
                  "tableName": "C1",
                  "attributeName": "Gender"
                },
                {
                  "atype": ".ReferenceAttribute",
                  "tableName": "C1",
                  "attributeName": "FirstName"
                },
                {
                  "atype": ".ReferenceAttribute",
                  "tableName": "C1",
                  "attributeName": "Age"
                },
                {
                  "atype": ".ReferenceAttribute",
                  "tableName": "C1",
                  "attributeName": "LastName"
                }
              ],
              "distinct": false
            },
            null
          ],
          "operator": "UNION",
          "distinct": false,
          "outputAttributes": [
            {
              "atype": ".ReferenceAttribute",
              "tableName": "C1",
              "attributeName": "ID"
            },
            {
              "atype": ".ReferenceAttribute",
              "tableName": "C1",
              "attributeName": "Age"
            },
            {
              "atype": ".ReferenceAttribute",
              "tableName": "C1",
              "attributeName": "Gender"
            },
            {
              "atype": ".ReferenceAttribute",
              "tableName": "C1",
              "attributeName": "FirstName"
            },
            {
              "atype": ".ReferenceAttribute",
              "tableName": "C1",
              "attributeName": "LastName"
            }
          ],
          "joinConditions": []
        },
        "type": "DW"
      }
    },
    "exportType": "ALL"
  }
}' -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6cGh4Om91ZHBzbXNlcnZlciIsInN1Yl90eXBlIjoiY2xpZW50Iiwic2NvcGUiOiJ1cm46b2N4Om91ZHBzY29wZTpjbGllbnQiLCJleHAiOjE1OTg5MjI1MTAsImlhdCI6MTU5ODU2MzY2MiwianRpIjoiNWY4MzkwMWMtZjZkYy00NGYxLWJiMGEtYmQ2Y2RmMjliYmRiIn0.JM03enklc-58b0Gu-q8mcWI4gngJB5LV4E0cQAIfOgM"  -H "Content-type: application/json")
                
        echo "Export Job Create Output : "$ExportJobCreateOutput
        
        
        if [ $ExportJobCreateOutput -eq 201 ]; then
                echo "Export Job Created Successfully with Status Code : " $ExportJobCreateOutput
        else    
                ExitCode=$?
                ValidateCommand
        fi

}


echo "#####Checking Tenant Exist or not ######## "
IsTenantExist

echo "############ Tenant Creation ###########..."
CreateTenant ${Id}

echo "############ Source Instance Creation ########....."
CreateSourceInstance ${Id}

echo "########### Sink Instance Creation ##########......."
CreateSinkInstance ${Id}

echo "######### Creating Ingest Job #########"
IngestFlow ${Id}

echo "######### Creating Export Job ##########"
ExportFlow ${Id}


