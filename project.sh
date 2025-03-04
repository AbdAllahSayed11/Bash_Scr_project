#!/usr/bin/bash

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
            read -p "Enter database name to connect: " connectDB
            if [ -e "$connectDB" ]; then
                cd "$connectDB"
                echo "Connected to database '$connectDB'."

                # Table management menu
                select table_option in Create_Table List_tables Drop_Table Insert_into_Table Select_From_Table Delete_From_Table Update_Table Exit
                do
                    case $table_option in
                        "Create_Table")
                            read -p "Enter table name: " tbName
                            if [ -e "$tbName" ]; 
                            then
                                echo "Table '$tbName' already exists."
                            else
                                read -p "Please enter column number to be created: " numcol
                                touch "$tbName"
                                touch ".$tbName.metadata"
                                pkFound=false
                                
                                for ((i=1;i<=$numcol;i++))
                                do
                                    line=""
                                    read -p "Please enter column $i name: " colName
                                    line+="$colName"
                                    
                                    echo "Select data type for $colName:"
                                    select dataType in String Integer
                                    do
                                        case $dataType in
                                            "String")
                                                line+=":string"
                                                break
                                                ;;
                                            "Integer")
                                                line+=":int"
                                                break
                                                ;;
                                            *)
                                                echo "Invalid option, please select again."
                                                ;;
                                        esac
                                    done
                                    
                                    if [ "$pkFound" = false ]
                                    then
                                        read -p "Do you want to make this column a primary key? (y/n): " checkPK
                                        if [[ "$checkPK" == [Yy]* ]]
                                        then
                                            line+=":PK"
                                            pkFound=true
                                        fi
                                    fi
                                    
                                    echo "$line" >> ".$tbName.metadata"
                                done
                                
                                if [ "$pkFound" = false ]
                                then
                                    echo "Warning: No primary key defined for table '$tbName'."
                                fi
                                
                                echo "Table '$tbName' created successfully."
                            fi
                            ;;
                        
                        "List_tables")
                            echo "Listing tables in database '$connectDB':"
                            ls -p | grep -v /
                            ;;
                        
                        "Drop_Table")
                            read -p "Enter table name to drop: " table_to_drop
                            if [ -e "$table_to_drop" ]; then
                                rm "$table_to_drop"
                                rm ".$table_to_drop.metadata" 2>/dev/null
                                echo "Table '$table_to_drop' dropped successfully."
                            else
                                echo "Table '$table_to_drop' does not exist."
                            fi
                            ;;
