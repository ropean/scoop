# Update Scoop Bucket (Call) Workflow

This workflow is designed to automatically update Scoop bucket manifests when a new release is published. It can be called from other repositories to update their corresponding Scoop package entries.

## Overview

The workflow downloads release assets from a source repository, calculates their SHA256 hash, and updates the Scoop bucket manifest files in the `ropean/scoop` repository.

## Features

- **Public and Private Repository Support**: Works with both public and private source repositories
- **Automatic Version Management**: Backs up previous versions and maintains version history
- **Flexible Configuration**: Supports various package metadata and shortcuts
- **Secure Authentication**: Uses deploy keys for pushing changes and optional tokens for private repos

## Usage

### Basic Example

```yaml
name: Update Scoop Bucket

on:
  workflow_run:
    workflows: ['Build and Release']
    types:
      - completed

jobs:
  update-scoop:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    uses: ropean/scoop/.github/workflows/update-scoop-call.yml@main
    with:
      tag: ${{ github.event.workflow_run.head_branch }}
      app_name: 'myhosts'
      exe_name: 'MyHosts.exe'
      source_repo: ${{ github.repository }}
      description: 'Hosts file editor utility for Windows'
      homepage: 'https://github.com/ropean/MyHosts'
      license_identifier: 'MIT'
      license_url: 'https://github.com/ropean/MyHosts/blob/main/LICENSE'
      shortcut_name: 'MyHosts'
      shortcut_description: 'Hosts file editor'
      notes: 'MyHosts is a utility that helps you edit and manage the Windows hosts file for network configuration and blocking.'
    secrets:
      deploy_key: ${{ secrets.SCOOP_ROPEAN_DEPLOY_KEY }}
```

### Private Repository Example

For private source repositories, add the `source_repo_token` secret:

```yaml
secrets:
  deploy_key: ${{ secrets.SCOOP_ROPEAN_DEPLOY_KEY }}
  source_repo_token: ${{ secrets.GITHUB_TOKEN }} # or your custom token
```

## Input Parameters

### Required Inputs

| Parameter     | Type   | Description                              | Example          |
| ------------- | ------ | ---------------------------------------- | ---------------- |
| `tag`         | string | Release tag (e.g., v1.2.3)               | `v1.0.0`         |
| `source_repo` | string | Source repository (e.g., ropean/MyHosts) | `ropean/MyHosts` |
| `app_name`    | string | App name for Scoop (e.g., myhosts)       | `myhosts`        |
| `exe_name`    | string | Executable name (e.g., MyHosts.exe)      | `MyHosts.exe`    |

### Optional Inputs

| Parameter              | Type   | Default                                              | Description                      |
| ---------------------- | ------ | ---------------------------------------------------- | -------------------------------- |
| `description`          | string | `A simple hosts file editor`                         | App description                  |
| `homepage`             | string | `https://github.com/{source_repo}`                   | Homepage URL                     |
| `license_identifier`   | string | `MIT`                                                | License identifier               |
| `license_url`          | string | `https://github.com/{source_repo}/blob/main/LICENSE` | License URL                      |
| `shortcut_name`        | string | `{app_name}`                                         | Shortcut display name            |
| `shortcut_description` | string | ``                                                   | Shortcut description             |
| `notes`                | string | ``                                                   | Additional notes for the package |

## Secrets

### Required Secrets

| Secret       | Description                                                              |
| ------------ | ------------------------------------------------------------------------ |
| `deploy_key` | Deploy key for pushing changes to https://github.com/ropean/scoop |

### Optional Secrets

| Secret              | Description                                                                         |
| ------------------- | ----------------------------------------------------------------------------------- |
| `source_repo_token` | GitHub App or CI token for accessing source repository (required for private repos) |

## How It Works

### 1. Version Extraction

- Extracts version number from the tag (removes 'v' prefix)
- Sets up default values for optional parameters

### 2. Asset Download

- Downloads the release asset from the source repository
- Uses token authentication for private repositories
- Works with both public and private repositories

### 3. Hash Calculation

- Calculates SHA256 hash of the downloaded executable
- Used for Scoop manifest integrity verification

### 4. Repository Setup

- Sets up SSH deploy key for pushing to target repository
- Checks out the `ropean/scoop` repository

### 5. Manifest Management

- **Backup**: Backs up existing manifest with current version suffix
- **Update**: Creates new manifest with latest version
- **Version History**: Maintains previous versions as backups

### 6. Commit and Push

- Commits changes with detailed commit message
- Pushes to the main branch of `ropean/scoop`

## File Structure

After running, the following files are created/updated:

```
bucket/
├── myhosts.json                    # Latest version manifest
├── myhosts@0.0.4.json             # Previous version backup (if version changed)
└── myhosts@0.0.5.json             # Another previous version backup
```

## Manifest Format

The generated manifest follows the Scoop bucket format:

```json
{
  "version": "1.0.0",
  "description": "Hosts file editor utility for Windows",
  "homepage": "https://github.com/ropean/MyHosts",
  "license": {
    "identifier": "MIT",
    "url": "https://github.com/ropean/MyHosts/blob/main/LICENSE"
  },
  "url": "https://github.com/ropean/MyHosts/releases/download/1.0.0/MyHosts.exe",
  "hash": "sha256hash...",
  "bin": "MyHosts.exe",
  "shortcuts": [["MyHosts.exe", "MyHosts", "Hosts file editor"]],
  "notes": "MyHosts is a utility that helps you edit and manage the Windows hosts file...",
  "checkver": {
    "github": "ropean/MyHosts"
  },
  "autoupdate": {
    "url": "https://github.com/ropean/MyHosts/releases/download/v$version/MyHosts.exe"
  }
}
```

## Setup Requirements

### 1. Deploy Key Setup

- Generate an SSH key pair for the `ropean/scoop` repository
- Add the public key as a deploy key in `ropean/scoop` repository settings
- Add the private key as `SCOOP_ROPEAN_DEPLOY_KEY` secret in your source repository

### 2. Private Repository Setup (Optional)

- For private source repositories, add a GitHub token as `source_repo_token` secret
- The token needs access to the source repository's releases

### 3. Workflow Trigger

- Set up a workflow in your source repository that calls this workflow
- Typically triggered by successful releases or builds

## Error Handling

The workflow includes error handling for:

- Missing release assets
- Authentication failures
- Invalid manifest formats
- Git push failures

## Best Practices

1. **Version Tags**: Use semantic versioning with 'v' prefix (e.g., `v1.0.0`)
2. **Release Assets**: Ensure your release includes the executable file
3. **Testing**: Test the workflow with a pre-release first
4. **Monitoring**: Monitor workflow runs for any failures
5. **Documentation**: Keep your package description and notes up to date

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check that deploy key has write access to `ropean/scoop`
2. **Asset Not Found**: Verify the executable name matches the release asset
3. **Private Repo Access**: Ensure `source_repo_token` has proper permissions
4. **Version Conflicts**: Check that the tag format is correct (vX.Y.Z)

### Debug Information

The workflow provides detailed logging for each step, including:

- Version extraction details
- Download URLs and success status
- Hash calculations
- File creation/update information
- Commit details

## Contributing

To contribute to this workflow:

1. Test changes with a sample repository
2. Update documentation for any new parameters
3. Ensure backward compatibility
4. Follow the existing code style and structure
