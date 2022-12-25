# MTS video transcoder with metadata

This PowerShell script will help you convert .MTS files from a Sony camera shooting in AVCHD to libx265 crf 23 .mp4 (by default, can be changed) with FFmpeg.

 It also retains the PGS subtitles they contain by converting them to .srt by with OCR by Subtitle Edit and embedding them in the mp4.  

 Most importantly it preserves as much metadata as possible with ExifTool.
 
## Before you begin

### Backup

 Please make sure to have all your data BACKED UP. I am not responsible for ANY data loss. Checking out the script before you begin is recommended. I would NOT advise deleting the original files automatically as with some ffmpeg settings the resulting files could be unplayable. This is why I did not build such an option. Please do that manually and carefully. Check each and every file. You do not want to lose any precious memories.

### Installing FFmpeg, Subtitle Edit and ExifTool for Windows

Please download and install/unzip the following to any directory. You will be asked for the directory of FFmpeg.exe, SubtitleEdit.exe and ExifTool.exe:

>FFmpeg: https://ffmpeg.org/download.html

>Subtilte Edit: https://www.nikse.dk/subtitleedit

>ExifTool: https://exiftool.org/

## FFmpeg settings  

The default FFmpeg settings used in this script are (for `libx265`): 

>`-copy_unknown -map_metadata 0 -map 0 -map -0:s -map 1:s -c:v libx265 -crf 23 -c:a aac -b:a 256k -c:s mov_text -threads 0`

These settings can be changed as the script prompts you for FFmpeg settings.

If you want to use `hevc_nvenc` (hardware acceleration with a supported Nvidia graphics card), I recommend:

>`-copy_unknown -map_metadata 0 -map 0 -map -0:s -map 1:s -c:v hevc_nvenc -qp 23 -c:a aac -b:a 256k -c:s mov_text -threads 0`

I would recommend using libx265 which is software encoding using the CPU. This is because it uses `CRF` (Constant Rate Factor) instead of `CQP` (Constant Quantization Parameter). For more on why these are different please refer to: https://slhck.info/video/2017/02/24/crf-guide.html. This will be much slower but for me it is worth the extra time for the smaller resulting file size and better perceived quality.

Note: I was having trouble with crashing FFmpeg when using `-threads 0` (default FFmpeg settings, uses all threads) and CPU encoding, so if that's your case I would recommend changing it to `-threads 1`. This uses 1 thread so you could possibly use this if you also want to use your computer while encoding.

## Subtitle Edit settings

This script uses `/ocrengine:nOCR` for the OCR of the PGS subtitles. If you know what you're doing, you can play with it. It is fine for most cases.