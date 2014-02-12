-module(bd_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    case bd_sup:start_link() of
        {ok, Pid} ->
            ok = riak_core:register_vnode_module(bd_vnode),
            ok = riak_core_ring_events:add_guarded_handler(bd_ring_event_handler, []),
            ok = riak_core_node_watcher_events:add_guarded_handler(bd_node_event_handler, []),
            ok = riak_core_node_watcher:service_up(bd, self()),
            {ok, Pid};
        {error, Reason} ->
            {error, Reason}
    end.

stop(_State) ->
    ok.
