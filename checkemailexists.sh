#!/bin/bash
# author : Oros
# 2016-05-30
#
# Check if an email address exists
# ./checkemailexists.sh <mail_to_check>

if [ ! `which expect` ]; then
	echo -e "\033[31mNeed expect!\033[0m\nsudo apt install expect"
fi
if [ ! `which nslookup` ]; then
	echo -e "\033[31mNeed nslookup!\033[0m\nsudo apt install nslookup"
fi

if [ $# -ne 1 ]; then
	echo "$0 <mail_to_check>"
	exit
fi
themail="$1"
domain=${themail##*@}
mailHost=`nslookup -type=mx $domain |grep exchanger | head -n 1`
mailHost=${mailHost##* }
mailHost=${mailHost::-1}
if [ "$mailHost" == "" ]; then
	echo "Error: Empty mailHost"
	exit
fi

a=$(
/usr/bin/expect -c '
proc connect {} {
	expect {
		"220" {
			#send_user "Send HELO\n"
			send "HELO '$domain'\r"
			sleep 0.5
			expect {
				"250" {
					send "mail from:<mr.nobody.404@gmail.com>\r"
					sleep 0.5
					expect {
						"250" {
							send "rcpt to:<'$themail'>\r"
							sleep 0.5
							expect {
								"250" {
									send_user "'$themail' Ok\n"
									sleep 0.5
									send "quit\r"
									return 1
								}
								"Protocol error" {
									send "quit\r"
									return 3
								}
								"550" {
									#send_user "'$themail' mailbox unavailable\n"
									send "quit\r"
									return 2
								}
								"501" {
									#send_user "'$themail' Invalid Address\n"
									send "quit\r"
									return 2
								}
								incorrect {
									#send_user "'$themail' NO\n"
									send "quit\r"
									return 2
								}
							}
						}
						"501" {
							#send_user "Oups Invalid Address for sender\n"
							send "quit\r"
							return 4
						}
					}
				}
			}
		}
	}
	return 4
}
spawn telnet '$mailHost' 25
sleep 0.5
set rez [connect]
#sleep 0.5
exit $rez
'
)
ex=$?
case $ex in
	1)
		echo "Ok" 
		exit 0;;
	2) 
		echo "mailbox unavailable"
		exit 1;;
	3)
		echo "Protocol error. Try it again"
		exit 2;;
	*)
		echo "Error 0_o ($ex)"
		exit 3;;
esac
