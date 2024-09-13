import sys
import pymysql

def insert_cache():
  conn = pymysql.connect(
    host='211.188.53.248t',
    user='ABO',
    password='!@ABOkSj0812@!',
    database='ABO',
    charset='utf8'
    )
  
  try:
    cur.execute(“"INSERT INTO cache VALUES (typo_name, accuracy, name)")
    conn.commit()
  finally:
    conn.close()
    return 1;

typo_name = sys.argv[1]
accuracy = float(sys.argv[2])
name = sys.argv[3]

insert_cache(typo_name, accuracy, name)
