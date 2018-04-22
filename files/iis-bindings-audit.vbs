' IIS Bindings Audit script
' Released into the Public Domain by its author as it's disgusting
'   -- Jonathan Matthews, 17/08/2011
'
' Invoke as 
'   cscript <filename.vbs> //NoLogo [IIS-Server] > output.txt
' IIS-Server defaults to "localhost" if not specified

Set args = Wscript.Arguments
if (args.Length=0) then
 MachineName="localhost"
else
 MachineName=args(0)
end if
Wscript.Echo "# MachineName : SiteComment : SomeSortOfName : IP : Port : HostHeader"

IIsObjectPath = "IIS://" & MachineName & "/w3svc"
Set IIsObject = GetObject(IIsObjectPath)

for each obj in IISObject
 if (Obj.Class = "IIsWebServer") then
  BindingPath = IIsObjectPath & "/" & Obj.Name
  Set IIsObjectIP = GetObject(BindingPath)
  Comment=IISObjectIP.ServerComment
  Name=obj.Name
  ValueList = IISObjectIP.Get("ServerBindings")
  ValueString = ""
  For ValueIndex = 0 To UBound(ValueList)
    value = ValueList(ValueIndex)
    Values = split(value, ":")
    IP = values(0)
    if (IP = "") then
      IP = "0.0.0.0"
    end if
    TCP = values(1)
    if (TCP = "") then
      TCP = "80"
    end if
    HostHeader = values(2)
    Wscript.Echo MachineName &":"& Comment & ":W3SVC" & Name & ":" & IP & ":" & TCP & ":" & HostHeader
  Next
  Set IISObjectIP = Nothing
 end if
Next
Set IISObject = Nothing

