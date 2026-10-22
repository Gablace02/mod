param()

$locPath = "c:\Users\Gabriel\Desktop\mod\hoi4_mod\localisation\spanish\gemini_advisor_l_spanish.yml"
$content = [System.IO.File]::ReadAllText($locPath, [System.Text.Encoding]::UTF8)

# Write with UTF8 Encoding that includes BOM
$utf8WithBOM = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($locPath, $content, $utf8WithBOM)

Write-Host "UTF8_BOM_SUCCESS"
