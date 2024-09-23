import ast
import sys
import os
import algo2
    
def get_imported_packages(file_path):
    if not os.path.isfile(file_path):
        print(f"오류: '{file_path}' 파일이 존재하지 않습니다.")
        return []

    packages = set()
    
    with open(file_path, 'r') as file:
        code = file.read()
        try:
            tree = ast.parse(code, filename=file_path)
            # 문법 오류가 없을 경우 패키지명 추가
            for node in ast.walk(tree):
                if isinstance(node, ast.Import):
                    for n in node.names:
                        packages.add(n.name)  # import 패키지명 추가
                elif isinstance(node, ast.ImportFrom):
                    packages.add(node.module)  # from 패키지명 추가
        except SyntaxError as e:
            print(f"문법 오류가 발생했습니다: {e}")
            # 문법 오류가 발생하더라도 패키지 추출을 시도
            for line in code.splitlines():
                # import 문을 포함한 라인만 추출
                if line.startswith('import ') or line.startswith('from '):
                    try:
                        # import 문을 파싱하여 패키지명 추가
                        node = ast.parse(line)
                        for subnode in ast.walk(node):
                            if isinstance(subnode, ast.Import):
                                for n in subnode.names:
                                    packages.add(n.name)
                            elif isinstance(subnode, ast.ImportFrom):
                                packages.add(subnode.module)
                    except SyntaxError:
                        continue  # 문법 오류 무시하고 계속 진행
    
    return list(packages)

def main(file_path):
    packages = get_imported_packages(file_path)
    list=algo2.main(packages)
    print(list)
    
file_path = sys.argv[1]
if not file_path:
        print("파일이 선택되지 않았습니다.")
else:
    main(file_path)
    

