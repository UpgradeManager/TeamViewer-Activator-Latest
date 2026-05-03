$sourcePath = 'C:\Source'
$destinationPath = 'C:\Destination'
$logFile = 'C:\log.txt'
$files = Get-ChildItem -Path $sourcePath -File
$successCount = 0
$errorCount = 0
foreach ($file in $files) {
    try {
        $destinationFile = Join-Path -Path $destinationPath -ChildPath $file.Name
        Copy-Item -Path $file.FullName -Destination $destinationFile
        $successCount++
    } catch {
        $errorCount++
        Add-Content -Path $logFile -Value "Error processing $($file.Name): $_"
    }
}
$summary = "Processed $($files.Count) files: $successCount succeeded, $errorCount failed."
Add-Content -Path $logFile -Value $summary
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
Add-Content -Path $logFile -Value "Log generated at $timestamp"
if ($errorCount -gt 0) {
    Write-Host "Some files failed to process. Check the log for details."
} else {
    Write-Host "All files processed successfully."
}
$backupPath = 'C:\Backup'
if (-Not (Test-Path -Path $backupPath)) {
    New-Item -Path $backupPath -ItemType Directory
}
$backupFile = Join-Path -Path $backupPath -ChildPath "backup_$(Get-Date -Format 'yyyyMMddHHmmss').zip"
Compress-Archive -Path $destinationPath\* -DestinationPath $backupFile
Write-Host "Backup created at $backupFile."
Start-Sleep -Seconds 2
$notification = New-Object -ComObject WScript.Shell
$notification.Popup('File processing complete', 0, 'Notification', 0)
Remove-Item -Path $destinationPath\* -Force
Write-Host "Temporary files cleaned up."
