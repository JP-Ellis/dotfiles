## Environment Variable
########################################
# By default, system paths are first and user paths come next. We want to
# reverse that.
$Env:Path = $Env:Path -Split ';' | Sort-Object -Descending { ++$script:i } | Join-String -Separator ';'

## Add $HOME/.local/bin to path
if (Test-Path -Path $Folder) {
    $Env:Path = "$HOME\.local\bin;$Env:Path"
}

## Powershell Configuration
########################################
# Use `Tab` for completion
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Add `Ctrl+D` to exit
Set-PSReadlineKeyHandler -Key Ctrl+D -Function ViExit

## Starship
########################################

if (Get-Command "starship" -ErrorAction SilentlyContinue) {
    $Env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
    Invoke-Expression (&starship init powershell)
}
