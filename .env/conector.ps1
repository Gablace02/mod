# =========================================================================
# CONECTOR HOI4 -> SERVIDOR EXTENDIDO (http://127.0.0.1:5050)
# =========================================================================
$rootDir = $PSScriptRoot
$gameLog = Join-Path $env:USERPROFILE "Documents\Paradox Interactive\Hearts of Iron IV\logs\game.log"

$global:HOI4_Data = @{
    tag         = "Esperando..."
    date        = "Esperando..."
    civs        = "0"
    mils        = "0"
    docks       = "0"
    manpower    = "---"
    pp          = "---"
    stability   = "---"
    war_support = "---"
    divs        = "0"
    convoys     = "0"
    in_war      = "En Paz"
    fuel        = "Optimo"
    ideology    = "democratic"
    doctrine    = "Sin doctrina"
}

function Actualizar-Datos-Desde-Log {
    if (Test-Path $gameLog) {
        try {
            $lines = Get-Content $gameLog -Tail 40 -ErrorAction SilentlyContinue
            foreach ($line in $lines) {
                if ($line.Contains("|TAG=")) {
                    $parts = $line.Split('|')
                    foreach ($p in $parts) {
                        $p = $p.Trim()
                        if ($p.StartsWith("TAG=")) { $global:HOI4_Data.tag = $p.Substring(4).Trim() }
                        if ($p.StartsWith("Fecha=")) { $global:HOI4_Data.date = $p.Substring(6).Trim() }
                        if ($p.StartsWith("Civs=")) { $global:HOI4_Data.civs = ($p.Substring(5) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Mils=")) { $global:HOI4_Data.mils = ($p.Substring(5) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Astilleros=")) { $global:HOI4_Data.docks = ($p.Substring(11) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Manpower=")) { $global:HOI4_Data.manpower = ($p.Substring(9) -replace '\..*','').Trim() }
                        if ($p.StartsWith("PP=")) { $global:HOI4_Data.pp = ($p.Substring(3) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Divs=")) { $global:HOI4_Data.divs = ($p.Substring(5) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Convoys=")) { $global:HOI4_Data.convoys = ($p.Substring(8) -replace '\..*','').Trim() }
                        if ($p.StartsWith("Ideologia=")) { $global:HOI4_Data.ideology = $p.Substring(10).Trim() }

                        # Doctrina Militar Terrestre
                        if ($p.StartsWith("Doctrina=")) {
                            $docVal = ($p.Substring(9) -replace '\..*','').Trim()
                            if ($docVal -eq "1") { $global:HOI4_Data.doctrine = "Guerra de Movimiento" }
                            elseif ($docVal -eq "2") { $global:HOI4_Data.doctrine = "Superioridad de Fuego" }
                            elseif ($docVal -eq "3") { $global:HOI4_Data.doctrine = "Gran Batalla" }
                            elseif ($docVal -eq "4") { $global:HOI4_Data.doctrine = "Asalto Masivo" }
                            else { $global:HOI4_Data.doctrine = "Sin doctrina" }
                        }

                        # Estabilidad %
                        if ($p.StartsWith("Estabilidad=")) {
                            $raw = $p.Substring(12).Trim()
                            try {
                                $num = [double]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture)
                                $global:HOI4_Data.stability = "$([math]::Round($num * 100))%"
                            } catch { 
                                $global:HOI4_Data.stability = $raw 
                            }
                        }

                        # Apoyo Belico %
                        if ($p.StartsWith("ApoyoB=")) {
                            $raw = $p.Substring(7).Trim()
                            try {
                                $num = [double]::Parse($raw, [System.Globalization.CultureInfo]::InvariantCulture)
                                $global:HOI4_Data.war_support = "$([math]::Round($num * 100))%"
                            } catch { 
                                $global:HOI4_Data.war_support = $raw 
                            }
                        }

                        # Estado de Guerra
                        if ($p.StartsWith("Guerra=")) {
                            $val = ($p.Substring(7) -replace '\..*','').Trim()
                            if ($val -eq "1") {
                                $global:HOI4_Data.in_war = "En Guerra"
                            } else {
                                $global:HOI4_Data.in_war = "En Paz"
                            }
                        }

                        # Nivel de Combustible
                        if ($p.StartsWith("Combustible=")) {
                            $val = ($p.Substring(12) -replace '\..*','').Trim()
                            if ($val -eq "1") { 
                                $global:HOI4_Data.fuel = "Critico (<25%)" 
                            } elseif ($val -eq "2") { 
                                $global:HOI4_Data.fuel = "Moderado" 
                            } else { 
                                $global:HOI4_Data.fuel = "Optimo (>60%)" 
                            }
                        }
                    }
                    Write-Host "`n>>> [HOI4 -> WEB]: Telemetria Recibida ($($global:HOI4_Data.tag) - $($global:HOI4_Data.doctrine) - $($global:HOI4_Data.divs) Divs)" -ForegroundColor Green
                }
            }
        } catch {}
    }
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:5050/")
$listener.Start()

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  PUENTE HOI4 MODULAR ACTIVO EN: http://127.0.0.1:5050" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "Abriendo tu navegador..." -ForegroundColor White

Start-Process "http://127.0.0.1:5050/"

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response

    $path = $req.Url.AbsolutePath
    if ($path -eq "/") { $path = "/index.html" }

    if ($path -eq "/api/data") {
        Actualizar-Datos-Desde-Log
        $json = $global:HOI4_Data | ConvertTo-Json
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        $res.ContentType = "application/json; charset=utf-8"
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
        $res.Close()
        continue
    }

    $filePath = Join-Path $rootDir ($path.TrimStart('/'))
    if (Test-Path $filePath) {
        $ext = [System.IO.Path]::GetExtension($filePath)
        $mime = "text/plain"
        if ($ext -eq ".html") { $mime = "text/html; charset=utf-8" }
        elseif ($ext -eq ".css") { $mime = "text/css; charset=utf-8" }
        elseif ($ext -eq ".js") { $mime = "application/javascript; charset=utf-8" }

        $bytes = [System.IO.File]::ReadAllBytes($filePath)
        $res.ContentType = $mime
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
        $res.Close()
    } else {
        $res.StatusCode = 404
        $res.Close()
    }
}