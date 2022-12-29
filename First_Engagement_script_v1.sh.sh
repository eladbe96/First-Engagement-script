#!/bin/bash
unset TMOUT
clear

#Setting the colours VARS:
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
clear='\033[0m'

printf "${GREEN}####################################################################${clear}\n"
printf "${BLUE}########Hello $(whoami)#################################################${clear}\n"
printf "${BLUE}########Welcome to First Engagement Check Point script##############${clear}\n"
printf "${GREEN}####################################################################${clear}\n\n"
#Creating the needed vars:
OutboundDir=/var/log/FE_Files
HCP=$OutboundDir/hcp_results
CRASH_OUTPUTS=$OutboundDir/crash_info.log

function collect_CPinfo {
    echo "--------------------------------"
    printf "${RED}Collecting CPinfo . . .${clear}\n"
    nohup cpinfo -d -D -z -o $OutboundDir/$(hostname)_$(date +"%d-%m-%Y").cpinfo > /dev/null 2>&1
    printf "${BLUE}CPinfo was collected${clear}\n"
}

function collect_HCP {
    echo "--------------------------------"
    printf "${RED}Collecting HCP. . .${clear}\n"
    nohup hcp -r all > /dev/null 2>&1
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP    
    printf "${BLUE}HCP was collected${clear}\n"
}
function collect_HCP_Performance {
    echo "--------------------------------"
    hcp --enable-product "Performance"
    hcp --enable-product "Threat Prevention"
    printf "${RED}Collecting HCP. . .${clear}\n"
    nohup hcp -r all > /dev/null 2>&1
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP
    hcp --disable-product "Performance"
    hcp --disable-product "Threat Prevention"
    printf "${BLUE}CPinfo was collected${clear}\n"
}

function collect_Spike_Detective {
    echo "--------------------------------"
    printf "${RED}Collecting Spike_Detective logs . . .${clear}\n"
    tar -czvf $OutboundDir/$(hostname)_$(date +"%d-%m-%Y")_spike_detective_logs.tgz /var/log/spike_detective/* > /dev/null 2>&1
	printf "${BLUE}Spike_Detective was collected${clear}\n"
    }

function additional_performance_files {
    echo "--------------------------------"
    printf "${RED}Collecting Connections table . . .${clear}\n"
    fw tab -t connections -z -u > $OutboundDir/conntable_reason_$(date +"%d-%m-%Y").log
    fw tab -t connections -u > $OutboundDir/conntable_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting SXL Statistics . . .${clear}\n"
    fwaccel stats -s > $OutboundDir/accel_stats_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting affinity information . . .${clear}\n"
    fw ctl affinity -l -a -r > $OutboundDir/affinity_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting CoreXL statistics. . .${clear}\n"
    fw ctl multik print_heavy_conn > $OutboundDir/havy_conns_$(date +"%d-%m-%Y").log
    fw ctl multik utilize > $OutboundDir/instance_util_$(date +"%d-%m-%Y").log
    }

function crash_files {
    echo "--------------------------------"
    printf "${RED}Checking for Crash files${clear}\n"
    
    OUTPUT=$(ls -lsA /var/log/crash/ | wc -l)
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/crash/ | wc -l)
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/log/dump/usermode/ | wc -l)
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/dump/usermode/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/dump/usermode/ >> $CRASH_OUTPUTS
        tar -czvf $CRASH_OUTPUTS/$(hostname)_$(date +"%d-%m-%Y")_crash_files /var/log/dump/usermode/*  > /dev/null 2>&1
    fi
    if [[ $CRASH_OUTPUTS == 0 ]]; then
        printf "${RED}The system didn't find any crash files${clear}\n"
    fi
    }

#Cheking if the folder exist, if not, creating it:
if [ -d "$OutboundDir" ]; then
    if [ "$(ls -A $OutboundDir)" ]; then
    	  
        printf "The system founds old files already exist\n"
		PS3="Please enter your choice:"
        options=("Keep the files" "Remove the files" "Quit")
        select opt in "${options[@]}"
            do
                case $opt in
                    "Keep the files")
                        echo -e "you chose 1 - Keeping the files \n"
                        break
                        ;;
                    "Remove the files")
                        echo -e "you chose 2 - Deleting old files \n"
                        rm -r $OutboundDir/*
                        break
                        ;;                 
                    "Quit")
                        exit 0
                        ;;
                    *) echo "invalid option $REPLY, please choose a valid option";;
                esac
            done
    fi
else
    mkdir /var/log/FE_Files
fi

    
# ------------------------------------------------------------------------------------------------

#Getting the user input:
printf "Please choose what should be collected:\n"
PS3="Please enter your choice:"
options=("Full Package (HCP, CPInfo, CPViewDB)" "Performace-related issues (Including option #1) and additional performance logs" "Crash files (Including option #1)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Full Package (HCP, CPInfo, CPViewDB)")
            printf "you chose 1 - Full Package (HCP, CPInfo, CPViewDB)\n \nThe system will collect the following files: ${GREEN}\n1) cpinfo -d -D -z -o \n2) hcp -r all${clear}\n\n"
            Package=1
            break
            ;;
        "Performace-related issues (Including option #1) and additional performance logs")
            echo -e "you chose 2 - Performace-related issues (Including option #1) and additional performance logs\n \nThe system will collect the following files:\n1) cpinfo -d -D -z -o \n2) hcp -r all \n3) /var/log/spike_detective/* \n4) connections table \n5) SXL and CoreXL Statistics\n"
            Package=2
            break
            ;;
        "Crash files (Including option #1)")
            echo -e "you chose 3 - Crash files (Including option #1) \n \nThe system will collect the following files: \n1) /var/log/dump/usermode \n2) /var/log/crash/(folder's content only) \n3) /var/crash/ (folder's content only)\n"
            Package=3
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) echo "invalid option $REPLY, please choose a valid option\n";;
    esac
done
echo "Please choose Yes or No if you wish to proceed:"
proceed=("Yes" "No")
select opt in "${proceed[@]}"
do
	  case $opt in
	  	"Yes")
	  	echo -e "you chose 1 - The system will collect the files"
	  	Choose=1
	  	break
	  	;;
	    "No")
	  	echo "you chose 2 - The system will not collect the files"
	  	Choose=2
	  	break
	  	;;
	  esac
done
if [[ $Package == "1" ]] && [[ $Choose == "1" ]]; then
    clear
	collect_CPinfo
    collect_HCP
    echo -e "Your outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
    
elif [[ $Package == "2" ]] && [[ $Choose == "1" ]]; then
    clear
	collect_CPinfo
    collect_HCP_Performance
    collect_Spike_Detective
    additional_performance_files
    echo -e "Your outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"

elif [[ $Package == "3" ]] && [[ $Choose == "1" ]]; then
	clear
#	collect_CPinfo
#    collect_HCP
    crash_files
    echo -e "Your outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
else
   echo 'Thank you for using the First Engagement Check Point script'
fi
