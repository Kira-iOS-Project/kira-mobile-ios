"""Builds App/Assets.xcassets from the Kira design system artifact (docs/design-system.md).

Reads, as data and never executed: the artifact's project/tokens.json (colour tokens, light and
dark) and the artwork tables of project/components/bundle.js (ILLUSTRATIONS, CATEGORIES, LEAF_ART,
SCENES, ARROWS, the logo paths and Kuku's parts). A small parser reads only JS literals: arrays,
objects, strings, numbers, the constants those tables name, `.concat(...)`, and the three part
builders bg/dot/leafAt, re-implemented here as bundle.js defines them. Each paint becomes the hex
of its ilu-* or hero-* token, once per theme, so every image set has a light and a dark SVG.

The artifact names things in Indonesian, as designers and tickets do; the catalog uses English names
(AGENTS.md Rule 35). The tables below translate each artifact name, and a name missing from them
stops the build, so a new token or drawing gets its English name before it reaches the app.
docs/design-system.md lists the same pairs.

Download the two files and the app icon (asset 71b17ca1ba371f63f5e8b48a782beea7) from the artifact,
then, from the repo root (it replaces the whole catalog):

    python3 -I scripts/generate/design-assets.py bundle.js tokens.json kira-ikon-1024.png \
        App/Assets.xcassets
"""
import json
import math
import re
import shutil
import sys
from pathlib import Path

BUNDLE, TOKENS, ICON, OUT = (Path(p) for p in sys.argv[1:5])
SRC = BUNDLE.read_text(encoding="utf-8")
TOK = json.loads(TOKENS.read_text(encoding="utf-8"))
COLORS = {t["name"]: t["value"] for t in TOK["color"]["tokens"]}


# ---------- a parser for the JS literal subset the artwork tables use ----------
class Parser:
    def __init__(self, text, pos, env):
        self.t, self.i, self.env = text, pos, env

    def ws(self):
        while True:
            while self.i < len(self.t) and self.t[self.i] in " \t\r\n":
                self.i += 1
            if self.t.startswith("/*", self.i):
                self.i = self.t.index("*/", self.i) + 2
            elif self.t.startswith("//", self.i):
                self.i = self.t.index("\n", self.i)
            else:
                return

    def peek(self):
        self.ws()
        return self.t[self.i]

    def eat(self, ch):
        self.ws()
        assert self.t[self.i] == ch, f"expected {ch!r} at {self.i}: {self.t[self.i:self.i + 40]!r}"
        self.i += 1

    def expr(self):
        value = self.primary()
        while self.peek() == ".":
            self.i += 1
            name = self.ident()
            assert name == "concat", name
            args = self.args()
            for a in args:
                value = value + a
        return value

    def args(self):
        self.eat("(")
        out = []
        while self.peek() != ")":
            out.append(self.expr())
            if self.peek() == ",":
                self.i += 1
        self.eat(")")
        return out

    def ident(self):
        self.ws()
        m = re.compile(r"[A-Za-z_$][\w$]*").match(self.t, self.i)
        assert m, self.t[self.i:self.i + 40]
        self.i = m.end()
        return m.group(0)

    def primary(self):
        ch = self.peek()
        if ch == "[":
            self.i += 1
            out = []
            while self.peek() != "]":
                out.append(self.expr())
                if self.peek() == ",":
                    self.i += 1
            self.eat("]")
            return out
        if ch == "{":
            self.i += 1
            out = {}
            while self.peek() != "}":
                key = self.string() if self.peek() == "'" else self.ident()
                self.eat(":")
                out[key] = self.expr()
                if self.peek() == ",":
                    self.i += 1
            self.eat("}")
            return out
        if ch == "'":
            return self.string()
        m = re.compile(r"-?(\d+\.?\d*|\.\d+)").match(self.t, self.i)
        if m:
            self.i = m.end()
            return float(m.group(0))
        name = self.ident()
        if self.peek() == "(":
            return BUILDERS[name](*self.args())
        return self.env[name]

    def string(self):
        self.eat("'")
        end = self.t.index("'", self.i)
        s = self.t[self.i:end]
        self.i = end + 1
        return s


