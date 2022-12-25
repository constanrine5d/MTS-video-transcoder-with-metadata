# MTS video transcoder with metadata

This PowerShell script will help you transcode / convert .MTS files from a Sony camera shooting in AVCHD to libx265 crf 23 .mp4 (by default, can be changed) with FFmpeg.

 It also retains the PGS subtitles they contain by converting them to .srt by with OCR by Subtitle Edit and embedding them in the mp4.  

 Most importantly it preserves as much metadata as possible with ExifTool.

## The problem

Have you been hoarding .MTS files from your Sony cameras like me? Do you wish you could convert them to h.265, HEVC or whatever you want but you can't figure out how to retain all of their metadata? Well that's the exact reason I made this PowerShell script.

As a certified video/photo/anything digital hoarder I would never convert my videos without having a way of:

1. Converting them to a more efficient video codec with imperceivable quality loss.
2. Converting them to a more efficient audio codec with imperceivable quality loss.
3. Preserving all metadata, especially `DateTimeOriginal`
4. Having the final videos display `DateTimeOriginal` as both the `DateModified` and `DateCreated` so that Synology Photos would sort them properly.
5. Preserving any extra data they have, like the embedded PGS subtitles. Why? Because it takes almost no space to keep them as embedded .srt subtitles and why not?

## How it works

It basically implements a 5 step method I came up with to do this job to an entire directory, searching for all .MTS files recursively.

Listed below are the basic steps. You can search for them in the script's code as mentioned here to take a look for yourself.

0. **`Extract PGS subtitles to .sup`**

In this step the PGS subtitle "stream" is extracted from the .MTS file to a .sup file using FFmpeg:

>```FFmpeg.exe -i "inputFile" -map 0:8? -c:s copy "outputFile" ```

Where `inputFile` is a .MTS file and `outputFile` is a `.sup file ` containing the PGS subtitles.

1. **`Convert PGS subtitles to srt w/ OCR from SubtitleEdit`**

In this step the PGS subtitles contained in the `.sup file` are converted to `.srt` using OCR from Subtitle Edit:

>```SubtitleEdit.exe /convert "$inputFileSubtitleEdit" srt $subtitleEditSettings /outputfilename:"$outputFileSubtitleEdit"```

Where `inputFileSubtitleEdit` is the `.sup file` and `outputFileSubtitleEdit` is the `.srt file` containing the generated .srt subtitles. At this point the `.sup file` is deleted.

2. **`Run FFMPEG w/ inputs: video and srt subtitles, output: video mp4`**

In this step the original .MTS file is transcoded with the selected FFmpeg settings and the `.srt file` is embedded to create a `.mp4 file`.

>```FFmpeg.exe -i "$inputFile" -i "$outputFileSubtitleEdit" $ffmpegSettings "$outputFile"```

Where `inputFile` is the .MTS file and `outputFileSubtitleEdit` is the `.srt file` containing the generated .srt subtitles and `outputFile` is the generated `.mp4 file` which does not yet contain all metadata. At this point the `.srt file` is deleted.

`ffmpegSettings` is explained below.

3. **`Run exiftool for metadata`**

In this step all the metadata that can be extracted with ExifTool from the original `.MTS file` are transfered to the resulting `.mp4 file`.

>```ExifTool.exe -ee -overwrite_original -tagsFromFile "$inputFile" "$outputFile"```

Where `inputFile` is the .MTS file and `outputFile` is the generated `.mp4 file` which now contains all metadata.

4. **`Run exiftool for datetimes`**

>```ExifTool.exe "-filemodifydate<datetimeoriginal" "-filecreatedate<datetimeoriginal" "$outputFile"```

Where `outputFile` is the generated `.mp4 file` which now displays the correct `DateModified` and `DateCreated`.
 
## Before you begin

