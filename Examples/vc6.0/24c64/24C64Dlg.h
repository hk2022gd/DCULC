// 24C64Dlg.h : header file
//

#if !defined(AFX_24C64DLG_H__127E74AF_7E28_40FE_9A1C_F5A67FBD2118__INCLUDED_)
#define AFX_24C64DLG_H__127E74AF_7E28_40FE_9A1C_F5A67FBD2118__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CMy24C64Dlg dialog

class CMy24C64Dlg : public CDialog
{
// Construction
public:
	int st;
	HANDLE icdev;
	CMy24C64Dlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CMy24C64Dlg)
	enum { IDD = IDD_MY24C64_DIALOG };
	CListBox	m_list1;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy24C64Dlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CMy24C64Dlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnButton1();
	afx_msg void OnButton2();
	afx_msg void OnButton3();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_24C64DLG_H__127E74AF_7E28_40FE_9A1C_F5A67FBD2118__INCLUDED_)
