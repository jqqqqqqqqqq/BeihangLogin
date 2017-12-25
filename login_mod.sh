#!/bin/bash
username="Student ID No."
password="Student ID PW"
useragent="Opera/9.23 (Nintendo Wii; U; ; 1038-58; Wii Internet Channel/1.0; en)"
retry=5

#### DO NOT EDIT THIS LINE BELOW ####

attempts=0
option=$1

logout()
{
    echo "Logging out..."
    result=$(curl -s -k -A "$useragent" -d "action=logout&username=${username}&password=${password}&ajax=1" "https://10.200.21.4/include/auth_action.php")
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
    while [ $attempts -lt $retry ]
    do
	    attempts=`expr $attempts + 1`
	    echo "Sending login request... Attempt "$attempts
	    result=$(curl -s -k -A "$useragent" -d "action=login&username=${username}&password={B}$(urlencode `echo -n $password|base64`)&ac_id=22&user_ip=&nas_ip=&user_mac=&save_me=1&ajax=1" "https://10.200.21.4:803/beihanglogin.php?ac_id=22&amp;url=https://10.200.21.4:803/beihangview.php")
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
    result=$(curl -s -k -A "$useragent" -d "action=get_online_info&key=45343" "https://10.200.21.4/include/auth_action.php")
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
