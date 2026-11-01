#!/usr/bin/env python3
"""Quartus Block Diagram File (.bdf) -> PNG renderer.
Usage: bdf2png.py in.bdf out.png
"""
import sys, re, math
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import Arc, Circle, Rectangle
from matplotlib import font_manager

# ---------- S-expression parser ----------
TOK = re.compile(r'\s*(?:(\()|(\))|("(?:[^"\\]|\\.)*")|([^\s()"]+))', re.S)

def parse(text):
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    text = re.sub(r'^\s*//.*$', '', text, flags=re.M)
    stack = [[]]
    for m in TOK.finditer(text):
        lp, rp, s, a = m.groups()
        if lp:
            stack.append([])
        elif rp:
            if len(stack) > 1:
                x = stack.pop(); stack[-1].append(x)
        elif s is not None:
            stack[-1].append(('S', s[1:-1].replace('\\"', '"')))
        elif a is not None:
            try:
                stack[-1].append(int(a))
            except ValueError:
                try: stack[-1].append(float(a))
                except ValueError: stack[-1].append(a)
    return stack[0]

def head(n): return n[0] if isinstance(n, list) and n and isinstance(n[0], str) else None
def kids(n, name): return [c for c in n[1:] if isinstance(c, list) and head(c) == name]
def kid(n, name):
    k = kids(n, name); return k[0] if k else None
def flags(n): return {head(c) for c in n[1:] if isinstance(c, list) and len(c) == 1 and head(c)}
def pt(n): return (n[1], n[2])
def rect(n): return tuple(n[1:5])

# ---------- transforms ----------
def make_tf(ox, oy, w, h, ops):
    """ops: list like ['flipy','rotate90'] applied in order in local coords; w,h = unrotated size."""
    def f(x, y):
        cw, ch = w, h
        for op in ops:
            if op == 'flipx': x = cw - x
            elif op == 'flipy': y = ch - y
            elif op == 'rotate180': x, y = cw - x, ch - y
            elif op == 'rotate90': x, y = y, cw - x; cw, ch = ch, cw
            elif op == 'rotate270': x, y = ch - y, x; cw, ch = ch, cw
        return ox + x, oy + y
    mirror = sum(op in ('flipx', 'flipy') for op in ops) % 2 == 1
    rot = sum({'rotate90': 90, 'rotate180': 180, 'rotate270': 270}.get(op, 0) for op in ops) % 360
    return f, mirror, rot

TF_NAMES = {'flipx', 'flipy', 'rotate90', 'rotate180', 'rotate270'}
def element_ops(n):
    for fl in flags(n):
        parts = fl.split('_')
        if all(p in TF_NAMES for p in parts):
            return parts
    return []

# ---------- drawing ----------
WIRE = '#800080'; SYM = '#000000'; PORT = '#0000A0'; PINNAME = '#0000A0'; SMALL = '#800080'
HANGUL = re.compile('[가-힣]')
KFONT = None
for f in font_manager.findSystemFonts():
    if re.search(r'(Nanum|NotoSansCJK|NotoSansKR|NotoSerifCJK|Malgun|UnDotum|Baekmuk)', f, re.I):
        KFONT = font_manager.FontProperties(fname=f); break

class R:
    def __init__(self, ax): self.ax = ax; self.xs = []; self.ys = []
    def bb(self, x, y): self.xs.append(x); self.ys.append(y)
    def line(self, p, q, color, lw=1.0):
        self.ax.plot([p[0], q[0]], [p[1], q[1]], color=color, lw=lw, solid_capstyle='butt')
        self.bb(*p); self.bb(*q)
    def text(self, s, x1, y1, x2, y2, size, color, bold=False, vertical=False, family='sans-serif'):
        if not s.strip(): return
        kw = dict(fontsize=size*0.9, color=color, fontweight='bold' if bold else 'normal', family=family)
        if KFONT is not None and HANGUL.search(s):
            kw.pop('family'); kw['fontproperties'] = KFONT.copy(); kw['fontproperties'].set_size(size*0.9)
            kw.pop('fontsize'); kw.pop('fontweight')
        if vertical:
            self.ax.text(x1, y2, s, rotation=90, ha='left', va='bottom', **kw)
        else:
            self.ax.text(x1, (y1 + y2) / 2, s, ha='left', va='center', **kw)
        self.bb(x1, y1); self.bb(x2, y2)

def font_of(t):
    f = kid(t, 'font'); size = 8; bold = False; fam = 'sans-serif'
    if f:
        fs = kid(f, 'font_size')
        if fs: size = fs[1]
        bold = 'bold' in flags(f)
        if any(isinstance(x, tuple) and 'Courier' in x[1] for x in f[1:]): fam = 'monospace'
    return size, bold, fam

def draw_text(r, t, tf, color, rot=0, force_upright=True):
    if 'invisible' in flags(t): return
    s = t[1][1] if len(t) > 1 and isinstance(t[1], tuple) else ''
    rc = kid(t, 'rect')
    if not rc: return
    x1, y1, x2, y2 = rect(rc)
    a = tf(x1, y1); b = tf(x2, y2)
    X1, X2 = sorted([a[0], b[0]]); Y1, Y2 = sorted([a[1], b[1]])
    size, bold, fam = font_of(t)
    vertical = 'vertical' in flags(t)
    if rot in (90, 270): vertical = not vertical
    r.text(s, X1, Y1, X2, Y2, size, color, bold, vertical, fam)

