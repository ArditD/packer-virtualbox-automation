#Wait a bit for slower systems
Start-Sleep -Seconds 60

Write-Host "Enabling RDP, reset SysprepStatus and show file extensions"

netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 0 /f
Set-ItemProperty -Path 'HKLM:\SYSTEM\Setup\Status\SysprepStatus'  -Name  'GeneralizationState' -Value 7
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Internet Explorer\UnattendBackup\ActiveSetup\DisableFirstRunWizard" -Name DisableFirstRunWizard -Value 1

# Installing Guest Additions
Write-Host 'Importing the certificates'
certutil -addstore -f "TrustedPublisher" A:\ORACLE.CER
#E:\cert\VBoxCertUtil.exe add-trusted-publisher --root E:\cert\vbox-*.cer
Write-Host 'Installing Guest additions'
E:\VBoxWindowsAdditions-amd64.exe /S
Start-Sleep -Seconds 60

#Disabling the Diagnostics Tracking Service
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled