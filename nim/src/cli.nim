from std/parseopt import OptParser, initOptParser, next, cmdEnd, cmdArgument, cmdLongOption, cmdShortOption
from std/terminal import styledWriteLine, resetAttributes, fgRed, fgBlue, fgYellow
from std/os import changeFileExt, fileExists, splitFile
from std/strutils import isEmptyOrWhitespace

from encoding import encodeU32le
from instructions import YAIR_VERSION, YAIS_VERSION, YAPL_VERSION

proc version(): void =
  template ln(args: varargs[untyped]): void = stdout.styledWriteLine(args)
  
  let yaplVersion: array[4, uint8] = encodeU32le(YAPL_VERSION)
  let yairVersion: array[4, uint8] = encodeU32le(YAIR_VERSION)
  let yaisVersion: array[4, uint8] = encodeU32le(YAIS_VERSION)
  
  ln fgBlue, "YAPL version: ", $yaplVersion[0], ".", $yaplVersion[1], ".", $yaplVersion[2], ".", $yaplVersion[3]
  ln fgBlue, "YAIR version: ", $yairVersion[0], ".", $yairVersion[1], ".", $yairVersion[2], ".", $yairVersion[3]
  ln fgBlue, "YAIS version: ", $yaisVersion[0], ".", $yaisVersion[1], ".", $yaisVersion[2], ".", $yaisVersion[3]
  
  stdout.resetAttributes()
  stderr.resetAttributes()

proc help(): void =
  template ln(args: varargs[untyped]): void = stdout.styledWriteLine(args)

  ln fgYellow, "YAPL - Yet Another Programming Language"
  ln ""
  
  version()
  
  ln ""
  ln "Usage: yapl [options*] file"
  ln ""
  ln "Options:"
  ln "  --help, -h:           Display this help"
  ln "  --assemble, -a:       Assemble a file"
  ln "  --compile, -c:        Compile a file"
  ln "  --emulate, -e:        Emulate a file"
  ln "  --execute, -x:        Execute a file"
  ln "  --output, -o:         Set the output file"
  ln "  --target, -t:         Set the target type"
  ln "  --optimisation, -m:   Set the optimisation level"
  ln ""
  ln "Targets:"
  ln "  yair:   binary, executable"
  ln "  yais:   text, human readable"
  ln ""
  ln "Optimisation Levels:"
  ln "  There are no options yet"

  stdout.resetAttributes()
  stderr.resetAttributes()

type Operation* = enum
  OP_INVALID
  OP_ASSEMBLE
  OP_COMPILE
  OP_EMULATE
  OP_EXECUTE

type Target* = enum
  TARGET_NON
  TARGET_YAIR
  TARGET_YAIS

type Optimisation* = enum
  OPT_NON

type Arguments* = ref object
  text: string
  
  input*: string
  output*: string
  
  operation*: Operation
  target*: Target

  optimisation: Optimisation

  valid*: bool

func newArguments*(text: string): Arguments =
  result = Arguments()

  result.text = text

  result.input = ""
  result.output = ""
  
  result.operation = OP_INVALID
  result.target = TARGET_NON

  result.optimisation = OPT_NON

  result.valid = true

proc summary*(this: Arguments): void =
  stdout.resetAttributes()
  stderr.resetAttributes()

proc setOperation(this: Arguments, operation: Operation): void =
  if this.operation == OP_INVALID:
    this.operation = operation
  else:
    stderr.styledWriteLine(fgRed, "Multiple operations, use --help for usage")

proc setOutput(this: Arguments, output: string): void =
  if this.output == "":
    this.output = output
  else:
    stderr.styledWriteLine(fgRed, "Multiple output files, use --help for usage")

proc setTarget(this: Arguments, target: Target): void =
  if this.target == TARGET_NON:
    this.target = target
  else:
    stderr.styledWriteLine(fgRed, "Multiple targets, use --help for usage")

proc invalidate*(this: Arguments): void =
  this.valid = false

