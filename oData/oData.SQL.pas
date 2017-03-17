{ //************************************************************// }
{ //         Projeto MVCBr                                      // }
{ //         tireideletra.com.br  / amarildo lacerda            // }
{ //************************************************************// }
{ // Data: 03/03/2017                                           // }
{ //************************************************************// }
unit oData.SQL;

interface

uses System.Classes, System.SysUtils, Data.DB,
  idURI, System.JSON, oData.ServiceModel,
  oData.Interf, oData.Dialect,
  oData.ProxyBase, oData.parse,
  MVCFramework;

type

  TODataSQL = class(TODataBase)
  private
  protected
    FResource: IJsonODastaServiceResource;
    function EncodeFilterSql(AFilter: string): string; virtual;
  public
    procedure CreateEntitiesSchema(ADataset: TDataset;
      var JSONResponse: TJsonObject); virtual;
    function QueryClass: TDatasetClass; virtual;
    function Select: string; virtual;
    function CreateGETQuery(FParse: IODataParse; AInLineCount: boolean = false)
      : string; virtual;
    function CreateSearchFields(FParse: IODataParse; const ASearch: String;
      const fields: string): String; virtual;
    function CreateDeleteQuery(FParse: IODataParse; AJsonBody: TJsonValue)
      : string; virtual;
    function CreatePOSTQuery(FParse: IODataParse; AJsonBody: TJsonValue)
      : string; virtual;
    function CreatePATCHQuery(FParse: IODataParse; AJsonBody: TJsonValue)
      : string; virtual;
    function Collection: string; override;

    procedure DecodeODataURL(CTX: TObject); override;

    function ExecuteGET(AJsonBody: TJsonValue; var JSONResponse: TJsonObject)
      : TObject; override;
    function ExecuteDELETE(ABody: string; var JSONResponse: TJsonObject)
      : Integer; override;

  end;

implementation

uses oData.JSON, oData.Engine;

{ TODataQuery }

function TODataSQL.Collection: string;
begin
  result := FODataParse.oData.Resource;
end;

function TODataSQL.CreateDeleteQuery(FParse: IODataParse;
  AJsonBody: TJsonValue): string;
begin
  result := AdapterAPI.CreateDeleteQuery(FParse.oData, AJsonBody);
  FResource := AdapterAPI.GetResource as IJsonODastaServiceResource;
end;

procedure TODataSQL.CreateEntitiesSchema(ADataset: TDataset;
  var JSONResponse: TJsonObject);
var
  fld: TField;
  jp: TJsonPair;
  jv: TJsonObject;
  ja: TJsonArray;
  AName: String;
  sl: TStringList;
  s: string;
begin

  if FResource.keyID <> '' then
  begin
    ja := TJsonArray.create;
    sl := TStringList.create;
    try
      sl.Delimiter := ',';
      sl.Text := FResource.keyID;
      for s in sl do
      begin
        ja.add(s);
      end;
      JSONResponse.AddPair(TJsonPair.create('keys', ja));
    finally
      sl.free;
    end;
  end;

  jv := TJsonObject.create;
  for fld in ADataset.fields do
  begin
    AName := fld.FieldName;
    ja := TJsonArray.create();
    case fld.DataType of
      ftInteger:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'Int32')));
        end;
      ftSmallint, ftShortint, ftWord:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'Int16')));
        end;
      ftCurrency, ftBCD, ftFMTBcd:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type',
            'Decimal')));
          ja.AddElement(TJsonObject.create(TJsonPair.create('Precision',
            TJSONNumber.create(TFloatField(fld).Precision))));
        end;
      ftFloat, ftSingle:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'Float')));
          ja.AddElement(TJsonObject.create(TJsonPair.create('Precision',
            TJSONNumber.create(TFloatField(fld).Precision))));
          ja.AddElement(TJsonObject.create(TJsonPair.create('Scale',
            TJSONNumber.create(5))));
        end;
      fttime:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'Time')));
        end;
      ftBlob:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'Binary')));
        end;
      ftTimeStamp, ftDate, ftDatetime:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type',
            'DateTime')));
        end;
      ftBoolean:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type',
            'Boolean')));
        end;
      ftString, ftFixedChar, ftWideString:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'String')));
          ja.AddElement(TJsonObject.create(TJsonPair.create('MaxLength',
            TJSONNumber.create(fld.Size))));
        end;
      ftMemo:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'String')));
          ja.AddElement(TJsonObject.create(TJsonPair.create('MaxLength',
            TJSONNumber.create(255 * 255))));
        end;
      ftGUID:
        begin
          ja.AddElement(TJsonObject.create(TJsonPair.create('Type', 'String')));
          ja.AddElement(TJsonObject.create(TJsonPair.create('MaxLength',
            TJSONNumber.create(36))));
        end;

    end;
    if fld.Required then
      ja.AddElement(TJsonObject.create(TJsonPair.create('Nullable', 'false')))
    else
      ja.AddElement(TJsonObject.create(TJsonPair.create('Nullable', 'true')));

    jv.AddPair(TJsonPair.create(AName, ja));
  end;
  jp := TJsonPair.create('properties', jv);
  JSONResponse.AddPair(jp);
