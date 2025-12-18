VERSION 5.00
Begin VB.Form frm24c01 
   Caption         =   "AT24C01 DEMO"
   ClientHeight    =   3945
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7365
   FillColor       =   &H00C0C0C0&
   ForeColor       =   &H00C0C0C0&
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   3945
   ScaleWidth      =   7365
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton Command1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Init Ic"
      Height          =   495
      Left            =   6000
      TabIndex        =   3
      Top             =   120
      Width           =   1215
   End
   Begin VB.CommandButton Command2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Test"
      Height          =   495
      Left            =   6000
      TabIndex        =   2
      Top             =   840
      Width           =   1215
   End
   Begin VB.ListBox List1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFF00&
      Height          =   3540
      Left            =   120
      TabIndex        =   1
      Top             =   120
      Width           =   5655
   End
   Begin VB.CommandButton Command3 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "End"
      Height          =   495
      Left            =   6000
      TabIndex        =   0
      Top             =   1560
      Width           =   1215
   End
End
Attribute VB_Name = "frm24c01"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim st As Integer


Private Sub Command1_Click()
   icdev = IC_InitComm(100)                    'Init USB
    If icdev <= 0 Then
      List1.AddItem ("Init COM Error!")
      List1.AddItem "icdev=" + Str(icdev)
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
    End If
    
    st = IC_Status(icdev)                    'Get Reader Status
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
      Exit Sub
    End If
    List1.Selected(List1.ListCount() - 1) = True
    
End Sub

Private Sub Command2_Click()
Dim readstr As String * 256
Dim writestr As String * 256
Dim st As Integer
List1.AddItem "Begin Test,please waiting........"
      List1.Selected(List1.ListCount() - 1) = True
st = IC_InitType(icdev, 64)                'tell type
If st = 0 Then
 List1.AddItem "Init Card Type OK!"
Else
 List1.AddItem "Init Card Type Error!"
      List1.Selected(List1.ListCount() - 1) = True
End If
writestr = "00010203040506070809f0f1f2f3f4f5f6f7f8f91122334455667788"  '
st = IC_Write24(icdev, 10, 56, writestr)
If st = 0 Then
 List1.AddItem "Write Card OK!"
Else
 List1.AddItem "Write Card Error!"
 List1.Selected(List1.ListCount() - 1) = True
 Exit Sub
End If
readstr = Space(56)
st = IC_Read(icdev, 10, 56, readstr)
If st = 0 Then
 List1.AddItem "Read Card OK!"
 List1.AddItem readstr
Else
 List1.AddItem "Read Card Error!"
 List1.Selected(List1.ListCount() - 1) = True
 Exit Sub
End If


If Mid(readstr, 1, 56) = Mid(writestr, 1, 56) Then
  List1.AddItem "Comp Read Data and Write Data OK!"
Else
  List1.AddItem "Comp Read Data and Write Data Error!"
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
End If
DoEvents
'****************写任意数据******************8
Dim wrdata(128) As Byte, redata(128) As Byte
Dim i As Integer, wrdatastr As String * 256, redatastr As String * 256
length = 128
For i = 0 To length - 1
wrdata(i) = Rnd(-Rnd * Timer) * 255
Next i

st = IC_Write24hex(icdev, 0, length, wrdata(0))
 
If st = 0 Then
 List1.AddItem "Writehex Card OK!"
Else
 List1.AddItem "Writehex Card Error!" + Str(st)
      List1.Selected(List1.ListCount() - 1) = True
End If
 st = asc2hex(wrdata(0), wrdatastr, length)
 If st <> 0 Then
    List1.AddItem "asc2hex error"
      List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
 End If
 List1.AddItem wrdatastr
DoEvents


End Sub

Private Sub Command3_Click()
If icdev > 0 Then
    st = IC_ExitComm(icdev) 'Close COM
End If
End
End Sub

Private Sub Form_Unload(Cancel As Integer)
If icdev > 0 Then
    st = IC_ExitComm(icdev) 'Close COM
End If
End Sub


Private Sub List1_DblClick()
List1.Clear
End Sub