"Insert_into_Table")
    read -p "Enter table name: " tbName
    if [ -e "$tbName" ]; then
        if [ -e ".$tbName.metadata" ]; then
            # Initialize variables
            record=""
            pk_column=""
            pk_position=0
            
            # Find the primary key column (if any)
            count=1
            while IFS= read -r line; do
                if [[ "$line" == *":PK" ]]; then
                    pk_column=$(echo "$line" | cut -d':' -f1)
                    pk_position=$count
                fi
                ((count++))
            done < ".$tbName.metadata"
            
            # Get values for each column
            count=1
            while IFS= read -r line; do
                col_name=$(echo "$line" | cut -d':' -f1)
                col_type=$(echo "$line" | cut -d':' -f2)
                
                # Keep asking until valid input
                while true; do
                    read -p "Enter value for $col_name ($col_type): " value
                    
                    # Basic validation
                    if [ "$col_type" = "int" ] && ! [[ "$value" =~ ^[0-9]+$ ]]; then
                        echo "Please enter a valid integer"
                        continue
                    fi
                    
                    if [[ "$value" == ":" ]]; then
                        echo "Value cannot contain ':' character"
                        continue
                    fi
                    
                    # Check primary key if this is the PK column
                    if [ $count -eq $pk_position ] && [ -s "$tbName" ]; then
                        is_duplicate=0
                        while IFS= read -r rec; do
                            field=$(echo "$rec" | cut -d':' -f$pk_position)
                            if [ "$field" = "$value" ]; then
                                is_duplicate=1
                                break
                            fi
                        done < "$tbName"
                        
                        if [ $is_duplicate -eq 1 ]; then
                            echo "Error: Primary key value already exists"
                            continue
                        fi
                    fi
                    
                    break
                done
                
                # Add to record
                if [ -z "$record" ]; then
                    record="$value"
                else
                    record="$record:$value"
                fi
                
                ((count++))
            done < ".$tbName.metadata"
            
            # Save the record
            echo "$record" >> "$tbName"
            echo "Record inserted successfully"
        else
            echo "Error: Metadata file not found"
        fi
    else
        echo "Error: Table does not exist"
    fi
    ;;


                        
		
		"Select_From_Table")
                            read -p "Enter table name: " tbName
                            if [ -e "$tbName" ]; then
                                if [ -e ".$tbName.metadata" ]; then
                                    echo "Select option:"
                                    PS3="Select option: "
                                    select select_option in "Select All" "Select by Column" "Select by Row" "Back"
                                    do
                                        case $select_option in
                                            "Select All")
                                                echo "Table: $tbName"
                                                echo "-----------------"
                                                
                                                # Print header
                                                header=""
                                                while IFS= read -r line
                                                do
                                                    colName=$(echo "$line" | cut -d':' -f1)
                                                    if [ -z "$header" ]; then
                                                        header="$colName"
                                                    else
                                                        header="$header | $colName"
                                                    fi
                                                done < ".$tbName.metadata"
                                                echo "$header"
                                                echo "-----------------"
                                                
                                                # Print data
                                                while IFS= read -r record
                                                do
                                                    formatted=$(echo "$record" | tr ':' ' | ')
                                                    echo "$formatted"
                                                done < "$tbName"
                                                break
                                                ;;
                                                
                                            "Select by Column")
                                                # Show available columns
                                                echo "Available columns:"
                                                counter=1
                                                declare -a columns
                                                while IFS= read -r line
                                                do
                                                    colName=$(echo "$line" | cut -d':' -f1)
                                                    echo "$counter) $colName"
                                                    columns[$counter]="$colName"
                                                    ((counter++))
                                                done < ".$tbName.metadata"
                                                
                                                read -p "Enter column number to select by: " colNum
                                                if [[ "$colNum" =~ ^[0-9]+$ ]] && [ "$colNum" -ge 1 ] && [ "$colNum" -lt "$counter" ]; then
                                                    read -p "Enter value to search for: " searchVal
                                                    
                                                    echo "Results for ${columns[$colNum]}='$searchVal':"
                                                    echo "-----------------"
                                                    
                                                    # Print header
                                                    header=""
                                                    while IFS= read -r line
                                                    do
                                                        colName=$(echo "$line" | cut -d':' -f1)
                                                        if [ -z "$header" ]; then
                                                            header="$colName"
                                                        else
                                                            header="$header | $colName"
                                                        fi
                                                    done < ".$tbName.metadata"
                                                    echo "$header"
                                                    echo "-----------------"
                                                    
                                                    # Search and print matching records
                                                    colIndex=$((colNum-1))
                                                    found=false
                                                    while IFS= read -r record
                                                    do
                                                        value=$(echo "$record" | cut -d':' -f$colNum)
                                                        if [ "$value" = "$searchVal" ]; then
                                                            formatted=$(echo "$record" | tr ':' ' | ')
                                                            echo "$formatted"
                                                            found=true
                                                        fi
                                                    done < "$tbName"
                                                    
                                                    if [ "$found" = false ]; then
                                                        echo "No matching records found."
                                                    fi
                                                else
                                                    echo "Invalid column number."
                                                fi
                                                break
                                                ;;
                                                
                                            "Select by Row")
                                                read -p "Enter row number to display: " rowNum
                                                if [[ "$rowNum" =~ ^[0-9]+$ ]]; then
                                                    totalRows=$(wc -l < "$tbName")
                                                    if [ "$rowNum" -ge 1 ] && [ "$rowNum" -le "$totalRows" ]; then
                                                        echo "Row $rowNum:"
                                                        echo "-----------------"
                                                        
                                                        # Print header
                                                        header=""
                                                        while IFS= read -r line
                                                        do
                                                            colName=$(echo "$line" | cut -d':' -f1)
                                                            if [ -z "$header" ]; then
                                                                header="$colName"
                                                            else
                                                                header="$header | $colName"
                                                            fi
                                                        done < ".$tbName.metadata"
                                                        echo "$header"
                                                        echo "-----------------"
                                                        
                                                        # Print specific row
                                                        sed -n "${rowNum}p" "$tbName" | tr ':' ' | '
                                                    else
                                                        echo "Row number out of range."
                                                    fi
                                                else
                                                    echo "Invalid row number."
                                                fi
                                                break
                                                ;;
                                                
                                            "Back")
                                                break
                                                ;;
                                                
                                            *)
                                                echo "Invalid option."
                                                ;;
                                        esac
                                    done
                                else
                                    echo "Error: Metadata file for table '$tbName' not found."
                                fi
                            else
                                echo "Table '$tbName' does not exist."
                            fi
                            ;;
                        
                        "Delete_From_Table")
                            read -p "Enter table name: " tbName
                            if [ -e "$tbName" ]; then
                                echo "Delete options:"
                                PS3="Delete option: "
                                select delete_option in "Delete All" "Delete by Column" "Back"
                                do
                                    case $delete_option in
                                        "Delete All")
                                            read -p "Are you sure you want to delete all records? (y/n): " confirm
                                            if [[ "$confirm" == [Yy]* ]]; then
                                                > "$tbName"  # Empty the file
                                                echo "All records deleted successfully."
                                            else
                                                echo "Operation cancelled."
                                            fi
                                            break
                                            ;;
                                            
                                        "Delete by Column")
                                            # Show available columns
                                            echo "Available columns:"
                                            counter=1
                                            declare -a columns
                                            while IFS= read -r line
                                            do
                                                colName=$(echo "$line" | cut -d':' -f1)
                                                echo "$counter) $colName"
                                                columns[$counter]="$colName"
                                                ((counter++))
                                            done < ".$tbName.metadata"
                                            
                                            read -p "Enter column number to delete by: " colNum
                                            if [[ "$colNum" =~ ^[0-9]+$ ]] && [ "$colNum" -ge 1 ] && [ "$colNum" -lt "$counter" ]; then
                                                read -p "Enter value to delete: " delVal
                                                
                                                # Create temporary file
                                                touch "$tbName.tmp"
                                                deletedCount=0
                                                
                                                # Copy non-matching records to temp file
                                                while IFS= read -r record
                                                do
                                                    value=$(echo "$record" | cut -d':' -f$colNum)
                                                    if [ "$value" != "$delVal" ]; then
                                                        echo "$record" >> "$tbName.tmp"
                                                    else
                                                        ((deletedCount++))
                                                    fi
                                                done < "$tbName"
                                                
                                                # Replace original with temp file
                                                mv "$tbName.tmp" "$tbName"
                                                
                                                if [ $deletedCount -gt 0 ]; then
                                                    echo "$deletedCount record(s) deleted successfully."
                                                else
                                                    echo "No matching records found."
                                                fi
                                            else
                                                echo "Invalid column number."
                                            fi
                                            break
                                            ;;
                                            
                                        "Back")
                                            break
                                            ;;
                                            
                                        *)
                                            echo "Invalid option."
                                            ;;
                                    esac
                                done
                            else
                                echo "Table '$tbName' does not exist."
                            fi
                            ;;
                        
                        "Update_Table")
                            read -p "Enter table name: " tbName
                            if [ -e "$tbName" ]; then
                                if [ -e ".$tbName.metadata" ]; then
                                    # Show available columns for condition
                                    echo "Available columns:"
                                    counter=1
                                    declare -a columns
                                    declare -a colTypes
                                    declare -a isPKs
                                    
                                    while IFS= read -r line
                                    do
                                        colName=$(echo "$line" | cut -d':' -f1)
                                        colType=$(echo "$line" | cut -d':' -f2)
                                        isPK=$(echo "$line" | grep -c ":PK")
                                        
                                        echo "$counter) $colName"
                                        columns[$counter]="$colName"
                                        colTypes[$counter]="$colType"
                                        isPKs[$counter]="$isPK"
                                        ((counter++))
                                    done < ".$tbName.metadata"
                                    
                                    # Get condition column
                                    read -p "Enter column number to search by: " searchColNum
                                    if [[ "$searchColNum" =~ ^[0-9]+$ ]] && [ "$searchColNum" -ge 1 ] && [ "$searchColNum" -lt "$counter" ]; then
                                        read -p "Enter value to search for: " searchVal
                                        
                                        # Get update column
                                        read -p "Enter column number to update: " updateColNum
                                        if [[ "$updateColNum" =~ ^[0-9]+$ ]] && [ "$updateColNum" -ge 1 ] && [ "$updateColNum" -lt "$counter" ]; then
                                            # Check if trying to update PK
                                            if [ "${isPKs[$updateColNum]}" -eq 1 ]; then
                                                read -p "Warning: Updating primary key. Are you sure? (y/n): " pkConfirm
                                                if [[ "$pkConfirm" != [Yy]* ]]; then
                                                    echo "Update cancelled."
                                                    break
                                                fi
                                            fi
                                            
                                            # Get new value with validation
                                            validInput=false
                                            while [ "$validInput" = false ]
                                            do
                                                read -p "Enter new value for ${columns[$updateColNum]}: " newVal
                                                
                                                # Validate based on data type
                                                if [ "${colTypes[$updateColNum]}" = "int" ]; then
                                                    if [[ "$newVal" =~ ^[0-9]+$ ]]; then
                                                        validInput=true
                                                    else
                                                        echo "Error: Please enter a valid integer."
                                                    fi
                                                else
                                                    # For string type, just make sure it doesn't contain the delimiter
                                                    if [[ "$newVal" != *":"* ]]; then
                                                        validInput=true
                                                    else
                                                        echo "Error: Value cannot contain ':' character."
                                                    fi
                                                fi
                                                
                                                # If updating PK, check uniqueness
                                                if [ "${isPKs[$updateColNum]}" -eq 1 ] && [ "$validInput" = true ]; then
                                                    if grep -q "^$newVal:" "$tbName" || grep -q ":$newVal:" "$tbName"; then
                                                        echo "Error: Primary key '$newVal' already exists!"
                                                        validInput=false
                                                    fi
                                                fi
                                            done
                                            
                                            # Create temporary file
                                            touch "$tbName.tmp"
                                            updatedCount=0
                                            
                                            # Process each record
                                            while IFS= read -r record
                                            do
                                                value=$(echo "$record" | cut -d':' -f$searchColNum)
                                                if [ "$value" = "$searchVal" ]; then
                                                    # Split record into array
                                                    IFS=':' read -ra fields <<< "$record"
                                                    
                                                    # Update the specified field
                                                    fields[$((updateColNum-1))]="$newVal"
                                                    
                                                    # Reconstruct the record
                                                    newRecord=$(IFS=':'; echo "${fields[*]}")
                                                    echo "$newRecord" >> "$tbName.tmp"
                                                    ((updatedCount++))
                                                else
                                                    echo "$record" >> "$tbName.tmp"
                                                fi
                                            done < "$tbName"
                                            
                                            # Replace original with temp file
                                            mv "$tbName.tmp" "$tbName"
                                            
                                            if [ $updatedCount -gt 0 ]; then
                                                echo "$updatedCount record(s) updated successfully."
                                            else
                                                echo "No matching records found."
                                            fi
                                        else
                                            echo "Invalid update column number."
                                        fi
                                    else
                                        echo "Invalid search column number."
                                    fi
                                else
                                    echo "Error: Metadata file for table '$tbName' not found."
                                fi
                            else
                                echo "Table '$tbName' does not exist."
                            fi
                            ;;
                        
                        "Exit")
                            cd "$dir_path"
                            break
                            ;;
                        
                        *)
                            echo "Invalid option."
                            ;;
                    esac
                done
            else
                echo "Database '$connectDB' does not exist."
            fi
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
