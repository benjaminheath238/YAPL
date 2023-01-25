from std/tables import Table, TableRef, toTable, newTable, values, contains, `[]`, `[]=`
from std/strutils import split, splitLines, strip, isEmptyOrWhitespace
from std/sequtils import map, filter
from std/sugar import `=>`

from parsing import parseU8, parseU16, parseU64
from encoding import encodeU64le, encodeU32le, encodeU16le

import instructions

const COMMENT_DELIMINATOR: char = '#'
const ADDRESS_DELIMINATOR: char = '@'
const VARIABLE_DELIMINATOR: char = '$'

const OP_CODES: Table[string, uint8] = toTable[string, uint8]([
  ("HALT", OP_HALT),
  
  ("ADD", OP_ADD),
  ("SUB", OP_SUB),
  ("MUL", OP_MUL),
  ("DIV", OP_DIV),

  ("LPUSH", OP_LPUSH),
  ("CPUSH", OP_CPUSH),
  ("DUP", OP_DUP),
  ("STORE", OP_STORE),
  ("LOAD", OP_LOAD),

  ("JP", OP_JP),
  ("JPZ", OP_JPZ),
  ("JPNZ", OP_JPNZ),
  ("JPS", OP_JPS),
  ("JPNS", OP_JPNS),
])

type Instruction = tuple[opcode, opand1, opand2: uint8]
type Error = string

type Assembler* = ref object
  addresses: TableRef[string, uint16]
  address: uint16

  variables: TableRef[string, tuple[id: uint16, value: uint64]]
  count: uint16

  program: seq[uint8]
  
  source: seq[string]

  errors: seq[Error]
  line: uint16

func newAssembler*(source: string): Assembler =
  result = Assembler()

  result.addresses = newTable[string, uint16]()
  result.address = 0

  result.variables = newTable[string, tuple[id: uint16, value: uint64]]()
  result.count = 0

  result.program = newSeq[uint8]()
  
  result.source = source.splitLines()
                        .map(x => x.strip())
                        .filter(x => not x.isEmptyOrWhitespace())

  result.errors = newSeq[Error]()
  result.line = 1

func constants*(this: Assembler): seq[uint64] =
  result = newSeq[uint64]()
  for item in this.variables.values():
    result.add(item.value)

func program*(this: Assembler): seq[uint8] = this.program
func errors*(this: Assembler): seq[Error] = this.errors

proc saveHeader(this: Assembler, file: File): void =
  var bytes: seq[uint8] = newSeq[uint8]()

  # Encode YAIR version in little endian
  bytes.add(encodeU32le(YAIR_VERSION))

  # Encode YAIS version in little endian
  bytes.add(encodeU32le(YAIS_VERSION))

  # Encode number of constants in little endian
  bytes.add(encodeU16le(uint16(this.constants.len)))

  # Encode number of instructions in little endian
  bytes.add(encodeU16le(uint16(this.program.len div INSTRUCTION_WIDTH)))

  discard file.writeBytes(bytes, 0, bytes.len)

proc saveConstants(this: Assembler, file: File): void =
  var bytes: seq[uint8] = newSeq[uint8]()

  # Encode all the constants in little endian
  for constant in this.constants:
    bytes.add(encodeU64le(constant))

  discard file.writeBytes(bytes, 0, bytes.len)

proc saveInstructions(this: Assembler, file: File): void =
  discard file.writeBytes(this.program, 0, this.program.len)

proc save*(this: Assembler, file: File): void = 
  this.saveHeader(file)
  this.saveConstants(file)
  this.saveInstructions(file)

func parseArguments(this: Assembler, source: string): uint16 =
  if source[0] == ADDRESS_DELIMINATOR:
    if this.addresses.contains(source[1..high source]):
      return this.addresses[source[1..high source]] 
    else:
      this.errors.add("[" & $this.line & "]: Failed to find section (" & $source[1..high source] & ")")
      return 0
  elif source[0] == VARIABLE_DELIMINATOR:
    if this.variables.contains(source[1..high source]):
      return this.variables[source[1..high source]].id
    else:
      this.errors.add("[" & $this.line & "]: Failed to find variable (" & $source[1..high source] & ")")
      return 0
  else:
    return parseU16(source)

func parseInstruction(this: Assembler, source: seq[string]): Instruction =
  if not OP_CODES.contains(source[0]):
    this.errors.add("[" & $this.line & "]: Failed to parse opcode (" & $source[0] & ")")
    return (opcode: OP_NOOP, opand1: 0'u8, opand2: 0'u8)

  let opcode = OP_CODES[source[0]]

  if source.len == 3:
    (opcode: opcode, opand1: parseU8(source[1]), opand2: parseU8(source[2]))
  elif source.len == 2:
    let opands: array[2, uint8] = encodeU16le(this.parseArguments(source[1]))
    (opcode: opcode, opand1: opands[0], opand2: opands[1])
  else:
    (opcode: opcode, opand1: 0'u8, opand2: 0'u8)

func process(this: Assembler): void =
  for line in this.source:
    this.line.inc()
    
    if line[0] in {COMMENT_DELIMINATOR, ADDRESS_DELIMINATOR, VARIABLE_DELIMINATOR}:
      continue
    else:
      this.address.inc()

    let instruction: Instruction = this.parseInstruction(line.split(" "));

    this.program.add(instruction.opcode)
    this.program.add(instruction.opand1)
    this.program.add(instruction.opand2)
  
  this.address = 0
  this.line = 1

func preprocess(this: Assembler): void =
  for line in this.source:
    this.line.inc()
    
    if line[0] == COMMENT_DELIMINATOR:
      continue
    elif line[0] == VARIABLE_DELIMINATOR:
      let parts: seq[string] = line.split("=")
                                   .map(x => x.strip())

      this.variables[parts[0][1..high parts[0]]] = (id: this.count, value: parseU64(parts[1]))
      
      this.count.inc()
    elif line[0] == ADDRESS_DELIMINATOR:
      this.addresses[line[1..high line]] = this.address
    else:
      this.address.inc()

  this.address = 0
  this.line = 1

func assemble*(this: Assembler): void =
  this.preprocess()
  this.process()
