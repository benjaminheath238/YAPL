#################
#    Imports    #
#################

from std/tables import TableRef, Table, newTable, toTable, contains, pairs, `[]`, `[]=`, `$`
from std/sugar import `=>`, `->`

import environments
import nodes
import tokens

#####################
#    Definitions    #
#####################

type
  ParseError* = CatchableError
  
  Parser* = ref object
    source: seq[Token]
    
    index: int

    ast: Node

    gEnv: Environment
    lEnv: Environment

###################
#    Constants    #
###################

const
  BINARY_PRECEDENCE_LEVELS: Table[TokenKind, int] = toTable[TokenKind, int]([
    (TK_ASSIGN, 2),
    (TK_ADD, 3),
    (TK_SUB, 3),
    (TK_MUL, 5),
    (TK_DIV, 5),
  ])

  UNARY_PRECEDENCE_LEVELS: Table[TokenKind, int] = toTable[TokenKind, int]([
    (TK_ADD, 4),
    (TK_SUB, 4),
  ])

  LASSOC: bool = true
  RASSOC: bool = false

  ASSOCIATIVITIES: Table[TokenKind, bool] = toTable[TokenKind, bool]([
    (TK_ASSIGN, RASSOC),
    (TK_ADD,    LASSOC),
    (TK_SUB,    LASSOC),
    (TK_MUL,    LASSOC),
    (TK_DIV,    LASSOC),
  ])

######################
#    Constructors    #
######################

func newParser*(source: seq[Token]): Parser =
  result = Parser()

  result.source = source

  result.index = 0

  result.gEnv = newEnvironment(nil)
  result.lEnv = result.gEnv

###################
#    Accessors    #
###################

func ast*(this: Parser): Node = this.ast
func env*(this: Parser): Environment = this.gEnv

###########################
#    Private Functions    #
###########################

template eos(this: Parser, lookahead: int = 0): bool = this.index + lookahead > high this.source

template read(this: Parser, lookahead: int = 0): Token = this.source[this.index + lookahead]

template next(this: Parser): void = this.index.inc()

func matches(this: Parser, kind: TokenKind, lookahead: int = 0): bool = this.read(lookahead).kind == kind
func matches(this: Parser, kinds: set[TokenKind], lookahead: int = 0): bool = this.read(lookahead).kind in kinds

func expected(this: Parser, kind: TokenKind, lookahead: int = 0, got: Token = this.read(lookahead)): void = raise newException(ParseError, "[" & $got.line & ":" & $got.column & "] Expected [\"" & $kind & "\"] but got " & $got.kind)
func expected(this: Parser, kinds: set[TokenKind], lookahead: int = 0, got: Token = this.read(lookahead)): void = raise newException(ParseError, "[" & $got.line & ":" & $got.column & "] Expected " & $kinds & " but got " & $got.kind)

func expects(this: Parser, kind: TokenKind or set[TokenKind]): void =
  if this.matches(kind):
    this.next()
  else:
    this.expected(kind)

template expect(this: Parser, kind: TokenKind or set[TokenKind], code: untyped): void =
  while not this.matches(kind):
    code
  this.expects(kind)

template enterScope(this: Parser): void = this.lEnv = newEnvironment(this.lEnv)
template exitScope(this: Parser): void = this.lEnv = this.lEnv.parent

template scoped(this: Parser, code: untyped): void =
  this.enterScope()
  
  code

  this.exitScope()

func parsePrimary(this: Parser): Node
func parseExpr(this: Parser, precedence: int = 0): Node
func parseStmt(this: Parser): Node

func parsePrimary(this: Parser): Node =
  case this.read().kind:
  of TK_IDENTIFIER:
    if this.matches(TK_LPAREN, 1):
      this.expects(TK_IDENTIFIER)

      result = newFunctionCallExpression()

      result.funcCallIdentifier = this.read(-1)

      this.expects(TK_LPAREN)
      
      this.expect(TK_RPAREN):
        result.funcCallArguments.add(this.parseExpr())

        if not this.matches(TK_RPAREN):
          this.expects(TK_COMMA)
    else:
      this.expects(TK_IDENTIFIER)

      result = newVariableExpression()

      result.variableIdentifier = this.read(-1)
  of {TK_LITERAL_BOOL..TK_LITERAL_CHAR}:
    this.expects({TK_LITERAL_BOOL..TK_LITERAL_CHAR})

    result = newLiteralExpression()

    result.literalValue = this.read(-1)
  else:
    this.expected({TK_IDENTIFIER, TK_LITERAL_BOOL..TK_LITERAL_CHAR})    

