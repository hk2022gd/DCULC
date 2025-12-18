Attribute VB_Name = "Module1"
Global icdev As Long
'example for add_s to dculc.dll
'useful function.
Declare Function IC_InitComm Lib "dculc.dll" (ByVal Port%) As Long
Declare Function IC_ExitComm% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_Down% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_InitType% Lib "dculc.dll" (ByVal icdev As Long, ByVal TypeNo%)
Declare Function IC_Status% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_Read% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal Databuffer$)
Declare Function IC_Read_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal Databuffer$)
Declare Function IC_Write% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
'4442
Declare Function IC_ReadProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_WriteProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_ReadCount_SLE4442% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_CheckPass_SLE4442% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_CheckPass_SLE4442hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_SLE4442% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
'4428
Declare Function IC_ReadWithProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_WriteWithProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%)
Declare Function IC_ReadCount_SLE4428% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_CheckPass_SLE4428% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_SLE4428% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
'ATMEL24C
Declare Function IC_Write24% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write24_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)

'CPU card
Declare Function IC_CpuReset_Hex Lib "dculc.dll" (ByVal icdev As Long, ByRef rlen As Byte, ByVal sdata$) As Integer
Declare Function IC_CpuApdu_Hex Lib "dculc.dll" (ByVal icdev As Long, ByVal slen%, ByVal senddata$, ByRef rlen As Byte, ByVal recdata As String) As Integer


