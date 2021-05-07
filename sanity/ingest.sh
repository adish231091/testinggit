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



IngestFlowRun()
{	
	echo "Getting Tenant Access Key...."
    
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/'  ${TenantDetails}/TenantDetails.txt)
	echo "Tenant Access Key is : " $TenantAccessKey


	echo "Getting Tenant ID ..."
    TenantID=$(sed -E 's/.*"id":"?([^,"]*)"?.*/\1/'  ${TenantDetails}/TenantDetails.txt)
    echo "Tenant ID : " $TenantID
    
	echo "Going to trigger ingest Job...."
	
	IngestJobTrigger="http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/job/INGEST/IngestSanityCheck/start"	
	echo "Executing the ingest Job with : " $IngestJobTrigger
    
    IngestJobTriggerOutput=$(curl -o ${WORKSPACE}/LogIngestTrigger.txt -w '%{http_code}' -X POST ${IngestJobTrigger} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

	

	echo "INGEST Job Trigger with status code :" $IngestJobTriggerOutput

	if [ $IngestJobTriggerOutput -eq 200 ] ; then
                echo "Ingest Job Started Successfully......"
                Output=$(cat ${WORKSPACE}/LogIngestTrigger.txt)
				echo "INGEST Job Trigger Output : " $Output
                
        else
        		echo "Ingest Job Not Started Successfully..."
                Output=$(cat ${WORKSPACE}/LogIngestTrigger.txt)
				echo "INGEST Job Trigger Output : " $Output
				ExitCode=$?
                ValidateCommand
        fi

	sleep 15

	echo "Monitoring INGEST Job Status in MCPS manager....:"

	curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22IngestSanityCheck%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application} >  ${WORKSPACE}/IngestJobStatus.json



	while [ true ] 
	do
		JobStatus=$(sed -E 's/.*"status":"?([^,"]*)"?.*/\1/' ${WORKSPACE}/IngestJobStatus.json)
		
		sleep 20
			
		if [ "$JobStatus" = "COMPLETED" ]; then
        	echo "CDAP URL for Ingest Job : "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/INGEST_IngestSanityCheck"
			echo "Ingest Job COMPLETED with below output......"
            
            cat ${WORKSPACE}/IngestJobStatus.json
			break
			
		elif [ "$JobStatus" = "RUNNING" ]; then
	
			echo "Ingest Job RUNNING...."
            echo "CDAP URL for Ingest Job : "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/INGEST_IngestSanityCheck"
			
		

		elif [ "$JobStatus" = "FAILED" ]; then

			echo "Ingest Job failed with below output,please check the logs..."
            cat ${WORKSPACE}/IngestJobStatus.json
			echo "CDAP URL for Ingest Job : "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/INGEST_IngestSanityCheck"
			
			
			exit 1
			

		elif [ "$JobStatus" = "KILLED" ]; then
        
        	echo "Ingest Job killed with below output,please check the logs..."
            cat ${WORKSPACE}/IngestJobStatus.json
			echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/INGEST_IngestSanityCheck"
		
			exit 1

		else 
			echo "Ingest Job is in provising state..."
		fi


		curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22IngestSanityCheck%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application}  >  ${WORKSPACE}/IngestJobStatus.json



	done



}

IngestFlowRun
