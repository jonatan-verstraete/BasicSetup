# 2023-01-16 CHANGES IN THIS FILE WILL BE OVERWRITTEN

: '
     Functions related to apps, opening
'

# new termianl tab
newtab() (
	open -n -a Terminal
)

# opens with vs code
code() (
	open -a "/Applications/Visual Studio Code.app" $1 $2 ;# ${1:=''}
)

# opens with pages
pages() (
	open -a "Pages"  $1
)

# opens with brave
brave() (
	open -a "Brave Browser" $1;
)
: '
	Functions that use external files
'

# opens this enclosing folder
opencustom() (
    code $p_custom
)


# gets specified file tags "$HOME/Documents/_personal/books/book_test.txt"
getFileTags() (
	if [[ -z $1 ]]; then
		echo "no file specified"
		return
	fi

	hasattr=$(xattr $1 | grep 'com.apple.metadata:_kMDItemUserTags')

	if [[ ! $hasattr ]]; then
		echo ""
	else
		hex=$(xattr -p com.apple.metadata:_kMDItemUserTags $1 2>&1 || echo "-")
		s=$(echo $hex | grep -Eo '[^A-Z]+?' | tail +2 | grep -oE '\w*' | awk '{print}' ORS=' ')
		echo "$s"
	fi
)


tags()(
	if [[ -z $1 ]]; then
		echo "tags: No 'type' argument pecified. requires 2 arguments"
		return
	elif [[ -z $2 ]]; then
		echo "tags: No 'file' argument pecified. requires 2 arguments"
		return
	fi

	if [ "$1" = "set" ]; then

		pls_head="<!DOCTYPE plist PUBLIC '-//Apple//DTD PLIST 1.0//EN' 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'><plist version='1.0'><array>"
		pls_foot="</array></plist>"

		for i in "${@:2}"
		do
			pls_head+="<string>$i</string>"
		done
		
		xattr -w com.apple.metadata:_kMDItemUserTags "$pls_head$pls_foot" $2



	# get file tags
	elif [ "$1" = "get" ]; then
		hasattr=$(xattr $2 | grep 'com.apple.metadata:_kMDItemUserTags')

		if [[ ! $hasattr ]]; then
			echo ""
		else
			hex=$(xattr -p com.apple.metadata:_kMDItemUserTags $2 2>&1 || echo "-")
			s=$(echo $hex | grep -Eo '[^A-Z]+?' | tail +2 | grep -oE '\w*' | awk '{print}' ORS=' ')
			echo "$s"
		fi
	fi
)



# cleares caches
clearcache() (
	#enter a path from a 'DIRECTORY'
	fileSize="###"
	isDir=true
	1=$(lowercase "$1")

	case $1 in
		"stremio" )
			spath="$HOME/Library/Application Support/stremio-server/stremio-cache";;
		"his"|"history"|'terminal' )
			spath="$HOME/.zsh_sessions";;
		"logs" )
			spath="/Library/Logs/*"
			isDir=false
			;;
		"valet" )

			read "response?Sure you want to stop valet (nginx)? [Y/n] "
			response=${response:l}

			if [[ $response =~ ^(yes|y|Y) ]]; then
				valet stop
				isDir=false
				spath='/usr/local/var/log/php-fpm.log'
			else
				return 
			fi;;
		* )
			echo "Error: No slot '$1' found"  
			return ;;
	esac

	if [[ "$2" == "path" ]]; then
		echo $spath
		return
	fi

	# verify path existance and calculate size
	if [ "$isDir" = true ]; then
		fileSize=$(du -hc "$spath/" | grep 'total' | cut -d$'\t' -f1)
	else
		fileSize=$(wc -c "$spath" | awk '{print $1}' )
	fi

	read "response?Remove $(bold $fileSize) of data? ? [Y/n] "
	response=${response:l}

	# confirm
	if [[ $response =~ ^(yes|y|Y) ]]; then
		if [ "$isDir" = true ]; then
			sudo rm -rf "$spath/"; mkdir "$spath" 
		else
			sudo echo "" > $spath
		fi
		echo 'done'
		# -r: ? +(auto -d)= ~=R?
		# -d: dirs and files
		# -f: force
	fi
)

