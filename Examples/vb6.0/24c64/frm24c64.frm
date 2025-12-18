VERSION 5.00
Begin VB.Form frm24c64 
   Caption         =   "AT24C64 DEMO"
   ClientHeight    =   3945
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7365
   FillColor       =   &H00E0E0E0&
   ForeColor       =   &H00C0C0C0&
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   3945
   ScaleWidth      =   7365
   StartUpPosition =   2  'CenterScreen
   Begin VB.ListBox List1 
      BackColor       =   &H00FFFF00&
      Height          =   3570
      Left            =   120
      TabIndex        =   3
      Top             =   120
      Width           =   5535
   End
   Begin VB.CommandButton Command3 
      Caption         =   "&Exit"
      Height          =   735
      Left            =   6000
      TabIndex        =   2
      Top             =   2400
      Width           =   1215
   End
   Begin VB.CommandButton Command2 
      Caption         =   "&Test"
      Height          =   735
      Left            =   6000
      TabIndex        =   1
      Top             =   1440
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Caption         =   "&Init"
      Height          =   615
      Left            =   6000
      TabIndex        =   0
      Top             =   480
      Width           =   1215
   End
End
Attribute VB_Name = "frm24c64"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False


Private Sub Command1_Click()
   icdev = IC_InitComm(100) 'Init USB
    If icdev <= 0 Then
      List1.AddItem ("Init COM Error!")
  List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
    End If
    st = IC_Status(icdev) 'Get Reader Status
    If st < 0 Then
      List1.AddItem ("Init COM OK,But Reader Status Error!")
  List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
    End If
    If st = 0 Then
      List1.AddItem "Init COM OK ,Card in Reader"
      
    End If
    If st = 1 Then
      List1.AddItem ("Init COM OK,NO Card in Reader")
  List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
    End If
  List1.Selected(List1.ListCount() - 1) = True
    
End Sub

Private Sub Command2_Click()
Dim readstr As String * 56
Dim writestr As String * 56
Dim st As Integer
List1.AddItem "Begin Test,please waiting....."
  List1.Selected(List1.ListCount() - 1) = True
  DoEvents
st = IC_InitType(icdev, 192)
If st = 0 Then
 List1.AddItem "Init Card Type OK!"
Else
 List1.AddItem "Init Card Type Error!"
  List1.Selected(List1.ListCount() - 1) = True
  Exit Sub
End If
DoEvents
writestr = "00010203040506070809f0f1f2f3f4f5f6f7f8f91122334455667788"  '
st = IC_Write64_Hex(icdev, 10, 28, writestr)
If st = 0 Then
 List1.AddItem "Write Card OK!"
 List1.AddItem writestr
Else
 List1.AddItem "Write Card Error!"
  List1.Selected(List1.ListCount() - 1) = True
  Exit Sub
End If
readstr = Space(56)
st = IC_Read_Hex(icdev, 10, 28, readstr)
If st = 0 Then
 List1.AddItem "Read Card OK!"
 List1.AddItem readstr
Else
 List1.AddItem "Read Card Error!"
  List1.Selected(List1.ListCount() - 1) = True
  Exit Sub
End If


If Mid(readstr, 1, 56) = Mid(UCase(writestr), 1, 56) Then
  List1.AddItem "Comp Read Data and Write Data OK!"
Else
  List1.AddItem "Comp Read Data and Write Data Error!"
  List1.Selected(List1.ListCount() - 1) = True
  Exit Sub
End If
DoEvents
'**************Ð´Õû¿¨Êý¾Ý************
Dim wrdata(8192) As Byte, redata(8192) As Byte
Dim length As Long, wrdatastr As String * 16384, redatastr As String * 16384
Dim i As Integer
Dim offset As Integer

offset = 0
length = 8 * 1024
List1.AddItem Str(Timer)
List1.Selected(List1.ListCount - 1) = True
DoEvents

For i = 0 To length - 1
wrdata(i) = Rnd(-Rnd * Timer) * 255
Next i
st = IC_Write64hex(icdev, offset, length, wrdata(0))
If st = 0 Then
 List1.AddItem "Writehex Card OK!"
 st = asc2hex(wrdata(0), wrdatastr, length)
 If st <> 0 Then
 List1.AddItem "asc2hex error"
  List1.Selected(List1.ListCount() - 1) = True
 Exit Sub
 End If
Else
 List1.AddItem "Writehex Card Error!" + Str(st)
  List1.Selected(List1.ListCount() - 1) = True
 ''Exit Sub
End If
DoEvents


End Sub

Private Sub Command3_Click()
If icdev > 0 Then
    st = IC_ExitComm(icdev) 'Close COM
    If st <> 0 Then
    List1.AddItem "exitComm error"
  List1.Selected(List1.ListCount() - 1) = True
  Exit Sub
  End If
  List1.AddItem "ExitComm ok"
  List1.Selected(List1.ListCount() - 1) = True
  End If
    Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
st = IC_ExitComm(icdev) 'Close COM
End Sub
