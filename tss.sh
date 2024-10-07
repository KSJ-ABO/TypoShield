#!/bin/bash

option_a=false

# check priv
if [ "$EUID" -ne 0 ]; then
    echo "root 권한으로 스크립트를 실행하여 주십시오."
    exit
fi

if [ -z "$1" ]; then
    echo "Usage: $0 [-a] [-p] [-c]"
    echo "[-a] [package_name]: install package (APT)"
    echo "[-p] [package_name]: install package (PYPI)"
    echo "[-c] [file_path]: check python code file pakage "
    exit 1
fi

# check option
while getopts "pc" opt; do
  case $opt in
    p}
        option_p=true
        option_a=false
        option_c=false
        if [ -z $2 ]; then
          echo "[-p] [package_name]: install package"
          ext 1
        fi
        ;;
    a)
      option_a=true
      option_c=false
      option_p=false
      if [ -z $2 ]; then
          echo "[-p] [package_name]: install package"
          ext 1
      fi
      ;;
    c)
      option_a=false
      option_c=true
      option_p=false
      if [ -z $2 ]; then
          echo "[-c] [file_path]: check python code file pakage "
          exit 1
      fi
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

clear;

if $option_a; then
    EXIST=$(apt-cache search "$INPUT" | grep -w "$INPUT")
    echo ""
    echo -e "\033[1m<typo Squatting Detection System for Packages>\033[0m"
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
    RESULT=$(python3 ./func/func.py "$INPUT")
    RESULT_ARRAY=($RESULT) # 결과 순서가 (test, 유사도, 1)인 경우로 가정
       
    ACCURACY=${RESULT_ARRAY[0]}
    NAME=${RESULT_ARRAY[1]}
    STATE=${RESULT_ARRAY[2]}


    if (( $(echo "$ACCURACY != 0" | bc -l) )); then
        if [ "$STATE" -eq 0 ]; then
           echo -e "\033[32mNo typosquotting probabilities found in $INPUT package.\033[0m"
           echo "Download the package..."
           echo ""
           sudo apt-get install -y "$INPUT"
           if [ $? -eq 0 ]; then
              echo -e "\n$INPUT Package Installation Completed"
           else
              echo -e "\n$INPUT Package Installation Failed"
           fi
        elif [ "$STATE" -eq 1 ]; then
           echo "This package is $ACCURACY similarity to $NAME."
           echo -e "\033[31mThere's a possibility that it's typosquoting\033[0m"
           echo -e "Please check the package you entered again ($INPUT)\n"
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo -e "-------------------------------------------\n"
           echo -e "Do you want to install this package? \033[1m(Y/N)\033[0m"
           read -p ">> Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           echo ""
           if [ "$OKAY" = "Y" ]; then
              sudo apt-get install -y "$INPUT"
              if [ $? -eq 0 ]; then
                 echo -e "\n$INPUT Package Installation Completed"
              else
                 echo -e "\n$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "Enter a number to download one of those three packages"
               echo "Other numbers shut down the system"
               read -p ">> Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   exit 1
               fi
               echo ""
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo apt-get install -y "$TARGET_PACKAGE"
               if [ $? -eq 0 ]; then
                  echo -e "\n$TARGET_PACKAGE Package Installation Completed"
              else
                 echo -e "\n$TARGET_PACKAGE Package Installation Failed"
              fi
           else   
              exit 1
           fi
        elif [ "$STATE" -eq 2 ]; then
           echo -e "\033[33mThis package is less likely to be a typosquotting package. ($INPUT)\033[0m"
           echo -e "It could be a user package..\n"
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo -e "-------------------------------------------\n"
           echo -e "Do you want to install this package? \033[1m(Y/N)\033[0m"
           
           read -p ">> Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           if [ "$OKAY" = "Y" ]; then
               echo ""
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo apt-get install -y "$INPUT"
              if [ $? -eq 0 ]; then
                  echo -e "\n$INPUT Package Installation Completed"
              else
                 echo -e "\n$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "Enter a number to download one of those three packages"
               echo "Other numbers shut down the system"
               read -p ">> Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   exit 1
               fi
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo apt-get install -y "$TARGET_PACKAGE"
               if [ $? -eq 0 ]; then
                  echo -e "\n$TARGET_PACKAGE Package Installation Completed"
              else
                 echo -e "\n$TARGET_PACKAGE Package Installation Failed"
              fi 
           else
              exit 1
           fi
        else
           echo "System Error"
        fi
    else
        echo "유사한 패키지가 없습니다."
    fi
