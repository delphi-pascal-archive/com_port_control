//********************************************************************
// Pilotage de 8 sorties avec un CD4094 depuis le port COM
//********************************************************************

unit C_L_4094;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, PORTUtil, ImgList, ExtCtrls, jpeg;

type
  TForm1 = class(TForm)
    GroupBoxS: TGroupBox;
    ImageListe: TImageList;
    ComboCOM: TComboBox;
    Image1: TImage;
    LedSortie1: TImage;
    LedSortie2: TImage;
    LedSortie3: TImage;
    LedSortie4: TImage;
    LedSortie5: TImage;
    LedSortie6: TImage;
    LedSortie7: TImage;
    LedSortie8: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LedSortie1Click(Sender: TObject);
    procedure ComboCOMClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  SortieVal:byte;

implementation

{$R *.dfm}

//**************************************************
// Au démarrage Lister les ports dispo et led a off
//**************************************************
procedure TForm1.FormCreate(Sender: TObject);
var   i: Integer;
      PortCOM: HWND;
begin
  ComboCOMClick(ComboCOM);      // Toutes les Leds OFF

  for i := 1 to 16 do begin     // Recherche des port disponibles
    PortCOM := CreateFile(PChar('COM' + inttostr(i)), GENERIC_READ or GENERIC_WRITE,
                  0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);

    if PortCOM <> INVALID_HANDLE_VALUE then begin
      CloseHandle(PortCOM);
      ComboCOM.Items.Add('COM' + inttostr(i));   // Ajout du port valide
    end;
  end;

  if ComboCOM.Items.Count=0 then begin      // Si aucun^port disponible
    MessageDlg('Pas de Port disponible sur cette machine !',mtError	,[mbOk],0);
    ComboCOM.Items.Add('indisponible');
    GroupBoxS.Enabled := False;
  end;

  ComboCOM.ItemIndex := 0;       // Pointer sur le premier port dispo
end;


//************************************************************
// Sur le click d'une led actualiser led et repercution sur CI
//************************************************************
procedure TForm1.LedSortie1Click(Sender: TObject);
Var i,PosBit: Integer;
begin
  if (Sender as TImage).Canvas.Pixels[10,10]= $848684 then  // états suivant couleur
    begin
        SortieVal := SortieVal + (Sender as TImage).Tag;    // Sortie 1, 2 ...,8 = 1
      ImageListe.GetBitmap(0,(Sender as TImage).Picture.Bitmap);  // Led (ON)
    end
  else
    begin
        SortieVal := SortieVal - (sender as TImage).Tag;    // Sortie 1, 2 ...,8 = 0
      ImageListe.GetBitmap(1,(Sender as TImage).Picture.Bitmap);  // Led (OFF)
    end;

  (Sender as TImage).Refresh;  // Actualiser l'affichage

  OPENCOM(pchar(ComboCOM.Items[ComboCOM.ItemIndex]));  // Ouvrir port COMx
  TXD(0);                      // Verrouillage des sorties STROBE=0
  DTR(0);                      // Entrée Data du 4094 = 0
  PosBit:=1;                   // Premier bit

  for i :=1 to 8 do begin      // Pour 8 bits
    RTS(0);                    // Entrée Clock du 4094 = 0
    if SortieVal and PosBit = PosBit then DTR(1) else DTR(0) ; // Fixer bit suivant...
    DELAYUS (1);               // Delais validation CI
    RTS(1);                    // Cycle Horloge 4094
    DELAYUS (1);               // ...
    PosBit := PosBit shl 1;    // passer au bit suivant
  end;

  TXD(1);                      // Déverrouillage des sorties STROBE=1

  CLOSECOM;           // Fermer le port serie
end;


//**************************************************
// Led off  et  SortieVal := 0;
//**************************************************
procedure TForm1.ComboCOMClick(Sender: TObject);
Var i: Integer;
begin
  For i := 0 To ComponentCount -1 Do      // Tous les
    If Components[i] Is TImage and not(TImage(Components[i]).Name='Image1') Then
      ImageListe.GetBitmap(1,TImage(Components[i]).Picture.Bitmap);  // Led (OFF)

  GroupBoxS.Repaint;   // actualiser l'affichage
  SortieVal := 0;      // init val sortie
end;


end.
