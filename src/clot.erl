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
-module(clot).

-export([
   seed/0,
   attach/0
]).
-export([
   which/1
]).

%%%----------------------------------------------------------------------------   
%%%
%%% interface
%%%
%%%----------------------------------------------------------------------------   

%%
%% seed cluster
-spec(seed/0 :: () -> {ok, pid()} | {error, any()}).

seed() ->
   clot_sup:start_child(worker, erlang:make_ref(), clot_seed, []).

%%
%% attach instance to elb

-spec(attach/0 :: () -> any()).

attach() ->
   esh:run([bash, clot:which(elb), "2> /dev/null"]).
   


%%%----------------------------------------------------------------------------   
%%%
%%% protected
%%%
%%%----------------------------------------------------------------------------   


%%
%% which script to run - lookup path to script
which(Name) ->
   filename:join([
      code:priv_dir(?MODULE),
      "aws",
      erlang:atom_to_list(Name) ++ ".sh"
   ]).
