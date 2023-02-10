#################
#    Imports    #
#################

import nodes

###################
#    Constants    #
###################

#####################
#    Definitions    #
#####################

type Compiler* = ref object
  source: seq[Node]

######################
#    Constructors    #
######################

func newCompiler*(source: seq[Node]): Compiler =
  result = Compiler()

  result.source = source

###################
#    Accessors    #
###################

###########################
#    Private Functions    #
###########################

##########################
#    Public Functions    #
##########################

func compile*(this: Compiler): void = discard
