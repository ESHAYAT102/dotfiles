#!/usr/bin/env python3
# @vicinae.schemaVersion 1
# @vicinae.title Confetti
# @vicinae.mode silent
# @vicinae.icon 🎉
# @vicinae.keywords ["celebrate", "celebration", "party"]
# @vicinae.description Fire confetti across every screen

import math
import os
import random
import sys
import tempfile
import time

import cairo
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell

COLORS = ("#ff4f64", "#ff8a00", "#ffd60a", "#ff5db1",
          "#9b6dff", "#5b8cff", "#31c5f4", "#72d572")
windows = []


def make_particles(width, height, count=320):
    particles = []
    for _ in range(count):
        left = random.random() < 0.5
        angle = random.uniform(math.radians(270 if left else 180),
                               math.radians(360 if left else 270))
        speed = random.uniform(height * 0.68, height * 1.4)
        color = Gdk.RGBA()
        color.parse(random.choice(COLORS))
        particles.append([
            0 if left else width, height,
            math.cos(angle) * speed, math.sin(angle) * speed,
            random.uniform(8, 16), color, random.uniform(0, math.tau),
            random.uniform(0, 0.45), random.randrange(3),
        ])
    return particles


def advance(particles, dt, height):
    gravity = height * 1.25
    for particle in particles:
        if particle[7] > 0:
            particle[7] -= dt
            continue
        particle[0] += particle[2] * dt
        particle[1] += particle[3] * dt
        particle[3] += gravity * dt
        particle[6] += dt * 8


class ConfettiWindow(Gtk.Window):
    def __init__(self, monitor):
        super().__init__()
        geometry = monitor.get_geometry()
        self.set_app_paintable(True)
        self.set_visual(self.get_screen().get_rgba_visual())
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_monitor(self, monitor)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.NONE)
        GtkLayerShell.set_exclusive_zone(self, -1)
        for edge in (GtkLayerShell.Edge.TOP, GtkLayerShell.Edge.RIGHT,
                     GtkLayerShell.Edge.BOTTOM, GtkLayerShell.Edge.LEFT):
            GtkLayerShell.set_anchor(self, edge, True)

        self.width, self.height = geometry.width, geometry.height
        self.running = False
        self.area = Gtk.DrawingArea()
        self.area.connect("draw", self.draw)
        self.add(self.area)

    def fire(self):
        if not self.running:
            self.particles = []
            self.previous = time.monotonic()
        self.particles.extend(make_particles(self.width, self.height))
        self.show_all()
        self.input_shape_combine_region(cairo.Region())
        if not self.running:
            self.running = True
            GLib.timeout_add(16, self.tick, self.area, self.height)

    def tick(self, area, height):
        now = time.monotonic()
        advance(self.particles, min(now - self.previous, 0.05), height)
        self.previous = now
        self.particles[:] = [p for p in self.particles
                             if p[7] > 0 or p[1] <= height + p[4]]
        area.queue_draw()
        if self.particles:
            return GLib.SOURCE_CONTINUE
        self.running = False
        self.hide()
        return GLib.SOURCE_REMOVE

    def draw(self, _area, cr):
        cr.set_operator(1)  # cairo.OPERATOR_SOURCE
        cr.set_source_rgba(0, 0, 0, 0)
        cr.paint()
        cr.set_operator(2)  # cairo.OPERATOR_OVER
        for x, y, _vx, _vy, size, color, rotation, delay, shape in self.particles:
            if delay > 0:
                continue
            cr.save()
            cr.translate(x, y)
            cr.rotate(rotation)
            cr.set_source_rgba(color.red, color.green, color.blue, 0.95)
            if shape == 0:
                cr.rectangle(-size / 2, -size / 4, size, size / 2)
            elif shape == 1:
                cr.arc(0, 0, size / 3, 0, math.tau)
            else:
                cr.move_to(0, -size / 2)
                cr.line_to(size / 2, size / 2)
                cr.line_to(-size / 2, size / 2)
                cr.close_path()
            cr.fill()
            cr.restore()


def self_test():
    particle = [[0, 0, 10, -10, 5, "#fff", 0, 0]]
    advance(particle, 0.5, 100)
    assert particle[0][:4] == [5, -5, 10, 52.5]
    assert all(p[8] in range(3) for p in make_particles(100, 100, 20))


def launch():
    global windows
    settings = Gtk.Settings.get_default()
    if settings and not settings.get_property("gtk-enable-animations"):
        return
    if not windows:
        display = Gdk.Display.get_default()
        windows = [ConfettiWindow(display.get_monitor(i))
                   for i in range(display.get_n_monitors())]
    for window in windows:
        window.fire()


def relaunch(fd, _condition):
    os.read(fd, 4096)
    launch()
    return True


if __name__ == "__main__":
    if "--self-test" in sys.argv:
        self_test()
        raise SystemExit
    fifo = os.path.join(os.environ.get("XDG_RUNTIME_DIR", tempfile.gettempdir()),
                        f"vicinae-confetti-{os.getuid()}")
    try:
        os.mkfifo(fifo, 0o600)
    except FileExistsError:
        pass
    fifo_fd = os.open(fifo, os.O_RDWR | os.O_NONBLOCK)
    GLib.io_add_watch(fifo_fd, GLib.IO_IN, relaunch)
    launch()
    Gtk.main()
