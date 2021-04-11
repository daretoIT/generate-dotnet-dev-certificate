# Generate Developer Certificate for ASP.Net Core on Ubuntu

## Problem
To develop ASP.Net Core Web Apps on Ubuntu you need to generate self-signed developer certificates.
This works fine under Windows and Mac OS X with 'dotnet dev-certs https --trust', but not under Linux operating systems
like Ubuntu 18.04 or 20.04. You will get SSL Connection errors if two Wep Apps need to communicate with each other.

## Solution
You need to generate self-signed certificates with OpenSSL and manually configure Kestrel to use them.
To simplify the process of generating these certificates for developers this script was created.

Tested with Ubuntu 20.04 and dotnet core 5.0
Automatically adding exceptions to your browser is not covered.

## What will it do?
1. Create a self-signed certificate
2. Add the certificate to the Ubuntu trust store
3. Copy the generated certificate to your user's home directory under '$HOME/.dotnet/custom_dev_certificate/localhost.pfx'
4. Create an terminal alias to simplify the creation of a symbolic link to the certificate.

## How To
Clone or download this git repository and make 'setup_dev_certs.sh' executable.
```shell
chmod +x ./setup_dev_certs.sh
```
Execute the script
```shell
./setup_dev_certs.sh
```
You will need to hit 'ENTER' three times.
```text
...
Common Name (e.g. server FQDN or YOUR name) [localhost]:
...
Enter Export Password:
Verifying - Enter Export Password:
```

You will also be asked to enter your sudo password, as adding the certificate to the Ubuntu trust store requires
elevated privileges.

Go to your ASP.Net Core Application and modify the appsettings.< environment >.json file and add following part:
```json
{
  ...
    "Kestrel": {
      "Certificates": {
        "Default": {
          "Path": "localhost.pfx",
          "Password": ""
        }
      }
    },
  ...
}
```

The script also has added an alias to your '$HOME/.bashrc' file which allows you to create a symlink to the centrally stored
localhost.pfx file. ('$HOME/.dotnet/custom_dev_certificate/localhost.pfx')

To create a symbolic link to the localhost.pfx certificate just type 'dcc' (dotnet custom certificate) in a terminal
within the C# project directory where your appsettings.< environment >.json is located.
Benefit of the symbolic link is, that it won't be added to git and therefore each developer can use his own generated
local developer certificate without collision, and the need to constantly trust the certificate again.

## References
[Stack Overflow: How to run 'dotnet dev-certs https --trust'](https://stackoverflow.com/questions/55485511/how-to-run-dotnet-dev-certs-https-trust)

[Github Issue: dev-certificates on Linux -- how to get dotnet-to-dotnet comms to work? #7246](https://github.com/dotnet/aspnetcore/issues/7246)