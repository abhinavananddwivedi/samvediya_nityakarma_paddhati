# Make web-sized JPEG copies for the site:
#   Images/pages/pNNN.jpg        -> Images/web/pNNN.jpg          (max 2000 px tall)
#   Images/figures/*.png|jpg     -> Images/web/figures/<name>.jpg (max 1600 px wide)
# Skips outputs that are newer than their source. Usage: .\make_web_images.ps1 [-force]
param([switch]$force)
Add-Type -AssemblyName System.Drawing
$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 84L
function Resize-One([string]$src, [string]$dst, [double]$maxW, [double]$maxH) {
  if ((Test-Path $dst) -and -not $force -and ((Get-Item $dst).LastWriteTime -gt (Get-Item $src).LastWriteTime)) { return }
  $img = [System.Drawing.Bitmap]::FromFile($src)
  $s = [Math]::Min(1.0, [Math]::Min($maxW / $img.Width, $maxH / $img.Height))
  $w = [int][Math]::Round($img.Width * $s); $h = [int][Math]::Round($img.Height * $s); $out = New-Object System.Drawing.Bitmap -ArgumentList $w, $h
  $g = [System.Drawing.Graphics]::FromImage($out)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $out.Width, $out.Height)
  $out.Save($dst, $codec, $ep); $g.Dispose(); $out.Dispose(); $img.Dispose()
  "wrote $dst"
}
$web = Join-Path $root "Images\web"; $wf = Join-Path $web "figures"
New-Item -ItemType Directory -Force $wf | Out-Null
Get-ChildItem (Join-Path $root "Images\pages") -Filter *.jpg | ForEach-Object { Resize-One $_.FullName (Join-Path $web $_.Name) 3000 2000 }
Get-ChildItem (Join-Path $root "Images\figures") -Include *.png, *.jpg -Recurse | ForEach-Object {
  Resize-One $_.FullName (Join-Path $wf ($_.BaseName + ".jpg")) 1600 2400 }

