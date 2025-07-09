# === Cleanup Step Flags ===
$DoTemp = "True"
$DoWindowsUpdate = "True"
$DoWindowsOld = "True"
$DoRecycleBin = "True"
$DoPrefetch = "True"
$DoDeliveryOptimization = "True"
$DoBranchCache = "True"
$DoHibernation = "True"
$DoFlushDNS = "True"
$DoIISLogs = "True"
$DoComponentCleanup = "True"
$DoOldUserProfiles = "True"
$DoDiskReport = "True"
$DoDiskCleanupTool = "True"

# === Set up log folder and main log file ===
$logDate = Get-Date -Format "MM-dd-yyyy"
$logFolder = "C:\temp\Disk_Space_Cleanup"
$mainLog = "$logFolder\$logDate`_Disk_Space_Cleanup.log"
if (!(Test-Path $logFolder)) { New-Item -ItemType Directory -Path $logFolder | Out-Null }
if (Test-Path $mainLog) { Remove-Item $mainLog -Force }

# === Logging Function ===
function Log-Step {
    param ([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Write-Host $entry
    Add-Content -Path $mainLog -Value $entry
}

function Try-Cleanup {
    param (
        [string]$Description,
        [scriptblock]$Command
    )

    Log-Step "*** Starting: $Description"
    try {
        & $Command
        Log-Step "*** Completed: $Description"
    } catch {
        Log-Step "*** Failed: $Description - $_"
    }
}

# === Cleanup Tasks ===

if ($DoTemp -eq "True") {
    Try-Cleanup "Cleaning TEMP folders (User + System)" {
        $paths = @($env:TEMP, "C:\Windows\Temp", "C:\Temp")
        foreach ($p in $paths) {
            if (Test-Path $p) {
                Get-ChildItem -Path $p -Recurse -Force -ErrorAction Stop |
                Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
    }
}

if ($DoWindowsUpdate -eq "True") {
    Try-Cleanup "Cleaning Windows Update Cache" {
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    }
}

if ($DoWindowsOld -eq "True") {
    Try-Cleanup "Removing Windows.old and performing component reset cleanup" {
        Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
        if (Test-Path "C:\Windows.old") {
            Remove-Item -Path "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($DoRecycleBin -eq "True") {
    Try-Cleanup "Emptying Recycle Bin" {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
}

if ($DoPrefetch -eq "True") {
    Try-Cleanup "Cleaning Prefetch files older than 30 days" {
        Get-ChildItem -Path "C:\Windows\Prefetch" -Recurse -Force |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
        Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

if ($DoDeliveryOptimization -eq "True") {
    Try-Cleanup "Cleaning Delivery Optimization Cache" {
        $doPath = "C:\Windows\SoftwareDistribution\DeliveryOptimization\Cache\*"
        if (Test-Path $doPath) {
            Remove-Item -Path $doPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if ($DoBranchCache -eq "True") {
    Try-Cleanup "Clearing BranchCache" {
        Clear-BCCache -Force -ErrorAction SilentlyContinue
    }
}

if ($DoHibernation -eq "True") {
    Try-Cleanup "Disabling hibernation (removes hiberfil.sys)" {
        powercfg -h off
    }
}

if ($DoFlushDNS -eq "True") {
    Try-Cleanup "Flushing DNS cache" {
        ipconfig /flushdns | Out-Null
    }
}

if ($DoIISLogs -eq "True") {
    Try-Cleanup "Removing IIS and system log files" {
        Remove-Item -Path "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\System32\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

if ($DoComponentCleanup -eq "True") {
    Try-Cleanup "Cleaning Component Store (WinSxS)" {
        Dism.exe /online /Cleanup-Image /StartComponentCleanup
    }
}

if ($DoOldUserProfiles -eq "True") {
    Try-Cleanup "Removing user profiles unused for 180+ days" {
        Get-CimInstance Win32_UserProfile | Where-Object {
            $_.LastUseTime -lt (Get-Date).AddDays(-180) -and -not $_.Special
        } | Remove-CimInstance -ErrorAction SilentlyContinue
    }
}

if ($DoDiskCleanupTool -eq "True") {
    Try-Cleanup "Running Disk Cleanup Tool (cleanmgr)" {
        cleanmgr /sagerun:1 | Out-Null
    }
}

if ($DoDiskReport -eq "True") {
    Try-Cleanup "Generating disk space report" {
        Get-PSDrive -PSProvider FileSystem | ForEach-Object {
            $line = "{0}: {1} GB free of {2} GB" -f $_.Name,
            [math]::Round($_.Free/1GB,2),
            [math]::Round(($_.Used + $_.Free)/1GB,2)
            Log-Step $line
        }
    }
}

Log-Step "`n System cleanup completed. All logs saved to $mainLog"
