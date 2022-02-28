#Eleva privilegios
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$testadmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if ($testadmin -eq $false) {
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -windowstyle hidden -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
exit $LASTEXITCODE
}
    

#Inicio Script
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$Form_main = New-Object System.Windows.Forms.Form
$Form_main.Text = "WinRepair    by gabrielrtl" 
$Form_main.Size = New-Object System.Drawing.Size(270,350)
$Form_main.FormBorderStyle = "FixedDialog"
$Form_main.TopMost = $true
$Form_main.MaximizeBox = $false
$Form_main.MinimizeBox = $false
$Form_main.ControlBox = $true
$Form_main.StartPosition = "CenterScreen"
$Form_main.Font = "Segoe UI"

# Texto menu
$label_main = New-Object System.Windows.Forms.Label
$label_main.Location = New-Object System.Drawing.Size(8,8)
$label_main.Size = New-Object System.Drawing.Size(240,32)
$label_main.TextAlign = "MiddleCenter"
$label_main.Text = "Escolha uma opção abaixo"
$Form_main.Controls.Add($label_main)

# Botão 1
$button_1 = New-Object System.Windows.Forms.Button
$button_1.Location = New-Object System.Drawing.Size(8,40)
$button_1.Size = New-Object System.Drawing.Size(240,32)
$button_1.TextAlign = "MiddleCenter"
$button_1.Text = "Reparar Windows"
$button_1.Add_Click({
    $button_1.Text = "INICIANDO..."
    Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation) \AppXManifest.xml”}
    $button_1.Text = "AGUARDE..."
    DISM /Online /Cleanup-Image /ScanHealth
    $button_1.Text = "REPARANDO..."
    DISM /Online /Cleanup-Image /RestoreHealth
    $button_1.Text = "UM MOMENTO..."
    chkdsk /f/r
    $button_1.Text = "FINALIZANDO..."
    sfc /scannow
    $button_1.Text = "REPARADO!!!"
    })
$Form_main.Controls.Add($button_1)

# Botão 2
$button_2 = New-Object System.Windows.Forms.Button
$button_2.Location = New-Object System.Drawing.Size(8,80)
$button_2.Size = New-Object System.Drawing.Size(240,32)
$button_2.TextAlign = "MiddleCenter"
$button_2.Text = "Reparar Rede"
$button_2.Add_Click({
    $button_2.Text = "REPARANDO..."
    netsh winsock reset all
    netsh int 6to4 reset all
    netsh int ipv4 reset all
    netsh int ipv6 reset all
    netsh int httpstunnel reset all
    netsh int isatap reset all
    netsh int portproxy reset all
    netsh int tcp reset all
    netsh int teredo reset all
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    ipconfig /registerdns
    nbtstat -rr
    netsh int ip reset all
    netsh winsock reset
    netcfg -d
    $button_2.Text = "REINICIANDO..."
    timeout /t 3
    shutdown -r -t 0
    })
$Form_main.Controls.Add($button_2)

