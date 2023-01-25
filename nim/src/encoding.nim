func decodeU16le*(sl, sh: uint8): uint16 =
  (sl shl 00) or
  (sh shl 08)

func decodeU32le*(sl, b, c, sh: uint8): uint32 =
  (sl shl 00) or
  (b  shl 08) or
  (c  shl 16) or
  (sh shl 24)

func decodeU64le*(sl, b, c, d, e, f, g, sh: uint8): uint64 =
  (sl shl 00) or
  (b  shl 08) or
  (c  shl 16) or
  (d  shl 24) or
  (e  shl 32) or
  (f  shl 40) or
  (g  shl 48) or
  (sh shl 56)

func decodeU16be*(sl, sh: uint8): uint16 =
  (sh shl 00) or
  (sl shl 08)

func decodeU32be*(sl, b, c, sh: uint8): uint32 =
  (sh shl 00) or
  (c  shl 08) or
  (b  shl 16) or
  (sl shl 24)

func decodeU64be*(sl, b, c, d, e, f, g, sh: uint8): uint64 =
  (sh shl 00) or
  (g  shl 08) or
  (f  shl 16) or
  (e  shl 24) or
  (d  shl 32) or
  (c  shl 40) or
  (b  shl 48) or
  (sl shl 56)

func encodeU16le*(a: uint16): array[2, uint8] =
  [
    uint8((0x00_00_00_ff'u32 and a) shr 00),
    uint8((0x00_00_ff_ff'u32 and a) shr 08)
  ]

func encodeU32le*(a: uint32): array[4, uint8] =
  [
    uint8((0x00_00_00_ff'u32 and a) shr 00),
    uint8((0x00_00_ff_ff'u32 and a) shr 08),
    uint8((0x00_ff_ff_ff'u32 and a) shr 16),
    uint8((0xff_ff_ff_ff'u32 and a) shr 24)
  ]

func encodeU64le*(a: uint64): array[8, uint8] =
  [
    uint8((0x00_00_00_00_00_00_00_ff'u64 and a) shr 00),
    uint8((0x00_00_00_00_00_00_ff_ff'u64 and a) shr 08),
    uint8((0x00_00_00_00_00_ff_ff_ff'u64 and a) shr 16),
    uint8((0x00_00_00_00_ff_ff_ff_ff'u64 and a) shr 24),
    uint8((0x00_00_00_ff_ff_ff_ff_ff'u64 and a) shr 32),
    uint8((0x00_00_ff_ff_ff_ff_ff_ff'u64 and a) shr 40),
    uint8((0x00_ff_ff_ff_ff_ff_ff_ff'u64 and a) shr 48),
    uint8((0xff_ff_ff_ff_ff_ff_ff_ff'u64 and a) shr 56)
  ]

func encodeU16be*(a: uint16): array[2, uint8] =
  [
    uint8((0x00_00_ff_ff'u32 and a) shr 08),
    uint8((0x00_00_00_ff'u32 and a) shr 00)
  ]

func encodeU32be*(a: uint32): array[4, uint8] =
  [
    uint8((0xff_ff_ff_ff'u32 and a) shr 24),
    uint8((0x00_ff_ff_ff'u32 and a) shr 16),
    uint8((0x00_00_ff_ff'u32 and a) shr 08),
    uint8((0x00_00_00_ff'u32 and a) shr 00)
  ]

func encodeU64be*(a: uint64): array[8, uint8] =
  [
    uint8((0xff_ff_ff_ff_ff_ff_ff_ff'u64 and a) shr 56),
    uint8((0x00_ff_ff_ff_ff_ff_ff_ff'u64 and a) shr 48),
    uint8((0x00_00_ff_ff_ff_ff_ff_ff'u64 and a) shr 40),
    uint8((0x00_00_00_ff_ff_ff_ff_ff'u64 and a) shr 32),
    uint8((0x00_00_00_00_ff_ff_ff_ff'u64 and a) shr 24),
    uint8((0x00_00_00_00_00_ff_ff_ff'u64 and a) shr 16),
    uint8((0x00_00_00_00_00_00_ff_ff'u64 and a) shr 08),
    uint8((0x00_00_00_00_00_00_00_ff'u64 and a) shr 00)
  ]
