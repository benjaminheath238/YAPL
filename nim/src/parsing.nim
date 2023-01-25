from std/parseutils import parseHex, parseOct, parseBin, parseInt

func parseUx(source: string): SomeUnsignedInt =
  result = 0
  
  if 1 >= high source:  # If the string is <= 2 chars it can not be hex/oct/bin
    let length = parseInt(source, result, 0)
    if length != source.len or length == 0:
      raise newException(ValueError, "Invalid dec integer: " & source)
  elif source[0..1] in ["0x", "0X"]:
    let length = parseHex(source, result, 0)
    if length != source.len or length == 0:
      raise newException(ValueError, "Invalid hex integer: " & source)
  elif source[0..1] in ["0b", "0B"]:
    let length = parseBin(source, result, 0)
    if length != source.len or length == 0:
      raise newException(ValueError, "Invalid bin integer: " & source)
  elif source[0..1] in ["0o", "0O"]:
    let length = parseOct(source, result, 0)
    if length != source.len or length == 0:
      raise newException(ValueError, "Invalid oct integer: " & source)
  else:
    let length = parseInt(source, result, 0)
    if length != source.len or length == 0:
      raise newException(ValueError, "Invalid dec integer: " & source)

func parseU8*(source: string): uint8 = parseUx(source)
func parseU16*(source: string): uint16 = parseUx(source)
func parseU32*(source: string): uint32 = parseUx(source)
func parseU64*(source: string): uint64 = parseUx(source)
