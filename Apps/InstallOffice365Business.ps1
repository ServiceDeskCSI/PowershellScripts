cd c:\temp\

# Change URL for https://www.microsoft.com/en-us/download/details.aspx?id=49117
Invoke-WebRequest -Uri "URLHERE" -OutFile officedeploymenttool.exe
cmd /c officedeploymenttool.exe /extract:C:\Temp\ /quiet /passive /norestart

#Check if files from office deployment tool and delete them
if (Test-Path c:\temp\configuration-Office365-x64.xml) {
        Remove-Item c:\temp\configuration-Office365-x64.xml -verbose
}
if (Test-Path c:\temp\configuration-Office365-x86.xml) {
        Remove-Item c:\temp\configuration-Office365-x86.xml -verbose
}
if (Test-Path c:\temp\configuration-Office2019Enterprise.xml) {
        Remove-Item c:\temp\configuration-Office2019Enterprise.xml -verbose
}
if (Test-Path c:\temp\configuration-Office2021Enterprise.xml) {
        Remove-Item c:\temp\configuration-Office2021Enterprise.xml -verbose
}
if (Test-Path c:\temp\Office365_business.xml) {
        Remove-Item c:\temp\Office365_business.xml -verbose
}

# Make a new config file for the XML to do a deployment https://config.office.com/deploymentsettings
New-Item c:\temp\Office365_business.xml -ItemType File -Force
Set-content c:\temp\Office365_business.xml -Value '<Configuration ID="b1b7f25d-ed92-4903-b7ef-9168cce85f0f">' 
Add-content c:\temp\Office365_business.xml -Value '  <Add OfficeClientEdition="64" Channel="Current">'
Add-content c:\temp\Office365_business.xml -Value '    <Product ID="O365BusinessRetail">'
Add-content c:\temp\Office365_business.xml -Value '      <Language ID="en-us" />'
Add-content c:\temp\Office365_business.xml -Value '      <ExcludeApp ID="Groove" />'
Add-content c:\temp\Office365_business.xml -Value '      <ExcludeApp ID="Lync" />'
Add-content c:\temp\Office365_business.xml -Value '    </Product>'
Add-content c:\temp\Office365_business.xml -Value '  </Add>'
Add-content c:\temp\Office365_business.xml -Value '  <Updates Enabled="TRUE" />'
Add-content c:\temp\Office365_business.xml -Value '  <AppSettings>'
Add-content c:\temp\Office365_business.xml -Value '    <User Key="software\microsoft\office\16.0\excel\options" Name="defaultformat" Value="51" Type="REG_DWORD" App="excel16" Id="L_SaveExcelfilesas" />'
Add-content c:\temp\Office365_business.xml -Value '    <User Key="software\microsoft\office\16.0\powerpoint\options" Name="defaultformat" Value="27" Type="REG_DWORD" App="ppt16" Id="L_SavePowerPointfilesas" />'
Add-content c:\temp\Office365_business.xml -Value '    <User Key="software\microsoft\office\16.0\word\options" Name="defaultformat" Value="" Type="REG_SZ" App="word16" Id="L_SaveWordfilesas" />'
Add-content c:\temp\Office365_business.xml -Value '  </AppSettings>'
Add-content c:\temp\Office365_business.xml -Value '</Configuration>'

cmd /c "setup.exe /configure Office365_business.xml"

if (Test-Path c:\temp\officedeploymenttool.exe) {
        Remove-Item c:\temp\officedeploymenttool.exe -verbose
}
