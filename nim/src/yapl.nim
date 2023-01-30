from std/strutils import join, endsWith
from std/os import commandLineParams

from assemblers import Assembler, newAssembler, assemble, constants, program, errors, save
from emulators import Emulator, newEmulator, execute, load
from cli import Arguments, newArguments, parse, validate, OP_INVALID, OP_ASSEMBLE, OP_COMPILE, OP_EMULATE, OP_EXECUTE

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
  
    of OP_COMPILE: discard
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
