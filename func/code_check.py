import ast
import sys
import os
import algo


def get_imported_packages(file_path):
    if not os.path.isfile(file_path):
        print(f"오류: '{file_path}' 파일이 존재하지 않습니다.")
        return []

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
    if not file_path:
        print("파일이 선택되지 않았습니다.")
        return
    
    # 패키지 이름 추출
    packages = get_imported_packages(file_path)
    
    # algorithm.py 실행
    list=algo2.main(packages)

    print(list)

