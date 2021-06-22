#!/usr/bin/python +x

from lib import get_user_input, safe_get_user_input

print "Executing 1st Rule"
user_input = get_user_input()
eval(user_input)

eval('print("Hardcoded eval")')

totally_safe_eval = eval
totally_safe_eval(user_input)

eval(safe_get_user_input())

print "Executing 2nd Rule"
print "Performing mathematical operaion...."
var1=100
var2=200

var3=var2/var1
print "Result after performing mathematical operation", var3

print "Executing 3rd Rule"
print "Calculating length of list.."
l1={1,2,3,4,5,6}
l2=len(l1)
print "Length of list is :" ,l2

print "Executing 4th Rule"
string1="oracle"

string2=string1.lower()

print "String2 after LOWER function :" ,string2

print "Executing 5th Rule"
user_dict={"a":1,"b":2}
print "User Dict is :" ,user_dict
