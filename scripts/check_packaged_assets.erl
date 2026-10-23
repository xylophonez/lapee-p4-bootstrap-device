%% Standalone regression guard for the packaged bootstrap, not its source tree.
%% Run through check-packaged-assets.sh; all keys and state are disposable.
-module(check_packaged_assets).
-export([run/0]).

run() ->
    {ok, _} = application:ensure_all_started(hb),
    Spec = env("BOOTSTRAP_SPEC_ID"),
    Impl = env("BOOTSTRAP_IMPL_ID"),
    PackageStore = #{
        <<"store-module">> => hb_store_lmdb,
        <<"name">> => env("BOOTSTRAP_PACKAGE_STORE"),
        <<"read-only">> => true,
        <<"capacity">> => 1073741824
    },
    Local = hb_test_utils:test_store(),
    Wallet = ar_wallet:new(),
    Address = hb_util:human_id(ar_wallet:to_address(Wallet)),
    Opts = #{
        <<"store">> => [Local, PackageStore],
        <<"priv-store">> => [Local],
        <<"priv-wallet">> => Wallet,
        <<"address">> => Address,
        <<"bundler-beneficiary">> => hb_util:human_id(ar_wallet:to_address(ar_wallet:new())),
        <<"load-remote-devices">> => true,
        <<"trusted-devices">> => #{hb_util:lowercase_key(Spec) => Impl}
    },
    %% Mirrors HyperBEAM hb_packager_test_vectors:priv_data_matches/4 and
    %% trusted_device_id_matches/4: resolve the actual pinned package first.
    {ok, Module} = hb_device_load:reference(Spec, Opts),
    Directory = hb_device_archive:implementation_dir(Module),
    Expected = [
        {"hyper-token.lua",
            <<"3CCE4A9EF7293BBA335BE87840E814E998B596BBB4F9FDD0778DE000BFF864CA">>},
        {"hyper-token-p4.lua",
            <<"DF3B704B1768D17C3431798111849B9066FEB983CC7D08507EADBF7BBE262587">>}
    ],
    Bodies = maps:from_list(lists:map(fun({Name, Hash}) ->
        {ok, Body} = file:read_file(filename:join([Directory, "lapee-p4", Name])),
        Hash = binary:encode_hex(crypto:hash(sha256, Body)),
        %% A wrong archive lookup must not silently pass by reading cwd/HB
        %% fallback scripts. The runner gives us an empty temporary cwd.
        Trap = filename:join(["priv", "lapee-p4", Name]),
        ok = filelib:ensure_dir(Trap),
        ok = file:write_file(Trap, <<"error('stale fallback selected')\n">>),
        {list_to_binary("scripts/" ++ Name), Body}
    end, Expected)),
    {ok, #{<<"body">> := Configured}} = hb_ao:resolve(
        #{<<"device">> => Spec}, #{<<"path">> => <<"start">>, <<"body">> => Opts}, Opts
    ),
    Ledger = maps:get(<<"ledger">>, maps:get(<<"node-processes">>, Configured)),
    Modules = maps:get(<<"module">>, Ledger),
    2 = length(Modules),
    lists:foreach(fun(Script) ->
        Name = maps:get(<<"name">>, Script),
        Body = maps:get(Name, Bodies),
        Body = maps:get(<<"body">>, Script)
    end, Modules),
    io:format("PASS packaged resource layout, canonical v0.11 SHA256s, and public bootstrap start ledger bodies; stale cwd fallback rejected. spec=~s impl=~s~n", [Spec, Impl]),
    ok.

env(Name) ->
    case os:getenv(Name) of
        false -> error({required_environment_variable, Name});
        Value -> list_to_binary(Value)
    end.
