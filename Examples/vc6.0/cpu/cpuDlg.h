// cpuDlg.h : header file
//

#if !defined(AFX_CPUDLG_H__EE62A73E_6EED_4C32_88E7_CDDA61D7CE9F__INCLUDED_)
#define AFX_CPUDLG_H__EE62A73E_6EED_4C32_88E7_CDDA61D7CE9F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CCpuDlg dialog

class CCpuDlg : public CDialog
{
// Construction
public:
	CCpuDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CCpuDlg)
	enum { IDD = IDD_CPU_DIALOG };
	CListBox	m_list1;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CCpuDlg)
	public:
	virtual BOOL DestroyWindow();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CCpuDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnButton1();
	afx_msg void OnButton2();
	afx_msg void OnButton3();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
private:
	int ic_type;
	int st;
	HANDLE icdev;
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_CPUDLG_H__EE62A73E_6EED_4C32_88E7_CDDA61D7CE9F__INCLUDED_)
