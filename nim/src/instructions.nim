from encoding import decodeU32le

# Opcode opand opand
const INSTRUCTION_WIDTH* = 3

# [Major], [Minor], [Patch], [RELEASE = 1, DEV = 0], Why are these here?
const YAPL_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)
const YAIR_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)
const YAIS_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)

const OP_NOOP*: uint8 = 0x00
const OP_HALT*: uint8 = 0x01

const OP_ADD*: uint8 = 0x10
const OP_SUB*: uint8 = 0x11
const OP_MUL*: uint8 = 0x12
const OP_DIV*: uint8 = 0x13

const OP_LPUSH*: uint8 = 0x20
const OP_CPUSH*: uint8 = 0x21
const OP_DUP*: uint8 = 0x22
const OP_STORE*: uint8 = 0x23
const OP_LOAD*: uint8 = 0x24

const OP_JP*: uint8 = 0x30
const OP_JPZ*: uint8 = 0x31
const OP_JPNZ*: uint8 = 0x32
const OP_JPS*: uint8 = 0x33
const OP_JPNS*: uint8 = 0x34
