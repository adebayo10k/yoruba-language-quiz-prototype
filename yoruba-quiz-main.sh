#!/bin/bash
#: Title		:yoruba-quiz-main.sh
#: Date			:2021-04-03
#: Author		:adebayo10k
#: Version		:1.0
#: Description	: script to help us practice our Yorùbá vocabulary. \ 
#: Description	: a proof-of-concept quiz application for Yorùbá language learners
#: Description	: prototype
#: Options		:
##
	
##################################################################
##################################################################
# THIS STUFF IS HAPPENING BEFORE MAIN FUNCTION CALL:
#===================================

# 1. MAKE SHARED LIBRARY FUNCTIONS AVAILABLE HERE

# make all the shared library functions available to this script
shared_bash_functions_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-functions.inc.sh"
shared_bash_constants_fullpath="${SHARED_LIBRARIES_DIR}/shared-bash-constants.inc.sh"

for resource in "$shared_bash_functions_fullpath" "$shared_bash_constants_fullpath"
do
	if [ -f "$resource" ]
	then
		echo "Required library resource FOUND OK at:"
		echo "$resource"
		source "$resource"
	else
		echo "Could not find the required resource at:"
		echo "$resource"
		echo "Check that location. Nothing to do now, except exit."
		exit 1
	fi
done


# 2. MAKE SCRIPT-SPECIFIC FUNCTIONS AVAILABLE HERE

# must resolve canonical_fullpath here, in order to be able to include sourced function files BEFORE we call main, and  outside of any other functions defined here, of course.

# at runtime, command_fullpath may be either a symlink file or actual target source file
command_fullpath="$0"
command_dirname="$(dirname $0)"
command_basename="$(basename $0)"

# if a symlink file, then we need a reference to the canonical file name, as that's the location where all our required source files definitely will be.
# we'll test whether a symlink, then use readlink -f or realpath -e although those commands return canonical file whether symlink or not.
# 
canonical_fullpath="$(readlink -f $command_fullpath)"
canonical_dirname="$(dirname $canonical_fullpath)"


# this is just development debug information
if [ -h "$command_fullpath" ]
then
	echo "is symlink"
	echo "canonical_fullpath : $canonical_fullpath"
else
	echo "is canonical"
	echo "canonical_fullpath : $canonical_fullpath"
fi

# class review quiz creation functions
source "${canonical_dirname}/yoruba-quiz-builder.inc.sh"

# included source files for user menu options
source "${canonical_dirname}/../app-data/review-week-menu.inc.sh"


# THAT STUFF JUST HAPPENED (EXECUTED) BEFORE MAIN FUNCTION CALL!
##################################################################
##################################################################


function main 
{
	#######################################################################
	# GLOBAL VARIABLE DECLARATIONS:
	#######################################################################

	actual_host=$(hostname)
	unset authorised_host_list
	declare -a authorised_host_list=($HOST_0065 $HOST_0054 $HOST_R001 $HOST_R002)  # allow | deny
	if [[ $(declare -a | grep 'authorised_host_list' 2>/dev/null) ]]
	then
		entry_test
	fi

	declare -i max_expected_no_of_program_parameters=0
	declare -i min_expected_no_of_program_parameters=0
	declare -ir actual_no_of_program_parameters=$#
	all_the_parameters_string="$@"

	program_title=""
	original_author=""
	program_dependencies=("vi" "jq" "curl" "cowsay")

	echo "project root directory is set to: $canonical_dirname"

	# JSON quiz data file locations
	quiz_data_week_01="${canonical_dirname}/../app-data/review-class-week-01/quiz-week-01.json"
	quiz_data_week_02="${canonical_dirname}/../app-data/review-class-week-02/quiz-week-02.json"
	quiz_data_week_03="${canonical_dirname}/../app-data/review-class-week-03/quiz-week-03.json"
 	quiz_data_week_04="${canonical_dirname}/../app-data/review-class-week-04/quiz-week-04.json"
 	quiz_data_week_05="${canonical_dirname}/../app-data/review-class-week-05/quiz-week-05.json"
    quiz_data_week_06="${canonical_dirname}/../app-data/review-class-week-06/quiz-week-06.json"
	quiz_data_week_07="${canonical_dirname}/../app-data/review-class-week-07/quiz-week-07.json"
	quiz_data_week_08="${canonical_dirname}/../app-data/review-class-week-08/quiz-week-08.json"
 	quiz_data_week_09="${canonical_dirname}/../app-data/review-class-week-09/quiz-week-09.json"
 	quiz_data_week_10="${canonical_dirname}/../app-data/review-class-week-10/quiz-week-10.json"

	num_of_players=1 # default value for quizzes to clear screen after every answer
    min_players=1
    max_players=4
	num_of_responses_to_display="$num_of_players"
	quiz_length=
	quiz_type=
	quiz_play_sequence_default_string=
	declare -a num_range_arr=()

	declare -a current_english_phrases_list=()
	declare -a current_yoruba_phrases_list=()
	declare -A current_yoruba_translations

	###############################################################################################

	check_program_requirements "${program_dependencies[@]}"

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
    clear # clear console before showing new quiz information

    # display:
    # quiz name (unique)
    # quiz size (number of questions)
    # quiz play sequence (ordered or shuffled)
    # quiz content (a preview)
    # quiz instructions 

	# display quiz theme (or name) and instructions
    echo "quiz theme (or name):"
    echo -e "${quiz_theme_string}"
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

    read    # user acknowledges info
    clear

    # quiz instructions 
	for line in "${quiz_instructions_array[@]}"
	do
		echo -e "$line"
	done

	read    # user acknowledges info

	
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
function get_user_player_count_choice() 
{
	echo -e "\033[33mHOW MANY QUIZ PLAYERS? ["${min_players}"-"${max_players}"].\033[0m"

    read num_of_players
    
    # validate user input (TODO: separate these out)
    # NOTE: discovered that regex only need be single quoted when assigned to variable.
    if  [[ "$num_of_players" =~ ^[0-9]+$ ]] && [ "$num_of_players" -ge "$min_players" ] && [ "$num_of_players" -le "$max_players"  ]  #
    then
      num_of_responses_to_display="$num_of_players"
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
