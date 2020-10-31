#!/bin/bash -i

# Automate the pentest and recon stuffs with this tool. 

echo -e "                                                      
 _     ___ ____ _   _ _____    ____ ___  ____  _____ ____  
| |   |_ _/ ___| | | |_   _|  / ___/ _ \|  _ \| ____|  _ \ 
| |    | | |  _| |_| | | |   | |  | | | | | | |  _| | |_) |
| |___ | | |_| |  _  | | |   | |__| |_| | |_| | |___|  _ < 
|_____|___\____|_| |_| |_|    \____\___/|____/|_____|_| \_\
                                                           
AUTHOR: Arun Bhandari"
        
echo -e "RECON TOOL FOR PENETRATION TESTING"
echo "USAGE:./lightcoder.sh domain.com"

echo -e "\e[31m[STARTING]\e[0m"

#starting sublist3r
sublist3r -d $1 -v -o domains.txt

#running assetfinder
assetfinder --subs-only $1 | tee -a domains.txt

#removing duplicate entries
sort -u domains.txt -o domains.txt

#checking for alive domains
echo -e "\e[31m[+] Checking for alive domains...\e[0m"
cat domains.txt | httprobe | tee -a final.txt

#Converting the alive domains into ip addresses. 
echo -e "\e[31m[+] Converting to ip addresses\e[0m"

for i in $(cat final.txt);
do
        a=`echo $i | cut -d '/' -f3`
        b=`host $a | grep -i 'has address' | awk '{print $4}'`
        echo $b >> ip_temp.txt
        echo $b
done
echo "[+]removing duplicates"
sort -u ip_temp.txt -o ips.txt
uniq -d ips.txt

# testing Put upload method.

echo -e "\e[31m[+] Testing for PUT upload method against all the alive hosts...\e[0m"

for domain in $(cat final.txt)
do
 curl -s -o /dev/null -w "URL: %{url_effective} - Response: %{response_code}\n" -X PUT -d "hello world"  "${domain}/evil.txt"
done > put.txt

# CORS
for i in $(cat final.txt);
do
assetfinder $1| httpx -threads 300 -follow-redirects -silent | rush -j200 'curl -m5 -s -I -H "Origin:evil.com" {} |  [[ $(grep -c "evil.com") -gt 0 ]] && printf "\n\033[0;32m[VUL TO CORS] - {}\e[m"' 2>/dev/null
done > cors.txt

#Data Collection
echo "\e[31m[+] Storing subdomain headers and response bodies...\e[0m"

mkdir headers
mkdir responsebody

CURRENT_PATH=$(pwd) 

for x in $(cat final.txt)
do
        NAME=$(echo $x | awk -F/ '{print $3}')
        curl -X GET -H "X-Forwarded-For: evil.com" $x -I > "$CURRENT_PATH/headers/$NAME"
        curl -s -X GET -H "X-Forwarded-For: evil.com" -L $x > "$CURRENT_PATH/responsebody/$NAME"
done


echo "\e[31m[+] Collecting JavaScript files and Hidden Endpoints..\e[0m"

mkdir scripts
mkdir scriptsresponse

RED='\033[0;31m'
NC='\033[0m'
CUR_PATH=$(pwd)

for x in $(ls "$CUR_PATH/responsebody")
do
        printf "\n\n${RED}$x${NC}\n\n"
        END_POINTS=$(cat "$CUR_PATH/responsebody/$x" | grep -Eoi "src=\"[^>]+></script>" | cut -d '"' -f 2)
        for end_point in $END_POINTS
        do
                len=$(echo $end_point | grep "http" | wc -c)
                mkdir "scriptsresponse/$x/"
                URL=$end_point
                if [ $len == 0 ]
                then
                        URL="https://$x$end_point"
                fi
                file=$(basename $end_point)
                curl -X GET $URL -L > "scriptsresponse/$x/$file"
                echo $URL >> "scripts/$x"
        done
done

echo "\e[31m[+] Looping through the scriptsresponse directory\e[0m"

mkdir endpoints

CUR_DIR=$(pwd)

for domain in $(ls scriptsresponse)
do
 
#looping through files in each domain
       
mkdir endpoints/$domain
for file in $(ls scriptsresponse/$domain)
do
        ruby ~/relative-url-extractor/extract.rb scriptsresponse/$domain/$file >> endpoints/$domain/$file 
        done
done

echo "\e[31m[+] Screenshotting the alive sudomains\e[0m"

cat final.txt | aquatone -out ~/$1/screenshots/

echo "\e[31m[+] Screenshotting the alive sudomains using eyewitness\e[0m"
eyewitness --web -f final.txt -d $1 

# Nmap scans

echo "\e[31m[+] Nmap scans..\e[0m"

mkdir nmapscans

for x in $(cat final.txt);
do
        nmap -sC -sV $x -oN $x -v | tee nmapscans/$x
done



# echo "Adding more features...."
# echo "-----More Features coming soon------"

