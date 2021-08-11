#!/bin/bash

# this function imports the json quiz week data and then structures
# it into the arrays needed by the main quiz execution function

function build_week_quizzes() 
{
	path_to_quiz_data="$1"

	#echo "path_to_quiz_data passed in and set to $path_to_quiz_data"

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

	class_review_name_string=$(cat "$path_to_quiz_data" | jq -j '.classReviewName' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//")
	#echo "class_review_name_string:"
	#echo -e "$class_review_name_string"
	#echo && echo

	class_review_audio_dir_string=$(cat "$path_to_quiz_data" | jq -j '.classReviewAudioDir' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "class_review_audio_dir_string:"
	#echo -e "$class_review_audio_dir_string"
	#echo && echo
	
	# IMPORT QUIZ KEY ATTRIBUTE FROM JSON AS A SINGLE IFS (where there are multiple quizzes) STRING:
	#=============================================================

	quiz_name_string=$(cat "$path_to_quiz_data" | jq -j '.classReviewQuizSet[] | .quizName' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_name_string:"
	#echo -e "$quiz_name_string"
	#echo && echo

	# put the key(s) into an indexed array and then loop over it to filter for each quizzes 
	# data, one quiz at a time

	OIFS=$IFS
	IFS='|'

	quiz_name_array=( $quiz_name_string )
    #echo "quiz_name_array:"
    #echo "${quiz_name_array[@]}"
    #echo && echo
    #echo "quiz_name_array size:"
    #echo "${#quiz_name_array[@]}"
    #echo && echo

	IFS=$OIFS

	for quiz_id in "${quiz_name_array[@]}"
	do
		#echo "quiz_id: $quiz_id" && echo && echo
		build_and_run_each_quiz "$quiz_id"
	done
}

##########################################################

# NOTE: arrays seem more useful in BASH than long strings from jq
function build_and_run_each_quiz
{
	id="$1"	
	# the unique quiz identifier (aka quiz_id) with single quotes added back
	id="'${id}'"
	#echo -e "unique id to FILTER from JSON: $id" 

	quiz_type_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizType' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_type_string:"
	#echo -e "$quiz_type_string"
	#echo && echo

    quiz_category_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizCategory' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//")
    #echo "quiz_category_string:"
    #echo -e "$quiz_category_string"
	#echo && echo

	quiz_play_sequence_default_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizPlaySequenceDefault' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_play_sequence_default_string:"
	#echo -e "$quiz_play_sequence_default_string"
	#echo && echo

	quiz_instructions_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizInstructions[]' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_instructions_string:"
	#echo -e "$quiz_instructions_string"
	#echo && echo

	
	OIFS=$IFS
	IFS='|'

	quiz_instructions_array=( $quiz_instructions_string )
	#echo "quiz_instructions_array:"
    #echo "${quiz_instructions_array[@]}"
    #echo && echo
    #echo "quiz_instructions_array size:"
    #echo "${#quiz_instructions_array[@]}"
    #echo && echo


	IFS=$OIFS

	# IMPORT QUIZ PHRASES FROM JSON AS A SINGLE STRING:
	#===================================

	# english phrases
	###########
	## give string an IFS for array creation, having preserved spaced phrases
	quiz_english_phrases_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizPhraseSet[] | .englishPhrase' | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_english_phrases_string:"
	#echo -e "$quiz_english_phrases_string"
	#echo && echo


	# yoruba phrases
	###########
	## give string an IFS for array creation, having preserved spaced phrases
	quiz_yoruba_phrases_string=$(cat "$path_to_quiz_data" | jq -j --arg quiz_id "$id" '.classReviewQuizSet[] | select(.quizName==$quiz_id) | .quizPhraseSet[] | .yorubaPhrase'  | sed "s/''/|/g" | sed "s/^'//" | sed "s/'$//") 
	#echo "quiz_yoruba_phrases_string:"
	#echo -e "$quiz_yoruba_phrases_string"
	#echo && echo


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

    #read # a pause so we can read the debug output

	# run the actual quiz using our current quiz data
	ask_quiz_questions

}