def bg(tint):
    return ["circle", "f:" + tint, {"cx": 60, "cy": 60, "r": 56}]


def dot(x, y, r, tint):
    return ["circle", "f:" + tint, {"cx": x, "cy": y, "r": r}]


def leaf_at(x, y, deg, tint, s=None):
    tr = f"translate({num(x)} {num(y)}) rotate({num(deg)})" + (f" scale({num(s)})" if s else "")
    return ["path", "f:" + tint, {"d": ENV["LEAF_T"], "transform": tr}]


BUILDERS = {"bg": bg, "dot": dot, "leafAt": leaf_at}
ENV = {}


def var(name):
    m = re.search(r"\bvar\s+" + name + r"\s*=", SRC)
    assert m, name
    p = Parser(SRC, m.end(), ENV)
    ENV[name] = p.expr()
    return ENV[name]




# ---------- SVG output ----------
def num(v):
    if isinstance(v, float) and v.is_integer():
        return str(int(v))
    return str(v)


def rgba(token, theme):
    hexv = COLORS[token][theme].lstrip("#")
    alpha = int(hexv[6:8], 16) / 255 if len(hexv) == 8 else 1.0
    return "#" + hexv[:6], alpha


def paint_token(tint):
    return tint if tint.startswith("hero-") else "ilu-" + tint


ATTR = {"fillOpacity": "fill-opacity"}


def part_svg(part, theme):
    tag, paint, attrs = part
    bits = paint.split(":")
    color, alpha = rgba(paint_token(bits[1]), theme)
    out = []
    for k, v in attrs.items():
        if k == "fillOpacity":
            alpha *= v
            continue
        out.append(f'{ATTR.get(k, k)}="{num(v) if not isinstance(v, str) else v}"')
    if bits[0] == "f":
        out.append(f'fill="{color}"')
        if alpha < 1:
            out.append(f'fill-opacity="{alpha:.3f}"')
    else:
        width = float(bits[2]) if len(bits) > 2 else 2.0
        out.append(f'fill="none" stroke="{color}" stroke-width="{num(width)}" '
                   'stroke-linecap="round" stroke-linejoin="round"')
        if alpha < 1:
            out.append(f'stroke-opacity="{alpha:.3f}"')
    return f"<{tag} {' '.join(out)}/>"


def svg(view_box, size, body):
    w, h = size
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{num(w)}" height="{num(h)}" '
            f'viewBox="{view_box}">{body}</svg>\n')


def tone_parts(parts, tone):
    if tone == "alam":
        return parts
    to = "hero-alam" if tone == "hero" else "hijau-muda"
    out = []
    for tag, paint, attrs in parts:
        b = paint.split(":")
        b[1] = to
        out.append([tag, ":".join(b), attrs])
    return out


