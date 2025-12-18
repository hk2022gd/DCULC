unit Test24c64;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrm24c64 = class(TForm)
    List1: TListBox;
    Button1: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
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
  Frm24c64:TFrm24c64;
  outbuff:pchar; //输出缓冲区
  inbuff:string; //输入缓冲区
implementation

uses drv_unit;

{$R *.DFM}

procedure TFrm24c64.Button1Click(Sender: TObject);
begin
 icdev := IC_InitComm(100); //打开USB端口                                        //初始化串口一
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


procedure TFrm24c64.Button3Click(Sender: TObject);

begin
   
 st := IC_InitType(icdev, 192);
 If st <> 0 Then begin                                                //给卡型号
     List1.Items.add('调用 IC_InitType函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_InitType函数成功');
                                                                    ///写数据
 inbuff:='0011223344556677';
 st := IC_Write64_Hex(icdev, 10,8,pchar(inbuff));
 If st <> 0 Then begin
     List1.Items.add('调用 IC_Write64_Hex函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_Write64_Hex函数成功'+inbuff);

 getmem(outbuff,18);
 st := IC_Read_hex(icdev, 10,8,outbuff);                                //读数据
 If st <> 0 Then begin
     List1.Items.add('调用 IC_Read_Hex函数出错');
     freemem(outbuff);
     Exit;
 End;
 List1.Items.add('调用 IC_Read_Hex函数成功');
 outbuff[16]:=chr(0);
 List1.items.add('数据为:'+outbuff);
 if copy(inbuff,1,16)<>copy(outbuff,1,16) then begin
 list1.Items.Add('comapa data error');
 FreeMem(outbuff);
 Exit;
 end;
 list1.Items.Add('compa data ok');
 freemem(outbuff);

 List1.Items.add('读写设备测试通过!');

end;

procedure TFrm24c64.Button4Click(Sender: TObject);
begin
if icdev>0 then begin
 st := IC_ExitComm(icdev);                                            //关闭串口
 icdev:=0;
 end;
 close;
end;

end.
