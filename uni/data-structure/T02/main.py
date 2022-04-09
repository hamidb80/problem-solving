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
        self.terms.sort(key=lambda x: x.degree, reverse=True)

    def __str__(self):
        poly = ""
        for term in self.terms[:-1]:
            poly += f"{term.coef}x^{term.degree}+"
        if self.terms[-1].degree != 0:
            poly += f"{self.terms[-1].coef}x^{self.terms[-1].degree}"
        else:
            poly += f"{self.terms[-1].coef}"
        return poly

    def __repr__(self):
        return [(t.degree, t.coef) for t in self.terms]

    def __add__(p1, p2):
        i1, i2 = 0, 0
        new_p = Polynomial()

        while True:
            e1 = i1 in range(len(p1.terms))
            e2 = i2 in range(len(p2.terms))

            try:
                c1 = p1.terms[i1].coef
                c2 = p2.terms[i2].coef
            except:
                ...

            if e1 and e2:
                d1 = p1.terms[i1].degree
                d2 = p2.terms[i2].degree

                if d1 == d2:
                    new_p.terms.append(Term(d1, c1 + c2))
                    i1 += 1
                    i2 += 1

                elif d1 > d2:
                    new_p.terms.append(Term(d1, c1))
                    i1 += 1

                else:
                    new_p.terms.append(Term(d2, c2))
                    i2 += 1

            elif e1:
                new_p.terms.append(Term(d1, c1))
                i1 += 1

            elif e2:
                new_p.terms.append(Term(d2, c2))
                i2 += 1

            else:
                return new_p


p1 = Polynomial("1x5+1x2")
p2 = Polynomial("1x3+3x2")
print(p1.__repr__())
print(p2.__repr__())
print((p1 + p2).__repr__())
# 4x6+2x2+-3x1 4x6+2x2+-3x1
