#!/bin/bash

option_a=false

# check priv
if [ "$EUID" -ne 0 ]; then
    echo "root 권한으로 스크립트를 실행하여 주십시오."
    exit
fi

if [ -z "$1" ]; then
    echo "잘못된 입력 (사용법: $0 [패키지명])"
    exit 1
fi

# check option
while getopts "pc" opt; do
  case $opt in
    p)
      option_p=true
      INPUT="$OPTARG"
      ;;
    c)
      option_c=true
      INPUT_file="$OPTARG"
      ;;
    *)
      echo "Usage: $0 [-p] [-c]"
      echo "[-p] [package_name]: install package"
      echo "[-c] [file_path]: check python code file pakage "
      exit 1
      ;;
  esac
done

if $option_p; then
    EXIST=$(apt-cache search "$INPUT" | grep -w "$INPUT")
    
    if [ -z "$EXIST" ]; then
       echo "해당 패키지는 존재하지 않습니다."
       echo "존재하는 패키지가 맞습니까?"
    
       read -p "Y/N: " OKAY
       OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
       if [ "$OKAY" = "Y" ]; then
          echo "해당 패키지를 대상으로 지정합니다"
       else
          echo "종료합니다."
          exit 1
       fi
    else
        echo "해당 패키지에 대한 오타 스쿼팅 여부를 판단합니다."
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
        
    RESULT=$(python3 ./func/test.py "$INPUT") # 머신러닝에 입력 값 삽입
    RESULT_ARRAY=($RESULT) # 결과 순서가 (test, 유사도, 1)인 경우로 가정
       
    ACCURACY=${RESULT_ARRAY[0]}
    NAME=${RESULT_ARRAY[1]}
    STATE=${RESULT_ARRAY[2]}
    
    if [ "$STATE" -eq 0 ]; then
       echo "$INPUT 에서 오타스쿼팅 확률이 발견되지않았습니다. 패키지를 다운 받습니다."
       sudo apt-get install -y "$INPUT"
       if [$? -eq 0]; then
          echo "$INPUT 패키지 설치 완료."
       else
          echo "$INPUT 패키지 설치 실패"
       fi
    elif [ "$STATE" -eq 1 ]; then
       echo "해당 패키지는 $NAME 과 $ACCURACY의 유사도가 판별되었습니다. 오타스쿼팅일 가능성이 존재합니다. $INPUT을 다시 한번 확인해보시길 바랍니다"
       echo "의도한 패키지가 맞다면 설치를 계속하시겠습니까? (Y/N)"
       read -p "Y/N: " OKAY
       OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
       if [ "$OKAY" = "Y" ]; then
          sudo apt-get install -y "$INPUT"
          if [ $? -eq 0 ]; then
             echo "$INPUT 패키지 설치 완료."
          else
             echo "$INPUT 패키지 설치 실패"
          fi
       else   
          exit 1
       fi
    elif [ "$STATE" -eq 2 ]; then
       echo "$INPUT 패키지는 오타스쿼팅 패키지일 확률이 낮지만, 유사한 이름의 패키지가 존재합니다. 원하는 패키지가 '$INPUT'이 맞습니까?"
       echo "의도한 패키지가 맞다면 설치를 계속하시겠습니까? (Y/N)"
       read -p "Y/N: " OKAY
       OKAY=$(echo "$OKAY" | tr '[:lower:]' '[:upper:]')
       if [ "$OKAY" = "Y" ]; then
           sudo apt-get install -y "$INPUT"
          if [ $? -eq 0 ]; then
              echo "$INPUT 패키지 설치 완료."
          else
             echo "$INPUT 패키지 설치 실패"
          fi
       else
          echo "종료합니다."
          exit 1
       fi
    else
       echo "시스템 오류"
    fi
fi

if $option_c; then
    
