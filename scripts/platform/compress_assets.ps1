Add-Type -AssemblyName System.Drawing

$root = Join-Path (Split-Path -Parent $PSScriptRoot) "assets"

function Save-Png($bitmap, $path) {
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

function Draw-BrandMark($g, $bounds, [System.Drawing.Color]$primary, [System.Drawing.Color]$secondary, [switch]$White) {
    $cx = $bounds.X + $bounds.Width / 2
    $cy = $bounds.Y + $bounds.Height / 2
    $size = [Math]::Min($bounds.Width, $bounds.Height) * 0.55
    $crossColor = if ($White) { [System.Drawing.Color]::White } else { $primary }
    $pulseColor = if ($White) { [System.Drawing.Color]::FromArgb(220, 255, 255, 255) } else { $secondary }

    $penCross = New-Object System.Drawing.Pen($crossColor, ($size * 0.12))
    $penCross.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penCross.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($penCross, $cx - $size * 0.22, $cy, $cx + $size * 0.22, $cy)
    $g.DrawLine($penCross, $cx, $cy - $size * 0.22, $cx, $cy + $size * 0.22)

    $penPulse = New-Object System.Drawing.Pen($pulseColor, ($size * 0.08))
    $penPulse.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $penPulse.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $points = @(
        [System.Drawing.PointF]::new($cx - $size * 0.42, $cy + $size * 0.08),
        [System.Drawing.PointF]::new($cx - $size * 0.18, $cy - $size * 0.18),
        [System.Drawing.PointF]::new($cx - $size * 0.02, $cy + $size * 0.02),
        [System.Drawing.PointF]::new($cx + $size * 0.12, $cy - $size * 0.28),
        [System.Drawing.PointF]::new($cx + $size * 0.42, $cy + $size * 0.08)
    )
    $g.DrawLines($penPulse, $points)
}

function Resize-ImageFile($source, $width, $height, $quality = 78, [switch]$Png) {
    $img = [System.Drawing.Image]::FromFile($source)
    $dest = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.DrawImage($img, 0, 0, $width, $height)
    $g.Dispose()
    $img.Dispose()

    if ($Png) {
        $dest.Save($source, [System.Drawing.Imaging.ImageFormat]::Png)
    } else {
        $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
            Where-Object { $_.MimeType -eq 'image/jpeg' }
        $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
            [System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
        $dest.Save($source, $encoder, $params)
    }
    $dest.Dispose()
}

$providerPhotos = @(
    @{ Path = "images\providers\doctor_african.jpg"; W = 1024; H = 1024 },
    @{ Path = "images\providers\doctor_2.jpg"; W = 1024; H = 1024 },
    @{ Path = "images\providers\doctor_1.jpg"; W = 1024; H = 1024 },
    @{ Path = "images\providers\doctor_3.jpg"; W = 1024; H = 1024 },
    @{ Path = "images\providers\hospital_1.jpg"; W = 1600; H = 1000 }
)

foreach ($item in $providerPhotos) {
    $path = Join-Path $root $item.Path
    Resize-ImageFile $path $item.W $item.H 76
}

$onboarding = @(
    @{ File = "onboarding_1.png"; W = 1200; H = 1200 },
    @{ File = "onboarding_2.png"; W = 1200; H = 1200 },
    @{ File = "onboarding_3.png"; W = 1200; H = 1200 }
)
foreach ($item in $onboarding) {
    $path = Join-Path $root "images\onboarding\$($item.File)"
    if (-not (Test-Path $path)) { continue }
    $jpgPath = [System.IO.Path]::ChangeExtension($path, ".jpg")
    $img = [System.Drawing.Image]::FromFile($path)
    $dest = New-Object System.Drawing.Bitmap $item.W, $item.H
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.Clear([System.Drawing.Color]::White)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($img, 0, 0, $item.W, $item.H)
    $g.Dispose()
    $img.Dispose()
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [long]72)
    $dest.Save($jpgPath, $encoder, $params)
    $dest.Dispose()
    Remove-Item $path -Force
}

# Replace large AI app icon with lightweight vector mark.
$iconPath = Join-Path $root "icon\app_icon.png"
$iconBmp = New-Object System.Drawing.Bitmap 1024, 1024
$iconG = [System.Drawing.Graphics]::FromImage($iconBmp)
$iconG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$iconG.Clear([System.Drawing.Color]::Transparent)
Draw-BrandMark $iconG (New-Object System.Drawing.Rectangle 0, 0, 1024, 1024) `
    ([System.Drawing.Color]::FromArgb(255, 25, 118, 210)) `
    ([System.Drawing.Color]::FromArgb(255, 0, 137, 123))
Save-Png $iconBmp $iconPath

Write-Host "Compressed bundled raster assets."
