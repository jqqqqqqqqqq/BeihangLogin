#!/bin/bash
username="你的学号"
password="你的密码"
useragent="Opera/9.23 (Nintendo Wii; U; ; 1038-58; Wii Internet Channel/1.0; en)"
retry=5

#### DO NOT EDIT THIS LINE BELOW ####

attemps=0
option=$1

logout()
{
    echo "Logging out..."
    result=$(curl -s -k -A "$useragent" -d "action=logout&username=${username}&password=${password}" "https://gw.buaa.edu.cn:803/cgi-bin/srun_portal")
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
    while [ $attemps -lt $retry ]
    do
	    attemps=`expr $attemps + 1`
	    echo "Sending login request... Attemp "$attemps
	    result=$(curl -s -k -A "$useragent" -d "action=login&username=${username}&password={B}$(urlencode `echo -n $password|base64`)&ac_id=22&user_ip=&nas_ip=&user_mac=&save_me=1&ajax=1" "https://gw.buaa.edu.cn:803/beihanglogin.php?ac_id=22&amp;url=https://gw.buaa.edu.cn:803/beihangview.php")
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
