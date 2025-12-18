Attribute VB_Name = "Module1"
Declare Function IC_InitComm Lib "dculc.dll" (ByVal Port%) As Long
Declare Function IC_ExitComm% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_Down% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_InitType% Lib "dculc.dll" (ByVal icdev As Long, ByVal TypeNo%)
Declare Function IC_Status% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_Read% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal Databuffer$)
Declare Function IC_Read_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal Databuffer$)
Declare Function IC_Write% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function asc2hex% Lib "dculc.dll" (ByRef asc As Byte, ByVal hex As String, ByVal length%)
Declare Function hex2asc% Lib "dculc.dll" (ByVal hex As String, ByRef asc As Byte, ByVal length%)

'4442
Declare Function IC_ReadProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_WriteProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_ReadCount_SLE4442% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_CheckPass_SLE4442% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_CheckPass_4442hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_SLE4442% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_4442hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
'4428
Declare Function IC_ReadWithProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)
Declare Function IC_ReadWithProtection_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal ProtBuffer$)

Declare Function IC_WriteWithProtection% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal l%, ByVal data$)
Declare Function IC_ReadCount_SLE4428% Lib "dculc.dll" (ByVal icdev As Long)
Declare Function IC_CheckPass_SLE4428% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_SLE4428% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_CheckPass_4428hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
Declare Function IC_ChangePass_4428hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal Password$)
'ATMEL24C
Declare Function IC_Write24% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write24_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write64% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)
Declare Function IC_Write64_Hex% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)



Global icdev As Long  'define COM Handle


