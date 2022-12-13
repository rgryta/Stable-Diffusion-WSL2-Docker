# Stable-Diffusion-WSL2-Docker

## About

This repository is meant to allow for easy installation of Stable Diffusion on Windows. One click to install. Second click to run.
(It is recommended to click install script before heading to bed - depends on your internet connection.)

This setup is completely dependant on current versions of AUTOMATIC1111's webui repository and StabilityAI's Stable-Diffusion models.

In it's current configuration only Nvidia GPUs are supported. This script will also install Xformers library in order to speed up output generation.

## Prerequisites

Before following through with these instructions. Please verify below.

1. You have virtualization support - easiest way is to check if you can see "Virtualization" section in Windows Task Manager -> Performance -> CPU (it's located under "More details" if you don't see the Performance tab).
1. You have virtualization enabled - you have to enable it in your BIOS if you don't.
1. You have Windows 11 Pro - you can also use Windows 11 Home (and according to some Stack Overflow comments also Windows 10), but you will have to perform manual installation and adjust it to your needs - e.g. Home edition needs a workaround in order to install Hyper-V.
1. You have Nvidia GPU - this is mandatory for current configuration. Support for AMD is presumably possible, but won't be added until such request shows up. Make sure you also have the newest drivers! Whole repository is based on CUDA 11.

## How to use

After installation simply execute run.bat file to start the Stable-Diffusion app. You can open it under [http://localhost:7860](http://localhost:7860).

If you want to close the app - simply launch stop.bat, it will terminate the application and close the terminals.

Note! Keep in mind that stop.bat will terminate and remove all containers based on Stable-Diffusion webui image. If you have downloaded additional models while the application was running - e.g. GAN models - they will have to be redownloaded again.

## Installation

### Automatic

Run install.bat in order to install the Stable Diffusion - this process will restart your computer at the beginning, and will take a long time to download.

### Manual

1. Install Windows 11
1. Install WSL from MS Store (https://www.microsoft.com/store/productId/9P9TQF7MRM4R)
1. Search for "Turn Windows features on or off" and enable "Hyper-V"
1. Set WSL to use v2: wsl --set-default-version 2
1. Install Linux distro of your choice (Ubuntu given as example): wsl --install Ubuntu
	1. Set up your username and password
1. (In distro command line) sudo sh -c 'echo "[boot]\nsystemd=true" > /etc/wsl.conf'
1. Check your distro name using "wsl --list"
1. Shutdown all distros "wsl --shutdown" and restart the one we're using "wsl --distribution Ubuntu"
1. Make sure you have nvidia drivers installed on Windows
1. Now open WSL. From now on, everything is executed from there.
1. Execute following scripts:
	1. sudo apt-key del 7fa2af80
	1. wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
	1. sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
	1. sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/3bf863cc.pub
	1. sudo add-apt-repository 'deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /'
	1. sudo apt-get update
	1. sudo apt-get -y install cuda
1. Check if you're able to see your GPU in WSL: nvidia-smi
1. Install docker:
	curl https://get.docker.com | sh \
  	&& sudo systemctl --now enable docker
1. distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
1. sudo apt-get install -y nvidia-docker2
1. sudo systemctl restart docker
1. Check if docker container also sees your GPU: sudo docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi
1. Run ./build.sh from repo directory to build the container (you can remove depth, upscaler, inpainting and gfpgan from Dockerfile to minimize downloads and size)
1. Run ./run.sh to start container. Open http://localhost:7860 to access the webui - you can do so from Windows of course.

## Sources

1. [StabilityAI Stable-Diffusion GitHub](https://github.com/Stability-AI/stablediffusion)
1. [StabilityAI Stable-Diffusion HuggingFace](https://huggingface.co/stabilityai/stable-diffusion-2-1)
1. [AUTOMATIC1111 webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
1. [Nvidia Container Runtime](https://nvidia.github.io/nvidia-container-runtime/)
1. [Ubuntu GPU acceleration on WSL2](https://ubuntu.com/tutorials/enabling-gpu-acceleration-on-ubuntu-on-wsl2-with-the-nvidia-cuda-platform#3-install-nvidia-cuda-on-ubuntu)
1. [MS WSL systemd](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/)
1. [Nvidia WSL](https://docs.nvidia.com/cuda/wsl-user-guide/index.html)
