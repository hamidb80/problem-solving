def toCircle(x, y, r=2.4, color='red'):
    return f"""
        <circle cx="{x}" cy="{y}" r="{r}" fill="{color}"/>
    """

def toRect(geo, color="transparent", border=1):
    return f"""
        <rect x="{geo.x}" y="{geo.y}" width="{geo.w}" height="{geo.h}" stroke="black" fill="{color}" stroke-width="{border}"/>
    """
