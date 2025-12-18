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

Declare Function IC_Write24% Lib "dculc.dll" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByVal Databuffer$)

Declare Function IC_Write24hex% Lib "dculc.dll" Alias "IC_Write24" (ByVal icdev As Long, ByVal offset%, ByVal length%, ByRef Databuffer As Byte)
Declare Function asc2hex% Lib "dculc.dll" (ByRef asc As Byte, ByVal hex As String, ByVal length%)
Declare Function hex2asc% Lib "dculc.dll" (ByVal hex As String, ByRef asc As Byte, ByVal length%)


Global icdev As Long  'define COM Handle


