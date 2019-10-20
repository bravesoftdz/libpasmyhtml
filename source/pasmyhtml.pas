(******************************************************************************)
(*                                libPasMyHTML                                *)
(*                object pascal wrapper around MyHTML library                 *)
(*                    https://github.com/lexborisov/myhtml                    *)
(*                                                                            *)
(* Copyright (c) 2019                                       Ivan Semenkov     *)
(* https://github.com/isemenkov/libpasmyhtml                ivan@semenkov.pro *)
(*                                                          Ukraine           *)
(******************************************************************************)
(*                                                                            *)
(* Module:          Unit 'pasmyhtml'                                          *)
(* Functionality:   Provides  TMyHTMLParser class                             *)
(*                                                                            *)
(*                                                                            *)
(*                                                                            *)
(******************************************************************************)
(*                                                                            *)
(* This source  is free software;  you can redistribute  it and/or modify  it *)
(* under the terms of the GNU General Public License as published by the Free *)
(* Software Foundation; either version 3 of the License.                      *)
(*                                                                            *)
(* This code is distributed in the  hope that it will  be useful, but WITHOUT *)
(* ANY  WARRANTY;  without even  the implied  warranty of MERCHANTABILITY  or *)
(* FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License for *)
(* more details.                                                              *)
(*                                                                            *)
(* A copy  of the  GNU General Public License is available  on the World Wide *)
(* Web at <http://www.gnu.org/copyleft/gpl.html>. You  can also obtain  it by *)
(* writing to the Free Software Foundation, Inc., 51  Franklin Street - Fifth *)
(* Floor, Boston, MA 02110-1335, USA.                                         *)
(*                                                                            *)
(******************************************************************************)

unit pasmyhtml;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, libpasmyhtml;

type

  { TMyHTMLParser }

  TMyHTMLParser = class
  public
    type
      (* Start parsing from the next element *)
      TDocumentParseFrom = (
        DOCUMENT_HTML, (* Start parse from HTML tag element *)
        DOCUMENT_HEAD, (* Start parse from HEAD tag element *)
        DOCUMENT_BODY  (* Start parse from BODY tag element *)
      );

    TTagNode = class;

    { TTreeChunk }
    (* Document tree or document tree chunk *)
    TTreeChunk = class
    private
      FNode : pmyhtml_tree_node_t;
      FNextNode : pmyhtml_tree_node_t;
    public
      constructor Create (ANode : pmyhtml_tree_node_t);
      destructor Destroy; override;

      (* Return first tree element node *)
      function First : TTagNode;

      (* Return next tree element node *)
      function Next : TTagNode;
    end;

    { TTagNode }
    (* Tag element *)
    TTagNode = class
    private
      FNode : pmyhtml_tree_node_t;
      FNextChildrenNode : pmyhtml_tree_node_t;
    public
      constructor Create (ANode : pmyhtml_tree_node_t);
      destructor Destroy; override;

      (* Return tag element id *)
      function GetTag : myhtml_tag_id_t;

      (* Return tag element class attributes list *)
      function GetClass : TStringList;

      (* Return tag element id attributes list *)
      function GetId : TStringList;

      (* Return tag element value *)
      function GetValue : string;

      (* Return tag element parent element *)
      function GetParent : TTreeChunk;

      (* Return if tag element has childrens *)
      function HasChildren : Boolean;

      (* Return first tag element inner element *)
      function FirstChildren : TTreeChunk;

      (* Return next tag element inner element *)
      function NextChildren : TTreeChunk;
    end;

  private
    FHTML : pmyhtml_t;
    FTree : pmyhtml_tree_t;
    FEncoding : myencoding_t;
    FError : mystatus_t;
  public
    constructor Create(
      AParserOptions: myhtml_options_t = MyHTML_OPTIONS_PARSE_MODE_SEPARATELY;
      AEncoding: myencoding_t = MyENCODING_UTF_8;
      AThreadCount: QWord = 1;
      AQueueSize: QWord = 4096;
      AFlags: myhtml_tree_parse_flags_t = MyHTML_TREE_PARSE_FLAGS_CLEAN);
    destructor Destroy; override;

    (* Document parse *)
    function Parse (AHTML : string; AParseFrom : TDocumentParseFrom =
      DOCUMENT_HTML) : TTreeChunk;

    (* Return if parse has errors *)
    function HasErrors : Boolean;

    (* Return error message if it is, or empty string *)
    function Error : string;
  end;


implementation

{ TMyHTMLParser.TTreeChunk }

constructor TMyHTMLParser.TTreeChunk.Create(ANode: pmyhtml_tree_node_t);
begin
  FNode := ANode;
  FNextNode := nil;
end;

destructor TMyHTMLParser.TTreeChunk.Destroy;
begin
  inherited Destroy;
end;

function TMyHTMLParser.TTreeChunk.First: TTagNode;
begin
  if FNode <> nil then
  begin
    FNextNode := myhtml_node_next(FNode);
  end;
  Result := TTagNode.Create(FNextNode);
end;

function TMyHTMLParser.TTreeChunk.Next: TTagNode;
begin
  if FNextNode <> nil then
  begin
    FNextNode := myhtml_node_next(FNextNode);
  end;
  Result := TTagNode.Create(FNextNode);
end;

{ TMyHTMLParser.TTagNode }

constructor TMyHTMLParser.TTagNode.Create(ANode: pmyhtml_tree_node_t);
begin
  FNode := ANode;
  FNextChildrenNode := nil;
end;

destructor TMyHTMLParser.TTagNode.Destroy;
begin
  inherited Destroy;
end;

function TMyHTMLParser.TTagNode.GetTag: myhtml_tag_id_t;
begin
  if FNode <> nil then
  begin
    Result := myhtml_node_tag_id(FNode);
  end else
  begin
     Result := MyHTML_TAG__UNDEF;
  end;
end;

function TMyHTMLParser.TTagNode.GetClass: TStringList;
begin

end;

function TMyHTMLParser.TTagNode.GetId: TStringList;
begin

end;

function TMyHTMLParser.TTagNode.GetValue: string;
begin

end;

function TMyHTMLParser.TTagNode.GetParent: TTreeChunk;
begin

end;

function TMyHTMLParser.TTagNode.HasChildren: Boolean;
begin

end;

function TMyHTMLParser.TTagNode.FirstChildren: TTreeChunk;
begin

end;

function TMyHTMLParser.TTagNode.NextChildren: TTreeChunk;
begin

end;

{ TMyHTMLParser }

constructor TMyHTMLParser.Create(AParserOptions: myhtml_options_t;
  AEncoding: myencoding_t; AThreadCount: QWord; AQueueSize: QWord;
  AFlags: myhtml_tree_parse_flags_t);
begin
  FHTML := myhtml_create;
  myhtml_init(FHTML, AParserOptions, AThreadCount, AQueueSize);
  FTree := myhtml_tree_create;
  myhtml_tree_init(FTree, FHTML);
  myhtml_tree_parse_flags_set(FTree, AFlags);
  FEncoding := AEncoding;
  FError := Cardinal(MyHTML_STATUS_OK);
end;

destructor TMyHTMLParser.Destroy;
begin
  myhtml_tree_clean(FTree);
  myhtml_clean(FHTML);
  myhtml_tree_destroy(FTree);
  myhtml_destroy(FHTML);
  inherited Destroy;
end;

function TMyHTMLParser.Parse(AHTML: string; AParseFrom: TDocumentParseFrom
  ): TTreeChunk;
begin
  FError := myhtml_parse(FTree, FEncoding, PChar(AHTML), Length(AHTML));
  if FError = Cardinal(MyHTML_STATUS_OK) then
  begin
    case AParseFrom of
      DOCUMENT_HTML :
        Result := TTreeChunk.Create(myhtml_tree_get_node_html(FTree));
      DOCUMENT_HEAD :
        Result := TTreeChunk.Create(myhtml_tree_get_node_head(FTree));
      DOCUMENT_BODY :
        Result := TTreeChunk.Create(myhtml_tree_get_node_body(FTree));
    end;
  end;
end;

function TMyHTMLParser.HasErrors: Boolean;
begin
  Result := (FError <> MyHTML_STATUS_OK);
end;

function TMyHTMLParser.Error: string;
begin
  case FError of
    MyHTML_STATUS_OK :
    begin
      Result := '';
    end;

    MyHTML_STATUS_ERROR :
    begin
      Result := 'MyHTML_STATUS_ERROR';
    end;

    MyHTML_STATUS_ERROR_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_ERROR_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_RULES_ERROR_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_RULES_ERROR_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TOKENIZER_ERROR_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_TOKENIZER_ERROR_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TOKENIZER_ERROR_FRAGMENT_INIT :
    begin
      Result := 'MyHTML_STATUS_TOKENIZER_ERROR_FRAGMENT_INIT';
    end;

    MyHTML_STATUS_TAGS_ERROR_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TAGS_ERROR_MCOBJECT_CREATE :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_MCOBJECT_CREATE';
    end;

    MyHTML_STATUS_TAGS_ERROR_MCOBJECT_MALLOC :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_MCOBJECT_MALLOC';
    end;

    MyHTML_STATUS_TAGS_ERROR_MCOBJECT_CREATE_NODE :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_MCOBJECT_CREATE_NODE';
    end;

    MyHTML_STATUS_TAGS_ERROR_CACHE_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_CACHE_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TAGS_ERROR_INDEX_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_TAGS_ERROR_INDEX_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TREE_ERROR_MEMORY_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_TREE_ERROR_MEMORY_ALLOCATION';
    end;

    MyHTML_STATUS_TREE_ERROR_MCOBJECT_CREATE :
    begin
      Result := 'MyHTML_STATUS_TREE_ERROR_MCOBJECT_CREATE';
    end;

    MyHTML_STATUS_TREE_ERROR_MCOBJECT_INIT :
    begin
      Result := 'MyHTML_STATUS_TREE_ERROR_MCOBJECT_INIT';
    end;

    MyHTML_STATUS_TREE_ERROR_MCOBJECT_CREATE_NODE :
    begin
      Result := 'MyHTML_STATUS_TREE_ERROR_MCOBJECT_CREATE_NODE';
    end;

    MyHTML_STATUS_TREE_ERROR_INCOMING_BUFFER_CREATE :
    begin
      Result := 'MyHTML_STATUS_TREE_ERROR_INCOMING_BUFFER_CREATE';
    end;

    MyHTML_STATUS_ATTR_ERROR_ALLOCATION :
    begin
      Result := 'MyHTML_STATUS_ATTR_ERROR_ALLOCATION';
    end;

    MyHTML_STATUS_ATTR_ERROR_CREATE :
    begin
      Result := 'MyHTML_STATUS_ATTR_ERROR_CREATE';
    end;

    MyHTML_STATUS_STREAM_BUFFER_ERROR_CREATE :
    begin
      Result := 'MyHTML_STATUS_STREAM_BUFFER_ERROR_CREATE';
    end;

    MyHTML_STATUS_STREAM_BUFFER_ERROR_INIT :
    begin
      Result := 'MyHTML_STATUS_STREAM_BUFFER_ERROR_INIT';
    end;

    MyHTML_STATUS_STREAM_BUFFER_ENTRY_ERROR_CREATE :
    begin
      Result := 'MyHTML_STATUS_STREAM_BUFFER_ENTRY_ERROR_CREATE';
    end;

    MyHTML_STATUS_STREAM_BUFFER_ENTRY_ERROR_INIT :
    begin
      Result := 'MyHTML_STATUS_STREAM_BUFFER_ENTRY_ERROR_INIT';
    end;

    MyHTML_STATUS_STREAM_BUFFER_ERROR_ADD_ENTRY :
    begin
      Result := 'MyHTML_STATUS_STREAM_BUFFER_ERROR_ADD_ENTRY';
    end;
  end;
end;

end.
