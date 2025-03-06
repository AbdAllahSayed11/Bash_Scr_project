#!/usr/bin/bash
<<COMMINT
dir_path="/home/electronica/bashdb"

# Check if DBMS directory exists
if [ -e "$dir_path" ]; then
    cd "$dir_path"
    echo "DBMS is ready."
else
    mkdir "$dir_path"
    cd "$dir_path"
    echo "DBMS is ready."
fi

select option in Create_DataBase List_DataBases Connect_DataBase Drop_DataBase Exit
do
    case $option in 
        "Create_DataBase")
            read -p "Enter database name: " DBname
            if [ -e "$DBname" ]; then
                echo "Database '$DBname' already exists."
            else
                mkdir "$DBname"
                echo "Database '$DBname' created successfully."
            fi
            ;;
        
        "List_DataBases")
            echo "Listing databases:"
            ls "$dir_path"
            ;;
        
                # Table management menu
               "Connect_DataBase")
            read -p "enter database name: " selectedDB
            if [ -e "$selectedDB" ]
            then
                cd "$selectedDB"
                echo "connected to $selectedDB "
                while true
                do
                    echo -e "\n Database: $selectedDB"
                    PS3="Select an option: "
                    select dbOption in CreateTable ListTables DropTable InsertIntoTable SelectFromTable DeleteFromTable UpdateTable BackToMain
                    do
                        case "$dbOption" in
                        "CreateTable")
                            read -p " Enter table name: " tableName
                            if [ -e "$tableName" ]
                            then
                                echo "Table already exists!"
                            else
                                read -p " Enter columns number : " colNum
				pk=0
                                for((i=1;i<=colNum;i++))
                                do
                                    line=""
                                    read -p " Enter column name $i : " colName
                                    line+="$colName"
                                    read -p " Enter column data type(int/string) : " colType
                                    line+=:"$colType"
				    if [[ "$pk" -eq 0 ]]
			            then
                                    read -p " Do you want to make this column PK(Y/N) : " checkPK
                                    	if [[  "yes" =~ "$checkPK" ]]
                                    	then
                                        	line+=:PK
						pk=1
                                    	fi
			            fi
                                    echo "$line" >> .$tableName"_Metadata"
                                done
                                touch "$tableName"
                                echo " Table '$tableName' created successfully!"
                            fi
                            break
                            ;;
                        "ListTables")
                            echo " Available tables:"
                            ls
                            break
                            ;;
                        "DropTable")
                            read -p " Enter table name to drop: " tableName
                            if [ -f "$tableName" ]
                            then
                                rm "$tableName"
                                echo "Table '$tableName' deleted successfully!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "InsertIntoTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				echo "Column names:"
        			awk -F: '{print $1}' ".${tableName}_Metadata"
                                read -p "Enter values (seperated (,)): " values
                                echo "$values" >> "$tableName"
                                echo "Data inserted successfully!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "SelectFromTable")
                            read -p " Enter table name to view: " tableName
                            if [ -f "$tableName" ]
                            then

                                cat "$tableName"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "DeleteFromTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				pk_col=$(grep ":PK" ".${tableName}_Metadata" | cut -d':' -f1)
				echo "Primary key column: $pk_col"
				read -p " Enter $pk_col value to delete: " idValue
           			sed -i "/^$idValue,/d" "$tableName"
                                echo "Record deleted!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "UpdateTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				pk_col=$(grep ":PK" ".${tableName}_Metadata" | cut -d':' -f1)
				echo "Primary key column: $pk_col"
				read -p " Enter $pk_col value to update: " idValue
			        echo "Column names:"
                                awk -F: '{print $1}' ".${tableName}_Metadata"
                                read -p " Enter new row values (separated(,)): " newRow
                                sed -i "s/^$idValue,.*/$newRow/" "$tableName"
                                echo "Record updated!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "BackToMain")
                            cd "$dir_path"
                            break 2
                            ;;
                        *)
                            echo " Invalid option!"
                            break
                            ;;
                        esac
                    done
                done
            else
                echo "DataBase is not exist "
            fi
            break
            ;;        
        "Drop_DataBase")
            read -p "Enter database name to drop: " DBname
            if [ -e "$DBname" ]; then
                rm -r "$DBname"
                echo "Database '$DBname' deleted successfully."
            else
                echo "Database '$DBname' does not exist."
            fi
            ;;
        
        "Exit")
            exit
            ;;
        
        *)
            echo "Invalid option."
            ;;
    esac
done

COMMINT


