#!/bin/bash
#: Title		:yoruba-quiz-main.sh
#: Date			:2021-04-03
#: Author		:adebayo10k
#: Description	: Script to help us practice our Yorùbá vocabulary. 
#: Description	: A proof-of-concept quiz application for Yorùbá language learners.
#: Description	: Uses an AWS S3 bucket as quiz data source.
#: Description	: Prototype.

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

### Library functions have now been read-in ###

# verify existence of included dependencies
if [ -d "${command_dirname}/includes" ] && \
[ -n "$(ls ${command_dirname}/includes)" ]
then
	for file in "${command_dirname}/includes"/*
	do
		source "$file"
	done
else
	msg="Required file not found. Returning non-zero exit code. Exiting now..."
	lib10k_exit_with_error "$E_REQUIRED_FILE_NOT_FOUND" "$msg"
fi

### Included file functions have now been read-in ###

# CALLS TO FUNCTIONS DECLARED IN helper.inc.sh
#==========================
check_all_program_conditions || exit 1
display_program_headers

##############################

function main(){
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
	hr='#================================#'
	
	##############################
	# FUNCTION CALLS:
	##############################

    # check that we have a reference to at least one JSON data file.
    check_for_data_urls "${dev_quiz_urls[@]}"

	# Keep running quizzes until user says stop.
	while true
	do
        # CALLS TO FUNCTIONS DECLARED IN get-quiz-data.inc.sh
	    #==========================
        get_user_quiz_choice "${dev_quiz_urls[@]}" || exit 1
        get_quiz_data_file "$user_quiz_choice_num" "${dev_quiz_urls[@]}"
        
        # CALLS TO FUNCTIONS DECLARED IN build-quiz.inc.sh
	    #==========================
        build_quiz "$local_quiz_file"

        # CALLS TO FUNCTIONS DECLARED IN run-quiz.inc.sh
	    #==========================
		display_quiz_info "$quiz_category_string" "$quiz_length" "$quiz_play_sequence_default_string" "$quiz_english_phrases_string" "$quiz_yoruba_phrases_string"
        
		display_quiz_instructions "$quiz_instructions_string"
		setup_quiz_sequence "$quiz_play_sequence_default_string" "$quiz_length"
		play_quiz_questions "$num_range_arr" "$quiz_type_string"
		finish_quiz
        
	done	
} ## end main

##############################
####  FUNCTION DECLARATIONS  
##############################


main "$@"; exit
