#!/bin/bash
unset TMOUT
clear

#Setting the colours VARS:
GREEN='\033[0;32m'
GREEN_B='\e[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
clear='\033[0m'

printf "${GREEN}#####################################################################${clear}\n"
printf "${RED}#                            Hello $(whoami)                            #${clear}\n"
printf "${RED}#          Welcome to First Engagement Check Point script           #${clear}\n"
printf "${GREEN}#####################################################################${clear}\n\n"



#Creating the needed vars:
OutboundDir=/var/log/FE_Files
HCP=$OutboundDir/hcp_results
CRASH_OUTPUTS=$OutboundDir/crash_info.log
IS_SCALABLE=$(if [ -f "/etc/.scalable_platform" ]; then echo "1" ;fi)
VERSION=$(cat /etc/cp-release | awk {'print $NF'})
JHF=$(grep "installer:packages:.*.tgz 5" /config/active | grep JUMBO | grep -o T[0-9]* | cut -c2-)
VSX=$(cpprod_util fwisvsx)
TYPE=$(cpstat os | grep "Appliance Name" | tr -s ' ' | cut -c 17-)

if [ $VSX == '1' ]; then
	VSX="Yes"
	echo "VSX:" $VSX
fi

echo "User:" $USER
echo "Date:" $(date +"%d-%m-%Y")
echo "Version" $VERSION
echo "JHF Take:" $JHF
echo "OS Type:" $TYPE
printf "\n"

function die_sig {
       tput cnorm
	   printf "${clear}"
	   printf "\n"
       exit 0
}
trap 'die_sig "SIGINT"' SIGINT
trap 'die_sig "SIGQUIT"' SIGQUIT
trap 'die_sig "SIGTERM"' SIGTERM




