import ast
import sys

data = sys.argv[1]
data = ast.literal_eval(data)

row_count = len(data)
column_counts = [len(item[1]) for item in data]

print(row_count)
