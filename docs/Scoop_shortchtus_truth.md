# Scoop Shortcuts - The Truth

## ❌ Common Misconception

Many people think Scoop shortcuts support 5 positions including a description field. **This is WRONG.**

## ✅ The Reality (Based on Scoop Source Code)

According to Scoop's `lib/shortcuts.ps1` source code, shortcuts **ONLY support 4 positions**:

```
Position 0: Executable path (required)
Position 1: Shortcut name (required)
Position 2: Startup arguments (optional)
Position 3: Icon file path (optional)
Position 4: DOES NOT EXIST ❌
```

## Source Code Evidence

From `lib/shortcuts.ps1`:

```powershell
$target = $_.item(0)    # Position 0: exe
$name = $_.item(1)      # Position 1: name
if($_.length -ge 3) {
    $arguments = $_.item(2)  # Position 2: args
}
if($_.length -ge 4) {
    $icon = $_.item(3)       # Position 3: icon
}
# NO position 4 for description!
```

## Your Original Problem

```json
// ❌ WRONG - 5 positions
"shortcuts": [["peek-windows-x64.exe", "peek", "", "", "HTTP inspector"]]
//            position 0                position 1  2   3   4 (doesn't exist!)
```

The empty string at position 3 (icon) caused Scoop to fail with:

```
Creating shortcut for peek (peek-windows-x64.exe) failed:
Couldn't find icon C:\Users\Robot-X\scoop\apps\peek\current
```

## ✅ Correct Solutions

### Option 1: Minimal (Recommended for GUI Apps)

```json
"shortcuts": [["peek-windows-x64.exe", "Peek"]]
```

**Your workflow call:**

```yaml
shortcut_name: 'Peek'
# Don't set shortcut_args or shortcut_icon
```

### Option 2: With Arguments

```json
"shortcuts": [["peek-windows-x64.exe", "Peek Debug", "--debug"]]
```

**Your workflow call:**

```yaml
shortcut_name: 'Peek Debug'
shortcut_args: '--debug'
```

### Option 3: With Icon

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "", "peek.ico"]]
```

**Your workflow call:**

```yaml
shortcut_name: 'Peek'
shortcut_icon: 'peek.ico'
```

### Option 4: All Fields

```json
"shortcuts": [["peek-windows-x64.exe", "Peek", "--port 8080", "peek.ico"]]
```

**Your workflow call:**

```yaml
shortcut_name: 'Peek'
shortcut_args: '--port 8080'
shortcut_icon: 'peek.ico'
```

## For Your Peek App

Since you want a simple GUI shortcut without args or icon:

### Update your workflow call to:

```yaml
- uses: ropean/scoop/.github/workflows/update-scoop-call.yml@main
  with:
    # ... other parameters ...
    shortcut_name: 'Peek'
    # Remove or leave empty:
    # shortcut_args: ''
    # shortcut_icon: ''
    # shortcut_description: ''  # This doesn't exist in Scoop!
```

### This will generate:

```json
"shortcuts": [["peek-windows-x64.exe", "Peek"]]
```

**Clean, simple, and NO errors!** ✅

## Quick Fix for Current Installation

Manually edit `bucket/peek.json`:

**Change from:**

```json
"shortcuts": [["peek-windows-x64.exe", "peek", "", "", "HTTP inspector"]]
```

**To:**

```json
"shortcuts": [["peek-windows-x64.exe", "peek"]]
```

Then reinstall:

```bash
scoop uninstall peek
scoop install peek
```

## Important Notes

1. **Description doesn't exist** - If you want to add a description, use the `notes` field in the manifest (not in shortcuts)
2. **Empty strings cause problems** - Don't include empty "" for optional positions
3. **Icon must exist** - If you specify an icon path, the file must actually exist in the app directory
4. **Use minimal format** - For most GUI apps, just use `[exe, name]`

## Summary

- ❌ Scoop does NOT support shortcut descriptions (position 4)
- ✅ Only 4 positions: `[exe, name, args, icon]`
- ✅ Remove `shortcut_description` from your workflow
- ✅ Use minimal 2-position format for simple GUI apps
- ✅ Only include optional positions if you actually need them

The new workflow correctly handles this by intelligently creating only the positions you need!
