import std/[strutils]

template err*(msg): untyped =
  raise newException(ValueError, msg)

template safe*(body): untyped {.used.} =
  {.cast(gcsafe).}:
    {.cast(nosideEffect).}:
      body


template joinLines*(s: seq): untyped =
  s.join "\n"
