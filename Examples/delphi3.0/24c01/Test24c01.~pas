unit Test24c01;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrm24c01 = class(TForm)
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
  Frm24c01:TFrm24c01;
  outbuff:pchar; //输出缓冲区
  inbuff:string; //输入缓冲区
  source,dest:array[0..16]of char;
  //dd:array[3.....34] of char;
implementation

uses drv_unit;

{$R *.DFM}

procedure TFrm24c01.Button1Click(Sender: TObject);
begin
 icdev := IC_InitComm(100);                                         //初始化串口一
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


procedure TFrm24c01.Button3Click(Sender: TObject);

begin
  inbuff:='0011223344556677';
 st := IC_InitType(icdev, 64);                                        //给卡型号
 If st <> 0 Then begin
     List1.Items.add('调用 IC_InitType函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_InitType函数成功');

                                                                      //写卡
 st := IC_Write24_Hex(icdev, 10,8,pchar(inbuff));
 If st <> 0 Then begin
     List1.Items.add('调用 IC_Write24_Hex函数出错');
     Exit;
 End;
 List1.Items.add('调用 IC_Write24_Hex函数成功');

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
 list1.Items.Add('compa data error');
 FreeMem(outbuff);
 Exit;
 end;
 list1.Items.Add('compa data ok ');
 freemem(outbuff);
 application.ProcessMessages ;

 

 List1.Items.add('读写设备测试通过!');

end;

procedure TFrm24c01.Button4Click(Sender: TObject);
begin
 st := IC_ExitComm(icdev);
 close
end;

end.
