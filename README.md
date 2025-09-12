# scoop

A Scoop bucket for Ropean's small Windows utilities.

## Quick Start

### Install Scoop (if you don't have it)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
```

### Add this bucket

```powershell
scoop bucket add ropean https://github.com/ropean/scoop
```

### Install apps

```cmd
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

```cmd
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

## Automated Updates

This bucket uses an automated workflow system to keep packages up to date:

- **Automatic Updates**: Packages are automatically updated when new releases are published
- **Version Management**: Previous versions are backed up and maintained
- **Public & Private Support**: Works with both public and private source repositories
- **Secure Authentication**: Uses deploy keys and optional tokens for secure access

### For Package Maintainers

If you want to add your package to this bucket, you can use the automated workflow:

1. **Set up the workflow** in your repository to call `ropean/scoop/.github/workflows/update-scoop-call.yml`
2. **Configure authentication** with the required deploy key
3. **Publish releases** with semantic versioning (e.g., `v1.0.0`)

See [update-scoop-call.yml.md](.github/workflows/update-scoop-call.yml.md) for detailed documentation.

### Versioning and Updates

- Packages download release assets from source repositories (tags like `v1.0.1`)
- Manifests are configured with GitHub `checkver` and `autoupdate` for automatic updates
- Previous versions are preserved as backups (e.g., `myhosts@0.0.4.json`)

## Contributing

### Adding New Packages

1. **Use the automated workflow** (recommended):

   - Set up the workflow in your source repository
   - Configure the required secrets and parameters
   - Publish releases with proper version tags

2. **Manual contribution**:
   - Open a PR that updates or adds a manifest in `bucket/`
   - Publish a new GitHub Release with tag `vX.Y.Z` and attach the updated `.exe` assets
   - Ensure SHA256 hashes in manifests match the uploaded assets

### Package Requirements

- Windows executable (`.exe` files)
- Semantic versioning with `v` prefix (e.g., `v1.0.0`)
- GitHub releases with attached assets
- Proper license and documentation

### License

Proprietary. See `LICENSE.txt`.
