#!/bin/bash
# functions to run to actual core quiz play features of the program
##############################
# GLOBAL VARIABLE DECLARATIONS:
##############################
declare -a num_range_arr=()
break_this_quiz='false'

# display quiz information and preview content
function display_quiz_info() {
    local quiz_category_string="$1"
    local quiz_length="$2"
    local quiz_play_sequence_default_string="$3"
    local quiz_english_phrases_string="$4"
    local quiz_yoruba_phrases_string="$5"

	# display quiz theme (or name)
    echo "quiz theme (or name):"
    echo -e "${quiz_category_string}"
    echo

    # quiz size (number of questions)
    echo "$quiz_length questions"
    echo

    # quiz play sequence (ordered or shuffled)
    echo "quiz questions sequence (ordered or shuffled):"
	echo -e "$quiz_play_sequence_default_string"
	echo

    # quiz content (a preview)
    echo "quiz_english_phrases_string:"
	echo -e "$quiz_english_phrases_string"
	echo && echo

    echo "quiz_yoruba_phrases_string:"
	echo -e "$quiz_yoruba_phrases_string"
	echo && echo

	echo && echo "$hr"

	# give user option to continue to Quiz Instructions or end program
	question_string='What next? Choose an option'
	responses_string='View the Quiz Instructions|Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# next question case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "Launching Quiz Instructions now..." && sleep 1 
		echo && clear
	# quit program case
	elif [ "$user_response_code" -eq 2 ]; then
		echo -e	"	Ok, see you next time!" && echo && sleep 2
		echo -e	"	yorubasystems.com" && echo && sleep 2
		echo -e "	\033[33m	End of program. O dabọ!\033[0m" && sleep 1
		echo && exit 0
	# unexpected, failsafe case	
	else
		msg="Unexpected user_response_code value returned. Exiting now..."
        lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
	fi
}

#
function display_quiz_instructions() {
    OIFS=$IFS; IFS='|'	
    local quiz_instructions_array=( "$@" )
	IFS=$OIFS
   
	echo && echo
	# quiz instructions 
	for line in "${quiz_instructions_array[@]}"
	do
		echo -e "$line"
	done
	echo

	# give user option to continue to Quiz Play or end program
	question_string='What next? Play the Quiz? Choose an option'
	responses_string='Yes, Play the Quiz now|No, Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# next question case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "Launching your Quiz now..." && sleep 2 
		echo && clear
	# quit program case
	elif [ "$user_response_code" -eq 2 ]; then
		echo -e	"	Ok, see you next time!" && echo && sleep 2
		echo -e	"	yorubasystems.com" && echo && sleep 2
		echo -e "	\033[33m	End of program. O dabọ!\033[0m" && sleep 1
		echo && exit 0
	# unexpected, failsafe case	
	else
		msg="Unexpected user_response_code value returned. Exiting now..."
        lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
	fi
}

#
function setup_quiz_sequence() {
    local quiz_play_sequence_default_string="$1"
    local quiz_length="$2"
	# create a number sequence to 'pilot' the quiz order
	if [[ "$quiz_play_sequence_default_string" = 'shuffled' ]]
	then
		make_shuffled_num_range 0 "$(( $quiz_length - 1 ))"
	elif [[ "$quiz_play_sequence_default_string" = 'ordered' ]]
	then
		make_ordered_num_range 0 "$(( $quiz_length - 1 ))"
	else
		## exit with error code and message
        msg="quiz play sequence not set. Exiting now..."
		lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
	fi
}

#
function play_quiz_questions() {
    local num_range_arr="$1"
    local quiz_type_string="$2"

	local num_of_responses_to_display=1
	# initialise before quiz starts
	local num_of_responses_showing=0 
	local is_first_quiz_question='true'
	break_this_quiz='false'

	for elem in ${num_range_arr[@]}
	do
		# value of break_this_quiz may be reset by player \
		# from the serve_vocabulary_question() function
		if [ $break_this_quiz = 'true' ]
		then
			break
		fi
		# always clear screen before first quiz question
		if [ "$is_first_quiz_question" = 'true' ]
		then
			clear
			is_first_quiz_question='false'
		fi

		# then only clear when num_of_responses_showing >= num_of_responses_to_display
		if [ "$num_of_responses_showing" -ge "$num_of_responses_to_display" ]
		then
			clear
			num_of_responses_showing=0 # reset
		fi
		
		echo && echo && echo # for positioning and display of next console output only	

		# handle quiz question serve method based on the quiz_type_string
		if [[ "$quiz_type_string" = 'vocabulary' ]]
		then
			serve_vocabulary_question "$elem" \
            current_yoruba_translations_assoc_array "${current_english_phrases_array[@]}"
		elif [[ "$quiz_type_string" = 'oral' ]]
		then
			serve_oral_question "$elem"
		else
			## failsafe branch
            msg="quiz type not set. Exiting now..."
            lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
		fi

		num_of_responses_showing=$((num_of_responses_showing + 1))
	done

}

