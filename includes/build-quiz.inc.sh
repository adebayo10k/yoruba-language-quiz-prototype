#!/bin/bash

# this function imports the json quiz week data and then structures
# it into the arrays needed by the main quiz execution function - run_quiz()

function build_quiz() 
{
	local path_to_quiz_data="$1"
    local current_yoruba_phrases_list
    declare -a current_yoruba_phrases_list=()
    
	# NOTES ON THE jq PROGRAM:
    #==================  
    # the -r option returns unquoted, line-separated string
	# the -j option gives unquoted and no newline
	# no option gives quoted, line-separated strings

	# values that are returned by jq as 'concatenated strings to be arrayed' get an IFS.
	# single string values don't. 
    # conveniently, the same sed command is applied to both (all) cases though!
	# therefore, for consistent handling, everything was single-quoted.

	# IMPORT YORUBA-REVIEW-CLASS ATTRIBUTES FROM JSON AS SINGLE STRINGS:
	#===============================================

	class_review_name_string=$(cat "$path_to_quiz_data" | \
    jq -j '.classReviewName' | \
    sed -f "$sed_script" \
    )
    
	class_review_audio_dir_string=$(cat "$path_to_quiz_data" | \
    jq -j '.classReviewAudioDir' | \
    sed -f "$sed_script" \
    )
	
	# IMPORT QUIZ KEY ATTRIBUTE FROM JSON AS A SINGLE IFS (where there are multiple quizzes) STRING:
	#=============================================================

	quiz_name_string=$(cat "$path_to_quiz_data" | \
    jq -j '.classReviewQuizSet[] | .quizName' | \
    sed -f "$sed_script" \
    )

	# put the key(s) into an indexed array and then loop over it to filter for each quizzes 
	# data, one quiz at a time

	OIFS=$IFS
	IFS='|'

	quiz_name_array=( $quiz_name_string )

	IFS=$OIFS

	for quiz_id in "${quiz_name_array[@]}"
	do
		#echo "quiz_id: $quiz_id" && echo && echo
		create_quiz_data_structures "$quiz_id"
	done
}

##############################

# This function builds data structures for the selected quiz and calls function to run that quiz. 
# NOTE: arrays seem more useful in BASH than long strings from jq.
function create_quiz_data_structures
{
	local id="$1"	
	# the unique quiz identifier (aka quiz_id) with single quotes added back
	id="'${id}'"

	quiz_type_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizType' | \
    sed -f "$sed_script" \
    )

    quiz_category_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizCategory' | \
    sed -f "$sed_script" \
    )

	quiz_play_sequence_default_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizPlaySequenceDefault' | \
    sed -f "$sed_script" \
    )

	quiz_instructions_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizInstructions[]' | \
    sed -f "$sed_script" \
    )

	OIFS=$IFS
	IFS='|'

	quiz_instructions_array=( $quiz_instructions_string )

	IFS=$OIFS

	# IMPORT QUIZ PHRASES FROM JSON AS A SINGLE STRING:
	#===================================

	# english phrases
	###########
	## give string an IFS for array creation, having preserved spaced phrases
	quiz_english_phrases_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizPhraseSet[] | 
    .englishPhrase' | \
    sed -f "$sed_script" \
    )

	# yoruba phrases
	###########
	## give string an IFS for array creation, having preserved spaced phrases
	quiz_yoruba_phrases_string=$(cat "$path_to_quiz_data" | \
    jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | 
    select(.quizName==$quiz_id) | 
    .quizPhraseSet[] | 
    .yorubaPhrase'  | \
    sed -f "$sed_script" \
    )

	# CREATE AN INDEXED ARRAY IN MEMORY FOR EACH PHRASE LIST:
	#=======================================

	OIFS=$IFS
	IFS='|'

	# assign the current_english_phrases_list array
	# create array after separating single-quoted phrases with a character
	current_english_phrases_list=( $quiz_english_phrases_string )
	#echo "${current_english_phrases_list[@]}"
	#echo && echo

	# assign the current_yoruba_phrases_list array
	# current_yoruba_phrases_list array is only needed to construct the associative current_yoruba_translations array
	current_yoruba_phrases_list=( $quiz_yoruba_phrases_string )
	#echo "${current_yoruba_phrases_list[@]}" #debug
	#echo && echo

	IFS=$OIFS

	#echo "${#current_english_phrases_list[@]} english elements"
	#echo "${#current_yoruba_phrases_list[@]} yoruba elements"

  	# NOW CONSTRUCT AN ASSOCIATIVE ARRAY FROM THE TWO INDEXED ARRAYS
 	#===============================================

	for ((i=0; i<${#current_english_phrases_list[@]}; i++));
	do
		current_yoruba_translations["${current_english_phrases_list[$i]}"]="${current_yoruba_phrases_list[$i]}"
	done

	#===============================================

	# set quiz_length variable for later use
	quiz_length="${#current_english_phrases_list[@]}"
}
