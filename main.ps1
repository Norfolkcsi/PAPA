# WinGet With UI
function Get-WinGetUI {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # === App categories ===
    $apps_antimalware = @{
        "Malwarebytes"     = "Malwarebytes.Malwarebytes"
        "Adware Cleaner"   = "Malwarebytes.AdwCleaner"
        "Glary"            = "Glarysoft.GlaryUtilities"
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

# Options
do {
    Clear-Host
    Write-Host "Main Menu"
    Write-Host "1. Run WinGet UI"
    Write-Host "2. Run Option B"
    Write-Host "3. Run Option C"
    Write-Host "0. Exit"
    
    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" {
            Write-Host "Starting WinGet UI" -ForegroundColor Green
            [void](Get-WinGetUI)
        }
        "2" {
            Write-Host "Running Option B..." -ForegroundColor Green
        }
        "3" {
            Write-Host "Running Option C..." -ForegroundColor Green
        }
        "0" {
            Write-Host "Exiting..." -ForegroundColor Green
            break
        }
        default {
            Write-Warning "Invalid selection. Please try again."
        }
    }

    if ($choice -ne "0") {
        Read-Host "Press Enter to return to the menu"
    }

} while ($true)

#updated