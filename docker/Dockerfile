################ Download models ################
FROM alpine:latest AS dw_models
RUN apk add wget

RUN mkdir /sd

# Stable diffusion models
RUN mkdir -p /sd/models/Stable-diffusion
WORKDIR /sd/models/Stable-diffusion
RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors -O sd_xl_base_1.0.safetensors
RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors -O sd_xl_refiner_1.0.safetensors

RUN mkdir -p /sd/models/VAE
WORKDIR /sd/models/VAE
RUN wget -c https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors -O sdxl_vae.safetensors

# Add/Modify used models here


################ Main container ################
FROM nvidia/cuda:12.0.1-devel-ubuntu22.04 as sd_webui

ENV SD_HOME=/home/sd
ENV SD_PROJECT=$SD_HOME/stable-diffusion-webui

# Install necessary packages
RUN apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -y \
		sudo git g++ python3 python3-pip python3-venv python3-dev ffmpeg libsm6 libxext6 curl wget vim

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
RUN cd $SD_PROJECT && python3 -m venv venv/ && chown -R sd venv
RUN sudo apt-get install google-perftools -y
USER sd

COPY --chown=sd --chmod=755 prep $SD_HOME/prep
RUN cd $SD_HOME/prep && ./launch_prep.sh

# Copy models
COPY --from=dw_models --chown=sd /sd/ $SD_PROJECT/

# Download cache
RUN cd $SD_HOME/prep && ./web_prep.sh

# Clean prep
RUN rm -r $SD_HOME/prep

WORKDIR $SD_PROJECT

EXPOSE 7860/tcp
CMD ["/bin/bash", "-c", "./webui.sh --xformers --listen --port 7860 --vae-path \"$SD_PROJECT/models/VAE/sdxl_vae.safetensors\""]
