function Invoke-RunAsAdministrator {
    #Get current user context
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
    #Check user is running the script is member of Administrator Group
    if ($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Host "Script is running with Administrator privileges!"
    }
    else {
        Start-Process pwsh -ArgumentList "-File $PSCommandPath" -Verb RunAs
        #Exit from the current, unelevated, process
        Exit
    }
}

function New-Symlink {
    param (
        $Path,
        $Target
    )

    try {
        Write-Host "Removing old symlink...." -NoNewline
        Remove-Item $Path -Recurse
        Write-Host "Success" -Foreground Yellow
    }
    catch {
        Write-Host "Failed" -ForegroundColor Red
    }
    try {
        Write-Host "Adding new symlink...." -NoNewline
        New-Item -ItemType SymbolicLink -Path $Path -Target $Target -Force | Out-Null
        Write-Host "Success" -Foreground Yellow
    }
    catch {
        Write-Host "Failed" -ForegroundColor Red
    }
    Write-Host
}

function Install-Font {  
    param  
    (  
        [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile  
    )  
      
    #Get Font Name from the File's Extended Attributes  
    $oShell = new-object -com shell.application  
    $Folder = $oShell.namespace($FontFile.DirectoryName)  
    $Item = $Folder.Items().Item($FontFile.Name)  
    $FontName = $Folder.GetDetailsOf($Item, 21)  
    try {  
        switch ($FontFile.Extension) {  
            ".ttf" { $FontName = $FontName + [char]32 + '(TrueType)' }  
            ".otf" { $FontName = $FontName + [char]32 + '(OpenType)' }  
        }  
        $Copy = $true  
        Write-Host ('Copying' + [char]32 + $FontFile.Name + '.....') -NoNewline  
        Copy-Item -Path $fontFile.FullName -Destination ("C:\Windows\Fonts\" + $FontFile.Name) -Force  
        #Test if font is copied over  
        If ((Test-Path ("C:\Windows\Fonts\" + $FontFile.Name)) -eq $true) {  
            Write-Host ('Success') -Foreground Yellow  
        }
        else {  
            Write-Host ('Failed') -ForegroundColor Red  
        }  
        $Copy = $false  
        #Test if font registry entry exists  
        If ($null -ne (Get-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
            #Test if the entry matches the font file name  
            If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
                Write-Host ('Success') -ForegroundColor Yellow  
            }
            else {  
                $AddKey = $true  
                Remove-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force  
                Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
                New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
                If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                    Write-Host ('Success') -ForegroundColor Yellow  
                }
                else {  
                    Write-Host ('Failed') -ForegroundColor Red  
                }  
                $AddKey = $false  
            }  
        }
        else {  
            $AddKey = $true  
            Write-Host ('Adding' + [char]32 + $FontName + [char]32 + 'to the registry.....') -NoNewline  
            New-ItemProperty -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
            If ((Get-ItemPropertyValue -Name $FontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts") -eq $FontFile.Name) {  
                Write-Host ('Success') -ForegroundColor Yellow  
            }
            else {  
                Write-Host ('Failed') -ForegroundColor Red  
            }  
            $AddKey = $false  
        }  
           
    }
    catch {  
        If ($Copy -eq $true) {  
            Write-Host ('Failed') -ForegroundColor Red  
            $Copy = $false  
        }  
        If ($AddKey -eq $true) {  
            Write-Host ('Failed') -ForegroundColor Red  
            $AddKey = $false  
        }  
        write-warning $_.exception.message  
    }  
    Write-Host  
}

function Set-PathVariable {
    param (
        [string]$AddPath,
        [string]$RemovePath,
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'User'
    )
    $regexPaths = @()
    if ($PSBoundParameters.Keys -contains 'AddPath') {
        $regexPaths += [regex]::Escape($AddPath)
    }

    if ($PSBoundParameters.Keys -contains 'RemovePath') {
        $regexPaths += [regex]::Escape($RemovePath)
    }
    
    $arrPath = [System.Environment]::GetEnvironmentVariable('PATH', $Scope) -split ';'
    foreach ($path in $regexPaths) {
        $arrPath = $arrPath | Where-Object { $_ -notMatch "^$path\\?" }
    }
    $value = ($arrPath + $addPath) -join ';'
    [System.Environment]::SetEnvironmentVariable('PATH', $value, $Scope)
}

# -------------------------------------------------------------------------------------------------
# PowerShell 7
# -------------------------------------------------------------------------------------------------
if (-Not (Get-Command -Name "pwsh" -ErrorAction Ignore)) {
    winget install --id Microsoft.Powershell
}
Invoke-RunAsAdministrator

# -------------------------------------------------------------------------------------------------
# Create tmp directory
# -------------------------------------------------------------------------------------------------
$TMPDirectory = "$PSScriptRoot\tmp"
New-Item -Path "$TMPDirectory" -ItemType Directory | Out-Null

# -------------------------------------------------------------------------------------------------
# Install Font (FiraCode Nerd Font)
# -------------------------------------------------------------------------------------------------
Write-Host "Installing Font"
Invoke-WebRequest -Uri https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip -OutFile "$TMPDirectory\FiraCode.zip"
Expand-Archive -Path "$TMPDirectory\FiraCode.zip" -DestinationPath "$TMPDirectory\font"
Get-ChildItem -Path "$TMPDirectory\font\" -Recurse -Filter *.ttf | 
ForEach-Object {
    Install-Font $_
}

# -------------------------------------------------------------------------------------------------
# Starship
# -------------------------------------------------------------------------------------------------
if (-Not (Get-Command -Name "starship" -ErrorAction Ignore)) {
    Write-Host "Installing Starship"
    winget install --id Starship.Starship
}
Write-Host "Adding Starship config...."
New-Symlink -Path "$env:USERPROFILE\.config\starship.toml" -Target "$PSScriptRoot\starship\starship.toml"

# -------------------------------------------------------------------------------------------------
# Neovim
# -------------------------------------------------------------------------------------------------
if (-Not (Get-Command -Name "nvim" -ErrorAction Ignore)) {
    Write-Host "Installing Neovim"
    winget install Neovim.Neovim
}
Write-Host "Adding Neovim config...."
New-Symlink SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$PSScriptRoot\nvim"

# -------------------------------------------------------------------------------------------------
# lf
# -------------------------------------------------------------------------------------------------
if (-Not (Get-Command -Name "nvim" -ErrorAction Ignore)) {
    Write-Host "Installing lf"
    Invoke-WebRequest -Uri https://github.com/gokcehan/lf/releases/download/r30/lf-windows-386.zip -OutFile "$TMPDirectory\lf.zip"
    Expand-Archive -Path "$TMPDirectory\lf.zip" -DestinationPath "$env:LOCALAPPDATA\lf" -Force
    Set-PathVariable -AddPath "$env:LOCALAPPDATA\lf"
}
Write-Host

# -------------------------------------------------------------------------------------------------
# Link PowerShell Profile
# -------------------------------------------------------------------------------------------------
$ProfilePath = $PROFILE -replace "\\(?:.(?!\\))+$"
New-Symlink -Path "$ProfilePath\profile.ps1" -Target "$PSScriptRoot\PowerShell\profile.ps1" 

# -------------------------------------------------------------------------------------------------
# Clean Up
# -------------------------------------------------------------------------------------------------
Write-Host "Cleaning Up"
Remove-Item -Path "$TMPDirectory" -Recurse

Write-Host "Init Complete"
Pause