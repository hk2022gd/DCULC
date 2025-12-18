unit Test4442;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrm4442 = class(TForm)
    List1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  icdev:longint;
  st:smallint;
  Frm4442:TFrm4442;
  outbuff:pchar; //输出缓冲区
  inbuff:string; //输入缓冲区
implementation

uses drv_unit;

{$R *.DFM}

procedure TFrm4442.Button1Click(Sender: TObject);
begin

 icdev := IC_InitComm(100);  //打开USB端口                                       //初始化串口一
  If icdev < 0 Then begin
      List1.items.Add('调用 IC_InitComm()函数出错!');
     exit;
 end;
 List1.Items.add('调用 IC_InitComm()函数成功!');


 st := IC_Status(icdev);
 If st <0 Then begin
      List1.items.add('读写器存在错误!');
      exit;
 end;
 List1.items.add('调用 IC_Status()函数成功!');

 If st = 1 Then
      List1.items.add('没有卡!')
 else
       List1.items.add('有卡!');


end;

procedure TFrm4442.Button2Click(Sender: TObject);
begin

     
 st := IC_InitType(icdev, 16);                                        //给卡型号
 If st <> 0 Then begin
     List1.Items.add('调用 IC_InitType函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_InitType函数成功');

 st := IC_ReadCount_SLE4442(icdev);
 If st < 0 Then begin
     List1.Items.add('调用 IC_ReadCount_SLE4442函数出错');
     Exit;
 End;

 List1.Items.add('调用 IC_ReadCount_SLE4442函数成功');
 List1.Items.add('错误记数器为'+inttostr(st));


 inbuff:='ffffff';                                                    //核对密码
 st := IC_CheckPass_4442hex(icdev,pchar(inbuff));
 If st <> 0 Then begin
     List1.Items.add('调用 IC_CheckPass_4442hex函数出错');
     Exit;
 End;

 List1.Items.add('调用 IC_CheckPass_4442hex函数成功');

end;

procedure TFrm4442.Button3Click(Sender: TObject);

begin

 inbuff:='001122334455';                                                //写数据
 st := IC_Write_hex(icdev, 40,6,pchar(inbuff));
 If st <> 0 Then begin
     List1.Items.add('调用 IC_Write_Hex函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_Write_Hex函数成功');

 getmem(outbuff,15);                                                    //读数据
 st := IC_Read_hex(icdev, 40,6,outbuff);
 If st <> 0 Then begin
     List1.Items.add('调用 IC_Read_Hex函数出错');
     freemem(outbuff);
     Exit;
 End;
 List1.Items.add('调用 IC_Read_Hex函数成功');
 outbuff[12]:=chr(0);
 List1.items.add('数据为:'+outbuff);
 if copy(inbuff,1,12)<>copy(outbuff,1,12) then begin
 list1.Items.Add('比较读数据与写数据错误');
 freemem(outbuff);
 exit;
 end;
 list1.Items.Add('比较读数据与写数据正确');
 freemem(outbuff);

 inbuff:='ffffff';                                                    //修改密码
 st := IC_ChangePass_4442hex(icdev,pchar(inbuff));
 If st <> 0 Then begin
     List1.Items.add('调用 IC_ChangePass_4442hex函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_ChangePass_4442hex函数成功');
 List1.Items.add('卡密码改为ffffff');


 List1.Items.add('读写设备测试通过!');

end;

procedure TFrm4442.Button4Click(Sender: TObject);
begin
 if icdev>0 then begin
 st := IC_ExitComm(icdev);                                            //关闭串口
 icdev:=0 ;
 end;
 close
end;

end.
