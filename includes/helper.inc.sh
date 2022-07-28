#! /bin/bash
# This is a helper script to help "the human" to interface appropriately
# with "the program". 

##############################
# GLOBAL VARIABLE DECLARATIONS:
##############################
declare -i max_expected_no_of_program_parameters=1
declare -i min_expected_no_of_program_parameters=0
declare -ir actual_no_of_program_parameters=$#
all_the_parameters_string="$@"
run_mode=${1:-''}

#########################
# FUNCTION DECLARATIONS:
#########################
#
function check_all_program_conditions() {
	local program_dependencies=("vi" "jq" "shuf" "seq" "curl")
	lib10k_check_no_of_program_args
	# validate program parameters
	validate_program_args
	[ $? -eq 0 ] || usage
	# check program dependencies
	lib10k_check_program_requirements "${program_dependencies[@]}"	
}

# 
function validate_program_args() {
	[ -z "$run_mode" ] && return 0
	[ -n "$run_mode" ] && [ $run_mode = 'help' ] && return 1
	[ -n "$run_mode" ] && return 1 # unrecognised parameter passed in
}

function display_program_headers() {
	program_title="yoruba quiz prototype"
	original_author="damola adebayo"
	lib10k_display_program_header "$program_title" "$original_author"
}

# This function always exits program
function usage () {

	cat <<_EOF	
Usage:	$command_basename [help]

A terminal console based vocabulary quiz game.
User selects a quiz and is prompted to translate a series
of basic English language words into Yorùbá.

help	Show this text.

_EOF

exit 0
}

