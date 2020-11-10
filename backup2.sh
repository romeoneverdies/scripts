#!/bin/bash
#  exec 1> >(logger -s -t $(basename $0)) 2>&1

# these are defaut values can be overridden at the cli
DEFOLDERLIST="/folder-list.txt"  #list of file to backup
DEBACKPATH="/backup"            #where to back them up
DEARCHPREFIX="backup_personels"  #prefix for the archive file





logger "Backing up files... `date`"


while [[ "$#" -gt 0 ]]; do case $1 in
  -p|--path) BACKPATH="$2"; shift;;
  -l|--list) FOLDERLIST="$2"; shift;;
  -x|--prefix) ARCHPREFIX="$2"; shift;; 
  -f|--freq) FREQ="$2"; shift;; 
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done



# no list provided lets set to default
if [[ ! ${FOLDERLIST+x} ]]; then
FOLDERLIST=$DEFOLDERLIST
fi
# no backup path lets set a default one
if [[ ! ${BACKPATH+x} ]]; then
BACKPATH=$DEBACKPATH
fi

if [[ ! ${ARCHPREFIX+x} ]]; then
ARCHPREFIX=$DEARCHPREFIX
fi

if [ -f "$FOLDERLIST" ]; then
  if [ -d "${BACKPATH}" ] ; then 


case $FREQ in
weekly)
weekly_backup;;

monthly)
monthly_backup;;
*)
full_backup;;
esac 


   else
      logger "Backup path/Drive does not exist or is not mounted/hooked-up defering backup..."
      exit 2
   fi
else
logger "folder/files list does not exist"
exit 1
fi

weekly_backup {
	
	tar -cvzf "${BACKPATH}${ARCHPREFIX}_`date +%W_%u`_`date +%F`.tar.gz" -T "$FOLDERLIST" -g "${BACKPATH}${ARCHPREFIX}_week_`date +%W`.snar"
    if [[ $? -ne 0 ]]; then
      logger "There was an error creating the archive"
      exit 3
    else logger "The archive was created with success"
    exit 0
    fi
}
monthly_backup {
	tar -cvzf "${BACKPATH}${ARCHPREFIX}_`date +%m_%d`_`date +%F`.tar.gz" -T "$FOLDERLIST" -g "${BACKPATH}${ARCHPREFIX}_month_`date +%m`.snar"
	if [[ $? -ne 0 ]]; then
      logger "There was an error creating the archive"
      exit 3
    else logger "The archive was created with success"
    exit 0
    fi
}
full_backup {
	tar -cvzf "${BACKPATH}${ARCHPREFIX}_`date +%F`.tar.gz" -T "$FOLDERLIST"
	if [[ $? -ne 0 ]]; then
       logger "There was an error creating the archive"
        exit 3
    else logger "The archive was created with success"
    exit 0
    fi
}


print_usage {
echo " Backup utility script
=============================
Usage:	
  -p|--path <path>           specify backup path
  -l|--list <folder list>    specify file with list of folders to backup
  -x|--prefix <string>       set archive name prefix 
  -f|--freq <frequency>      run full backup every week|month (incremental) 
  
  <frequency> weekly|monthly 
 
"
}


