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




DwFlowRun()
{	
	echo "Getting Tenant Access Key...."
	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
	echo "Tenant Access Key is : " $TenantAccessKey
    
    
	echo "Getting Tenant ID...."
	TenantId=$(sed -E 's/.*"id":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
	echo "Tenant ID is : " $TenantId
    
    
    
	echo "Going to trigger DW Job...."
	
	DwJobTrigger="http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/job/DW/Dw/start"	
	echo "Executing DW Job : "$DwJobTrigger
    
    DwJobTriggerOutput=$(curl -o ${WORKSPACE}/DwTrigger.txt -w '%{http_code}' -X POST ${DwJobTrigger} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

	echo "DW Job Trriger with status code :" $DwJobTriggerOutput

	if [ $DwJobTriggerOutput -eq 200 ] ; then
                echo "Dw Job Started Successfully......"
                cat ${WORKSPACE}/DwTrigger.txt
    else
        		echo "DW Job Not Started Successfully..."
                cat ${WORKSPACE}/DwTrigger.txt
                ExitCode=$?
                ValidateCommand
    fi

	sleep 10

	echo "Monitoring DW Job Status in MCPS manager....:"

	curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22Dw%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application} >  ${WORKSPACE}/DwJobStatus.json


	while [ true ] 
	do
		JobStatus=$(sed -E 's/.*"status":"?([^,"]*)"?.*/\1/' ${WORKSPACE}/DwJobStatus.json)
		
		sleep 20
			
		if [ "$JobStatus" = "COMPLETED" ]; then
        
			echo "DW Job COMPLETED......"
            echo "CDAP URL For DW Job - "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/DW_Dw"
            cat ${WORKSPACE}/DwJobStatus.json   
			break
			
		elif [ "$JobStatus" = "RUNNING" ]; then
	
			echo "DW Job RUNNING...."
            
		

		elif [ "$JobStatus" = "FAILED" ]; then

			echo "DW Job FAILED..."
            echo "CDAP URL For DW Job - "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/DW_Dw"
            cat ${WORKSPACE}/DwJobStatus.json
			exit 1
			

		elif [ "$JobStatus" = "KILLED" ]; then

			echo "DW Job KILLED...."
            echo "CDAP URL For DW Job - "
            echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/DW_Dw"
            cat ${WORKSPACE}/DwJobStatus.json
			exit 1

		else 
			echo "DW Job Is In PROVISING STATE ..."
		fi


		curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22Dw%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application} >  ${WORKSPACE}/DwJobStatus.json


	done
}


DwFlowRun
