#################
#    Imports    #
#################

from std/strformat import fmt

###################
#    Constants    #
###################

#####################
#    Definitions    #
#####################

type
  TokenKind* = enum
    TK_LPAREN
    TK_RPAREN
    TK_LBRACE
    TK_RBRACE
    TK_LBRACK
    TK_RBRACK

    TK_COLON
    TK_SEMI
    TK_COMMA

    TK_ASSIGN

    TK_ADD
    TK_SUB
    TK_MUL
    TK_DIV

    TK_IDENTIFIER

    TK_LITERAL_BOOL
    TK_LITERAL_INTEGER
    TK_LITERAL_FLOAT
    TK_LITERAL_STRING
    TK_LITERAL_CHAR

    TK_VAR
    TK_VAL
    TK_CONST

    TK_WHILE

    TK_IF

  Token* = ref object
    kind: TokenKind

    lexeme: string

    line: int
    column: int

######################
#    Constructors    #
######################

func newToken*(kind: TokenKind, lexeme: string, line: int, column: int): Token =
  result = Token()

  result.kind = kind

  result.lexeme = lexeme

  result.line = line
  result.column = column

###################
#    Accessors    #
###################

func kind*(this: Token): TokenKind = this.kind

func lexeme*(this: Token): string = this.lexeme

func line*(this: Token): int = this.line
func column*(this: Token): int = this.column

###########################
#    Private Functions    #
###########################

##########################
#    Public Functions    #
##########################

func `$`*(this: Token): string = fmt"(kind={this.kind}, lexeme={this.lexeme}, line={this.line}, column={this.column})"
