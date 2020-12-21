#!/usr/bin/env escript
-module(program).
-export([main/1]).

main(Args) ->
	Command = "/usr/bin/opskit " ++ string:join([[X] || X <- Args], " "),
	Result = os:cmd(Command),
	Split=re:split(Result, "\n", [{return,list}]),
	lists:foldl(
		fun(Elem, Acc) -> 
			ElemSplit=re:split(Elem, "\s+", [{return,list}]),
			case ElemSplit of
				[Properties, Value] -> 
					ExportCommand = "export OPSKIT_" ++ string:uppercase(Properties) ++ "=" ++ Value,
					io:format("~s\n", [ExportCommand]),
					os:cmd(ExportCommand),
					Acc ++ [{list_to_atom(string:lowercase(Properties)), Value}];
				_ -> 
					Acc
			end
		end, [], Split 
	),
	io:format("psql -h postgres.$OPSKIT_ENVIRONMENT -d $OPSKIT_DATABASE -U $OPSKIT_USERNAME -W $OPSKIT_PASSWORD\n",[]).