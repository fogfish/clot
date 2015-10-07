%%
%%   Copyright 2015 Dmitry Kolesnikov, All Rights Reserved
%%
%%   Licensed under the Apache License, Version 2.0 (the "License");
%%   you may not use this file except in compliance with the License.
%%   You may obtain a copy of the License at
%%
%%       http://www.apache.org/licenses/LICENSE-2.0
%%
%%   Unless required by applicable law or agreed to in writing, software
%%   distributed under the License is distributed on an "AS IS" BASIS,
%%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%   See the License for the specific language governing permissions and
%%   limitations under the License.
%%
-module(clot_seed).
-behaviour(pipe).

-export([
   start_link/0
  ,init/1
  ,free/2
  ,handle/3
]).

%%%----------------------------------------------------------------------------   
%%%
%%% factory
%%%
%%%----------------------------------------------------------------------------   

start_link() ->
   pipe:start_link(?MODULE, [], []).

init(_) ->
   Tts = application:get_env(clot, tts, 30000),
   Sg  = application:get_env(clot, sg, ""),
   {ok, Pid} = esh:spawn_link([sh, clot:which(seed), Sg, "2> /dev/null"], [norun]),
   erlang:send_after(Tts, self(), seed),
   {ok, handle, #{pid => Pid, tts => Tts}}.

free(_, _) ->
   ok.

%%%----------------------------------------------------------------------------   
%%%
%%% pipe
%%%
%%%----------------------------------------------------------------------------   

handle({esh, _, {eof, _}}, _, #{tts := Tts} = State) ->
   erlang:send_after(Tts, self(), seed),
   {next_state, handle, State};

handle({esh, _, Msg}, _, State) ->
   Nodes = [X || X <- binary:split(Msg, <<$\n>>, [global, trim]), X =/= <<>>],
   seed_cluster([erlang:node() | erlang:nodes()], Nodes),
   {next_state, handle, State};

handle(seed, _, #{pid := Pid} = State) ->
   pipe:send(Pid, run),
   {next_state, handle, State}.

%%%----------------------------------------------------------------------------   
%%%
%%% private
%%%
%%%----------------------------------------------------------------------------   

%%
%%
seed_cluster(Known, Seed)
 when length(Known) =:= length(Seed) ->
   ok;
seed_cluster(Known, Seed) ->
   [Name, _] = binary:split(erlang:atom_to_binary(erlang:node(), utf8), <<$@>>), 
   lists:foreach(
      fun(Host) ->
         Node = erlang:binary_to_atom(<<Name/binary, $@, Host/binary>>, utf8),
         case lists:member(Node, Known) of
            true  ->
               ok;
            false ->
               net_kernel:connect_node(Node)
         end
      end,
      Seed
   ).
