import os

os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "hide"
import pygame
from PySide6.QtCore import QEvent, QObject, QThread, Signal, Slot


class GlobalKeyboardFilter(QObject):
    """Intercepts key presses application-wide, regardless of which window has focus."""

    def __init__(self, input_manager):
        super().__init__()
        self.input_manager = input_manager

    def eventFilter(self, watched, event):
        if event.type() == QEvent.Type.KeyPress and not event.isAutoRepeat():
            key_name = event.text().upper() or f"Key_{event.key()}"
            self.input_manager.handle_key_press(key_name)
            return True

        elif event.type() == QEvent.Type.KeyRelease and not event.isAutoRepeat():
            key_name = event.text().upper() or f"Key_{event.key()}"
            self.input_manager.handle_key_release(key_name)
            return True

        # Allow standard Qt event propagation to continue
        return super().eventFilter(watched, event)


class InputManager(QObject):
    # Emits abstract actions, not raw keys/buttons
    # Examples: ("jump", True), ("move_x", 0.75)
    actionSignal = Signal(str, bool)
    gamepadSignal = Signal(str, float)

    def __init__(self):
        super().__init__()

        # 1. Define Action Mappings
        self.KEY_MAP = {
            "W": "move_up",
            "S": "move_down",
            "SPACE": "jump",
            "RETURN": "select",
        }

        self.GAMEPAD_BUTTON_MAP = {
            0: "jump",  # e.g., 'A' button
            1: "select",  # e.g., 'B' button
        }

    # --- RAW INPUT RECEIVERS ---
    @Slot(str)
    def handle_key_press(self, key_name):
        action = self.KEY_MAP.get(key_name.upper())
        if action:
            self.actionSignal.emit(action, True)

    @Slot(str)
    def handle_key_release(self, key_name):
        action = self.KEY_MAP.get(key_name.upper())
        if action:
            self.actionSignal.emit(action, False)

    @Slot(int)
    def handle_gamepad_button(self, button_id):
        action = self.GAMEPAD_BUTTON_MAP.get(button_id)
        if action:
            self.actionSignal.emit(action, True)

    @Slot(int, float)
    def handle_gamepad_axis(self, axis_id, value):
        # Left Stick X-axis
        if axis_id == 0:
            if abs(value) > 0.15:  # Deadzone check
                self.gamepadSignal.emit("move_x", value)
            else:
                self.gamepadSignal.emit("move_x", 0.0)


class GamepadWorker(QThread):
    button_pressed = Signal(int)
    axis_moved = Signal(int, float)

    def __init__(self):
        super().__init__()
        self._running = True

    def run(self):
        pygame.init()
        pygame.joystick.init()
        joystick = None

        if pygame.joystick.get_count() > 0:
            joystick = pygame.joystick.Joystick(0)
            joystick.init()

        clock = pygame.time.Clock()
        while self._running:
            for event in pygame.event.get():
                if event.type == pygame.JOYDEVICEADDED and joystick is None:
                    joystick = pygame.joystick.Joystick(event.device_index)
                    joystick.init()
                elif event.type == pygame.JOYBUTTONDOWN:
                    self.button_pressed.emit(event.button)
                elif event.type == pygame.JOYAXISMOTION:
                    self.axis_moved.emit(event.axis, event.value)
            clock.tick(60)

    def stop(self):
        self._running = False
        self.wait()
