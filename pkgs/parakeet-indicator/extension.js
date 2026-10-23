// SPDX-License-Identifier: MIT
//
// Floating dictation pill for parakeet-typing.
//
// The engine exposes a tiny session-bus API:
//   org.denis.ParakeetTyping  /org/denis/ParakeetTyping
//     methods: GetState, GetLevel, Confirm, Cancel, Toggle
//     signals: StateChanged(s), LevelChanged(d)
//
// While the engine is loading/listening we show a bottom-centre pill with a
// live waveform (bar history built from the RMS level the engine sends).
// Click = confirm/commit, right click = cancel.

import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import Meta from 'gi://Meta';
import St from 'gi://St';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const DBUS_NAME = 'org.denis.ParakeetTyping';
const DBUS_PATH = '/org/denis/ParakeetTyping';
const DBUS_IFACE = 'org.denis.ParakeetTyping';

const PILL_WIDTH = 208;
const PILL_HEIGHT = 58;
const BARS = 34;
const BAR_WIDTH = 3;
const BAR_GAP = 2.8;
const TICK_MS = 33;

const VISIBLE_STATES = new Set(['loading', 'listening', 'stopping']);

function callRemote(method, onResult = null) {
    Gio.DBus.session.call(
        DBUS_NAME,
        DBUS_PATH,
        DBUS_IFACE,
        method,
        null,
        null,
        Gio.DBusCallFlags.NONE,
        1500,
        null,
        (connection, result) => {
            try {
                const reply = connection.call_finish(result);
                if (onResult)
                    onResult(reply);
            } catch (error) {
                if (onResult)
                    onResult(null);
            }
        }
    );
}

function roundedRect(cr, x, y, width, height, radius) {
    const r = Math.min(radius, width / 2, height / 2);
    cr.newSubPath();
    cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI);
    cr.arc(x + width - r, y + r, r, 1.5 * Math.PI, 0);
    cr.arc(x + width - r, y + height - r, r, 0, 0.5 * Math.PI);
    cr.arc(x + r, y + height - r, r, 0.5 * Math.PI, Math.PI);
    cr.closePath();
}

const ParakeetPill = GObject.registerClass(
class ParakeetPill extends St.Widget {
    _init() {
        super._init({
            style_class: 'parakeet-pill',
            reactive: true,
            track_hover: true,
            can_focus: false,
            layout_manager: new Clutter.BinLayout(),
        });

        this._state = 'idle';
        this._levels = new Array(BARS).fill(0);
        this._target = 0;
        this._display = 0;
        this._phase = 0;
        this._tickId = 0;

        this._area = new St.DrawingArea({
            style_class: 'parakeet-wave',
            x_expand: true,
            y_expand: true,
        });
        this._area.connect('repaint', () => this._draw());
        this.add_child(this._area);

        this.set_size(PILL_WIDTH, PILL_HEIGHT);
        this.hide();

        this._tickId = GLib.timeout_add(
            GLib.PRIORITY_DEFAULT,
            TICK_MS,
            () => this._tick()
        );

        this.connect('button-press-event', (actor, event) => {
            const button = event.get_button();
            if (button === 1)
                callRemote('Confirm');
            else if (button === 3)
                callRemote('Cancel');
            return Clutter.EVENT_STOP;
        });

        this.connect('enter-event', () => {
            global.display.set_cursor(Meta.Cursor.POINTING_HAND);
            return Clutter.EVENT_PROPAGATE;
        });
        this.connect('leave-event', () => {
            global.display.set_cursor(Meta.Cursor.DEFAULT);
            return Clutter.EVENT_PROPAGATE;
        });

        this.connect('destroy', () => {
            if (this._tickId) {
                GLib.source_remove(this._tickId);
                this._tickId = 0;
            }
        });
    }

    setState(state) {
        if (this._state === state && this.visible === VISIBLE_STATES.has(state))
            return;
        this._state = state;
        if (VISIBLE_STATES.has(state)) {
            if (!this.visible) {
                this.opacity = 0;
                this.show();
                this.ease({
                    opacity: 255,
                    duration: 140,
                    mode: Clutter.AnimationMode.EASE_OUT_QUAD,
                });
            }
            this.reposition();
        } else {
            this.hide();
            global.display.set_cursor(Meta.Cursor.DEFAULT);
        }
    }

    setLevel(level) {
        if (typeof level !== 'number' || !Number.isFinite(level))
            return;
        this._target = Math.min(1, Math.max(0, level));
    }

    reposition() {
        const monitor = Main.layoutManager.primaryMonitor;
        if (!monitor)
            return;
        const [width, height] = this.get_size();
        const x = Math.round(monitor.x + (monitor.width - width) / 2);
        const y = Math.round(monitor.y + monitor.height - height - 92);
        this.set_position(x, y);
    }

    _tick() {
        if (!this.visible)
            return GLib.SOURCE_CONTINUE;

        this._display += (this._target - this._display) * 0.45;

        if (this._state === 'loading') {
            // No audio levels yet (the recognizer is loading); draw a soft
            // travelling wave so the pill does not look frozen.
            this._phase += 0.22;
            for (let i = 0; i < BARS; i++) {
                const wave = 0.12 + 0.10 * Math.sin(this._phase + i * 0.55);
                this._levels[i] = wave;
            }
        } else {
            this._levels.shift();
            this._levels.push(this._display);
        }

        this._area.queue_repaint();
        return GLib.SOURCE_CONTINUE;
    }

    _draw() {
        const area = this._area;
        const [width, height] = area.get_surface_size();
        if (width <= 0 || height <= 0)
            return;

        const cr = area.get_context();
        const total = BARS * BAR_WIDTH + (BARS - 1) * BAR_GAP;
        let x = (width - total) / 2;
        const centerY = height / 2;
        const maxBar = height - 16;

        cr.setSourceRGBA(1, 1, 1, 0.96);
        for (let i = 0; i < BARS; i++) {
            const level = Math.min(1, Math.max(0, this._levels[i]));
            const barHeight = Math.max(3, 3 + level * maxBar);
            const y = centerY - barHeight / 2;
            roundedRect(cr, x, y, BAR_WIDTH, barHeight, BAR_WIDTH / 2);
            x += BAR_WIDTH + BAR_GAP;
        }
        cr.fill();
        cr.$dispose();
    }
});

