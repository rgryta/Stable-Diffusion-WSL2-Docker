function Write-ColorOutput($ForegroundColor)
{
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Host.UI.RawUI.BackgroundColor = 'Black'

$ignr = wsl --set-default-version 2
Start-Sleep -Seconds 2

$option = 1
$distro = 'Ubuntu-Stable-Diffusion'

# Option 1 (automatic setup)
# Option 2 (interactive setup)
if ($option -eq 1) {
	Write-ColorOutput green ('Downloading Linux. This will take a while...') 
	
	# Using cURL as Invoke-WebRequest would sometimes get stuck and freeze PS
	curl -L -o $scriptPath\Ubuntu.appx https://aka.ms/wslubuntu
	
	$ignr = wsl --unregister $distro

	Rename-Item -Path $scriptPath\Ubuntu.appx -NewName $scriptPath\Ubuntu.zip

	Expand-Archive -Path $scriptPath\Ubuntu.zip -DestinationPath $scriptPath\tmp
	Remove-Item $scriptPath\Ubuntu.zip

	$ubuntuAPPX = (Get-ChildItem -Path $scriptPath\tmp\ -Filter *x64.appx).Basename
	Rename-Item -Path $scriptPath\tmp\$ubuntuAPPX.appx -NewName $scriptPath\tmp\Ubuntu.zip
	Move-Item -Path $scriptPath\tmp\Ubuntu.zip -Destination $scriptPath\Ubuntu.zip
	Remove-Item -Path $scriptPath\tmp -Recurse

	Expand-Archive -Path $scriptPath\Ubuntu.zip -DestinationPath $scriptPath\tmp\
	Remove-Item $scriptPath\Ubuntu.zip


	$ubuntuSysPackage = (Get-ChildItem -Path $scriptPath\tmp\ -Filter *.tar.gz).Basename
	Rename-Item -Path $scriptPath\tmp\$ubuntuSysPackage.gz -NewName $scriptPath\tmp\Ubuntu.tar.gz
	Move-Item -Path $scriptPath\tmp\Ubuntu.tar.gz -Destination $scriptPath\Ubuntu.tar.gz

	Remove-Item -Path $scriptPath\tmp -Recurse

	wsl --import $distro $scriptPath/install-dir/ $scriptPath\Ubuntu.tar.gz
	$ignr = wsl -d $distro -u root -e sh -c "useradd -m -G sudo -p `$(openssl passwd -1 St@bl3D1ff) sd"
	$ignr = wsl -d $distro -u root -e sh -c 'echo "[boot]\\nsystemd=true" > /etc/wsl.conf'
	$ignr = wsl -d $distro -u root -e sh -c 'echo "[user]\\ndefault=sd" >> /etc/wsl.conf'
}
elseif ($option -eq 1) {
	$distro = 'Ubuntu'
	wsl --install $distro
}
else {
	throw "Unexpected installation option."
}

Write-ColorOutput green ('Initlialization completed')
Start-Sleep -Seconds 5

Write-ColorOutput green ('Waiting for Ubuntu setup to finish...')
while ($true)
{
	$username = wsl -d $distro -e sh -c "grep -v '/usr/sbin/nologin' /etc/passwd | grep -v '^root\|^sync' | awk -F: '{print `$1}'"
	if ($username -ne $null) {
		Write-ColorOutput yellow ("Created default WSL user: $username")
		break
    }
}

Start-Sleep -Seconds 2
while ($true)
{
	$setupstatus = wsl -d $distro -u root -e sh -c "ps -Ao comm --no-headers | grep 'adduser\|passwd' | wc -l"
	if ($setupstatus -eq '0') {
		break
    }
}

Write-ColorOutput green ('Rebooting WSL distribution...')
Start-Sleep -Seconds 15

$ignr = wsl -d $distro -u root -e sh -c 'echo "[boot]\\nsystemd=true" > /etc/wsl.conf'
$ignr = wsl -t $distro

Write-ColorOutput green ('Adding NVIDIA repositories')

$ignr = wsl -d $distro -u root -e sh -c "apt-key del 7fa2af80 > /dev/null 2>&1 `&`& wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin > /dev/null 2>&1 `&`& mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600 `&`& apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/3bf863cc.pub > /dev/null 2>&1 `&`& add-apt-repository -y 'deb https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/ /' > /dev/null 2>&1 `&`& apt-get update > /dev/null 2>&1 `&`& apt-get -y install cuda > /dev/null 2>&1"

Write-ColorOutput yellow ('If you can see your GPU listed below, everything went smoothly so far:')
Start-Sleep -Seconds 5
wsl -d $distro -e sh -c 'nvidia-smi'

Write-ColorOutput green ('Installing docker within selected WSL distro')

$ignr = wsl -d $distro -u root -e sh -c "curl https://get.docker.com | sh  > /dev/null 2>&1 `&`& systemctl --now enable docker  > /dev/null 2>&1 "
	
$ignr = wsl -d $distro -u root -e sh -c "distribution=`$(. /etc/os-release;echo `$ID`$VERSION_ID) `&`& curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg > /dev/null 2>&1 `&`& curl -s -L https://nvidia.github.io/libnvidia-container/`$distribution/libnvidia-container.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list"

Write-ColorOutput green ('Installing nvidia-docker')

$ignr = wsl -d $distro -u root -e sh -c "apt-get update > /dev/null 2>&1 `&`& apt-get install -y nvidia-docker2 > /dev/null 2>&1"
$ignr = wsl -d $distro -u root -e sh -c 'systemctl restart docker'
$ignr = wsl -d $distro -u root -e sh -c "apt-get upgrade -y > /dev/null 2>&1 `&`& apt-get autoremove -y `&`& apt-get autoclean -y"

Clear-Host
Write-ColorOutput green ('Pulling base NVIDIA CUDA container')
Start-Sleep -Seconds 10
$ignr = wsl -d $distro -u root -e sh -c "usermod -aG docker $username"
$ignr = wsl -d $distro -e sh -c "docker pull nvidia/cuda:11.6.2-base-ubuntu20.04"

Write-ColorOutput yellow ('Verify if you are able to see your GPU below - this time within docker container:')
wsl -d $distro -e sh -c "docker run --rm --gpus all nvidia/cuda:11.6.2-base-ubuntu20.04 nvidia-smi"

Write-ColorOutput green ('Now local container will be built. This can take about an hour depending on your CPU and internet speed.')

Start-Process pwsh -ArgumentList "-NoExit -ExecutionPolicy Bypass -file $scriptPath\build.ps1"

Write-ColorOutput green ('You can close this window.')