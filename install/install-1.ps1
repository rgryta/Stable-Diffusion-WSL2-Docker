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

Write-ColorOutput green ('Enabling Hyper-V')

$hyperv = (Get-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online).State -ne "Enabled"

if($hyperv) {
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V-All
}

Write-ColorOutput green ('Installing newest PowerShell instance and Windows Subsystem for Linux from MS Store')
winget install --id Microsoft.Powershell --source winget --accept-source-agreements --accept-package-agreements
winget install 9P9TQF7MRM4R --source msstore --accept-source-agreements --accept-package-agreements

$command = "powershell.exe ""Start-Process pwsh -ArgumentList '-ExecutionPolicy Bypass -file $scriptPath\install-2.ps1'"""

if($hyperv) {
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce" `
	-Name SDINSTALL -PropertyType String `
	-Value $command  | Out-Null

	Write-ColorOutput red ('Your computer will restart in 15 seconds and resume right after...')
	Start-Sleep -Seconds 15

	Restart-Computer -Force
}
else {
	Start-Process $command
}