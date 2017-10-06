%%%-------------------------------------------------------------------
%%% @author  linyibin
%%% @copyright (C) 2010, 
%%% @doc
%%%  ģ�����ȡ����, �ý������ڶ�ȡ������Ҫ�õ���ģ���, ���������̲�ѯ����
%%% @end
%%% Created : 31 Mar 2010 by  <>
%%%-------------------------------------------------------------------
-module(tplt).

-include_lib("xmerl/include/xmerl.hrl").
-include_lib("xmerl/include/xmerl_xsd.hrl").
-include("tplt_field_type.hrl").
-include("tplt_def.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0, 
	 get_data/2, 
	 is_exist/2, 
	 get_all_data/1, 
	 transform_filename_atom/1, 
	 get_size/1, 
	 info/1,
	 reload/0,
	 read_template_file/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

%%%===================================================================
%%% API1
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, template}, ?MODULE, [], []).

%% ���ָ��ģ�����ָ����¼
%% ����Ҳ�������empty
%% ����Ҳ�������erlang:error().
-spec get_data(atom(), any()) -> tuple().
get_data(TpltName, Key) ->
    case get_data1(TpltName, Key) of
	empty -> erlang:error({not_found, TpltName, Key});
	Data -> Data
    end.

-spec get_data1(atom(), any()) -> tuple() | empty.
get_data1(TpltName, Key) when is_atom(TpltName), is_list(Key)->
    get_data1(TpltName, list_to_binary(Key));
get_data1(TpltName, Key) when is_atom(TpltName) ->
    case ets:lookup(TpltName, Key) of
        [{Key, Value}] ->
            Value;
	_Result -> empty
    end.


%% ȡ��¼��
get_size(TpltName) ->
    ets:info(TpltName, size).

%% �ж�ָ���������Ƿ����
-spec is_exist(atom(), any()) -> boolean().
is_exist(TpltName, Key) when is_atom(TpltName)->
    case ets:lookup(TpltName, Key) of
	[]-> false;
	_ -> true
    end.

info(TpltName) when is_atom(TpltName) ->
    ets:info(TpltName). 

%% ���ָ��ģ��������м�¼
%% ���ؼ�¼�����б���ʽ
-spec get_all_data(atom()) -> [tuple()].
get_all_data(TpltName) when is_atom(TpltName)->
    % ��ʹ��Ĭ�ϵ�dict:to_list,��Ϊ�ú����ǲ���[{Key,Value}]���б�
    % ����ߵ������ǲ���[Value]�б�
    F = fun({_Key, Value}, AccIn)-> [Value | AccIn] end,
    lists:reverse(ets:foldl(F, [], TpltName)).

%% ת��ָ�����ļ���Ϊatom�ķ�ʽ
%% ����ļ���������չ��, ���Զ�ȥ��
transform_filename_atom(Filename)->
    FileName1 = binary_to_list(Filename),
    io_helper:format("FileName1:~p~n", [FileName1]),
    case FileName1 =:= "0" of
	true ->[];
	_ -> list_to_atom(filename:basename(FileName1, ".xml"))
    end.

%% ����Template�ļ�

reload()->
    io_helper:format("reload template start~n"),
    read_template_file("./template/"),
    io_helper:format("reload template end~n"),
    erlang:garbage_collect(self()),
    task:init_task_info(),
    {ok,[]}.
    
    

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
    io_helper:format("read template start~n"),
    read_template_file("./template/"),
    erlang:garbage_collect(self()),
    task:init_task_info(),
    io_helper:format("read template end~n"),
    {ok, []}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
read_template_file(FilePath1)->
    {ok, Files} = get_file_list(FilePath1),
    [try
	 io_helper:format("File:~s~s~n",[FilePath1, File]),
	 transform_file_to_dict(?field_type_list, FilePath1, File)
     catch 
	 error: Msg ->
	     %% ����������ѶϢ����ȷ
	     %% logger:delay_log(error, "file: ~p~n ~p~n stack:~p~n", 
	     %% 		      [File, Msg, erlang:get_stacktrace()]),
	     erlang:error({Msg, erlang:get_stacktrace()})		    
     end || File <- Files].

%% ��ȡ�ļ��б�
get_file_list(FilePath) -> 
    case file:list_dir(FilePath) of
	{ok, Files} -> {ok, Files};
	_ -> error
    end.

%% ���ļ��ж�ȡ����,��䵽dict��
transform_file_to_dict(FTList, FilePath, File) ->
    case filename:extension(File) of
	".xml" -> 
	    FileAtom = list_to_atom(filename:basename(File, ".xml")),
	    {ok, Xml} = file:read_file(FilePath++File),
	    {ok, {_Root, _, [{Name,_,_}|_]=Records}, _} = erlsom:simple_form(Xml),
	    case is_define_exist(list_to_atom(Name)) of
		false -> erlang:error({'program not define', File});
		true -> ok
	    end,
	    case ets:info(FileAtom) of
		undefined -> ok;
		_ -> 
		    ets:delete(FileAtom)
	    end,
	    ets:new(FileAtom, [ordered_set, public, named_table]),
	    F = fun({FieldName, _, C}, Row)->
			case C of
			    [] ->
				ok;
			    _ ->
				FieldAtom = list_to_atom(FieldName),
				case lists:keysearch(FieldAtom, 1, FTList) of			    
				    {value, {_, FTs}} ->
					case lists:keysearch(FileAtom, 1, FTList) of
					    false -> ok;
					    _ ->
						%% ���ͷ��Tag���ļ����Ƿ�ƥ��
						case FileAtom =:= FieldAtom of
						    true -> ok;
						    _ ->					    
							erlang:error({filename_not_match, FieldAtom, FileAtom})
						end
					end,
					try
					    T = list_to_tuple([FieldAtom|transform_field_value(FileAtom, FTs, C, Row)]),

					    Key = element(2, T),
					    case ets:lookup(FileAtom, Key) of
						[] ->
						    ets:insert(FileAtom, {element(2, T), T});
						_ ->
						    erlang:error({key_reapeat, FileAtom, Key})
					    end
					catch
					    _:Reason ->
						erlang:error({Reason, {err_id, list_to_integer(hd(element(3, hd(C))))}})
					end;
				    _ -> 
					erlang:error({'not found', FieldAtom, FTList})
				end
			end,
			Row + 1
		end,
	    lists:foldl(F, 1, Records),
	    ok;
	_ ->
	    ok
    end.

%% ���ݼ�¼�����Ͷ���, ���ַ���ת������Ӧ��ֵ
transform_field_value(_File, [], [], _Row) ->
    [];
transform_field_value(File, [], Values, Row)->
    erlang:error({type_value_mismatch, [File, Values, Row]});
transform_field_value(File, FieldTypes, [], Row)->
    erlang:error({type_field_mismatch, [File, FieldTypes, Row]});
transform_field_value(File, [FieldType|FTRest], [{_, _, StringValue}|VRest], Row)->
    %% ���б�������������, ��Ҫʱ����
    %%io:format("~p~n", [{FieldType, FTRest, StringValue, Row}]),
    Value = case StringValue of 
		[]->
		    "";
		[NotEmpty]->
		    NotEmpty
	    end,
    [case FieldType of
	 int -> list_to_integer(string:strip(Value, both, $ ));
	 float -> trans_to_float(string:strip(Value, both, $ ));
	 string -> unicode:characters_to_binary(Value);
	 range -> get_range_field(Value); 
	 list_int -> get_list_int(Value);
	 list_tuple ->get_list_tuple(Value);
	 list_space_int ->
	     [list_to_integer(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
	 list_space_float ->
	     [list_to_float(string:strip(Token, both, $ )) || Token <- string:tokens(Value, " ")];
	 list_float -> [list_to_float(string:strip(Token, both, $ ))
		      || Token <- string:tokens(Value, ",")];
	 list_string -> [unicode:characters_to_binary(string:strip(Token, both, $ ))
		      || Token <- string:tokens(Value, ",")];
	 exp_str ->
	     expression:trans_expression(Value);
	 _ -> erlang:error(badtype)
     end | transform_field_value(File, FTRest, VRest, Row)].

get_list_int(Value) when Value == "-1" ->
    [];
get_list_int(Value) ->
    [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, ",")].

get_list_tuple(Value) when Value == "-1" ->
    [];

get_list_tuple(OldValue) ->
    Value = lists:concat(["[", OldValue, "]"]),
    {ok, Scan1, _} = erl_scan:string(Value++"."),
    {ok,P}=erl_parse:parse_exprs(Scan1),
    P1 = erl_eval:exprs(P, []),
    {_,P2,_} = P1,
    P2.

trans_to_float(Value) when is_list(Value)->
    case string:chr(Value, $.) of
	0 -> float(list_to_integer(Value));
	_ -> list_to_float(Value)
    end.

%% �ж��ƶ������ͳ����Ƿ���
is_define_exist(Type)->
    case lists:keyfind(Type, 1, ?field_type_list) of
	false -> false;
	_-> true
    end.

get_range_field([]) ->
    {0, 0};
get_range_field(Value) ->
    IntList = [list_to_integer(string:strip(Token, both, $ ))
     || Token <- string:tokens(Value, "~")],
    case length(IntList) of
	2 -> list_to_tuple(IntList);
	1 -> {hd(IntList), hd(IntList)};
	_ -> 
	    erlang:error(bad_range, Value)
    end.
%%------------------------------���Դ���---------------------------------------
-include_lib("eunit/include/eunit.hrl").
-ifdef(TEST).

is_define_exist_test()->
    false = is_define_exist(ttt),
    true = is_define_exist(house_tplt).

-endif.