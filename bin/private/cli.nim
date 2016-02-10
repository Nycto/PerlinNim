##
## Helper code for parsing CLI options
##


import parseopt2, strutils, sets, sequtils, macros

type
    FlagKind = enum ## \
        ## The two kinds of CLI flags: --withValue and --withValue=value
        withValue, withoutValue

    Flag = object
        ## An individual command line flag; --flag or --flag=value
        key: string
        case kind: FlagKind
        of withValue:
            val: string
        of withoutValue:
            discard

    CLIOptions* = object
        ## Collected list of all CLI args and flags
        args: seq[string]
        flags: seq[Flag]

macro str( expression: expr ): expr =
    ## Converts an expression to a string
    strVal( toStrLit(expression) )

template failIf ( condition: expr, msg: expr ) =
    ## Quits with a failure code and a message
    if condition:
        stderr.write("Error: ", msg, "\n")
        quit(1)

template parseOptions*( name: expr, actions: stmt ) {.immediate.} =
    ## Produces a CLIOptions object to be parsed
    var args: seq[string] = @[]
    var flags: seq[Flag] = @[]

    # Collect all the args and flags
    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            args.add(key)
        of cmdLongOption, cmdShortOption:
            if val == "":
                flags.add(Flag(kind: withoutValue, key: key.toLower))
            else:
                flags.add(Flag(
                    kind: withValue,
                    key: key.toLower,
                    val: val))
        of cmdEnd:
            failIf(true, "Internal CLI parsing error")

    var name = CLIOptions(args: args, flags: flags)

    # Execute the internal actions, which will process the flags
    actions

    # When the flags are processed, it will clear out the used values. That
    # allows us to validate that everything was appropriately handled
    failIf(
        name.flags.len > 0,
        "Unexpected flag(s): " & name.flags.mapIt(it.key).join(", "))
    failIf(
        name.args.len > 0,
        "Unexpected arg(s): " & name.args.join(", "))

template forFlag(
    opts: var CLIOptions, keys: openArray[string], name: expr, action: stmt
) {.immediate.} =
    ## Executes the given action if the command line options contains any
    ## of the given keys
    let keySet = toSet[string](keys)
    for name in opts.flags:
        if keySet.contains(name.key):
            keepIf(opts.flags, proc (flag: Flag): bool = flag.key != name.key)
            action

template parse*(
    opts: var CLIOptions,
    variable: expr, keys: openArray[string],
    parse: expr, validate: expr = true
) {.immediate.} =
    ## Parses a command line key/value flag: --key=value
    forFlag(opts, keys, flag):
        failIf(
            flag.kind == withoutValue,
            "CLI Option expects a value: --" & flag.key &
            ".\nDid you remember to use an '='?")
        try:
            let it {.inject.} = flag.val
            let parsed = parse

            block validation:
                {.push hints: off.}
                let it {.inject.} = parsed
                {.pop.}

                failIf(
                    not validate,
                    "Invalid value for --" & flag.key &
                    ". It must pass: " & str(validate))

            variable = parsed
        except:
            failIf(true,
                "Invalid value for " & str(variable) & ". " &
                capitalize(getCurrentExceptionMsg()) )

template parseFlag*(
    opts: var CLIOptions,
    variable: expr, keys: openArray[string],
    parse: expr
) =
    ## Parses a simple command line flag: --key
    forFlag(opts, keys, flag):
        failIf(
            flag.kind == withValue,
            "CLI Option does not expect a value: --" & flag.key)
        variable = parse

template parseArg*( opts: var CLIOptions, variable: expr ) =
    ## Parses an argument from the command line
    failIf(
        opts.args.len == 0,
        "Expecting argument: " & str(variable))
    variable = opts.args[0]
    delete(opts.args, 0, 0)