export default class ParakeetIndicatorExtension extends Extension {
    enable() {
        this._pill = new ParakeetPill();
        Main.layoutManager.addChrome(this._pill);

        this._signalId = Gio.DBus.session.signal_subscribe(
            DBUS_NAME,
            DBUS_IFACE,
            null,
            DBUS_PATH,
            null,
            Gio.DBusSignalFlags.NONE,
            (connection, sender, path, iface, signal, params) =>
                this._onSignal(signal, params)
        );

        this._watchId = Gio.bus_watch_name(
            Gio.BusType.SESSION,
            DBUS_NAME,
            Gio.BusNameWatcherFlags.NONE,
            () => this._sync(),
            () => this._pill?.setState('idle')
        );

        this._monitorsId = Main.layoutManager.connect('monitors-changed', () => {
            this._pill?.reposition();
        });

        this._sync();
        this._pill.setState('idle');
    }

    disable() {
        if (this._signalId) {
            Gio.DBus.session.signal_unsubscribe(this._signalId);
            this._signalId = 0;
        }
        if (this._watchId) {
            Gio.bus_unwatch_name(this._watchId);
            this._watchId = 0;
        }
        if (this._monitorsId) {
            Main.layoutManager.disconnect(this._monitorsId);
            this._monitorsId = 0;
        }
        if (this._pill) {
            Main.layoutManager.removeChrome(this._pill);
            this._pill.destroy();
            this._pill = null;
        }
        global.display.set_cursor(Meta.Cursor.DEFAULT);
    }

    _sync() {
        callRemote('GetState', (reply) => {
            if (!reply) {
                this._pill?.setState('idle');
                return;
            }
            const [state] = reply.deep_unpack();
            this._pill?.setState(state);
        });
        callRemote('GetLevel', (reply) => {
            if (!reply)
                return;
            const [level] = reply.deep_unpack();
            this._pill?.setLevel(level);
        });
    }

    _onSignal(signal, params) {
        if (signal === 'StateChanged') {
            const [state] = params.deep_unpack();
            this._pill?.setState(state);
        } else if (signal === 'LevelChanged') {
            const [level] = params.deep_unpack();
            this._pill?.setLevel(level);
        }
    }
}
