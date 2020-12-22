#!/usr/bin/env escript
-module(program).
-export([main/1]).

main(Args) ->
	Command = "/usr/bin/opskit " ++ string:join([[X] || X <- Args], " "),
	Result = os:cmd(Command),
	Split=re:split(Result, "\n", [{return,list}]),
	ConnectionDetails = lists:foldl(
		fun(Elem, Acc) -> 
			ElemSplit=re:split(Elem, "\s+", [{return,list}]),
			case ElemSplit of
				[Properties, Value] ->
					Acc ++ [{list_to_atom(string:lowercase(Properties)), Value}];
				_ -> 
					Acc
			end
		end, [], Split 
	),

	Env = proplists:get_value(environment, ConnectionDetails),
	DevStgPrdOnAzure = string:prefix(Env, <<"rlr-az-">>),
	case DevStgPrdOnAzure of
	    nomatch ->
	    	io:format("psql 'postgresql://~s:~s@postgres.~s/~s'\n",[
                proplists:get_value(username, ConnectionDetails),
                proplists:get_value(password, ConnectionDetails),
                proplists:get_value(environment, ConnectionDetails),
                proplists:get_value(database, ConnectionDetails)
        	]);
	    _ ->
	        Hostname = case DevStgPrdOnAzure of
	            "prd" -> "postgres-main-rlr-az-prd.postgres.database.azure.com";
	            "stg" -> "postgres-main-rlr-az-stg.postgres.database.azure.com";
	            "dev" -> "postgres-main-rlr-az-dev.postgres.database.azure.com"
	        end,
	    	io:format("export PGPASSWORD='~s'; psql 'postgresql://~s/~s?sslmode=require' -U '~s'\n",[
                proplists:get_value(password, ConnectionDetails),
                Hostname,
                proplists:get_value(database, ConnectionDetails),
                proplists:get_value(username, ConnectionDetails)
        	])
	end.