dir_path="/home/electronica/bashdb"
#dir_path="/home/omar/iti/bashDB"
# Check if DBMS directory exists
if [ -e "$dir_path" ]; then
    cd "$dir_path"
    echo "DBMS is ready."
else
    mkdir "$dir_path"
    cd "$dir_path"
    echo "DBMS is ready."
fi

select option in Create_DataBase List_DataBases Connect_DataBase Drop_DataBase Exit
do
    case $option in 
        "Create_DataBase")
            read -p "Enter database name: " DBname
            if [ -e "$DBname" ]; then
                echo "Database '$DBname' already exists."
            else
                mkdir "$DBname"
                echo "Database '$DBname' created successfully."
            fi
            ;;
        
        "List_DataBases")
            echo "Listing databases:"
            ls "$dir_path"
            ;;
        
        "Connect_DataBase") 
            read -p "enter database name: " selectedDB
            if [ -e "$selectedDB" ]
            then
                cd "$selectedDB"
                echo "connected to $selectedDB "
                while true
                do
                    echo -e "\n Database: $selectedDB"
                    PS3="Select an option: "
                    select dbOption in CreateTable ListTables DropTable InsertIntoTable SelectFromTable DeleteFromTable UpdateTable BackToMain
                    do
                        case "$dbOption" in
                        "CreateTable")
                            read -p " Enter table name: " tableName
                            if [ -e "$tableName" ]
                            then
                                echo "Table already exists!"
                            else
                                read -p " Enter columns number : " colNum
				pk=0
                                for((i=1;i<=colNum;i++))
                                do
                                    line=""
                                    read -p " Enter column name $i : " colName
                                    line+="$colName"
                                    read -p " Enter column data type(int/string) : " colType
                                    line+=:"$colType"
				    if [[ "$pk" -eq 0 ]]
			            then
                                    read -p " Do you want to make this column PK(Y/N) : " checkPK
                                    	if [[  "yes" =~ "$checkPK" ]]
                                    	then
                                        	line+=:PK
						pk=1
                                    	fi
			            fi
                                    echo "$line" >> .$tableName"_Metadata"
                                done
                                touch "$tableName"
                                echo " Table '$tableName' created successfully!"
                            fi
                            break
                            ;;
                        "ListTables")
                            echo " Available tables:"
                            ls
                            break
                            ;;
                        "DropTable")
                            read -p " Enter table name to drop: " tableName
                            if [ -f "$tableName" ]
                            then
                                rm "$tableName"
                                echo "Table '$tableName' deleted successfully!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "InsertIntoTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				echo "Column names:"
        			awk -F: '{print $1}' ".${tableName}_Metadata"
                                read -p "Enter values (seperated (,)): " values
                                echo "$values" >> "$tableName"
                                echo "Data inserted successfully!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "SelectFromTable")
                            read -p " Enter table name to view: " tableName
                            if [ -f "$tableName" ]
                            then

                                cat "$tableName"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "DeleteFromTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				pk_col=$(grep ":PK" ".${tableName}_Metadata" | cut -d':' -f1)
				echo "Primary key column: $pk_col"
				read -p " Enter $pk_col value to delete: " idValue
           			sed -i "/^$idValue,/d" "$tableName"
                                echo "Record deleted!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "UpdateTable")
                            read -p " Enter table name: " tableName
                            if [ -f "$tableName" ]
                            then
				pk_col=$(grep ":PK" ".${tableName}_Metadata" | cut -d':' -f1)
				echo "Primary key column: $pk_col"
				read -p " Enter $pk_col value to update: " idValue
			        echo "Column names:"
                                awk -F: '{print $1}' ".${tableName}_Metadata"
                                read -p " Enter new row values (separated(,)): " newRow
                                sed -i "s/^$idValue,.*/$newRow/" "$tableName"
                                echo "Record updated!"
                            else
                                echo " Table does not exist!"
                            fi
                            break
                            ;;
                        "BackToMain")
                            cd "$dir_path"
                            break 2
                            ;;
                        *)
                            echo " Invalid option!"
                            break
                            ;;
                        esac
                    done
                done
            else
                echo "DataBase is not exist "
            fi
            break
            ;;
        "Drop_DataBase")
            read -p "Enter database name to drop: " DBname
            if [ -e "$DBname" ]; then
                rm -r "$DBname"
                echo "Database '$DBname' deleted successfully."
            else
                echo "Database '$DBname' does not exist."
            fi
            ;;
        
        "Exit")
            exit
            ;;
        
        *)
            echo "Invalid option."
            ;;
    esac
done
