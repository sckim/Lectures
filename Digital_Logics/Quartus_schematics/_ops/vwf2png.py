#!/usr/bin/env python3
"""Quartus simulation result (.sim.vwf) -> waveform PNG.
Usage: vwf2png.py in.sim.vwf out.png
Single-bit signals only; display order follows the DISPLAY_LINE entries.
"""
import sys, re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def block(text, start):
    """Return the {...} body that follows position start."""
    i = text.index('{', start); depth = 0
    for j in range(i, len(text)):
        if text[j] == '{': depth += 1
        elif text[j] == '}':
            depth -= 1
            if depth == 0: return text[i + 1:j]
    raise ValueError('unbalanced braces')

def expand(body):
    """Flatten NODE { REPEAT = n; ... } nesting into [(level, duration), ...]."""
    out, pos = [], 0
    tok = re.compile(r'NODE\s*\{|LEVEL\s+(\S+)\s+FOR\s+([\d.]+)\s*;|REPEAT\s*=\s*(\d+)\s*;|\}')
    def walk():
        nonlocal pos
        seq, rep = [], 1
        while pos < len(body):
            m = tok.search(body, pos)
            if not m: pos = len(body); break
            pos = m.end()
            s = m.group(0)
            if s.startswith('NODE'): seq += walk()
            elif s == '}': return seq * rep
            elif m.group(3): rep = int(m.group(3))
            else: seq.append((m.group(1), float(m.group(2))))
        return seq * rep
    return walk()

def load(path):
    text = open(path, encoding='utf-8', errors='replace').read()
    text = re.sub(r'/\*.*?\*/', '', text, flags=re.S)
    dirs = {}
    for m in re.finditer(r'SIGNAL\("([^"]+)"\)', text):
        b = block(text, m.end())
        if 'SINGLE_BIT' in b:
            d = re.search(r'DIRECTION\s*=\s*(\w+)', b)
            dirs[m.group(1)] = d.group(1) if d else 'INPUT'
    waves = {}
    for m in re.finditer(r'TRANSITION_LIST\("([^"]+)"\)', text):
        if m.group(1) in dirs: waves[m.group(1)] = expand(block(text, m.end()))
    order = []
    for m in re.finditer(r'DISPLAY_LINE', text):
        c = re.search(r'CHANNEL\s*=\s*"([^"]+)"', block(text, m.end()))
        if c and c.group(1) in waves and c.group(1) not in order: order.append(c.group(1))
    order += [s for s in waves if s not in order]
    return [(s, dirs[s], waves[s]) for s in order]

def render(path, out):
    sigs = load(path)
    end = max(sum(d for _, d in w) for _, _, w in sigs)
    scale, unit = (1e-3, 'µs') if end >= 2000 else (1.0, 'ns')
    fig, ax = plt.subplots(figsize=(12, 0.55 * len(sigs) + 0.9), dpi=150)
    for row, (name, direction, wave) in enumerate(sigs):
        y0 = (len(sigs) - 1 - row) * 1.4
        color = '#1f5fa8' if direction == 'INPUT' else '#c0392b'
        # faint 0/1 guides so a constant signal still reads as its own row
        ax.hlines([y0, y0 + 0.9], 0, end * scale, color='#e6e6e6', lw=0.8, zorder=0)
        t = 0.0; xs, ys = [], []
        for lvl, dur in wave:
            t1 = t + dur
            if lvl in ('0', '1'):
                v = y0 + (0.9 if lvl == '1' else 0.0)
                xs += [t * scale, t1 * scale]; ys += [v, v]
            else:  # X / U / Z: hatched band
                ax.fill_between([t * scale, t1 * scale], y0, y0 + 0.9, color='#999999', alpha=0.35, lw=0)
                ax.text((t + t1) / 2 * scale, y0 + 0.45, lvl, ha='center', va='center', fontsize=7, color='#555555')
                xs.append(float('nan')); ys.append(float('nan'))
            t = t1
        ax.plot(xs, ys, color=color, lw=1.4, drawstyle='default')
        ax.text(-0.01, y0 + 0.45, name, transform=ax.get_yaxis_transform(), ha='right', va='center',
                fontsize=10, color=color, family='monospace')
    ax.set_xlim(0, end * scale)
    ax.set_ylim(-0.4, (len(sigs) - 1) * 1.4 + 1.3)
    ax.set_yticks([])
    ax.set_xlabel(f'time ({unit})')
    ax.grid(axis='x', color='#dddddd', lw=0.6)
    for s in ('left', 'right', 'top'): ax.spines[s].set_visible(False)
    fig.tight_layout()
    fig.savefig(out, facecolor='white')
    plt.close(fig)
    return f'{out}: {len(sigs)} signals, {end * scale:g} {unit}'

if __name__ == '__main__':
    print(render(sys.argv[1], sys.argv[2]))
