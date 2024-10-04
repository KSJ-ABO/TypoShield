#insert

import pymysql
import json

conn = pymysql.connect(
    host='localhost',
    user='root',
    password='abo!@Fighting!',
    database='ABO',
    charset='utf8'
)

cur = conn.cursor()

def json_to_name(file_path):
    count = 0
    
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            data = json.load(file)
    
        name_values = [row["project"] for row in data["rows"]]
        print("Extracted names:", name_values)
        
        for name in name_values:
            insert(name) 
    except Exception as e:
        print(f"json_to_name error : {e}")

    
def insert(name):
    try:
        result = cur.execute("insert into Pypi_PackageName values (%s)", name)
        conn.commit()
        
    except pymysql.MySQLError as e:
        print(f"insert error: {e}")
    
    

json_to_name('./pypi.json')
cur.close()
conn.close()