fi

if option_p; then
    EXIST=$(pip show "$INPUT" | grep -w "$INPUT")
    echo ""
    echo -e "\033[1m<typo Squatting Detection System for Packages>\033[0m"
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
    
    echo ""
    RESULT=$(python3 ./func/func.py "$INPUT")
    RESULT_ARRAY=($RESULT) # 결과 순서가 (test, 유사도, 1)인 경우로 가정
       
    ACCURACY=${RESULT_ARRAY[0]}
    NAME=${RESULT_ARRAY[1]}
    STATE=${RESULT_ARRAY[2]}


    if (( $(echo "$ACCURACY != 0" | bc -l) )); then
        if [ "$STATE" -eq 0 ]; then
           echo -e "\033[32mNo typosquotting probabilities found in $INPUT package.\033[0m"
           echo "Download the package..."
           echo ""
           sudo pip install -y "$INPUT"
           if [ $? -eq 0 ]; then
              echo -e "\n$INPUT Package Installation Completed"
           else
              echo -e "\n$INPUT Package Installation Failed"
           fi
        elif [ "$STATE" -eq 1 ]; then
           echo "This package is $ACCURACY similarity to $NAME."
           echo -e "\033[31mThere's a possibility that it's typosquoting\033[0m"
           echo -e "Please check the package you entered again ($INPUT)\n"
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo -e "-------------------------------------------\n"
           echo -e "Do you want to install this package? \033[1m(Y/N)\033[0m"
           read -p ">> Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           echo ""
           if [ "$OKAY" = "Y" ]; then
              sudo pip install -y "$INPUT"
              if [ $? -eq 0 ]; then
                 echo -e "\n$INPUT Package Installation Completed"
              else
                 echo -e "\n$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "Enter a number to download one of those three packages"
               echo "Other numbers shut down the system"
               read -p ">> Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   exit 1
               fi
               echo ""
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo pip install -y "$TARGET_PACKAGE"
               if [ $? -eq 0 ]; then
                  echo -e "\n$TARGET_PACKAGE Package Installation Completed"
              else
                 echo -e "\n$TARGET_PACKAGE Package Installation Failed"
              fi
           else   
              exit 1
           fi
        elif [ "$STATE" -eq 2 ]; then
           echo -e "\033[33mThis package is less likely to be a typosquotting package. ($INPUT)\033[0m"
           echo -e "It could be a user package..\n"
           echo "-------------------------------------------"
           echo "PackgeName: Similarity"
           echo "-------------------------------------------"
           echo "1. $NAME: $ACCURACY"
           echo "2. ${RESULT_ARRAY[4]}: ${RESULT_ARRAY[3]}"
           echo "3. ${RESULT_ARRAY[6]}: ${RESULT_ARRAY[5]}"
           echo -e "-------------------------------------------\n"
           echo -e "Do you want to install this package? \033[1m(Y/N)\033[0m"
           
           read -p ">> Y/N: " OKAY
           OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
           if [ "$OKAY" = "Y" ]; then
               echo ""
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo pip install -y "$INPUT"
              if [ $? -eq 0 ]; then
                  echo -e "\n$INPUT Package Installation Completed"
              else
                 echo -e "\n$INPUT Package Installation Failed"
              fi
           elif [ "$OKAY" = "N" ]; then
               echo "Enter a number to download one of those three packages"
               echo "Other numbers shut down the system"
               read -p ">> Select Option: " CHOICE
               if [ "$CHOICE" -eq 1 ]; then
                   TARGET_PACKAGE=$NAME
               elif [ "$CHOICE" -eq 2 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[4]}
               elif [ "$CHOICE" -eq 3 ]; then
                   TARGET_PACKAGE=${RESULT_ARRAY[6]}
               else
                   exit 1
               fi
               echo -e "Download Packge: $TARGET_PACKAGE\n"
               sudo pip install -y "$TARGET_PACKAGE"
               if [ $? -eq 0 ]; then
                  echo -e "\n$TARGET_PACKAGE Package Installation Completed"
              else
                 echo -e "\n$TARGET_PACKAGE Package Installation Failed"
              fi 
           else
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
    echo "Explore the package of that path Python file..."
    echo""
    LIST=$(python3 ./func/code_check.py "$INPUT")
    
    if [ $? -eq 0 ]; then
        echo "Prints a list of up to four similarities"
        python3 ./func/get_len.py "$LIST"
        echo -e "-------------------------------------------\n"
    else
        echo "System Error"
   fi
fi
echo ""
