$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$distro = 'ubuntu-stable-diffusion'

wsl -d $distro -e sh -c "cd ``wslpath -a '$scriptPath'``/../docker && ./trunc-sd-containers.sh"