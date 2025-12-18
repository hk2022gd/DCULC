// 24C01Dlg.cpp : implementation file
//

#include "stdafx.h"
#include "24C01.h"
#include "24C01Dlg.h"
#include "dculc.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMy24C01Dlg dialog

CMy24C01Dlg::CMy24C01Dlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMy24C01Dlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMy24C01Dlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CMy24C01Dlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMy24C01Dlg)
	DDX_Control(pDX, IDC_LIST1, m_list1);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CMy24C01Dlg, CDialog)
	//{{AFX_MSG_MAP(CMy24C01Dlg)
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_BUTTON1, OnButton1)
	ON_BN_CLICKED(IDC_BUTTON2, OnButton2)
	ON_BN_CLICKED(IDC_BUTTON3, OnButton3)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMy24C01Dlg message handlers

BOOL CMy24C01Dlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	st=0;
	return TRUE;  // return TRUE  unless you set the focus to a control
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CMy24C01Dlg::OnPaint() 
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
HCURSOR CMy24C01Dlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

void CMy24C01Dlg::OnButton1() 
{
	// TODO: Add your control notification handler code here
		
	//初始化端口,100表示USB端口

	icdev=IC_InitComm(100);
	if((int)icdev<0) 
	{
		m_list1.AddString("IC_InitComm Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	else
	{
		m_list1.AddString("IC_InitCOmm ok");
		m_list1.SetCurSel(m_list1.GetCount()-1);
	}
	st=IC_Status(icdev);
	if (st<0)
	{
		m_list1.AddString ("IC_status error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	else
		m_list1.AddString ("IC_status OK");
	if (st==1)
	{
		m_list1.AddString ("Reader No card,Please Insert....");
		m_list1.SetCurSel(m_list1.GetCount()-1);
	    return;
	}
	if (st==0)
		m_list1.AddString ("Have card,Please Test");
	m_list1.SetCurSel(m_list1.GetCount()-1);
    st=IC_InitType(icdev,64);
	if (st!=0)
	{
		m_list1.AddString("IC_InitType Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	else
	{
		m_list1.AddString("IC_InitType OK ,24c01 card");
	}	

}

void CMy24C01Dlg::OnButton2() 
{
	// TODO: Add your control notification handler code here

	CString strTmp;
	//Test 24C01 card
    m_list1.AddString("24C01 Test Begin,Please Waiting....");
	m_list1.SetCurSel(m_list1.GetCount()-1);
	
	MSG message;
		if(::PeekMessage(&message,NULL,0,0,PM_REMOVE))
		{
			::TranslateMessage(&message);
			::DispatchMessage(&message);
		}
	
	//给卡型号：24C01卡（64）

	st = IC_CheckCard(icdev);
	if (st<0)
	{
		m_list1.AddString("IC_Check_24C01 Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	strTmp.Format("IC_CheckCard %d",st);
	m_list1.AddString(strTmp);
	m_list1.SetCurSel(m_list1.GetCount()-1);
	
return ;
	//读写卡，然后比较读数据与写数据

	int offset;
	int length,i;
	offset=0;
	length=128;
	char WrData[1000];
	char ReData[1000];
	
	for (i=0;i<length;i++)
	{
		WrData[i]=rand();
	}
	st=IC_Write24(icdev,offset,length,(unsigned char *)WrData);
	if (st!=0)
	{
		m_list1.AddString("IC_Write Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		
	}
	else
	{
		m_list1.AddString("IC_Write OK ");
	}
	st=IC_Read(icdev,offset,length,(unsigned char *)ReData);
	if (st!=0)
	{
		m_list1.AddString("IC_Read Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	else
	{
		m_list1.AddString("IC_Read OK ");
		m_list1.AddString(ReData);
	}
	if(memcmp(ReData,WrData,length)==0)
	{
		m_list1.AddString("Comp Data OK");
    
	}
	else
	{
		m_list1.AddString("Comp Data Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
	st = IC_Down(icdev);
	if (st)
	{
		m_list1.AddString("IC_Down Error");
		m_list1.SetCurSel(m_list1.GetCount()-1);
		return;
	}
    m_list1.AddString("24C01 card Test OK");
    m_list1.SetCurSel(m_list1.GetCount()-1);	
	
}

void CMy24C01Dlg::OnButton3() 
{
	// TODO: Add your control notification handler code here
	
	//关闭端口
	if(int(icdev)>0)
	{
		st=IC_ExitComm(icdev);
		if(st!=0)
		{
			m_list1.AddString ("Exitcomm Error");
			m_list1.SetCurSel(m_list1.GetCount()-1);
		    return;
		}
		icdev=0;
	}
	OnOK();	
}
