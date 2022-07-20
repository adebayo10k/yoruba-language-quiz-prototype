#!/bin/bash
#: Title		:yoruba-quiz-main.sh
#: Date			:2021-04-03
#: Author		:adebayo10k
#: Description	: Script to help us practice our Yorùbá vocabulary. 
#: Description	: A proof-of-concept quiz application for Yorùbá language learners.
#: Description	: Uses an AWS S3 bucket as quiz data source.
#: Description	: Prototype.

## THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:

command_fullpath="$(readlink -f $0)" 
command_basename="$(basename $command_fullpath)"
command_dirname="$(dirname $command_fullpath)"

# verify existence of library dependencies
if [ -d "${command_dirname}/shared-functions-library" ] && \
[ -n "$(ls ${command_dirname}/shared-functions-library | grep  'shared-bash-')" ]
then
	for file in "${command_dirname}/shared-functions-library"/shared-bash-*
	do
		source "$file"
	done
else
	# return a non-zero exit code with native exit
	echo "Required file not found. Returning non-zero exit code. Exiting now..."
	exit 1
fi

# verify existence of included dependencies
if [ -d "${command_dirname}/includes" ] && \
[ -n "$(ls ${command_dirname}/includes)" ]
then
	for file in "${command_dirname}/includes"/*
	do
		source "$file"
	done
else
	# return a non-zero exit code with native exit
	echo "Required file not found. Returning non-zero exit code. Exiting now..."
	exit 1
fi

## THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!

function main(){
	##############################
	# GLOBAL VARIABLE DECLARATIONS:
	##############################
	program_title="yoruba quiz prototype"
	original_author="damola adebayo"
	program_dependencies=("vi" "jq" "shuf" "seq" "curl")

	declare -i max_expected_no_of_program_parameters=0
	declare -i min_expected_no_of_program_parameters=0
	declare -ir actual_no_of_program_parameters=$#
	all_the_parameters_string="$@"

	declare -a authorised_host_list=()
	actual_host=`hostname`


	#num_of_players=1 # default value for quizzes to clear screen after every answer
  #min_players=1
  #max_players=4

    

    user_quiz_choice_num=

    remote_quiz_file_url=
    local_quiz_file=
    quiz_data=


	num_of_responses_to_display=1
	quiz_length=
	quiz_type=
	quiz_play_sequence_default_string=
	declare -a num_range_arr=()
    quiz_week_choice=
  

	declare -a current_english_phrases_list=()
	declare -a current_yoruba_phrases_list=()
	declare -A current_yoruba_translations
	
	##############################
	# FUNCTION CALLS:
	##############################
	if [ ! $USER = 'root' ]
	then
		## Display a program header
		lib10k_display_program_header "$program_title" "$original_author"
		## check program dependencies and requirements
		lib10k_check_program_requirements "${program_dependencies[@]}"
	fi

	# check the number of parameters to this program
	lib10k_check_no_of_program_args
	# controls where this program can be run, to avoid unforseen behaviour
	lib10k_entry_test


	##############################
	# PROGRAM-SPECIFIC FUNCTION CALLS:	
	##############################

    # check that the JSON data files are available and readable
    get_quiz_names

	# keep running quizzes until user says stop
	while true
	do

        get_user_quiz_choice
        #echo "user_quiz_choice_num : $user_quiz_choice_num"

        get_quiz_data_file

        exit 0

        # we now have all configuration instructions that we needed from user
        #call_user_selected_review_week_builder

        # returns here when the chosen week of quizzes has been built, run and finished
        echo -e "\033[33m		QUIZ FINISHED!\033[0m" && sleep 1 && echo
        echo "Press ENTER to continue..." && read # user acknowledges info

	    echo && echo -e "\033[33m	RUN ANOTHER QUIZ? [Y/n]\033[0m" && sleep 1 && echo

	    	read more_quizzing_response

	    	case $more_quizzing_response in
	    		[yY])	echo && echo "Launching quizzes now..." && echo && sleep 2
        		continue
	    					;;
	    		[nN])	echo
	    					echo "Ok, see you next time!" && sleep 1
	    					echo -e "\033[33m	END OF PROGRAM. GOODBYE!\033[0m" && sleep 1 && echo
	    					exit 0
	    					;;			
	    		*) 	echo " Needed a Y or N...Quitting" && echo && sleep 1
	    					echo -e "\033[33m	END OF PROGRAM. GOODBYE!\033[0m" && sleep 1 && echo
	    					exit 0
	    					;;
	    	esac

	    done
	
} ## end main

##############################
####  FUNCTION DECLARATIONS  
##############################

function get_quiz_names() {
    # 
    [ ${#dev_quiz_urls[@]} -gt 0 ] || \
    msg="Quiz data not available. Nothing to do. Exiting now..." || \
    lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
}

##############################
function get_user_quiz_choice() {

    local quiz_num_selected="false"
    echo -e "\033[33mEnter the NUMBER (eg. 2) of the quiz you want to try...\033[0m"

    while [[ $quiz_num_selected =~ 'false' ]]
    do
        bn_count=0
        # list quiz files from the dev_quiz_urls array
        for url in "${dev_quiz_urls[@]}"
        do
            bn_count=$((bn_count + 1))
            echo "$bn_count : ${url##*/}"
        done

        read user_quiz_choice_num
    
        # NOTE: discovered that regex only need be single quoted when assigned to variable.
        if [[ "$user_quiz_choice_num" =~ ^[0-9]+$ ]] && \
            [ "$user_quiz_choice_num" -ge 1 ] && \
            [ "$user_quiz_choice_num" -le ${#dev_quiz_urls[@]} ]
        then
            quiz_num_selected="true"
            echo "Quiz Selected OK."
        else
            echo "No Quiz Selected. Try Again..."
            continue
        fi    
    done
}

##############################
function get_quiz_data_file() {

    create_local_quiz_file

    request_quiz_data
   
    write_decoded_quiz_data    
}

##############################
function create_local_quiz_file() {

    # assign  a value to remote_quiz_file_url (json input file)
    # ( using user_quiz_choice_num on ${dev_quiz_urls[@]})
    remote_quiz_file_url="${dev_quiz_urls[${user_quiz_choice_num}-1]}"
    echo "remote_quiz_file_url: $remote_quiz_file_url"

    # assign value to local_quiz_file (json conversion output file)
    # derived from the remote_quiz_file_url
    local_quiz_file="${command_dirname}/data/${remote_quiz_file_url##*/}"
    echo "local_quiz_file: $local_quiz_file"

    # touch the local_quiz_file
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

    #local quiz_data=    
    quiz_data="$(cat "$remote_quiz_file_url")" 
    #quiz_data="$(curl -s https://yoruba-quiz.s3.eu-west-2.amazonaws.com/test-quiz-data-uc-wk01.json 2>/dev/null)"
    #quiz_data="$(curl -s https://yoruba-quiz.s3.eu-west-2.amazonaws.com/test-quiz-data-uc-wk04.json 2>/dev/null)"

    # Data transfer successful?
    [ $? -ne 0 ] && msg="cURL Failed. Exiting..." && \
    lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg" || \
    echo "cURL Client Succeeded."

    # JSON-like data received?
    if [ -n "$quiz_data" ] && echo $quiz_data | grep '{' >/dev/null 2>&1 
    then
    	echo "JSON Downloaded OK."
    else
    	msg="Could not retrieve a valid JSON file. Exiting now..."
        lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
    fi
}

##############################
function write_decoded_quiz_data() {

    local tmp_line
    # write decoded quiz data to the local quiz file
    for line in "$quiz_data"
    do
       tmp_line="$(echo -e "$line")"
       echo -e "$tmp_line" >> $local_quiz_file
     done # end while
}

##############################





# populates a globally accessible array with shuffled integer values
function make_shuffled_num_range() {

	lower_limit=$1 # array start index
	upper_limit=$2 # (array size - 1) is passed in

	num_range_arr=()	# reset this global variable
	for index in "$(shuf -i "$1"-"$2")"
	do
		num_range_arr+=("${index}") # append an indexed array of shuffled numbers
	done
}
##############################
# populates a globally accessible array with ordered, sequenced integer values
function make_ordered_num_range()
{
	lower_limit=$1 # array start index
	upper_limit=$2 # (array size - 1) is passed in

	num_range_arr=()	# reset this global variable
	for index in "$(seq "$lower_limit" "$upper_limit")"
	do
		num_range_arr+=("${index}") # append an indexed array of sequenced numbers
	done
}
##############################
# iterate over num_range_arr numbers array to select questions in the global current quiz
function ask_quiz_questions()
{
    clear # clear console before showing new quiz information

    # display:
    # quiz name (unique)
    # quiz size (number of questions)
    # quiz play sequence (ordered or shuffled)
    # quiz content (a preview)
    # quiz instructions 

	# display quiz theme (or name) and instructions
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

    echo "Press ENTER to continue..." && read # user acknowledges info
    clear

    # quiz instructions 
	for line in "${quiz_instructions_array[@]}"
	do
		echo -e "$line"
	done

	echo "Press ENTER to continue..." && read # user acknowledges info

	
	# create a number sequence to 'pilot' the quiz order
	if [[ "$quiz_play_sequence_default_string" = 'shuffled' ]]
	then
		make_shuffled_num_range 0 "$(( ${#current_english_phrases_list[@]} - 1 ))"
	elif [[ "$quiz_play_sequence_default_string" = 'ordered' ]]
	then
		make_ordered_num_range 0 "$(( ${#current_english_phrases_list[@]} - 1 ))"
	else
		## exit with error code and message
        msg="quiz play sequence not set. Exiting now..."
		lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
	fi

	# initialise before quiz starts
	num_of_responses_showing=0 
	is_first_quiz_question='true'

	for elem in ${num_range_arr[@]}
	do
		
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
		
		echo && echo && echo # for positioning and display of next console output	only	

		# handle quiz question serve method based on the quiz_type_string
		if [[ "$quiz_type_string" = 'vocabulary' ]]
		then
			serve_vocabulary_question "$elem"
		elif [[ "$quiz_type_string" = 'oral' ]]
		then
			serve_oral_question "$elem"
		else
			## exit with error code and message
            msg="quiz type not set. Exiting now..."
            lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
		fi

		num_of_responses_showing=$((num_of_responses_showing + 1))
		read	# wait for user to acknowledge answer

	done

}

##############################
# vocabulary questions wait for user to respond before displaying answer
function serve_vocabulary_question() 
{
	num=$1

	eng_word="${current_english_phrases_list[$num]}"
    # -e because some english phrases include Yoruba names
	echo -e "		$eng_word" && echo 
    echo "Press ENTER to see translation..." && read # wait for user to answer
	#read	# wait for user to answer

	# if translation is a colon separated list, print a listing
	translatedString="${current_yoruba_translations[$eng_word]}"
	echo "$translatedString" | grep -q ':'
	isList=$?
	if [ $isList -eq 0 ]	# 0 means colon delimited translation lines/list was found
	then
		enum_list "$translatedString"
	else
		echo -e "		${translatedString}"
	fi
}

# oral questions just serve a series of phrases, with no specific answer given
# if quiz type is oral, just iterate over as a list
function serve_oral_question() 
{
	num=$1
	# if question is a colon separated lines, print a listing
	yoruba_oral_question="${current_yoruba_oral_questions[$num]}"
	echo "$yoruba_oral_question" | grep -q ':'
	isList=$?
	if [ $isList -eq 0 ]	# 0 means colon delimited oral question lines are present
	then
		enum_list "$yoruba_oral_question"		
	else
		echo -e "		${yoruba_oral_question}"
	fi
}

function enum_list()
{
	list=$1 #
	while [ ${#list} -gt 0 ]
	do
		item=${list%%':'*}
		list=${list#"${item}:"} 
		echo -e "		$item" # 
	done
}

##############################
##function get_user_player_count_choice() 
##{
##	echo -e "\033[33mHOW MANY QUIZ PLAYERS? ["${min_players}"-"${max_players}"].\033[0m"
##
##    read num_of_players
##    
##    # NOTE: discovered that regex only need be single quoted when assigned to variable.
##    if  [[ "$num_of_players" =~ ^[0-9]+$ ]] && \
##    [ "$num_of_players" -ge "$min_players" ] && \
##    [ "$num_of_players" -le "$max_players"  ]  #
##    then
##      num_of_responses_to_display="$num_of_players"
##    else
##      ## exit with error code and message
##      msg="The number of players you entered is bad. Exiting now..."
##	  lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
##    fi
##}
##

##############################

##function call_user_selected_review_week_builder() 
##{
##  # calls included file function to assemble data structures for the specific, user-selected quiz week
##  #local quiz_week_choice="$1"
##	case $quiz_week_choice in
##		'1')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_01]}"
##			;;
##	#	'2')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_02]}"
##	#		;;
##	#	'3')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_03]}"
##	#		;;
##		'4')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_04]}"
##			;;
##	#	'5')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_05]}"
##	#		;;
##	#	'6')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_06]}"
##	#		;;
##	#	'7')	build_week_quizzes "${dev_quiz_urls[quiz_data_week_07]}"
##	#		;;
##		*)  # NOTE: THIS SHOULD BE PART OF SOME WHILE LOOP
##	esac
##	
##}
##
##############################

main "$@"; exit
