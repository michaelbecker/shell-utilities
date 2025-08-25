#!/bin/bash

echo This file contains useful little snippets of code for bash.


log_command() {
    echo "    $@" | tee -a $log_file
    $@ | tee -a $log_file
}


log_echo() {
    echo "    $@" | tee -a $log_file
}


patch_batch_script() {

    local script_file=$1
    local patch_file=$2
    local function_to_patch=$3

    local tmp_file=$(mktemp)

    # Make a backup
    cp $script_file $script_file.BACKUP

    # Comment out the old function
    sed -i "/^${function_to_patch}/,/^}/ s/^/#/" $script_file

    # Find the insertion point
    line_number=$(grep -n "#${function_to_patch}" $script_file | cut -d : -f 1)
    let line_number=line_number-1

    # Copy the first half of the file...
    head -n $line_number $script_file > $tmp_file

    # Insert the new function
    cat $patch_file >> $tmp_file

    # And copy the last half of the file
    tail -n +$line_number $script_file >> $tmp_file

    # And rearrange the files so we are good.
    rm $script_file
    mv $tmp_file $script_file
}



