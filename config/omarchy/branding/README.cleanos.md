# CleanOS branding assets

`cleanos-mkmark.py <#hex> <outdir>` regenerates both marks from the pixel-font
table inside it. Glyphs are laid out on a terminal-cell grid (3-column stems,
1-row bars) and the PNG uses 1:2 cells, so one source renders crisply as both
block ASCII and a logo image.

Regenerate after a theme change:

    cd ~/.config/omarchy/branding
    ./cleanos-mkmark.py '#d4be98' .                       # new foreground colour
    omarchy transcode ascii cleanos-wordmark.png screensaver.txt --mode block --width 75
    omarchy transcode ascii cleanos-badge.png    about.txt      --mode block --width 53 --height 26
    omarchy plymouth set '#282828' '#d4be98' ~/.config/omarchy/branding/cleanos-wordmark.png

The widths above are exact multiples of the source grid; other values resample
and blur the pixel edges.

Stock Omarchy originals are kept alongside as `*.omarchy-<timestamp>`.
