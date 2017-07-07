-module(discovery_workers_manager).
-behaviour(gen_server).

%% API.
-export([start_link/0]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-record(state, {
    hosts :: binary()
}).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
	gen_server:start_link(?MODULE, [], []).

%% gen_server.

init([]) ->
    Opts = application:get_env(node_discovery),

    Hosts = proplists:get_value(hosts, Opts),
    Nodes = proplists:get_value(nodes, Opts),
    RegisterCallback = proplists:get_value(register_callback, Opts),
    lists:foreach(
        fun({Host, {NodeName, Port}}) ->

            HostFullName = list_to_atom(
                io_lib:format("~s@~s", [NodeName, Host])
            ),
            {ok, _Pid} = discovery_workers_sup:start_worker(HostFullName, Port, RegisterCallback)
        end,
        [{Host, Node} || Host <- Hosts, Node <-Nodes]
    ),

	{ok, #state{}}.

handle_call(_Request, _From, State) ->
	{reply, ignored, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.
