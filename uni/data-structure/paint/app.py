# written by @hamidb80

from dataclasses import *
from typing import *
import sys

from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *


@dataclass
class Line:
    points: list[QPoint]
    color: QColor
    size: int


class History:
    index: int
    events: List

    def __init__(self):
        self.index = -1
        self.events = []

    def get_events(self):
        return self.events[0:self.index + 1]

    def push(self, ev):
        if self.index != len(self.events) - 1:
            print(".. ahead events deleted")
            self.events = self.get_events()

        self.events.append(ev)
        self.index += 1

        print(">> pushed, len: ", len(self.events))

    def move_cursor(self, step):
        if step > 0:
            if self.index < len(self.events) - 1:
                self.index += step

        else:
            if self.index > -1:
                self.index += step

        print(f"&& cursor {self.index}/{len(self.events)}")


class Window(QMainWindow):
    history: History
    brush_size: int
    brush_color: QColor
    current_points: List[QPoint]

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Paint App")
        self.setGeometry(100, 100, 2000, 1800)
        self.build_menu()
        self.init_states()
        self.render()

    def build_menu(self):
        main_menu = self.menuBar()

        # ---
        file_menu = main_menu.addMenu("File")

        save_action = QAction("Save", self)
        save_action.setShortcut("Ctrl+S")
        file_menu.addAction(save_action)
        save_action.triggered.connect(self.save)

        clear_action = QAction("Clear", self)
        clear_action.setShortcut("Ctrl+C")
        file_menu.addAction(clear_action)
        clear_action.triggered.connect(self.clear)

        # ---
        state_menu = main_menu.addMenu("State")

        undo_action = QAction("Undo", self)
        undo_action.setShortcut("Ctrl+Z")
        state_menu.addAction(undo_action)
        undo_action.triggered.connect(self.undo)

        redo_action = QAction("Redo", self)
        redo_action.setShortcut("Ctrl+Y")
        state_menu.addAction(redo_action)
        redo_action.triggered.connect(self.redo)

        # ---
        brush_size_menu = main_menu.addMenu("Brush Size")
        for brush_size in [2, 4, 8, 12, 16, 20]:
            action = QAction(f"{brush_size}px", self)
            brush_size_menu.addAction(action)
            action.triggered.connect(self.gen_brush_size_setter(brush_size))

        brush_color_menu = main_menu.addMenu("Brush Color")
        for (qt_color, color_name) in [(Qt.black, "Black"), (Qt.white, "White"),
                                       (Qt.green, "Green"), (Qt.yellow, "Yellow"),
                                       (Qt.red, "Red")]:

            color = QAction(color_name, self)
            brush_color_menu.addAction(color)
            color.triggered.connect(self.gen_brush_color_setter(qt_color))

    def gen_brush_size_setter(self, size):
        def setter():
            self.brush_size = size

        return setter

    def gen_brush_color_setter(self, color):
        def setter():
            self.brush_color = color

        return setter

    def init_states(self):
        self.history = History()

        self.brush_size = 2  # default brush size
        self.brush_color = Qt.black  # default color

        self.current_points = []

    def render(self):
        self.image = QImage(self.size(), QImage.Format_RGB32)
        self.image.fill(Qt.white)

        self.update()

        for line in self.history.get_events():
            self.draw_line(line)


    def draw_line(self, line: Line):
        painter = QPainter(self.image)

        painter.setPen(
            QPen(line.color, line.size, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))

        for i in range(1, len(line.points)):
            painter.drawLine(line.points[i-1], line.points[i])

        self.update()

    # --- events

    def resizeEvent(self, event: QResizeEvent):
        self.render()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.current_points.append(event.pos())

    def mouseMoveEvent(self, event):
        new_pos = event.pos()
        points = [self.current_points[-1], new_pos]
        self.draw_line(Line(points, self.brush_color, self.brush_size))
        self.current_points.append(new_pos)

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.history.push(
                Line(self.current_points, self.brush_color, self.brush_size))

            self.current_points = []

    def paintEvent(self, event):
        QPainter(self).drawImage(self.rect(), self.image, self.image.rect())

    # --- helpers

    def save(self):
        filePath, _ = QFileDialog.getSaveFileName(
            self, "Save Image", "",
            "PNG(*.png);;JPEG(*.jpg *.jpeg);;All Files(*.*) ")

        if filePath != "":
            self.image.save(filePath)

    def clear(self):
        self.image.fill(Qt.white)
        self.update()

    def undo(self):
        self.history.move_cursor(-1)
        self.render()

    def redo(self):
        self.history.move_cursor(+1)
        self.render()


if __name__ == "__main__":
    App = QApplication(sys.argv)
    window = Window()
    window.show()
    sys.exit(App.exec())
