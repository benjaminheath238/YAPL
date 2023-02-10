#################
#    Imports    #
#################

from std/parseutils import parseHex, parseOct, parseBin, parseInt

###################
#    Constants    #
###################

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

func parseUx(source: string): SomeUnsignedInt =
  result = 0
  
  if 1 >= high source:  # If the string is <= 2 chars it can not be hex/oct/bin
    let parsed = parseInt(source, result, 0)
    if parsed != source.len or parsed == 0:
      raise newException(ValueError, "Invalid dec integer: " & source)
  elif source[0..1] in ["0x", "0X"]:
    let parsed = parseHex(source, result, 0)
    if parsed != source.len or parsed == 0:
      raise newException(ValueError, "Invalid hex integer: " & source)
  elif source[0..1] in ["0b", "0B"]:
    let parsed = parseBin(source, result, 0)
    if parsed != source.len or parsed == 0:
      raise newException(ValueError, "Invalid bin integer: " & source)
  elif source[0..1] in ["0o", "0O"]:
    let parsed = parseOct(source, result, 0)
    if parsed != source.len or parsed == 0:
      raise newException(ValueError, "Invalid oct integer: " & source)
  else:
    let parsed = parseInt(source, result, 0)
    if parsed != source.len or parsed == 0:
      raise newException(ValueError, "Invalid dec integer: " & source)

func parseIx(source: string): SomeSignedInt =
  if source[0] == '-':
    result = parseUx(source[1..high source])
    result = -1 * result
  else:
    result = parseUx(source[0..high source])

##########################
#    Public Functions    #
##########################

func parseU8*(source: string): uint8 = parseUx(source)
func parseU16*(source: string): uint16 = parseUx(source)
func parseU32*(source: string): uint32 = parseUx(source)
func parseU64*(source: string): uint64 = parseUx(source)

func parseI8*(source: string): int8 = parseIx(source)
func parseI16*(source: string): int16 = parseIx(source)
func parseI32*(source: string): int32 = parseIx(source)
func parseI64*(source: string): int64 = parseIx(source)
