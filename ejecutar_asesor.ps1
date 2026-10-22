param(
    [string]$ApiKey = ""
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   HOI4 - ASESOR ESTRATEGICO GEMINI IA (PUENTE EN VIVO)    " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$savesDir = Join-Path $env:USERPROFILE "Documents\Paradox Interactive\Hearts of Iron IV\save games"
$locFile = Join-Path $env:USERPROFILE "Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor\localisation\spanish\gemini_advisor_l_spanish.yml"

if (-not (Test-Path $savesDir)) {
    Write-Host "Directorio de saves no encontrado en: $savesDir" -ForegroundColor Red
}

Write-Host "Monitorizando saves de Hearts of Iron IV..." -ForegroundColor Green
Write-Host "Presiona Ctrl+C para detener el puente en cualquier momento." -ForegroundColor DarkGray
Write-Host ""

$lastSaveTime = [DateTime]::MinValue

while ($true) {
    Start-Sleep -Seconds 3
    if (Test-Path $savesDir) {
        $latestSave = Get-ChildItem -Path $savesDir -Filter *.hoi4 | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latestSave -and $latestSave.LastWriteTime -gt $lastSaveTime) {
            $lastSaveTime = $latestSave.LastWriteTime
            Write-Host "[NUEVO GUARDADO DETECTADO] $($latestSave.Name) ($($latestSave.LastWriteTime))" -ForegroundColor Cyan
            Write-Host "Procesando estado de la partida para Gemini IA..." -ForegroundColor Gray
        }
    }
}
