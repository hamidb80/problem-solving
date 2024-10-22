from pprint import pprint
# pip install ply
import ply.lex  as lex 
import ply.yacc as yacc

# lexer -----------------------------------------

tokens = [
    'OP',  # open paren
    'CP',  # close paren
    'ID',  # identifier
    'NUM', # number
    'STR', # string
]

t_OP = r'\('
t_CP = r'\)'
t_ID = r'[^ 0-9()"]+'
t_NUM = r'[0-9]+'
t_STR = r'".*?"'

t_ignore = r'[ \n]'

def t_error(p):
    print(f"error: {p}")

lexer = lex.lex() # init

def get_all_tokens(input_string): # debug
    lexer.input(input_string)
    all_tokens = []
    while True:
        tok = lexer.token()
        if not tok: break
        all_tokens.append(tok)
    return all_tokens

# parser ------------------------------------------

def p_program(p):
    '''
    program : expr_list
    '''
    p[0] = p[1]

def p_expr_list(p):
    '''
    expr_list : empty
              | expr expr_list
    '''

    if len(p) == 2:
        p[0] = []
    elif len(p) == 3:
        p[0] = [p[1], *p[2]]
    else:
        raise "nadarim"
    
def p_empty(p):
    '''
    empty :
    '''

def p_expr(p):
    '''
    expr : num
         | id
    '''
    p[0] = p[1]

def p_id(p):
    '''
    id : ID
    '''
    p[0] = p[1]

def p_num(p):
    '''
    num : NUM
    '''
    p[0] = int(p[1])


def p_error(p):
    print(f"Syntax error at '{p}'")

parser = yacc.yacc()

def parse_lisp(code):
    return parser.parse(code)

# test ----------------------------------------

input_string = '1 a b'

print(input_string)
pprint(get_all_tokens("( - (* b b) (* 4 a c))"))
pprint(parse_lisp(input_string))
