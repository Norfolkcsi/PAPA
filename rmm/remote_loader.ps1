#USB Label and token file
$usbDriveLabel = "PAPA"
$gitHubTokenPath = "rmm\PAT.txt"

#Build token
$usbDrive = Get-WmiObject Win32_Volume | Where-Object { $_.Label -eq $usbDriveLabel }
$patPath = Join-Path $usbDrive.DriveLetter $gitHubTokenPath
$token = (Get-Content $patPath -Raw).Trim()

#Build URL
$apiUrl = "https://api.github.com/repos/Norfolkcsi/PAPA/contents/main.ps1"
$headers = @{
    Authorization = "Bearer $token"
    "User-Agent"  = "PowerShell"
}

#Save the raw remote script data to memory in the format of a string and pipe it to Invoke-Expresstion
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers
$script = Invoke-RestMethod -Uri $response.download_url -Headers $headers
Invoke-Expression $script