# ---------- English names for the artifact's Indonesian ones ----------
COLOR_NAMES = {
    "sehat": "healthy", "sehat-soft": "healthy-soft", "sehat-line": "healthy-line",
    "bertahan": "coping", "bertahan-soft": "coping-soft", "bertahan-line": "coping-line",
    "rentan": "vulnerable", "rentan-soft": "vulnerable-soft", "rentan-line": "vulnerable-line",
    "darurat": "emergency", "darurat-soft": "emergency-soft", "on-darurat": "on-emergency",
    "hero-alam": "hero-nature", "hero-alam-2": "hero-nature-2",
    "ilu-hijau": "art-green", "ilu-hijau-tua": "art-green-dark", "ilu-hijau-muda": "art-green-light",
    "ilu-hijau-lembut": "art-green-soft", "ilu-kunyit": "art-turmeric", "ilu-kunyit-tua": "art-turmeric-dark",
    "ilu-kunyit-muda": "art-turmeric-light", "ilu-persik": "art-peach", "ilu-persik-muda": "art-peach-light",
    "ilu-bata": "art-brick", "ilu-tanah": "art-soil", "ilu-tanah-tua": "art-soil-dark", "ilu-langit": "art-sky",
    "ilu-langit-tua": "art-sky-dark", "ilu-langit-muda": "art-sky-light", "ilu-putih": "art-white",
    "ilu-tinta": "art-ink", "ilu-kilau": "art-gleam", "ilu-bulu": "art-feather", "ilu-bulu-tua": "art-feather-dark",
    "ilu-topeng": "art-mask", "ilu-krem": "art-cream", "ilu-mata": "art-eye",
}
ENGLISH_TOKENS = {"surface", "surface-raised", "surface-muted", "button", "button-line", "track", "line",
                  "hairline", "line-strong", "ink", "ink-muted", "pandan", "pandan-strong", "pandan-soft",
                  "pandan-line", "on-pandan", "hero", "on-hero", "on-hero-muted", "hero-track", "hero-accent",
                  "glass", "scrim"}
COLOR_NAMES.update({name: name for name in ENGLISH_TOKENS})
ILLUSTRATION_NAMES = {
    "tunas": "sprout", "tumbuh": "growing", "mekar": "bloom", "celengan": "piggy-bank",
    "kartu-lunas": "card-paid-off", "peduli": "care", "struk": "receipt", "payung": "umbrella",
    "perisai": "shield", "kalender": "calendar", "tangga": "stairs", "buku": "book", "surat": "letter",
    "gembok": "padlock", "komunitas": "community",
}
CATEGORY_NAMES = {
    "makan": "food", "transportasi": "transport", "kopi": "coffee", "belanja": "shopping", "tagihan": "bills",
    "gaji": "salary", "paylater": "paylater", "tabungan": "savings", "proteksi": "protection", "rumah": "home",
    "pendidikan": "education", "kesehatan": "health", "hiburan": "entertainment", "menikah": "wedding",
    "pensiun": "retirement", "bank": "bank", "ewallet": "ewallet", "tunai": "cash", "kartu": "card",
    "pinjol": "online-loan", "emas": "gold", "saham": "stocks", "reksadana": "mutual-funds", "kripto": "crypto",
    "sbn": "government-bonds", "darurat": "emergency", "barang": "goods", "lainnya": "other",
}
EXPRESSION_NAMES = {"tenang": "calm", "senang": "happy", "bangga": "proud"}
LEAF_NAMES = {"daun": "single", "ranting": "twig", "pandan": "pandan"}
LEAF_TONES = {"alam": "nature", "lembut": "soft", "hero": "hero"}


def english(table, name):
    assert name in table, f"no English name for the artifact's {name!r}: add it to the table"
    return table[name]


# ---------- the asset catalog ----------
INFO = {"author": "xcode", "version": 1}


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def folder(name):
    d = OUT / name
    write_json(d / "Contents.json", {"info": INFO})
    return d


def image_set(group, name, light, dark=None, template=False):
    d = group / f"{name}.imageset"
    d.mkdir(parents=True, exist_ok=True)
    images = [{"filename": f"{name}.svg", "idiom": "universal"}]
    (d / f"{name}.svg").write_text(light, encoding="utf-8")
    if dark is not None and dark != light:
        images.append({"appearances": [{"appearance": "luminosity", "value": "dark"}],
                       "filename": f"{name}-dark.svg", "idiom": "universal"})
        (d / f"{name}-dark.svg").write_text(dark, encoding="utf-8")
    props = {"preserves-vector-representation": True}
    if template:
        props["template-rendering-intent"] = "template"
    write_json(d / "Contents.json", {"images": images, "info": INFO, "properties": props})


def themed(fn):
    return fn("light"), fn("dark")


