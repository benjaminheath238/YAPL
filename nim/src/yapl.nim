#################
#    Imports    #
#################

from std/strutils import join, endsWith
from std/os import commandLineParams
from std/json import `%`, pretty

from cli import Arguments, newArguments, parse, validate, OP_INVALID, OP_ASSEMBLE, OP_COMPILE, OP_EMULATE, OP_EXECUTE

from environments import `$`, `%`
from tokens import `$`
from nodes import `$`

from assemblers import Assembler, newAssembler, assemble, constants, program, errors, save
from emulators import Emulator, newEmulator, execute, load
from lexers import Lexer, newLexer, tokens, tokenize
from parsers import Parser, newParser, ast, parse, env

when isMainModule:
  let args: Arguments = newArguments(commandLineParams().join(" "))
  
  args.parse()
  args.validate()

  if args.valid:
    case args.operation:
    of OP_INVALID:
      quit(QuitFailure)
    of OP_ASSEMBLE:
      let assembler: Assembler = newAssembler(readFile(args.input))
  
      assembler.assemble()
    
      if assembler.errors.len() == 0:
        let output: File = open(args.output, fmWrite)
        assembler.save(output)
        output.close()
      else:
        for error in assembler.errors:
          echo error
  
    of OP_COMPILE:
      let lexer: Lexer = newLexer(readFile(args.input))

      lexer.tokenize()

      let parser: Parser = newParser(lexer.tokens)

      parser.parse()

      writeFile("lex.json", pretty(%lexer.tokens))
      writeFile("parse.json", pretty(%parser.ast))
    of OP_EMULATE:
      let emulator: Emulator = newEmulator()

      let input: File = open(args.input, fmRead)
      emulator.load(input)
      input.close()

      emulator.execute()
    of OP_EXECUTE:
      let assembler: Assembler = newAssembler(readFile(args.input))
      assembler.assemble()

      if assembler.errors.len() == 0:
        let emulator: Emulator = newEmulator(assembler.program, assembler.constants)
        emulator.execute()
      else:
        for error in assembler.errors:
          echo error
