param()

$src = "c:\Users\Gabriel\Desktop\mod\hoi4_mod"
$dest = "C:\Users\Gabriel\Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor"
$modFile = "C:\Users\Gabriel\Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor.mod"

if (Test-Path $dest) {
    Remove-Item -Recurse -Force $dest
}

Copy-Item -Recurse -Force $src $dest

$modContent = @"
version="1.0"
tags={
	"Gameplay"
	"Utilities"
}
name="HOI4 Asesor Estrategico - Gemini IA"
supported_version="1.*"
path="mod/gemini_advisor"
"@

Set-Content -Path $modFile -Value $modContent -Encoding UTF8
Write-Host "MOD_INSTALADO_CON_EXITO"