def draw_drawing(r, d, tf, mirror, color):
    for c in d[1:]:
        if not isinstance(c, list): continue
        h = head(c)
        lw = 1.0
        lwn = kid(c, 'line_width')
        if lwn: lw = max(1.0, lwn[1] * 0.9)
        if h == 'line':
            ps = kids(c, 'pt')
            r.line(tf(*pt(ps[0])), tf(*pt(ps[1])), color, lw)
        elif h == 'rectangle':
            x1, y1, x2, y2 = rect(kid(c, 'rect'))
            cs = [tf(x1, y1), tf(x2, y1), tf(x2, y2), tf(x1, y2)]
            for i in range(4): r.line(cs[i], cs[(i + 1) % 4], color, lw)
        elif h == 'circle':
            x1, y1, x2, y2 = rect(kid(c, 'rect'))
            a = tf(x1, y1); b = tf(x2, y2)
            cx, cy = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2; rad = abs(x2 - x1) / 2
            r.ax.add_patch(Circle((cx, cy), rad, fill=False, ec=color, lw=lw)); r.bb(cx - rad, cy - rad); r.bb(cx + rad, cy + rad)
        elif h == 'arc':
            ps = kids(c, 'pt'); x1, y1, x2, y2 = rect(kid(c, 'rect'))
            p0, p1 = tf(*pt(ps[0])), tf(*pt(ps[1]))
            a, b = tf(x1, y1), tf(x2, y2)
            cx, cy = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
            w, hh = abs(b[0] - a[0]), abs(b[1] - a[1])
            # angles in y-up sense (axis is inverted so draw with screen angles)
            ang = lambda p: math.degrees(math.atan2(-(p[1] - cy) * (w / hh if hh else 1), p[0] - cx))
            s0, s1 = ang(p0), ang(p1)
            if mirror: s0, s1 = s1, s0
            # matplotlib on inverted y: angles measured clockwise visually -> negate
            r.ax.add_patch(Arc((cx, cy), w, hh, theta1=-s1, theta2=-s0, ec=color, lw=lw))
            r.bb(*p0); r.bb(*p1)

def render(path, out, max_px=4200):
    tree = parse(open(path, encoding='latin-1').read())
    fig = plt.figure(); ax = fig.add_axes([0, 0, 1, 1]); ax.set_axis_off()
    r = R(ax)
    for n in tree:
        h = head(n)
        if h in ('symbol', 'pin'):
            x1, y1, x2, y2 = rect(kid(n, 'rect'))
            ops = []  # bdf stores already-transformed coordinates
            W, H = x2 - x1, y2 - y1
            rotq = sum({'rotate90': 1, 'rotate270': 1}.get(o, 0) for o in ops) % 2
            w, hh = (H, W) if rotq else (W, H)
            tf, mirror, rot = make_tf(x1, y1, w, hh, ops)
            texts = kids(n, 'text')
            for i, t in enumerate(texts):
                if h == 'pin':
                    s = t[1][1] if len(t) > 1 and isinstance(t[1], tuple) else ''
                    col = SMALL if s in ('INPUT', 'OUTPUT', 'BIDIR', 'VCC', 'GND') and font_of(t)[0] <= 6 else PINNAME
                else:
                    col = SYM
                draw_text(r, t, tf, col, rot)
            for p in kids(n, 'port'):
                pts = [c for c in p[1:] if isinstance(c, list) and head(c) == 'pt']
                ts = kids(p, 'text')
                if ts: draw_text(r, ts[-1], tf, PORT, rot)
                for ln in kids(p, 'line'):
                    ps = kids(ln, 'pt')
                    lwn = kid(ln, 'line_width'); lw = 2.4 if (lwn and lwn[1] >= 3) else 1.0
                    r.line(tf(*pt(ps[0])), tf(*pt(ps[1])), SYM, lw)
            d = kid(n, 'drawing')
            if d: draw_drawing(r, d, tf, mirror, SYM)
        elif h == 'connector':
            ps = kids(n, 'pt')
            bus = 'bus' in flags(n)
            if len(ps) >= 2:
                r.line(pt(ps[0]), pt(ps[1]), WIRE, 2.4 if bus else 1.0)
            for t in kids(n, 'text'):
                draw_text(r, t, lambda x, y: (x, y), WIRE)
        elif h == 'junction':
            x, y = pt(kid(n, 'pt'))
            r.ax.add_patch(Circle((x, y), 2.6, color=WIRE, zorder=5)); r.bb(x, y)
        elif h == 'text':
            draw_text(r, n, lambda x, y: (x, y), SYM)
    if not r.xs:
        plt.close(fig); return False
    m = 24
    X1, X2 = min(r.xs) - m, max(r.xs) + m; Y1, Y2 = min(r.ys) - m, max(r.ys) + m
    W, H = X2 - X1, Y2 - Y1
    ax.set_xlim(X1, X2); ax.set_ylim(Y2, Y1); ax.set_aspect('equal')
    fig.set_size_inches(W / 96, H / 96)
    dpi = min(200, max_px * 96 / max(W, H))
    fig.patch.set_facecolor('white')
    fig.savefig(out, dpi=dpi, facecolor='white')
    plt.close(fig)
    return True

if __name__ == '__main__':
    print(render(sys.argv[1], sys.argv[2]))
