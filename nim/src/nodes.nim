#################
#    Imports    #
#################

from std/strformat import fmt

from environments import Environment, `$`
from tokens import Token, `$`

###################
#    Constants    #
###################

#####################
#    Definitions    #
#####################

type
  NodeKind* = enum
    NK_PROGRAM

    NK_STMT_BLOCK
    NK_STMT_WHILE
    NK_STMT_IF
    NK_STMT_DEFINE
    NK_STMT_EXPR

    NK_EXPR_BINARY
    NK_EXPR_UNARY
    NK_EXPR_ASSIGN
    NK_EXPR_LITERAL
    NK_EXPR_VARIABLE
    NK_EXPR_FUNC_CALL

  Node* = ref object of RootObj
    case kind: NodeKind:
    of NK_PROGRAM:
      programEnv*: Environment
      programBody*: seq[Node]
    of NK_STMT_BLOCK:
      blockEnv*: Environment
      blockBody*: seq[Node]
    of NK_STMT_WHILE:
      whileCondition*: Node
      whileBody*: Node
    of NK_STMT_IF:
      ifCondition*: Node
      ifBody*: Node
    of NK_STMT_DEFINE:
      defineIdentifier*: Token
      defineKind*: Token
      defineValue*: Node
    of NK_STMT_EXPR:
      stmtExpr*: Node
    of NK_EXPR_BINARY:
      bopOperand1*: Node
      bopOperator*: Token
      bopOperand2*: Node
    of NK_EXPR_UNARY:
      uopOperator*: Token
      uopOperand1*: Node
    of NK_EXPR_ASSIGN:
      assignIdentifier*: Token
      assignValue*: Node
    of NK_EXPR_LITERAL:
      literalValue*: Token
    of NK_EXPR_VARIABLE:
      variableIdentifier*: Token
    of NK_EXPR_FUNC_CALL:
      funcCallIdentifier*: Token
      funcCallArguments*: seq[Node]

######################
#    Constructors    #
######################

func newProgram*(programBody: seq[Node], programEnv: Environment): Node =
  result = Node(kind: NK_PROGRAM)

  result.programBody = programBody
  result.programEnv = programEnv

template newProgram*(): Node = newProgram(newSeq[Node](), nil)

func newBlockStatement*(blockBody: seq[Node], blockEnv: Environment): Node =
  result = Node(kind: NK_STMT_BLOCK)

  result.blockBody = blockBody
  result.blockEnv = blockEnv

template newBlockStatement*(): Node = newBlockStatement(newSeq[Node](), nil)

func newWhileStatement*(whileCondition: Node, whileBody: Node): Node =
  result = Node(kind: NK_STMT_WHILE)

  result.whileCondition = whileCondition
  result.whileBody = whileBody

template newWhileStatement*(): Node = newWhileStatement(nil, nil)

func newIfStatement*(ifCondition: Node, ifBody: Node): Node =
  result = Node(kind: NK_STMT_IF)

  result.ifCondition = ifCondition
  result.ifBody = ifBody

template newIfStatement*(): Node = newIfStatement(nil, nil)

func newDefineStatement*(defineIdentifier: Token, defineKind: Token, defineValue: Node): Node =
  result = Node(kind: NK_STMT_DEFINE)

  result.defineIdentifier = defineIdentifier
  result.defineKind = defineKind
  result.defineValue = defineValue

template newDefineStatement*(): Node = newDefineStatement(nil, nil, nil)

func newExpressionStatement*(stmtExpr: Node): Node =
  result = Node(kind: NK_STMT_EXPR)

  result.stmtExpr = stmtExpr

template newExpressionStatement*(): Node = newExpressionStatement(nil)

func newBinaryExpression*(operand1: Node, operator: Token, operand2: Node): Node =
  result = Node(kind: NK_EXPR_BINARY)

  result.bopOperand1 = operand1
  result.bopOperator = operator
  result.bopOperand2 = operand2

template newBinaryExpression*(): Node = newBinaryExpression(nil, nil, nil)

func newUnaryExpression*(operand1: Node, operator: Token): Node =
  result = Node(kind: NK_EXPR_UNARY)

  result.uopOperator = operator
  result.uopOperand1 = operand1

template newUnaryExpression*(): Node = newUnaryExpression(nil, nil)

func newAssignExpression*(assignIdentifier: Token, assignValue: Node): Node =
  result = Node(kind: NK_EXPR_ASSIGN)

  result.assignIdentifier = assignIdentifier
  result.assignValue = assignValue

template newAssignExpression*(): Node = newAssignExpression(nil, nil)

func newLiteralExpression*(literalValue: Token): Node =
  result = Node(kind: NK_EXPR_LITERAL)

  result.literalValue = literalValue

template newLiteralExpression*(): Node = newLiteralExpression(nil)

func newVariableExpression*(variableIdentifier: Token): Node =
  result = Node(kind: NK_EXPR_VARIABLE)

  result.variableIdentifier = variableIdentifier

template newVariableExpression*(): Node = newVariableExpression(nil)

func newFunctionCallExpression*(identifier: Token, args: seq[Node]): Node =
  result = Node(kind: NK_EXPR_FUNC_CALL)

  result.funcCallIdentifier = identifier
  result.funcCallArguments = args

template newFunctionCallExpression*(): Node = newFunctionCallExpression(nil, newSeq[Node]())

###################
#    Accessors    #
###################

###########################
#    Private Functions    #
###########################

##########################
#    Public Functions    #
##########################

func `$`*(this: Node): string =
  return case this.kind:
  of NK_PROGRAM:        fmt"(kind={this.kind}, body={this.programBody}, env={this.programEnv})"
  of NK_STMT_BLOCK:     fmt"(kind={this.kind}, body={this.blockBody}, env={this.blockEnv})"
  of NK_STMT_WHILE:     fmt"(kind={this.kind}, condition={this.whileCondition}, body={this.whileBody})"
  of NK_STMT_IF:        fmt"(kind={this.kind}, condition={this.ifCondition}, body={this.ifBody})"
  of NK_STMT_DEFINE:    fmt"(kind={this.kind}, identifier={this.defineIdentifier}, type={this.defineKind}, value={this.defineValue})"
  of NK_STMT_EXPR:      fmt"(kind={this.kind}, expression={this.stmtExpr})"
  of NK_EXPR_BINARY:    fmt"(kind={this.kind}, operand1={this.bopOperand1}, operator={this.bopOperator}, operand2={this.bopOperand2})"
  of NK_EXPR_UNARY:     fmt"(kind={this.kind}, operator={this.uopOperator}, operand1={this.uopOperand1})"
  of NK_EXPR_ASSIGN:    fmt"(kind={this.kind}, identifier={this.assignIdentifier}, value={this.assignValue})"
  of NK_EXPR_LITERAL:   fmt"(kind={this.kind}, value={this.literalValue})"
  of NK_EXPR_VARIABLE:  fmt"(kind={this.kind}, value={this.variableIdentifier})"
  of NK_EXPR_FUNC_CALL: fmt"(kind={this.kind}, identifier={this.funcCallIdentifier}, args={this.funcCallArguments})"
