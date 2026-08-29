' start-hidden.vbs
Option Explicit
Dim shell, fso, projDir, port, url, i, waitMs, http, ready
Set shell = CreateObject("WScript.Shell")
Set fso   = CreateObject("Scripting.FileSystemObject")

projDir = fso.GetParentFolderName(WScript.ScriptFullName)
port    = 9002  ' يجب أن يتطابق مع PORT في start-prod.bat
url     = "http://localhost:" & port & "/"
waitMs  = 300   ' تأخير بين المحاولات بالملي ثانية

' شغّل الـ BAT مخفياً (0 = مخفي، False = لا ننتظر انتهاءه)
shell.Run "cmd /c """ & projDir & "\start-prod.bat""", 0, False

' انتظر جاهزية السيرفر (جس النبض بالرابط)
ready = False
For i = 1 To 120 ' حوالي 36 ثانية (120 * 300ms) — عدِّل إذا تريد مدة انتظار أطول
  On Error Resume Next
  Set http = CreateObject("MSXML2.ServerXMLHTTP.6.0")
  http.setTimeouts 2000,2000,2000,2000
  http.Open "GET", url, False
  http.Send
  If Err.Number = 0 Then
    If http.Status >= 200 And http.Status < 500 Then
      ready = True
      On Error GoTo 0
      Exit For
    End If
  End If
  On Error GoTo 0
  WScript.Sleep waitMs
Next

' افتح المتصفح (يفتح تبويب/نافذة حسب إعدادات المستخدم)
If ready Then
  shell.Run url, 1, False
Else
  ' لو لم يجهز في الوقت المحدد، جرّب تفتحه على أي حال
  shell.Run url, 1, False
End If
