#!/bin/bash
USERNAME="你的学号"
PASSWORD="你的密码"
USERAgent="Opera/9.23 (Nintendo Wii; U; ; 1038-58; Wii Internet Channel/1.0; en)"
RETRY=5
INTERFACE="eth0"
#### DO NOT EDIT THIS LINE BELOW ####

attempts=0
option=$1

logout()
{
    echo "Logging out..."
    result=$(curl -s -k -A "$USERAGENT" --interface "$INTERFACE" -d "action=logout&username=${USERNAME}&password=${PASSWORD}&ajax=1" "https://gw.buaa.edu.cn/include/auth_action.php")
    if [[ $result =~ "logout" ]]; then
        echo "Success"
    else
        echo $result
    fi
}

urlencode()
{
    url=$(echo "$1" | sed -e 's/\//%2f/g' -e 's/=/%3d/g')
    echo $url
}

login()
{
    while [ $attempts -lt $RETRY ]
    do
	    attempts=`expr $attempts + 1`
	    echo "Sending login request... Attempt "$attempts
	    result=$(curl -s -k -A "$USERAGENT" --interface "$INTERFACE"-d "action=login&username=${USERNAME}&password={B}$(urlencode `echo -n $PASSWORD|base64`)&ac_id=22&user_ip=&nas_ip=&user_mac=&save_me=1&ajax=1" "https://gw.buaa.edu.cn:803/beihanglogin.php?ac_id=22&amp;url=https://gw.buaa.edu.cn:803/beihangview.php")
	    if [[ $result =~ "login_ok" ]]; then
		    echo "Login success! Your internet connection has been activated."
#		    echo $(date)" Success" >> /tmp/login.txt
		    break;
	    else
		    echo $result
#		    echo $(date)" "$result >> /tmp/login.txt
		    sleep 3
	    fi
    done
}

get_info()  # TODO
{
    result=$(curl -s -k -A "$USERAGENT" --interface "$INTERFACE"-d "action=get_online_info&key=45343" "https://gw.buaa.edu.cn/include/auth_action.php")
}

main()
{
    case $option in
        login)
            login;;
        logout)
            logout;;
        *)
            echo "Usage: \
            login \
            logout" ;;
    esac
}

main
