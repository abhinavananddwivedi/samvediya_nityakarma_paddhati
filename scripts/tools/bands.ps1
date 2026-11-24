# Cut a page photo into $n overlapping horizontal bands (_b0.._b{n-1}), each up to $maxw px wide, for reading.
# Usage: .\bands.ps1 -page 24 [-n 5] [-y0 0.03 -y1 0.97] [-x0 0.03 -x1 0.97] [-maxw 2000] [-outdir dir]
param([int]$page, [int]$n = 5, [double]$y0 = 0.02, [double]$y1 = 0.98, [double]$x0 = 0.03, [double]$x1 = 0.97,
      [int]$maxw = 2000, [double]$overlap = 0.025, [string]$src = "", [string]$outdir = "$env:TEMP\babaji2_crops")
$s = Join-Path $PSScriptRoot "crop.ps1"
$p = "{0:D3}" -f $page
$h = ($y1 - $y0) / $n
for ($i = 0; $i -lt $n; $i++) {
  $a = [Math]::Max(0.0, $y0 + $i * $h - $overlap); $b = [Math]::Min(1.0, $y0 + ($i + 1) * $h + $overlap)
  & $s -page $p -y0 $a -y1 $b -x0 $x0 -x1 $x1 -maxw $maxw -tag ("_b" + $i) -src $src -outdir $outdir | Out-Null
}
"bands for p$p in $outdir"