func parseExpr(this: Parser, precedence: int = 0): Node =
  if not (this.matches({TK_ADD..TK_DIV}, 1) and BINARY_PRECEDENCE_LEVELS[this.read(1).kind] >= precedence):
    case this.read().kind:
    of {TK_ADD, TK_SUB}:
      this.expects({TK_ADD, TK_SUB})

      result = newUnaryExpression()

      result.uopOperator = this.read(-1)

      result.uopOperand1 = this.parseExpr(precedence)
    of TK_LPAREN:
      this.expects(TK_LPAREN)

      result = this.parseExpr()

      this.expects(TK_RPAREN)
    of {TK_IDENTIFIER, TK_LITERAL_BOOL..TK_LITERAL_CHAR}:
      result = this.parsePrimary()
    else:
      this.expected({TK_ADD, TK_SUB, TK_LPAREN, TK_LITERAL_BOOL..TK_LITERAL_CHAR})
  else:
    while not this.eos(1) and this.matches({TK_ADD..TK_DIV}, 1) and BINARY_PRECEDENCE_LEVELS[this.read(1).kind] >= precedence:
      result = newBinaryExpression()

      result.bopOperand1 = this.parsePrimary()

      this.expects({TK_ADD..TK_DIV})

      result.bopOperator = this.read(-1)

      result.bopOperand2 = this.parseExpr(
        if ASSOCIATIVITIES[result.bopOperator.kind]:
          BINARY_PRECEDENCE_LEVELS[result.bopOperator.kind] + 1
        else:
          BINARY_PRECEDENCE_LEVELS[result.bopOperator.kind] + 0
      )

func parseStmt(this: Parser): Node =
  case this.read().kind:
  of TK_LBRACE:
    this.expects(TK_LBRACE)
    this.scoped():
      result = newBlockStatement()

      this.expect(TK_RBRACE):
        result.blockBody.add(this.parseStmt())

      result.blockEnv = this.lEnv
  of TK_WHILE:
    this.expects(TK_WHILE)
    
    result = newWhileStatement()
    
    this.expects(TK_LPAREN)

    result.whileCondition = this.parseExpr()

    this.expects(TK_RPAREN)

    result.whileBody = this.parseStmt()
  of TK_IF:
    this.expects(TK_IF)

    result = newIfStatement()

    this.expects(TK_LPAREN)

    result.ifCondition = this.parseExpr()

    this.expects(TK_RPAREN)

    result.ifBody = this.parseStmt()
  of {TK_VAR..TK_CONST}:
    this.expects({TK_VAR..TK_CONST})

    result = newDefineStatement()

    this.expects(TK_IDENTIFIER)

    result.defineIdentifier = this.read(-1)

    this.expects(TK_COLON)
    this.expects(TK_IDENTIFIER)

    result.defineKind = this.read(-1)

    var symbol: Symbol = newSymbol(result.defineIdentifier.lexeme, result.defineKind.lexeme)

    if this.matches(TK_ASSIGN):
      this.expects(TK_ASSIGN)
      
      result.defineValue = this.parseExpr()
    
    this.lEnv[symbol.identifier] = symbol

    this.expects(TK_SEMI)
  of TK_IDENTIFIER:
    this.expects(TK_IDENTIFIER)

    result = newExpressionStatement()

    result.stmtExpr = this.parseExpr()

    this.expects(TK_SEMI)
  else:      
    this.expected({TK_WHILE, TK_IF, TK_LBRACE, TK_IDENTIFIER})

func parseProg(this: Parser): Node =
  let node: Node = newProgram()
  while not this.eos():
    node.programBody.add(this.parseStmt())

  node.programEnv = this.lEnv

  return node

##########################
#    Public Functions    #
##########################

func parse*(this: Parser): void =
  this.ast = this.parseProg()
