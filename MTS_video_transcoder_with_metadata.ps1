# Displays a message in a message box
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[System.Windows.Forms.MessageBox]::Show("Hello, this script will help you convert .MTS files from a Sony camera shooting in AVCHD to libx265 crf 23 .mp4 (by default, can be changed) (ffmpeg) with their PGS subtitles converted to .srt by OCR (Subtitle Edit) and embedded in the mp4. It also preserves as much metadata as possible (ExifTool).`n`nMake sure you have ffmpeg.exe, SubtitleEdit.exe and Exiftool.exe downloaded/installed. You will be asked for their directory.`n`nPlease make sure to have all your data BACKED UP. I am not responsible for ANY data loss. Checking out the script before you begin is recommended.`n`nI would NOT advise deleting the original files automatically as with some ffmpeg settings the resulting files could be unplayable. This is why I did not build such an option. Please do that manually and carefully. Check each and every file. You do not want to lose any precious memories.")

# Load the System.Windows.Forms assembly
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

$selectedDirectory = (Get-Location).Path

# Display a message box that asks the user if they want to use the current directory
$result = [System.Windows.Forms.MessageBox]::Show(
  "Do you want to use the current directory, $selectedDirectory ? Press `"No`" to choose a different directory. Press `"Cancel`" to exit.",
  "Select directory",
  [System.Windows.Forms.MessageBoxButtons]::YesNoCancel
)

# If the user selects "Yes", use the current directory
if ($result -eq "Yes") {
  $selectedDirectory = (Get-Location).Path
}
# If the user selects "No", use the FolderBrowserDialog to select a directory
elseif ($result -eq "No") {
  # Create a FolderBrowserDialog object
  $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog

  # Set the dialog options
  $folderBrowserDialog.Description = "Select a directory"
  $folderBrowserDialog.RootFolder = "Desktop"

  # Display the dialog and get the selected folder
  if ($folderBrowserDialog.ShowDialog() -eq "OK") {
    $selectedDirectory = $folderBrowserDialog.SelectedPath
  }
}
elseif ($result -eq "Cancel") {
    Exit
    }

# If the user selects "Cancel", exit

"------------------------------------------------------------------`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
$time = Get-Date -UFormat "%A %m/%d/%Y %R %Z"
"New session started: $time`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append


###----------------------------------------------------------------------------###

# Load the System.Windows.Forms assembly
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

# Create a Form object
$form = New-Object System.Windows.Forms.Form

# Set the form properties
$form.Text = "Directory Paths"
$form.Width = 1150
$form.Height = 250
$form.StartPosition = "CenterScreen"

# Create the labels and text boxes
$instructionsLabel = New-Object System.Windows.Forms.Label
$instructionsLabel.Text = "Please specify the following directories and settings:"
$instructionsLabel.Width = 300
$instructionsLabel.Height = 20
$instructionsLabel.Location = New-Object System.Drawing.Point(20, 20)

$ffmpegLabel = New-Object System.Windows.Forms.Label
$ffmpegLabel.Text = "FFmpeg.exe path:"
$ffmpegLabel.Width = 120
$ffmpegLabel.Height = 20
$ffmpegLabel.Location = New-Object System.Drawing.Point(20, 50)

$ffmpegTextBox = New-Object System.Windows.Forms.TextBox
$ffmpegTextBox.Width = 250
$ffmpegTextBox.Height = 20
$ffmpegTextBox.Location = New-Object System.Drawing.Point(140, 50)

$ffmpegBrowseButton = New-Object System.Windows.Forms.Button
$ffmpegBrowseButton.Text = "Browse"
$ffmpegBrowseButton.Width = 70
$ffmpegBrowseButton.Height = 20
$ffmpegBrowseButton.Location = New-Object System.Drawing.Point(400, 50)

$ffmpegTextBoxSettings = New-Object System.Windows.Forms.TextBox
$ffmpegTextBoxSettings.Width = 600
$ffmpegTextBoxSettings.Height = 20
$ffmpegTextBoxSettings.Location = New-Object System.Drawing.Point(470, 50)
$ffmpegTextBoxSettings.Text = "-copy_unknown -map_metadata 0 -map 0 -map -0:s -map 1:s -c:v libx265 -crf 23 -c:a aac -b:a 256k -c:s mov_text -threads 0"

