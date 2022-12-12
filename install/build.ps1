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

$directdist = !$(wsl -l -q).Contains('Ubuntu-Stable-Diffusion')
$distro = 'Ubuntu-Stable-Diffusion'

if ($directdist) {
	$distro = 'Ubuntu'
}

wsl -d $distro -e sh -c "cd ``wslpath -a '$scriptPath'``/../docker && ./build.sh"

Write-ColorOutput green ('You can close this window.')