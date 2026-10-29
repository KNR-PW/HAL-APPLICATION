# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause
from __future__ import annotations

import signal
import sys

from PySide6.QtCore import QTimer
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from hal062_application import inputs

# To be used on the @QmlElement decorator
QML_IMPORT_NAME = "io.qt.textproperties"
QML_IMPORT_MAJOR_VERSION = 1

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    input_manager = inputs.InputManager()
    kb_filter = inputs.GlobalKeyboardFilter(input_manager)
    app.installEventFilter(kb_filter)

    gamepad_thread = inputs.GamepadWorker()
    gamepad_thread.button_pressed.connect(input_manager.handle_gamepad_button)
    gamepad_thread.axis_moved.connect(input_manager.handle_gamepad_axis)
    gamepad_thread.start()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("inputManager", input_manager)
    # Add the current directory to the import paths and load the main module.
    engine.addImportPath(sys.path[-1])
    engine.loadFromModule("Static", "Main")

    # Make python read signals every 500ms so ctrl+C will work
    signal.signal(signal.SIGINT, lambda sig, frame: app.quit())
    timer = QTimer()
    timer.start(500)
    timer.timeout.connect(lambda: None)

    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    del engine
    sys.exit(exit_code)
