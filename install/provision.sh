cp -rf webui-user.sh /home/sd/stable-diffusion-webui
cp -rf config.json /home/sd/stable-diffusion-webui

cd /home/sd/stable-diffusion-webui/models/Stable-diffusion
curl -OL https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
curl -OL https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors

cd /home/sd/stable-diffusion-webui/models/VAE
curl -OL https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors