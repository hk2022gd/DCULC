// cpu.h : main header file for the CPU application
//

#if !defined(AFX_CPU_H__DB90EA50_946D_4713_9D26_95470D0121AA__INCLUDED_)
#define AFX_CPU_H__DB90EA50_946D_4713_9D26_95470D0121AA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CCpuApp:
// See cpu.cpp for the implementation of this class
//

class CCpuApp : public CWinApp
{
public:
	CCpuApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCpuApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CCpuApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CPU_H__DB90EA50_946D_4713_9D26_95470D0121AA__INCLUDED_)
