{//************************************************************//}
{//                                                            //}
{//         C�digo gerado pelo assistente                      //}
{//                                                            //}
{//         Projeto MVCBr                                      //}
{//         tireideletra.com.br  / amarildo lacerda            //}
{//************************************************************//}
{// Data: 10/03/2017 21:21:54                                  //}
{//************************************************************//}
/// <summary>
///    Uma View representa a camada de apresenta��o ao usu�rio
///    deve esta associado a um controller onde ocorrer�
///    a troca de informa��es e comunica��o com os Models
/// </summary>
unit RestODataAppView;
interface
uses
{$IFDEF FMX}FMX.Forms, {$ELSE}VCL.Forms, {$ENDIF}
  System.SysUtils, System.Classes,MVCBr.Interf,
  MVCBr.View,MVCBr.FormView,MVCBr.Controller, IPPeerClient, Data.DB,
  Datasnap.DBClient, Vcl.Controls, Vcl.Grids, Vcl.DBGrids, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, REST.Response.Adapter;
type
/// Interface para a VIEW
  IRestODataAppView = interface(IView)
    ['{2AEBB87C-2DE9-4616-87D8-2A31D98574C2}']
    // incluir especializacoes aqui
  end;
/// Object Factory que implementa a interface da VIEW
  TRestODataAppView = class(TFormFactory {TFORM} ,IView,IThisAs<TRestODataAppView>,
  IRestODataAppView,IViewAs<IRestODataAppView>)
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    RESTResponse1: TRESTResponse;
    RESTRequest1: TRESTRequest;
    RESTClient1: TRESTClient;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    ClientDataSet1: TClientDataSet;
  private
  protected
    function Controller(const aController: IController): IView;override;
  public
   { Public declarations }
    class function New(AController:IController):IView;
    function This: TObject;override;
    function ThisAs:TRestODataAppView;
    function ViewAs:IRestODataAppView;
    function ShowView(const AProc: TProc<IView>): integer;override;
    function Update: IView;override;
  end;
Implementation
{$R *.DFM}
function TRestODataAppView.Update:IView;
begin
  result := self;
  {codigo para atualizar a View vai aqui...}
end;
function TRestODataAppView.ViewAs:IRestODataAppView;
begin
  result := self;
end;
class function TRestODataAppView.new(AController:IController):IView;
begin
   result := TRestODataAppView.create(nil);
   result.controller(AController);
end;
function TRestODataAppView.Controller(const AController:IController):IView;
begin
  result := inherited Controller(AController);
end;
function TRestODataAppView.This:TObject;
begin
   result := inherited This;
end;
function TRestODataAppView.ThisAs:TRestODataAppView;
begin
   result := self;
end;
function TRestODataAppView.ShowView(const AProc:TProc<IView>):integer;
begin
  inherited;
end;
end.
