import ast
import sys
import subprocess
import algo
from tkinter import Tk
from tkinter.filedialog import askopenfilename

def get_imported_packages(file_path):
    with open(file_path, 'r') as file:
        tree = ast.parse(file.read(), filename=file_path)
    
    packages = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for n in node.names:
                packages.add(n.name)
        elif isinstance(node, ast.ImportFrom):
            packages.add(node.module)
    
    return list(packages)

def main(file_path):
    # Tkinter 루트를 숨깁니다
    
    if not file_path:
        print("파일이 선택되지 않았습니다.")
        return
    
    # 패키지 이름 추출
    packages = get_imported_packages(file_path)
    
    # algorithm.py 실행
    list=algo.main2(packages)

    print(list)

