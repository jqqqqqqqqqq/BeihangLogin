"""
This is a simple script for students in BUAA to check their remaining network traffic (in bytes).
Usage: python buaa_traffic.py [uid]
Your uid can be found using Chrome Developer Tools, etc., when you try to log in 'gw.buaa.edu.cn.'
"""
import sys
import requests
import json

UNFORMATTED_URL = "https://gw.buaa.edu.cn:803/beihang.php?route=getPackage&uid={0}&pid=6"
UID = sys.argv[1]


def check_by_uid(uid):
    """
    uid: str
    """
    url = UNFORMATTED_URL.format(uid)
    res = requests.get(url)
    return res.json()


def main():
    json_dict = check_by_uid(UID)
    remain_bytes = json_dict["product_remain_bytes"]
    res = "{:,}".format(remain_bytes)
    print(res)


if __name__ == "__main__":
    main()
