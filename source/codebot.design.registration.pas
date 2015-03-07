(********************************************************)
(*                                                      *)
(*  Codebot Pascal Library                              *)
(*  http://cross.codebot.org                            *)
(*  Modified September 2013                             *)
(*                                                      *)
(********************************************************)

{ <include docs/codebot.graphics.design.registration.txt> }
unit Codebot.Design.Registration;

{$i codebot.inc}

interface

uses
  Classes, PropEdits, ComponentEditors,
  Codebot.Design.Editors,
  Codebot.Design.Forms,
  Codebot.Graphics,
  Codebot.Controls,
  Codebot.Controls.Grids,
  Codebot.Controls.Banner,
  Codebot.Controls.Colors,
  Codebot.Controls.Extras,
  Codebot.Controls.Scrolling,
  Codebot.Controls.Sliders;

procedure Register;

implementation

{$R palette_icons.res}

procedure Register;
begin
  { Components }
  RegisterComponents('Codebot', [TIndeterminateProgress, TBorderContainer, TRenderBox, TRenderImage, TImageStrip,
    TContentGrid, TDrawList, TDrawTextList, THuePicker, TSaturationPicker, TSlideBar]);
  { Property editors }
  RegisterPropertyEditor(TypeInfo(string), nil, 'ThemeName',
    TThemeNamePropertyEditor);
  RegisterPropertyEditor(TSurfaceBitmap.ClassInfo, nil, '',
    TSurfaceBitmapPropertyEditor);
  { Component editors }
  RegisterComponentEditor(TRenderImage, TRenderImageEditor);
  RegisterComponentEditor(TImageStrip, TImageStripEditor);
  { Custom forms }
  RegisterForm(TRenderForm, 'Render Form', 'A form with surface and theme support',
    'Codebot.Controls');
  RegisterForm(TBannerForm, 'Banner Form', 'A form a customizable header and footer',
    'Codebot.Controls.Banner');
end;

end.