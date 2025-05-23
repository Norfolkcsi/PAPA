# WinGet With UI
function Get-WinGetUI {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # === App categories ===
    $apps_antimalware = @{
        "Malwarebytes"     = "Malwarebytes.Malwarebytes"
        "Adware Cleaner"   = "Malwarebytes.AdwCleaner"
        "Glary"            = "Glarysoft.GlaryUtilities"
        "Revo"             = "RevoUninstaller.RevoUninstaller"
    }
    
    $apps_browsers = @{
        "Google Chrome"    = "Google.Chrome"
        "Brave Browser"    = "Brave.Brave"
        "Mozilla Firefox"  = "Mozilla.Firefox"
    }
    
    $apps_misc = @{
        "NAPS2"            = "Cyanfish.NAPS2"
        "7-Zip"            = "7zip.7zip"
        "VLC Media Player" = "VideoLAN.VLC"
        "Discord"          = "Discord.Discord"
        "VS Code"          = "Microsoft.VisualStudioCode"
        "LibreOffice"      = "TheDocumentFoundation.LibreOffice"
    }
    
    # === Create Form ===
    $form = New-Object Windows.Forms.Form
    $form.Text = "Winget App Installer"
    $form.Size = New-Object Drawing.Size(420, 700)
    $form.StartPosition = "CenterScreen"
    $form.Topmost = $true
    
    # === Create Category Labels ===
    $lblAntimalware = New-Object Windows.Forms.Label
    $lblAntimalware.Text = "Antimalware"
    $lblAntimalware.Location = New-Object Drawing.Point(10, 10)
    $form.Controls.Add($lblAntimalware) 
    
    $lblBrowsers = New-Object Windows.Forms.Label
    $lblBrowsers.Text = "Browsers"
    $lblBrowsers.Location = New-Object Drawing.Point(10, 140)
    $form.Controls.Add($lblBrowsers) 
    
    $lblMisc = New-Object Windows.Forms.Label
    $lblMisc.Text = "Miscellaneous"
    $lblMisc.Location = New-Object Drawing.Point(10, 270)
    $form.Controls.Add($lblMisc) 
    
    # === App Selection Lists ===
    $chkAntimalware = New-Object Windows.Forms.CheckedListBox
    $chkAntimalware.Location = New-Object Drawing.Point(10, 30)
    $chkAntimalware.Size = New-Object Drawing.Size(380, 100)
    $chkAntimalware.CheckOnClick = $true
    $apps_antimalware.Keys | ForEach-Object { $chkAntimalware.Items.Add($_) }
    $form.Controls.Add($chkAntimalware)
    
    $chkBrowsers = New-Object Windows.Forms.CheckedListBox
    $chkBrowsers.Location = New-Object Drawing.Point(10, 160)
    $chkBrowsers.Size = New-Object Drawing.Size(380, 100)
    $chkBrowsers.CheckOnClick = $true
    $apps_browsers.Keys | ForEach-Object { $chkBrowsers.Items.Add($_) }
    $form.Controls.Add($chkBrowsers)
    
    $chkMisc = New-Object Windows.Forms.CheckedListBox
    $chkMisc.Location = New-Object Drawing.Point(10, 290)
    $chkMisc.Size = New-Object Drawing.Size(380, 100)
    $chkMisc.CheckOnClick = $true
    $apps_misc.Keys | ForEach-Object { $chkMisc.Items.Add($_) }
    $form.Controls.Add($chkMisc)
    
    # === Output TextBox ===
    $outputBox = New-Object Windows.Forms.TextBox
    $outputBox.Location = New-Object Drawing.Point(10, 430)
    $outputBox.Size = New-Object Drawing.Size(380, 180)
    $outputBox.Multiline = $true
    $outputBox.ScrollBars = "Vertical"
    $outputBox.ReadOnly = $true
    $outputBox.Font = New-Object Drawing.Font("Consolas", 9)
    $form.Controls.Add($outputBox)
    
    function Write-Log($text) {
        $outputBox.AppendText("$text`r`n")
        $outputBox.SelectionStart = $outputBox.Text.Length
        $outputBox.ScrollToCaret()
    }
    
    # === Clear Button ===
    $btnClear = New-Object Windows.Forms.Button
    $btnClear.Text = "Clear Output"
    $btnClear.Location = New-Object Drawing.Point(210, 400)
    $btnClear.Size = New-Object Drawing.Size(100, 25)
    $btnClear.Add_Click({ $outputBox.Clear() })
    $form.Controls.Add($btnClear)
    
    # === Install Button ===
    $btnInstall = New-Object Windows.Forms.Button
    $btnInstall.Text = "Install Selected"
    $btnInstall.Location = New-Object Drawing.Point(10, 400)
    $btnInstall.Size = New-Object Drawing.Size(180, 25)
    $btnInstall.Add_Click({
        $allChecked = @()
        $allChecked += $chkAntimalware.CheckedItems
        $allChecked += $chkBrowsers.CheckedItems
        $allChecked += $chkMisc.CheckedItems
    
        if ($allChecked.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one app to install.", "No apps selected", "OK", "Warning")
            return
        }
    
        Write-Log "`nStarting installation..."
    
        foreach ($item in $allChecked) {
            $name = $item.ToString()
            $id = if ($apps_antimalware.ContainsKey($name)) {
    $apps_antimalware[$name]
} elseif ($apps_browsers.ContainsKey($name)) {
    $apps_browsers[$name]
} elseif ($apps_misc.ContainsKey($name)) {
    $apps_misc[$name]
} else {
    $null
}
            Write-Log "Installing ${name}..."
            try {
                $result = winget install --id $id --silent --accept-package-agreements --accept-source-agreements 2>&1
                Write-Log "$result"
            } catch {
                Write-Log "Failed to install ${name}: $($_.Exception.Message)"
            }
            Write-Log "---------------------"
        }
    })
    $form.Controls.Add($btnInstall) 
    
    # === Run the Form ===
    [void]$form.ShowDialog() 
    
}

