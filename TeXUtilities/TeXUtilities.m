(* ::Package:: *)

BeginPackage["TeXUtilities`"]


(* ::Section:: *)
(*Usage messages*)


TeXVerbatim::usage =
"\
TeXVerbatim[\"str\"] \
converted to TeX gives verbatim \"str\"."


TeXDelimited::usage =
"\
TeXDelimited[\"startDelim\", expr1, expr2, ..., \"endDelim\"] \
converted to TeX gives:
startDelim
	expr1
	expr2
	...
endDelim
with expri converted to TeXForm."


(* ::Section:: *)
(*Implementation*)


(*
	Unprotect all symbols in this context
	(all public symbols provided by this package)
*)
Unprotect["`*"]


Begin["`Private`"]


(* ::Subsection:: *)
(*Private symbols usage*)


TeXCommandArgument::usage =
"\
TeXCommandArgument[arg, argConverter]\
returns string representing argument of TeX command i.e. arg convetred to TeX \
using argConverter, wrapped in curly bracket.\

TeXCommandArgument[{opt1, opt2 -> val2, ...}, argConverter]\
returns string representing list of optional arguments of TeX command i.e. \
\"[opt1,opt2=val2,...]\" with opti and vali converted to TeX using \
argConverter."


(* ::Subsection:: *)
(*TeXVerbatim*)


TeXVerbatim[arg:Except[_String]] := (
	Message[TeXVerbatim::string, 1, HoldForm[TeXVerbatim[arg]]];
	$Failed
)

TeXVerbatim[args___] :=
	With[
		{argsNo = Length[{args}]}
		,
		(
			Message[
				TeXVerbatim::argx,
				HoldForm[TeXVerbatim],
				HoldForm[argsNo]
			];
			$Failed
		)
			/; argsNo =!= 1
	]


System`Convert`TeXFormDump`maketex[
	RowBox[{
		"TeXVerbatim",
		"(" | "[", 
		arg_String?(StringMatchQ[#, "\"" ~~ ___ ~~ "\""] &), 
		")" | "]"
	}]] :=
		ToExpression[arg]


(* ::Subsection:: *)
(*TeXDelimited*)


Options[TeXDelimited] = {
	"BodyConverter" -> (ToString[#, TeXForm]&),
	"BodySeparator" -> "\n",
	"DelimSeparator" -> "\n",
	"Indentation" -> "    "
}


TeXDelimited[arg:Repeated[_, {0, 1}]] := (
	Message[TeXDelimited::argm, HoldForm[TeXDelimited], Length[{arg}], 2];
	$Failed
)

TeXDelimited[start:Except[_String], rest__] := (
	Message[TeXDelimited::string, 1, HoldForm[TeXDelimited[start, rest]]];
	$Failed
)

TeXDelimited[
	rest__,
	end:Except[_String | _?OptionQ],
	opts:Longest[OptionsPattern[]]
] := (
	Message[
		TeXDelimited::string,
		Length[{rest}] + 1,
		HoldForm[TeXDelimited[rest, end, opts]]
	];
	$Failed
)


TeXDelimited /:
	MakeBoxes[
		TeXDelimited[
			start_String,
			body___,
			end_String,
			opts:OptionsPattern[]
		]
		,
		TraditionalForm
	] :=
		With[
			{
				delimSeparator =
					OptionValue[TeXDelimited, opts, "DelimSeparator"]
			}
			,
			ToBoxes[
				TeXVerbatim @ StringJoin[
					start
					,
					StringReplace[
						StringJoin[
							If[Length[{body}] > 0,
								delimSeparator
							(* else *),
								""
							]
							,
							Riffle[
								OptionValue[
									TeXDelimited, opts, "BodyConverter"
								] /@
									{body}
								,
								OptionValue[
									TeXDelimited, opts, "BodySeparator"
								]
							]
						]
						,
						"\n" ->
							"\n" <>
							OptionValue[TeXDelimited, opts, "Indentation"]
					]
					,
					delimSeparator
					,
					end
				]
				,
				TraditionalForm
			]
		]


(* ::Subsection:: *)
(*TeXCommandArgument*)


TeXCommandArgument[optArgs_List, argConverter_] :=
	StringJoin[
		"["
		,
		Riffle[
			Replace[
				optArgs
				,
				{
					(Rule | RuleDelayed)[argName_, value_] :>
						argConverter[argName] <>
						"=" <>
						argConverter[value]
					,
					arg_ :> argConverter[arg]
				}
				,
				{1}
			]
			, 
			","
		]
		,
		"]"
	]
	
TeXCommandArgument[arg_, argConverter_] := "{" <> argConverter[arg] <> "}"


End[]


(* ::Section:: *)
(*Public symbols protection*)


(*
	Protect all symbols in this context
	(all public symbols provided by this package)
*)
Protect["`*"]


EndPackage[]
