import ply.lex as lex
import ply.yacc as yacc
from pprint import pprint

# Tokens
tokens = ['NUMBER', 'IDENT', 'LPAREN', 'RPAREN']

# Regular expression rules for tokens
t_NUMBER = r'\d+'
t_IDENT = r'[^()\s\d]+'
t_LPAREN = r'\('
t_RPAREN = r'\)'
t_ignore = '[ \t\n]'

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
    '''program : expression'''
    p[0] = p[1]

def p_expression(p):
    '''expression : NUMBER
                   | IDENT
                   | call'''
    p[0] = p[1]

def p_call(p):
    '''call : LPAREN expression_list RPAREN'''
    p[0] = p[2]

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
pprint(parse_lisp(input_string))