##############################
#
function finish_quiz() {
	echo -e "\033[33m		QUIZ FINISHED!\033[0m" && sleep 1 && echo

	# give user option to continue to Quiz Play or end program
	question_string='What next? Play a Different Quiz? Choose an option'
	responses_string='Yes, Try Another Quiz now|No, Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# next question case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "Launching Quizzes now..." && sleep 2 
		echo && clear
	# quit program case
	elif [ "$user_response_code" -eq 2 ]; then
		echo -e	"	Ok, see you next time!" && echo && sleep 1
		echo -e	"	yorubasystems.com" && echo && sleep 2
		echo -e "	\033[33m	End of program. O dabọ!\033[0m" && sleep 1
		echo && exit 0
	# unexpected, failsafe case	
	else
		msg="Unexpected user_response_code value returned. Exiting now..."
        lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
	fi
}


##############################
# populates a globally accessible array with shuffled integer values
function make_shuffled_num_range() {
	lower_limit="$1" # array start index
	upper_limit="$2" # (array size - 1) is passed in

	num_range_arr=()	# reset this global variable
	for index in "$(shuf -i "$lower_limit"-"$upper_limit")"
	do
		num_range_arr+=("${index}") # append an indexed array of shuffled numbers
	done
}

##############################
# populates a globally accessible array with ordered, sequenced integer values
function make_ordered_num_range() {
	lower_limit="$1" # array start index
	upper_limit="$2" # (array size - 1) is passed in

	num_range_arr=()	# reset this global variable
	for index in "$(seq "$lower_limit" "$upper_limit")"
	do
		num_range_arr+=("${index}") # append an indexed array of sequenced numbers
	done
}

##############################
# vocabulary questions wait for user to respond before displaying answer
function serve_vocabulary_question() {
	local question_num="$1"; shift    
    local -n current_yoruba_translations_assoc_array_ref=$1; shift
    local current_english_phrases_array=( "$@" )

	eng_word="${current_english_phrases_array[$question_num]}"
    # -e because some english phrases include Yoruba names
	echo -e "		$eng_word" && echo
    echo -e "First Type your answer (Optional)" 
    echo -e "...then Press ENTER to see translation..."
	
	read	# wait for user to answer

	# if translation is a colon separated list, print a listing
	translatedString="${current_yoruba_translations_assoc_array_ref[$eng_word]}"
	echo "$translatedString" | grep -q ':'
	isList=$?
	if [ $isList -eq 0 ]	# 0 means colon delimited translation lines/list was found
	then
		enum_list "$translatedString"
	else
		echo -e "		${translatedString}"
	fi

	echo && echo
	# give user option to continue playing, change quit or end program
	question_string='What next? Choose an option'
	responses_string='Go to Next Question|Leave this Quiz|Quit the Program'
	get_user_response "$question_string" "$responses_string"
	user_response_code="$?"
	# next question case
	if [ "$user_response_code" -eq 1 ]; then
		echo && echo "OK, Continuing to Next Question..." && sleep 1 
		echo && clear
	# leave this quiz case
	elif [ "$user_response_code" -eq 2 ]; then
		break_this_quiz='true'
	# quit program case
	elif [ "$user_response_code" -eq 3 ]; then
		echo -e	"	Ok, see you next time!" && echo && sleep 2
		echo -e	"	yorubasystems.com" && echo && sleep 2
		echo -e "	\033[33m	End of program. O dabọ!\033[0m" && sleep 1
		echo && exit 0
	# unexpected, failsafe case	
	else
		msg="Unexpected user_response_code value returned. Exiting now..."
        lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"		
	fi
}

# oral questions just serve a series of phrases, with no specific answer given
# if quiz type is oral, just iterate over as a list
function serve_oral_question() {
	question_num="$1"
	# if question is a colon separated lines, print a listing
	yoruba_oral_question="${current_yoruba_oral_questions[$question_num]}"
	echo "$yoruba_oral_question" | grep -q ':'
	isList=$?
	if [ $isList -eq 0 ]	# 0 means colon delimited oral question lines are present
	then
		enum_list "$yoruba_oral_question"		
	else
		echo -e "		${yoruba_oral_question}"
	fi
}
##############################
function enum_list() {
	list=$1 #
	while [ ${#list} -gt 0 ]
	do
		item=${list%%':'*}
		list=${list#"${item}:"} 
		echo -e "		$item" # 
	done
}

##############################