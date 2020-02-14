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
        ///Функция получения размера файла в байтах
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
    ///Процедура основного потока
   procedure MainThread;

begin
   { Если в потоке используем COM объекты то в начале и в конце
     потока используем функцию CoInitialize(nil)
              }
      CoInitialize(nil);
Form1.XMLDocument1.Active := false;
Form1.XMLDocument1.Active := True;
     /// Выключаем режим автосохранения и включаем режим форматирования XML текста.
  Form1.XMLDocument1.Options := Form1.XMLDocument1.Options + [doNodeAutoIndent] - [doAutoSave];

  Form1.XMLDocument1.Version := '1.0';
  Form1.XMLDocument1.Encoding := 'utf-8';
   ///Формируем XML документ главный узел документа
  Doc := Form1.XMLDocument1.AddChild('document');

  Node := Doc.AddChild('ПодсчетаСуммыКаждогоФайлаВПапке');
  Node.Attributes['ИмяПапки'] := TPath.GetFileNameWithoutExtension(sDir);
  Node.Attributes['СуммаВсехФайловВбайтах'] := inttostr(summofbytes);
 /////Добавляем данные на узлы и на аттрибуты
for i := 0 to Length(files) - 1 do
begin
    if (extractfilename(files[i])='SummOfBytes.xml') then continue;
    ChNode := Node.AddChild('Имя');
    ChNode.Attributes['Файла'] := extractfilename(files[i]);


      ChNode.Attributes['РазмерФайлаВбайтах'] := inttostr(FileSizeInByte(files[i]));

 form1.ListBox1.Items.Add(extractfilename(files[i])+ '  ' + inttostr(FileSizeInByte(files[i])));

  end;

   //////Сохранить данные в XML документ
form1.XMLDocument1.SaveToFile(sDir+'\SummOfBytes.xml');
  form1.ListBox1.Items.Add('Сумма в байтах всех файлов'+ '  ' + inttostr(summofbytes));

 CoInitialize(nil);
end;



 ///Процедура второго потока
procedure SecondThread;
begin
 ///Процедура расчитывает общую сумму байтов всех файлов
summofbytes:=0;

for i := 0 to Length(files) - 1 do
begin
///В расчёт суммы всех байтов не включается созданный программой файл SummOfBytes.xml
if (extractfilename(files[i])='SummOfBytes.xml') then continue;

summofbytes:=summofbytes+FileSizeInByte(files[i]);
end;

end;
procedure TForm1.Button1Click(Sender: TObject);
begin
///Вызов окна выбора папки
SelectDirectory('Bыбрать папку','',sDir);
{
Проверка выбрал ли пользователь папку если выбрал то получаем все имена и пути файлов
 присваеваем их в массив запускаем процедуры в потоке паралельно используем API функцию потока для этого.
  Подсчет суммы всех файлов выполняться не в контексте основного потока.
 }
if sDir<>'' then begin

files := TDirectory.GetFiles(sDir, '*.*', TSearchOption.soAllDirectories);
CloseHandle(BeginThread(nil, 0, @MainThread, nil, 0, ThrID1));
CloseHandle(BeginThread(nil, 0, @SecondThread, nil, 0, ThrID2));

end;
end;

end.
