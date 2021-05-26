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

puts "Truncating the tenant ID 100146 in MIDGARD Env....\n"

url = URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/tenant/#$TruncateType")
puts "#{url}"

http = Net::HTTP.new(url.host, url.port);
request = Net::HTTP::Post.new(url)

request["Content-Type"] = "application/json"

request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiY2xpZW50X2lkIjoiMTIzIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6dXMtYXNoYnVybi0xOjVlOTBjMjg4MzQ1MjQ4N2FiMjQyOWZmYWM2MjE2OGYzIiwic3ViX3R5cGUiOiJjbGllbnQiLCJzY29wZSI6InVybjpvY3g6b3VkcHNjb3BlOmNsaWVudCIsImV4cCI6MTU5ODkyMjUxMCwiaWF0IjoxNTk4NTYzNjYyLCJqdGkiOiI1ZjgzOTAxYy1mNmRjLTQ0ZjEtYmIwYS1iZDZjZGYyOWJiZGIifQ.36aT_6HzMiH9Cy5lAKq52njpRVqtjfl5RLCNoGyWWkk"

request.body={"truncateDW":true,"truncateCube":true}.to_json
response = http.request(request)

code=response.code
TruncateOutput=response.read_body
puts "Output of Truncate TenantId-1000146 : #{TruncateOutput}"


if code=="200"
	puts "Successfully Truncate Tenant 100146 Triggered \n"
else
	puts "Status Code is - #{code}"
	assert_equal(code,"200",failure_mesg="Unable to trigger Truncate Tenant-100146 API Failed.... \n")

end

sleep 60


puts "Publishing the tenant ID 100146 in MIDGARD Env.... \n"	
url = URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/tenant/#$Type")
puts "#{url}"

http = Net::HTTP.new(url.host, url.port);
request = Net::HTTP::Post.new(url)

request["Content-Type"] = "application/json"

request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJtY3BzIiwiaXNzIjoiaHR0cHM6Ly9pZGVudGl0eS5vcmFjbGVjbG91ZC5jb20vIiwiY2xpZW50X2lkIjoiMTIzIiwiYXVkIjoidXJuOm9jeDpvdWRwaWQ6dXMtYXNoYnVybi0xOjVlOTBjMjg4MzQ1MjQ4N2FiMjQyOWZmYWM2MjE2OGYzIiwic3ViX3R5cGUiOiJjbGllbnQiLCJzY29wZSI6InVybjpvY3g6b3VkcHNjb3BlOmNsaWVudCIsImV4cCI6MTU5ODkyMjUxMCwiaWF0IjoxNTk4NTYzNjYyLCJqdGkiOiI1ZjgzOTAxYy1mNmRjLTQ0ZjEtYmIwYS1iZDZjZGYyOWJiZGIifQ.36aT_6HzMiH9Cy5lAKq52njpRVqtjfl5RLCNoGyWWkk"

response = http.request(request)


PublishStatusCode=response.code
PublishResponseBody= response.read_body


if PublishStatusCode=="200"
	puts "Publish Job Output - #{PublishResponseBody}"
	puts "Successfully Publish Tenant 100146 Triggered \n"
else
	puts "Status Code to trigger Publish Job - #{PublishStatusCode}"
	assert_equal(PublishStatusCode,"200",failure_mesg="Unable to trigger Publish Tenant-100196 API Failed....\n")
end

puts "Monitoring Publish Job Status in MCPS................\n"

url=URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/jobsummaries?q=[{\"operator\":\"EQUALS\",\"attribute\":\"jobId\",\"value\":\"Publish\"}]")
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
        assert_equal(code,"200",failure_mesg="Job Admin API to monitor Publish Tenant-100196 API triggered not sucessfully....\n")
end

#PublishJobStatus=response.read_body
#puts "Publish Job Status Content : #{PublishJobStatus}"

#puts "Writing Publish Job Status in a file...."
#File.write("/Users/adishsharma/automation/regression_tenant100146/PublishJobStatus.json", "#{PublishJobStatus}" , mode: "w")
#puts "Fetching Job Status from its Job Status File..."
#Fread= File.read("/Users/adishsharma/automation/PublishJobStatus.json", mode: "r")
#Fstatus= JSON.parse(Fread)
#JobStatus= Fstatus[0][ "status" ]

while true
	
	url=URI("http://#$Host:#$Port/#$ApiType/v1/#$TenantAccessKey/admin/jobsummaries?q=[{\"operator\":\"EQUALS\",\"attribute\":\"jobId\",\"value\":\"Publish\"}]")
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
        	assert_equal(code,"200",failure_mesg="Job Admin API to monitor Publish Tenant-100196 API triggered not sucessfully....\n")
	end

	$PublishJobStatus=response.read_body
	
	File.write("/Users/adishsharma/automation/PublishJobStatus.json", "#$PublishJobStatus" , mode: "w") 
	puts "Fetching Publish Job Status from Admin API..."
	$Fread= File.read("/Users/adishsharma/automation/PublishJobStatus.json", mode: "r")
	fstatus= JSON.parse("#$Fread")
	
	$JobStatus= fstatus[0]["status"]
	puts "JobStatus - #$JobStatus"
	if "#$JobStatus" == "PENDING"
		puts "Publish Job is in PENDING State.."
	
	elsif "#$JobStatus" == "RUNNING"
		puts "Publish Job is in RUNNING State..."

	elsif "#$JobStatus" == "FAILED"
		puts "Publish Job is in FAILED State..."
		break	

	elsif "#$JobStatus" == "KILLED"
		puts "Publish Job Killed..."
		break
	else
		puts "Publish Job has been COMPLETED.................."
		break

	end

	sleep 20	
	
end
