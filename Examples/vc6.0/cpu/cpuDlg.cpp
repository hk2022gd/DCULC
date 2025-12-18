// cpuDlg.cpp : implementation file
//

#include "stdafx.h"
#include "cpu.h"
#include "cpuDlg.h"
#include "dculc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CCpuDlg dialog

CCpuDlg::CCpuDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CCpuDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CCpuDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CCpuDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CCpuDlg)
	DDX_Control(pDX, IDC_LIST1, m_list1);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CCpuDlg, CDialog)
	//{{AFX_MSG_MAP(CCpuDlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON1, OnButton1)
	ON_BN_CLICKED(IDC_BUTTON2, OnButton2)
	ON_BN_CLICKED(IDC_BUTTON3, OnButton3)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CCpuDlg message handlers

BOOL CCpuDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	UpdateData(FALSE);
	ic_type=12;
	icdev=0;
	st=0;
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CCpuDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CCpuDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CCpuDlg::OnButton1() 
{
	// TODO: Add your control notification handler code here
	//初始化端口，100表示USB端口
	icdev=IC_InitComm(100);
	if ((int)icdev<=0)
	{
		m_list1.AddString ("IC_InitComm Error");
		return;
	}
	m_list1.AddString ("IC_InitComm ok");
}

void CCpuDlg::OnButton2() 
{
	// TODO: Add your control notification handler code here
	
	st=IC_InitType(icdev,0x12);
	if (st!=0)
	{
		m_list1.AddString ("IC_InitType Error");
		return;
	}
	m_list1.AddString("IC_InitType OK");
	
	
	st=IC_Status(icdev);
	if (st==1)
	{
		m_list1.AddString("No card");
		return;
	}
	if (st)
	{
		m_list1.AddString("IC_Status Error");
		return;
	}
	m_list1.AddString("IC_Status OK");
	
	unsigned char relen;
	unsigned char redata[64];
	st=IC_CpuReset_Hex(icdev,&relen,redata);
	if (st!=0)
	{
		CString temp;
		temp.Format("%d",st);
		m_list1.AddString ("IC_CpuReset_Hex Error,Error : "+temp);
		return;
	}
	m_list1.AddString ("IC_CpuReset_Hex ok");
	redata[2*relen]=0;
	m_list1.AddString ((const char *)redata);
	unsigned char sedata[64]={"0084000008"};
	st=IC_CpuApdu_Hex(icdev,5,sedata,&relen,redata);
	if (st!=0)
	{
		CString temp;
		temp.Format("%d",st);
		m_list1.AddString ("IC_CpuApdu_Hex Error,Error Number is "+temp);
		return;
	}
	m_list1.AddString ("IC_CpuApdu_Hex ok");
	redata[2*relen]=0;
	m_list1.AddString ((const char *)redata);
	
}

void CCpuDlg::OnButton3() 
{
	// TODO: Add your control notification handler code here
	if ((int)icdev>0)
	{
		IC_ExitComm(icdev);
		icdev=0;
	}
	OnOK();
}



BOOL CCpuDlg::DestroyWindow() 
{
	// TODO: Add your specialized code here and/or call the base class
	if ((int)icdev>0)
		IC_ExitComm(icdev);
	return CDialog::DestroyWindow();
}
