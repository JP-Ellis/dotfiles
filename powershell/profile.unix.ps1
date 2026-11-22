#!/usr/bin/env pwsh

## Load Brew
################################################################################
if (Test-Path /opt/homebrew/bin/brew) {
    . ([scriptblock]::Create((& /opt/homebrew/bin/brew shellenv | Out-String)))
    [System.Environment]::SetEnvironmentVariable("DYLD_FALLBACK_LIBRARY_PATH", "$env:HOMEBREW_PREFIX/lib")
}

## SSH Socket from GPG Agent
################################################################################
if (-not $env:SSH_AUTH_SOCK -and (Get-Command gpgconf -ErrorAction SilentlyContinue)) {
    [System.Environment]::SetEnvironmentVariable("SSH_AUTH_SOCK", (& gpgconf --list-dirs agent-ssh-socket))
}

## Load environment variables from .config/environment.d
################################################################################
# $envDir = "$env:HOME/.config/environment.d"
# if (Test-Path $envDir) {
#     Get-ChildItem -Path $envDir -Filter *.conf | ForEach-Object {
#         $content = Get-Content -Path $_.FullName
#         foreach ($line in $content) {
#             if ($line -match '^\s*([^#\s][^=]*)\s*=\s*(.*)\s*$') {
#                 $name = $matches[1]
#                 $value = $matches[2]
#                 $value = $value -replace '\$(\w+)', {[System.Environment]::GetEnvironmentVariable("$_")}
#                 [System.Environment]::SetEnvironmentVariable($name, $evaluatedValue, [System.EnvironmentVariableTarget]::Process)
#             }
#         }
#     }
# }

## Paths
################################################################################
function Add-Path {
    param (
        [string]$pathVar,
        [string]$path,
        [switch]$append
    )

    $path = $path.TrimEnd('/')
    $sep = [System.IO.Path]::PathSeparator
    $expanded = [System.Environment]::GetEnvironmentVariable($pathVar)

    if ($expanded -notlike "*$path*") {
        if ($expanded) {
            if ($append) {
                $newPath = "$expanded$sep$path"
            }
            else {
                $newPath = "$path$sep$expanded"
            }
        }
        else {
            $newPath = $path
        }
        [System.Environment]::SetEnvironmentVariable($pathVar, $newPath)
    }
}

$dirs = @(
    "$env:HOME/.local",
    "/scratch/$env:USER/local",
    "/scratch/$env:SUSER/local",
    "$env:CARGO_HOME",
    "$env:HOME/.jenv/bin"
)

foreach ($dir in $dirs) {
    if (Test-Path "$dir/bin") {
        Add-Path -pathVar "PATH" -path "$dir/bin"
    }
    if (Test-Path "$dir/lib") {
        Add-Path -pathVar "LD_LIBRARY_PATH" -path "$dir/lib"
    }
}

## Podman and Docker
################################################################################
## If podman is installed and docker is not, alias docker to podman
if ((Get-Command podman -ErrorAction SilentlyContinue) -and -not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Set-Alias docker podman
    ## Only macOS runs podman inside a machine; Linux talks to the native socket.
    if ($IsMacOS) {
        [System.Environment]::SetEnvironmentVariable("DOCKER_HOST", (& podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}'))
    }
}
if ((Get-Command podman-compose -ErrorAction SilentlyContinue) -and -not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Set-Alias docker-compose podman-compose
}

################################################################################
## Interactive shell
################################################################################

if ([System.Console]::IsOutputRedirected -or ![Environment]::UserInteractive -or ([Environment]::GetCommandLineArgs() | Where-Object { $_ -ilike '-noni*' })) {
    return
}

## Github Copilot alias
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Set-Alias ?? 'gh copilot suggest -t shell'
    Set-Alias gh? 'gh copilot suggest -t gh'
    Set-Alias git? 'gh copilot suggest -t git'
}

# Load starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    . ([scriptblock]::Create((& starship init powershell --print-full-init | Out-String)))
}
