#!/bin/bash
# Please ensure that `curl` and `openssl` is installed before you run the script.

#####################
# Login Information #
#####################
USERNAME="你的学号"
PASSWORD="你的密码"

#################
# Customization #
#################
# If you need to modify SYSNAME, please use a url-encoded string
SYSNAME="Mac+OS"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.100 Safari/537.36"

#################################
# Utility Functions & Variables #
#################################

# TIMESTAMP: Get current timestamp in ms.
TIMESTAMP=`date +%s%3N`

# str2ascii(str): Convert a character to integer.
function str2ascii()
{
	s=$1
	if [ "$s" == "\"" ]; then
		ascii="34"
	else
		ascii=`printf "%d" "'$s"`
	fi
	return $((ascii))
}

# ascii2str(code): Convert a integer to hex digit code.
function ascii2str()
{
	code=$1
	printf '\\x%x' $code
}

# floor(num): Dirty implementation of Math.floor().
function floor()
{
	result=`echo $1 | cut -f1 -d"."`
	return $((result))
}

# Note that integer in bash in mostly 64 bits, 
# functions below aim to simulate 32 bits calculation.

# sl(base, shift): Bitwise shift left (32 bits).
function sl()
{
	a=$1
	b=$2
	result=$((a<<b))
	if [ "$result" -gt "2147483647" ]; then
		result=$((result&4294967295|18446744069414584320))
	fi
	echo $result
}

# sr(base, shift): Bitwise shift right logical (32 bits).
function sr()
{
	a=$1
	b=$2
	result=$(((a&4294967295)>>b))
	echo $result
}

# xor(num1, num2): Bitwise xor (32 bits).
function xor()
{
	a=$1
	b=$2
	result=$(((a^b)&4294967295))
	if [ "$result" -gt "2147483647" ]; then
		result=$((result|18446744069414584320))
	fi
	echo $result
}

# add(num1, num2): Bitwise add (32 bits).
function add()
{
	a=$1
	b=$2
	result=$(((a+b)&4294967295))
	if [ "$result" -gt "2147483647" ]; then
		result=$((result|18446744069414584320))
	fi
	echo $result
}

######################
# srun_bx1 Algorithm #
######################

