unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,System.IOUtils,System.Types,FileCtrl,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,ActiveX, Vcl.ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    XMLDocument1: TXMLDocument;
    ListBox1: TListBox;

    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  hThr1, hThr2: THandle;
ThrID1, ThrID2: DWORD;
files: TStringDynArray;
 sDir:String;
 i:integer;
 summofbytes:Int64;
 Doc, Node, ChNode : IXMLNode;
implementation

{$R *.dfm}
        ///������� ��������� ������� ����� � ������
function FileSizeInByte(fileName : wideString) : Int64;
var
sr : TSearchRec;
begin
if FindFirst(fileName, faAnyFile, sr ) = 0 then
result := Int64(sr.FindData.nFileSizeHigh) shl Int64(32) + Int64(sr.FindData.nFileSizeLow)
else
result := -1;
FindClose(sr);
end;
    ///��������� ��������� ������
   procedure MainThread;

begin

      CoInitialize(nil);
Form1.XMLDocument1.Active := false;
Form1.XMLDocument1.Active := True;

  Form1.XMLDocument1.Options := Form1.XMLDocument1.Options + [doNodeAutoIndent] - [doAutoSave];

  Form1.XMLDocument1.Version := '1.0';
  Form1.XMLDocument1.Encoding := 'utf-8';

  Doc := Form1.XMLDocument1.AddChild('document');

  Node := Doc.AddChild('�������������������������������');
  Node.Attributes['��������'] := TPath.GetFileNameWithoutExtension(sDir);
  Node.Attributes['����������������������'] := inttostr(summofbytes);

for i := 0 to Length(files) - 1 do
begin
    if (extractfilename(files[i])='SummOfBytes.xml') then continue;
    ChNode := Node.AddChild('���');
    ChNode.Attributes['�����'] := extractfilename(files[i]);


      ChNode.Attributes['������������������'] := inttostr(FileSizeInByte(files[i]));

 form1.ListBox1.Items.Add(extractfilename(files[i])+ '  ' + inttostr(FileSizeInByte(files[i])));

  end;


form1.XMLDocument1.SaveToFile(sDir+'\SummOfBytes.xml');
  form1.ListBox1.Items.Add('����� � ������ ���� ������'+ '  ' + inttostr(summofbytes));

 CoInitialize(nil);
end;



 ///��������� ������� ������
procedure SecondThread;
begin
summofbytes:=0;
for i := 0 to Length(files) - 1 do
begin
if (extractfilename(files[i])='SummOfBytes.xml') then continue;

summofbytes:=summofbytes+FileSizeInByte(files[i]);
end;

end;
procedure TForm1.Button1Click(Sender: TObject);
begin
///����� ���� ������ �����
SelectDirectory('B������ �����','',sDir);
{
�������� ������ �� ������������ ����� ���� ������ �� �������� ��� ����� � ���� ������
 ����������� �� � ������ ��������� ��������� � ������ ���������� ���������� API ������� ������ ��� �����.
  ������� ����� ���� ������ ����������� �� � ��������� ��������� ������.
 }
if sDir<>'' then begin

files := TDirectory.GetFiles(sDir, '*.*', TSearchOption.soAllDirectories);
CloseHandle(BeginThread(nil, 0, @MainThread, nil, 0, ThrID1));
CloseHandle(BeginThread(nil, 0, @SecondThread, nil, 0, ThrID2));

end;
end;

end.
