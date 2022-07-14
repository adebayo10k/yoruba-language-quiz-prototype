#!/bin/bash
#: Title		:yoruba-quiz-main.sh
#: Date			:2021-04-03
#: Author		:adebayo10k
#: Version		:
#: Description	: script to help us practice our Yorùbá vocabulary. \ 
#: Description	: a proof-of-concept quiz application for Yorùbá language learners
#: Description	: prototype
#: Options		:
##

## THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:

command_fullpath="$(readlink -f $0)" 
command_basename="$(basename $command_fullpath)"
command_dirname="$(dirname $command_fullpath)"

for file in "${command_dirname}/shared-functions-library"/shared-bash-*
do
	source "$file"
done

for file in "${command_dirname}/includes"/*
do
	source "$file"
done

## THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!

function main(){
	##############################
	# GLOBAL VARIABLE DECLARATIONS:
	##############################
	program_title="yoruba quiz prototype"
	original_author="damola adebayo"
	program_dependencies=("vi" "jq" "shuf" "seq")

	declare -i max_expected_no_of_program_parameters=0
	declare -i min_expected_no_of_program_parameters=0
	declare -ir actual_no_of_program_parameters=$#
	all_the_parameters_string="$@"

	declare -a authorised_host_list=()
	actual_host=`hostname`

	

	num_of_players=1 # default value for quizzes to clear screen after every answer
    min_players=1
    max_players=4
	num_of_responses_to_display="$num_of_players"
	quiz_length=
	quiz_type=
	quiz_play_sequence_default_string=
	declare -a num_range_arr=()
    quiz_week_choice=1 # default value for now

	declare -a current_english_phrases_list=()
	declare -a current_yoruba_phrases_list=()
	declare -A current_yoruba_translations

    # JSON quiz data file locations
    declare -A quiz_data_file_locations=(
	    [quiz_data_week_01]="${command_dirname}/../app-data/review-class-week-01/quiz-week-01.json"
	    [quiz_data_week_02]="${command_dirname}/../app-data/review-class-week-02/quiz-week-02.json"
	    [quiz_data_week_03]="${command_dirname}/../app-data/review-class-week-03/quiz-week-03.json"
 	    [quiz_data_week_04]="${command_dirname}/../app-data/review-class-week-04/quiz-week-04.json"
 	    [quiz_data_week_05]="${command_dirname}/../app-data/review-class-week-05/quiz-week-05.json"
        [quiz_data_week_06]="${command_dirname}/../app-data/review-class-week-06/quiz-week-06.json"
	    [quiz_data_week_07]="${command_dirname}/../app-data/review-class-week-07/quiz-week-07.json"
	    [quiz_data_week_08]="${command_dirname}/../app-data/review-class-week-08/quiz-week-08.json"
 	    [quiz_data_week_09]="${command_dirname}/../app-data/review-class-week-09/quiz-week-09.json"
 	    [quiz_data_week_10]="${command_dirname}/../app-data/review-class-week-10/quiz-week-10.json"
	)

	##############################
	
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
    check_quiz_data_exists

	# keep running quizzes until user says stop
	while true
	do

		get_user_player_count_choice
        get_user_quiz_week_choice
   
        # we now have all configuration instructions that we needed from user
		
        call_user_selected_review_week_builder

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




#######################################################################################
####  FUNCTION DECLARATIONS  
#######################################################################################

function check_quiz_data_exists()
{
    for path_to_quiz_data in "${!quiz_data_file_locations[@]}"
    do

        # if path_to_quiz_data not found, exit with error message/suggestion
	    lib10k_test_file_path_valid_form "$path_to_quiz_data"
	    return_code=$?
	    if [ $return_code -ne 0 ]
	    then
	    	msg="Quiz data not yet available. Check https://hub.docker.com/u/adebayo10k for a prototype image of this program. Exiting now..."
	    	lib10k_exit_with_error "$E_UNEXPECTED_ARG_VALUE" "$msg"
        fi

        # if path_to_quiz_data not readable, exit with error message/suggestion
	    lib10k_test_file_path_access "$path_to_quiz_data"
	    return_code=$?
	    if [ $return_code -ne 0 ]
	    then
	    	msg="Quiz data not yet available. Check https://hub.docker.com/u/adebayo10k for a prototype image of this program. Exiting now..."
	    	lib10k_exit_with_error "$E_UNEXPECTED_ARG_VALUE" "$msg"
        fi

    done
}
##############################
# populates a globally accessible array with shuffled integer values
function make_shuffled_num_range()
{
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

##############################################################
function get_user_player_count_choice() 
{
	echo -e "\033[33mHOW MANY QUIZ PLAYERS? ["${min_players}"-"${max_players}"].\033[0m"

    read num_of_players
    
    # NOTE: discovered that regex only need be single quoted when assigned to variable.
    if  [[ "$num_of_players" =~ ^[0-9]+$ ]] && \
    [ "$num_of_players" -ge "$min_players" ] && \
    [ "$num_of_players" -le "$max_players"  ]  #
    then
      num_of_responses_to_display="$num_of_players"
    else
      ## exit with error code and message
      msg="The number of players you entered is bad. Exiting now..."
	  lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
    fi
}

##############################################################

function get_user_quiz_week_choice()
{
    echo -e "\033[33mWHICH QUIZ WEEK?\033[0m"

    read quiz_week_num
    
    # NOTE: discovered that regex only need be single quoted when assigned to variable.
    if  [[ "$quiz_week_num" =~ ^[0-9]+$ ]] # && \
    #[ "$quiz_week_num" -ge "$min_week_num" ] && \
    # [ "$quiz_week_num" -le "$max_week_num"  ]  #
    then
      quiz_week_choice="$quiz_week_num"
    else
      ## exit with error code and message
      msg="The number of players you entered is bad. Exiting now..."
	  lib10k_exit_with_error "$E_UNEXPECTED_BRANCH_ENTERED" "$msg"
    fi
}

##############################################################

function call_user_selected_review_week_builder() 
{
  # calls included file function to assemble data structures for the specific, user-selected quiz week
  #local quiz_week_choice="$1"
	case $quiz_week_choice in
		'1')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_01]}"
			;;
		'2')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_02]}"
			;;
		'3')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_03]}"
			;;
		'4')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_04]}"
			;;
		'5')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_05]}"
			;;
		'6')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_06]}"
			;;
		'7')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_07]}"
			;;
		'8')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_08]}"
			;;
		'9')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_09]}"
			;;
		'10')	build_week_quizzes "${quiz_data_file_locations[quiz_data_week_10]}"
			;;
		*)  
	esac
	
}

##############################################################

main "$@"; exit