: '
	* helpers/functions 
	-* extension of bultin functionalities

'

# copies to clipboard
copy()(
	$1 | pbcopy
)

# gives network info
netw()(
	[[ "$1" == "-4" ]] && ip4=1 || ip4=0
	ip=`ipconfig getifaddr en0`
	subnet=`ipconfig getoption en0 subnet_mask`
	dns=`ipconfig getoption en0 domain_name_server`

	#info: https://gree2.github.io/mac/2015/07/18/mac-network-commands-cheat-sheet

	case "$1" in
		info)
			echo "more info: https://gree2.github.io/mac/2015/07/18/mac-network-commands-cheat-sheet"
			;;
		ip)
			case "$2" in
				get)
					echo $ip
					;;
				set)
					read "enter new ip xxx.xxx.xxx.xxx:" newip
					read "are you sre to set ip to: $newip ? y/n" res
					if [[ "$res" == 'y' ]]; then
						ipconfig set en0 INFORM $newip
					fi
					;;
				*)
					echo "usage - ip: get, set"
					;;
			esac
			;;
		man)
			cat $p_custom/mans/ip.txt | less
			;;
		*)
			echo "usage: [info,ip[get,set],man]"
			;;
	esac
)

# gets time
now() (
	if [ "$1" = "-h" ]; then
		date +"%T"
	elif [ "$1" = "-d" ]; then
		date '+%Y-%m-%d'
	else
		date '+%Y-%m-%d %H:%M:%S'
	fi;
)

# kodo aka Kodokushi (孤独死) or lonely death refers to a Japanese phenomenon of people dying alone and remaining undiscovered for a long period of time.
kodo() (
	if [[ $1 ]]; then
		newtab
		clear
	fi
	kill -9 $$
)

# closes current terminal
close() (
	#v=$(echo $RANDOM | md5sum | head -c 20; echo;)
	v="green-mile"

	echo -n -e "\033]0;$v\007"
	osascript -e 'tell application "Terminal" to close (every window whose name contains "'$v'")' &

	#killall "${$1:-'Terminal'}"
	# osascript -e "quit app 'Terminal'"
)

# does nothing
dummy()(
	return
)

# trap ctrl-c and then cleanup
# use in combo with: 
#$: trap cleanup INT
# more inf: https://www.linuxjournal.com/content/bash-trap-command
cleanup () {
	clear
	echo "i am only an annomally"
	kodo
}


