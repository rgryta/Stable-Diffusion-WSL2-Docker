wsl -d ubuntu-stable-diffusion -e sh -c "cd `wslpath -a '%~dp0'`/docker && ./stop.sh"
wsl -t ubuntu-stable-diffusion
