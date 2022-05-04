template err*(msg): untyped =
  raise newException(ValueError, msg)

template safe*(body): untyped {.used.} =
  {.cast(gcsafe).}:
    {.cast(nosideEffect).}:
      body

