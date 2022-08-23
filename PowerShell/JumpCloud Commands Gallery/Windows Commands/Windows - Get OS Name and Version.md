#### Name

Windows - Get OS Name and Version | v1.0 JCCG

#### commandType

windows

#### Command

```
$sys = (systeminfo /fo csv | ConvertFrom-Csv)
return "HostName: " + ($sys.'Host Name') + "`n" + "OS Name: " + ($sys.'OS Name') + "`n" + "OS Version: " +($sys.'OS Version')
```

#### Description

Returns the hostname, OS Name, and OS Version including build number of a Windows host. 
#### *Import This Command*

To import this command into your JumpCloud tenant run the below command using the [JumpCloud PowerShell Module](https://github.com/TheJumpCloud/support/wiki/Installing-the-JumpCloud-PowerShell-Module)

```
Import-JCCommand -URL "https://github.com/TheJumpCloud/support/blob/master/PowerShell/JumpCloud%20Commands%20Gallery/Windows%20Commands/Windows%20-%20Get%20OS%20Name%20and%20Version.md"
```
