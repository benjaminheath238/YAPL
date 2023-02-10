#################
#    Imports    #
#################

from encoding import decodeU32le

###################
#    Constants    #
###################

const
  # 3 bytes per instruction
  # <opcode> u8 u8 | <opcode> u16
  INSTRUCTION_WIDTH* = 3

  # [Major], [Minor], [Patch], [RELEASE = 1, DEV = 0], Why are these here?
  YAPL_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)
  YAIR_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)
  YAIS_VERSION*: uint32 = decodeU32le(1, 0, 0, 0)

  OP_NOOP*: uint8 = 0x00
  OP_HALT*: uint8 = 0x01

  OP_ADD*: uint8 = 0x10
  OP_SUB*: uint8 = 0x11
  OP_MUL*: uint8 = 0x12
  OP_DIV*: uint8 = 0x13

  OP_LPUSH*: uint8 = 0x20
  OP_CPUSH*: uint8 = 0x21
  OP_DUP*: uint8 = 0x22
  OP_STORE*: uint8 = 0x23
  OP_LOAD*: uint8 = 0x24

  OP_JP*: uint8 = 0x30
  OP_JPZ*: uint8 = 0x31
  OP_JPNZ*: uint8 = 0x32
  OP_JPS*: uint8 = 0x33
  OP_JPNS*: uint8 = 0x34

#####################
#    Definitions    #
#####################

######################
#    Constructors    #
######################

###################
#    Accessors    #
###################

###########################
#    Private Functions    #
###########################

##########################
#    Public Functions    #
##########################
