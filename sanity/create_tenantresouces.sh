#!/bin/sh +x

unset http_proxy
unset https_proxy

IsTenantExist()
{
	while [ true ] 
	do

		RANDOM=$$
		Id=$RANDOM
        echo $Id
		IsObjectExist="http://${Host}:${Port}/api-metadata/v1/metadata/tenants/${Id}"
		echo $IsObjectExist

		IsObjectExistOutput=$(curl -s --keepalive-time 60 -o ${WORKSPACE}/LogIsTenantExists.txt -w '%{http_code}' -X GET ${IsObjectExist} -H "Authorization: Bearer ${Token}"  -H "Content-type: application/json")

		echo $IsObjectExistOutput

		if [ $IsObjectExistOutput -eq 200 ]; then
			echo "Tenant Already Exist with ID : " $Id
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

	echo "Id to create a tenant in ADW QA Env : " $1
	TenantId=$1

	TenantCreateCall="http://${Host}:${Port}/api-metadata/v1/metadata/tenants"
	echo "Creating Tenant : " $TenantCreateCall
        
	TenantCreateOutput=$(curl -s --keepalive-time 60 -o ${TenantDetails}/TenantDetails.txt -w '%{http_code}' -X POST ${TenantCreateCall} -d '{
	"id" : '"${TenantId}"',
	"parentTenantID" : 0,
	"abbreviation" : "testing Jira",
	"displayName" : "Testingtenantsanity"}' -H "Authorization: Bearer '${Token}'"  -H "Content-type: application/json")
	 echo "Tenant Create API Status Code is : " $TenantCreateOutput
	
    

	 if [ $TenantCreateOutput -eq 201 ]; then
     	
		echo "Tenant Creates Successfully..." $TenantCreateOutput
        echo "Tenant ID Details - "
        cat ${TenantDetails}/TenantDetails.txt	
			
	 else
        
		ExitCode=$?
        echo "Tenant Create Failed due to - "
        cat ${TenantDetails}/TenantDetails.txt
		ValidateCommand
	 fi
	

}

CreateSourceInstance()
{
	
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
	echo "Tenant Access Key : " $TenantAccessKey
	SourceInstanceCreateCall="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sourceinstances"
	
    echo "Creating Source Instance : " $SourceInstanceCreateCall
	TenantId=$1
	echo $SourceInstanceCreateCall
        SourceInstanceCreateOutput=$(curl -o ${WORKSPACE}/LogSourceInstance.txt -w '%{http_code}' -X POST ${SourceInstanceCreateCall} -d '{
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
}' -H "Authorization: Bearer '${Token}'"  -H "Content-type: application/json")
	

	echo "SourceInstance Status Code:" $SourceInstanceCreateOutput

	if [ $SourceInstanceCreateOutput -eq 201 ]; then
		echo "Source Instance created successfully with status code :" $SourceInstanceCreateOutput
        echo "Source Instance Details - "
        cat ${WORKSPACE}/LogSourceInstance.txt
        
	else
		ExitCode=$?
		echo "Source Instance Create Failed due to - "
        cat ${WORKSPACE}/LogSourceInstance.txt
		ValidateCommand
	fi
}

CreateSinkInstance()
{
	 
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
    	echo "Tenant Access Key : " $TenantAccessKey

	SinkInstanceCreateCall="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sinkinstances"
	
    echo "Creating Sink Instance : " $SinkInstanceCreateCall
	TenantId=$1
    	SinkInstanceOutput=$(curl -o ${WORKSPACE}/LogSinkInstance.txt -w '%{http_code}' -X POST ${SinkInstanceCreateCall} -d '{
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
}' -H "Authorization: Bearer '${Token}'" -H "Content-Type: application/json")

    	echo "Sink Instance Status Code : " $SinkInstanceOutput

	
	if [ $SinkInstanceOutput -eq 201 ]; then
		echo "Sink Instance created successfully with status code :" $SinkInstanceOutput
        echo "Sink Instance Details - "
        cat ${WORKSPACE}/LogSinkInstance.txt
        
	else
		ExitCode=$?
		echo "Sink Instance Create Failed due to - "
        cat ${WORKSPACE}/LogSinkInstance.txt
		ValidateCommmand
	fi
}

IngestFlow()
{

        echo "Creating Ingest Job...."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
	
		TenantId=$1

        IngestJobCreate="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs"
		echo "Creating Ingestion Job : " $IngestJobCreate
        
        echo "Updating the tenant ID in ingest payload"
        echo "sed -i '' 's/0/${TenantId}/g' ${IngestPayload}/ingest_payload.json"
        sed -i 's/0/'${TenantId}'/g' ${IngestPayload}/ingest_payload.json
        output=$(cat ${IngestPayload}/ingest_payload.json)
        
        
		IngestJobCreateOutput=$(curl -o ${WORKSPACE}/LogIngestCreate.txt -w '%{http_code}' -X POST ${IngestJobCreate}  -d @${IngestPayload}/ingest_payload.json -H "Authorization: Bearer ${Token}"  -H "Content-Type: application/json")

        echo "INGEST Job Create Output :" $IngestJobCreateOutput


        if [ $IngestJobCreateOutput -eq 201 ] ; then
                echo "Ingest Job Created Successfully......"
                echo "Ingest Job Detail - "
                cat ${WORKSPACE}/LogIngestCreate.txt
        else
                ExitCode=$?
                echo "Ingest Job Creat Failed due to - "
                cat ${WORKSPACE}/LogIngestCreate.txt
                ValidateCommand
        fi


}


ExportFlow()
{       
        
        echo "##### Creating Export Job for Sanity #######"
        
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' /home/opc/.jenkins/workspace/ADW_Sanity_TenantDetails/TenantDetails.txt)
        echo $TenantAccessKey
     	TenantId=$1
	   
        ExportJobCreate="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs"
        echo "Creating Export Job : " $ExportJobCreate
        
        ExportJobCreateOutput=$(curl -o ${WORKSPACE}/LogExportJobCreate.txt -w '%{http_code}' -X POST ${ExportJobCreate} -d '{
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
}' -H "Authorization: Bearer '${Token}'"  -H "Content-type: application/json")
                
        echo "Export Job Create Output : "$ExportJobCreateOutput
        
        
        if [ $ExportJobCreateOutput -eq 201 ]; then
                echo "Export Job Created Successfully with Status Code : " $ExportJobCreateOutput
                echo "Export Job Details - "
                cat ${WORKSPACE}/LogExportJobCreate.txt
        else    
                ExitCode=$?
                echo "Export Job Create Failed due to - "
                cat ${WORKSPACE}/LogExportJobCreate.txt
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
