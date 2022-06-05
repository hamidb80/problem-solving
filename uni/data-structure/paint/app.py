# importing libraries
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from typing import *
import sys


def gen_line(ps: List[QPoint], color, size):
    return dict(points=ps, color=color, size=size)


class Window(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Paint App")
        self.setGeometry(100, 100, 1000, 800)
        self.render()
        self.build_menu()
        self.init_states()

    def build_menu(self):
        mainMenu = self.menuBar()
        fileMenu = mainMenu.addMenu("File")

        saveAction = QAction("Save", self)
        saveAction.setShortcut("Ctrl + S")
        fileMenu.addAction(saveAction)
        saveAction.triggered.connect(self.save)

        clearAction = QAction("Clear", self)
        clearAction.setShortcut("Ctrl + C")
        fileMenu.addAction(clearAction)
        clearAction.triggered.connect(self.clear)

        brush_size_menu = mainMenu.addMenu("Brush Size")
        for brush_size in [2, 4, 8, 12, 16, 20]:
            action = QAction(f"{brush_size}px", self)
            brush_size_menu.addAction(action)
            action.triggered.connect(self.gen_brush_size_setter(brush_size))

        brush_color_menu = mainMenu.addMenu("Brush Color")
        for (qt_color, color_name) in [(Qt.black, "Black"), (Qt.white, "White"),
                                       (Qt.green, "Green"), (Qt.yellow, "Yellow"),
                                       (Qt.red, "Red")]:

            color = QAction(color_name, self)
            brush_color_menu.addAction(color)
            color.triggered.connect(self.gen_brush_color_setter(qt_color))

    def gen_brush_size_setter(self, size):
        def setter():
            self.brushSize = size

        return setter

    def gen_brush_color_setter(self, color):
        def setter():
            self.brushColor = color

        return setter

    def init_states(self):
        self.brushSize = 2  # default brush size
        self.brushColor = Qt.black  # default color
        self.lastPoint = QPoint()
        self.is_drawing = False  # drawing flag
        self.history = []

    def render(self):
        self.image = QImage(self.size(), QImage.Format_RGB32)
        self.image.fill(Qt.white)

    # --- events
    
    def resizeEvent(self, e: QResizeEvent):
        self.render()

    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.is_drawing = True
            self.lastPoint = event.pos()

    def mouseMoveEvent(self, event):
        if (event.buttons() & Qt.LeftButton) & self.is_drawing:
            painter = QPainter(self.image)  # creating painter object

            # set the pen of the painter
            painter.setPen(QPen(self.brushColor, self.brushSize,
                                Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin))

            # draw line from the last point of cursor to the current point
            # this will draw only one step
            painter.drawLine(self.lastPoint, event.pos())
            self.lastPoint = event.pos()
            self.update()

    def mouseReleaseEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.is_drawing = False

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

if __name__ == "__main__":
    App = QApplication(sys.argv)
    window = Window()
    window.show()
    sys.exit(App.exec())
