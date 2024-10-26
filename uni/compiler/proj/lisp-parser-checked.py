from pprint import pprint
from dataclasses import dataclass

import ply.lex as lex
import ply.yacc as yacc

# --------------------------------------

class LispNode: 
    pass

@dataclass
class FnDef(LispNode):
    name: str
    args: list[str]
    body: list[LispNode]

@dataclass
class FnCall(LispNode):
    callee: str
    params: list[str]

@dataclass
class Ident(LispNode):
    val: str

@dataclass
class Number(LispNode):
    val: int

# --------------------------------------

# Tokens
tokens = [
    'NUMBER',
    'IDENT', 
    
    'LPAREN', 
    'RPAREN', 
    
    'DEFUN', 
    # 'LOOP'
]


t_LPAREN = r'\('
t_RPAREN = r'\)'
t_NUMBER = r'\d+'
t_ignore = '[ \t\n]'

def t_IDENT(t): 
    r'[^()\s\d]+'

    if   t.value == 'defun': t.type = 'DEFUN'
    # elif t.value == 'loop': t.type = 'LOOP'
    else: pass

    return t

def t_error(p):
    # error token
    print("Token error at '%s'" % p)

# Build the lexer
lexer = lex.lex()

def get_all_tokens(input_string):
    lexer.input(input_string)
    all_tokens = []
    while True:
        tok = lexer.token()
        if not tok: break
        all_tokens.append(tok)
    return all_tokens

# ---------------------------------

def p_program(p):
    '''program : expression_list'''
    p[0] = p[1]

def p_empty(p):
    'empty :'
    pass

def p_expression(p):
    '''expression  : number
                   | ident
                   | call
                   | function_def
    '''
    p[0] = p[1]

def p_number(p):
    '''
    number : NUMBER
    '''
    p[0] = Number(int(p[1]))


def p_ident(p):
    '''
    ident : IDENT
    '''
    p[0] = Ident(p[1])


def p_ident_list(p):
    '''
    ident_list : empty
               | ident ident_list
    '''
    # print([p[a] for a in range(1, len(p))])

    if len(p) == 2:
        p[0] = []

    elif len(p) == 3:
        p[0] = [p[1], *p[2]]

    else:
        raise "error cannot be more than 3"

def p_function_def(p):
    '''
        function_def : LPAREN DEFUN IDENT LPAREN ident_list RPAREN expression_list RPAREN
    '''
    fname = p[3]
    params = p[5]
    body = p[7]

    p[0] = FnDef(fname, params, body)

def p_call(p):
    '''call : LPAREN expression_list RPAREN'''
    p[0] = FnCall(p[2][0], p[2][1:])

def p_expression_list(p):
    '''expression_list : expression
                       | expression expression_list'''
    if len(p) == 3:
        p[0] = [p[1], *p[2]]

    elif len(p) == 2:
        p[0] = [p[1]]

    else:
        raise "err"

def p_error(p):
    print(f"Syntax error at '{p}'")

parser = yacc.yacc()

def parse_lisp(code):
    return parser.parse(code)

# ---------------------------------

input_string = '''
    (print 
        (defun delta (a b c) 
            (- (* b b) (* 4 a c))))
'''

pprint(get_all_tokens(input_string))
pprint("--------------")
print(input_string)
pprint(parse_lisp(input_string))