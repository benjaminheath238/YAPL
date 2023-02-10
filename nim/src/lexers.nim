#################
#    Imports    #
#################

from std/tables import Table, toTable, `[]`, contains

import tokens

###################
#    Constants    #
###################

const
  RESERVED_WORDS: Table[string, TokenKind] = toTable[string, TokenKind]([
    ("false", TK_LITERAL_BOOL),
    ("true", TK_LITERAL_BOOL),
    ("while", TK_WHILE),
    ("if", TK_IF),
    ("var", TK_VAR),
    ("val", TK_VAL),
    ("const", TK_CONST),
  ])

#####################
#    Definitions    #
#####################

type Lexer* = ref object
  source: string

  start: int
  index: int

  column: int
  line: int

  tokens: seq[Token]

######################
#    Constructors    #
######################

func newLexer*(source: string): Lexer =
  result = Lexer()

  result.source = source

  result.start = 0
  result.index = 0
  
  result.column = 1
  result.line = 1

  result.tokens = newSeq[Token]()

###################
#    Accessors    #
###################

func tokens*(this: Lexer): seq[Token] = this.tokens

###########################
#    Private Functions    #
###########################

template eos(this: Lexer): bool = this.index > high this.source

template reset(this: Lexer): void = this.start = this.index

template nextColumn(this: Lexer): void =
  this.index.inc()
  this.column.inc()

template nextLine(this: Lexer): void = 
  this.index.inc()
  this.line.inc()
  this.column = 1

template read(this: Lexer): char = this.source[this.index]

template lexeme(this: Lexer, backwards: int = 0, forwards: int = -1): string = this.source[(this.start + backwards)..(this.index + forwards)]

template token(this: Lexer, kind: TokenKind, lexeme: string = this.lexeme(), columnOffset: int = (if lexeme.len == 1: (0) else: -lexeme.len)): Token = newToken(kind, lexeme, this.line, this.column + columnOffset)

func add(this: Lexer, token: Token): void = this.tokens.add(token)
func add(this: Lexer, kind: TokenKind, lexeme: string = this.lexeme(), columnOffset: int = (if lexeme.len == 1: (0) else: -lexeme.len)): void = this.add(this.token(kind, lexeme, columnOffset))

template consume(this: Lexer, kind: TokenKind): void =
  this.nextColumn()
  this.add(kind)

##########################
#    Public Functions    #
##########################

func tokenize*(this: Lexer): void =
  while not this.eos():
    this.reset()

    case this.read():
    of {' ', '\t', '\r'}:
      this.nextColumn()
    of '\n':
      this.nextLine()
    of '#':
      while this.read() != '\n':
        this.nextColumn()
      this.nextLine()
    of '\'':
      if this.read() == '\'':
        this.nextColumn()
      else:
        this.nextColumn()
        discard # TODO: throw error
      
      if this.read() notin {'"', '\0'..'\31', '\127'}:
        this.nextColumn()
      else:
        this.nextColumn()
        discard # TODO: throw error
      
      if this.read() == '\'':
        this.nextColumn()
      else:
        this.nextColumn()
        discard # TODO: throw error
      
      this.add(TK_LITERAL_CHAR)
    of '\"':
      if this.read() == '\"':
        this.nextColumn()
      else:
        this.nextColumn()
        discard # TODO: throw error
      
      while this.read() notin {'"', '\0'..'\31', '\127'}:
        this.nextColumn()
      
      if this.read() == '\"':
        this.nextColumn()
      else:
        this.nextColumn()
        discard # TODO: throw error
      
      this.add(TK_LITERAL_STRING)
    of {'0'..'9'}:
      if this.read() == '0':
        this.nextColumn()
        if this.read() in {'x', 'X', 'b', 'B', 'o', 'O'}:
          this.nextColumn()
    
      while this.read() in {'0'..'9', 'a'..'f', 'A'..'F'}:
        this.nextColumn()

      if this.read() == '.':
        this.nextColumn()
        while this.read() in {'0'..'9', 'a'..'f', 'A'..'F'}:
          this.nextColumn()

        this.add(TK_LITERAL_FLOAT)
      else:
        this.add(TK_LITERAL_INTEGER)
    of '(':
      this.consume(TK_LPAREN)
    of ')':
      this.consume(TK_RPAREN)
    of '{':
      this.consume(TK_LBRACE)
    of '}':
      this.consume(TK_RBRACE)
    of '[':
      this.consume(TK_LBRACK)
    of ']':
      this.consume(TK_RBRACK)
    of ':':
      this.consume(TK_COLON)
    of ';':
      this.consume(TK_SEMI)
    of ',':
      this.consume(TK_COMMA)
    of '=':
      this.consume(TK_ASSIGN)
    of '+':
      this.consume(TK_ADD)
    of '-':
      this.consume(TK_SUB)
    of '*':
      this.consume(TK_MUL)
    of '/':
      this.consume(TK_DIV)
    else:
      if this.read() in {'a'..'z', 'A'..'Z', '_', '$'}:
        while this.read() in {'a'..'z', 'A'..'Z', '_', '$', '0'..'9'}:
          this.nextColumn()

        let lexeme: string = this.lexeme()

        if RESERVED_WORDS.contains(lexeme):
          this.add(RESERVED_WORDS[lexeme], lexeme)
        else:
          this.add(TK_IDENTIFIER, lexeme)
      else:
        this.nextColumn() # TODO: handle error