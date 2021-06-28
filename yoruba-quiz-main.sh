#!/bin/bash
#: Title		:yoruba-quiz-main.sh
#: Date			:2021-04-03
#: Author		:adebayo10k
#: Version		:1.0
#: Description	: script to help us practice our Yorùbá vocabulary. \ 
#: Description	: a prototype quiz application for Yorùbá language learners
#: Description	:
#: Options		:
##

	#######################################################################

	## REMEMBER TO CAPITALISE ONLY THOSE VARIABLES THAT ARE DEFINITELY
	## BEING EXPORTED TO THE ENVIRONMENT! UNTIL THEN, USE LOWERCASE. 
	## or, should we..
	## CAPITALISE VARIABLES TO DISTINGUISH THEM FROM COMMANDS?
	## let's look at what others do on github.

	#######################################################################


function main 
{
	###############################################################################################
	# GLOBAL VARIABLE DECLARATIONS:
	###############################################################################################


	## EXIT CODES:
	export E_UNEXPECTED_BRANCH_ENTERED=10
	export E_OUT_OF_BOUNDS_BRANCH_ENTERED=11
	export E_INCORRECT_NUMBER_OF_ARGS=12
	export E_UNEXPECTED_ARG_VALUE=13
	export E_REQUIRED_FILE_NOT_FOUND=20
	export E_REQUIRED_PROGRAM_NOT_FOUND=21
	export E_UNKNOWN_RUN_MODE=30
	export E_UNKNOWN_EXECUTION_MODE=31
	export E_FILE_NOT_ACCESSIBLE=40
	export E_UNKNOWN_ERROR=32


	#######################################################################

	max_expected_no_of_program_parameters=0
	actual_no_of_program_parameters=$#
	
	abs_filepath_regex='^(/{1}[A-Za-z0-9._~:@-]+)+/?$' # absolute file path, ASSUMING NOT HIDDEN FILE, ...
	all_filepath_regex='^(/?[A-Za-z0-9._~:@-]+)+(/)?$' # both relative and absolute file path
	actual_host=$(hostname)
	project_root_dir="$(dirname $0)"
	#echo "project root directory is now set to: $project_root_dir"

	# JSON quiz data file locations
	quiz_data_week_01="${project_root_dir}/../app-data/review-class-week-01/quiz-week-01.json"
	quiz_data_week_02="${project_root_dir}/../app-data/review-class-week-02/quiz-week-02.json"
	quiz_data_week_03="${project_root_dir}/../app-data/review-class-week-03/quiz-week-03.json"
 	quiz_data_week_04="${project_root_dir}/../app-data/review-class-week-04/quiz-week-04.json"
 	quiz_data_week_05="${project_root_dir}/../app-data/review-class-week-05/quiz-week-05.json"
  quiz_data_week_06="${project_root_dir}/../app-data/review-class-week-06/quiz-week-06.json"
	quiz_data_week_07="${project_root_dir}/../app-data/review-class-week-07/quiz-week-07.json"
	quiz_data_week_08="${project_root_dir}/../app-data/review-class-week-08/quiz-week-08.json"
 	quiz_data_week_09="${project_root_dir}/../app-data/review-class-week-09/quiz-week-09.json"
 	quiz_data_week_10="${project_root_dir}/../app-data/review-class-week-10/quiz-week-10.json"

	num_of_players=1 # default value for quizzes to clear screen after every answer 
	num_of_responses_to_display="$num_of_players"
	quiz_length=
	quiz_type=
	quiz_play_sequence_default_string=
	declare -a num_range_arr=()

	declare -a current_english_phrases_list=()
	declare -a current_yoruba_phrases_list=()
	declare -A current_yoruba_translations

	###############################################################################################

	check_program_requirements

	display_program_header


	###############################################################################################
	# PROGRAM-SPECIFIC FUNCTION CALLS:	
	###############################################################################################

	# keep running quizzes until user says stop
	while true
	do

		get_user_quiz_week_choice

		get_user_player_count_choice
    
    # we now have all configuration instructions that we needed from user
		
    call_user_selected_review_week_builder

    # returns here when the chosen week of quizzes has finished

		echo -e "\033[33m		QUIZ FINISHED!\033[0m" && sleep 1 && echo
		read

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

# included source files for common header functions
source ./common-src/header-functions.sh


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
###############################################################################################
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
###############################################################################################
# iterate over num_range_arr numbers array to select questions in the global current quiz
function ask_quiz_questions()
{
	
	echo && echo && echo
	
	# display quiz theme and instructions
	echo -e "${quiz_theme_string}:"
	for line in "${quiz_instructions_array[@]}"
	do
		echo -e "$line"
	done

	read
	
	echo "$quiz_length questions"
	read
	
	# create a number sequence to 'pilot' the quiz order
	if [[ "$quiz_play_sequence_default_string" = 'shuffled' ]]
	then
		make_shuffled_num_range 0 "$(( ${#current_english_phrases_list[@]} - 1 ))"
	elif [[ "$quiz_play_sequence_default_string" = 'ordered' ]]
	then
		make_ordered_num_range 0 "$(( ${#current_english_phrases_list[@]} - 1 ))"
	else
		## exit with error code and message
		echo "quiz play sequence not set"
		exit 1
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
		
		echo && echo && echo # for positioning and display of next terminal output	only	


		# handle quiz question serve method based on the quiz_type_string
		if [[ "$quiz_type_string" = 'vocabulary' ]]
		then
			serve_vocabulary_question "$elem"
		elif [[ "$quiz_type_string" = 'oral' ]]
		then
			serve_oral_question "$elem"
		else
			## exit with error code and message
			echo "quiz type not set"
			exit 1
		fi

		num_of_responses_showing=$((num_of_responses_showing + 1))
		read	# wait for user to acknowledge answer

	done

}

###############################################################################################
# vocabulary questions wait for user to respond before displaying answer
function serve_vocabulary_question() 
{
	num=$1

	eng_word="${current_english_phrases_list[$num]}"
	echo -e "		$eng_word" # -e because some english phrases include Yoruba names
	read	# wait for user to answer		

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

# class review quiz creation functions
source "${project_root_dir}/yoruba-quiz-builder.sh"


##############################################################

# included source files for user menu options
source "${project_root_dir}/../app-data/review-week-menu.sh"


##############################################################
function get_user_player_count_choice() 
{
		echo -e "\033[33mHOW MANY QUIZ PLAYERS?.\033[0m" && sleep 1 && echo

		read num_of_players
		num_of_responses_to_display="$num_of_players"
}

##############################################################

function call_user_selected_review_week_builder() 
{

	clear && echo

  # calls included file function to assemble data structures for the specific, user-selected quiz week

	case $quiz_week_choice in
		'1')	build_week_quizzes "$quiz_data_week_01"
			;;
		'2')	build_week_quizzes "$quiz_data_week_02"
			;;
		'3')	build_week_quizzes "$quiz_data_week_03"
			;;
		'4')	build_week_quizzes "$quiz_data_week_04"
			;;
		'5')	build_week_quizzes "$quiz_data_week_05"
			;;
    '6')	build_week_quizzes "$quiz_data_week_06"
			;;
		'7')	build_week_quizzes "$quiz_data_week_07"
			;;
		'8')	build_week_quizzes "$quiz_data_week_08"
			;;
		'9')	build_week_quizzes "$quiz_data_week_09"
			;;
		'10')	build_week_quizzes "$quiz_data_week_10"
			;;
		*)  
	esac
	
}

##############################################################

main "$@"; exit
