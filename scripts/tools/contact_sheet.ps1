# Thumbnail contact sheet of Images/pages/pNNN.jpg, $from..$to, labelled.
# Usage: .\contact_sheet.ps1 -from 1 -to 24 -out sheet.png [-cols 6] [-tw 330]
param([int]$from, [int]$to, [string]$out, [int]$cols = 6, [int]$tw = 330, [string]$dir = "")
Add-Type -AssemblyName System.Drawing
if (-not $dir) { $dir = Join-Path $PSScriptRoot "..\..\Images\pages" }
$pages = $from..$to
$th = [int]($tw * 1.45)
$rows = [Math]::Ceiling($pages.Count / $cols)
$sheet = New-Object System.Drawing.Bitmap ($tw * $cols), (($th + 30) * $rows)
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::White)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$font = New-Object System.Drawing.Font "Arial", 16
$i = 0
foreach ($p in $pages) {
  $f = Join-Path $dir ("p{0:D3}.jpg" -f $p)
  $img = [System.Drawing.Bitmap]::FromFile((Resolve-Path $f))
  $s = [Math]::Min($tw / $img.Width, $th / $img.Height)
  $w = [int]($img.Width * $s); $h = [int]($img.Height * $s)
  $x = ($i % $cols) * $tw; $y = [Math]::Floor($i / $cols) * ($th + 30)
  $g.DrawImage($img, $x, $y + 30, $w, $h)
  $g.DrawString(("p{0:D3}" -f $p), $font, [System.Drawing.Brushes]::Red, $x + 5, $y + 3)
  $img.Dispose(); $i++
}
$sheet.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
"$out"
