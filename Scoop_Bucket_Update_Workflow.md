# Shortcuts Generation Examples

## How It Works Now

The script intelligently includes only the fields that have actual values, avoiding empty strings that cause Scoop errors.

## Generation Logic

```
IF shortcut_name is provided:
  Always include: [exe_name, shortcut_name]

  IF any of (args, icon, desc) has value:
    Add args (even if empty)

    IF icon OR desc has value:
      Add icon (even if empty)

      IF desc has value:
        Add desc
```

## Examples

### Example 1: Only Name (Your Current Case)

**Input:**

```yaml
shortcut_name: 'peek'
shortcut_args: ''
shortcut_icon: ''
shortcut_description: 'HTTP inspector'
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "peek", "", "", "HTTP inspector"]]
```

❌ **Problem:** Empty icon string causes Scoop to fail

**Fixed Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "peek", "", "HTTP inspector"]]
```

✅ **Better:** Skips icon position, only includes description

### Example 2: Name + Description Only

**Input:**

```yaml
shortcut_name: 'Peek'
shortcut_description: 'HTTP Inspector'
# No args, no icon
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "", "HTTP Inspector"]]
```

✅ Includes empty args because description exists

### Example 3: Name Only (Minimal)

**Input:**

```yaml
shortcut_name: 'Peek'
# No args, no icon, no description
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek"]]
```

✅ Cleanest format - only required fields

### Example 4: Name + Args

**Input:**

```yaml
shortcut_name: 'Peek Debug'
shortcut_args: '--debug --verbose'
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek Debug", "--debug --verbose"]]
```

✅ Includes args, stops there

### Example 5: Name + Args + Description

**Input:**

```yaml
shortcut_name: 'Peek Debug'
shortcut_args: '--debug'
shortcut_description: 'Debug mode'
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek Debug", "--debug", "", "Debug mode"]]
```

✅ Must include empty icon position because description exists

### Example 6: All Fields

**Input:**

```yaml
shortcut_name: 'Peek'
shortcut_args: '--port 8080'
shortcut_icon: 'peek.ico'
shortcut_description: 'HTTP Inspector'
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "--port 8080", "peek.ico", "HTTP Inspector"]]
```

✅ All 5 positions included

### Example 7: Name + Icon Only

**Input:**

```yaml
shortcut_name: 'Peek'
shortcut_icon: 'app.ico'
```

**Output:**

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "", "app.ico"]]
```

✅ Empty args included because icon exists

## Recommendation for Your Peek App

Since you want description but no icon, use:

```yaml
- uses: ./.github/workflows/update-scoop-bucket.yml
  with:
    # ... other inputs ...
    shortcut_name: 'Peek'
    shortcut_description: 'HTTP Inspector'
    # Don't set shortcut_icon at all, or leave it empty
```

This will generate:

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "", "HTTP Inspector"]]
```

No more "Couldn't find icon" error! 🎉

## Quick Fix for Your Current Installation

Manually edit your `peek.json` in the scoop bucket and change:

```json
"shortcuts": [["peek-windows-x64.exe", "peek", "", "", "HTTP inspector"]]
```

To:

```json
"shortcuts": [["peek-windows-x64.exe", "peek", "", "HTTP inspector"]]
```

Then reinstall:

```bash
scoop uninstall peek
scoop install peek
```
