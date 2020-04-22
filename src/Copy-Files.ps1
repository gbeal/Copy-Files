Function Copy-Files {
    <#
     Add some comment based help for the function here.
    .SYNOPSIS
        Recursively copies files from a source location to a *relative* target location.
        
        Optionally:
            * removes source after successful copy
            * shows progress
            * 
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]  # Add cmdlet features.
    Param (
        # Define parameters below, each separated by a comma
    
        [Parameter(Mandatory = $True, HelpMessage = "Enter a source directory")]
        [string]$Source,
    
        [Parameter(Mandatory = $True, HelpMessage = "Enter a target directory")]
        [string]$Target,
     
        [switch]$ShowProgress,
            
        [switch]$DeleteSource,

        [switch]$CreateTarget
            
    )
    
    
    Begin {
        # Start of the BEGIN block.
        $Action = if ($DeleteSource) { "Moving" } else { "Copying" }
        $ActionString = "$Action files from $Source to $Target"
        # Add additional code here.

        $Target = Resolve-Path $Target
        $Source = Resolve-Path $Source

        if (-not (Test-Path $Target) -and $CreateTarget) {
            try {
                New-Item -ItemType "directory" $Target
            }
            catch {
                Write-Verbose "Could not create base target directory $Target"
                Write-Verbose $_
                throw
            }
        }

        Push-Location $Source

        $Files = Get-ChildItem -Path . -Recurse #| Resolve-Path -Relative
            
    } # End Begin block
    
    Process {
        # Start of PROCESS block.
        $fileCounter = 1
        $totalFiles = ($Files | Measure-Object).Count

        foreach ($file in $Files) {
            
            try {
                #create destination file name
                $relativeFileName = Resolve-Path -Relative $file.FullName
                Push-Location $Target
                $destFile = Join-Path -Path $Target -ChildPath $relativeFileName
                Pop-Location
            }
            catch {
                Write-Verbose "An error occurred while trying to construct paths"
                Write-Verbose "Source: $($file.Fullname) , Relative Filename: $($relativeFileName) , Target: $($destFile)"
                Write-Verbose $_
                throw
            }

            #show progress if appropriate
            if ($ShowProgress) {
                $progress = ($fileCounter / $totalFiles) * 100
                $currentActivity = "$Action $($file) to $($destFile)"
                Write-Progress -CurrentOperation $currentActivity -PercentComplete $progress -Activity $currentActivity
            }

            if ($PSCmdlet.ShouldProcess($file, "Copy-Files")) {
                #create target directory if desired
                if ($CreateTarget `
                        -and $file.PSIsContainer `
                        -and (-not (Test-Path -Path $destFile))) {
                    try {
                        Write-Verbose "Creating directory $($file.FullName)"
                        New-Item -ItemType Directory -Path $destFile | Out-Null
                    }
                    catch {
                        Write-Verbose "An error occurred while trying to create directory $destFile"
                        Write-Verbose $_
                        throw
                    }
                }

                if (-not ($file.PSIsContainer)) {
                    try {
                        if ($DeleteSource) {
                            Write-Verbose "Moving File $($file.FullName) to $destFile"
                            Move-Item -Path $file.FullName -Destination $destFile | Out-Null
                        }
                        else {
                            #copy
                            Write-Verbose "Copying File $($file.FullName) to $destFile"
                            Copy-Item -Path $file.FullName -Destination $destFile | Out-Null
                        }
                    }
                    catch {
                        Write-Verbose "An error occurred while trying to move/copy file $destFile"
                        Write-Verbose $_
                        throw
                    }
                }
            }

            $fileCounter += 1   
        } 
            
    } # End of PROCESS block.
    
    End {
        # Start of END block.
        Write-Verbose -Message "Entering the END block [$($MyInvocation.MyCommand.CommandType): $($MyInvocation.MyCommand.Name)]."
    
        Pop-Location
        # Add additional code here.
    
    } # End of the END Block.
} # End Function
    
#----------------[ Main ]-----------------
# Optional Script Execution goes here
# and can call any of the functions above.

