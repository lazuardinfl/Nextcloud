function Get-NextcloudItem {
    [OutputType([System.IO.FileInfo])]
    param (
        [Alias("NextcloudUrl")] [ValidateNotNullOrWhiteSpace()] [string]$url,
        [Alias("ItemPath")] [ValidateNotNullOrWhiteSpace()] [string]$path,
        [Alias("DownloadPath")] [ValidateNotNullOrWhiteSpace()] [string]$destination,
        [Alias("UserId")] [ValidateNotNullOrWhiteSpace()] [string]$id,
        [Alias("UserPassword")] [ValidateNotNullOrWhiteSpace()] [string]$pass,
        [Alias("OnErrorContinue")] [switch]$silent
    )
    try {
        $rest = @{
            Uri = "$($url)/remote.php/dav/files/$($id)/$($path)"
            Method = "Get"
            Authentication = "Basic"
            Credential = [pscredential]::new($id, (ConvertTo-SecureString $pass -AsPlainText -Force))
            OutFile = $destination
        }
        Invoke-RestMethod @rest | Out-Null
        if (Test-Path -Path $destination -PathType Leaf -ErrorAction Stop) { return Get-Item -Path $destination -ErrorAction Stop }
        else { return Get-ChildItem -Path $destination -ErrorAction Stop | Sort-Object -Property LastWriteTime, CreationTime -Descending | Select-Object -First 1 }
    }
    catch { if ($silent) { return $null } else { throw } }
}