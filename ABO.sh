#!/bin/bash

option_a=false

# check priv
if [ "$EUID" -ne 0 ]; then
    echo "root 권한으로 스크립트를 실행하여 주십시오."
    exit
fi

if [ -z "$1" ]; then
    echo "Usage: $0 [-p] [-c]"
    echo "[-p] [package_name]: install package"
    echo "[-c] [file_path]: check python code file pakage "
    exit 1
fi

# check option
while getopts "pc" opt; do
  case $opt in
    p)
      option_p=true
      option_c=false
      ;;
    c)
      option_c=true
      option_p=false
      ;;
    *)
      echo "Usage: $0 [-p] [-c]"
      echo "[-p] [package_name]: install package"
      echo "[-c] [file_path]: check python code file pakage "
      exit 1
      ;;
  esac
done

INPUT=$2

if $option_p; then
    EXIST=$(apt-cache search "$INPUT" | grep -w "$INPUT")
    echo ""
    echo "<typo Squatting Detection System for Packages>"
    echo ""
    if [ -z "$EXIST" ]; then
       echo "No such packages were found."
       echo "Is this the package that exists?"
       read -p "Y/N: " OKAY
       echo ""
       OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
       if [ "$OKAY" = "Y" ]; then
          echo "Target Package: $INPUT"
       else
          echo "Exit."
          exit 1
       fi
    else
        echo "Target Package: $INPUT"
    fi
    
    #CHECK=$(python3 cache.py "$INPUT")
    
    #if [ $CHECK -eq 0 ]; then
    #    RESULT=$(python3 ./func/test.py "$INPUT") # 머신러닝에 입력 값 삽입
    #    RESULT_ARRAY=($RESULT) # 결과 순서가 (test, 유사도, 1)인 경우로 가정
    #    
    #    ACCURACY=${RESULT_ARRAY[0]}
    #    NAME=${RESULT_ARRAY[1]}
    #    STATE=${RESULT_ARRAY[2]}
    #    python3 insert_cache.py "$INPUT", "$ACCURACY", "$NAME"
    #    
    #else
    #    DATA=$(python3 cache.py "$INPUT")
    #    ACCURACY=${DATA[0]}
    #    NAME=${DATA[1]}
    #    STATE=${DATA[2]}

    echo ""
    RESULT=$(python3 ./func/test.py "$INPUT")
    RESULT_ARRAY=($RESULT) # 결과 순서가 (test, 유사도, 1)인 경우로 가정
       
    ACCURACY=${RESULT_ARRAY[0]}
    NAME=${RESULT_ARRAY[1]}
    STATE=${RESULT_ARRAY[2]}


    if (( $(echo "$ACCURACY == 0" | bc -l) )); then
        if [ "$STATE" -eq 0 ]; then
           echo "No typosquotting probabilities found in $INPUT package."
           echo "Download the package..."
           echo ""
           sudo apt-get install -y "$INPUT"
           echo ""
           if [$? -eq 0]; then
              echo "$INPUT Package Installation Completed"
           else
              echo "$INPUT Package Installation Failed"
           fi
        elif [ "$STATE" -eq 1 ]; then
           echo "This package is $ACCURACY similarity to $NAME."
           echo "There's a possibility that it's typosquoting"
           echo "Please check the package you entered again ($INPUT)"
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo "-------------------------------------------"
           echo "Do you want to install this package? (Y/N)"
           read -p "Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           if [ "$OKAY" = "Y" ]; then
              sudo apt-get install -y "$INPUT"
              echo ""
              if [ $? -eq 0 ]; then
                 echo "$INPUT Package Installation Completed"
              else
                 echo "$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "if you want to install package"
               read -p "Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   echo "System Finish"
                   exit 1
               fi
               echo "Download Packge: $TARGET_PACKAGE"
               sudo apt-get install -y "$TARGET_PACKGE"
               echo ""
               if [ $? -eq 0 ]; then
                  echo "$TARGET_PACKGE Package Installation Completed"
              else
                 echo "$TARGET_PACKGE Package Installation Failed"
              fi
           else   
              exit 1
           fi
        elif [ "$STATE" -eq 2 ]; then
           echo "$INPUT This package is less likely to be a typosquotting package."
           echo "It could be a user package.."
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo "-------------------------------------------"
           echo "Do you want to install this package? (Y/N)"
           read -p "Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           if [ "$OKAY" = "Y" ]; then
               sudo apt-get install -y "$INPUT"
              if [ $? -eq 0 ]; then
                  echo "$INPUT Package Installation Completed"
              else
                 echo "$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "if you want to install package"
               read -p "Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   echo "System finish"
                   exit 1
               fi
               echo "Download Packge: $TARGET_PACKAGE"
               sudo apt-get install -y "$TARGET_PACKGE"
               echo ""
               if [ $? -eq 0 ]; then
                  echo "$TARGET_PACKGE Package Installation Completed"
              else
                 echo "$TARGET_PACKGE Package Installation Failed"
              fi 
           else
              echo "DONE."
              exit 1
           fi
        else
           echo "System Error"
        fi
    else
        echo "유사한 패키지가 없습니다."
    fi
fi

if $option_c; then
    LIST=$(python3 ./func/code_check.py "$INPUT")
    if [ $? -eq 0 ]; then
        python3 ./func/get_len.py "$LIST"
    else
        echo "System Error"
   fi
fi