# s_func(a, b): reimplement of s()
function s_func()
{
	a=$1
	b=$2
	c=${#a}
	v=()
	aa=(`echo $a | grep -o .`)
	for ((i=0;i<c;i+=4)); do
		idx=$((i>>2))
		str2ascii ${aa[i]}
		item1=$?
		str2ascii ${aa[((i+1))]}
		item2=$?
		item2=$((item2*256))
		str2ascii ${aa[((i+2))]}
		item3=$?
		item3=$((item3*65536))
		str2ascii ${aa[((i+3))]}
		item4=$?
		item4=$((item4*16777216))
		v[idx]=$((item1|item2|item3|item4))
		#echo "v["$idx"]="$((item1|item2|item3|item4))
	done
	if [ "$b" == "1" ]; then
		v[${#v[@]}]=$c
	fi
	v=$( IFS=" "; echo "${v[*]}" )
	echo $v
}

# xEncode(str, challenge): reimplement of xEncode()
function xEncode()
{
	str=$1
	key=$2
	if [ $str == "" ]; then
		return ""
	fi
	v=$(s_func $str "1")
	k=$(s_func $key "0")
	v=($v)
	k=($k)
	#echo ${v[@]} > v.txt
	#echo ${k[@]} > k.txt

	while [ ${#k[@]} -lt 4 ]; do
		k[${#k[@]}]=0
	done
	n=$((${#v[@]}-1))
	z=${v[$n]}
	y=${v[0]}
	c=-1640531527
	m=0
	e=0
	p=0
	floor $((6+52/(n+1)))
	q=$?
	d=0
	for ((;q>0;q-=1)); do
		d=$(add $d $c)
		e=$((d>>2&3))
		for ((p=0;p<n;p+=1)); do
			y=${v[$((p+1))]}
			#echo "y= "$y
			t1=$(sr $z 5)
			t2=$(sl $y 2)
			m=$(xor $t1 $t2)
			#echo "m1= "$m
			t1=$(sr $y 3)
			t2=$(sl $z 4)
			t1=$(xor $t1 $t2)
			t2=$(xor $d $y)
			t=$(xor $t1 $t2)
			m=$((m+t))
			#echo "m2= "$m
			t1=$((p&3))
			idx=$(xor $t1 $e)
			elem=${k[$idx]}
			t2=$(xor $elem $z)
			m=$((m+t2))
			#echo "m3= "$m
			v[$p]=$(add ${v[$p]} $m)
			z=${v[$p]}
			#echo "z= "$z
		done
		y=${v[0]}
		#echo "y= "$y
		t1=$(sr $z 5)
		t2=$(sl $y 2)
		m=$(xor $t1 $t2)
		#echo "m1= "$m
		t1=$(sr $y 3)
		t2=$(sl $z 4)
		t1=$(xor $t1 $t2)
		t2=$(xor $d $y)
		t=$(xor $t1 $t2)
		m=$((m+t))
		#echo "m2= "$m
		t1=$((p&3))
		idx=$(xor $t1 $e)
		elem=${k[$idx]}
		t2=$(xor $elem $z)
		m=$((m+t2))
		#echo "m3= "$m
		v[$n]=$(add ${v[$n]} $m)
		z=${v[$n]}
		#echo "z= "$z
	done
	#echo ${v[@]}
	v=$( IFS=" "; echo "${v[*]}" )
	echo $v
}

# l_func(str, key): reimplement of l(), but not exactly the same.
function l_func()
{
	str=$1
	key=$2
	a=$(xEncode $str $key)
	#echo ${a[@]} > x.txt
	a=($a)
	d=${#a[@]}
	c=$(((d-1)<<2))
	for ((i=0;i<d;i+=1)); do
		code1=$((${a[$i]}&255))
		s1=$(ascii2str $code1)
		code2=$((${a[$i]}>>8&255))
		s2=$(ascii2str $code2)
		code3=$((${a[$i]}>>16&255))
		s3=$(ascii2str $code3)
		code4=$((${a[$i]}>>24&255))
		s4=$(ascii2str $code4)
		a[$i]=${s1}${s2}${s3}${s4}
	done
	result=$( IFS=""; echo "${a[*]}" )
	echo $result 
}

################
# Main Process #
################
option=$1
if [[ "$option" == "" ]]; then
	option="login"
fi

# Get cookies and ac_id
# Cookies will save as cookies.txt in the working directory.
RESULT=`curl -k -s -c cookies.txt \
-H 'Host: gw.buaa.edu.cn' \
-H 'Upgrade-Insecure-Requests: 1' \
-H 'User-Agent: $UA' \
-H 'Sec-Fetch-Mode: navigate' \
-H 'Sec-Fetch-User: ?1' \
-H 'DNT: 1' \
-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' \
-H 'Purpose: prefetch' \
-H 'Sec-Fetch-Site: none' \
-H 'Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6' \
-H 'Cookie: pgv_pvi=2381688832; AD_VALUE=8751256e; cookie=0; lang=zh-CN; user=$USERNAME' \
'https://gw.buaa.edu.cn/index_1.html?ad_check=1'`

#echo $RESULT
AC_ID=${RESULT#*ac_id=}
AC_ID=${AC_ID%&amp*}
echo "AC_ID: "$AC_ID

# Get challenge number
RESULT=`curl -k -s -b cookies.txt \
-H "Host: gw.buaa.edu.cn" \
-H "Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01" \
-H "DNT: 1" \
-H "X-Requested-With: XMLHttpRequest" \
-H "User-Agent: $UA" \
-H "Sec-Fetch-Mode: cors" \
-H "Sec-Fetch-Site: same-origin" \
-H "Referer: https://gw.buaa.edu.cn/srun_portal_pc?ac_id=$AC_ID&theme=buaa&url=www.buaa.edu.cn" \
-H "Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6" \
"https://gw.buaa.edu.cn/cgi-bin/get_challenge?callback=jQuery112407419864172676014_1566720734115&username="$USERNAME"&ip="$IPADDR"&_="$TIMESTAMP`

# A dirty way to obtain information in JSON string.
CHALLENGE=`echo $RESULT | cut -d '"' -f4`
CLIENTIP=`echo $RESULT | cut -d '"' -f8`
echo "Challenge: "$CHALLENGE
echo "Client IP: "$CLIENTIP

if [[ "$option" == "login" ]]; then
	# The password is hashed using HMAC-MD5.
	ENCRYPT_PWD=`echo -n $PASSWORD | openssl md5 -hmac $CHALLENGE`
	# Remove the possible "(stdin)= " prefix
	ENCRYPT_PWD=${ENCRYPT_PWD#*= }
	PWD=$ENCRYPT_PWD
	echo "Encrypted PWD: "$PWD

	# Some info is encrypted using srun_bx1 and base64 and substitution ciper
	INFO='{"username":"'$USERNAME'","password":"'$PASSWORD'","ip":"'$CLIENTIP'","acid":"'$AC_ID'","enc_ver":"srun_bx1"}'
	#echo "Info: "$INFO
	ENCRYPT_INFO=$(l_func $INFO $CHALLENGE)
	ENCRYPT_INFO=`echo -ne $ENCRYPT_INFO | openssl enc -base64 -A | tr "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" "LVoJPiCN2R8G90yg+hmFHuacZ1OWMnrsSTXkYpUq/3dlbfKwv6xztjI7DeBE45QA"`
	echo "Encrypted Info: "$ENCRYPT_INFO

	# Checksum is calculated using SHA1
	CHKSTR=${CHALLENGE}${USERNAME}${CHALLENGE}${ENCRYPT_PWD}${CHALLENGE}${AC_ID}${CHALLENGE}${CLIENTIP}${CHALLENGE}"200"${CHALLENGE}"1"${CHALLENGE}"{SRBX1}"${ENCRYPT_INFO}
	#echo "Check String: "$CHKSTR
	CHKSUM=`echo -n $CHKSTR | openssl dgst -sha1`
	# Remove the possible "(stdin)= " prefix
	CHKSUM=${CHKSUM#*= }
	echo "Checksum: "$CHKSUM

	# URLEncode the "+", "=", "/" in encrypted info.
	URL_INFO=$(echo -n $ENCRYPT_INFO | sed "s/\//%2F/g" | sed "s/=/%3D/g" | sed "s/+/%2B/g")
	#echo "URL Info: "$URL_INFO

	# Submit data and login
	curl -k -b cookies.txt \
	-H "Host: gw.buaa.edu.cn" \
	-H "Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01" \
	-H "DNT: 1" \
	-H "X-Requested-With: XMLHttpRequest" \
	-H "User-Agent: $UA" \
	-H "Sec-Fetch-Mode: cors" \
	-H "Sec-Fetch-Site: same-origin" \
	-H "Referer: https://gw.buaa.edu.cn/srun_portal_pc?ac_id=$AC_ID&theme=buaa&url=www.buaa.edu.cn" \
	-H "Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6" \
	"https://gw.buaa.edu.cn/cgi-bin/srun_portal?callback=jQuery112407419864172676014_1566720734115&action=login&username="$USERNAME"&password=%7BMD5%7D"$PWD"&ac_id=$AC_ID&ip="$CLIENTIP"&chksum="$CHKSUM"&info=%7BSRBX1%7D"$URL_INFO"&n=200&type=1&os="$SYSNAME"&name=Macintosh&double_stack=0&_="$TIMESTAMP

elif [[ "$option" == "logout" ]]; then
	curl -k -b cookies.txt \
	-H "Host: gw.buaa.edu.cn" \
	-H "Accept: text/javascript, application/javascript, application/ecmascript, application/x-ecmascript, */*; q=0.01" \
	-H "DNT: 1" \
	-H "X-Requested-With: XMLHttpRequest" \
	-H "User-Agent: $UA" \
	-H "Sec-Fetch-Mode: cors" \
	-H "Sec-Fetch-Site: same-origin" \
	-H "Referer: https://gw.buaa.edu.cn/srun_portal_pc?ac_id=$AC_ID&theme=buaa&url=www.buaa.edu.cn" \
	-H "Accept-Language: en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,zh-TW;q=0.6" \
	"https://gw.buaa.edu.cn/cgi-bin/srun_portal?callback=jQuery112407419864172676014_1566720734115&action=logout&username="$USERNAME"&ac_id=$AC_ID&ip="$CLIENTIP
fi