def color_component(hexv):
    hexv = hexv.lstrip("#")
    alpha = int(hexv[6:8], 16) / 255 if len(hexv) == 8 else 1.0
    return {"color-space": "srgb", "components": {
        "red": "0x" + hexv[0:2].upper(), "green": "0x" + hexv[2:4].upper(), "blue": "0x" + hexv[4:6].upper(),
        "alpha": f"{alpha:.3f}"}}


def color_set(group, name, value):
    colors = [{"color": color_component(value["light"]), "idiom": "universal"}]
    colors.append({"appearances": [{"appearance": "luminosity", "value": "dark"}],
                   "color": color_component(value["dark"]), "idiom": "universal"})
    write_json(group / f"{name}.colorset" / "Contents.json", {"colors": colors, "info": INFO})


def vein_outline(d, width):
    """The logo's vein (one cubic) as a closed outline, so the mark can knock it out (even-odd)."""
    nums = [float(x) for x in re.findall(r"-?\d+\.?\d*", d)]
    p = [(nums[i], nums[i + 1]) for i in range(0, 8, 2)]
    r = width / 2

    def normal(a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        n = math.hypot(dx, dy)
        return (-dy / n, dx / n)

    n0, n1, n2 = normal(p[0], p[1]), normal(p[1], p[2]), normal(p[2], p[3])
    n12 = ((n1[0] + n2[0]) / 2, (n1[1] + n2[1]) / 2)
    ns = [n0, n0, n12, n2]

    def off(i, s):
        return f"{p[i][0] + s * r * ns[i][0]:.3f} {p[i][1] + s * r * ns[i][1]:.3f}"

    return (f"M{off(0, 1)}C{off(1, 1)} {off(2, 1)} {off(3, 1)}"
            f"A{r} {r} 0 0 0 {off(3, -1)}"
            f"C{off(2, -1)} {off(1, -1)} {off(0, -1)}"
            f"A{r} {r} 0 0 0 {off(0, 1)}Z")


def build():
    # Kuku comes from the owner's guide ("Kira.Mascot · Kuku — Identitas & panduan"), not the
    # artifact's KUKU_* tables: the Mascot folder is kept across the rebuild, untouched.
    kept = OUT.parent / ".mascot-kept"
    if (OUT / "Mascot").exists():
        shutil.rmtree(kept, ignore_errors=True)
        shutil.move(str(OUT / "Mascot"), str(kept))
    if OUT.exists():
        shutil.rmtree(OUT)
    write_json(OUT / "Contents.json", {"info": INFO})

    # AppIcon: the 1024 px full square, iOS masks it.
    icon = OUT / "AppIcon.appiconset"
    icon.mkdir(parents=True)
    shutil.copyfile(ICON, icon / "kira-icon-1024.png")
    write_json(icon / "Contents.json", {"images": [{"filename": "kira-icon-1024.png", "idiom": "universal",
                                                    "platform": "ios", "size": "1024x1024"}], "info": INFO})
    # AccentColor: pandan, so system controls (cursor, selection) carry the accent.
    color_set(OUT, "AccentColor", COLORS["pandan"])

    tokens = folder("Tokens")
    for name, value in COLORS.items():
        color_set(tokens, english(COLOR_NAMES, name), value)

    ilu = folder("Illustrations")
    for name, parts in ENV["ILLUSTRATIONS"].items():
        image_set(ilu, f"illustration-{english(ILLUSTRATION_NAMES, name)}", *themed(
            lambda th: svg("0 0 120 120", (120, 120), "".join(part_svg(p, th) for p in parts))))

    cat = folder("Categories")
    for name, c in ENV["CATEGORIES"].items():
        image_set(cat, f"category-{english(CATEGORY_NAMES, name)}", *themed(
            lambda th: svg("0 0 40 40", (40, 40), "".join(part_svg(p, th) for p in c["parts"]))))

    if kept.exists():
        shutil.move(str(kept), str(OUT / "Mascot"))

    alam = folder("Nature")
    for name, art in ENV["LEAF_ART"].items():
        vb = int(art["vb"])
        for tone in ("alam", "lembut", "hero"):
            parts = tone_parts(art["parts"], tone)
            image_set(alam, f"leaf-{english(LEAF_NAMES, name)}-{english(LEAF_TONES, tone)}", *themed(
                lambda th: svg(f"0 0 {vb} {vb}", (vb, vb), "".join(part_svg(p, th) for p in parts))))
    bukit = ENV["SCENES"]["bukit"]
    hero_hills = []
    for tag, paint, attrs in bukit:
        b = paint.split(":")
        b[1] = "hero-alam-2" if b[1] == "hijau-lembut" else "hero-alam"
        hero_hills.append([tag, ":".join(b), attrs])
    scenes = {"nature": bukit, "nature-evening": ENV["SCENES"]["sore"] + bukit, "hero": hero_hills}
    for name, parts in scenes.items():
        image_set(alam, f"scenery-{name}", *themed(
            lambda th: svg("0 0 400 150", (400, 150), "".join(part_svg(p, th) for p in parts))))

    hand = folder("Handwriting")
    for name, paths in ENV["ARROWS"].items():
        body = "".join(f'<path d="{d}"/>' for d in paths)
        image_set(hand, f"arrow-{name}", svg("0 0 40 28", (40, 28),
                  f'<g fill="none" stroke="#000000" stroke-width="1.8" stroke-linecap="round" '
                  f'stroke-linejoin="round">{body}</g>'), template=True)

    logo = folder("Logo")
    leaf = ENV["LOGO_LEAF"] + vein_outline(ENV["LOGO_VEIN"], 9)

    def mark(leaf_token, dot_token, th):
        fill, _ = rgba(leaf_token, th)
        body = f'<path fill-rule="evenodd" d="{leaf}" fill="{fill}"/>'
        if dot_token:
            body += f'<circle cx="184" cy="38" r="11" fill="{rgba(dot_token, th)[0]}"/>'
        return svg("36 22 162 162", (162, 162), body)

    image_set(logo, "logo-mark", *themed(lambda th: mark("pandan", "ilu-kunyit", th)))
    image_set(logo, "logo-mark-hero", *themed(lambda th: mark("on-hero", "hero-accent", th)))
    image_set(logo, "logo-mark-mono", svg("36 22 162 162", (162, 162),
              f'<path fill-rule="evenodd" d="{leaf}" fill="#000000"/>'), template=True)

    def app_icon(th):
        hero = rgba("hero", th)[0]
        return svg("0 0 220 220", (220, 220),
                   f'<rect width="220" height="220" rx="50" fill="{hero}"/>'
                   f'<path d="{ENV["LOGO_LEAF"]}" fill="{rgba("on-hero", th)[0]}"/>'
                   f'<path d="{ENV["LOGO_VEIN"]}" fill="none" stroke="{hero}" stroke-width="8" '
                   'stroke-linecap="round"/>'
                   f'<circle cx="184" cy="38" r="11" fill="{rgba("hero-accent", th)[0]}"/>')

    image_set(logo, "logo-icon", *themed(app_icon))


for v in ["POT", "LEAF_L1", "LEAF_R1", "LEAF_L2", "ILLUSTRATIONS", "CATEGORIES", "LEAF_T", "LEAF_ART",
          "SCENES", "ARROWS", "LOGO_LEAF", "LOGO_VEIN", "KUKU_BODY", "KUKU_EYES", "KUKU_STAR", "KUKU_FACE",
          "KUKU_FRONT"]:
    var(v)
build()
print("colors", len(COLORS), "illustrations", len(ENV["ILLUSTRATIONS"]), "categories", len(ENV["CATEGORIES"]),
      "expressions", len(ENV["KUKU_FACE"]), "leaves", len(ENV["LEAF_ART"]), "arrows", len(ENV["ARROWS"]))
