# BIKES

IMPORTANT - IF SCLANG IS NOT FOUND TYPE THIS source ~/.bash_profile (FOR MAC)


FOR MAC ONLY 
MAC OS

Step 1: Find where sclang and scsynth live in your computer, copy the FOLDER path (remove /sclang, /scsynth from output)

find /Applications/SuperCollider.app -name sclang
find /Applications/SuperCollider.app -name scsynth

Step 2: Open your environment variables file, and add the file paths at the bottom

nano ~/.bash_profile  

export PATH="/Applications/SuperCollider.app/Contents/MacOS:$PATH"
export PATH="/Applications/SuperCollider.app/Contents/Resources:$PATH"

Step 3: Update your terminal to accept new changes

source ~/.bash_profile

Step 4:

Now you should be able to run the following commands
sclang
scsynth




/Applications/SuperCollider.app/Contents/Resources/scsynth


When running sclang. microcenter
source nano ~/.bash_profile

After u add a new synth def, you need to .SYNC the server
CODE BLOCKS DONT EXIST IN SCLANG, NOT IDE B[V

Bashscript: 
U have to change permissions of bash script using chmod






Do not type 

/Applications/SuperCollider.app/Contents/MacOS/sclang
/Applications/SuperCollider.app/Contents/Resources/scsynth