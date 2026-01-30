if [ -z "$1" ]
  then
    echo "No argument supplied, call this again with the target IP as argument"
    exit 1;
fi

echo "Uploading data folder"
scp -r data_Toast\ machine_linuxbsd_arm32 lisse@$1:/home/lisse

echo "Uploading executable"
scp toastmachine.arm32 lisse@$1:/home/lisse 
