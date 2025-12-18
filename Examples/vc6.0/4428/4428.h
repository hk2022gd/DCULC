// 4428.h : main header file for the 4428 application
//

#if !defined(AFX_4428_H__B55BCE89_1B21_449F_8C27_C3619BB44A7B__INCLUDED_)
#define AFX_4428_H__B55BCE89_1B21_449F_8C27_C3619BB44A7B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMy4428App:
// See 4428.cpp for the implementation of this class
//

class CMy4428App : public CWinApp
{
public:
	CMy4428App();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy4428App)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMy4428App)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_4428_H__B55BCE89_1B21_449F_8C27_C3619BB44A7B__INCLUDED_)
