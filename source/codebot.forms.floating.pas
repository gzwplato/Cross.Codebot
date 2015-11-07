(********************************************************)
(*                                                      *)
(*  Codebot Pascal Library                              *)
(*  http://cross.codebot.org                            *)
(*  Modified November 2015                              *)
(*                                                      *)
(********************************************************)

{ <include docs/codebot.forms.floating.txt> }
unit Codebot.Forms.Floating;

{$i codebot.inc}

interface

uses
  Classes, SysUtils, Controls, Forms,
  Codebot.System,
  Codebot.Graphics.Types;

{ TFloatingForm }

type
  TFloatingForm = class(TForm)
  private
    FWindow: Pointer;
    FOpacity: Byte;
    FFaded: Boolean;
    function GetCompositing: Boolean;
    procedure SetFaded(Value: Boolean);
    procedure SetOpacity(Value: Byte);
  protected
    procedure CreateHandle; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure MoveSize(Rect: TRectI);
    property Opacity: Byte read FOpacity write SetOpacity;
    property Compositing: Boolean read GetCompositing;
    property Faded: Boolean read FFaded write SetFaded;
  end;

implementation

{$if defined(linux) and defined(lclgtk2)}
uses
  GLib2, Gdk2, Gtk2, Gtk2Def, Gtk2Extra, Gtk2Globals,
  Codebot.Interop.Linux.NetWM;

procedure gdk_window_input_shape_combine_mask (window: PGdkWindow;
  mask: PGdkBitmap; x, y: GInt); cdecl; external gdklib;
function gtk_widget_get_window(widget: PGtkWidget): PGdkWindow; cdecl; external gtklib;
function gdk_window_get_screen(window: PGdkWindow): PGdkScreen; cdecl; external gdklib;
function gdk_screen_is_composited(screen: PGdkScreen): gboolean; cdecl; external gdklib;

procedure FormScreenChanged(widget: PGtkWidget; old_screen: PGdkScreen;
  userdata: GPointer); cdecl;
var
  Screen: PGdkScreen;
  Colormap: PGdkColormap;
begin
  Screen := gtk_widget_get_screen(widget);
  Colormap := gdk_screen_get_rgba_colormap(Screen);
    gtk_widget_set_colormap(widget, Colormap);
end;

{ TFloatingForm }

constructor TFloatingForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  BorderStyle := bsNone;
  FOpacity := $FF;
end;

procedure TFloatingForm.CreateHandle;
type
  PFormBorderStyle = ^TFormBorderStyle;
var
  W: TGtkWindowType;
begin
  PFormBorderStyle(@BorderStyle)^ := bsNone;
  W := FormStyleMap[bsNone];
  FormStyleMap[bsNone] := GTK_WINDOW_POPUP;
  inherited CreateHandle;
  FormStyleMap[bsNone] := W;
  if not (csDesigning in ComponentState) then
  begin
    FWindow := Pointer(Handle);
    gtk_widget_set_app_paintable(PGtkWidget(FWindow), True);
    g_signal_connect(G_OBJECT(FWindow), 'screen-changed',
      G_CALLBACK(@FormScreenChanged), nil);
    FormScreenChanged(PGtkWidget(FWindow), nil, nil);
  end;
end;

procedure TFloatingForm.MoveSize(Rect: TRectI);
var
  Window: PGdkWindow;
begin
  Window := GTK_WIDGET(Pointer(Handle)).window;
  gdk_window_move_resize(Window, Rect.Left, Rect.Top, Rect.Width, Rect.Height);
end;

procedure TFloatingForm.SetOpacity(Value: Byte);
begin
  if Value <> FOpacity then
  begin
    gtk_window_set_opacity(PGtkWindow(FWindow), Value / $FF);
    FOpacity := Value;
  end;
end;

function TFloatingForm.GetCompositing: Boolean;
var
  Screen: PGdkScreen;
begin
  Screen := gdk_window_get_screen(GTK_WIDGET(Pointer(Handle)).window);
  Result := gdk_screen_is_composited(screen);
end;

procedure TFloatingForm.SetFaded(Value: Boolean);
begin
  if FFaded <> Value then
  begin
    FFaded := Value;
    if WindowManager.Compositing and (WindowManager.Name = 'Compiz') then
      if FFaded then
        Opacity := 0
      else
        Opacity := $FF
    else
      Visible := not FFaded;
  end;
end;
{$endif}

end.
