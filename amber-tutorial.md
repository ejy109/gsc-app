# Intel&reg; Amber Attestation Sample Guide


## Introduction

This tutorial describes how to build and run Intel Amber Attestation sample code in Azure confidential VM that supports Intel SGX hardware.

## Prerequisites
To run this sample code, you need the following prerequisites.
- Azure subscription (for Confidential VM with SGX support)
- Amber service subscription
- Linux kernel: 5.11 and newer
<!--- Intel&reg; SGX SDK and SGX Platform Software (PSW) 
- Intel&reg; Data Center Attestation Primitives (DCAP)
-->

<!-- ## 2 Confidential VM on Azure Cloud

Steps to create Azure Confidential VM and to enable SGX on Azure CVM.
-->

## 1 Creating a Confidential VM on Azure Cloud

1. Go to Azure portal (https://portal.azure.com).
2. Select ’Virtual Machines’ from Azure Services.
3. Create ’Azure virtual machine’ with Ubuntu Server 20.04 LTS Image.
4. Select 'Resource group' and VM name and Region and image (e.g., Ubuntu Server 20.04i LTS - x64 Gen2).
5. Click 'See all sizes" under Size.
6. Select a VM size you want (vcpu, memory). 
7. Go!

![](azure-vm.png)

## 2 Configure and get a SGX API key from the Amber Service Portal

1. Go to the Amber Service Portal (https://projectamber.intel.com/)
2. Select "Managed services" menu.
3. Click "ADD API KEY" under "SGX API Keys" tab.
4. Enter your API key name and expiration date.
5. Click "SAVE AND CONTINUE" and "SUBMIT"
6. Check if API key is successfully created. 

## 3 Enabling SGX in Azure Confidential VM
Enabling SGX in Azure CVM can be done either running the script (enable-sgx.sh) or by following the steps. 

To automatically enable SGX, run the script:
```console
./enable-sgx.sh
```
To enable SGX step-by-step:
1. Install SGX SDX and Extensions
- The SGX SDK and extensions need to be installed to configure the system to run and the sample SGX application.
  
 ```console
 # check if SGX is enabled in BIOS
 ls /dev/sgx 

 # add the repository
 echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | sudo tee /etc/apt/sources.list.d/intel-sgx.list

# get the repo public key and add it to the list of trusted keys
 wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgxdeb.key | sudo apt-key add

 # update apt and install packages
 sudo apt-get update

 sudo apt-get install libsgx-epid libsgx-quote-ex libsgx-dcap-ql

 wget https://packages.microsoft.com/ubuntu/20.04/prod/pool/main/a/az-dcap-client/az-dcap-client_1.11.2_amd64.deb

 sudo dpkg -i az-dcap-client_1.11.2_amd64.deb

 sudo apt install make gcc g++ pkg-config binutils

 # download the latest Intel SGX driver
 wget https://download.01.org/intel-sgx/latest/dcap-latest/linux/distro/ubuntu20.04-server/sgx_linux_x64_sdk_2.19.100.3.bin

 chmod u+x sgx_linux_x64_sdk_2.19.100.3.bin

 ./sgx_linux_x64_sdk_2.19.100.3.bin source sgxsdk/environment
 ```

2. Start the AESM Service
 ```console
 # start the AESM service
 /opt/intel/sgx-aesm-service

 # check AESM status
 systemctl status aesmd
```
   
## 4 Enabling Gramine in Azure Confidential VM
For the details of Gramine, go to https://github.com/gramineproject/gramine

Enabling Gramine in Azure CVM can be done either running the script (enable-gramine.sh) or by following the steps. 

To automatically enable Gramine, run the script:
```console
./enable-gramine.sh
```

To enable Gramine step-by-step:

1. Install Gramine  (Ubuntu)

```console
sudo curl -fsSLo /usr/share/keyrings/gramine-keyring.gpg https://packages.gramineproject.io/gramine-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gramine-keyring.gpg] https://packages.gramineproject.io/ $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/gramine.list

sudo curl -fsSLo /usr/share/keyrings/intel-sgx-deb.asc
https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.keyA

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-sgx-deb.asc] https://download.01.org/intel-sgx/sgx_repo/ubuntu $(lsb_release -sc) main" \
| sudo tee /etc/apt/sources.list.d/intel-sgx.list

sudo apt-get update
sudo apt-get install gramine
```

2. Prepare a signing key
   
   Only for SGX. If you already have a signing key, skip this step.

```console
gramine-sgx-gen-private-key
```
*This command generates an RSA 3072 key suitable for signing SGX enclaves and stores it in $HOME/.config/gramine/enclave-key.pem. This key need to be protected and should not be disclosed to anyone.*
   
3. Install Docker

   For running the containerized sample application 

```console
pip install docker
or
sudo apt install docker.io
```
   
4. Install toml
   
```console
pip install toml
```

## 5 Running a Graminine Sample Application in Azure CVM

To run a sample Gramine application, you can run the script (test-gramine.sh)

```console
./test-gramine.sh
```
or follow the step-by-step instructions. 

1. Clone the Gramine repository.

```console
git clone --depth 1 --branch v1.4 https://github.com/gramineproject/gramine.git
``` 
2. Build and run Hello World example.
```console
# if gcc and make is not installed
sudo apt-get install gcc make

cd gramine/CI-Examples/helloworld

# build and run without SGX
make
gramine-direct helloworld

# build and run with SGX
make SGX=1
gramine-sgx helloworld
```

## 6 Running a Sample Application in Docker using Gramine Shielded Containers (GSC)
Prerequisite: Please ensure the correct Docker proxy settings if Docker runs/builds behind the intranet proxy.

1. Download the GSC sample application (https://github.com/bigdata-memory/gsc-app).
```console
sudo apt install git
git clone https://github.com/bigdata-memory/gsc-app
```

2. Edit manifest to point to Amber attestation service


```console
cd /gsc-app
# edit gramine.manifest file 
# Use the Amber SGX API key that was created on Amber Service portal.

sgx.amber_url = "https://api-pre21-green.ambernp.adsdcsp.com/appraisal/v1/"
sgx.amber_ip = "54.174.158.81"
sgx.amber_apikey = "AHxWJ9PERLlEB5S0svkP4n3tUFpa6651HXAUzVsd"
```

3. Run a workflow of attestation token retrieval.
```console
cd /gsc-app
make clean
make

# testing the plain app (optional)
make test-app
```

Note: The docker image needs to be rebuilt if the gramine.manifest file has been updated with new configurations. All previously generated docker containers, including dangling containers, need to be manually removed before rebuilding.

4. Test the containerized and graminized application.
```console
# Make the first time, starting the container and runnings the application and code. This will generate an Amber Token.

make test-gsc-app

# Run the application in docker
docker run --rm --device=/dev/sgx_enclave --device=/dev/sgx/enclave -v
/var/run/aesmd/aesm.socket:/var/run/aesmd/aesm.socket gsc-app:0.3
```

## 7 Verify if Amber Attestation Token is valid
You can check it on the web (https://jwt.io/) or on terminal as follows (only debugging purpose).

```console
jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "<token_here>"
```
