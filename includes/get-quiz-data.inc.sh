#!/bin/bash

##############################
function get_user_quiz_choice() {

    local quiz_num_selected="false"
    echo && \
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
            echo && echo "Quiz Selected OK."
        else
            echo && echo "No Quiz Selected. Try Again..."
            continue
        fi    
    done
}

##############################
function get_quiz_data_file() {

    # assign  a value to remote_quiz_file_url
    # using user_quiz_choice_num on ${dev_quiz_urls[@]})
    remote_quiz_file_url="${dev_quiz_urls[${user_quiz_choice_num}-1]}"

    # assign value to local_quiz_file
    # derived from the remote_quiz_file_url
    local_quiz_file="${command_dirname}/data/${remote_quiz_file_url##*/}"

    # if local_quiz_file already exists, and is not empty, then no need to fetch it down again.
    local_quiz_file_line_count=$(wc -l "$local_quiz_file" 2>/dev/null | sed 's/[^0-9]//g')
    if [ -f "$local_quiz_file" ] && \
    [ -r "$local_quiz_file" ] && \
    [ $local_quiz_file_line_count -gt 30 ] # 30 is arbitrary minimum for a 'good file'
    then
        # ..
        echo && echo "Requested quiz file already exists locally OK."
    else
        create_data_dirs

        request_quiz_data
           
        # once a new local quiz file is written, make it ro \
        # so that it can be used again in future, unchanged
        write_decoded_quiz_data && chmod 440 "$local_quiz_file" && \
        echo && echo "Local quiz data file created OK" || \
        msg="Could not write local JSON quiz file. Exiting now..." || \
        lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg"
    fi    
}

##############################
function create_data_dirs() {    

    # then create touch the local_quiz_file
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
    quiz_data="$(curl -s "$remote_quiz_file_url" 2>/dev/null)"

    # Data transfer successful?
    [ $? -ne 0 ] && msg="cURL Failed. Exiting..." && \
    lib10k_exit_with_error "$E_UNKNOWN_ERROR" "$msg" || \
    echo && echo "cURL Client Succeeded."

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