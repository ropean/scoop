## scoop-ropean

A Scoop bucket for Ropean's small Windows utilities.

### Install Scoop (if you don't have it)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

### Add this bucket

```powershell
scoop bucket add ropean https://github.com/ropean/windows-tools
```

### Install apps

```powershell
scoop install bestpwd
scoop install cssimagedownload
scoop install filesplit
scoop install httpstatus
scoop install music2sd
scoop install myexplorer
scoop install myhosts
scoop install suckcolor
```

### Upgrade

```powershell
scoop update             # update Scoop and buckets
scoop update <app>       # update a specific app
```

### Packages

- **bestpwd**: Password management utility
- **cssimagedownload**: Download images referenced in CSS
- **filesplit**: Split large files into smaller chunks
- **httpstatus**: Check HTTP status codes
- **music2sd**: Copy music to SD/removable devices
- **myexplorer**: Enhanced file explorer
- **myhosts**: Hosts file editor
- **suckcolor**: Color picker utility

### Versioning and updates

- Packages download release assets from `ropean/scoop-ropean` GitHub Releases (tags like `v1.0.0`).
- Manifests are configured with GitHub `checkver` and `autoupdate` so new releases are picked up automatically.

### Contributing

1. Open a PR that updates or adds a manifest in `bucket/`.
2. Publish a new GitHub Release with tag `vX.Y.Z` and attach the updated `.exe` assets.
3. Ensure SHA256 hashes in manifests match the uploaded assets.

### License

Proprietary. See `LICENSE.txt`.
