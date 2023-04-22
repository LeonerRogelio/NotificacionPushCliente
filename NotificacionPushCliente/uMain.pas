unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  REST.Backend.PushTypes, System.JSON, REST.Backend.EMSPushDevice,
  System.PushNotification, Data.Bind.Components, Data.Bind.ObjectScope,
  REST.Backend.BindSource, REST.Backend.PushDevice, REST.Backend.EMSProvider,
  FMX.ScrollBox, FMX.Memo, FMX.TabControl, FMX.Edit, FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Platform; // para Clipboard support.

type
  TfrmMain = class(TForm)
    Panel1: TPanel;
    btnCopy2Clipboard: TButton;
    swtEnableNotifications: TSwitch;
    Label1: TLabel;
    edtToken: TEdit;
    TabControl: TTabControl;
    tabMesagges: TTabItem;
    Memo1: TMemo;
    tabLog: TTabItem;
    memLog: TMemo;
    EMSProvider: TEMSProvider;
    PushEvents: TPushEvents;
    procedure PushEventsDeviceTokenReceived(Sender: TObject);
    procedure PushEventsPushReceived(Sender: TObject; const AData: TPushData);
    procedure swtEnableNotificationsSwitch(Sender: TObject);
    procedure btnCopy2ClipboardClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.btnCopy2ClipboardClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc)
  then
  begin
    Svc.SetClipboard(edtToken.Text);
    ShowMessage('Token copiado al portapeles');
  end;
end;

{ Para Para recibir el token que se indicó en la consola de la “API Google” que servirá para el
  proyecto del servidor }
procedure TfrmMain.PushEventsDeviceTokenReceived(Sender: TObject);
begin
  Memo1.Lines.Add(PushEvents.DeviceToken);
end;

{ Para recibir los mensajes de notificaciones. }
procedure TfrmMain.PushEventsPushReceived(Sender: TObject;
  const AData: TPushData);
var
  i: integer;
begin
  Memo1.Lines.Add(AData.Message);
  for i := 0 to AData.Extras.Count - 1 do
    Memo1.Lines.Add(AData.Extras[i].Key + '=' + AData.Extras[i].Value);
end;

{ Para activar el servicio de notificaciones. }
procedure TfrmMain.swtEnableNotificationsSwitch(Sender: TObject);
var
  notify: TPushData;
  i: integer;
begin
  try
    PushEvents.Active := true;
    notify := PushEvents.StartupNotification;
  except
    on E: Exception do
      Memo1.Lines.Add(E.ToString);
  end;
  try
    if Assigned(notify) then
    begin
      Memo1.Lines.Add(notify.Message);
      // Android : Google Cloud Messaging
      if PushEvents.StartupNotification.GCM.Message <> '' then
      begin
        for i := 0 to notify.Extras.Count - 1 do
          Memo1.Lines.Add(notify.Extras[i].Key + '=' + notify.Extras[i].Value);
      end;
      // iOS : Apple Push notifications Service
      if PushEvents.StartupNotification.APS.Alert <> '' then
      begin
        for i := 0 to notify.Extras.Count - 1 do
          Memo1.Lines.Add(notify.Extras[i].Key + '=' + notify.Extras[i].Value);
      end;
    end;
  finally
    notify.DisposeOf;
  end;

end;

end.
