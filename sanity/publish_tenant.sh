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


PublishTenant()
{
	
    TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
    
    echo "Tenant Access Key :" $TenantAccessKey
	
    TenantID=$(sed -E 's/.*"id":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
    
    echo "Tenant ID : " $TenantID

	PublishTenant="http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/tenant/publish"
	echo "Publishing the Tenant in ADW Env : " $PublishTenant
    
	PublishTenantOutput=$(curl -o ${WORKSPACE}/PublishTenant.txt -w '%{http_code}' -X POST ${PublishTenant} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})	

	echo "Publish Tenant API status code :" $PublishTenantOutput

	if [ $PublishTenantOutput -eq 200 ] ; then
		echo "Publist Tenant Successfully Triggered ......"
        cat ${WORKSPACE}/PublishTenant.txt
        
	else
    
		ExitCode=$?
		echo "Publishing tenant not trigger successfully ..."
        echo "Error -"
        cat ${WORKSPACE}/PublishTenant.txt
		ValidateCommand
        
	fi

	sleep 20

	echo "Monitoring Publish Job Status in MCPS manager....:"

        curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22Publish%22}]" --header "Authorization: Bearer ${Token}" --header ${ContentType}:${Application}  >  ${WORKSPACE}/PublishJobStatus.json

        while [ true ]
        do
                JobStatus=$(sed -E 's/.*"status":"?([^,"]*)"?.*/\1/' ${WORKSPACE}/PublishJobStatus.json)
                
              
                sleep 30

                if [ "$JobStatus" = "COMPLETED" ]; then
                
                        echo "Publish Job COMPLETED......"
                        res=$(cat ${WORKSPACE}/PublishJobStatus.json)
                        echo "Publish Tenant Job Status : " $res
                        
          				echo "CDAP Publish Job URL : "
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantID}/view/PUBLISH_Publish"     
                   
                        break

                elif [ "$JobStatus" = "RUNNING" ]; then

                        echo "Publish Job RUNNING...."
                       


                elif [ "$JobStatus" = "FAILED" ]; then
						
                        echo "Publish Tenant FAILED...."
                        res=$(cat ${WORKSPACE}/PublishJobStatus.json)
                        echo "Publish Tenant Job Status : " $res
                        
                        echo "Please find below CDAP Publish Job URL..."
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantID}/view/PUBLISH_Publish"     
                   
                        exit 1


                elif [ "$JobStatus" = "KILLED" ]; then

						echo "Publish Tenant KILLED....."
                        echo "Publish Job killed please find below URL of CDAP logs...."
                        echo "http://144.25.44.151:11011/pipelines/ns/t_${TenantID}/view/PUBLISH_Publish"     
                   
                        exit 1

                else
                        echo "Publish Job Is In Provising State..."
                fi


                curl  -g --request GET "http://${Host}:${Port}/api-admin/v1/${TenantAccessKey}/admin/jobsummaries?q=[{%22operator%22:%22EQUALS%22,%22attribute%22:%22jobId%22,%22value%22:%22Publish%22}]" --header "Authorization: Bearer ${Token}"  --header ${ContentType}:${Application}  >  ${WORKSPACE}/PublishJobStatus.json

        done

}


echo "######### Publishing the tenant in ADW ENV ########"
PublishTenant
