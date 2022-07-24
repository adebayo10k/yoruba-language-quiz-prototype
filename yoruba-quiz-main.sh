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

    user_quiz_choice_num=

    remote_quiz_file_url=
    local_quiz_file=
    quiz_data=

    sed_script="${command_dirname}/sed-script.txt"

	quiz_length=
	quiz_play_sequence_default_string=
	declare -a num_range_arr=()
	declare -a current_english_phrases_list=()	
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

    # check that we have a reference to at least one JSON data file.
    check_for_data_urls

	# Keep running quizzes until user says stop.
	while true
	do
        # CALLS TO FUNCTIONS DECLARED IN get-quiz-data.inc.sh
	    #==========================
        get_user_quiz_choice
        get_quiz_data_file
        #pause here. see if this data is useful to user. if so, pause to allow read
        echo && echo "Quiz data available. Press Enter to continue..."
        read

        # CALLS TO FUNCTIONS DECLARED IN build-quiz.inc.sh
	    #==========================
        build_quiz "$local_quiz_file"

        # CALLS TO FUNCTIONS DECLARED IN run-quiz.inc.sh
	    #==========================
        run_quiz

        # give user option to continue playing or end program
        get_user_continue_response
        echo "yorubasystems.com" && echo && sleep 2
	done	
} ## end main

##############################
####  FUNCTION DECLARATIONS  
##############################

function check_for_data_urls() {
    # 
    [ ${#dev_quiz_urls[@]} -gt 0 ] || \
    msg="Quiz data not available. Nothing to do. Exiting now..." || \
    lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
}

##############################
function get_user_continue_response() {

    echo -e "\033[33m		QUIZ FINISHED!\033[0m" && sleep 1 && echo
    echo "Press ENTER to continue..." && read # user acknowledges info
    echo && echo -e "\033[33m	RUN ANOTHER QUIZ? [Y/n]\033[0m" && sleep 1 && echo
    read more_quizzing_response

    case $more_quizzing_response in
    	[yY])	echo && echo "Launching quizzes now..." && echo && sleep 2
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
}

##############################
main "$@"; exit
