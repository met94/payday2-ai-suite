<#
.SYNOPSIS
    Renders the AI Suite ModWorkshop thumbnail (512x512 PNG).

.DESCRIPTION
    Deterministic GDI+ drawing - no image model, no external assets. Run from
    anywhere; writes art\ai-suite-thumbnail.png next to this script.

    Design: dark flat background, white clown-mask glyph, bold "AI SUITE"
    wordmark, yellow rule and the four member names, red hazard stripes in the
    top-right corner.
#>
param(
    [int]$Size = 512,
    [string]$OutPath = ''
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$ArtDir = $PSScriptRoot
if (-not $OutPath) { $OutPath = Join-Path $ArtDir 'ai-suite-thumbnail.png' }

function Get-Font([string[]]$Names, [float]$Px, [System.Drawing.FontStyle]$Style) {
    foreach ($Name in $Names) {
        try {
            $Candidate = New-Object System.Drawing.Font($Name, $Px, $Style, [System.Drawing.GraphicsUnit]::Pixel)
            if ($Candidate.Name -eq $Name) { return $Candidate }
            $Candidate.Dispose()
        } catch { }
    }
    return New-Object System.Drawing.Font('Arial', $Px, $Style, [System.Drawing.GraphicsUnit]::Pixel)
}

$Bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
$G = [System.Drawing.Graphics]::FromImage($Bitmap)
$G.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$G.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$G.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$Bg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 18, 18, 20))
$White = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 240, 240, 242))
$Red = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 176, 30, 34))
$DarkRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 120, 20, 24))
$Yellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 235, 197, 76))
$Grey = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 130, 132, 138))
$Black = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 10, 10, 12))

$G.FillRectangle($Bg, 0, 0, $Size, $Size)

$Scale = $Size / 512.0

# Hazard stripes, top-right corner (clipped by a triangle so they read as a motif).
$Clip = New-Object System.Drawing.Drawing2D.GraphicsPath
$ClipPoints = [System.Drawing.Point[]]@(
    [System.Drawing.Point]::new([int]$Size, 0),
    [System.Drawing.Point]::new([int]$Size, [int](150 * $Scale)),
    [System.Drawing.Point]::new([int](320 * $Scale), 0)
)
$Clip.AddPolygon($ClipPoints)
$G.SetClip($Clip)
for ($i = 0; $i -lt 7; $i++) {
    $X = [int]((330 * $Scale) + ($i * 46 * $Scale))
    $Brush = if ($i % 2 -eq 0) { $Red } else { $DarkRed }
    $Points = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new($X, 0),
        [System.Drawing.Point]::new($X + 20, 0),
        [System.Drawing.Point]::new($X - 60, [int]$Size),
        [System.Drawing.Point]::new($X - 80, [int]$Size)
    )
    $G.FillPolygon($Brush, $Points)
}
$G.ResetClip()
$Clip.Dispose()

# Clown-mask glyph.
$MaskW = 132 * $Scale
$MaskH = 150 * $Scale
$MaskX = ($Size - $MaskW) / 2
$MaskY = 92 * $Scale
$MaskPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$MaskPath.AddBezier(
    [float]($MaskX), [float]($MaskY + $MaskH * 0.30),
    [float]($MaskX + $MaskW * 0.02), [float]($MaskY),
    [float]($MaskX + $MaskW * 0.30), [float]($MaskY - $MaskH * 0.06),
    [float]($MaskX + $MaskW * 0.50), [float]($MaskY - $MaskH * 0.06)
)
$MaskPath.AddBezier(
    [float]($MaskX + $MaskW * 0.50), [float]($MaskY - $MaskH * 0.06),
    [float]($MaskX + $MaskW * 0.70), [float]($MaskY - $MaskH * 0.06),
    [float]($MaskX + $MaskW * 0.98), [float]($MaskY),
    [float]($MaskX + $MaskW), [float]($MaskY + $MaskH * 0.30)
)
$MaskPath.AddBezier(
    [float]($MaskX + $MaskW), [float]($MaskY + $MaskH * 0.30),
    [float]($MaskX + $MaskW), [float]($MaskY + $MaskH * 0.72),
    [float]($MaskX + $MaskW * 0.78), [float]($MaskY + $MaskH),
    [float]($MaskX + $MaskW * 0.50), [float]($MaskY + $MaskH)
)
$MaskPath.AddBezier(
    [float]($MaskX + $MaskW * 0.50), [float]($MaskY + $MaskH),
    [float]($MaskX + $MaskW * 0.22), [float]($MaskY + $MaskH),
    [float]($MaskX), [float]($MaskY + $MaskH * 0.72),
    [float]($MaskX), [float]($MaskY + $MaskH * 0.30)
)
$MaskPath.CloseFigure()
$G.FillPath($White, $MaskPath)