#Remove big fish games
function Get-BigFishUninstall {
    
    Write-Host "Starting Big Fish Game Manager removal..." -ForegroundColor Cyan
    
    # Attempt to uninstall via registry Uninstall entry
    $uninstallKeyPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    foreach ($path in $uninstallKeyPaths) {
        Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
            $_.DisplayName -like "*Big Fish Games*" -or $_.DisplayName -like "*Game Manager*"
        } | ForEach-Object {
            Write-Host "Found: $($_.DisplayName)" -ForegroundColor Yellow
            if ($_.UninstallString) {
                $uninstallCmd = $_.UninstallString
                Write-Host "Running uninstall command..." -ForegroundColor Red
                Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstallCmd" -Wait
            }
        }
    }
    
    # Define leftover paths to delete
    $pathsToDelete = @(
        "$env:ProgramFiles(x86)\Big Fish Games",
        "$env:ProgramData\Big Fish",
        "$env:APPDATA\Big Fish"
    )
    
    foreach ($folder in $pathsToDelete) {
        if (Test-Path $folder) {
            Write-Host "Deleting folder: $folder" -ForegroundColor Green
            Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
        } else {
            Write-Host "Folder not found: $folder" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "Cleanup complete. You can now reinstall Big Fish Game Manager." -ForegroundColor Cyan
}

#Get wifi passwords
# Get a list of saved Wi-Fi profiles
$wifiProfiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ": ")[1].Trim() }

# Loop through each profile and extract the password
function Get-WifiPass {

    foreach ($profile in $wifiProfiles) {
        $passwordInfo = netsh wlan show profile name="$profile" key=clear | Select-String "Key Content"
        
        if ($passwordInfo) {
            $password = ($passwordInfo -split ": ")[1].Trim()
        } else {
            $password = "No password found (Open Network or Insufficient Permissions)"
        }
        
        Write-Output "Wi-Fi: $profile | Password: $password"
    }
}

#Install print Management console
function Get-Print-Management-Console {
    $cmd = "dism.exe /online /add-capability /capabilityname:Print.Management.Console~~~~0.0.1.0"
    Invoke-Expression $cmd
}

# Options
$continueLoop = $true
do {
    Clear-Host
    Write-Host "Main Menu"
    Write-Host "1. Run WinGet UI"
    Write-Host "2. Run Get-Print-Management-Console"
    Write-Host "3. Wifi Pass"
    Write-Host "0. Exit"
    
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            Write-Host "Starting WinGet UI" -ForegroundColor Green
            [void](Get-WinGetUI)
        }
        "2" {
            Write-Host "Running Get-Print-Management-Console" -ForegroundColor Green
            Get-Print-Management-Console
        }
        "3" {
            Write-Host "Running Option C..." -ForegroundColor Green
            Get-WifiPass
        }
        "0" {
            Write-Host "Exiting..." -ForegroundColor Green
            $continueLoop = $false
        }
        default {
            Write-Warning "Invalid selection. Please try again."
        }
    }

    if ($choice -ne "0") {
        Read-Host "Press Enter to return to the menu"
    }

} while ($continueLoop -eq $true)

#Working
