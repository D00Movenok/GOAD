#ps1

# TLDR: sysprep after reboot runs $env:windir\Setup\Scripts\SetupComplete.cmd that
# runs $env:windir\Setup\Scripts\SetupComplete.ps1
#
# without sysprep different DCs have the same sid and trust cannot be established

New-Item "$env:windir\Setup\Scripts\" -ItemType Directory -ea 0

$startup_ps_script = @'
    # prepare instance for ansible
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $url = "https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file -ForceNewSSLCert

    # rename Administrator 
    Rename-LocalUser -Name "Administrator" -NewName "${username}"
    net user ${username} '${password}' /expires:never /y

    # create ansible user
    net user ansible '${password}' /add /expires:never /y
    net localgroup administrators ansible /add

    # rename ethernet N to ethernet 1 to fix some issues
    Rename-NetAdapter -Name "Ethernet*" -NewName "Ethernet 1"
'@ -replace "`n", "`r`n"

Add-Content "$env:windir\Setup\Scripts\SetupComplete.ps1" $startup_ps_script

# call powershell startup script and remove script dir
$startup_cmd_script = @'
    powershell.exe -ExecutionPolicy ByPass -File %WINDIR%\Setup\Scripts\SetupComplete.ps1 > "c:\output.txt" 2>&1

    del %WINDIR%\Setup\Scripts\ /q
'@ -replace "`n", "`r`n"

Add-Content "$env:windir\Setup\Scripts\SetupComplete.cmd" $startup_cmd_script

# sysprep to make SIDs unique
cd "C:/Program Files/Cloudbase Solutions/Cloudbase-Init/conf"
start-process -FilePath "C:/Windows/system32/sysprep/sysprep.exe" -ArgumentList "/generalize /oobe /mode:vm /quit /unattend:Unattend.xml" -wait
shutdown -r -f -t 05
