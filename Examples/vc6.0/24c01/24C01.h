// 24C01.h : main header file for the 24C01 application
//

#if !defined(AFX_24C01_H__556F1858_8B9C_4072_8882_0006A8ADCDF8__INCLUDED_)
#define AFX_24C01_H__556F1858_8B9C_4072_8882_0006A8ADCDF8__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMy24C01App:
// See 24C01.cpp for the implementation of this class
//

class CMy24C01App : public CWinApp
{
public:
	CMy24C01App();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy24C01App)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMy24C01App)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_24C01_H__556F1858_8B9C_4072_8882_0006A8ADCDF8__INCLUDED_)
