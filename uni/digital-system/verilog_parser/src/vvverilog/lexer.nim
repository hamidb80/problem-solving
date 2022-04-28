import std/[strutils]

type
  VTokenKinds* = enum
    vtkKeyword                            # begin end if else
    vtkString                             # "hello"
    vtkNumber                             # 12 4.6 3b'101

    vtkScope                              # () [] {}
    vtkSign                               # . , : ;

    vtkQuoted                             # `anything
    vtkOperator                           # + - && ~^ !== ?:
    vtkInlineComment, vtkMultiLineComment # //  /* */

  VToken* = object # verilog token
    case kind: VTokenKinds
    of vtkKeyword:
      keyword: string

    of vtkString:
      content: string

    of vtkNumber:
      digits: string

    of vtkSign:
      sign: char

    of vtkQuoted:
      token: string

    of vtkOperator:
      operator: string

    of vtkScope:
      scope: char

    of vtkInlineComment, vtkMultiLineComment:
      comment: string


  LexerState = enum
    lsInit, lsNumber, lsKeyword, lsString
    lsInlineComment, lsMultiLineComment


const
  VerilogIdentStartChars = IdentStartChars + {'$'}
  VerilogIdentChars = IdentStartChars + Digits
  EoC = '\0' # end of content


proc tokenize*(content: string): seq[VToken] =
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


  while true:
    let
      lc = fetchChar i-1 # last char
      cc = fetchChar i   # current char
      fc = fetchChar i+1 # forward char

    case lxState:
    of lsInit:
      case cc:
      of Digits:
        discard

      of VerilogIdentStartChars:
        discard

      of '.', ',', ':', ';':
        result.add VToken(kind: vtkSign, sign: cc)

      of '`':
        discard

      of Whitespace, EoC:
        discard

      of '/':
        case fc:
        of '/':
          lxState = lsInlineComment

        of '*':
          lxState = lsMultiLineComment

        else: # operator
          discard

      of '(', ')', '[', ']', '{', '}':
        discard

      else: # operator
        discard

    of lsNumber:
      discard

    of lsKeyword:
      discard

    of lsString:
      if cc == '"' and lc != '\\':
        result.add VToken(kind: vtkString, content: content[start ..< i])

      reset()

    of lsInlineComment:
      if cc in Newlines:
        reset()

    of lsMultiLineComment:
      if cc == '/' and lc == '*':
        reset()


    if cc == EoC:
      break
