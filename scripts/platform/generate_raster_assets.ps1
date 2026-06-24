Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$iconDir = Join-Path $root "assets\icon"
$placeholderDir = Join-Path $root "assets\images\placeholders"

function Save-Png($bitmap, $path) {
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

function Save-Jpeg($bitmap, $path, $quality = 85) {
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq 'image/jpeg' }
    $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    $bitmap.Save($path, $encoder, $params)
    $bitmap.Dispose()
}

function New-LinearGradientBrush($rect, $c1, $c2) {
    return New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect, $c1, $c2, [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
}

function New-SolidBrush($a, $r, $g, $b) {
    return New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($a, $r, $g, $b))
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

$silhouette = New-SolidBrush 180 176 190 197

$avatar = New-Object System.Drawing.Bitmap 512, 512
$ag = [System.Drawing.Graphics]::FromImage($avatar)
$ag.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$ag.Clear([System.Drawing.Color]::FromArgb(255, 236, 239, 241))
$headRect = New-Object System.Drawing.Rectangle 186, 120, 140, 140
$ag.FillEllipse($silhouette, $headRect)
$bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$bodyPath.AddArc(136, 250, 240, 120, 0, 180)
$bodyPath.AddLine(136, 310, 376, 310)
$bodyPath.AddLine(376, 440, 136, 440)
$ag.FillPath($silhouette, $bodyPath)
Save-Png $avatar (Join-Path $placeholderDir "avatar_placeholder.png")

$provider = New-Object System.Drawing.Bitmap 1024, 1024
$pg = [System.Drawing.Graphics]::FromImage($provider)
$rect = New-Object System.Drawing.Rectangle 0, 0, 1024, 1024
$brush = New-LinearGradientBrush $rect ([System.Drawing.Color]::FromArgb(255, 25, 118, 210)) ([System.Drawing.Color]::FromArgb(255, 0, 137, 123))
$pg.FillRectangle($brush, $rect)
$brush.Dispose()
$pg.FillEllipse((New-SolidBrush 40 255 255 255), (New-Object System.Drawing.Rectangle 312, 312, 400, 400))
Save-Jpeg $provider (Join-Path $placeholderDir "provider_placeholder.jpg") 80

$fg = New-Object System.Drawing.Bitmap 432, 432
$fgG = [System.Drawing.Graphics]::FromImage($fg)
$fgG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$fgG.Clear([System.Drawing.Color]::Transparent)
Draw-BrandMark $fgG (New-Object System.Drawing.Rectangle 0, 0, 432, 432) `
    ([System.Drawing.Color]::FromArgb(255, 25, 118, 210)) `
    ([System.Drawing.Color]::FromArgb(255, 0, 137, 123))
Save-Png $fg (Join-Path $iconDir "app_icon_foreground.png")

$splash = New-Object System.Drawing.Bitmap 512, 512
$sg = [System.Drawing.Graphics]::FromImage($splash)
$sg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$sg.Clear([System.Drawing.Color]::Transparent)
Draw-BrandMark $sg (New-Object System.Drawing.Rectangle 0, 0, 512, 512) `
    ([System.Drawing.Color]::White) ([System.Drawing.Color]::White) -White
Save-Png $splash (Join-Path $iconDir "splash_logo.png")

Write-Host "Raster utility assets generated."
