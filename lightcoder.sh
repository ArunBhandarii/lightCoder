#!/bin/bash

# Automate 

#starting sublist3r
sublist3r -d $1 -v -o domains.txt

#running assetfinder
~/go/bin/assetfinder --subs-only $1 | tee -a domains.txt

#removing duplicate entries
sort -u domains.txt -o domains.txt

#checking for alive domains
echo "[+] Checking for alive domains.."
cat domains.txt | ~/go/bin/httprobe | tee -a final.txt

echo "Converting to ip addresses"
echo "-------------------------"


