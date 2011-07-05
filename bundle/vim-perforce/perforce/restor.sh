#!/bin/bash
# Author: Hari Krishna Dara ( hari_vim at yahoo dot com ) 
# Last Change: 06-Jan-2004 @ 19:07
# Requires:
#   - bash or ksh (tested on cygwin and MKS respectively).
#   - Info Zip for the -z option to work (comes with linux/cygwin). Download for
#     free from:
#       http://www.info-zip.org/
# Version: 1.1.0
# Licence: This program is free software; you can redistribute it and/or
#          modify it under the terms of the GNU General Public License.
#          See http://www.gnu.org/copyleft/gpl.txt 
usage()
{
cat <<END
$0 <input package>
  The input package is the name of the backup directory or the archive file(with
  or without extension).
END
}

inputType=''
inputPackage=''
verboseMode=1
if [ -d $1 ]; then
    inputType='dir'
    inputPackage=$1
elif [ -r $1.zip ]; then
    inputType='zip'
    inputPackage=$1.zip
elif [ -r $1.tar.gz ]; then
    inputType='tar'
    inputPackage=$1.tar.gz
    tarOpt='z'
elif [ -r $1.tar.bz2 ]; then
    inputType='tar'
    inputPackage=$1.tar.bz2
    tarOpt='j'
elif [ -r $1.tar.Z ]; then
    inputType='tar'
    inputPackage=$1.tar.Z
    tarOpt='Z'
elif [ -r $1.tar ]; then
    inputType='tar'
    inputPackage=$1.tar
    tarOpt=''
elif [ -r $1 ]; then
    case $1 in
    *.zip)
	inputType='zip'
	;;
    *.tar.gz)
	inputType='tar'
	tarOpt='z'
	;;
    *.tar.bz2)
	inputType='tar'
	tarOpt='j'
	;;
    *.tar.Z)
	inputType='tar'
	tarOpt='Z'
	;;
    *.tar)
	inputType='tar'
	tarOpt=''
	;;
    *)
	echo "$0: Unknown input package type."
	exit 1
	;;
    esac
    inputPackage=$1
else
    echo "$0: No input package found for $1"
    exit 1
fi

if [ $inputType = 'dir' ]; then
    listCmd="find $inputPackage -type f -print | sed -e 's;^$1/*;;'"
    copyCmd="cp"
    if [ $verboseMode -ne 0 ]; then
	copyCmd="$copyCmd -v"
    fi
    copyCmd="$copyCmd -r $inputPackage/* ."
elif [ $inputType = 'zip' ]; then
    listCmd="unzip -l -qq $inputPackage | awk 'BEGIN{OFS=\"\"}{\$1=\"\"; \$2=\"\"; \$3=\"\"; print \$0}'"
    copyCmd="unzip"
    if [ $verboseMode -ne 1 ]; then
	copyCmd="$copyCmd -q"
    fi
    copyCmd="$copyCmd $inputPackage.zip"
elif [ $inputType = 'tar' ]; then
    listCmd="tar -t${tarOpt}f $inputPackage"
    copyCmd="tar"
    if [ $verboseMode -ne 0 ]; then
	copyCmd="$copyCmd -v"
    fi
    copyCmd="$copyCmd -x${tarOpt}f $inputPackage"
fi

if [ $verboseMode -eq 1 ]; then
    echo "Opening files in Perforce for edit."
fi
discardOutput=''
if [ $verboseMode -eq 0 ]; then
    discardOutput=' > /dev/null'
fi
#eval $listCmd | cat
eval $listCmd | p4 -x - edit $discardOutput
if [ $? -ne 0 ]; then
    echo "$0: There was an error opening files in Perforce for edit."
    echo "Make sure you are in the right directory and try again."
    exit 1
fi

if [ $verboseMode -eq 1 ]; then
    echo "$0: Copying files to the target directories."
fi
#echo $copyCmd
eval $copyCmd
if [ $? -ne 0 ]; then
    echo "$0: Error copying files."
    exit 1
fi
