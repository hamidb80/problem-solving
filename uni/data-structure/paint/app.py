# author: @hamidb80

import sys
from typing import *

from dataclasses import *

from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


# _-- Funcdumental Data Structures

class Stack:
    data: List

    def __init__(self):
        self.data = []

    def push(self, v):
        self.data.append(v)

    def pop(self):
        return self.data.pop()

    def reset(self):
        self.data = []

    def is_empty(self):
        return len(self.data) == 0


class History:
    past: Stack
    future: Stack

    def __init__(self):
        self.past = Stack()
        self.future = Stack()

    def push(self, val):
        self.past.push(val)
        self.future.reset()

    def undo(self):
        if not self.past.is_empty():
            self.future.push(self.past.pop())

    def redo(self):
        if not self.future.is_empty():
            self.past.push(self.future.pop())

    def get_current_data(self):
        return self.past.data

# --- App Specefic Data Strcutures


@dataclass
class Line:
    points: list[QPoint]
    color: QColor

# --- App Specefic Constants


LINE_WIDTH = 4
WHITE = QColor('#FFFFFF')

# --- visual Components


class Canvas(QLabel):
    pen_color: QColor
    drawn_points: List[tuple]
    history: History

    def __init__(self, height, width, background_color=WHITE):
        super().__init__()

        qpixmap = QPixmap(int(height), int(width))
        qpixmap.fill(background_color)
        self.setPixmap(qpixmap)

        self.pen_color = QColor('#000000')
        self.drawn_points = []
        self.history = History()

    def mousePressEvent(self, e: QMouseEvent):
        self.drawn_points.append((e.x(), e.y()))

    def mouseMoveEvent(self, e):
        last_point = self.drawn_points[-1]
        new_point = (e.x(), e.y())

        self.draw_segement(last_point, new_point,
                           self.pen_color, LINE_WIDTH, True)
        self.drawn_points.append(new_point)

    def mouseReleaseEvent(self, _):
        self.history.push(Line(self.drawn_points, self.pen_color))
        self.drawn_points = []

    def set_pen_color(self, color):
        self.pen_color = QColor(color)

    def draw_segement(self, p1, p2, color, width, should_update):
        painter = QPainter(self.pixmap())
        p = painter.pen()
        p.setWidth(width)
        p.setColor(color)

        painter.setPen(p)
        painter.drawLine(p1[0], p1[1], p2[0], p2[1])
        painter.end()

        if should_update:
            self.update()

    def draw_line(self, points, color, width):
        for i in range(1, len(points)):
            self.draw_segement(points[i-1], points[i], color, width, True)

    def refill(self):
        self.pixmap().fill(WHITE)

    def draw_all_lines(self):
        for l in self.history.get_current_data():
            self.draw_line(l.points, l.color, LINE_WIDTH)

    def time_travel(self, undo: bool):
        """
        the screen gets cleaned and is redrawn from the very first action
        """

        if undo:
            self.history.undo()
        else:
            self.history.redo()

        self.refill()
        self.draw_all_lines()
        self.update()


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

        self.build_menu()

    def build_menu(self):
        main_menu = self.menuBar()

        state_menu = main_menu.addMenu("State")

        undo_action = QAction("Undo", self)
        undo_action.setShortcut("Ctrl+Z")
        state_menu.addAction(undo_action)
        undo_action.triggered.connect(self.undo)

        redo_action = QAction("Redo", self)
        redo_action.setShortcut("Ctrl+Y")
        state_menu.addAction(redo_action)
        redo_action.triggered.connect(self.redo)

    def add_palette_button(self, palette):
        for c in self.colors:
            item = PaletteButton(c)
            item.pressed.connect(self.set_canvas_color)
            palette.addWidget(item)

    def set_canvas_color(self):
        self.canvas.set_pen_color(self.sender().color)

    def undo(self):
        self.canvas.time_travel(True)

    def redo(self):
        self.canvas.time_travel(False)


# --- run

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.setWindowFlags(Qt.WindowCloseButtonHint |
                          Qt.WindowMinimizeButtonHint)
    window.show()
    app.exec_()
