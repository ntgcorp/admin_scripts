This suite consists of two minimal and optimized Bash scripts designed to be executed within Live Linux environments (such as GParted Live). They allow smart backup and restoration of system partitions (including Windows NTFS) by skipping unallocated free space and applying dynamic compression.

Official documentation and updates: [http://ntgcorp.it/admin_scripts](https://github.com/ntgcorp/admin_scripts/)

---

## 💾 1. Backup: `ntjobs_partclone_backup.sh`

This script analyzes the file system of the specified partition, backs up only the used data blocks (ignoring the empty space on the disk), compresses the data stream on the fly, and saves it into an image file inside the destination folder.

### Execution Syntax
```bash
sudo ./ntjobs_partclone_backup.sh <source_partition> <destination_folder> <compression_level>
```

### Practical Example
```bash
sudo ./ntjobs_partclone_backup.sh /dev/sda1 /mnt/usb_storage 6
```

### 📊 Compression Levels Guide (gzip)
The script strictly requires an integer from **1 to 9** as the third parameter:
* **`1`** : Fastest speed, lowest compression (largest final file size).
* **`2 - 3`** : Light compression. Ideal for older or low-spec processors.
* **`4 - 5`** : Balanced compromise between CPU load and saved storage space.
* **`6`** : **[Recommended]** Default standard. Offers the best speed-to-size ratio.
* **`7 - 8`** : High compression. Demands more computing resources and time.
* **`9`** : Maximum compression. Generates the smallest possible file, but the process is very slow.

### Output Naming Convention
The final file is automatically named using the following schema:  
`backup_[FSTYPE]_[PARTITION_NAME]_[DATE_TIME].img.gz`  
*(Example: `backup_ntfs_sda1_20260609_193000.img.gz`)*

---

## 🔄 2. Restore: `ntjobs_partclone_restore.sh`

This script performs the reverse process. It decompresses the generated backup file on the fly and streams it directly to the target partition, overwriting and formatting it completely.

### ⚠️ Critical Safety Warning
Restoration is a **highly destructive operation**. The script includes a security prompt that strictly requires the user to type **`SI`** (in uppercase) before proceeding with the target disk overwrite.

### Execution Syntax
```bash
sudo ./ntjobs_partclone_restore.sh <compressed_backup_file> <target_partition>
```

### Practical Example
```bash
sudo ./ntjobs_partclone_restore.sh /mnt/usb_storage/backup_ntfs_sda1_20260609_193000.img.gz /dev/sda1
```

---

## 🚀 3. How to Create the Bootable USB Drive

You can easily build a minimal, dedicated live USB environment using Rufus and GParted Live (which natively includes `partclone`, `gzip`, and full exFAT/FAT32 support).

### Step-by-Step Guide
1. **Download GParted Live**: Download the stable `.iso` file from the official GParted website (choose the **amd64** version for modern 64-bit PCs).
2. **Configure Rufus**: Insert your USB flash drive into a Windows PC and open Rufus.
   * **Device**: Select your USB flash drive.
   * **Boot selection**: Click *Select* and choose the downloaded GParted Live ISO file.
   * **Partition scheme**: Choose **MBR** (for maximum universal compatibility with older BIOS and newer UEFI systems) or **GPT** (for modern UEFI-only setups).
   * **File system**: Select **exFAT**. This allows you to store backup files larger than 4GB directly on the same bootable USB drive (if it has enough capacity).
3. **Flash the Drive**: Click **Start**. If prompted by Rufus, select **Write in ISO Image mode (Recommended)**. Confirm formatting and wait for completion.

### Adding the Scripts to the USB
Once Rufus finishes, the USB drive remains accessible as a standard external drive in Windows:
1. Create a folder named `ntjobs` in the root of the USB drive.
2. Copy the files `ntjobs_partclone_backup.sh`, `ntjobs_partclone_restore.sh`, and this `ntjobs_partclone_readme.md` file into that folder.

---

## 📋 Running the Scripts in the Live Environment

1. Boot the target PC from the created USB drive (usually by pressing F12, F11, or F8 at startup to open the Boot Menu).
2. Once GParted Live loads, open the terminal window.
3. Access your scripts folder. In GParted Live, the bootable USB drive is automatically mounted. You can navigate to it by running:
   ```bash
   cd /lib/live/mount/medium/ntjobs/
   ```
   *(Note: If not found there, check `/run/live/medium/ntjobs/`)*
4. Make sure the scripts have execution privileges:
   ```bash
   chmod +x *.sh
   ```
5. Run your desired script using `sudo`.

---

## 💡 Pro-Tip for Windows (NTFS) Backups
To maximize compression efficiency and speed, boot into Windows before running the backup script. Open a Command Prompt as Administrator and use the official Microsoft **SDelete** utility to zero out deleted file fragments:
```cmd
sdelete64.exe -z C:
```

For more info, troubleshooting, and updates, visit: http://www.ntgcorp.it

## 💾 11. setres: `ntsetres.ps1`
Setting Resolution using command line
