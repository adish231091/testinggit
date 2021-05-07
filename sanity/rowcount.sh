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

DataDensity()
{

	echo  "Fetching Row Count for below tablesId : 
		1. Address
		2. Customer"

	TenantAccessKey=$(sed -E 's/.*"accessKey":"?([^,"]*)"?.*/\1/' ${TenantDetails}/TenantDetails.txt)
    echo "Tenant Access Key is : " $TenantAccessKey
    
	TableName=( "Address" "Customer" )
	
	for TableId in "${TableName[@]}"
	do
		DataDensityCall="http://${Host}:${Port}/api-data/v1/${TenantAccessKey}/data/density/entities/${TableId}"
		echo "Data Density Call : " $DataDensityCall
        
        DataDensityOutput=$(curl -o ${WORKSPACE}/${TableId}.json -w '%{http_code}' -X GET  ${DataDensityCall} -H "Authorization: Bearer ${Token}"  -H ${ContentType}:${Application})

		echo "DataDensity Call Status Code :" $DataDensityOutput
        
		if [ $DataDensityOutput -eq 200 ]; then

			echo "Data Density on Table ID : ${TableId} successfully executed......\n"
			echo "Data Density Output of Table Id - ${TableId}.json"
            cat ${WORKSPACE}/${TableId}.json
            
        else
			echo "Data Density on Table ID : ${TableId} not successfully executed....\n"
			echo "Data Density Output of Table Id - ${TableId}.json"
            cat ${WORKSPACE}/${TableId}.json
           
            ExitCode=$?
			ValidateCommand
		fi

	done

}

sleep 10

TableRowCountValidation()
{

	echo "####### Validating Expected and Actual Row Count of Table : Address ####### \n"
	
    Actual_TableAddress_RowCount=$(cat /${WORKSPACE}/Address.json | tr -d '\n')
	Actual_TableAddress_RowCount=$(echo ${Actual_TableAddress_RowCount} | awk -F"," '{print $2}')
		
	Actual_TableAddress_RowCount=$(echo ${Actual_TableAddress_RowCount} | tr -d '"')
	echo "Actual Row Count :" $Actual_TableAddress_RowCount
	Expected_TableAddress_RowCount="rowCount:9"
		
	if [ "$Actual_TableAddress_RowCount" = "$Expected_TableAddress_RowCount" ]; then
		echo "Expected and Actual Row Count matches for Address"
	else
		echo "Expected and Actual Row Count not matches for Address"
		ExitCode=$?
		ValidateCommand
	fi

	
	echo "####### Validating Expected and Actual Row Count of Table : Customer ####### \n"
        Actual_TableCustomer_RowCount=$(cat ${WORKSPACE}/Customer.json | tr -d '\n')
        Actual_TableCustomer_RowCount=$(echo ${Actual_TableCustomer_RowCount} | awk -F"," '{print $2}')

        Actual_TableCustomer_RowCount=$(echo ${Actual_TableCustomer_RowCount} | tr -d '"') 
        echo "Actual Row Count : " $Actual_TableCustomer_RowCount

        Expected_TableCustomer_RowCount="rowCount:8"

        if [ "$Actual_TableCustomer_RowCount" = "$Expected_TableCustomer_RowCount" ]; then 
                echo "Expected and Actual Row Count matches for Customer"
        else    
                echo "Expected and Actual Row Count not matches for Customer"
                ExitCode=$?
                ValidateCommand
        fi

	
}

DataDensity
TableRowCountValidation
