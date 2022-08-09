#!/bin/bash
# functions responsible for getting the source data for quizzes

function check_for_data_urls() {
    local dev_quiz_urls=( "$@" )
    if [ ! ${#dev_quiz_urls[@]} -gt 0 ]; then
		msg="Quiz data not available. Nothing to do. Exiting now..."
		lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
	fi
}

# 
function get_user_quiz_choice() {
    local dev_quiz_urls=( "$@" )
	# make an array of url basenames. parameter expansion on an array.
	dev_quiz_url_bns=("${dev_quiz_urls[@]##*/}")
	#
    PS3="> "
    echo "Enter the number of the quiz you want to try : " && echo
	select bn in ${dev_quiz_url_bns[@]} 'None'
	do
		# type error case
		if [[ ! $REPLY =~ ^[0-9]+$ ]] 
		then
			echo && echo "No Quiz Selected. Integer [1 - $(( ${#dev_quiz_url_bns[@]} + 1 ))] Required. Try Again." && echo
			continue
		# out of bounds integer error case
		elif [ $REPLY -lt 1 ] || [ $REPLY -gt $(( ${#dev_quiz_url_bns[@]} + 1 )) ]
		then
			echo && echo "Invalid Selection. Integer [1 - $(( ${#dev_quiz_url_bns[@]} + 1 ))] Required. Try Again." && echo
			continue
		# valid user response case
		elif [ ${REPLY} -ge 1 ] && [ ${REPLY} -le ${#dev_quiz_url_bns[@]} ]
		then		
			echo "You Selected : ${bn}"
			echo "...which was choice number: ${REPLY}"
			user_quiz_choice_num="${REPLY}"
			echo && echo "Quiz Selected OK."
			break
		# valid user response case (for None)
		elif [ ${REPLY} -eq $(( ${#dev_quiz_url_bns[@]} + 1 )) ]
		then
			echo "You selected \"None\". O dabọ!" && echo && exit 0 # Exit Program
		# unexpected, failsafe case
		else
			msg="Unexpected branch entered!"
			lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"  # Exit Program with error
		fi
	done
}

##############################
#
function get_quiz_data_file() {
    local user_quiz_choice_num="$1"
    shift
    local dev_quiz_urls=( "$@" )
	remote_get='false'
    # assign  a value to remote_quiz_file_url by
    # using user_quiz_choice_num on ${dev_quiz_urls[@]})
    remote_quiz_file_url="${dev_quiz_urls[${user_quiz_choice_num}-1]}"
    # assign value to local_quiz_file
    # derived from the remote_quiz_file_url
    local_quiz_file="${command_dirname}/data/${remote_quiz_file_url##*/}"
    # if local_quiz_file already exists, and is not empty, then no need to fetch it down again.
    local_quiz_file_line_count=$(wc -l "$local_quiz_file" 2>/dev/null | sed 's/[^0-9]//g')
    if [ -f "$local_quiz_file" ] && \
    [ -r "$local_quiz_file" ] && \
    [ $local_quiz_file_line_count -gt 30 ] # 30 is arbitrary minimum for a 'good file'
    then
        # ..
        echo && echo -e "Good News! Requested quiz file already exists locally."
    else
		echo && echo "The requested quiz data file does not exist locally." 
		echo "The program needs to download it from its' remote storage location."
		echo "It will then create a directory called 'data', in the same directory from which this program is being run, where it can store the quiz data file for future use."

		# give user option to continue playing, change quit or end program
		question_string='What next? Continue to Download and Store the quiz data file? Choose an option'
		responses_string='Yes, Download and Store the quiz data|No, Quit the Program'
		get_user_response "$question_string" "$responses_string"
		user_response_code="$?"
		# affirmative case
		if [ "$user_response_code" -eq 1 ]; then
			echo && echo "Downloading data file now..." && sleep 2
			echo
		# negative case 
		elif [ "$user_response_code" -eq 2 ]; then
			echo -e	"	Ok, see you next time!" && echo && sleep 2
			echo -e	"	yorubasystems.com" && echo && sleep 2
			echo -e "	${BROWN}	End of program. O dabọ!${NC}" && sleep 1
			echo && exit 0
		# unexpected, failsafe case	
		else
			msg="Unexpected user_response_code value returned. Exiting now..."
    	    lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
		fi
		
        create_data_dirs "$local_quiz_file"
        request_quiz_data "$remote_quiz_file_url"   
        # once a new local quiz file is written, make it ro \
        # so that it can be used again in future, unchanged
        write_decoded_quiz_data "$quiz_data"  && \
		chmod 440 "$local_quiz_file"
		if [ $? -eq 0 ]; then
			echo && echo "Local quiz data file created OK"
		else
			msg="Could not write local JSON quiz file. Exiting now..."
			lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
		fi
    fi

	echo && echo "Quiz data available." && echo
	echo && echo "$hr"

	# give user option to continue to Quiz Information page or end program
	question_string='What next? View the Information Page for this Quiz? Choose an option'
	responses_string='Yes, View it now|No, Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# affirmative case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "Launching Quiz Information page now..." && sleep 2
		echo && clear
	# negative case 
	elif [ "$user_response_code" -eq 2 ]; then
		echo -e	"	Ok, see you next time!" && echo && sleep 2
		echo -e	"	yorubasystems.com" && echo && sleep 2
		echo -e "	${BROWN}	End of program. O dabọ!${NC}" && sleep 1
		echo && exit 0
	# unexpected, failsafe case	
	else
		msg="Unexpected user_response_code value returned. Exiting now..."
        lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
	fi
}

##############################
function create_data_dirs() {
    local local_quiz_file="$1"
    # then create touch the local_quiz_file
    if mkdir -p "${command_dirname}/data" && touch "$local_quiz_file"
    then
        echo -n >"$local_quiz_file"
    else
        # can't write local JSON quiz file, so exit program
        msg="Could not write local JSON quiz file. Exiting now..."
        lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
    fi
}

##############################
function request_quiz_data() {
    local remote_quiz_file_url="$1"
    quiz_data="$(curl -s "$remote_quiz_file_url" 2>/dev/null)"

    # Data transfer successful?
    [ $? -ne 0 ] && msg="cURL Failed. Exiting..." && \
    lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg" || \
    echo && echo -e  "${GREEN_BOLD}cURL Client Succeeded.${NC}"

    # JSON-like data received?
    if [ -n "$quiz_data" ] && echo $quiz_data | grep '{' >/dev/null 2>&1 
    then
    	echo -e "${GREEN}JSON Downloaded OK.${NC}"
    else
    	msg="Could not retrieve a valid JSON file. Exiting now..."
        lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
    fi
}

##############################
function write_decoded_quiz_data() {
    local quiz_data="$1"
    local tmp_line
    # write decoded quiz data to the local quiz file
    for line in "$quiz_data"
    do
       tmp_line="$(echo -e "$line")"
       echo -e "$tmp_line" >> $local_quiz_file
     done # end while
}

##############################