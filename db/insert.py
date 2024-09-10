#insert

import pymysql
import pandas as pd

conn = pymysql.connect(
    host='localhost',
    user='ABO',
    password='!@ABOkSj0812@!',
    database='ABO',
    charset='utf8'
)

cur = conn.cursor()

def csv_to_name(file_path):
    count = 0
    
    try:
        df = pd.read_csv(file_path)
        
        for name in df['name']:
            insert(name) 
    except Exception as e:
        print(f"csv_to_name error : {e}")

    
def insert(name):
    try:
        result = cur.execute("insert into PackageName values (%s)", name)
        conn.commit()
        
    except pymysql.MySQLError as e:
        print(f"insert error: {e}")
    
    

csv_to_name('./dataset/dataset1.csv')
cur.close()
conn.close()

