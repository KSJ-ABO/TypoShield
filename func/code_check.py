import ast
import sys
import subprocess
from tkinter import Tk
from tkinter.filedialog import askopenfilename

def get_imported_packages(file_path):
    packages = set()  # 패키지명을 저장할 집합

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

    return list(packages)

def main():
    Tk().withdraw()
    
    file_path = askopenfilename(title="코드 파일 선택", filetypes=[("Python files", "*.py")])
    
    if not file_path:
        print("파일이 선택되지 않았습니다.")
        return
    
    packages = get_imported_packages(file_path)
    
    if not packages:
        print("패키지를 추출할 수 없습니다.")
        return
    
    packages_str = ','.join(packages)
    subprocess.run([sys.executable, 'algorithm.py', packages_str])

if __name__ == "__main__":
    main()
