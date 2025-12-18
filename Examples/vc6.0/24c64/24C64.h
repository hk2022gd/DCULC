// 24C64.h : main header file for the 24C64 application
//

#if !defined(AFX_24C64_H__99BDA047_B631_41EF_96B7_E240A361D3EE__INCLUDED_)
#define AFX_24C64_H__99BDA047_B631_41EF_96B7_E240A361D3EE__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMy24C64App:
// See 24C64.cpp for the implementation of this class
//

class CMy24C64App : public CWinApp
{
public:
	CMy24C64App();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy24C64App)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMy24C64App)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_24C64_H__99BDA047_B631_41EF_96B7_E240A361D3EE__INCLUDED_)
