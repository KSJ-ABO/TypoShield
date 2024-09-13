import sys
import pymysql

def check_cache(input):
  conn = pymysql.connect(
    host='211.188.53.248',
    user='ABO',
    password='!@ABOkSj0812@!',
    database='ABO',
    charset='utf8'
    )  
  cur = conn.cursor() 
  data = cur.execute("SELECT * FROM cache WHERE typo_name = %s", (input,)) 
  if data == null:
    return 0;
  else:
    return data;
    

check_cache(sys.argv[1])
print(data)
