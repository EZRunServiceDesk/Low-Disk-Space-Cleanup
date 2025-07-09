# 💻 PowerShell Disk Cleanup Script

This PowerShell script helps free up disk space and improve system performance on Windows by running various cleanup tasks. Each task is controlled by a toggle flag at the top of the script.

---

## 🔧 Features

This script can perform the following cleanup actions:

- 🗑️ **Temporary Files** — Cleans TEMP folders (User and System)  
- ♻️ **Recycle Bin** — Empties the recycle bin  
- 🧹 **Windows Update Cache** — Removes downloaded update files  
- 🪟 **Windows.old** — Deletes leftover files from old Windows installations  
- ⚡ **Prefetch** — Deletes prefetch data older than 30 days  
- 🚚 **Delivery Optimization** — Clears cached delivery optimization files  
- 🌿 **BranchCache** — Clears cached network files  
- 💤 **Hibernation File** — Disables hibernation and removes `hiberfil.sys`  
- 🌐 **DNS Cache** — Flushes the DNS resolver cache  
- 📑 **Log Files** — Deletes IIS and system log files  
- 🏗️ **Component Store** — Cleans up the WinSxS folder using DISM  
- 👤 **Old User Profiles** — Deletes user profiles not used for 180+ days  
- 🧰 **Disk Cleanup Tool** — Executes `cleanmgr /sagerun:1`  
- 📊 **Disk Report** — Logs free and total space for each disk  

---

## 🧾 Log Output

- **Log Folder:** `C:\temp\Disk_Space_Cleanup`  
- **Log Format:** `MM-dd-yyyy_Disk_Space_Cleanup.log`  
- Each step logs a timestamped entry indicating:
  - `Starting`
  - `Completed`
  - `Failed`


## ⚙️ Configuration

The script is controlled by string flags at the top of the file:

```powershell
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
```

| Flag                      | Description                                    |
| ------------------------- | ---------------------------------------------- |
| `$DoTemp`                 | Clean TEMP folders                             |
| `$DoWindowsUpdate`        | Clear Windows Update cache                     |
| `$DoWindowsOld`           | Remove `Windows.old` and reset component store |
| `$DoRecycleBin`           | Empty the recycle bin                          |
| `$DoPrefetch`             | Delete old prefetch files                      |
| `$DoDeliveryOptimization` | Clear Delivery Optimization cache              |
| `$DoBranchCache`          | Clear BranchCache                              |
| `$DoHibernation`          | Disable hibernation and remove `hiberfil.sys`  |
| `$DoFlushDNS`             | Flush DNS resolver cache                       |
| `$DoIISLogs`              | Remove IIS and system logs                     |
| `$DoComponentCleanup`     | DISM component store cleanup                   |
| `$DoOldUserProfiles`      | Delete profiles not used in 180+ days          |
| `$DoDiskCleanupTool`      | Run `cleanmgr /sagerun:1`                      |
| `$DoDiskReport`           | Log disk free/total space to the cleanup log   |

🛡️ Disclaimer
This script is provided “as-is” without warranty.
Please review and test in a safe environment before deploying in production.

Use at your own risk.
