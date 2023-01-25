from assemblers import Assembler, newAssembler, assemble, constants, program, errors, save
from emulators import Emulator, newEmulator, execute, load

when isMainModule:
  let assembler: Assembler = newAssembler(readFile("res/test0.yais"))

  assembler.assemble()

  #let saved: File = open("res/test0.yair", fmWrite)
  #assembler.save(saved)
  #saved.close()

  if assembler.errors.len() != 0:
    for error in assembler.errors:
      echo error
  else:
    #let emulator: Emulator = newEmulator()
    let emulator: Emulator = newEmulator(assembler.program, assembler.constants)

    #let loaded: File = open("res/test0.yair", fmRead)
    #emulator.load(loaded)
    #loaded.close()

    emulator.execute()
