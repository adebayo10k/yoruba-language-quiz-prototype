# yoruba-language-quiz-prototype

## About this Project

Just for the fun and the challenge of it. You can read the [origin story](https://adebayo10k.github.io/projects/yoruba-vocab-test.html) of this project on my GitHub Pages site, so I won't repeat it here.

This program has so far been tested only on 64-bit Ubuntu (20.04) Linux and with its' default, built-in BASH interpreter.

## Files
- yoruba-quiz-main.sh - the main script file.
- includes/helper.inc.sh - functions to assist user with correct program use.
- includes/build-quiz.inc.sh - included functions in which JSON data gets parsed through jq filters.
- includes/dev-quiz-data.inc.sh - included file containing URLs of transport-safe, unicode encoded, development only data files.
- includes/get-quiz-data.inc.sh - functions to download and decode JSON files for the program.
- includes/run-quiz.inc.sh - functions executed during actual quiz play.
- shared-functions-library/shared-bash-constants.inc.sh - common module.
- shared-functions-library/shared-bash-functions.inc.sh - common module.
- data/ - directory created in the project root for the downloaded development data.

## Purpose

The main purpose of this project is to demonstrate one way to reliably transfer remote, JSON structured, Unicode encoded data to a bash shell program application, which then decodes it before use.

To that end, its' value is for developers who develop applications that need to reliably encode, transmit and decode data used by applications running anywhere on the Internet. I suppose that today, that's just the standard case for every developer.

Additionally, the quiz game demonstrates how an application can reliably interpret characters for which no unicode code-points currently exist.


This project sets up the following scenario...
1. Your user is running an application that uses data that may not have unicode code-points, so it's handling during transport may not be reliable.
2. The data is actually located on a remote server, to which the client application knows how to make requests.
    - This program uses an AWS S3 bucket for that remote storage of application data as JSON structured text files. The program uses cURL to make HTTPS requests to that remote storage.
3. When requested, the data must arrive uncorrupted by it's journey across the Internet and through a variety of compressions, decompression, encryptions and decryptions. An appropriate encoding scheme must therefore have been selected for data storage.
4. Safely arriving client-side, the application environment must also be configured to render the symbols of the weird lingo correctly.
5. Subsequent requests for the same file will use the local version, rather than making another web request.


## Dependencies

("jq" "shuf" "seq" "curl")

Unless part of the default Ubuntu Desktop build, the programs I chose to do the work of downloading files etc. are the ones I prefer to use.

## Requirements

This program is run as just the regular, non-privileged user. It does not require you to use `sudo` privileges or run a root user.

## Prerequisites

A reasonable ability to learn new languages.

## Installation

This project includes the separate shared-functions-library repository as a submodule. The clone command must therefore include the `--recurse-submodules` option which will initialise and fetch changes from the submodule repository, like so...

``` bash
git clone --recurse-submodules https://github.com/adebayo10k/yoruba-language-quiz-prototype.git

```

That done, you can optionally create a symbolic link file in a directory in your `PATH` that targets your cloned yoruba-quiz-main.sh executable, something like...

```
ln -s path-to-cloned-repo-root-directory/yoruba-quiz-main.sh ~/${USER}/bin/yoruba-quiz-main.sh
```


## Configuration
### Terminal Font Configuration

Of the 13 pre-installed font styles that can be configured in the Ubuntu Terminal, 7 are considered Yorùbá-safe. That is, they're able to render those weird Yorùbá character symbols without errors. You'll want to set one of these fonts.

- Noto Mono *
- Courier New *
- FreeMono *
- Noto Color Emoji *
- Tlwg Mono *
- Tlwg Typo *
- Ubuntu Mono *

\* - Regular, Bold, (Italic|Oblique) or Bold (Italic|Oblique)


## Parameters

yoruba-quiz-main.sh [help]


## Running the Script

Internet connectivity is required at runtime, when the program first requests the development test data from their S3 storage location.

If you've symlinked from a directory in your `PATH`, then just execute...
``` bash
yoruba-quiz-main.sh
```

... else, execute yoruba-quiz-main.sh from within your Git project root directory with...
```
cd path-to-cloned-repo-root-directory && \
./yoruba-quiz-main.sh
```
NOTE: Being only a development prototype, the program will just exit if it encounters incorrect inputs or failed connections etc.

NOTE: Good idea to run in a new terminal console, as this program makes gratuitous use of the `clear` command.


### Quiz Information Output

1. The program gets the player quiz selection
2. Check for quiz data file locally, if it's already available, otherwise
3. Outputs everything it knows about that quiz.

```
Hello,

Enter the number of the quiz you want to try :

1) test-quiz-data-uc-wk01.json
2) test-quiz-data-uc-wk04.json
3) None
> 2
You Selected : test-quiz-data-uc-wk04.json
...which was choice number: 2

Quiz Selected OK.

Good News! Requested quiz file already exists locally.

Quiz data available.

#================================#

What next? View the Information Page for this Quiz? Choose an option : 

1) Yes, View it now
2) No, Quit the Program
> 1

```


```
quiz theme (or name):
numbers

21 questions

quiz questions sequence (ordered or shuffled):
shuffled

quiz_english_phrases_string:
zero | one | two | three | four | five | six | seven | eight | nine | ten | eleven | twelve | thirteen | fourteen | fifteen | sixteen | seventeen | eighteen | nineteen | twenty

quiz_yoruba_phrases_string:
òdo | oókan | eéjì | ẹẹ́ta | ẹẹ́rin | aárùnún | ẹẹ́fà | eéje | ẹẹ́jọ | ẹẹ́sànán | ẹẹ́wàá | oókànlá | eéjìlá | ẹẹ́tàlá | ẹẹ́rìnlá | aárùnúndínlógún | ẹẹ́rìndínlógún | ẹẹ́tàdínlógún | eéjìdínlógún | oókàndínlógún | ogún

#================================#

What next? Choose an option : 

1) View the Quiz Instructions
2) Quit the Program
> 1

```

### Quiz Questions Output
The program goes though the following sequence:
1. Clears screen of the previous information output.
2. Displays a word, with instructions for the player.
3. Repeats previous 2 steps until the end on the quiz.

```
		fifteen

First Type your answer (Optional)
...then Press ENTER to see translation...
aarunundinlogun
		aárùnúndínlógún

What next? Choose an option : 

1) Go to Next Question
2) Leave this Quiz
3) Quit the Program
> 1

```

## Logging

None.

## License
No changes or additions. See [LICENCE](./LICENSE).




