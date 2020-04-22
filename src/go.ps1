Copy-Files -CreateTarget -ShowProgress -Source "\\path\to\source" -Target "\\path\to\target" -ErrorVariable +err -ErrorAction "Silent"

if ($null -eq $err) {
    Write-host "No errors occurred"
}
else {
    Write-Host "Errors occurred!"
    foreach ($e in $err) {
        $e.Exception.Message
    }
}