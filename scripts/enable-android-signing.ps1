$ErrorActionPreference = 'Stop'
$gradlePath = Join-Path (Get-Location) 'android/app/build.gradle.kts'
$keyPropertiesPath = Join-Path (Get-Location) 'android/key.properties'

if (-not (Test-Path -LiteralPath $gradlePath)) {
    throw 'android/app/build.gradle.kts not found. Run flutter create --platforms=web,android . first.'
}
if (-not (Test-Path -LiteralPath $keyPropertiesPath)) {
    throw 'android/key.properties not found. Create it with your keystore path, alias, and passwords before running this script.'
}

$text = Get-Content -LiteralPath $gradlePath -Raw

$imports = "import java.io.FileInputStream`r`nimport java.util.Properties`r`n"
if ($text -notmatch '(?m)^import java\.io\.FileInputStream$') {
    $text = $imports + $text
}

$propertiesBlock = @'
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

'@
if ($text -notmatch 'val keystoreProperties = Properties\(\)') {
    $androidIndex = $text.IndexOf('android {')
    if ($androidIndex -lt 0) { throw 'Could not find the android { block in build.gradle.kts.' }
    $text = $text.Insert($androidIndex, $propertiesBlock)
}

$signingBlock = @'
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

'@
if ($text -notmatch 'create\("release"\)') {
    $buildTypesIndex = $text.IndexOf('    buildTypes {')
    if ($buildTypesIndex -lt 0) { throw 'Could not find buildTypes { inside android {.' }
    $text = $text.Insert($buildTypesIndex, $signingBlock)
}

# Flutter's generated template commonly signs release with the debug config.
$text = $text.Replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')

if ($text -notmatch 'signingConfig = signingConfigs.getByName\("release"\)') {
    throw 'A release signingConfig assignment was not found. Inspect build.gradle.kts and add signingConfig = signingConfigs.getByName("release") inside buildTypes { release { ... } }.'
}

Set-Content -LiteralPath $gradlePath -Value $text -Encoding utf8
Write-Host 'Android release signing configuration added.' -ForegroundColor Green
Write-Host 'Verify the generated Gradle file before running a release build.'