# Botão 3
$button_3 = New-Object System.Windows.Forms.Button
$button_3.Location = New-Object System.Drawing.Size(8,120)
$button_3.Size = New-Object System.Drawing.Size(240,32)
$button_3.TextAlign = "MiddleCenter"
$button_3.Text = "Verificar Licença"
$button_3.Add_Click({
    $Form_main.TopMost = $false
    Powershell.exe -ExecutionPolicy Bypass slmgr /dli
    function Get-ProductKey {
        $map="BCDFGHJKMPQRTVWXY2346789"
        $value = (get-itemproperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").digitalproductid[0x34..0x42]
        $ProductKey = ""
            for ($i = 24; $i -ge 0; $i--) {
                $r = 0
                for ($j = 14; $j -ge 0; $j--) {
                    $r = ($r * 256) -bxor $value[$j]
                    $value[$j] = [math]::Floor([double]($r / 24))
                    $r = $r % 24
                }
                $ProductKey = $map[$r] + $ProductKey
                if (($i % 5) -eq 0 -and $i -ne 0) {
                $ProductKey = "-" + $ProductKey
                }
            }
        Write-Output $ProductKey
    }
    $key = Get-ProductKey
   
    $Form_key = New-Object System.Windows.Forms.Form
    $Form_key.Size = New-Object System.Drawing.Size(270,300)
    $Form_key.StartPosition = "CenterScreen"
    $Form_key.TopMost = $true
    $Form_key.FormBorderStyle = "FixedDialog"

    $label_key = New-Object System.Windows.Forms.Label
    $label_key.Location = New-Object System.Drawing.Size(8,8)
    $label_key.Size = New-Object System.Drawing.Size(240,10)
    $label_key.TextAlign = "MiddleCenter"
    $label_key.Text = "CHAVE DO WINDOWS:"
    $Form_key.Controls.Add($label_key)

    $label_key2 = New-Object System.Windows.Forms.Label
    $label_key2.Location = New-Object System.Drawing.Size(8,8)
    $label_key2.Size = New-Object System.Drawing.Size(240,32)
    $label_key2.TextAlign = "MiddleCenter"
    $label_key2.Text = $key
    $Form_key.Controls.Add($label_key2)
    
    $Form_key.ShowDialog()
})
$Form_main.Controls.Add($button_3)

$button_3 = New-Object System.Windows.Forms.Button
$button_3.Location = New-Object System.Drawing.Size(8,160)
$button_3.Size = New-Object System.Drawing.Size(240,32)
$button_3.TextAlign = "MiddleCenter"
$button_3.Text = "Reparar Teclado"
$button_3.Add_Click({
    $hexified = "00,00,00,00,00,00,00,00,02,00,00,00,73,00,1d,e0,00,00,00,00".Split(',') | % { "0x$_"};
    $kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';
    New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);
    $button_3.Text = "OK..."
    })
$Form_main.Controls.Add($button_3)

$button_4 = New-Object System.Windows.Forms.Button
$button_4.Location = New-Object System.Drawing.Size(8,200)
$button_4.Size = New-Object System.Drawing.Size(240,32)
$button_4.TextAlign = "MiddleCenter"
$button_4.Text = "Otimizar Windows"
$button_4.Add_Click({
    REM Apaga todas as pastas temporárias e arquivos temporários do usuário
    takeown /A /R /D Y /F C:\Users\%USERNAME%\AppData\Local\Temp\
    icacls C:\Users\%USERNAME%\AppData\Local\Temp\ /grant administradores:F /T /C
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Temp\
    md C:\Users\%USERNAME%\AppData\Local\Temp\

    REM Apaga os arquivos de \Windows\Temp
    takeown /A /R /D Y /F C:\windows\temp
    icacls C:\windows\temp /grant administradores:F /T /C
    rmdir /q /s c:\windows\temp
    md c:\windows\temp

    REM Apaga arquivos de log
    del c:\windows\logs\cbs\*.log
    del C:\Windows\Logs\MoSetup\*.log
    del C:\Windows\Panther\*.log /s /q
    del C:\Windows\inf\*.log /s /q
    del C:\Windows\logs\*.log /s /q
    del C:\Windows\SoftwareDistribution\*.log /s /q
    del C:\Windows\Microsoft.NET\*.log /s /q
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\WebCache\*.log /s /q
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\SettingSync\*.log /s /q
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Explorer\ThumbCacheToDelete\*.tmp /s /q
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\"Terminal Server Client"\Cache\*.bin /s /q
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\INetCache\

    REM ******************** EDGE ********************
    taskkill /F /IM "msedge.exe"
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\GrShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\ShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\Default\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 1"\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Microsoft\Edge\"User Data"\"Profile 2"\Storage\ext\

    REM ******************** FIREFOX ********************
    taskkill /F /IM "firefox.exe"
    REM define qual é a pasta Profile do usuário e apaga os arquivos temporários dali
    set parentfolder=C:\Users\%USERNAME%\AppData\Local\Mozilla\Firefox\Profiles\
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\cache2\entries\*.
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\startupCache\*.bin
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\startupCache\*.lz*
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\cache2\index*.*
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\startupCache\*.little
    del C:\Users\%USERNAME%\AppData\local\Mozilla\Firefox\Profiles\%folder%\cache2\*.log /s /q

    REM ******************** VIVALDI ********************
    taskkill /F /IM "vivaldi.exe"
    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\GrShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\ShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\Default\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 1"\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Vivaldi\"User Data"\"Profile 2"\Storage\ext\

    REM ******************** BRAVE ********************
    taskkill /F /IM "brave.exe"
    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\GrShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\ShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\Default\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 1"\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\"User Data"\"Profile 2"\Storage\ext\

    REM ******************** CHROME ********************
    taskkill /F /IM "chrome.exe"
    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\Cache\f*.
    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\Cache\index.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\GrShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\ShaderCache\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\Default\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 1"\Storage\ext\

    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\Cache\data*.
    del C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\Cache\f*.
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\"Service Worker"\Database\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\"Service Worker"\CacheStorage\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\"Service Worker"\ScriptCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\GPUCache\
    rmdir /q /s C:\Users\%USERNAME%\AppData\Local\Google\Chrome\"User Data"\"Profile 2"\Storage\ext\
    $button_4.Text = "OTIMIZADO!"
    })
