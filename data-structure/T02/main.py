class Term:
    def __init__(self, degree, coef):
        self.degree = degree
        self.coef = coef

class Polynomial:
    def __init__(self, polynomial=None):  # "2x2+4x6+-3"
        self.terms = []
        if polynomial is not None:
            self.create_poly(polynomial)

    def create_poly(self, poly):
        terms = poly.split("+")
        for term in terms:
            if "x" in term:
                coef, degree = map(int, term.split("x"))
            else:
                coef, degree = int(term), 0
            self.terms.append(Term(coef=coef, degree=degree))
        self.terms.sort(key= lambda x:x.degree, reverse=True)

    def __str__(self):
        poly = ""
        for term in self.terms[:-1]:
            poly += f"{term.coef}x^{term.degree}+"
        if self.terms[-1].degree != 0:
            poly += f"{self.terms[-1].coef}x^{self.terms[-1].degree}"
        else:
            poly += f"{self.terms[-1].coef}"
        return poly

    def __add__(self):  # theta(n^2) --> theta(nlog(n)) --> theta(n)
        pass

p = Polynomial("2x2+4x6+-3x1")
print(p)
# 4x6+2x2+-3x1 4x6+2x2+-3x1