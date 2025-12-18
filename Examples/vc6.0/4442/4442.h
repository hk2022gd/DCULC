// 4442.h : main header file for the 4442 application
//

#if !defined(AFX_4442_H__33C5CCAA_50EA_48C3_8078_81B0A7C3B550__INCLUDED_)
#define AFX_4442_H__33C5CCAA_50EA_48C3_8078_81B0A7C3B550__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMy4442App:
// See 4442.cpp for the implementation of this class
//

class CMy4442App : public CWinApp
{
public:
	CMy4442App();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy4442App)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMy4442App)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_4442_H__33C5CCAA_50EA_48C3_8078_81B0A7C3B550__INCLUDED_)
