# Crop a region of a page after rotating the whole page by -deg degrees (to level sloping lines).
# Usage: .\crop_rot.ps1 -page 049 -deg 6 -y0 0.2 -y1 0.5 [-x0 0 -x1 1] [-maxw 2000] [-tag _r] [-outdir dir]
param([string]$page, [double]$deg = 0, [double]$y0 = 0, [double]$y1 = 1, [double]$x0 = 0, [double]$x1 = 1,
      [int]$maxw = 2000, [string]$tag = "_r", [string]$outdir = "$env:TEMP\babaji2_crops")
Add-Type -AssemblyName System.Drawing
$src = Join-Path $PSScriptRoot "..\..\Images\pages\p$page.jpg"
New-Item -ItemType Directory -Force $outdir | Out-Null
$img = [System.Drawing.Bitmap]::FromFile((Resolve-Path $src))
$W = $img.Width; $H = $img.Height
$rot = New-Object System.Drawing.Bitmap -ArgumentList $W, $H
$g = [System.Drawing.Graphics]::FromImage($rot)
$g.Clear([System.Drawing.Color]::White)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TranslateTransform($W / 2, $H / 2); $g.RotateTransform(-$deg); $g.TranslateTransform(-$W / 2, -$H / 2)
$g.DrawImage($img, 0, 0, $W, $H); $g.Dispose(); $img.Dispose()
$rect = New-Object System.Drawing.Rectangle ([int]($x0*$W)), ([int]($y0*$H)), ([int](($x1-$x0)*$W)), ([int](($y1-$y0)*$H))
$c = $rot.Clone($rect, $rot.PixelFormat); $rot.Dispose()
$scale = [Math]::Min(1.0, $maxw / $c.Width)
$out = New-Object System.Drawing.Bitmap -ArgumentList ([int]($c.Width*$scale)), ([int]($c.Height*$scale))
$g2 = [System.Drawing.Graphics]::FromImage($out)
$g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g2.DrawImage($c, 0, 0, $out.Width, $out.Height)
$dst = Join-Path $outdir ("p" + $page + $tag + ".png")
$out.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose(); $out.Dispose(); $c.Dispose()
$dst
