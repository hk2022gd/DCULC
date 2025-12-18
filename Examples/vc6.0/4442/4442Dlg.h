// 4442Dlg.h : header file
//

#if !defined(AFX_4442DLG_H__68983DC7_7EB3_4EA4_93AC_30EBF0EA1F6D__INCLUDED_)
#define AFX_4442DLG_H__68983DC7_7EB3_4EA4_93AC_30EBF0EA1F6D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CMy4442Dlg dialog

class CMy4442Dlg : public CDialog
{
// Construction
public:
	int st;
	HANDLE icdev;
	CMy4442Dlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CMy4442Dlg)
	enum { IDD = IDD_MY4442_DIALOG };
	CListBox	m_list1;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMy4442Dlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CMy4442Dlg)
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

#endif // !defined(AFX_4442DLG_H__68983DC7_7EB3_4EA4_93AC_30EBF0EA1F6D__INCLUDED_)
