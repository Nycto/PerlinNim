##
## Helper code for parsing CLI options
##

import sugar, sequtils, tables, parseopt

type
    OptionKind = enum
        ## The kind of flag represented
        WithValue, NoValue

    Option = object
        ## A single option definition
        keys: seq[string]
        case kind: OptionKind
        of WithValue:
            assign: (string, string) -> void
        of NoValue:
            enable: () -> void

template failIf(condition: bool, msg: untyped) =
    ## Quits with a failure code and a message
    if condition:
        stderr.write("Error: ", msg, "\n")
        quit(1)

func option*[T](assign: (T) -> void, keys: openArray[string], parse: (string) -> T, validate: (T) -> bool): Option =
    ## Creates an option with the given definition
    result = Option(
        keys: keys.toSeq,
        kind: WithValue,
        assign: proc(key: string, value: string): void =
            let parsed = parse(value)
            failIf(not validate(parsed), "Invalid value passed for " & key)
            assign(parsed)
    )

func option*[T](assign: (T) -> void, keys: openArray[string], parse: (string) -> T): Option =
    ## Creates an option with the given definition
    option(assign, keys, parse, (it) => true)

func flag*(assign: () -> void, keys: openArray[string]): Option =
    ## Creates an option with the given definition
    result = Option(keys: keys.toSeq, kind: NoValue, enable: assign)

func toTable(options: openarray[Option]): Table[string, Option] =
    ## Indexes a set of options by their flags
    for option in options:
        for key in option.keys:
            result[key] = option

proc getOption(options: Table[string, Option], key: string): Option =
    ## Fetches an option given a flag
    failIf(not options.contains(key), "Unrecognized CLI flag: " & key)
    return options[key]

proc parse*(options: varargs[Option]) =
    ## Parses the given options
    let lookup = options.toTable

    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            failIf(true, "Unexpected CLI argument: " & key)
        of cmdLongOption, cmdShortOption:
            let opt = lookup.getOption(key)
            case opt.kind
            of WithValue:
                failIf(val == "", "A value must be passed for CLI flag: " & key)
                opt.assign(key, val)
            of NoValue:
                failIf(val != "", "A value should not be passed for CLI flag: " & key)
                opt.enable()
        of cmdEnd:
            failIf(true, "Internal CLI parsing error")

