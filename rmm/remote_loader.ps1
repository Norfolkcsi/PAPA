#USB Label and token file
$usbDriveLabel = "WIN_11"
$gitHubTokenPath = "rmm\PAT.txt"

#Build token
$usbDrive = Get-WmiObject Win32_Volume | Where-Object { $_.Label -eq $usbDriveLabel }
$patPath = Join-Path $usbDrive.DriveLetter $gitHubTokenPath
$token = (Get-Content $patPath -Raw).Trim()

#Build URL
$apiUrl = "https://api.github.com/repos/Norfolkcsi/PAPA/contents/script.ps1"
$headers = @{
    Authorization = "Bearer $token"
    "User-Agent"  = "PowerShell"
}

#Save raw remote script data to a string in memory only and pipe it to Invoke-Expression
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
$script = Invoke-RestMethod -Uri $response.download_url -Headers $headers
Invoke-Expression $script
