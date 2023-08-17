config_env() {
    if [[ ! -d ./database || ! -f ./database/database.csv ]]; then
        mkdir database
        touch ./database/database.csv
    fi
}

display_main_menu() {
    echo "\n$(whoami)'s Address Book\n"
    echo "Please choose one of the below options:\n"
    echo "1. Add an entry."
    echo "2. Search/edit entry."
    echo "x. Exit"
    echo ""
    echo "Note: Script Exit Timeout is set"
    echo ""
    read -p "Please choose your option: " user_input
}

add_entry() {
    echo "\nAdd New Entry:\n"
	echo "1: Name       : "
	echo "2: Email      : "
	echo "3: Home #     : "
	echo "4: Mobile #   : "
	echo "5: Work #     : "
	echo "6: Address    : "
	echo "7: Note       : \n"
	read -p "Please choose the field to be added: " field
}

process_user_input() {
    case $user_input in
    "1")
        add_entry
        ;;
    "x")
        exit 0
        break
        ;;
    *)
        echo "Invalid argument entered"
        exit 1
        ;;
    esac
}

config_env
display_main_menu
process_user_input
