// 4428Dlg.h : header file
//

#if !defined(AFX_4428DLG_H__AA6E87A3_5B3A_4638_8742_9300355A3328__INCLUDED_)
#define AFX_4428DLG_H__AA6E87A3_5B3A_4638_8742_9300355A3328__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CMy4428Dlg dialog

class CMy4428Dlg : public CDialog
{
// Construction
public:
	int st;
	HANDLE icdev;
	CMy4428Dlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CMy4428Dlg)
	enum { IDD = IDD_MY4428_DIALOG };
	CListBox	m_list1;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy4428Dlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CMy4428Dlg)
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

#endif // !defined(AFX_4428DLG_H__AA6E87A3_5B3A_4638_8742_9300355A3328__INCLUDED_)
