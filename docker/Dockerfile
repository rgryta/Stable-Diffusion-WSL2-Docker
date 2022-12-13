################ Download models ################
FROM alpine:latest AS dw_models
RUN apk add wget

RUN mkdir /sd

# Stable diffusion models
RUN mkdir -p /sd/models/Stable-diffusion
WORKDIR sd/models/Stable-diffusion
RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-2-1/resolve/main/v2-1_768-ema-pruned.ckpt -O 768-v-ema.ckpt && \
	wget -c https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inference-v.yaml -O 768-v-ema.yaml

#RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-2-depth/resolve/main/512-depth-ema.ckpt -O 512-depth-ema.ckpt && \
#	wget -c https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-midas-inference.yaml -O 512-depth-ema.yaml

#RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-x4-upscaler/resolve/main/x4-upscaler-ema.ckpt -O x4-upscaler-ema.ckpt && \
#	wget -c https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/x4-upscaling.yaml -O x4-upscaler-ema.yaml

#RUN wget -c https://huggingface.co/stabilityai/stable-diffusion-2-inpainting/resolve/main/512-inpainting-ema.ckpt -O 512-inpainting-ema.ckpt && \
#	wget -c https://raw.githubusercontent.com/Stability-AI/stablediffusion/main/configs/stable-diffusion/v2-inpainting-inference.yaml -O 512-inpainting-ema.yaml


################ Main container ################
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as sd_webui

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
ENV PYTHONUNBUFFERED=1 \
	PATH="$PATH:$SD_HOME/.local/bin" \
	TORCH_CUDA_ARCH_LIST=All \
	CUDA_VISIBLE_DEVICES=0 \
	NVIDIA_VISIBLE_DEVICES=all \
	FORCE_CUDA=1

# Clone AUTOMATIC1111 repo
RUN cd $SD_HOME && git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Set up virtual python environment
USER root
RUN cd $SD_PROJECT && python3 -m venv venv/ && chown -R sd venv
USER sd

COPY --chown=sd prep $SD_HOME/prep
RUN cd $SD_HOME/prep && ./launch_prep.sh

# Copy models
COPY --from=dw_models --chown=sd /sd/ $SD_PROJECT/

# Download cache
RUN cd $SD_HOME/prep && ./web_prep.sh

# Clean prep
RUN rm -r $SD_HOME/prep

WORKDIR $SD_PROJECT

EXPOSE 7860/tcp
CMD ["/bin/bash", "-c", "./webui.sh --xformers --listen --port 7860"]