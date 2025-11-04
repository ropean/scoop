# Scoop Bucket Update Workflow - Changes and Usage

## Key Changes

### 1. Fixed Shortcut Position Issue

**Before (INCORRECT):**

```yaml
# shortcut_description was in position 2 (startup args position)
{ 'shortcuts': [[$exe, $name, $desc]] }
```

**After (CORRECT):**

```yaml
# Now properly positioned at position 4 (description position)
{ 'shortcuts': [[$exe, $name, $args, $icon, $desc]] }
```

### 2. Added New Optional Inputs

```yaml
shortcut_args:
  description: 'Startup arguments for the shortcut (optional)'
  required: false
  type: string
  default: ''

shortcut_icon:
  description: 'Icon file path for the shortcut (optional)'
  required: false
  type: string
  default: ''
```

### 3. Scoop Shortcuts Array Format

```json
"shortcuts": [
  [
    "app.exe",           // Position 0: Executable name (required)
    "App Name",          // Position 1: Shortcut display name (required)
    "--flag",            // Position 2: Startup arguments (optional)
    "icon.ico",          // Position 3: Icon file path (optional)
    "Description text"   // Position 4: Description/tooltip (optional)
  ]
]
```

## Usage Examples

### Example 1: Basic Shortcut (No Args, No Icon)

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    tag: v1.0.0
    source_repo: ropean/MyApp
    app_name: myapp
    exe_name: MyApp.exe
    shortcut_name: 'My Application'
    shortcut_description: 'A cool application'
```

**Generated shortcuts:**

```json
"shortcuts": [["MyApp.exe", "My Application", "", "", "A cool application"]]
```

### Example 2: With Startup Arguments

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    tag: v1.0.0
    source_repo: ropean/peek
    app_name: peek
    exe_name: peek-windows-x64.exe
    shortcut_name: 'Peek HTTP Inspector'
    shortcut_args: '--port 8080 --debug'
    shortcut_description: 'HTTP inspector tool with debug mode'
```

**Generated shortcuts:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek HTTP Inspector", "--port 8080 --debug", "", "HTTP inspector tool with debug mode"]]
```

### Example 3: With Custom Icon

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    tag: v1.0.0
    source_repo: ropean/MyApp
    app_name: myapp
    exe_name: MyApp.exe
    shortcut_name: 'My Application'
    shortcut_icon: 'myapp.ico'
    shortcut_description: 'My awesome app'
```

**Generated shortcuts:**

```json
"shortcuts": [["MyApp.exe", "My Application", "", "myapp.ico", "My awesome app"]]
```

### Example 4: Complete Configuration

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    tag: v1.2.3
    source_repo: ropean/MyApp
    app_name: myapp
    exe_name: MyApp.exe
    description: 'A powerful application'
    homepage: 'https://myapp.example.com'
    shortcut_name: 'My Application Pro'
    shortcut_args: '--config production'
    shortcut_icon: 'app-icon.ico'
    shortcut_description: 'Professional version of My Application'
    notes: 'Run with administrator privileges for full features'
  secrets:
    deploy_key: ${{ secrets.SCOOP_DEPLOY_KEY }}
```

**Generated shortcuts:**

```json
"shortcuts": [["MyApp.exe", "My Application Pro", "--config production", "app-icon.ico", "Professional version of My Application"]]
```

### Example 5: No Shortcuts (Skip Shortcut Creation)

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    tag: v1.0.0
    source_repo: ropean/cli-tool
    app_name: mytool
    exe_name: mytool.exe
    # Don't provide shortcut_name - no shortcuts will be created
```

**Result:** No `shortcuts` field in manifest (suitable for CLI tools).

## Important Notes

1. **Minimum Required**: Only `shortcut_name` is needed to create shortcuts
2. **Empty Strings**: Empty optional fields will be included as empty strings `""`
3. **Conditional Logic**: Shortcuts are only added if `shortcut_name` is provided
4. **Array Format**: All 5 positions are always included when shortcuts are created

## Troubleshooting

### Issue: CMD Window Appears and Closes

**Solution:** Add this to your Rust `main.rs`:

```rust
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
```

### Issue: Shortcut Description Not Showing

**Verify** the manifest has the correct format:

```json
"shortcuts": [["app.exe", "Name", "args", "icon", "description"]]
```

Position 4 should contain your description text.
