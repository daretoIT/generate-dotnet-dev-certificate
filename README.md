# Generate Developer Certificate for ASP.Net Core on Ubuntu

## Problem
To develop ASP.Net Core Web Apps on Ubuntu you need to generate self-signed developer certificates.
This works fine under Windows and Mac OSX with 'dotnet dev-certs https --trust', but not under Linux operating systems
like Ubuntu 18.04 or 20.04. You will get SSL Connection errors if two Wep Apps need to communicate with each other or
you want to access it via browser.

## Solution
You need to generate self-signed certificates with OpenSSL to successfully use them. To be fully compatible with Firefox
and Chrome, you need to setup a local trust chain.
To simplify the process of generating these certificates for developers this script was created.

Tested with Ubuntu 20.04 and dotnet core 5.0

## What will it do?
1. Create a self-signed Root CA certificate.
2. Add the certificate to the Developer Root CA Ubuntu trust store.
3. Add the certificate to the browser's trust store (certutil).
4. Create a self-signed server certificate to use in dotnet development.
5. Add the generated certificate to aspnet environment 'dotnet dev-certs https --trust' to use it **without** any custom
   configuration of Kestrel in e.g. appsettings.json

## How To
Clone or download this git repository and make 'setup_dev_certs.sh' executable.
```shell
chmod +x ./setup_dev_certs.sh
```
Execute the script
```shell
./setup_dev_certs.sh
```

You will also be asked to enter your sudo password, as adding the certificate to the Ubuntu trust store requires
elevated privileges.

## Dependencies
- libnss3-tools (script will ask you to install if not found on your system)
- dotnet SDK (you should already have this)

## References
[Stack Overflow: How to run 'dotnet dev-certs https --trust'](https://stackoverflow.com/questions/55485511/how-to-run-dotnet-dev-certs-https-trust)

[Github Issue: dev-certificates on Linux -- how to get dotnet-to-dotnet comms to work? #7246](https://github.com/dotnet/aspnetcore/issues/7246)

[Github: BorisWilhelms/create-dotnet-devcert](https://github.com/BorisWilhelms/create-dotnet-devcert)