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

echo -e "\n\n#### Copying Developer Root CA certificate to Arch Linx Trust Store ####"
sudo rm -rf /etc/ca-certificates/trust-source/anchors/ca.crt
sudo cp ./output/ca.crt /etc/ca-certificates/trust-source/anchors/ca.crt
sudo trust extract-compat

echo -e "\n\n#### Verify that server certificate is trusted by system ####"
openssl verify ./output/localhost.crt

echo -e "\n\n#### Trusting self-signed server certificate in dotnet ####"
rm -rf "$HOME"/.dotnet/corefx/cryptography/x509stores/my/*
dotnet dev-certs https --clean --import ./output/localhost.pfx -p ""
