#!/bin/bash +x
  


Body="Job Fails ${JOB_NAME}, Please check below Build URL ...
        ${BUILD_URL}"

Subject="Job : ${JOB_NAME} with build no ${BUILD_NUMBER}  Fails in Jenkins Pipeline"


echo "Executing Call to fetch last job status...."
res=$(curl https://ci-cloud.us.oracle.com/jenkins/mcp/view/PipelineJobs/job/${JOB_NAME}/lastBuild/api/json)
JobStatus=$(echo $res | jq '.result')
echo "JobStatus is : " $JobStatus
ActualStatus=$(echo $JobStatus | tr -d '"')
#echo $ActualStatus
ActualStatus="fails"

if [ "$ActualStatus" = "SUCCESS" ]; then
        echo "Job Pass..."
else
        echo "Job Failed , sending mail to below members ..."
        echo $Body | mail -s $Subject  adish.sharma@oracle.com
fi
