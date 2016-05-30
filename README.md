# checkemailexists
Check if an email address exists

Install
-------
```
sudo apt install expect dnsutils telnet
wget https://raw.githubusercontent.com/Oros42/checkemailexists/master/checkemailexists.sh -O checkemailexists.sh
chmod u+x checkemailexists.sh
```

Run
---

```
./checkemailexists.sh <mail_to_check>
```

Examples
--------

```
$ ./checkemailexists.sh oros@ecirtam.net
Ok
$ ./checkemailexists.sh 404@test.com
mailbox unavailable
```