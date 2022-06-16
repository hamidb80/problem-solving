import sys
from typing import *

from dataclasses import *

from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


# _------------------------

class Stack:
    data: List

    def __init__(self):
        self.data = []

    def push(self, v):
        self.data.append(v)

    def pop(self, v):
        return self.data.pop(v)

    def reset(self):
        self.data.clear()

    def is_empty(self):
        return len(self.data) == 0


class History:
    past: Stack
    future: Stack

    def __init__(self):
        self.past = Stack()
        self.future = Stack()

    def push(self, ev):
        self.future.reset()
        self.past.push(ev)

    def undo(self):
        if not self.past.is_empty():
            self.future.push(self.past.pop())

    def redo(self):
        if not self.future.is_empty():
            self.past.push(self.future.pop())

    def get_current_data(self):
        return self.past.data

# _------------------------


@dataclass
class Line:
    points: list[QPoint]
    color: QColor


LINE_WIDTH = 4


class Canvas(QLabel):
    pen_color: QColor
    drawn_points: List[tuple]

    def __init__(self, height, width, background_color=QColor('#FFFFFF')):
        super().__init__()
        qpixmap = QPixmap(int(height), int(width))
        qpixmap.fill(background_color)
        self.setPixmap(qpixmap)
        self.pen_color = QColor('#000000')
        self.drawn_points = []

    def set_pen_color(self, color):
        self.pen_color = QColor(color)

    def draw_line(self, p1, p2):
        painter = QPainter(self.pixmap())
        p = painter.pen()
        p.setWidth(LINE_WIDTH)
        p.setColor(self.pen_color)
        painter.setPen(p)
        painter.drawLine(p1[0], p1[1], p2[0], p2[1])
        painter.end()
        self.update()

    def mousePressEvent(self, e: QMouseEvent):
        self.drawn_points.append((e.x(), e.y()))

    def mouseMoveEvent(self, e):
        last_point = self.drawn_points[-1]
        new_point = (e.x(), e.y())

        self.draw_line(last_point, new_point)
        self.drawn_points.append(new_point)

    def mouseReleaseEvent(self, _):
        self.drawn_points.clear()


class PaletteButton(QPushButton):
    def __init__(self, color):
        super().__init__()

        self.setFixedSize(QSize(32, 32))
        self.color = color

        self.setStyleSheet(f"""
            background-color: {color};
            border-radius : 15;
        """)


class MainWindow(QMainWindow):
    colors = [
        '#000002', '#868687', '#900124', '#ed2832', '#2db153', '#13a5e7', '#4951cf',
        '#fdb0ce', '#fdca0f', '#eee3ab', '#9fdde8', '#7a96c2', '#cbc2ec', '#a42f3b',
        '#f45b7a', '#c24998', '#81588d', '#bcb0c2', '#dbcfc2',
    ]

    def __init__(self):
        super().__init__()

        app = QApplication.instance()
        screen = app.primaryScreen()
        geometry = screen.availableGeometry()

        self.canvas = Canvas(geometry.width()*0.60, geometry.height()*0.7)

        w = QWidget()
        l = QVBoxLayout()  # vertical layout

        w.setStyleSheet("background-color: #313234")
        w.setLayout(l)
        l.addWidget(self.canvas)

        palette = QHBoxLayout()  # horizontal layout
        self.add_palette_button(palette)
        l.addLayout(palette)

        self.setCentralWidget(w)

    def add_palette_button(self, palette):
        for c in self.colors:
            item = PaletteButton(c)
            item.pressed.connect(self.set_canvas_color)
            palette.addWidget(item)

    def set_canvas_color(self):
        self.canvas.set_pen_color(self.sender().color)

# ----------------------


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.setWindowFlags(Qt.WindowCloseButtonHint |
                          Qt.WindowMinimizeButtonHint)
    window.show()
    app.exec_()
