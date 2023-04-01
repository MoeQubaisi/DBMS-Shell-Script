#!/bin/bash

main_menu() {
    PS3='>'
    echo "Choose an action: "
    select choice in "Create Database" "List Databases" "Connect To Database" "Drop Database" "exit"; do
        case $choice in
        "Create Database")
            clear
            create_db
            echo -e "\nPress Enter to view menu"
            ;;
        "List Databases")
            clear
            echo -e "Available Databases:\n$(ls -1 ./db)"
            echo -e "\nPress Enter to view menu"
            ;; # ls -F ./db | grep / | sed -n 's/\///gp' ;;
        "Connect To Database")
            clear
            connect_db
            ;;
        "Drop Database")
            clear
            drop_db
            echo -e "\nPress Enter to view menu"
            ;;
        "exit") exit ;;
        *) echo "Invalid choice" ;;
        esac
    done
}
create_db() {
    read -p "Enter the name of the Database that will be created: " db_name
    if [ -e ./db/"$db_name" ]; then
        echo "Database name already exist"

    else
        if [[ "$db_name" =~ ^[a-zA-Z]+[a-zA-Z1-9_]+ ]]; then
            mkdir ./db/$db_name
            echo "The $db_name database was created successfully"
        else
            echo "Invalid name"
        fi
    fi
}

drop_db() {
    echo -e "Available Databases: \n$(ls -1 ./db)"
    read -p "Enter the Database you want to remove: " db_drop
    if [[ $(find ./db -name $db_drop) ]]; then
        rm -r ./db/$db_drop
        echo "The $db_drop is removed successfully"
    else
        echo "$db_drop Database not exist"
    fi
}

# drop_db2() {
#     PS3="Choose a database to drop to:  "
#     echo -e "Available Databases:"
#     select db_name in $(ls ./db); do

#     done

# }

init() {
    if ! [ -d ./db/ ]; then
        mkdir ./db/
    fi
}

connect_db() {

    PS3="Select a Database to connect to: "
    echo -e "Available Databases:"
    select db_name in $(ls ./db); do
        if [ $db_name ]; then
            cd ./db/$db_name
            PS3="$(pwd | awk -F "/" '{print $NF}') >"
            clear
            db_actions
        else
            echo "db not exist"
            connect_db

        fi

    done

}

db_actions() {
    echo "Choose an action: "
    select db_action in "Create table" "Drop table" "Insert table" "Select table" "Delete Table" "List table" "Update table" "Return to the main menu"; do
        case $db_action in
        "Create table") create_table ;;
        "Drop table") echo "function not added yet" ;;
        "Insert table") insert_table ;;
        "Select table") echo "function not added yet" ;;
        "Delete Table") echo "function not added yet" ;;
        "List Table") echo "function not added yet" ;;
        "Update Table") echo "function not added yet" ;;
        "Return to the main menu")
            cd ../..
            clear
            main_menu
            ;;
        *) echo "Invalid choice" ;;
        esac
    done
}

create_table() {
    read -p "Enter the table name: " t_name
    if [ -e ./$t_name ]; then
        echo "Table already exist"
        create_table
    else
        if [[ "$db_name" =~ ^[a-zA-Z]+[a-zA-Z1-9_]+ ]]; then
            touch ./$t_name
            read -p "Enter the number of fields: " fields_num
            read -p "Enter Primary key: " pk
            echo -n ${pk}: >>$t_name
            index=1
            while [ $index -lt $fields_num ]; do
                read -p "Enter name for field $index: " field_name
                echo -n ${field_name}: >>$t_name
                let index++
            done
            index=1
            while true; do
                read -p "Enter Primary key data type: " pk_t
                if [ $pk_t = int ] || [ $pk_t = string ]; then
                    echo -en "\n${pk_t}": >>$t_name
                    break
                else
                    echo "Invalid datatype"
                fi
            done
            while [ $index -lt $fields_num ]; do
                read -p "Enter data type for field $index: " field_type
                if [ $field_type = int ] || [ $field_type = string ] || [ $field_type = bool ];
                then 
                    echo -n ${field_type}: >>$t_name
                    let index++
                else
                    echo "Invalid datatype"
                fi
            done
        else
            echo "Invalid name"
            create_table
        fi
        sed -i 's/:$//' $t_name &
    fi
}

check_datatype(){
    datatype_postion=$1
    data_type=`awk -F: -v var="$datatype_postion" '{if(NR==2)print $var}' $ins_table`
    if [ "$data_type" = int ];then
        if ! [[ "$field_data" =~ ^[0-9]+$ ]]; then
            echo "Invalid input by data type"
        else
            status=done
        fi
    elif [ "$data_type" = string ];then
        if ! [[ "$field_data" =~ ^[a-zA-Z]+[a-zA-Z1-9_]+ ]]; then
            echo "Invalid input by data type"
        else
            status=done
        fi
    elif [ "$data_type" = bool ];then
        if ! [[ "$field_data" =~ [tT]rue ]] || ! [[ "$field_data" =~ [fF]alse ]]; then
            echo "Invalid input by data type"
        else
            status=done
        fi
    fi
}

insert_table (){
    ls
    read -p "Enter the table that you want to insert it: " ins_table
    if [[ `find -name $ins_table` ]];then
        fields_num=`awk -F: '{print NF}' $ins_table | head -1`
        for ((i=1; i<=$fields_num;i++));do
            status=""
            echo this is $i
            if [ $i -eq 1 ]; then
                while true; do
                    if [ "$status" = "done" ];then
                        break
                    fi
                    read -p "enter data in field number $i: " field_data
                    if [[ `awk -F: '{if(NR>2)print $1}' $ins_table | grep $field_data 2> /dev/null` ]]
                    then
                        echo "id is duplicated"
                    elif [ -z $field_data ]; then
                        echo "id is NULL"
                    elif [ "$status" != "done" ]; then
                        check_datatype $i
                    fi
                done
            else
                status=""
                while true; do
                    if [ "$status" = "done" ];then
                        break
                    fi
                    read -p "enter data in field number $i: " field_data
                    if [ "$status" != "done" ]; then
                        check_datatype $i
                    fi
                done
            fi
            data=$data:${field_data}
            
            # echo -n "${field_data}:" >>$ins_table
        done
        echo $data:>>$ins_table
        data=""
        sed -i 's/:$//' $ins_table
        sed -i 's/^://' $ins_table
    else
        echo "$ins_table is Invalid table name"
    fi
}

init
main_menu
