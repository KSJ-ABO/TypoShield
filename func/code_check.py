import ast
import sys
import subprocess
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

def main():
    # Tkinter 루트를 숨깁니다
    Tk().withdraw()
    
    # 사용자로부터 코드 파일 선택
    file_path = askopenfilename(title="코드 파일 선택", filetypes=[("Python files", "*.py")])
    
    if not file_path:
        print("파일이 선택되지 않았습니다.")
        return
    
    # 패키지 이름 추출
    packages = get_imported_packages(file_path)
    
    # algorithm.py 실행
    packages_str = ','.join(packages)
    subprocess.run([sys.executable, 'algorithm.py', packages_str])

if __name__ == "__main__":
    main()
