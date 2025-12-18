VERSION 5.00
Begin VB.Form frmcpu 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H00C0C0C0&
   Caption         =   "CPU TEST"
   ClientHeight    =   4020
   ClientLeft      =   1275
   ClientTop       =   1680
   ClientWidth     =   7365
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   LinkTopic       =   "Form3"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4020
   ScaleWidth      =   7365
   Begin VB.CommandButton Command1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Init Ic"
      Height          =   495
      Left            =   5880
      TabIndex        =   3
      Top             =   720
      Width           =   1215
   End
   Begin VB.CommandButton cpu 
      Caption         =   "CPU"
      Height          =   495
      Left            =   5880
      TabIndex        =   2
      Top             =   1680
      Width           =   1215
   End
   Begin VB.CommandButton Command3 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "End"
      Height          =   495
      Left            =   5880
      TabIndex        =   1
      Top             =   2640
      Width           =   1215
   End
   Begin VB.ListBox List1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFF00&
      Height          =   3735
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   5535
   End
End
Attribute VB_Name = "frmcpu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim st%
Dim cardtype As Integer
Dim cardcircle As Integer '循环次数


Private Sub Command1_click()
   '初始化端口，100表示USB端口
   icdev = IC_InitComm(100)
    If icdev <= 0 Then
      List1.AddItem ("Init COM Error!")
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
    End If
    st = IC_Status(ByVal icdev&)
    DoEvents
    If st < 0 Then
            List1.AddItem "0: ic_status is error! Return: " + Str(st)
      List1.Selected(List1.ListCount() - 1) = True
            Exit Sub
    Else
        List1.AddItem "0: ic_status is ok!"
    End If
    '''''''''''''''''''''''''''''''''''''''''''''''''
    'ic_inittype.
    st = IC_InitType(ByVal icdev&, cardtype)
    If st < 0 Then
        List1.AddItem "ic_inittype() is error! Return: " + Str(st)
      List1.Selected(List1.ListCount() - 1) = True
        Exit Sub
    Else
        List1.AddItem "ic_inittype() is ok!"
    End If
    
      List1.Selected(List1.ListCount() - 1) = True
End Sub



Private Sub Command3_click()
If icdev > 0 Then
st = IC_ExitComm(icdev)
icdev = 0
End If
End
End Sub

Private Sub cpu_Click()

Dim data1 As String * 100
Dim data2 As String * 100
Dim key As String * 100
Dim slen As Byte
Dim rlen As Byte
List1.AddItem "Begin test,please waiting...."
List1.Selected(List1.ListCount() - 1) = True

    '''''''''''''''''''''''''''''''''''''''''''''''''
    'ic_inittype.
    st = IC_InitType(ByVal icdev&, cardtype)
    If st < 0 Then
        List1.AddItem "ic_inittype() is error! Return: " + Str(st)
      List1.Selected(List1.ListCount() - 1) = True
        Exit Sub
    Else
        List1.AddItem "ic_inittype() is ok!"
    End If

cardcircle = 20
For i = 0 To cardcircle
List1.AddItem Str(i)
List1.Selected(List1.ListCount() - 1) = True
DoEvents
st = IC_CpuReset_Hex(ByVal icdev, rlen, data1)
If st <> 0 Then
      List1.AddItem ("调用 IC_CpuReset函数出错")
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
End If
List1.AddItem ("调用 IC_CpuReset()函数成功")
List1.AddItem data1


slen = 5
data1 = "0084000008"
st = IC_CpuApdu_Hex(icdev, ByVal slen, ByVal data1, rlen, ByVal data2)
If st <> 0 Then
      List1.AddItem ("调用 IC_CpuApdu函数出错")
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
End If
List1.AddItem ("调用 IC_CpuApdu()函数成功")
List1.AddItem data2
Next i


st = IC_Down(icdev)
If st <> 0 Then
      List1.AddItem ("调用 IC_Down 函数出错")
      List1.Selected(List1.ListCount() - 1) = True
      Exit Sub
End If
List1.AddItem ("调用 IC_Down 函数成功")
List1.Selected(List1.ListCount() - 1) = True
End Sub

Private Sub Form_Load()

cardtype = 12

End Sub

Private Sub Form_Unload(Cancel As Integer)
If icdev > 0 Then
   st = IC_ExitComm(icdev)
End If
End Sub

Private Sub List1_DblClick()
List1.Clear
List1.Refresh

End Sub