# Set the ffmpeg browse button's click event
$ffmpegBrowseButton.Add_Click({
  # Create an OpenFileDialog object
  $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

  # Set the OpenFileDialog properties
  $openFileDialog.Filter = "Executable files (*.exe)|*.exe"
  $openFileDialog.Title = "Select FFmpeg Executable"

  # Show the OpenFileDialog and get the selected file
  $result = $openFileDialog.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK)
  {
    # Set the ffmpeg text box's text to the selected file's path
    $ffmpegTextBox.Text = $openFileDialog.FileName
  }
})

$subtitleEditLabel = New-Object System.Windows.Forms.Label
$subtitleEditLabel.Text = "SubtitleEdit.exe path:"
$subtitleEditLabel.Width = 120
$subtitleEditLabel.Height = 20
$subtitleEditLabel.Location = New-Object System.Drawing.Point(20, 80)

$subtitleEditTextBox = New-Object System.Windows.Forms.TextBox
$subtitleEditTextBox.Width = 250
$subtitleEditTextBox.Height = 20
$subtitleEditTextBox.Location = New-Object System.Drawing.Point(140, 80)

$subtitleEditBrowseButton = New-Object System.Windows.Forms.Button
$subtitleEditBrowseButton.Text = "Browse"
$subtitleEditBrowseButton.Width = 70
$subtitleEditBrowseButton.Height = 20
$subtitleEditBrowseButton.Location = New-Object System.Drawing.Point(400, 80)

$subtitleEditTextBoxSettings = New-Object System.Windows.Forms.TextBox
$subtitleEditTextBoxSettings.Width = 600
$subtitleEditTextBoxSettings.Height = 20
$subtitleEditTextBoxSettings.Location = New-Object System.Drawing.Point(470, 80)
$subtitleEditTextBoxSettings.Text = "/ocrengine:nOCR"

# Set the subtitle edit browse button's click event
$subtitleEditBrowseButton.Add_Click({
  # Create an OpenFileDialog object
  $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

  # Set the OpenFileDialog properties
  $openFileDialog.Filter = "Executable files (*.exe)|*.exe"
  $openFileDialog.Title = "Select Subtitle Edit Executable"

  # Show the OpenFileDialog and get the selected file
  $result = $openFileDialog.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK)
  {
    # Set the subtitle edit text box's text to the selected file's path
    $subtitleEditTextBox.Text = $openFileDialog.FileName
  }
})

$exiftoolLabel = New-Object System.Windows.Forms.Label
$exiftoolLabel.Text = "ExifTool.exe path:"
$exiftoolLabel.Width = 120
$exiftoolLabel.Height = 20
$exiftoolLabel.Location = New-Object System.Drawing.Point(20, 110)

$exiftoolTextBox = New-Object System.Windows.Forms.TextBox
$exiftoolTextBox.Width = 250
$exiftoolTextBox.Height = 20
$exiftoolTextBox.Location = New-Object System.Drawing.Point(140, 110)

$exiftoolBrowseButton = New-Object System.Windows.Forms.Button
$exiftoolBrowseButton.Text = "Browse"
$exiftoolBrowseButton.Width = 70
$exiftoolBrowseButton.Height = 20
$exiftoolBrowseButton.Location = New-Object System.Drawing.Point(400, 110)

# Set the exiftool browse button's click event
$exiftoolBrowseButton.Add_Click({
  # Create an OpenFileDialog object
  $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog

  # Set the OpenFileDialog properties
  $openFileDialog.Filter = "Executable files (*.exe)|*.exe"
  $openFileDialog.Title = "Select Exiftool Executable"

  # Show the OpenFileDialog and get the selected file
  $result = $openFileDialog.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK)
  {
    # Set the exiftool text box's text to the selected file's path
    $exiftoolTextBox.Text = $openFileDialog.FileName
  }
})

