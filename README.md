# First-Engagement-script

Welcome to our First Engagement script GIT!

Here you can find the latest version of our script + intersting information and updates.

Important:

For version managin, I have created a seperated branch called 'dev' letting you work on the script, updating, adding features, etc
while protecting the original script's version.
Make sure to work only on this specific branch.

To get the latest script, you can choose one of the following options:

1. Copy the script manually to a txt file.

2. Generate an SSH-key to be able 'clone' the script directly to your PC.

--- Download GIT BASH terminal to your PC:
    This will allows you to run Linux command on your WIN machine, and navigate easily.

    https://github.com/git-for-windows/git/releases/download/v2.39.0.windows.2/Git-2.39.0.2-64-bit.exe

--- Open GIT BASH Terminal, and browse to the desired location where you want to copy the script.

--- Generate an SSH key:

    [Expert@hostname:0]# ssh-keygen -t rsa

--- Choose the location of the new key:

    Enter file in which to save the key (/home/admin/.ssh/id_rsa): 
    
    For example: 
    
    Enter file in which to save the key (/home/admin/.ssh/id_rsa): /home/admin/ssh-git-key
 
--- Skip all the next steps.

--- Browse to the locaiton of your SSH-Key, and do #cat to your ssh-key.pub:

    For example:
    [Expert@hostname:0]# cd /home/admin/
    [Expert@hostname:0]# cat ssh-git-key.pub
    
    ssh-rsa################ USER_ID@hostname
    
--- Share the content of your public key with me, and I wil make sure to add you to this repository collaborators list
to be able to get the script.

--- Run the following command to get the script:

--- For any issues, please reach me offline :)



