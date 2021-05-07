#!/bin/sh +x


unset http_proxy
unset https_proxy

ValidateCommand()
{
        if [ $ExitCode -eq 0 ]; then
                exit 0
        else
                exit 1
        fi
}

DelSourceInstance()
{
        echo "Getting Tenant Access key....."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)

        DelSourceInstance="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sourceinstances/SanityCheckPostDeployment1"       
        DelSourceInstanceOutput=$(curl -o ${WORKSPACE}/DelSourceInstance.txt -w '%{http_code}' -X DELETE ${DelSourceInstance} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})
        
        echo "DelSource Instance :" $DelSourceInstance
        
        echo "Delete Source Instances with Status Code : " $DelSourceInstanceOutput
        if [ $DelSourceInstanceOutput -eq 204 ]; then
                echo "Source Instance deleted....."
        else
                echo "Source Instance not delete...."
                ExitCode=$?
                ValidateCommand
        fi
}

DelSinkInstance()
{
        echo "Getting Tenant Access key....."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
	
        DelSinkInstance="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/sinkinstances/FTPCSVSink"
        echo "DelSink Instance :" $DelSinkInstance
        DelSinkInstanceOutput=$(curl -w '%{http_code}' -X DELETE ${DelSinkInstance} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

        echo "Delete Sink Instances with Status Code : " $DelSinkInstanceOutput
        if [ $DelSinkInstanceOutput -eq 204 ]; then
                echo "Sink Instance deleted....."
        else
                echo "Sink Instance not delete...."
                ExitCode=$?
                ValidateCommand
        fi
}


DelIngestJob()
{
        echo "Getting Tenant Access key....."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
        
        DelIngestJob="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs/ingest/IngestSanityCheck"
        DelIngestJobOutput=$(curl -w '%{http_code}' -X DELETE ${DelIngestJob} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})
		echo "DelIngest Job : " $DelIngestJob
        
        echo "Delete Ingest Job  with Status Code : " $DelIngestJobOutput
        if [ $DelIngestJobOutput -eq 204 ]; then
                echo "Ingest Instance deleted....."
        else
                echo "Ingest Job not delete...."
                ExitCode=$?
                ValidateCommand
        fi
}


DelExportJob()
{
        echo "Getting Tenant Access key....."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
        
        DelExportJob="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/jobs/export/C1234567890"
        echo "Del Export Job : " $DelExportJob
        DelExportJobOutput=$(curl -w '%{http_code}' -X DELETE ${DelExportJob} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

        echo "Delete Export Job  with Status Code : " $DelExportJobOutput
        if [ $DelExportJobOutput -eq 204 ]; then
                echo "Export Instance deleted....."
        else
                echo "Export Job not delete...."
                ExitCode=$?
                ValidateCommand
        fi
}


DelTenant()
{
        echo "Getting Tenant and TenantAccess key....."
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
		TenantId=$(sed -E 's/.*"id":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
		
        echo "Tenant AccessKey : " $TenantAccessKey
        echo "Tenant ID : " $TenantId
        
        DelTenant="http://${Host}:${Port}/api-metadata/v1/${TenantAccessKey}/metadata/tenants/${TenantId}"
        echo "Del Tenant :" $DelTenant
        
        DelTenantOutput=$(curl -w '%{http_code}' -X DELETE ${DelTenant} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})


        echo "Delete Tenant  with Status Code : " $DelTenantOutput
        if [ $DelTenantOutput -eq 204 ]; then
                echo "Tenant Instance deleted....."
        else
                echo "Tenant Instance delete...."
                ExitCode=$?
                ValidateCommand
        fi
}

echo "Deleting Source Instance ......."
DelSourceInstance

echo "Deleting Sink Instance......."
DelSinkInstance

echo "Deleting INGEST Job instance......."
DelIngestJob

echo "Deleting EXPORT Job instance......."
DelExportJob

echo "Deleting Tenant ID from ADW....."
DelTenant
