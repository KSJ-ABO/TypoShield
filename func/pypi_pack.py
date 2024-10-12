import requests

package_name = sys.argv[1]

def check_package(package_name):
    url = f"https://pypi.org/pypi/{package_name}"
    response = requests.get(url)

    if response.status_code == 200:
        print "exist"

check_package(package_name}
