#!/usr/bin/ruby +x

require "json"

def test1

	myString=String.new("THIS IS OUDP QA TEAM")
	foo=myString.downcase
	puts "#{foo}"
end

def test2

	var="OUDP QA TEAM"
        puts "#{var}"
end

def test3

	names= Array.new(4,"macos")
        puts "#{names}"

end

def test3

	a="oudp"
        b=a

	expect(a).to eql(b)
end



test1
test2
test3

