param()

$locPath = "C:\Users\Gabriel\Documents\Paradox Interactive\Hearts of Iron IV\mod\gemini_advisor\localisation\spanish\gemini_advisor_l_spanish.yml"
$content = [System.IO.File]::ReadAllText($locPath, [System.Text.Encoding]::UTF8)

$utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($locPath, $content, $utf8WithBOM)

Write-Host "TARGET_BOM_SUCCESS"
