
function check_program_requirements() 
{
	declare -a dependencies=(vi jq curl cowsay)

	for program_name in ${dependencies[@]}
	do
	  if type $program_name >/dev/null 2>&1
		then
			:
			clear
			#echo "$program_name already installed OK"
		else
			echo "${program_name} is NOT installed."
			echo "program dependencies are: ${dependencies[@]}"
  	echo "exiting with error" && echo && exit 1
		fi
	done
}

###############################################################################################
# Display a program header:
function display_program_header(){

	#echo
	#echo -e "		\033[33m===================================================================\033[0m";
	#echo -e "		\033[33m||                  Welcome to the YORUBA QUIZ                ||  author: adebayo10k\033[0m";  
	#echo -e "		\033[33m===================================================================\033[0m";
	#echo

	# REPORT SOME SCRIPT META-DATA
	#echo "The absolute path to this script is:	$0"

	if type cowsay > /dev/null 2>&1
	then
		cowsay "Hello, sibs!"
	fi
		
}
