import ast
import sys

data = sys.argv[1]
data = ast.literal_eval(data)

row_count = len(data)
for package, packages in data:
    print(f"package: {package}")
    for item in packages:
        print(f"  Name: {item[0]}, Similarity: {item[1]}")

