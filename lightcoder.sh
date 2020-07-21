#!/bin/bash -i

# Automate the pentest and recon stuffs with this tool. 

echo -e "
+-+-+-+-+-+-+-+-+-+-+
|L|I|G|H|T|C|O|D|E|R|
+-+-+-+-+-+-+-+-+-+-+
AUTHOR: Arun Bhandari"
        
    echo -e "RECON TOOL FOR PENETRATION TESTING"
    echo "USAGE:./lightcoder.sh domain.com"

echo -e "\e[31m[STARTING]\e[0m"

#starting sublist3r
sublist3r -d $1 -v -o domains.txt

#running assetfinder
~/go/bin/assetfinder --subs-only $1 | tee -a domains.txt

#removing duplicate entries
sort -u domains.txt -o domains.txt

#checking for alive domains
echo "[+] Checking for alive domains.."
cat domains.txt | ~/go/bin/httprobe | tee -a final.txt

echo "Adding more features...."
echo "-----More Features coming soon------"