# Create the submit button
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"
$submitButton.Width = 100
$submitButton.Height = 30
$submitButton.Location = New-Object System.Drawing.Point(150, 150)

#Create the invalid label

$invalidLabel = New-Object System.Windows.Forms.Label
$invalidLabel.Text = "One or more paths are invalid:"
$invalidLabel.Width = 200
$invalidLabel.Height = 20
$invalidLabel.Location = New-Object System.Drawing.Point(270, 155)
$invalidLabel.ForeColor = [System.Drawing.Color]::Red
$invalidLabel.Visible = $False
$invalidLabel.Font.Bold


# Set the default text for the text boxes
$ffmpegTextBox.Text = "C:\Program Files\ffmpeg\bin\ffmpeg.exe"
$subtitleEditTextBox.Text = "C:\Program Files\Subtitle Edit\SubtitleEdit.exe"
$exiftoolTextBox.Text = "C:\Program Files\ExifTool\ExifTool.exe"


# Add the controls to the form
$form.Controls.Add($instructionsLabel)
$form.Controls.Add($ffmpegLabel)
$form.Controls.Add($ffmpegTextBox)
$form.Controls.Add($ffmpegTextBoxSettings)
$form.Controls.Add($ffmpegBrowseButton)
$form.Controls.Add($subtitleEditLabel)
$form.Controls.Add($subtitleEditTextBox)
$form.Controls.Add($subtitleEditTextBoxSettings)
$form.Controls.Add($subtitleEditBrowseButton)
$form.Controls.Add($exiftoolLabel)
$form.Controls.Add($exiftoolTextBox)
$form.Controls.Add($exiftoolBrowseButton)
$form.Controls.Add($submitButton)
$form.Controls.Add($invalidLabel)

# Set the submit button's click event
$submitButton.Add_Click({
  # Get the values from the text boxes
  $global:ffmpegPath = $ffmpegTextBox.Text.ToString()
  $global:subtitleEditPath = $subtitleEditTextBox.Text.ToString()
  $global:exiftoolPath = $exiftoolTextBox.Text.ToString()

  $global:ffmpegSettings = $ffmpegTextBoxSettings.Text.ToString()
  $global:subtitleEditSettings = $subtitleEditTextBoxSettings.Text.ToString()

   # Check if the locations of the programs are valid
  if ($ffmpegPath -eq "" -or !(Test-Path $ffmpegPath) -or !(Test-Path $subtitleEditPath) -or !(Test-Path $exiftoolPath)) {
    
    # If the locations are not valid, show the invalid label
    
    $invalidLabel.Visible = $True
    
    return
  }
  else {
    # If the locations are valid, close the form
    $invalidLabel.Visible = $False

    $global:cancelTranscoding = $False

    # Close the form
    $form.Close()
  }

  # Check if the label is visible
  if ($invalidLabel.Visible) {
    # If the label is visible, do nothing
    return
  }

})

# Set the AcceptButton property of the form to the submit button control
$form.AcceptButton = $submitButton

# Show the form
$global:cancelTranscoding = $True
$form.ShowDialog()

if ($cancelTranscoding) {
    #If the form is closed by X, exit the script
    exit
  }


###----------------------------------------------------------------------------###

# Write program paths
Write-Output "  "
Write-Output "  "
Write-Output "ffmpeg.exe path: $ffmpegPath"
Write-Output "SubtitleEdit.exe path: $subtitleEditPath"
Write-Output "exiftool.exe path: $exiftoolPath"

"Program paths:`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"ffmpeg.exe path: $ffmpegPath" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"SubtitleEdit.exe path: $subtitleEditPath" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"exiftool.exe path: $exiftoolPath`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Write program settings

Write-Output "`nThe following settings will be used for ffmpeg: $ffmpegSettings `nand for subtitle edit: $subtitleEditSettings`n"

"The following settings are used for ffmpeg: $ffmpegSettings `nand for subtitle edit: $subtitleEditSettings`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

###----------------------------------------------------------------------------###

Write-Output "  "
Write-Output "The selected folder is: $selectedDirectory"

