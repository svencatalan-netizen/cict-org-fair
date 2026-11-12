$ErrorActionPreference = 'Stop'

function Set-TextFile([string]$Path, [string]$Text) {
    Set-Content -LiteralPath $Path -Value $Text -Encoding utf8
}

$webIndex = Join-Path (Get-Location) 'web/index.html'
$webManifest = Join-Path (Get-Location) 'web/manifest.json'
$androidManifest = Join-Path (Get-Location) 'android/app/src/main/AndroidManifest.xml'

foreach ($path in @($webIndex, $webManifest, $androidManifest)) {
    if (-not (Test-Path -LiteralPath $path)) {
        throw "Missing $path. First run: flutter create --platforms=web,android ."
    }
}

# web/index.html: browser title and iOS home-screen title.
$html = Get-Content -LiteralPath $webIndex -Raw
if ($html -match '(?is)<title>.*?</title>') {
    $html = [regex]::Replace($html, '(?is)<title>.*?</title>', '<title>CICT Org Fair</title>', 1)
} else {
    $html = $html.Replace('</head>', "  <title>CICT Org Fair</title>`r`n</head>")
}
$appleMeta = '<meta name="apple-mobile-web-app-title" content="CICT Org Fair">'
if ($html -match '(?is)<meta\s+name=["'']apple-mobile-web-app-title["''][^>]*>') {
    $html = [regex]::Replace($html, '(?is)<meta\s+name=["'']apple-mobile-web-app-title["''][^>]*>', $appleMeta, 1)
} else {
    $html = $html.Replace('</head>', "  $appleMeta`r`n</head>")
}
Set-TextFile $webIndex $html

# web/manifest.json: installable app metadata.
$manifest = Get-Content -LiteralPath $webManifest -Raw | ConvertFrom-Json
$manifest.name = 'CICT Org Fair'
$manifest.short_name = 'CICT Org Fair'
$manifest.description = 'Explore CICT organizations, fair events, schedules, and activities.'
Set-TextFile $webManifest ($manifest | ConvertTo-Json -Depth 20)

# Android manifest: app label and release INTERNET permission.
$android = Get-Content -LiteralPath $androidManifest -Raw
if ($android -match 'android:label="[^"]*"') {
    $android = [regex]::Replace($android, 'android:label="[^"]*"', 'android:label="CICT Org Fair"', 1)
} else {
    $android = [regex]::Replace($android, '<application\b', '<application android:label="CICT Org Fair"', 1)
}
if ($android -notmatch 'android\.permission\.INTERNET') {
    $permission = '    <uses-permission android:name="android.permission.INTERNET" />' + "`r`n"
    $android = [regex]::Replace($android, '(<manifest\b[^>]*>)', ('$1' + "`r`n" + $permission), 1)
}
Set-TextFile $androidManifest $android

Write-Host 'Updated web title, web manifest, Android label, and INTERNET permission.' -ForegroundColor Green
Write-Host 'Next: inspect the three files and continue with Android signing setup.'