function compress {
    tar -czvf $OutboundDir/$(hostname)_First_Engagement_Last_Run_$(date +"%d-%m-%Y").tgz $OutboundDir/* >/dev/null 2>&1 &
}


spinner() {
    local PROC="$1"
    local str="$2"
    local delay="0.5"
    tput civis  # hide cursor
    while [ -d /proc/$PROC ]; do
		printf "${RED}"
        printf '\033[s\033[u[ / ] %s\033[u' "Collecting $str"; sleep "$delay"
        printf '\033[s\033[u[ — ] %s\033[u' "Collecting $str"; sleep "$delay"
		printf '\033[s\033[u[ \ ] %s\033[u' "Collecting $str"; sleep "$delay"
        printf '\033[s\033[u[ | ] %s\033[u' "Collecting $str"; sleep "$delay"
		printf "${clear}"
    done
    printf '\033[s\033[u%*s\033[u\033[0m' $((${#str}+6)) " " >/dev/null 2>&1 # return to normal
    tput cnorm  # restore cursor
    printf "${GREEN_B}[V] $str was collected ${clear}\n"
}

function collect_CPinfo {												
    nohup cpinfo -d -D -z -o $OutboundDir/$(hostname)_$(date +"%d-%m-%Y").info >/dev/null 2>&1 &
	spinner $! CPInfo
}

function collect_HCP {    												
    nohup hcp -r all >/dev/null 2>&1 &
	spinner $! HCP
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP     
}
function collect_HCP_Performance {
    hcp --enable-product "Performance"
    hcp --enable-product "Threat Prevention"							  
    nohup hcp -r all >/dev/null 2>&1 &
	spinner $! HCP
	if [ ! -d "$OutboundDir/hcp_results" ]; then
		mkdir $OutboundDir/hcp_results
	fi
    mv /var/log/hcp/last/* $HCP
    hcp --disable-product "Performance"
    hcp --disable-product "Threat Prevention"						   
}

function collect_Spike_Detective {
	printf "${RED}Collecting Spike_Detective logs . . .${clear}\n"
    tar -czvf $OutboundDir/$(hostname)_$(date +"%d-%m-%Y")_spike_detective_logs.tgz /var/log/spike_detective/* > /dev/null 2>&1
	printf "${GREEN}[V]Spike_Detective was collected${clear}\r\n"
    }

function additional_performance_files {															  
    printf "${RED}Collecting Connections table . . .${clear}\n"
    fw tab -t connections -z -u > $OutboundDir/conntable_reason_$(date +"%d-%m-%Y").log
    fw tab -t connections -u > $OutboundDir/conntable_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting SXL Statistics . . .${clear}\n"
    fwaccel stats -s > $OutboundDir/accel_stats_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting affinity information . . .${clear}\n"
    fw ctl affinity -l -a -r > $OutboundDir/affinity_$(date +"%d-%m-%Y").log
    printf "${RED}Collecting CoreXL statistics. . .${clear}\n"
    fw ctl multik print_heavy_conn > $OutboundDir/heavy_conns_$(date +"%d-%m-%Y").log
    fw ctl multik utilize > $OutboundDir/instance_util_$(date +"%d-%m-%Y").log
	fw ctl multik dynamic_dispatching get_mode > $OutboundDir/dispatcher-stat_$(date +"%d-%m-%Y").log	
	printf "${RED}Collecting mux information statistics. . .${clear}\n"
	fw_mux all > $OutboundDir/fw_mux_$(date +"%d-%m-%Y").log	
    printf "${GREEN}[V] Performance related logs were collected${clear}\n"
    }

<<<<<<< HEAD
function crash_files {
	checker=0
=======
function crash_files {				  
>>>>>>> 799e3f41d369d86c688dad6ad9f41c707898e5d2
    printf "${RED}Checking for Crash files${clear}\n"					   
    OUTPUT=$(ls -lsA /var/log/crash/ | wc -l)
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/crash/ | wc -l)
<<<<<<< HEAD
		checker=1
=======
>>>>>>> 799e3f41d369d86c688dad6ad9f41c707898e5d2
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/crash/:" >> $CRASH_OUTPUTS
        ls -lsA /var/crash/ >> $CRASH_OUTPUTS
        OUTPUT=$(ls -lsA /var/log/dump/usermode/ | wc -l)
<<<<<<< HEAD
		checker=1
=======
>>>>>>> 799e3f41d369d86c688dad6ad9f41c707898e5d2
    fi
    if [[ $OUTPUT -ge 2 ]]; then
        echo "/var/log/dump/usermode/:" >> $CRASH_OUTPUTS
        ls -lsA /var/log/dump/usermode/ >> $CRASH_OUTPUTS
        tar -czvf $CRASH_OUTPUTS/$(hostname)_$(date +"%d-%m-%Y")_crash_files /var/log/dump/usermode/*  > /dev/null 2>&1
<<<<<<< HEAD
		checker=1
    fi
    if [[ $checker == 0 ]]; then
        printf "${RED}The system didn't find any crash files${clear}\n"
	else
		printf "${GREEN}Crash files were collected${clear}\n"
	fi
=======
    fi
    if [[ $CRASH_OUTPUTS == 0 ]]; then
        printf "${RED}The system didn't find any crash files${clear}\n"
    fi
>>>>>>> 799e3f41d369d86c688dad6ad9f41c707898e5d2
    }


function sp_maestro {

	if  [[ $VERSION == "R81.20" ]] || [[ $VERSION == "R81.10" &&  $JHF -ge 75 ]] || [[ $VERSION == "R81" &&  $JHF -ge 72 ]]; then
			nohup cpinfo -Q '-r -t all -m all' -d -D -o $OutboundDir/$(hostname)_CPdata_Collector_$(date +"%d-%m-%Y") > /dev/null 2>&1 &
			spinner $! CPdata_Collector
	elif [[ $VERSION == "R81.10" &&  $JHF -ge 75 ]] || [[ $VERSION == "R81" &&  $JHF -le 72 ]]; then
			nohup asg_info -q -f -d > /dev/null 2>&1 &
			spinner $! asg_info
			LAST_RUN=$(ls -lst /var/log/ | grep asg_info | awk {'print $10'} | head -n 1)
			mv /var/log/$LAST_RUN $OutboundDir
	else 
			nohup asg_info -q -f -d > /dev/null 2>&1 &
			spinner $! asg_info
			LAST_RUN=$(ls -lst /var/log/ | grep asg_info | awk {'print $10'} | head -n 1)
			mv /var/log/$LAST_RUN $OutboundDir
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
options=("Full Package (HCP, CPInfo, CPViewDB)" "Performace-related issues (Including option #1) and additional performance logs" "Crash files (Including option #1)" "sp_maestro(including HCP)" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Full Package (HCP, CPInfo, CPViewDB)")
            printf "you chose 1 - Full Package (HCP, CPInfo, CPViewDB)\n \nThe system will collect the following files: ${GREEN}\n1) cpinfo -d -D -z \n2) hcp -r all${clear}\n\n"
            Package=1
            break
            ;;
        "Performace-related issues (Including option #1) and additional performance logs")
            echo -e "you chose 2 - Performace-related issues (Including option #1) and additional performance logs\n \nThe system will collect the following files: ${GREEN}\n1) cpinfo -d -D -z\n2) hcp -r all \n3) /var/log/spike_detective/* \n4) connections table \n5) SXL and CoreXL Statistics${clear}\n\n"
            Package=2
            break
            ;;
        "Crash files (Including option #1)")
            echo -e "you chose 3 - Crash files (Including option #1) \n \nThe system will collect the following files: ${GREEN}\n1) /var/log/dump/usermode \n2) /var/log/crash/(folder's content only) \n3) /var/crash/ (folder's content only)${clear}\n\n"
            Package=3
            break
            ;;
		"sp_maestro(including HCP)")
			if [ "$IS_SCALABLE" != 1 ]; then
				printf "${RED}This option can be used in Scalable Platform only!\nPlease choose another option${clear}\n"
				continue
			fi
            echo -e "you chose 4 - sp_maestro(including HCP) \n \nThe system will collect the following files: ${GREEN}\n1) asg_info OR CPINFO(according to the installed version) \n2) HCP ${clear}\n\n"
            Package=4
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) printf "${RED}Invalid option $REPLY, please choose a valid option${clear}\n";;
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
	echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
    
elif [[ $Package == "2" ]] && [[ $Choose == "1" ]]; then
    clear
	collect_CPinfo
    collect_HCP_Performance
    collect_Spike_Detective
	additional_performance_files
    compress
    echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"

elif [[ $Package == "3" ]] && [[ $Choose == "1" ]]; then
	clear
	collect_CPinfo
    collect_HCP
    crash_files
    compress
    echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
	
elif [[ $Package == "4" ]] && [[ $Choose == "1" ]]; then
	clear
	sp_maestro
	collect_CPinfo
	collect_HCP
    compress
	echo -e "\nYour outputs can be found under  $OutboundDir \nThank you for using the First Engagement Check Point script"
	
else
   echo 'Thank you for using the First Engagement Check Point script'
fi
