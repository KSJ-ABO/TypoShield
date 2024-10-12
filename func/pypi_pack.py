def check_package(package_name):
    url = f"https://pypi.org/pypi/{package_name}/json"
    response = requests.get(url)

    if response.status_code == 200:
        package_info = response.json()
        print(f"Package Name: {package_info['info']['name']}")
        print(f"Version: {package_info['info']['version']}")
        print(f"Summary: {package_info['info']['summary']}")
    else:
        print(f"패키지를 찾을 수 없습니다: {package_name}")

# 사용 예시

package_name = input("확인할 패키지 이름을 입력하세요: ")
check_package(package_name)