end;

function TODataSQL.CreatePATCHQuery(FParse: IODataParse;
  AJsonBody: TJsonValue): string;
var
  LJson: IJsonObject;
  LRowState: string;
begin
  LJson := TInterfacedJsonObject.New(AJsonBody);
  if LJson.JsonObject.TryGetValue<string>(cODataRowState, LRowState) then
  begin
    if LRowState = cODataModified then
      result := AdapterAPI.CreatePATCHQuery(FParse.oData, AJsonBody)
    else if LRowState = cODataDeleted then
      result := AdapterAPI.CreateDeleteQuery(FParse.oData, AJsonBody)
    else if LRowState = cODataInserted then
      result := AdapterAPI.CreatePOSTQuery(FParse.oData, AJsonBody)
    else
      raise Exception.create(tODataError.create(500, 'RowState inv�lido'));
  end
  else
    result := AdapterAPI.CreatePATCHQuery(FParse.oData, AJsonBody);
  FResource := AdapterAPI.GetResource as IJsonODastaServiceResource;
end;

function TODataSQL.CreatePOSTQuery(FParse: IODataParse;
  AJsonBody: TJsonValue): string;
begin
  result := AdapterAPI.CreatePOSTQuery(FParse.oData, AJsonBody);
  FResource := AdapterAPI.GetResource as IJsonODastaServiceResource;
end;

function TODataSQL.CreateGETQuery(FParse: IODataParse;
  AInLineCount: boolean = false): string;
begin
  result := AdapterAPI.CreateGETQuery(FParse.oData,
    EncodeFilterSql(FParse.oData.Filter), AInLineCount);
  FResource := AdapterAPI.GetResource as IJsonODastaServiceResource;

end;

function TODataSQL.CreateSearchFields(FParse: IODataParse;
  const ASearch: String; const fields: string): String;
var
  str: TStringList;
  i: Integer;
  LSearch: string;
begin
  LSearch := stringReplace(TIdURI.URLDecode(ASearch), '''', '', [rfReplaceAll]);
  result := '';
  if fields = '' then
    exit;

  str := TStringList.create;
  try
    str.Delimiter := ',';
    str.DelimitedText := fields;
    for i := 0 to str.Count - 1 do
    begin
      if result <> '' then
        result := result + ' or ';
      result := result + str[i] + ' like (''%' + LSearch + '%'')';
    end;
  finally
    str.free;
  end;
end;

procedure TODataSQL.DecodeODataURL(CTX: TObject);
var
  url: string;
begin
  inherited;
  FODataParse := TODataParse.create;
  try
    url := FCTX.Request.PathInfo;
    if FCTX.Request.QueryStringParams.Count > 0 then
    begin
      url := url + '?' + FCTX.Request.RawWebRequest.Query;
    end;
    FODataParse.parse(url);
  finally
  end;
end;

function TODataSQL.EncodeFilterSql(AFilter: string): string;
begin
  result := TODataParse.OperatorToString(AFilter);
end;

function TODataSQL.ExecuteDELETE(ABody: string;
  var JSONResponse: TJsonObject): Integer;
begin
  result := 0;
end;

function TODataSQL.ExecuteGET(AJsonBody: TJsonValue;
  var JSONResponse: TJsonObject): TObject;
begin
  result := nil;
end;

function TODataSQL.QueryClass: TDatasetClass;
begin
  result := nil;
end;

function TODataSQL.Select: string;
begin
  result := FODataParse.oData.Select;
  if result = '' then
    result := '*';
end;

{ TODataSQLDialec }

end.