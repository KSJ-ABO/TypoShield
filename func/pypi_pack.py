import request

def check_package(package_name):
    url = f"https://pypi.org/pypi/{package_name}"
    response = requests.get(url)

    if response.status_code == 200:
        print "exist"
    else:
        print "None"

# 사용 예시

package_name = input("확인할 패키지 이름을 입력하세요: ")
check_package(package_name)