# Get a list of all .mts files in the current directory and all subdirectories
$mtsFiles = Get-ChildItem $selectedDirectory -Recurse -Include *.mts

# Write two empty lines
Write-Host ""
Write-Host ""

# Write some text
Write-Host "Size for each input file:`n"
"Size for each input file" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

foreach ($file in $mtsFiles) {

  $file.FullName
  $file.FullName | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

  # Get the size of a file in the current directory and display it in gigabytes
  $sizeInBytes = (Get-Item $file).Length
  $sizeInGB = [math]::Round(($sizeInBytes / 1GB), 3)
  $sizeInGB.ToString("N3") + " GB"
  $sizeInGB.ToString("N3") + " GB" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
}

# Write some text
Write-Host "Total mts files size:"
"`nTotal mts files size:" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Get the total size of all the files in the $mtsFiles list and display it in gigabytes
$totalSizeOriginal = $mtsFiles | Measure-Object -Property Length -Sum
$sizeInGB = [math]::Round(($totalSizeOriginal.Sum / 1GB), 3)
$sizeInGB.ToString("N3") + " GB"

$sizeInGB.ToString("N3") + " GB`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Write two empty lines
Write-Host ""
Write-Host ""

###----------------------------------------------------------------------------###

# Display a message box with a Yes/No button
$result = [System.Windows.Forms.MessageBox]::Show("Listed in the console are the sizes of each file found and the total size. Are you sure you want to continue with transcoding?`n`nPress `"Yes`" to start transcoding.`n`nPress `"No`" to exit.", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo)

# Check the result of the message box
if ($result -eq [System.Windows.Forms.DialogResult]::Yes)
{
  # The user clicked Yes, so continue execution
  # ...
}
else
{
  # The user clicked No, so cancel execution
  Exit
}

# Write two empty lines
Write-Host ""
Write-Host ""



###----------------------------------------------------------------------------###

$outputFiles = New-Object System.Collections.ArrayList

"Transcoding started.`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

"Now processing:`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Create a new Stopwatch object
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($file in $mtsFiles) {

  # 0. Extract PGN subtitles to .sup

  # Set the input and output filenames

  $inputFile = $file

  $inputFile.FullName | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

  $outputFile = "$($inputFile.BaseName).sup"

  # Extract the directory from the input file path
  $inputDirectory = Split-Path $inputFile -Parent

  # Set the output file path
  $outputFile = Join-Path $inputDirectory $outputFile

  Write-Output "0. $inputFile Extract PGN subtitles to $outputFile"


  # Set the ffmpeg arguments
  $arguments = "-i `"$inputFile`" -map 0:8? -c:s copy `"$outputFile`""
  Write-Output "$arguments"

  # Start ffmpeg.exe with the specified arguments
  Start-Process -FilePath $ffmpegPath $arguments -Wait

  Write-Host ""

  # 1. Convert PGN subtitles to srt w/ OCR from SubtitleEdit

  # Set the input and output filenames
  $inputFileSubtitleEdit = $outputFile
  $outputFileSubtitleEdit = "$($inputFile.BaseName).srt"

  # Set the output file path
  $outputFileSubtitleEdit = Join-Path $inputDirectory $outputFileSubtitleEdit

  Write-Output "1. '$inputFileSubtitleEdit' Convert PGS subtitles to srt w/ OCR from SubtitleEdit '$outputFileSubtitleEdit'"

  # Set the SubtitleEdit arguments
  $arguments = "/convert `"$inputFileSubtitleEdit`" srt $subtitleEditSettings /outputfilename:`"$outputFileSubtitleEdit`""
  Write-Output "$arguments"

  # Start SubtitleEdit.exe with the specified arguments
  Start-Process -FilePath $subtitleEditPath -ArgumentList $arguments -Wait

  Remove-Item $inputFileSubtitleEdit -Force
  
  Write-Host ""


  # 2. Run FFMPEG w/ inputs: video and srt subtitles, output: video mp4


  # Set the input and output filenames
  #$inputFile = $file
  $outputFile = "$($inputFile.BaseName).mp4"

  # Set the output file path
  $outputFile = Join-Path $inputDirectory $outputFile

  Write-Output "2. $inputFile Run FFMPEG w/ inputs: video and srt subtitles, output: $outputFile"

  # Set the ffmpeg arguments
  $arguments = "-i `"$inputFile`" -i `"$outputFileSubtitleEdit`" $ffmpegSettings `"$outputFile`""
  Write-Output "$arguments"

  # Start ffmpeg.exe with the specified arguments
  Start-Process -FilePath $ffmpegPath -ArgumentList $arguments -Wait

  Remove-Item $outputFileSubtitleEdit -Force
    
  Write-Host ""


  # 3. Run exiftool for metadata

  Write-Output "3. $inputFile Run exiftool for metadata $outputFile"

  # Set the input and output filenames
  #$inputFile = $file
  #$outputFile = "$($inputFile.BaseName).mp4"

  # Set the ExifTool arguments
  $arguments = "-ee -overwrite_original -tagsFromFile `"$inputFile`" `"$outputFile`""
  Write-Output "$arguments"

  # Start ExifTool.exe with the specified arguments
  Start-Process -FilePath $exiftoolPath -ArgumentList $arguments -Wait
      
  Write-Host ""


  # 4. Run exiftool for datetimes

  Write-Output "4. $outputFile Run exiftool for datetimes"

  # Set the input and output filenames
  #$inputFile = $file
  #$outputFile = "$($inputFile.BaseName).mp4"

  # Set the ExifTool arguments
  $arguments = "`"-filemodifydate<datetimeoriginal`" `"-filecreatedate<datetimeoriginal`" `"$outputFile`""
  Write-Output "$arguments"


  # Start ExifTool.exe with the specified arguments
  Start-Process -FilePath $exiftoolPath -ArgumentList $arguments -Wait


  # Write two empty lines
  Write-Host ""
  Write-Host ""
  Write-Host ""
  Write-Host ""

  $outputFile = $outputFile

  $outputFiles += $outputFile
}

"`nSize for each output file:`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Get the total size of all the files in the $outputFiles list and display it in gigabytes

$totalSizeFinal=0

foreach ($file in $outputFiles) {

  $file
  $file | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

  # Get the size of a file in the current directory and display it in gigabytes
  $sizeInBytes = (Get-Item $file).Length
  $sizeInGB = [math]::Round(($sizeInBytes / 1GB), 3)
  $totalSizeFinal=$totalSizeFinal+$sizeInGB
  $sizeInGB.ToString("N3") + " GB"
  $sizeInGB.ToString("N3") + " GB" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
}

# Write some text
Write-Host "Total mp4 files size:"
"`nTotal mp4 files size:" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

$totalSizeFinal.ToString("N3") + " GB"
$totalSizeFinal.ToString("N3") + " GB" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

$percentOfOriginal = [math]::Round($totalSizeFinal/[math]::Round(($totalSizeOriginal.Sum / 1GB), 3), 3)*100

Write-Host "  "
Write-Host "  "

Write-Host "Final files are approximately $percentOfOriginal % the size of the original ones.`n"
$stopwatch.Stop()
Write-Output "Elapsed time: $($stopwatch.Elapsed.TotalSeconds) seconds since the beginning of transcoding."

Write-Host "  "

Write-Host "The following settings were used for ffmpeg: $ffmpegSettings `nand for subtitle edit: $subtitleEditTextBoxSettings"

$time = Get-Date -UFormat "%A %m/%d/%Y %R %Z"

# Save the output of the script to a text file and append the output
"`nDate is: $time`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

"Final files are approximately $percentOfOriginal % the size of the original ones.`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"Elapsed time: $($stopwatch.Elapsed.TotalSeconds) seconds since the beginning of transcoding.`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"The following settings were used for ffmpeg: $ffmpegSettings `nand for subtitle edit: $subtitleEditSettings`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append
"------------------------------------------------------------------`n" | Out-File -FilePath "$selectedDirectory\MTS_video_transcoder_output.txt" -Append

# Display a message and pause until the user presses the Enter key
Read-Host -Prompt "Press Enter to exit"