# A Minimal Containerized & Graminized Application

This example takes advantage of GSC tool's ability
to wrap a common application container with Gramine-SGX.

# Quick Start

- Prerequisites
1) A SGX2 enabled Linux box
```sh
grep sgx /proc/cpuinfo && ls -l /dev/sgx*
```

2) AESMD service up and running
```
Please refer to the repo of Intel SGX SDK
[Linux SGX](https://github.com/intel/linux-sgx)
```

3) Others
```sh
# please properly config it after docker installation
sudo apt install docker.io
sudo apt install pv
```

- Configuration

For attestation token retrieval.
In file gramine.manifest
```toml
# must be a IP address of the host set in sgx.amber_url
sgx.amber_ip = "<IP address>"
sgx.amber_url = "https://localhost:443/appraisal/v1/"
# the default apikey, and it should be securely overwritten by
# a valid apikey through the `/dev/amber/endpoint_apikey` file
sgx.amber_apikey = ""
```

- Run a workflow of attestation token retrieval; build with SGX enabled:

```sh
make clean
make

# test the plain app
make test-app

# test the containerized & graminized app
make test-gsc-app

# deploy it to Azure VM
make AZURESSHPRVKEYFILE=<ssh private key file> AZURESSHIP=<ssh ip> deploy
```

- Check the attestation token as needed

```sh
# install this tool for JWT decode
sudo snap install jwt-decode

# decode the header of attestation token
jwt-decode.header "<paste attestation token here>"

# decode the payload of attestation token
jwt-decode.payload "<paste attestation token here>"
```
