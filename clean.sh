#!/bin/bash
#############################################################################
#
#   Utility to recursively search and delete backup files.
#
#   MIT License
# 
#   Copyright (c) 2016, Michael Becker (michael.f.becker@gmail.com)
#   
#   Permission is hereby granted, free of charge, to any person obtaining a 
#   copy of this software and associated documentation files (the "Software"),
#   to deal in the Software without restriction, including without limitation
#   the rights to use, copy, modify, merge, publish, distribute, sublicense, 
#   and/or sell copies of the Software, and to permit persons to whom the 
#   Software is furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included 
#   in all copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
#   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
#   OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR 
#   THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#############################################################################

let COUNT=0
START_DIR=$PWD


clean_temp_files_in_pwd()
{
    local FILES=$(ls)

    for FILE in $FILES ; do        
        if [ -f $FILE ] ; then 
            if [[ $FILE == *~ ]] ; then 
                #echo $FILE is a backup
                let COUNT=COUNT+1
                rm $FILE
            fi
        fi
    done
}


clean_dir()
{
    clean_temp_files_in_pwd

    local SUBDIRS=$(ls)

    for SUBDIR in $SUBDIRS ; do
        if [ -d $SUBDIR ] ; then 
            #echo "DEBUG ($PWD) \$SUBDIR = $SUBDIR"
            if pushd $SUBDIR > /dev/null ; then 
                clean_dir
                popd > /dev/null
            fi
        fi
    done
}


display_results()
{
    if [ $COUNT -gt 1 ] ; then 
        echo "$COUNT backup files were deleted"
    elif [ $COUNT -gt 0 ] ; then 
        echo "$COUNT backup file was deleted"
    else
        echo "No backup files found"
    fi
}


clean_up_on_signal() 
{
    cd $START_DIR
    echo 
    echo "Exiting script early"
    display_results
    exit 
}


trap clean_up_on_signal SIGHUP SIGINT SIGTERM


clean_dir .
display_results