# Eyes.
$EyeW = 34 * $Scale
$EyeH = 24 * $Scale
$EyeY = $MaskY + (52 * $Scale)
$G.FillEllipse($Black, [float]($MaskX + (24 * $Scale)), [float]$EyeY, [float]$EyeW, [float]$EyeH)
$G.FillEllipse($Black, [float]($MaskX + $MaskW - $EyeW - (24 * $Scale)), [float]$EyeY, [float]$EyeW, [float]$EyeH)

# Red mouth bar.
$G.FillRectangle(
    $Red,
    [float]($MaskX + ($MaskW * 0.33)),
    [float]($MaskY + (98 * $Scale)),
    [float]($MaskW * 0.34),
    [float](14 * $Scale)
)
$MaskPath.Dispose()

# Wordmark.
$TitleFont = Get-Font @('Arial Black', 'Arial Bold', 'Impact', 'Arial') (68 * $Scale) ([System.Drawing.FontStyle]::Bold)
$Title = 'AI SUITE'
$TitleFmt = New-Object System.Drawing.StringFormat
$TitleFmt.Alignment = [System.Drawing.StringAlignment]::Center
$TitleRect = New-Object System.Drawing.RectangleF(0, [float](258 * $Scale), [float]$Size, [float](90 * $Scale))
$G.DrawString($Title, $TitleFont, $White, $TitleRect, $TitleFmt)
$TitleFont.Dispose()

# Yellow rule.
$RuleW = 250 * $Scale
$G.FillRectangle($Yellow, [float](($Size - $RuleW) / 2), [float](350 * $Scale), [float]$RuleW, [float](4 * $Scale))

# Member names.
$SubFont = Get-Font @('Arial', 'Segoe UI', 'Tahoma') (17 * $Scale) ([System.Drawing.FontStyle]::Bold)
$Dot = [string][char]0x00B7
$Sub = "LIES $Dot ITER $Dot KEEPERS $Dot MONKEEPERS"
$SubFmt = New-Object System.Drawing.StringFormat
$SubFmt.Alignment = [System.Drawing.StringAlignment]::Center
$SubRect = New-Object System.Drawing.RectangleF(0, [float](366 * $Scale), [float]$Size, [float](34 * $Scale))
$G.DrawString($Sub, $SubFont, $Yellow, $SubRect, $SubFmt)
$SubFont.Dispose()

# Footer.
$FootFont = Get-Font @('Arial', 'Segoe UI', 'Tahoma') (14 * $Scale) ([System.Drawing.FontStyle]::Regular)
$Foot = 'PAYDAY 2   |   248.2 x64'
$FootFmt = New-Object System.Drawing.StringFormat
$FootFmt.Alignment = [System.Drawing.StringAlignment]::Center
$FootRect = New-Object System.Drawing.RectangleF(0, [float](448 * $Scale), [float]$Size, [float](28 * $Scale))
$G.DrawString($Foot, $FootFont, $Grey, $FootRect, $FootFmt)
$FootFont.Dispose()

$G.Dispose()
$Bitmap.Save($OutPath, [System.Drawing.Imaging.ImageFormat]::Png)
$Bitmap.Dispose()

Write-Host "wrote $OutPath"
