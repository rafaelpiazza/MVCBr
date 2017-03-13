{//************************************************************//}
{//                                                            //}
{//         C�digo gerado pelo assistente                      //}
{//                                                            //}
{//         Projeto MVCBr                                      //}
{//         tireideletra.com.br  / amarildo lacerda            //}
{//************************************************************//}
{// Data: 10/03/2017 21:21:53                                  //}
{//************************************************************//}
 /// <summary>
 /// O controller possui as seguintes caracter�sticas:
 ///   - pode possuir 1 view associado  (GetView)
 ///   - pode receber 0 ou mais Model   (GetModel<Ixxx>)
 ///   - se auto registra no application controller
 ///   - pode localizar controller externos e instanci�-los
 ///     (resolveController<I..>)
 /// </summary>
unit RestODataApp.Controller;
 /// <summary>
 ///    Object Factory para implementar o Controller
 /// </summary>
interface
{.$I ..\inc\mvcbr.inc}
uses
System.SysUtils, {$ifdef FMX} FMX.Forms,{$else}  VCL.Forms,{$endif}
System.Classes, MVCBr.Interf,
MVCBr.Model, MVCBr.Controller, MVCBr.ApplicationController,
System.RTTI, RestODataApp.Controller.interf, RestODataApp.ViewModel, RestODataApp.ViewModel.Interf,
RestODataAppView;
type
  TRestODataAppController = class(TControllerFactory,
    IRestODataAppController,
    IThisAs<TRestODataAppController>, IModelAs<IRestODataAppViewModel>)
  protected
    Procedure DoCommand(ACommand: string;
        const AArgs: array of TValue); override;
  public
    // inicializar os m�dulos personalizados em CreateModules
    Procedure CreateModules;virtual;
    Constructor Create;override;
    Destructor Destroy; override;
 /// New Cria nova inst�ncia para o Controller
    class function New(): IController; overload;
    class function New(const AView: IView; const AModel: IModel)
      : IController; overload;
    class function New(const AModel: IModel): IController; overload;
    function ThisAs: TRestODataAppController;
 /// Init ap�s criado a inst�ncia � chamado para concluir init
    procedure init;override;
 /// ModeAs retornar a pr�pria interface do controller
    function ModelAs: IRestODataAppViewModel;
  end;
implementation
///  Creator para a classe Controller
Constructor TRestODataAppController.Create;
begin
 inherited;
  ///  Inicializar as Views...
  //%view View(TRestODataAppView.New(self));
  add(TRestODataAppViewModel.New(self).ID('{RestODataApp.ViewModel}'));  ///  Inicializar os modulos
 CreateModules; //< criar os modulos persolnizados
end;
///  Finaliza o controller
Destructor TRestODataAppController.destroy;
begin
  inherited;
end;
///  Classe Function basica para criar o controller
class function TRestODataAppController.New(): IController;
begin
 result := new(nil,nil);
end;
///  Classe para criar o controller com View e Model criado
class function TRestODataAppController.New(const AView: IView;
   const AModel: IModel) : IController;
var
  vm: IViewModel;
begin
  result := TRestODataAppController.create as IController;
  result.View(AView).Add(AModel);
  if assigned(AModel) then
    if supports(AModel.This, IViewModel, vm) then
      begin
        vm.View(AView).Controller( result );
      end;
end;
///  Classe para inicializar o Controller com um Modulo inicialz.
class function TRestODataAppController.New(
   const AModel: IModel): IController;
begin
  result := new(nil,AModel);
end;
///  Cast para a interface local do controller
function TRestODataAppController.ThisAs: TRestODataAppController;
begin
   result := self;
end;
///  Cast para o ViewModel local do controller
function TRestODataAppController.ModelAs: IRestODataAppViewModel;
begin
 if count>=0 then
  supports(GetModelByType(mtViewModel), IRestODataAppViewModel, result);
end;
///  Executar algum comando customizavel
Procedure TRestODataAppController.DoCommand(ACommand: string;
   const AArgs:Array of TValue);
begin
    inherited;
end;
///  Evento INIT chamado apos a inicializacao do controller
procedure TRestODataAppController.init;
var ref:TRestODataAppView;
begin
  inherited;
 if not assigned(FView) then
 begin
   Application.CreateForm( TRestODataAppView, ref );
   supports(ref,IView,FView);
  {$ifdef FMX}
    if Application.MainForm=nil then
      Application.RealCreateForms;
  {$endif}
 end;
 AfterInit;
end;
/// Adicionar os modulos e MODELs personalizados
Procedure TRestODataAppController.CreateModules;
begin
   // adicionar os seus MODELs aqui
   // exemplo: add( MeuModel.new(self) );
end;
initialization
///  Inicializa��o automatica do Controller ao iniciar o APP
//TRestODataAppController.New(TRestODataAppView.New,TRestODataAppViewModel.New)).init();
///  Registrar Interface e ClassFactory para o MVCBr
  RegisterInterfacedClass(TRestODataAppController.ClassName,IRestODataAppController,TRestODataAppController);
finalization
///  Remover o Registro da Interface
  unRegisterInterfacedClass(TRestODataAppController.ClassName);
end.
