#!/bin/bash

CSV_PATH="./database/database.csv"

RED="\033[0;31m"
YELLOW="\033[1;33m"
LIGHT_BLUE="\033[1;34m"
LIGHT_PURPLE="\033[1;35m"
NC="\033[0m"

field_topics=("name" "email" "home #" "mobile #" "work #" "address")
valid_field_pattern="^[[:space:]]*([1-6]{1}|[xX]{1})[[:space:]]*$"
valid_menu_pattern="^[[:space:]]*([1-2]{1}|[xX]{1})[[:space:]]*$"


delete_empty_entries() {
    sed -i "/^,,,,,$/d" "$CSV_PATH"
    sed -i "/^$/d" "$CSV_PATH"
}

trap delete_empty_entries EXIT

config_env() {
    if [[ ! -d ./database || ! -f "$CSV_PATH" ]]; then
        mkdir database
        touch "$CSV_PATH"
        header="Name,Email,Home #,Mobile #,Work #,Address,Note"
        echo "$header" | tee -a "$CSV_PATH" > /dev/null
    fi
}

display_main_menu() {
    echo ""
    echo -e "${LIGHT_PURPLE}$(whoami)'s Address Book${NC}"
    echo ""
    echo -e "${RED}1.${NC} Add an entry."
    echo -e "${RED}2.${NC} Search & edit entry."
    echo -e "${RED}x.${NC} Exit."
    echo ""
    echo -ne "${LIGHT_BLUE}Please choose your option [1-2|x]: ${NC}"
    read -r menu_input
}

process_menu_input() {
    get_valid_menu_input

    case ${menu_input,,} in
        "1")
            add_entry
            ;;
        "2")
            search_entry
            ;;
        "x")
            exit 0
            ;;
    esac
}

get_valid_menu_input() {
    while [[ ! $menu_input =~ $valid_menu_pattern ]]; do
        echo -e "${YELLOW}Invalid argument entered.${NC}"
        echo -ne "${LIGHT_BLUE}Please choose your option [1-2|x]: ${NC}"
        read -r menu_input
    done
}

add_entry() {
    print_empty_fields "Add New Entry"
    empty_entry=",,,,,"
    csv_line_count=$(wc -l $CSV_PATH | sed -E "s/(^[0-9]+).*$/\1/")
    sed -i "${csv_line_count}a $empty_entry" "$CSV_PATH" 
    edit_csv_field $(( csv_line_count + 1 ))
}

print_empty_fields() {
    title=$1

    echo ""
    echo -e "${LIGHT_PURPLE}$title${NC}"
    echo ""
	echo -e "${RED}1:${NC} Name       : "
	echo -e "${RED}2:${NC} Email      : "
	echo -e "${RED}3:${NC} Home #     : "
	echo -e "${RED}4:${NC} Mobile #   : "
	echo -e "${RED}5:${NC} Work #     : "
	echo -e "${RED}6:${NC} Address    : "
    echo -e "${RED}x:${NC} Exit       : "
    echo ""
}

get_valid_field_input() {
    functionality=$1

    echo -ne "${LIGHT_BLUE}Please choose the field to be ${functionality}: ${NC}"
    read -r field_input
    while [[ ! $field_input =~ $valid_field_pattern ]]; do
        echo -e "${YELLOW}Invalid argument entered.${NC}"
        echo -ne "${LIGHT_BLUE}Please choose a valid field to be ${functionality}: ${NC}"
        read -r field_input
    done
}

process_exit_request() {
    user_input=${1,,}

    if [[ $user_input == "x" ]]; then
        display_main_menu
        process_menu_input
        return
    fi
}

edit_csv_field() {
    record_num=$1

    while true; do
        get_valid_field_input "edited"
        process_exit_request "$field_input"

        echo -ne "${LIGHT_BLUE}Please enter the ${field_topics[(( $field_input - 1 ))]}: ${NC}"
        read -r field_value
        
        awk -F "," -v record_num="$record_num" -v field_input="$field_input" -v field_value="$field_value" '
            NR == record_num {
                OFS = FS
                $field_input = field_value
            }
            { print }
        ' "$CSV_PATH" > ./database/temp.csv
        mv ./database/temp.csv "$CSV_PATH"

        print_entry "$record_num"
    done
}

search_entry() {
    print_empty_fields "Search by Field"
    get_valid_field_input "searched"
    process_exit_request "$field_input"

    echo -ne "${LIGHT_BLUE}Please enter the ${field_topics[(( $field_input - 1 ))]}: ${NC}"
    read -r field_value
    get_queried_line_number

    while [[ $line_number -lt 0 || -z $line_number ]]; do
        echo -e "${YELLOW}Search was unsuccessful. Enter 'x' to exit search.${NC}"
        echo -ne "${LIGHT_BLUE}Please enter the correct ${field_topics[(( $field_input - 1 ))]}: ${NC}"
        read -r field_value
        process_exit_request "$field_value" 
        get_queried_line_number
    done

    print_entry "$line_number"
    edit_csv_field "$line_number"
}

get_queried_line_number() {
    line_number=$(awk -F "," -v field_input="$field_input" '{ print $field_input }' "$CSV_PATH" | grep -E --line-number "^${field_value}$" | head -n1 | sed -E "s/(^[0-9]+):.*$/\1/")
}

print_entry() {
    line_number=$1

    echo ""
    echo -e "${LIGHT_PURPLE}Entry $(( line_number - 1 ))${NC}"

    awk -F "," -v line_number="$line_number" -v RED="$RED" -v NC="$NC" '
        NR == line_number { 
            print ""
            print RED "1:" NC " Name       : " $1
            print RED "2:" NC " Email      : " $2
            print RED "3:" NC " Home #     : " $3
            print RED "4:" NC " Mobile #   : " $4
            print RED "5:" NC " Work #     : " $5
            print RED "6:" NC " Address    : " $6
            print RED "x:" NC " Exit       : "
            print ""
        }
    ' "$CSV_PATH"
}

config_env
display_main_menu
process_menu_input
