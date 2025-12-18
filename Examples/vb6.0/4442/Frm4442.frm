VERSION 5.00
Begin VB.Form Frm4442 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H00C0C0C0&
   Caption         =   "SLE4442 TEST"
   ClientHeight    =   4020
   ClientLeft      =   1275
   ClientTop       =   1680
   ClientWidth     =   7365
   FillColor       =   &H00C0C0C0&
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00C0C0C0&
   LinkTopic       =   "Form3"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4020
   ScaleWidth      =   7365
   Begin VB.CommandButton Command3 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "End"
      Height          =   495
      Left            =   6000
      TabIndex        =   3
      Top             =   1560
      Width           =   1215
   End
   Begin VB.ListBox List1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFF00&
      Height          =   3735
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Width           =   5655
   End
   Begin VB.CommandButton Command2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Test"
      Height          =   495
      Left            =   6000
      TabIndex        =   1
      Top             =   840
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Init Ic"
      Height          =   495
      Left            =   6000
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "Frm4442"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim st%

Private Sub Command1_click()
   icdev = IC_InitComm(100) '初始化端口，100表示USB端口
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
Dim Password As String * 20
Dim ReadStr As String * 1024
Dim WriteStr As String * 1024
Dim st As Integer
Dim StarAddr  As Integer
Dim Length As Integer

List1.AddItem "Begin test,please waiting......"
    List1.Selected(List1.ListCount() - 1) = True

st = IC_InitType(icdev, 16)
If st = 0 Then
 List1.AddItem "Init Card Type OK!"
Else
 List1.AddItem "Init Card Type Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
End If
DoEvents

st = IC_ReadCount_SLE4442(ByVal icdev&)
If st < 0 Then
   List1.AddItem ("Read Card Count Error!")
    List1.Selected(List1.ListCount() - 1) = True
   Exit Sub
Else
   List1.AddItem ("Read Card Count OK!The Count is " + Str(st))
End If
DoEvents

Password = "ffffff" 'you may be use different password
st = IC_CheckPass_4442hex(ByVal icdev&, ByVal Password$)
If st < 0 Then
   List1.AddItem ("Check Card Password Error!")
    List1.Selected(List1.ListCount() - 1) = True
   Exit Sub
Else
   List1.AddItem ("Check Card Password OK!")
End If
DoEvents
      
'******************写固定数据**********************
WriteStr = String(224 * 2, "3")
StarAddr = 32
Length = 224
st = IC_Write_Hex(ByVal icdev&, StarAddr, Length, Left$(WriteStr$, Length * 2))
If st = 0 Then
 List1.AddItem "Write Card OK!"
Else
 List1.AddItem "Write Card Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
End If
DoEvents

st = IC_Read_Hex(ByVal icdev, StarAddr, Length, ByVal ReadStr$)
If st = 0 Then
 List1.AddItem "Read Card OK!"
 List1.AddItem ReadStr
Else
 List1.AddItem "Read Card Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
End If
DoEvents

If Mid(ReadStr, 1, Length * 2) = Mid(WriteStr, 1, Length * 2) Then
  List1.AddItem "写固定数据 Comp Read Data and Write Data OK!"
Else
  List1.AddItem "写固定数据 Comp Read Data and Write Data Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
End If
DoEvents
   
StarAddr = 29
Length = 3
WriteStr = "333"
''st = IC_WriteProtection(icdev, StarAddr, Length, Left(WriteStr, 3))
If st < 0 Then
List1.AddItem "IC_WriteProtection Error"
Else
List1.AddItem "IC_WriteProtection OK"
List1.AddItem WriteStr
End If


st = IC_ReadProtection_Hex(icdev, StarAddr, Length, ReadStr)
If st < 0 Then
List1.AddItem "IC_ReadProtection_Hex Error"
Else
List1.AddItem "IC_ReadProtection_Hex OK"
List1.AddItem ReadStr
End If
Password = "ffffff"
st = IC_ChangePass_4442hex(ByVal icdev&, ByVal Password$)
If st < 0 Then
    List1.AddItem "Change Card Password Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
Else
    List1.AddItem "Change Card Password OK!"
End If

st = IC_Down(ByVal icdev)
If st < 0 Then
    List1.AddItem "IC_Down Error!"
    List1.Selected(List1.ListCount() - 1) = True
    Exit Sub
Else
    List1.AddItem "IC_Down OK!"
End If
    List1.Selected(List1.ListCount() - 1) = True

End Sub

Private Sub Command3_click()
If icdev > 0 Then
  st = IC_ExitComm(icdev) 'Close COM
  icdev = 0
End If
  Unload Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
If icdev > 0 Then
 st = IC_ExitComm(icdev) 'Close COM
End If
End Sub
