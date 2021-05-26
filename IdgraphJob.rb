#!/usr/bin/ruby +x

require "json"
require "yaml"
require "uri"
require "net/http"
require 'test-unit'
require "rspec/expectations"
require "test/unit"
extend Test::Unit::Assertions

puts "Reading configurations of env....\n"
log = File.open( "/Users/adishsharma/automation/regression_tenant100146/property.yaml" )
yp = YAML::load_stream( log ) { |doc|
        
	$Host= "#{doc['HostEnv']}"
	$Port= "#{doc['PortEnv']}"
	$TenantAccessKey= "#{doc['TenantAccessKeyEnv']}"
	$ApiType= "#{doc['ApiTypeEnv']}"
	$Type= "#{doc['TypeEnv']}"
	$TruncateType= "#{doc['TruncateTenantType']}"

puts $Host
puts $Port
puts $TenantAccessKey
puts $ApiType
puts $Type
puts $TruncateType
puts "\n"
}

puts "Running Job for  tenant ID 100146 in MIDGARD Env....\n"

url = URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/job/IDGRAPH/IdGraph/start")
puts "#{url}"

http = Net::HTTP.new(url.host, url.port);
request = Net::HTTP::Post.new(url)

request["Content-Type"] = "application/json"

request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiY2xpZW50X2lkIjoiMTIzIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6dXMtYXNoYnVybi0xOjVlOTBjMjg4MzQ1MjQ4N2FiMjQyOWZmYWM2MjE2OGYzIiwic3ViX3R5cGUiOiJjbGllbnQiLCJzY29wZSI6InVybjpvY3g6b3VkcHNjb3BlOmNsaWVudCIsImV4cCI6MTU5ODkyMjUxMCwiaWF0IjoxNTk4NTYzNjYyLCJqdGkiOiI1ZjgzOTAxYy1mNmRjLTQ0ZjEtYmIwYS1iZDZjZGYyOWJiZGIifQ.36aT_6HzMiH9Cy5lAKq52njpRVqtjfl5RLCNoGyWWkk"


response = http.request(request)

code=response.code
JobRun_Output=response.read_body
puts "Job run output of TenantId-1000146 : #{JobRun_Output}"

if code=="200"
	puts "Successfully Job run of tenant 100146 Triggered \n"
else
	puts "Status Code is - #{code}"
	assert_equal(code,"200",failure_mesg="Unable to trigger Job run for Tenant-100146 API Failed.... \n")

end

sleep 10

puts "Monitoring Job Status in MCPS................\n"

url=URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/jobsummaries?q=[{\"operator\":\"EQUALS\",\"attribute\":\"jobId\",\"value\":\"IdGraph\"}]")
http = Net::HTTP.new(url.host, url.port);
request = Net::HTTP::Get.new(url)
request["Content-Type"] = "application/json"

request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiY2xpZW50X2lkIjoiMTIzIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6dXMtYXNoYnVybi0xOjVlOTBjMjg4MzQ1MjQ4N2FiMjQyOWZmYWM2MjE2OGYzIiwic3ViX3R5cGUiOiJjbGllbnQiLCJzY29wZSI6InVybjpvY3g6b3VkcHNjb3BlOmNsaWVudCIsImV4cCI6MTU5ODkyMjUxMCwiaWF0IjoxNTk4NTYzNjYyLCJqdGkiOiI1ZjgzOTAxYy1mNmRjLTQ0ZjEtYmIwYS1iZDZjZGYyOWJiZGIifQ.36aT_6HzMiH9Cy5lAKq52njpRVqtjfl5RLCNoGyWWkk"

response = http.request(request)

code=response.code
if code=="200"
        puts "Successfully Job Admin API Publish Tenant 100146 Triggered \n"
else
        puts "Status Code is - #{code}"
        assert_equal(code,"200",failure_mesg="Job Admin API to monitor Job for Tenant-100196 API triggered not sucessfully....\n")
end

while true
	
	url=URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/jobsummaries?q=[{\"operator\":\"EQUALS\",\"attribute\":\"jobId\",\"value\":\"IdGraph\"}]")	
	http = Net::HTTP.new(url.host, url.port);
	request = Net::HTTP::Get.new(url)

	request["Content-Type"] = "application/json"

	request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiY2xpZW50X2lkIjoiMTIzIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6dXMtYXNoYnVybi0xOjVlOTBjMjg4MzQ1MjQ4N2FiMjQyOWZmYWM2MjE2OGYzIiwic3ViX3R5cGUiOiJjbGllbnQiLCJzY29wZSI6InVybjpvY3g6b3VkcHNjb3BlOmNsaWVudCIsImV4cCI6MTU5ODkyMjUxMCwiaWF0IjoxNTk4NTYzNjYyLCJqdGkiOiI1ZjgzOTAxYy1mNmRjLTQ0ZjEtYmIwYS1iZDZjZGYyOWJiZGIifQ.36aT_6HzMiH9Cy5lAKq52njpRVqtjfl5RLCNoGyWWkk"

	response = http.request(request)

	code=response.code
	if code=="200"
        	puts "Successfully Job Admin API for Job of  Tenant 100146 Triggered \n"
	else
		puts "Status Code is - #{code}"
        	assert_equal(code,"200",failure_mesg="Job Admin API to monitor job for Tenant-100196 API triggered not sucessfully....\n")
	end

	$MonitorJobStatus=response.read_body
	
	File.write("/Users/adishsharma/automation/regression_tenant100146/IdgraphJobStatus.json", "#$MonitorJobStatus" , mode: "w") 
	puts "Fetching Publish Job Status from Admin API..."
	$Fread= File.read("/Users/adishsharma/automation/regression_tenant100146/IdgraphJobStatus.json.json", mode: "r")
	fstatus= JSON.parse("#$Fread")
	
	$JobStatus= fstatus[0]["status"]
	puts "JobStatus - #$JobStatus"
	if "#$JobStatus" == "PENDING"
		puts "Job is in PENDING State.."
	
	elsif "#$JobStatus" == "RUNNING"
		puts "Job is in RUNNING State..."

	elsif "#$JobStatus" == "FAILED"
		puts "Job is in FAILED State..."
		break	

	elsif "#$JobStatus" == "KILLED"
		puts "Job Killed..."
		break
	else
		puts "Job has been COMPLETED.................."
		break

	end

	sleep 20	
	
end
