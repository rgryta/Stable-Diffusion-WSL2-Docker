FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as sd_webui

ENV SD_HOME=/home/sd
ENV SD_PROJECT=$SD_HOME/stable-diffusion-webui

# Install necessary packages
RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && echo $CONTAINER_TIMEZONE > /etc/timezone
RUN apt-get install --no-install-recommends --no-install-suggests -y \
		sudo git g++ python3.11 python3.11-distutils python3.11-venv python3.11-dev ffmpeg libsm6 libxext6 curl wget vim bc
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Create Stable Diffusion user
RUN useradd -m -G sudo -p $(openssl passwd -1 St@bl3D1ff) sd
USER sd

# Python setup - PYTHONUNBUFFERED set to 1 makes logs pipe into the container output
RUN pip install --upgrade pip
# Torch support list based on https://github.com/pytorch/builder/blob/main/conda/pytorch-nightly/build.sh
# and https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
ENV PYTHONUNBUFFERED=1 \
	PATH="$PATH:$SD_HOME/.local/bin" \
	TORCH_CUDA_ARCH_LIST=All \
	FORCE_CUDA=1

# Clone AUTOMATIC1111 repo
RUN cd $SD_HOME && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Set up virtual python environment
USER root
RUN cd $SD_PROJECT && python3.11 -m venv venv/ && chown -R sd venv
RUN sudo apt-get install google-perftools -y
USER sd

COPY --chown=sd --chmod=755 prep $SD_HOME/prep
RUN cd $SD_HOME/prep && ./launch_prep.sh

# Download cache
RUN cd $SD_HOME/prep && ./web_prep.sh

# Clean prep
RUN rm -r $SD_HOME/prep

WORKDIR $SD_PROJECT

EXPOSE 7860/tcp
CMD ["/bin/bash", "-c", "./webui.sh --listen --port 7860 --enable-insecure-extension-access"]
