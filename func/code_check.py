import ast
import sys
import subprocess
from tkinter import Tk
from tkinter.filedialog import askopenfilename

def get_imported_packages(file_path):
    packages = set()

    with open(file_path, 'r') as file:
        code = file.readlines()  # 라인 단위로 읽기

        for line in code:
            if line.startswith('import ') or line.startswith('from '):
                try:
                    # 라인을 ast로 파싱하여 패키지명 추출
                    node = ast.parse(line)
                    for subnode in ast.walk(node):
                        if isinstance(subnode, ast.Import):
                            for n in subnode.names:
                                packages.add(n.name)
                        elif isinstance(subnode, ast.ImportFrom):
                            packages.add(subnode.module)
                except SyntaxError:
                    # 문법 오류가 발생한 경우, 해당 라인을 무시
                    print(f"문법 오류가 발생한 라인: {line.strip()}")
                    continue
                except Exception as e:
                    print(f"예외가 발생했습니다: {e}")

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
