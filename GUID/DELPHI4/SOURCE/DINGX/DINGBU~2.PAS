unit DingButtonXControl_TLB;

// ************************************************************************ //
// WARNING                                                                  //
// -------                                                                  //
// The types declared in this file were generated from data read from a     //
// Type Library. If this type library is explicitly or indirectly (via      //
// another type library referring to this type library) re-imported, or the //
// 'Refresh' command of the Type Library Editor activated while editing the //
// Type Library, the contents of this file will be regenerated and all      //
// manual modifications will be lost.                                       //
// ************************************************************************ //

// PASTLWTR : $Revision:   1.11.1.23  $
// File generated on 5/15/98 1:55:11 AM from Type Library described below.

// ************************************************************************ //
// Type Lib: E:\source\DingX\DingButtonXControl.tlb
// IID\LCID: {199D9A87-CC89-11D1-AC07-C54ACBC13325}\0
// Helpfile: 
// HelpString: DingButtonXControl Library
// Version:    1.0
// ************************************************************************ //

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:      //
//   Type Libraries     : LIBID_xxxx                                    //
//   CoClasses          : CLASS_xxxx                                    //
//   DISPInterfaces     : DIID_xxxx                                     //
//   Non-DISP interfaces: IID_xxxx                                      //
// *********************************************************************//
const
  LIBID_DingButtonXControl: TGUID = '{199D9A87-CC89-11D1-AC07-C54ACBC13325}';
  IID_IDingButtonX: TGUID = '{199D9A88-CC89-11D1-AC07-C54ACBC13325}';
  DIID_IDingButtonXEvents: TGUID = '{199D9A89-CC89-11D1-AC07-C54ACBC13325}';
  CLASS_DingButtonX: TGUID = '{199D9A8A-CC89-11D1-AC07-C54ACBC13325}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                  //
// *********************************************************************//
// TxDragMode constants
type
  TxDragMode = TOleEnum;
const
  dmManual = $00000000;
  dmAutomatic = $00000001;

// TxMouseButton constants
type
  TxMouseButton = TOleEnum;
const
  mbLeft = $00000000;
  mbRight = $00000001;
  mbMiddle = $00000002;


// *********************************************************************//
// Forward declaration of interfaces defined in Type Library            //
// *********************************************************************//
type
  IDingButtonX = interface;
  IDingButtonXDisp = dispinterface;
  IDingButtonXEvents = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                     //
// (NOTE: Here we map each CoClass to its Default Interface             //
// *********************************************************************//
  DingButtonX = IDingButtonX;

  IDingButtonX = interface(IDispatch)
    ['{199D9A88-CC89-11D1-AC07-C54ACBC13325}']
    procedure Click; safecall;
    function Get_Cancel: WordBool; safecall;
    procedure Set_Cancel(Value: WordBool); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function Get_DragCursor: Smallint; safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
    function Get_DragMode: TxDragMode; safecall;
    procedure Set_DragMode(Value: TxDragMode); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Font: IFontDisp; safecall;
    procedure Set_Font(const Value: IFontDisp); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    procedure AboutBox; safecall;
    property Cancel: WordBool read Get_Cancel write Set_Cancel;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Default: WordBool read Get_Default write Set_Default;
    property DragCursor: Smallint read Get_DragCursor write Set_DragCursor;
    property DragMode: TxDragMode read Get_DragMode write Set_DragMode;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Font: IFontDisp read Get_Font write Set_Font;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
  end;

// Dispinterface declaration for dual interface IDingButtonX

  IDingButtonXDisp = dispinterface
    ['{199D9A88-CC89-11D1-AC07-C54ACBC13325}']
    procedure Click; dispid 1;
    property Cancel: WordBool dispid 2;
    property Caption: WideString dispid 3;
    property Default: WordBool dispid 4;
    property DragCursor: Smallint dispid 5;
    property DragMode: TxDragMode dispid 6;
    property Enabled: WordBool dispid 7;
    property Font: IFontDisp dispid 8;
    property Visible: WordBool dispid 9;
    property Cursor: Smallint dispid 10;
    procedure AboutBox; dispid -552;
  end;

  IDingButtonXEvents = dispinterface
    ['{199D9A89-CC89-11D1-AC07-C54ACBC13325}']
    procedure OnClick; dispid 1;
    procedure OnKeyPress(var Key: Smallint); dispid 2;
  end;

//  DingButtonX control 

  TDingButtonXOnKeyPress = procedure(Sender: TObject; var Key: Smallint) of object;

  TDingButtonX = class(TOleControl)
  private
  // Instance of Closures to expose OCX Events as VCL ones
  //
    FOnClick: TNotifyEvent;
    FOnKeyPress: TDingButtonXOnKeyPress;
    FIntf: IDingButtonX;
    function  GetControlInterface: IDingButtonX;
  protected
    procedure CreateControl;
    procedure InitControlData; override;
  public
    procedure Click;
    procedure AboutBox;
    property  ControlInterface: IDingButtonX read GetControlInterface;
  published
    property Cancel: WordBool index 2 read GetWordBoolProp write SetWordBoolProp stored False;
    property Caption: WideString index 3 read GetWideStringProp write SetWideStringProp stored False;
    property Default: WordBool index 4 read GetWordBoolProp write SetWordBoolProp stored False;
    property DragCursor: Smallint index 5 read GetSmallintProp write SetSmallintProp stored False;
    property DragMode: TOleEnum index 6 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Enabled: WordBool index 7 read GetWordBoolProp write SetWordBoolProp stored False;
    property Font: TFont index 8 read GetTFontProp write SetTFontProp stored False;
    property Visible: WordBool index 9 read GetWordBoolProp write SetWordBoolProp stored False;
    property Cursor: Smallint index 10 read GetSmallintProp write SetSmallintProp stored False;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnKeyPress: TDingButtonXOnKeyPress read FOnKeyPress write FOnKeyPress;
  end;

procedure Register;

implementation

uses ComObj;

procedure TDingButtonX.InitControlData;
const
  CEventDispIDs: array [0..1] of Integer = (
    $00000001, $00000002);
  CTFontIDs: array [0..0] of Integer = (
    $00000008);
  CControlData: TControlData = (
    ClassID: '{199D9A8A-CC89-11D1-AC07-C54ACBC13325}';
    EventIID: '{199D9A89-CC89-11D1-AC07-C54ACBC13325}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300;
    FontCount: 1;
    FontIDs: @CTFontIDs);
begin
  ControlData := @CControlData;
end;

procedure TDingButtonX.CreateControl;

  procedure DoCreate;
  begin
    FIntf := IUnknown(OleObject) as IDingButtonX;
  end;

begin
  if FIntf = nil then DoCreate;
end;

function TDingButtonX.GetControlInterface: IDingButtonX;
begin
  CreateControl;
  Result := FIntf;
end;

procedure TDingButtonX.Click;
begin
  ControlInterface.Click;
end;

procedure TDingButtonX.AboutBox;
begin
  ControlInterface.AboutBox;
end;

procedure Register;
begin
  RegisterComponents('ActiveX',[TDingButtonX]);
end;

end.
