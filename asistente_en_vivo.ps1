param(
    [string]$ApiKey = ""
)

$Host.UI.RawUI.WindowTitle = "HOI4 Asesor Estrategico - Asistente Gemini IA"

Clear-Host
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "       HOI4 - ASESOR ESTRATEGICO VIVO (GEMINI IA ASISTENTE)     " -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Tu asistente personal en tiempo real para Hearts of Iron IV   " -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$savesDir = Join-Path $env:USERPROFILE "Documents\Paradox Interactive\Hearts of Iron IV\save games"
$locFile = Join-Path $env:USERPROFILE "Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor\localisation\spanish\gemini_advisor_l_spanish.yml"

# Obtener API Key guardada
$keyFile = "c:\Users\Gabriel\Desktop\mod\gemini_key.txt"
if (-not $ApiKey -and (Test-Path $keyFile)) {
    $ApiKey = (Get-Content $keyFile -Raw).Trim()
}

if (-not $ApiKey) {
    Write-Host "Ingresa tu API Key de Gemini (o presiona Enter para usar modo sin conexion):" -ForegroundColor Yellow
    $ApiKey = Read-Host
    if ($ApiKey) {
        Set-Content -Path $keyFile -Value $ApiKey
    }
}

if ($ApiKey) {
    Write-Host "[OK] Gemini IA Conectado y listo." -ForegroundColor Green
} else {
    Write-Host "[MODO LOCAL] Consejero activo con base estrategica experta." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " ESCRIBE CUALQUIER PREGUNTA PARA TU ASESOR (o 'auto' para vigilar tu partida):" -ForegroundColor Cyan
Write-Host " Ejemplo: 'Como invado Francia?', 'Que tanques hago?', 'Ratio civil/mil'" -ForegroundColor Gray
Write-Host "----------------------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

function Consultar-Gemini([string]$prompt, [string]$key) {
    if (-not $key) {
        return "Estrategia recomendada: Asegura lineas de suministro, mantén superioridad aerea (70% cazas, 30% CAS) y ancho de combate de 21 o 30 con artilleria."
    }
    
    $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key"
    $body = @{
        system_instruction = @{ parts = @(@{ text = "Eres un Asesor Militar y Economico experto de Hearts of Iron IV (HOI4) en espanol. Responde de forma muy concisa, directa, estrategica y con pasos accionables. Maximo 120 palabras. Usa formato limpio sin caracteres extranos." }) }
        contents = @(@{ role = "user"; parts = @(@{ text = $prompt }) })
    } | ConvertTo-Json -Depth 5
    
    try {
        $res = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json" -TimeoutSec 10
        return $res.candidates[0].content.parts[0].text
    } catch {
        return "Atencion general: Balancea tus fabricas civiles a militares antes de entrar en conflicto activo."
    }
}

function Actualizar-VentanaJuego([string]$titulo, [string]$texto) {
    if (-not (Test-Path $locFile)) { return }
    $clean = $texto -replace '"', "'" -replace "`r`n", "\n" -replace "`n", "\n"
    
    $newLoc = @"
l_spanish:
 GEMINI_OPEN_TOOLTIP:0 "§HAbrir Asesor Estratégico Gemini IA§!\n§GAtajo: Ctrl + Shift + G§!\nConsulta a la inteligencia artificial cómo optimizar tu imperio en tiempo real."
 GEMINI_WINDOW_TITLE:0 "§HAsesor Estratégico Gemini IA§!"
 GEMINI_CHAT_DISPLAY_TEXT:0 "§T¡Consejo de tu Asesor!§!\n\n§YTema: $titulo§!\n\n$clean"

 GEMINI_BTN_INDUSTRY:0 "🏭 Optimizar Industria"
 GEMINI_BTN_INDUSTRY_TT:0 "§HAnalizar Industria y Producción§!\nRevisa tu ratio de fábricas civiles y militares para optimizar tu capacidad de guerra."

 GEMINI_BTN_TECH:0 "🔬 Focos e Investigación"
 GEMINI_BTN_TECH_TT:0 "§HConsultar Tecnología§!\nConsejos sobre qué investigar y qué focos nacionales elegir según el año actual."

 GEMINI_BTN_MILITARY:0 "🪖 Plantillas de División"
 GEMINI_BTN_MILITARY_TT:0 "§HConsultar Doctrina y División§!\nDiseños de plantillas de combate óptimas según tu equipamiento."

 GEMINI_BTN_RESOURCES:0 "⛏️ Gestión de Recursos"
 GEMINI_BTN_RESOURCES_TT:0 "§HDiagnosticar Recursos§!\nIdentifica carencias de petróleo, caucho o acero y cómo resolverlas."

 GEMINI_BTN_WAR:0 "⚡ Estrategia de Guerra"
 GEMINI_BTN_WAR_TT:0 "§HPlan General de Combate§!\nRecomendaciones para defender fronteras o invadir objetivos."

 gemini_advisor_category:0 "§HAsesor Estratégico Gemini IA§!"
 gemini_advisor_category_desc:0 "§YTu ayudante de Inteligencia Artificial para optimizar tu producción, divisiones, economía y focos en tiempo real.§!"
 gemini_ask_industry:0 "Optimizar Industria y Economía"
 gemini_ask_industry_desc:0 "Consulta a Gemini IA cómo balancear tus fábricas civiles vs militares."
 gemini_ask_tech:0 "Prioridad de Investigación y Focos"
 gemini_ask_tech_desc:0 "Solicita consejo sobre tecnologías e investigaciones nacionales prioritarias."
 gemini_ask_military:0 "Plantillas de División y Doctrina"
 gemini_ask_military_desc:0 "Pide recomendaciones de plantillas de combate eficaces."
 gemini_ask_general:0 "Diagnóstico Estratégico General"
 gemini_ask_general_desc:0 "Informe completo del estado de tu nación."
 gemini_advisor.ok:0 "Entendido, gracias Asesor."
 gemini_advisor.1.t:0 "Asesor Gemini: Optimización Industrial"
 gemini_advisor.1.d:0 "Regla de oro: Antes de 1938 construye únicamente Fábricas Civiles e Infraestructura al máximo."
 gemini_advisor.2.t:0 "Asesor Gemini: Investigación y Focos"
 gemini_advisor.2.d:0 "Prioridad absoluta: Herramientas Básicas y Construcción I/II de la rama de Industria."
 gemini_advisor.3.t:0 "Asesor Gemini: Diseño de Divisiones"
 gemini_advisor.3.d:0 "Plantilla estándar: 9 Infantería + 1 o 2 Artillería con Ingenieros y Antiaéreo."
 gemini_advisor.4.t:0 "Asesor Gemini: Diagnóstico General"
 gemini_advisor.4.d:0 "Estado General: Revisa reservas de petróleo y caucho para sostener la aviación."
"@

    $utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($locFile, $newLoc, $utf8WithBOM)
}

# Bucle interactivo del Asistente
while ($true) {
    Write-Host ""
    Write-Host "Pregunta al Asesor > " -ForegroundColor Yellow -NoNewline
    $inputUser = Read-Host
    
    if (-not $inputUser) { continue }
    if ($inputUser -eq "salir" -or $inputUser -eq "exit") { break }
    
    Write-Host "[Asesor]: Pensando analisis estrategico..." -ForegroundColor DarkGray
    $respuesta = Consultar-Gemini -prompt $inputUser -key $ApiKey
    
    Write-Host ""
    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    Write-Host $respuesta -ForegroundColor White
    Write-Host "---------------------------------------------------------" -ForegroundColor Green
    
    Actualizar-VentanaJuego -titulo "Respuesta en Vivo" -texto $respuesta
    Write-Host "-> Actualizado dentro de la ventana de HOI4 (Presiona Ctrl+Shift+G en el juego para leerlo)" -ForegroundColor Cyan
}
