#!/bin/bash

# exit program with non-zero exit code
function exit_with_error()
{	
	error_code="$1"
	error_message="$2"

	echo "EXIT CODE: $error_code"
	echo "$error_message" && echo && sleep 1
	echo "USAGE: $(basename $0) ABSOLUTE_FILEPATH..." && echo && sleep 1

	exit $error_code
}

##################################################################
# 
function log_error() 
{
	error_code="$1"
	error_message="$2"

	#echo "EXIT CODE: $error_code" | tee -a $LOG_FILE
	#echo "$error_message" | tee -a $LOG_FILE && echo && sleep 1
	#echo "USAGE: $(basename $0) ABSOLUTE_FILEPATH..." | tee -a $LOG_FILE && echo && sleep 1
#
	#exit $error_code
}

##################################################################
# 
function display_error()
{

	:
		
}
