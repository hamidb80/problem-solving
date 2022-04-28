import std/[strutils]

type
  VTokenKinds* = enum
    vtkKeyword   # begin end if `pragma
    vtkString    # "hello"
    vtkNumber    # 12 4.6 3b'101

    vtkScope     # () [] {}
    vtkSeparator # . , : ;

    vtkOperator  # + - && ~^ !== ?:
    vtkComment   # //  /* */

  VToken* = object # verilog token
    case kind: VTokenKinds
    of vtkKeyword:
      keyword: string

    of vtkString:
      content: string

    of vtkNumber:
      digits: string

    of vtkSeparator:
      sign: char

    of vtkOperator:
      operator: string

    of vtkScope:
      scope: char

    of vtkComment:
      inline: bool
      comment: string


  LexerState = enum
    lsInit
    lsNumber, lsKeyword, lsString
    lsOperator
    lsInlineComment, lsMultiLineComment


const
  VerilogIdentStartChars = IdentStartChars + {'$'}
  EoC = '\0' # end of content
  Stoppers = Whitespace + {EoC}


iterator vlex*(content: string): VToken =
  var
    lxState = lsInit
    i = 0
    start = 0

  template reset: untyped =
    lxState = lsInit
  template fetchChar(i: int): untyped =
    if i in 0 ..< content.len:
      content[i]
    else:
      EoC
  template append(newToken): untyped =
    yield newToken
    reset()

  while true:
    let
      lc = fetchChar i-1 # last char
      cc = fetchChar i   # current char
      fc = fetchChar i+1 # forward char

    case lxState:
    of lsInit:
      case cc:
      of Digits:
        lxState = lsNumber
        start = i
        inc i

      of VerilogIdentStartChars, '`':
        lxState = lsKeyword
        start = i
        inc i

      of '"':
        lxState = lsString
        inc i
        start = i

      of '.', ',', ':', ';':
        append VToken(kind: vtkSeparator, sign: cc)
        inc i

      of '/':
        case fc:
        of '/':
          lxState = lsInlineComment
          inc i, 2
          start = i

        of '*':
          lxState = lsMultiLineComment
          inc i, 2
          start = i

        else:
          lxState = lsOperator
          start = i
          inc i

      of '(', ')', '[', ']', '{', '}':
        append VToken(kind: vtkScope, scope: cc)
        inc i

      of Stoppers:
        inc i

      else:
        lxState = lsOperator
        start = i
        inc i

    of lsKeyword:
      case cc:
      of IdentChars: 
        inc i
      else:
        append VToken(kind: vtkKeyword, keyword: content[start ..< i])

    of lsNumber:
      case cc:
      of '.', '_',  '\'', 'b', 'h', Digits, 'A' .. 'F', 'x', 'Z': 
        inc i
      else:
        append VToken(kind: vtkNumber, digits: content[start ..< i])

    of lsString:
      if cc == '"' and lc != '\\':
        append VToken(kind: vtkString, content: content[start ..< i])

      inc i

    of lsOperator:
      if cc in "/&!:?~+-%<=>^|":
        inc i
      else:
        append VToken(kind: vtkOperator, operator: content[start ..< i])

    of lsInlineComment:
      if cc in Newlines:
        append VToken(kind: vtkComment, comment: content[start ..< i], inline: true)

      inc i

    of lsMultiLineComment:
      if cc == '/' and lc == '*':
        append VToken(kind: vtkComment, comment: content[start ..< i-1], inline: false)

      inc i

    if cc == EoC:
      break

