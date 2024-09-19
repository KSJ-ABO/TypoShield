import ast
import sys


data = sys.argv[1]
data = ast.literal_eval(data)

row_count = len(data)
for package, packages in data:
    print("-------------------------------------------")
    print(f"package: {package}")
    print("-------------------------------------------")
    for i, item in enumerate(packages):
        if i >= 4:
            break
        print(f"  Name: {item[0]}, Similarity: {item[1]}")

