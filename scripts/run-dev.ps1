<#
  scripts/run-dev.ps1

  Lee un archivo de entorno (por defecto ../supabase.env relativo a este script),
  exporta las variables al entorno del proceso y ejecuta `flutter run` con
  --dart-define para SUPABASE_URL y SUPABASE_ANON_KEY.

  Uso:
    # Ejecutar con el supabase.env que esté en la raíz del repo
    .\scripts\run-dev.ps1

    # Proveer ruta alternativa al archivo de entorno
    .\scripts\run-dev.ps1 -EnvFile .\my.secrets.env

    # Pasar argumentos extra a flutter (por ejemplo, dispositivo)
    .\scripts\run-dev.ps1 -- -d emulator-5554

  Nota: No subas `supabase.env` al repositorio. Asegúrate de tener Flutter en PATH.
#>

param(
    [string]$EnvFile = (Join-Path $PSScriptRoot '..\supabase.env')
)

function Read-EnvFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Error "Archivo de entorno no encontrado: $Path"
        return $null
    }

    $lines = Get-Content $Path -ErrorAction Stop
    $pairs = @{}
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        if ($trimmed -eq '' -or $trimmed.StartsWith('#')) { continue }

        # Split en la primera '='
        $parts = $trimmed -split '=', 2
        if ($parts.Count -ne 2) { continue }
        $name = $parts[0].Trim()
        $value = $parts[1].Trim()
        # Some example env files may contain a leading space after '='; Trim above handles it
        if ($name -ne '') { $pairs[$name] = $value }
    }
    return $pairs
}

Write-Host "Leyendo archivo de entorno: $EnvFile"
$envPairs = Read-EnvFile -Path $EnvFile
if ($null -eq $envPairs) { exit 1 }

# Set environment variables for this process
foreach ($k in $envPairs.Keys) {
    $v = $envPairs[$k]
    Set-Item -Path Env:\$k -Value $v
}

if (-not $env:SUPABASE_URL -or -not $env:SUPABASE_ANON_KEY) {
    Write-Error "Faltan SUPABASE_URL o SUPABASE_ANON_KEY en $EnvFile"
    exit 1
}

# Mostrar información mínima para confirmar (no imprimir la key completa)
function Mask([string]$s, [int]$unmaskedStart=6, [int]$unmaskedEnd=4) {
    if (-not $s) { return '' }
    $len = $s.Length
    if ($len -le ($unmaskedStart + $unmaskedEnd)) { return ('*' * $len) }
    return $s.Substring(0,$unmaskedStart) + ('*' * ($len - $unmaskedStart - $unmaskedEnd)) + $s.Substring($len - $unmaskedEnd)
}

Write-Host "SUPABASE_URL: $(if ($env:SUPABASE_URL.Length -gt 80) { $env:SUPABASE_URL.Substring(0,80) + '...' } else { $env:SUPABASE_URL })"
Write-Host "SUPABASE_ANON_KEY: $(Mask $env:SUPABASE_ANON_KEY)"

# Construir argumentos para flutter run
$flutterArgs = @(
    'run',
    '--dart-define', "SUPABASE_URL=$($env:SUPABASE_URL)",
    '--dart-define', "SUPABASE_ANON_KEY=$($env:SUPABASE_ANON_KEY)"
)

# Añadir cualquier argumento extra pasado al script (PowerShell coloca los parámetros posicionales en $args)
if ($args.Count -gt 0) {
    $flutterArgs += $args
}

Write-Host "Ejecutando: flutter $($flutterArgs -join ' ')"

# Ejecutar flutter con los argumentos construidos
try {
    & flutter @flutterArgs
    $exit = $LASTEXITCODE
    exit $exit
} catch {
    Write-Error "Error al ejecutar flutter: $_"
    exit 1
}