proc validateInputFile(this: Arguments, usage: string, fileTypes: seq[string]): void =
  if not this.valid:
    return
  
  if not this.input.fileExists():
    stderr.styledWriteLine(fgRed, "Input file does not exist, use --help for usage")
    this.invalidate()

  if this.input.splitFile().ext notin fileTypes:
    stderr.styledWriteLine(fgRed, "Invalid input file for " & usage & ", use --help for usage")
    this.invalidate()

proc validateOutputFile(this: Arguments, ext: string): void =
  if not this.valid:
    return
  
  if this.output == "":
    this.output = this.input.changeFileExt(ext)

proc validate*(this: Arguments): void =
  case this.operation:
  of OP_INVALID:
    if not this.valid:
      stderr.styledWriteLine(fgRed, "Invalid operation, use --help for usage")
  of OP_ASSEMBLE:
    this.validateInputFile("assembling", @[".yais"])
    this.validateOutputFile("yair")
  of OP_COMPILE:
    this.validateInputFile("compiling", @[".yapl"])
    case this.target:
    of TARGET_YAIR:
      this.validateOutputFile("yair")
    of TARGET_YAIS:
      this.validateOutputFile("yais")
    of TARGET_NON:
      this.target = TARGET_YAIR
  of OP_EMULATE:
    this.validateInputFile("emulating", @[".yair"])
  of OP_EXECUTE:
    this.validateInputFile("executing", @[".yair", ".yais"])

  stdout.resetAttributes()
  stderr.resetAttributes()

proc parseShort(this: Arguments, key, val: string): void =
  case key:
  of "h": help()
  of "v": version()
  of "a": this.setOperation(OP_ASSEMBLE)
  of "c": this.setOperation(OP_COMPILE)
  of "e": this.setOperation(OP_EMULATE)
  of "x": this.setOperation(OP_EXECUTE)
  of "o": this.setOutput(val)
  of "t":
    case val:
    of "yair": this.setTarget(TARGET_YAIR)
    of "yais": this.setTarget(TARGET_YAIS)
    else:
      stderr.styledWriteLine(fgRed, "Unrecognised target: ", val, ", use --help for usage")
  of "m":
    case val:
    else:
      stderr.styledWriteLine(fgRed, "Unrecognised optimisation level: ", val, ", use --help for usage")
  else:
    this.invalidate()
    stderr.styledWriteLine(fgRed, "Unrecognised option: ", key, ", use --help for usage")
    
proc parseLong(this: Arguments, key, val: string): void =
  case key:
  of "help": help()
  of "version": version()
  of "assemble": this.setOperation(OP_ASSEMBLE)
  of "compile": this.setOperation(OP_COMPILE)
  of "emulate": this.setOperation(OP_EMULATE)
  of "execute": this.setOperation(OP_EXECUTE)
  of "output": this.setOutput(val)
  of "target":
    case val:
    of "yair": this.setTarget(TARGET_YAIR)
    of "yais": this.setTarget(TARGET_YAIS)
    else:
      stderr.styledWriteLine(fgRed, "Unrecognised target: ", val, ", use --help for usage")
  of "optimisation":
    case val:
    else:
      stderr.styledWriteLine(fgRed, "Unrecognised optimisation level: ", val, ", use --help for usage")
  else:
    this.invalidate()
    stderr.styledWriteLine(fgRed, "Unrecognised option: ", key, ", use --help for usage")
    

proc parse*(this: Arguments): void =
  if this.text.isEmptyOrWhitespace():
    return
  
  var parser: OptParser = this.text.initOptParser()

  while true:
    parser.next()

    case parser.kind:
    of cmdArgument:
      this.input = parser.key
    of cmdLongOption:
      this.parseLong(parser.key, parser.val)
    of cmdShortOption:
      this.parseShort(parser.key, parser.val)
    of cmdEnd:
      break

  stdout.resetAttributes()
  stderr.resetAttributes()
