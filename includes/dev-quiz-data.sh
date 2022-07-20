#!/bin/bash

# AWS S3 bucket object URLs for development quiz data

# JSON quiz data file locations
declare -a dev_quiz_urls=(
  "${command_dirname}/test-quiz-data-uc-wk01.json"
  "${command_dirname}/test-quiz-data-uc-wk04.json"
)

## JSON quiz data file locations
#declare -a dev_quiz_urls=(
#"https://yoruba-quiz.s3.eu-west-2.amazonaws.com/test-quiz-data-uc-wk01.json"
#"https://yoruba-quiz.s3.eu-west-2.amazonaws.com/test-quiz-data-uc-wk04.json"
#)

