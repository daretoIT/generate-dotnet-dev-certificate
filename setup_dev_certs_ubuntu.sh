#!/bin/bash

rm -rf ./output
mkdir -p ./output

echo -e "\n\n#### Generating self-signed certificate authority ####"
openssl genrsa -out ./output/ca.key 4096
openssl req -x509 -new -nodes -key ./output/ca.key -sha256 -days 730 -out ./output/ca.crt -config ca.conf

echo -e "\n\n#### Generating server certificate and signing it ####"
openssl genrsa -out ./output/localhost.key 4096
openssl req -new -key ./output/localhost.key -out ./output/localhost.csr -config localhost.conf
openssl req -text -noout -verify -in ./output/localhost.csr
openssl x509 -req -in ./output/localhost.csr -CA ./output/ca.crt -CAkey ./output/ca.key -CAcreateserial -out ./output/localhost.crt -days 730 -sha256 -extfile localhost.conf -extensions v3_req

echo -e "\n\n#### Verify certificate ####"
openssl verify -CAfile ./output/ca.crt ./output/localhost.crt

echo -e "\n\n#### Convert certificate to pfx ####"
openssl pkcs12 -export -out ./output/localhost.pfx -inkey ./output/localhost.key -in ./output/localhost.crt --passout pass:

echo -e "\n\n#### Copying Developer Root CA certificate to Ubuntu Trust Store ####"
sudo rm -rf /usr/local/share/ca-certificates/aspnet
sudo mkdir -p /usr/local/share/ca-certificates/aspnet
sudo cp ./output/ca.crt /usr/local/share/ca-certificates/aspnet/ca.crt
sudo update-ca-certificates

echo -e "\n\n#### Verify that server certificate is trusted by system ####"
openssl verify ./output/localhost.crt

echo -e "\n\n#### Trusting self-signed server certificate in dotnet ####"
rm -rf "$HOME"/.dotnet/corefx/cryptography/x509stores/my/*
dotnet dev-certs https --clean --import ./output/localhost.pfx -p ""

echo -e "\n\n#### Trusting self-signed Developer Root CA certificate in browsers ####"
sudo apt install libnss3-tools

cert_file='./output/ca.crt'
cert_name="Developer self-signed Root CA"

while IFS= read -r -d '' certDB
do
  echo "Working on: $certDB"
  cert_directory=$(dirname "$certDB");
  certutil -d sql:"$cert_directory" -D -n "$cert_name"
  certutil -A -n "$cert_name" -t "TCu,," -i "$cert_file" -d sql:"$cert_directory"
done <   <(find "$HOME" -mtime -7 -name 'cert9.db' -print0)

# DEPRECATED: No need for appsettings stuff if dev cert has 1.3.6.1.4.1.311.84.1.1 which will be recognized during import

#echo -e "\n\n#### Copy pfx certificate to user's home directory to be able to reuse it in every project. ####"
#mkdir -p ~/.dotnet/custom_dev_certificate
#cp ./output/localhost.pfx ~/.dotnet/custom_dev_certificate/localhost.pfx
#echo "File location: ~/.dotnet/custom_dev_certificate/localhost.pfx"
#
#
#echo -e "\n\n#### Copy following configuration to your appsettings.<environment>.json ####\n"
#IFS='' read -r -d '' CONFIG <<"EOF"
#"Kestrel": {
#  "Certificates": {
#    "Default": {
#      "Path": "localhost.pfx",
#      "Password": ""
#    }
#  }
#}
#EOF
#echo "$CONFIG"
#
#echo -e "\n\n#### Execute following command in the C# project directory to create a symbolic link: ###"
#echo "ln -s $HOME/.dotnet/custom_dev_certificate/localhost.pfx localhost.pfx"
#
#echo -e "\n\n#### Creating terminal alias to create above symlink. Just type 'dcc' (dotnet custom certificate) in a terminal within your C# project folder. ###"
#echo "Maybe you need to 'source ~/.bashrc' again if you're in the same terminal session."
#LINE=$'alias dcc=\'ln -s $HOME/.dotnet/custom_dev_certificate/localhost.pfx localhost.pfx; echo "Symlink to dotnet custom certificate created!"\''
#grep -qF -- "$LINE" "$HOME/.bashrc" || echo "$LINE" >> "$HOME/.bashrc"