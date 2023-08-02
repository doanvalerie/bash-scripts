#!/bin/bash

# My refactored batch rename inspired by the class I am instructing, UC Davis ECS 098F.
# Purposes: Build Bash skills by practicing scripting and enhancing functionality.

FUNCTION_MODE=$1
RECURSIVE_MODE=$2
FIND=$3
REPLACE=$4
TARGET_DIR=$5

print_help() {
    echo "Usage: ./rename.sh [-h|-d|-f] [-r|-nr] FIND REPLACE TARGET_DIR"
    echo ""
    echo "-h: Help. Print script usage and exit."
    echo "-d: Dry run. Show new filenames without actually renaming the files."
    echo "-f: Force. Rename the files in the target directory."
    echo ""
    echo "-r: Recursive. Perform file renaming within TARGET_DIR and subdirectories."
    echo "-nr: Nonrecursive. Perform file renaming within TARGET_DIR, ignoring files within subdirectories."
    echo ""
    echo "FIND: Substring to be replaced in file name."
    echo "REPLACE: String to substitute FIND with."
    echo "TARGET_DIR: Directory composed of files to be renamed."
}

do_rename() {
    original_file=$1
    dry_run=$2
	find=$3
	replace=$4
    
    dirname=$(dirname $original_file)
    old_basename=$(basename $original_file)
    new_basename=${old_basename/$find/$replace}
	
    echo "Renaming $original_file to $dirname/$new_basename"

    if [[ $dry_run = true ]]; then
        mv $original_file $dirname/$new_basename
    fi
}

export -f do_rename

find_exec_files() {
	dry_run=$1
	if [[ $RECURSIVE_MODE = "-nr" ]]; then
            find $TARGET_DIR -maxdepth 1 -type f -name "*${FIND}*" -exec bash -c "do_rename {} $dry_run $FIND $REPLACE" \;
	elif [[ $RECURSIVE_MODE = "-r" ]]; then
		find $TARGET_DIR -type f -name "*${FIND}*" -exec bash -c "do_rename {} $dry_run $FIND $REPLACE" \;
	fi
}

case $FUNCTION_MODE in
    "-h")
        print_help
        ;;
    "-d")
		find_exec_files false
        ;;
	"-f")
		find_exec_files true
		;;
    *)
        echo "Invalid arguments."
        print_help
        exit 1
esac
