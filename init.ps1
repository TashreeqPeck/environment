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
        Remove-Item $Path -Recurse -ErrorAction SilentlyContinue
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
        Copy-Item -Path $fontFile.FullName -Destination ("C:\Windows\Fonts\" + $FontFile.Name) -Force -ErrorAction Ignore
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

function Expand-Archive {
    param (
        $Path,
        $DestinationPath
    )
    Write-Host "Extracting $Path...." -NoNewline
    try {
        $7Zip = (Get-ChildItem -Path "C:\" -Recurse -Filter "7z.exe" | Select-Object -First 1).FullName
        & $7Zip x $Path -o"$DestinationPath" -y | Out-Null
        Write-Host "Success" -Foreground Yellow
    }
    catch {
        Write-Host "Failed" -ForegroundColor Red
    }
}

function Install-Binary {
    param(
        $Name,
        $FriendlyName = $Name,
        $Uri,
        $Extension = "zip",
        $DestinationPath = $Name,
        $EnvironmentPath = $Name
    )
    if (-Not (Get-Command -Name $Name -ErrorAction Ignore)) {
        Write-Host "Installing $FriendlyName"
        Invoke-WebRequest -Uri $Uri -OutFile "$TMPDirectory\$Name.$Extension"
        Expand-Archive -Path "$TMPDirectory\$Name.$Extension" -DestinationPath "$env:LOCALAPPDATA\$DestinationPath"
        Set-PathVariable -AddPath "$env:LOCALAPPDATA\$EnvironmentPath"
    }
    else {
        Write-Host "$FriendlyName already installed"
    }
    Write-Host
}

function Install-WinGet {
    param (
        $Name,
        $FriendlyName = $Name,
        $Package
    )

    if (-Not (Get-Command -Name "$Name" -ErrorAction Ignore)) {
        Write-Host "Installing $FriendlyName"
        winget install --id $Package
    }
    else {
        Write-Host "$FriendlyName already installed"
    }
    Write-Host
    
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
Get-ChildItem -Path "$TMPDirectory\font" -Recurse -Filter *.ttf | 
ForEach-Object {
    Install-Font $_
}

# -------------------------------------------------------------------------------------------------
# Starship
# -------------------------------------------------------------------------------------------------
# Install-WinGet -Name "starship" -FriendlyName "Starship" -Package Starship.Starship
# if (-Not (Get-Command -Name "starship" -ErrorAction Ignore)) {
#     Write-Host "Installing Starship"
#     winget install --id Starship.Starship
# }
# Write-Host "Adding Starship config...."
# New-Symlink -Path "$env:USERPROFILE\.config\starship.toml" -Target "$PSScriptRoot\starship\starship.toml"

# -------------------------------------------------------------------------------------------------
# Neovim
# -------------------------------------------------------------------------------------------------
Install-WinGet -Name "nvim" -FriendlyName "Neovim" -Package Neovim.Neovim
New-Symlink SymbolicLink -Path "$env:LOCALAPPDATA\nvim" -Target "$PSScriptRoot\nvim"

# -------------------------------------------------------------------------------------------------
# lf
# -------------------------------------------------------------------------------------------------
# Install-Binary -Name "lf" -Uri https://github.com/gokcehan/lf/releases/download/r30/lf-windows-386.zip
# if (-Not (Get-Command -Name "lf" -ErrorAction Ignore)) {
#     Write-Host "Installing lf"
#     Invoke-WebRequest -Uri  -OutFile "$TMPDirectory\lf.zip"
#     Expand-Archive -Path "$TMPDirectory\lf.zip" -DestinationPath "$env:LOCALAPPDATA\lf"
#     Set-PathVariable -AddPath "$env:LOCALAPPDATA\lf"
# }
# else {
#     Write-Host "lf already installed"
# }
# Write-Host

# -------------------------------------------------------------------------------------------------
# LazyGit
# -------------------------------------------------------------------------------------------------
Install-Binary -Name "lazygit" -FriendlyName "LazyGit" -Uri https://github.com/jesseduffield/lazygit/releases/download/v0.38.2/lazygit_0.38.2_Windows_x86_64.zip
Write-Host

# -------------------------------------------------------------------------------------------------
# gcc
# -------------------------------------------------------------------------------------------------
# Install-Binary -Name "gcc" -FriendlyName "MinGw64" -Extension "7zip" -DestinationPath "" -EnvironmentPath "mingw64\bin" -Uri https://github.com/niXman/mingw-builds-binaries/releases/download/13.1.0-rt_v11-rev1/x86_64-13.1.0-release-win32-seh-msvcrt-rt_v11-rev1.7z
# if (-Not (Get-Command -Name "gcc" -ErrorAction Ignore)) {
#     Write-Host "Installing MinGw64"
#     Invoke-WebRequest -Uri https://github.com/niXman/mingw-builds-binaries/releases/download/13.1.0-rt_v11-rev1/x86_64-13.1.0-release-win32-seh-msvcrt-rt_v11-rev1.7z -OutFile "$TMPDirectory\mingw64.7z"
#     Expand-Archive -Path "$TMPDirectory\mingw64.7z" -DestinationPath "$env:LOCALAPPDATA"
#     Set-PathVariable -AddPath "$env:LOCALAPPDATA\mingw64\bin"
# }
# else {
#     Write-Host "MinGw64 already installed"
# }

# -------------------------------------------------------------------------------------------------
# LuaRocks
# -------------------------------------------------------------------------------------------------
# Install-Binary -Name "luarocks" -FriendlyName "LuaRocks" -Uri http://luarocks.github.io/luarocks/releases/luarocks-3.9.2-windows-64.zip
# if (-Not (Get-Command -Name "luarocks" -ErrorAction Ignore)) {
#     Write-Host "Installing LuaRocks"
#     Invoke-WebRequest -Uri https://github.com/gokcehan/lf/releases/download/r30/lf-windows-386.zip -OutFile "$TMPDirectory\luarocks.zip"
#     Expand-Archive -Path "$TMPDirectory\luarocks.zip" -DestinationPath "$env:LOCALAPPDATA\luarocks"
#     Set-PathVariable -AddPath "$env:LOCALAPPDATA\luarocks"
# }
# else {
#     Write-Host "lf already installed"
# }
# Write-Host

# -------------------------------------------------------------------------------------------------
# Ruby 3.2
# -------------------------------------------------------------------------------------------------
# Install-WinGet -Name "ruby" -FriendlyName "Ruby 3.2" -Package "RubyInstallerTeam.Ruby.3.2"
# Set-PathVariable -AddPath "C:\Ruby32-x64\bin"

# -------------------------------------------------------------------------------------------------
# PHP
# -------------------------------------------------------------------------------------------------
# Install-Binary -Name "php" -FriendlyName "PHP" -Uri https://windows.php.net/downloads/releases/php-8.2.7-Win32-vs16-x64.zip

# -------------------------------------------------------------------------------------------------
# Julia
# -------------------------------------------------------------------------------------------------
# Install-Binary -Name "julia" -EnvironmentPath "julia\julia-1.9.1\bin" -Uri https://julialang-s3.julialang.org/bin/winnt/x64/1.9/julia-1.9.1-win64.zip

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
