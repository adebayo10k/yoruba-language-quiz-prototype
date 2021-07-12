
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
