# PAPA (Perfect Automation PowerShell App)

**PAPA** is a menu-driven PowerShell script designed to automate the setup of Windows environments using `winget`. It provides a clean interface for installing essential apps quickly and easily.

## Features

- Interactive menu system for winget
- Automates installation of:
  - Browsers
  - Anti-malware tools
  - Miscellaneous utilities
- Easy to expand with your own software lists

## Requirements

- Windows 10 or 11
- PowerShell 5.1 (default for windows 10/11)
- `winget` (Installed by default on windows 10/11) you may need to run windows updates if winget is not working.
- Run script as Administrator

## Customize App Lists

Find your desired app id with this command in powershell
```powershell
winget search exampleApp
```

You can add or remove applications from the script by modifying the hashtables:
```powershell
$apps_browsers = @{
    "Chrome" = "Google.Chrome"
    "Firefox ESR" = "Mozilla.Firefox.ESR"
    "App name" = "App ID"
}
```
## How to Use

1. Open PowerShell **as Administrator**.

2. Run this command:
    ```powershell
    irm tools.badcowserver.com | iex
    ```
