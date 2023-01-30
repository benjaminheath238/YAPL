from encoding import decodeU16le, decodeU32le, decodeU64le

import instructions

const LOCALS_COUNT: int = 8
const STACK_SIZE: int = 8

type VersionError* = CatchableError

type Program = ref object
  bytes: seq[uint8]

  yairVersion: uint32
  yaisVersion: uint32

  constants: seq[uint64]
  constantsCount: uint16

  instructions: seq[uint8]
  instructionsCount: uint16

type Emulator* = ref object
  constants: seq[uint64]

  locals: seq[uint64]

  program: seq[uint8]
  ip: uint32

  stack: seq[uint64]
  sp: uint32

proc newEmulator*(program: seq[uint8] = newSeq[uint8](0), constants: seq[uint64] = newSeq[uint64](0)): Emulator =
  result = Emulator()

  result.constants = constants

  result.locals = newSeq[uint64](LOCALS_COUNT)
  #result.locals = cast[seq[]](result.memory[LOCALS_OFFSET..LOCALS_OFFSET+LOCALS_COUNT]) # newSeq[uint64](LOCALS_COUNT)

  result.program = program
  result.ip = 0

  result.stack = newSeq[uint64](STACK_SIZE)
  result.sp = 0

func loadHeader(this: Emulator, program: var Program): void =
  # Decode YAIR version from little endian
  program.yairVersion = decodeU32le(
    program.bytes[0],
    program.bytes[1],
    program.bytes[2],
    program.bytes[3])

  # Decode YAIS version from little endian
  program.yaisVersion = decodeU32le(
    program.bytes[4],
    program.bytes[5],
    program.bytes[6],
    program.bytes[7])

  # Decode number of constants from little endian
  program.constantsCount = decodeU16le(
    program.bytes[8],
    program.bytes[9])

  # Decode number of instructions from little endian
  program.instructionsCount = decodeU16le(
    program.bytes[10],
    program.bytes[11])

func loadConstants(this: Emulator, program: var Program): void =
  let stop: int = program.bytes.len - int(program.instructionsCount * INSTRUCTION_WIDTH)
  let start: int = stop - int(program.constantsCount * 8)
  
  let bytes: seq[uint8] = program.bytes[start..stop - 1]

  program.constants = newSeq[uint64](program.constantsCount)
  for i in countup(0, high bytes, 8):
    program.constants[i div 8] = decodeU64le(
      bytes[i + 0],
      bytes[i + 1],
      bytes[i + 2],
      bytes[i + 3],
      bytes[i + 4],
      bytes[i + 5],
      bytes[i + 6],
      bytes[i + 7]
    )

func loadInstructions(this: Emulator, program: var Program): void =
  let start: int = program.bytes.len - int(program.instructionsCount * INSTRUCTION_WIDTH)

  program.instructions = program.bytes[start..high program.bytes]

proc load*(this: Emulator, file: File): void =
  var program: Program = Program()

  let len: int64 = file.getFileSize() 

  program.bytes = newSeq[uint8](len)

  let read: int64 = file.readBytes(program.bytes, 0, len)

  if read < len:
    raise newException(IOError, "Failed to read file")

  this.loadHeader(program)
  this.loadConstants(program)
  this.loadInstructions(program)

  if program.yairVersion != YAIR_VERSION:
    raise newException(VersionError, "Emulator YAIR version is " & $YAIR_VERSION & " but program version is " & $program.yairVersion)
  elif program.yaisVersion != YAIS_VERSION:
    raise newException(VersionError, "Emulator YAIS version is " & $YAIS_VERSION & " but program version is " & $program.yaisVersion)
  else:
    this.constants = program.constants
    this.program = program.instructions

func push(this: Emulator, value: uint64): void =
  this.stack[this.sp] = value
  this.sp.inc()

func pop(this: Emulator): uint64 =
  this.sp.dec()
  this.stack[this.sp]

func peek(this: Emulator): uint64 =
  this.stack[this.sp - 1]

func drop(this: Emulator): void =
  this.sp.dec()

func execute(this: Emulator, opcode: uint8, opand1: uint8, opand2: uint8): void =
  case opcode:
  of OP_NOOP:
    discard
  of OP_HALT:
    this.ip = high uint32
  of OP_ADD:
    this.push(this.pop()  +  this.pop())
  of OP_SUB:
    this.push(this.pop()  -  this.pop())
  of OP_MUL:
    this.push(this.pop()  *  this.pop())
  of OP_DIV:
    this.push(this.pop() div this.pop())
  of OP_LPUSH:
    this.push(decodeU16le(opand1, opand2))
  of OP_CPUSH:
    this.push(this.constants[decodeU16le(opand1, opand2)])
  of OP_DUP:
    this.push(this.peek())
  of OP_STORE:
    this.locals[decodeU16le(opand1, opand2)] = this.pop()
  of OP_LOAD:
    this.push(this.locals[decodeU16le(opand1, opand2)])
  of OP_JP:
    this.ip = (decodeU16le(opand1, opand2) - 1) * INSTRUCTION_WIDTH
  of OP_JPZ:
    if this.peek() == 0:
      this.ip = (decodeU16le(opand1, opand2) - 1) * INSTRUCTION_WIDTH
    this.drop()
  of OP_JPNZ:
    if this.peek() != 0:
      this.ip = (decodeU16le(opand1, opand2) - 1) * INSTRUCTION_WIDTH
    this.drop()
  of OP_JPS:
    if this.peek() < 0:
      this.ip = (decodeU16le(opand1, opand2) - 1) * INSTRUCTION_WIDTH
    this.drop()
  of OP_JPNS:
    if this.peek() >= 0:
      this.ip = (decodeU16le(opand1, opand2) - 1) * INSTRUCTION_WIDTH
    this.drop()
  else: discard

func execute*(this: Emulator): void =
  while this.ip + INSTRUCTION_WIDTH <= uint32(high this.program):
    this.execute(this.program[this.ip + 0],
                 this.program[this.ip + 1],
                 this.program[this.ip + 2])
    this.ip.inc(INSTRUCTION_WIDTH)
