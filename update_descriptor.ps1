param()

$modPath = "C:\Users\Gabriel\Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor.mod"
$txt = @"
version="1.0"
tags={
	"Gameplay"
	"Utilities"
}
name="HOI4 Asesor Estrategico - Gemini IA"
supported_version="1.*"
path="mod/gemini_advisor/"
"@

Set-Content -Path $modPath -Value $txt
Write-Host "DESCRIPTOR_FIXED"
