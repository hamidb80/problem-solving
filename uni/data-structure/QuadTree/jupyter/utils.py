

def svg_cirle(x, y, r=2.4):
    return f"""
        <circle cx="{x}" cy="{y}" r="{r}" fill="red"/>
    """


def svg_rect(geo, color="transparent", border=1):
    return f"""
        <rect x="{geo.x}" y="{geo.y}" width="{geo.w}" height="{geo.h}" stroke="black" fill="{color}" stroke-width="{border}"/>
    """


def save_file_binary(path, content):
    file = open(path, "wb")
    file.write(content)
    file.close()


def insersects(r1, r2):
    """

    INTERSECTION:
    A
        +---(2)---+
    +--(1)---+

    B
    +---(2)---+
        +--(1)---+

    C
    +-----(2)------+
       +--(1)---+

    D
       +--(2)---+
    +-----(1)------+


    NO:
    E
                +--(2)---+
    +--(1)--+

    F
    +--(2)--+
                +--(1)--+
    """

    a = max(r1[0], r2[0])
    b = min(r1[1], r2[1])
    ln = (b - a)

    r1_len = (r1[1] - r1[0])
    r2_len = (r2[1] - r2[0])

    return (ln > 0) and (ln <= r1_len) and (ln <= r2_len)


# print(insersects((0, 4), (2, 6)))  # A
# print(insersects((2, 6), (0, 4)))  # B
# print(insersects((0, 6), (2, 3)))  # C
# print(insersects((2, 3), (0, 6)))  # D
# print(insersects((0, 4), (5, 9)))  # E
# print(insersects((5, 9), (0, 4)))  # F