$Form_main.Controls.Add($button_4)


# Botão 5
$button_5 = New-Object System.Windows.Forms.Button
$button_5.Location = New-Object System.Drawing.Size(8,240)
$button_5.Size = New-Object System.Drawing.Size(240,32)
$button_5.TextAlign = "MiddleCenter"
$button_5.Text = "Informação do Sistema"
$button_5.Add_Click({
    $Form_info = New-Object System.Windows.Forms.Form
    $Form_info.Size = New-Object System.Drawing.Size(300,200)
    $Form_info.StartPosition = "CenterScreen"
    $Form_info.TopMost = $true
    $Form_info.FormBorderStyle = "FixedDialog"

    $label_info = New-Object System.Windows.Forms.Label
    $label_info.Location = New-Object System.Drawing.Size(8,8)
    $label_info.Size = New-Object System.Drawing.Size(240,12)
    $label_info.TextAlign = "MiddleCenter"
    $fabricante = Get-WmiObject Win32_ComputerSystem |select Manufacturer,Model -ExpandProperty Manufacturer
    $modelo = Get-WmiObject Win32_ComputerSystem |select Manufacturer,Model -ExpandProperty Model
    $label_info.Text = "$fabricante $modelo"
    $Form_info.Controls.Add($label_info)

    $label_info2 = New-Object System.Windows.Forms.Label
    $label_info2.Location = New-Object System.Drawing.Size(8,20)
    $label_info2.Size = New-Object System.Drawing.Size(240,25)
    $label_info2.TextAlign = "MiddleCenter"
    $cpuinfo = Get-WmiObject win32_processor |select DeviceID,Name -ExpandProperty Name
    $label_info2.Text = "$cpuinfo"
    $Form_info.Controls.Add($label_info2)

    $label_info3 = New-Object System.Windows.Forms.Label
    $label_info3.Location = New-Object System.Drawing.Size(8,45)
    $label_info3.Size = New-Object System.Drawing.Size(240,12)
    $label_info3.TextAlign = "MiddleCenter"
    $colslots = Get-CimInstance -ClassName "win32_PhysicalMemoryArray"
    $colrAM = Get-CimInstance -ClassName "win32_PhysicalMemory"
    $ramtotal = $($mem = $null; $colram.capacity | foreach{$mem += $_};[math]::round($mem /1gb, 0))
    $label_info3.Text = "Ram Total: " + $ramtotal + "GB"
    $Form_info.Controls.Add($label_info3)

    $label_info4 = New-Object System.Windows.Forms.Label
    $label_info4.Location = New-Object System.Drawing.Size(8,60)
    $label_info4.Size = New-Object System.Drawing.Size(240,12)
    $label_info4.TextAlign = "MiddleCenter"
    $slotsmemoria = Get-CimInstance -ClassName "win32_PhysicalMemoryArray" |select MemoryDevices  -ExpandProperty MemoryDevices
    $label_info4.Text = "Slots Total: " + $slotsmemoria
    $Form_info.Controls.Add($label_info4)

    $label_info5 = New-Object System.Windows.Forms.Label
    $label_info5.Location = New-Object System.Drawing.Size(8,75)
    $label_info5.Size = New-Object System.Drawing.Size(240,12)
    $label_info5.TextAlign = "MiddleCenter"
    $gpuinfo = Get-WmiObject win32_videocontroller |select Name -ExpandProperty Name
    $label_info5.Text = $gpuinfo
    $Form_info.Controls.Add($label_info5)

    
    $Form_info.ShowDialog()
    })
$Form_main.Controls.Add($button_5)


# Mostra o script
$Form_main.Add_Shown({$Form_main.Activate()})
[void] $Form_main.ShowDialog()