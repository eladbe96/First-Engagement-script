Hey Guys,

Below you can find the template for our customer, before sharing this script:

In addition to the above, we would like to collect additional information and outputs to have a better understanding of the issue and to make an offline investigation.
Therefore, we have created a dedicated script, called First_Engagement_script.sh to simplify the logs’ collection procedure.
This is an interactive script, which allows us to collect the information we need for our investigation, divided by categories.
For our issue, please make sure to choose option <1/2/3>.

Note: The script will take CPInfo/HCP in the background(according to the user’s input) and thus, it might take a few minutes to complete the collection of the logs.
Note: The script will not perform any debugs, and thus there is no business impact using this script, as it only generates general logs and information(To get more information, please run #cat First_Engagement_script.sh)

Once the script was completed, the system will print the location of all the files, which is under ‘/var/log/FE_Files’.
Please make sure to upload the content of the directory for our analysis.
