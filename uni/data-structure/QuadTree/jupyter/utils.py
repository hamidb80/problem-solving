# --- converting .SVG to .PNG
from cairosvg import svg2png  # pip install cairosvg


class SVG:
    """
    SVG utility
    """

    @staticmethod
    def toCircle(x, y, r=2.4, color='red'):
        return f"""
            <circle cx="{x}" cy="{y}" r="{r}" fill="{color}"/>
        """

    @staticmethod
    def toRect(geo, color="transparent", border=1):
        return f"""
            <rect x="{geo.x}" y="{geo.y}" width="{geo.w}" height="{geo.h}" stroke="black" fill="{color}" stroke-width="{border}"/>
        """

    @staticmethod
    def toPNG(content) -> bytes:
        return svg2png(bytestring=content)


def save_file_binary(path, content):
    file = open(path, "wb")
    file.write(content)
    file.close()
