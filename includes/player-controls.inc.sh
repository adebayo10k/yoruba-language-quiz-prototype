#!/bin/bash
# controller functions that are responsible for program interaction with players

##############################
# passed a question and possible responses
# returns a user_response_num integer
# expect 2 incoming params, (not assumed):
# 1. A single string for the question.
# 2. A single string containing 2 or more IFS separated responses.
function get_user_response() {
	# check number of parameters
	if [ $# -ne 2 ]
	then
		msg="Incorrect number of params passed to function."
		lib10k_exit_with_error "$E_INCORRECT_NUMBER_OF_ARGS" "$msg"
	fi
	# assign parameters to variables
	question_string="$1"
	responses_string="$2"

	# expand and separate the responses into array elements
	OIFS=$IFS
	IFS='|'
	response_list=( $responses_string )
	# 
	echo && echo # space after last question
	user_response_num=''
	PS3="$question_string : "
	select response in ${response_list[@]}
	do
		if [[ ! $REPLY =~ ^[0-9]{1}$ ]]
		then
			echo && echo "No option selected. Integer [1 - ${#response_list[@]}] Required. Try Again." && echo
			continue
		# out of bounds integer error case
		elif [ $REPLY -lt 1 ] || [ $REPLY -gt ${#response_list[@]} ]
		then
			echo && echo "Invalid selection. Integer [1 - ${#response_list[@]}] Required. Try Again." && echo
			continue
		# valid integer case
		elif [ $REPLY -ge 1 ] && [ $REPLY -le ${#response_list[@]} ] 
		then		
			echo && echo "You Selected : ${response}" && echo
			user_response_num="${REPLY}"
			break
		# unexpected, failsafe case
		else		
			msg="Unexpected branch entered!"
			lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
		fi
	done
	IFS=$OIFS
	return "$user_response_num"	
}


