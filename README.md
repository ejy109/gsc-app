# A Minimal Containerized & Graminized Attestable Application

This example takes advantage of GSC tool's ability
to wrap a common application container with Gramine-SGX.

It shows a way to attest a SGX wrapped application with project Amber.

## Quick Start

- Prerequisites

    1. A SGX2 enabled Linux box

        ```sh
        grep sgx /proc/cpuinfo && ls -l /dev/sgx*
        ```

    2. AESMD service up and running

        Please refer to the repo of Intel SGX SDK
        [Linux SGX](https://github.com/intel/linux-sgx) and
        [Installation Guide](https://download.01.org/intel-sgx/sgx-dcap/1.16/linux/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf) and make sure it functions correctly.

        ```sh
        # check status
        systemctl status aesmd
        journalctl -u aesmd
        ```

    3. Others

        ```sh
        # please properly config it after docker installation
        sudo apt install docker.io
        # make sure you can use the following command
        # under your account
        docker images

        sudo apt install pv

        # and Linux kernel v5.15 or greater
        uname -a
        ```

- Configuration

    For attestation token retrieval.
    In file `gramine.manifest`

    ```toml
    # must be a IP address of the host set in sgx.amber_url
    sgx.amber_ip = "<IP address>"
    sgx.amber_url = "https://localhost:443/appraisal/v1/"
    # the default apikey, and it should be securely overwritten by
    # a valid apikey through the `/dev/amber/endpoint_apikey` file
    sgx.amber_apikey = "<default API key>"
    ```

    Please note that these settings will be measured with the SGX application, so any changes to this configuration will require rebuilding it.

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

    Please note that all previously generated containers, including dangling containers, need to be removed before rebuilding.

- Check the attestation token as needed

    ```sh
    # install this tool for JWT decode
    sudo snap install jwt-decode

    # decode the header of attestation token
    jwt-decode.header "<paste attestation token here>"

    # decode the payload of attestation token
    jwt-decode.payload "<paste attestation token here>"
    ```
