#################
#    Imports    #
#################

from std/tables import TableRef, Table, newTable, toTable, contains, pairs, `[]`, `[]=`, `$`
from std/strformat import fmt
from std/json import JsonNode, newJObject, newJNull, `%`, `[]=`

#####################
#    Definitions    #
#####################

type
  SymbolError* = CatchableError

  SymbolKind* = enum
    SK_U8
    SK_U16
    SK_U32
    SK_U64
    
    SK_I8
    SK_I16
    SK_I32
    SK_I64
    
    SK_F32
    SK_F64
    
    SK_STRING
    SK_CHAR

    SK_BOOL

    SK_OBJECT

  Symbol* = ref object
    identifier: string
    
    case kind: SymbolKind
    of SK_U8:     valU8*:  uint8
    of SK_U16:    valU16*: uint16
    of SK_U32:    valU32*: uint32
    of SK_U64:    valU64*: uint64
    of SK_I8:     valI8*:  int8
    of SK_I16:    valI16*: int16
    of SK_I32:    valI32*: int32
    of SK_I64:    valI64*: int64
    of SK_F32:    valF32*: float32
    of SK_F64:    valF64*: float64
    of SK_STRING: valString*: string
    of SK_CHAR:   valChar*: char
    of SK_BOOL:   valBool*: bool
    of SK_OBJECT: objectIdentifier*: string

  Environment* = ref object
    parent: Environment

    symbols: TableRef[string, Symbol]

###################
#    Constants    #
###################

const
  SYMBOL_KINDS: Table[string, SymbolKind] = toTable[string, SymbolKind]([
    ("U8",      SK_U8),
    ("U16",     SK_U16),
    ("U32",     SK_U32),
    ("U64",     SK_U64),
    ("I8",      SK_I8),
    ("I16",     SK_I16),
    ("I32",     SK_I32),
    ("I64",     SK_I64),
    ("F32",     SK_F32),
    ("F64",     SK_F64),
    ("String",  SK_STRING),
    ("Char",    SK_CHAR),
    ("Bool",    SK_BOOL),
  ])

######################
#    Constructors    #
######################

func newSymbol*(identifier: string, kind: string): Symbol =
  let k: SymbolKind = if kind in SYMBOL_KINDS:
    SYMBOL_KINDS[kind]
  else:
    SK_OBJECT
  
  result = Symbol(kind: k)

  result.identifier = identifier

  if k == SK_OBJECT: result.objectIdentifier = kind

func newEnvironment*(parent: Environment): Environment =
  result = Environment()

  result.parent = parent

  result.symbols = newTable[string, Symbol]()

###################
#    Accessors    #
###################

func identifier*(this: Symbol): string = this.identifier
func kind*(this: Symbol): SymbolKind = this.kind

func parent*(this: Environment): Environment = this.parent

###########################
#    Private Functions    #
###########################

##########################
#    Public Functions    #
##########################

template `[]=`*(this: Environment, identifier: string, symbol: Symbol): void = this.symbols[identifier] = symbol
template contains*(this: Environment, identifier: string): bool = identifier in this.symbols

func `[]`*(this: Environment, identifier: string): Symbol =
  var env: Environment = this
  while env != nil:
    if identifier in this:
      return this.symbols[identifier]
    else:
      env = env.parent
  
  raise newException(SymbolError, "Failed to find symbol " & identifier)

func `$`*(this: Symbol): string =
  return case this.kind:
  of SK_U8:     fmt"(identifier={this.identifier}, type={this.kind}, val={this.valU8})"
  of SK_U16:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valU16})"
  of SK_U32:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valU32})"
  of SK_U64:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valU64})"
  of SK_I8:     fmt"(identifier={this.identifier}, type={this.kind}, val={this.valI8})"
  of SK_I16:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valI16})"
  of SK_I32:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valI32})"
  of SK_I64:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valI64})"
  of SK_F32:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valF32})"
  of SK_F64:    fmt"(identifier={this.identifier}, type={this.kind}, val={this.valF64})"
  of SK_STRING: fmt"(identifier={this.identifier}, type={this.kind}, val={this.valString})"
  of SK_CHAR:   fmt"(identifier={this.identifier}, type={this.kind}, val={this.valChar})"
  of SK_BOOL:   fmt"(identifier={this.identifier}, type={this.kind}, val={this.valBool})"
  of SK_OBJECT: fmt"(identifier={this.identifier}, type={this.kind}, val={this.objectIdentifier})"

func `%`*(this: Symbol): JsonNode = 
  result = newJObject()

  result["identifier"] = %this.identifier
  result["kind"] = %this.kind

  case this.kind:
  of SK_U8:     result["valU8"] = %this.valU8
  of SK_U16:    result["valU16"] = %this.valU16
  of SK_U32:    result["valU32"] = %this.valU32
  of SK_U64:    result["valU64"] = %this.valU64
  of SK_I8:     result["valI8"] = %this.valI8
  of SK_I16:    result["valI16"] = %this.valI16
  of SK_I32:    result["valI32"] = %this.valI32
  of SK_I64:    result["valI64"] = %this.valI64
  of SK_F32:    result["valF32"] = %this.valF32
  of SK_F64:    result["valF64"] = %this.valF64
  of SK_STRING: result["valString"] = %this.valString
  of SK_CHAR:   result["valChar"] = %fmt"{this.valChar}"
  of SK_BOOL:   result["valBool"] = %this.valBool
  of SK_OBJECT: result["objectIdentifier"] = %this.objectIdentifier

func `$`*(this: Environment): string =
  "(symbols=" & $this.symbols & ", parent=" & (if this.parent == nil: "nil" else: $this.parent) & ")"

func `%`*(this: Environment): JsonNode =
  result = newJObject()

  var symbols: JsonNode = newJObject()

  for k, v in this.symbols:
    symbols[k] = %v

  result["parent"] = if this.parent == nil: newJNull() else: %this.parent
  result["symbols"] = symbols
