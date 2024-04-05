$PathPS = "c:\temp\"
$FileNamePS = "File.exe"
$URLPS = "http://website.com/File.exe"

cd $PathPS
Invoke-WebRequest -Uri "$URLPS" -OutFile $FileNamePS