# extended cd with ls overview 
-cd() (
	local lines=$(ls \-1$1$2)
	IFS=$'\n' read -d '' -rA arr <<< $lines

	for ((i = 1; i < $#arr; i++)); do
		echo "${i}: ${arr[i]} ${@:2}"
	done
	read "idx?Enter index:"

	re='^[0-9]+$'
	if ! [[ $idx =~ $re ]] ; then
		echo "error: only number allowed"
		return
	fi
	cd "${arr[idx]}"
	return
)


# removes history
rmhis () (
	#"${1:='-1'}"
	# Prevent the specified history line from being saved.
	local HISTORY_IGNORE="${(b)$(fc -ln $1 $1)}"
	# Write out the history to file, excluding lines that match `$HISTORY_IGNORE`.
	fc -W
	# Dispose of the current history and read the new history from file.
	fc -p $HISTFILE $HISTSIZE $SAVEHIST
)


# encrypts, decrypts
crypt() (
	err() 
	(
		echo "Usage: crypt -e|-d key string"
		echo "'crypt' 'type' 'key' 'value'"
		return
	)
	if [[ -z $1 || -z $2 || -z $3 ]]; then
		echo 'crypt: requires 3 parameters'
		err
	elif [[ "${1}" =~ ^(set|encrypte|-e)$ ]]; then
		echo $3 | openssl enc -base64 -e -aes-256-cbc -nosalt -pass pass:$2

	elif [[ "${1}" =~ ^(get|decrypt|-d)$ ]]; then
		echo $3 | openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:$2
	else
		echo "crypt: incorrect parameter: $1"
		err
	fi
)




# displayes all possible custom functions
allfunc() (
	n=$(grep -E '^\w*\(\)\s\(' "$pth_compiled" | cut -d"(" -f1)
	IFS=$'\n' read -d '' -rA arr <<< $n

	for ((i = 1; i < $#arr; i++)); do
		echo "$i: ${arr[i]}"
	done

	if [[ $2 ]]; then
		read "idx?Enter index:"
		eval "${arr[idx]}"
	fi

	# 	n=$(grep -E '^[[:space:]]*([[:alnum:]_]+[[:space:]]*\(\)|function[[:space:]]+[[:alnum:]_]+)' "$p_custom/functions.sh" | cut -d" " -f2)
	# if [[ $1 ]]; then
	# 	for ((i = 1; i < $#arr; i++)); do
	# 		if [[ $i = $1 ]]; then
	# 			eval "${arr[i]} ${@:2}"
	# 			return
	# 		fi
	# 	done
	# 	echo "Nothing found with index '$1'"
	# else
	# 	for ((i = 1; i < $#arr; i++)); do
	# 		echo "$i: ${arr[i]}"
	# 	done
	# fi
)



# runs a secret command 
runsecret() (
	if [[ -z $1 ]]; then
		echo 'Error: requires slot parameters'
		return 
	fi

	case $1 in
		1 )
			echo "no slot $1" ;;
		2 )
			trap cleanup INT

			echo -n additional parameter: 
			read -s param
			s=$(crypt get $param LTbu8amJn9qcpBBWLCzDHXstXnKsZpdxfH9DTEKd3sU=)
			eval $s;;
		* )
			echo "no slot found:  '$1'"  ;;
	esac
)





# disables 'unwanted' services
# dus() (
# 	read "red?Sure you want to stop basic MacOs services? \n This might make some programs unable to run [Y/n]"

# 	if [[ $res =~ ^(yes|y|Y) ]]; then
# 		bash /Users/home/.custom/advanced/disable_macos_process.sh
# 	fi
# )


# eg, gives examples of functions
eg()(
	case $1 in 
		"style" )
			echo "bold\t\t $(bold herring_999)"
			echo "italic\t\t $(italic herring_999)"
			echo "underline\t $(underline herring_999)"
			echo "blinking\t $(blinking herring_999)"
			echo "strikethrough\t $(strikethrough herring_999)"
			echo "gray\t\t $(gray herring_999)"
			echo "cyan\t\t $(cyan herring_999)"
			echo "purlpe\t\t $(purlpe herring_999)"
			echo "blue\t\t $(blue herring_999)"
			echo "yellow\t\t $(yellow herring_999)"
			echo "green\t\t $(green herring_999)"
			echo "red\t\t $(red herring_999)"
			echo "dark\t\t $(dark herring_999)"
		;;
	* )
		echo "Err: no example found";;
	esac
)


# info/remove ssh synced devides
: '
    Styling
'
ansi()          { echo -e "\e[${1}m${@:2}\e[0m"; }


bold()          { ansi 1 "$@"; }
italic()        { ansi 3 "$@"; }
underline()     { ansi 4 "$@"; }
blinking()      { ansi 5 "$@"; }
strikethrough() { ansi 9 "$@"; }

gray()    { ansi '1;37' "$@";}
cyan()     { ansi '1;36' "$@";}
purlpe()   { ansi '1;35' "$@";}
blue()     { ansi '1;34' "$@";}
yellow()   { ansi '1;33' "$@";}
green()    { ansi '1;32' "$@";}
red()      { ansi '1;31' "$@";}
dark()     { ansi '1;30' "$@";}


lowercase(){ 
    echo "$1" | tr '[:upper:]' '[:lower:]'
}


uppercase(){ 
    echo "$1" | tr '[:lower:]' '[:upper:]' 
}# vars
# ref pulp fiction
zed=".zprofile"


alias python=python3
alias pip=pip3
alias l='ls'
alias ll='ls -l'
alias la='ls -a'
alias l1='ls -1'
alias c='clear'

alias t1='tree -L 1'
alias t2='tree -L 2'
alias t3='tree -L 3'
# usage of file size (only 2levels as it might do insane search otherwise)
alias t2m='tree --du -h -L 2 | grep M]'
#alias tsg='tree --du -h | grep G]'


alias editcustom='opencustom'