### Backup

 Please make sure to have all your data BACKED UP. I am not responsible for ANY data loss. Checking out the script before you begin is recommended. I would NOT advise deleting the original files automatically as with some FFmpeg settings the resulting files could be unplayable. This is why I did not build such an option. Please do that manually and carefully. Check each and every file. You do not want to lose any precious memories.

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

Note: I was having trouble with crashing FFmpeg when using `-threads 0` (default FFmpeg settings, uses all threads) and CPU encoding, so if that's your case I would recommend changing it to `-threads 1`. This uses 1 thread (in theory) so you could possibly use this if you also want to use your computer while encoding.

## Subtitle Edit settings

This script uses `/ocrengine:nOCR` for the OCR of the PGS subtitles. If you know what you're doing, you can play with it. It is fine for most cases.

## How to use

1. Download the script.

2. Run the script by right clicking and selecting `Run with PowerShell`:

![tutorial/Run_script.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/Run_script.png)

3. Read the starting screen and press `OK`:

![tutorial/Starting_screen.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/Starting_screen.png)

4. Select if you want to use the current directory (where the script is located), or a different directory. This is the directory where your `.MTS files` are located. They don't have to be exactly there, the script searches for .MTS files recursively in that directory, so you can have multiple folders inside it and it will find all `.MTS files`:

![tutorial/Selecting_directory_1.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/Selecting_directory_1.png)

5. If you pressed `No` a new pop-up will ask you to choose a folder:

![tutorial/Selecting_directory_2.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/Selecting_directory_2.png)

6. After selecting a directory to search for `.MTS files` you will need to specify the location of FFmpeg.exe, SubtitleEdit.exe and ExifTool.exe. You can also change the settings for FFmpeg and Subtitle Edit.

![tutorial/Directory_paths_and_settings.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/Directory_paths_and_settings.png)

7. If all is good you will be presented in the console (and also in the output file) with the files to be transcoded (+ their individual and total size) and the FFmpeg.exe, SubtitleEdit.exe and ExifTool.exe locations you chose + their settings. If you wish to continue with transcoding press `Yes`.

![tutorial/start_transcoding.png](https://github.com/constanrine5d/MTS-video-transcoder-with-metadata/blob/main/Tutorial/start_transcoding.png)

After pressing `Yes` the script will start the basic steps described [above](##How-it-works).

## The output file: `MTS_video_transcoder_output.txt` 

An output file with the name `MTS_video_transcoder_output.txt` will be exported to the selected directory (the directory you chose at the beginning). It contains a list of the files found, the settings used, the time it took to complete transcoding, the file sizes and the size of the final files as a percentage of the size of the original ones.

Here's an example of an output file:

```
------------------------------------------------------------------

New session started: **censored date**

Program paths:

ffmpeg.exe path: C:\Program Files\ffmpeg\ffmpeg-2022-10-27-git-00b03331a0-full_build\bin\ffmpeg.exe
SubtitleEdit.exe path: C:\Program Files\Subtitle Edit\SubtitleEdit.exe
exiftool.exe path: C:\Program Files\ExifTool\ExifTool.exe

The following settings are used for ffmpeg: -copy_unknown -map_metadata 0 -map 0 -map -0:s -map 1:s -c:v hevc_nvenc -qp 23 -c:a aac -b:a 256k -c:s mov_text -threads 0 
and for subtitle edit: /ocrengine:nOCR

Size for each input file:

**inputs censored**

Total mts files size:
56.905 GB

Transcoding started.

Now processing:

**files processed censored**

Size for each output file:

**outputs censored**

Total mp4 files size:
18.315 GB

Date is: **censored date**

Final files are approximately 32.2 % the size of the original ones.

Elapsed time: 6130.1385046 seconds since the beginning of transcoding.

The following settings were used for ffmpeg: -copy_unknown -map_metadata 0 -map 0 -map -0:s -map 1:s -c:v hevc_nvenc -qp 23 -c:a aac -b:a 256k -c:s mov_text -threads 0 
and for subtitle edit: /ocrengine:nOCR

------------------------------------------------------------------
```
