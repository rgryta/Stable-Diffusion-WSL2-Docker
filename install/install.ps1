# Install dependencies for installing Linux
if (-not (Get-Module -ListAvailable -Name WSLTools)) {
    Install-Module -Name WSLTools -Force
} 

Import-Module WSLTools -WarningAction SilentlyContinue
if (-not (Ensure-WSL)) {
	$question = "Yes","No"
	$selected = Get-Select -Prompt "[OPER] Would you like to install HyperV and WSL now?" -Options $question
	if ($selected -eq "Yes") {
		iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/rgryta/PowerShell-WSLTools/main/install-wsl.ps1'))
		Write-Host "Reboot your system now and then restart the script"
	}
	if ($selected -eq "No") {
		Write-Host "Please set up HyperV and WSL manually and then relaunch the script"
	}
	return $false
}

# Install Ubuntu on WSL2
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$distro = 'ubuntu-stable-diffusion'
$ignr = wsl --unregister $distro

WSL-Ubuntu-Install -DistroAlias $distro -InstallPath $scriptPath -Version jammy # lunar has no docker, and kinetic has no nvidia-container-toolkit
$ignr = wsl -d $distro -u root -e sh -c "apt-get install -y apt-utils sudo curl systemd"

# Creating new user
$ignr = wsl -d $distro -u root -e sh -c "useradd -m -G sudo sd"
$ignr = wsl -d $distro -u root -e sh -c "echo sd:U6aMy0wojraho | sudo chpasswd -e" # No password

# Enabling Systemd (with fix: https://github.com/microsoft/WSL/issues/9602#issuecomment-1421897547)
$ignr = wsl -d $distro -u root -e sh -c 'echo "[boot]\\nsystemd=true" > /etc/wsl.conf'
$ignr = wsl -d $distro -u root -e sh -c 'echo "[user]\\ndefault=sd" >> /etc/wsl.conf'
$ignr = wsl -d $distro -u root -e sh -c 'ln -s /usr/lib/systemd/systemd /sbin/init'

Write-Host "Waiting for Ubuntu setup to finish..."
while ($true)
{
	$username = wsl -d $distro -e sh -c "grep -v '/usr/sbin/nologin' /etc/passwd | grep 'sd:' | awk -F: '{print `$1}'"
	if ($username -ne $null) {
		Write-Host "Created default WSL user: $username"
		break
    }
}

# Waiting for processes to finish and restarting
while ($true)
{
	$setupstatus = wsl -d $distro -u root -e sh -c "ps -Ao comm --no-headers | grep 'adduser\|passwd' | wc -l"
	if ($setupstatus -eq '0') {
		break
    }
}
$ignr = wsl -t $distro

# Setting up CUDA drivers
$ignr = wsl -d $distro -u root -e sh -c "apt-key del 7fa2af80 > /dev/null 2>&1 `&`& wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin > /dev/null 2>&1 `&`& mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600 `&`& apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/3bf863cc.pub > /dev/null 2>&1 `&`& add-apt-repository -y 'deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /' > /dev/null 2>&1 `&`& apt-get update > /dev/null 2>&1 `&`& apt-get -y install cuda > /dev/null 2>&1"


Write-Host 'If you can see your GPU listed below, everything went smoothly so far:'
Start-Sleep -Seconds 5
wsl -d $distro -e sh -c 'nvidia-smi'

# Installing Docker
$ignr = wsl -d $distro -u root -e sh -c "curl https://get.docker.com | sh  > /dev/null 2>&1 `&`& systemctl --now enable docker  > /dev/null 2>&1 "
	
$ignr = wsl -d $distro -u root -e sh -c "distribution=`$(. /etc/os-release;echo `$ID`$VERSION_ID) `&`& curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg > /dev/null 2>&1 `&`& curl -s -L https://nvidia.github.io/libnvidia-container/`$distribution/libnvidia-container.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"

# Installing Nvidia Docker
Write-Host 'Installing nvidia-docker'

$ignr = wsl -d $distro -u root -e sh -c "apt-get update > /dev/null 2>&1 `&`& apt-get install -y nvidia-docker2 > /dev/null 2>&1"
$ignr = wsl -d $distro -u root -e sh -c 'systemctl restart docker'
$ignr = wsl -d $distro -u root -e sh -c "apt-get upgrade -y > /dev/null 2>&1 `&`& apt-get autoremove -y `&`& apt-get autoclean -y"

# Testing Nvidia Docker
Write-Host 'Pulling base NVIDIA CUDA container'
$ignr = wsl -d $distro -u root -e sh -c "usermod -aG docker $username"
$ignr = wsl -d $distro -e sh -c "docker pull nvidia/cuda:12.1.1-base-ubuntu22.04"

Write-Host 'Verify if you are able to see your GPU below - this time within docker container:'
wsl -d $distro -e sh -c "docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi"

Write-Host 'Now local container will be built. This can take about an hour depending on your CPU and internet speed.'
wsl -d $distro -e sh -c "cd ``wslpath -a '$scriptPath'``/../docker && ./build.sh"

wsl -d $distro -e sh -c "mkdir -p /home/sd/stable-diffusion-webui"
wsl -d $distro -e sh -c "docker volume create --driver local --opt type=none --opt device=/home/sd/stable-diffusion-webui --opt o=bind sd_vol"
wsl -d $distro -e sh -c "docker create -v sd_vol:/home/sd/stable-diffusion-webui -p 127.0.0.1:7860:7860 --name sd --gpus all sd"

wsl -d $distro -e sh -c "cd ``wslpath -a '$scriptPath'`` && ./provision.sh"

Write-Host 'You can now use `start.bat` to launch Stable Diffusion. Closing this window in 5 seconds...'
Start-Sleep -Seconds 5