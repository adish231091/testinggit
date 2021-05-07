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


ExportFlowRun()
{
        echo "Getting Tenant AccessKey..."
        
        TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
        echo "Tenant Access Key is : " $TenantAccessKey
        
        echo "Getting Tenant ID ...."
        TenantId=$(sed -E 's/.*"id":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
        echo "Tenant Access Key is : " $TenantId
        
       

        echo "Going to trigger EXPORT  Job...."

        ExportJobTrigger="http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/job/EXPORT/C1234567890/start"
        echo "Executing Export Job in MCPS  : " $ExportJobTrigger
        
        ExportJobTriggerOutput=$(curl -o ${WORKSPACE}/ExportTrigger.txt -w '%{http_code}' -X POST ${ExportJobTrigger} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

        echo "Export Job Trriger with status code :" $DwJobTriggerOutput

        if [ $ExportJobTriggerOutput -eq 200 ] ; then
                echo "Export Job Started Successfully......"
                cat ${WORKSPACE}/ExportTrigger.txt
        else
        		echo "Export Job Not Started Successfully.."
                cat ${WORKSPACE}/ExportTrigger.txt
                ExitCode=$?
                ValidateCommand
        fi

        sleep 15

        echo "Monitoring Export Job Status in MCPS manager....:"

        curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22C1234567890%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application}  >  ${WORKSPACE}/ExportJobStatus.json

        while [ true ]
        do
                JobStatus=$(sed -E 's/.*"status":"?([^,"]*)"?.*/\1/'  ${WORKSPACE}/ExportJobStatus.json)
               
                sleep 20

                if [ "$JobStatus" = "COMPLETED" ]; then
                        echo "Export Job COMPLETED......"
                        echo "CDAP URL For Export Job -"
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/EXPORT_C1234567890"
                        echo "Export Job COMPLETES With - "
                        cat ${WORKSPACE}/ExportJobStatus.json
                        
                        echo "Exported Data in Sink Instance Location - "
                        cat ${ExportPath}/*.json
                        break

                elif [ "$JobStatus" = "RUNNING" ]; then

                        echo "Export Job RUNNING...."
                     
                elif [ "$JobStatus" = "FAILED" ]; then

                        echo "Export Job FAILED..."
                        echo "CDAP URL For Export Job -"
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/EXPORT_C1234567890"
                       
                        cat ${WORKSPACE}/ExportJobStatus.json
                        exit 1


                elif [ "$JobStatus" = "KILLED" ]; then

                        echo "Export Job KILLED..."
                        echo "CDAP URL For Export Job -"
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantId}/view/EXPORT_C1234567890"
                       
                        exit 1

                else
                        echo "Export Job Is In PROVISING STATE..."
                fi


                curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22C1234567890%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application}>  ${WORKSPACE}/ExportJobStatus.json

        done

}

ExportFlowRun
