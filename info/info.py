#!/usr/bin/python3

import i3ipc
import threading
import subprocess
from collections import defaultdict
from queue import Queue

from visual import PanelVisual
from raster import Raster
from panel import PanelStrip, Panel

class WindowManager:
    def __init__(self):
        self._i3 = None

    @property
    def i3(self):
        if not self._i3:
            self._i3 = i3ipc.Connection()
        return self._i3

    def loop(self, events):
        def workspace_event(connection, event):
            self.refresh_workspaces(events)
        self.i3.on('workspace::focus', workspace_event)

        def window_event(connection, event):
            self.set_window(events, event.container)
        self.i3.on('window', window_event)

        def mode_event(connection, event):
            self.set_mode(events, event.change)
        self.i3.on('mode', mode_event)

        self.set_mode(events, 'default')
        self.refresh_workspaces(events)
        self.i3.main()

    def refresh_workspaces(self, events):
        info = PanelStrip('workspaces')
        for workspace in self.i3.get_workspaces():
            colour, background = None, None
            if workspace.visible:
                colour = PanelVisual.semiactive
            if workspace.focused:
                colour = PanelVisual.active
            if workspace.urgent:
                background = PanelVisual.urgent
            info.text(workspace.name, colour, background).text(' ')

        events.put(PanelStrip('current_window').text(':)'))
        events.put(info)

    def set_window(self, events, window_container):
        if window_container.urgent:
            self.refresh_workspaces(events)
        if window_container.focused:
            events.put(PanelStrip('current_window').text(window_container.name))

    def set_mode(self, events, mode):
        if mode == 'default':
            events.put(PanelStrip('mode'))
        else:
            events.put(PanelStrip('mode').text(
                mode, background=PanelVisual.urgent
            ))


class EventLoop:
    def __init__(self):
        self.window_manager = WindowManager()
        self.events = Queue()
        self.panel = Panel()

    def start_thread(self, loop):
        thread = threading.Thread(
            target=loop,
            kwargs={'events': self.events}
        )
        thread.daemon = True
        thread.start()
        return thread

    def process_event(self, event):
        if isinstance(event, PanelStrip):
            self.panel.update(event)

    def loop(self):
        self.window_manager_thread = self.start_thread(
            self.window_manager.loop
        )

        self.panel.start()

        while True:
            self.process_event(self.events.get())

if __name__ == '__main__':
    EventLoop().loop()
