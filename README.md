# cix-tigers-jfs
Set JoinFS variables files as required for 2-4-CIX Tigers.

This (currently) only works for the FSX and MSFS 2020 versions of JoinFS. Pull requests will be accepted to make it work for the XPlane version!

For the CIX Tiger Moth smoke system to work with JoinFS version 3.x, JoinFS needs a special "variables" file mapping for each Tiger Moth model/variation. This can (should?!) be done manually, but is a bit laborious so this repository attempts to simplify the process.

1. Close JoinFS

2. Copy `Plane-CixTigerMoth.txt` into `Documents\JoinFS-FSX\Variables` and/or `Documents\JoinFS-FS2020\Variables`

3. In PowerShell, run `.\Update-CixTigersJfsVariables.ps1` (run `help .\Update-CixTigersJfsVariables.ps1` for more options, but this isn't necessary)

The script will update a file `C:\Users\<username>\AppData\Local\JoinFS-FSX\variables.txt` and/or `C:\Users\<username>\AppData\Local\JoinFS-FS2020\variables.txt`. A backup is made first (backup filename includes date and time).

If you need to revert:

1. Close JoinFS

2. Go to `C:\Users\<username>\AppData\Local\JoinFS-FSX` or `C:\Users\<username>\AppData\Local\JoinFS-FS2020`

3. Replace `variables.txt` with whichever `variables.txt.xxxxxxxx-xxxxxx.backup` file you want to go back to

# Contributing
Please feel free to open issues/pull requests