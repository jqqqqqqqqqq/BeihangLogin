"""
This is a simple script for students in BUAA to check their remaining network traffic (in bytes).
Usage: python buaa_traffic.py [username]
Your username is your ID number.
"""
import sys
import requests
import json

UNFORMATTED_URL = "https://gw.buaa.edu.cn:803/beihang.php?route=getPackage&username={0}&pid=6"
USERNAME = sys.argv[1]


def check_by_username(username):
    """
    uid: str
    """
    url = UNFORMATTED_URL.format(username)
    res = requests.get(url)
    return res.json()


def main():
    json_dict = check_by_username(USERNAME)
    remain_bytes = json_dict["product_remain_bytes"]
    res = "{:,}".format(remain_bytes)
    print(res)


if __name__ == "__main__":
    main()
