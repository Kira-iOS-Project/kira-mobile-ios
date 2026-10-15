#!/usr/bin/env node
/**
 * English names (AGENTS.md Rule 35): identifiers, asset names, file names and String Catalog keys
 * are English; Indonesian lives only in the catalog's translations.
 *
 * Heuristic: it splits every Swift identifier (code only, not strings or comments), every name in
 * App/Assets.xcassets, every Swift file name and every catalog key into words, and fails on a word
 * from the Indonesian design vocabulary below (the artifact's token, category, illustration,
 * mascot and screen names). A word it does not list passes, so a reviewer still reads new names;
 * add a word here when the design system brings one.
 *
 *   node scripts/check/english-names.mjs
 *
 * Exit 0 clean, 1 a finding.
 */
import { execFileSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';

const DENY = new Set(`
  alam aman bahaya bangga barang bata belanja beranda bertahan buku bulu catat celengan darurat daun
  edukasi emas gaji gembok hiburan hijau ikon ilu ilustrasi kalender kartu kategori kesehatan kilau
  komunitas kopi krem kripto kuku kunyit lainnya langit lembut lunas makan maskot mata mekar menikah
  muda netral panah payung peduli pemandangan pendidikan pensiun peringatan perisai persik pinjol
  pita privasi proteksi putih ranting reksadana rencana rentan rumah saham sbn sehat senang simulasi
  struk surat tabungan tagihan tanah tanda tangga tenang tinta topeng transportasi tua tulisan
  tumbuh tunai tunas wajah
`.split(/\s+/).filter(Boolean));

/** The words of a name: camelCase, kebab-case, snake_case and dotted parts, lowercased. */
function words(name) {
  return name
    .replace(/([a-z0-9])([A-Z])/g, '$1 $2')
    .split(/[^A-Za-z]+/)
    .filter(Boolean)
    .map((w) => w.toLowerCase());
}

/** The code of a Swift file without its comments and string literals. */
function swiftCode(src) {
  let out = '';
  let i = 0;
  while (i < src.length) {
    if (src.startsWith('//', i)) {
      const end = src.indexOf('\n', i);
      i = end === -1 ? src.length : end;
    } else if (src.startsWith('/*', i)) {
      let depth = 0;
      while (i < src.length) {
        if (src.startsWith('/*', i)) { depth += 1; i += 2; }
        else if (src.startsWith('*/', i)) { depth -= 1; i += 2; if (depth === 0) break; }
        else i += 1;
      }
    } else if (src[i] === '"') {
      const close = src.startsWith('"""', i) ? '"""' : '"';
      i += close.length;
      while (i < src.length && !src.startsWith(close, i)) i += src[i] === '\\' ? 2 : 1;
      i += close.length;
      out += ' ';
    } else {
      out += src[i];
      i += 1;
    }
  }
  return out;
}

const findings = [];
function check(where, name) {
  const bad = words(name).filter((w) => DENY.has(w));
  if (bad.length) findings.push(`${where}: "${name}" (${bad.join(', ')})`);
}

const tracked = execFileSync('git', ['ls-files'], { encoding: 'utf8' }).split('\n').filter(Boolean);
for (const file of tracked) {
  if (file.includes('/GeneratedSources/') || !existsSync(file)) continue;
  if (file.endsWith('.swift')) {
    check(file, file.split('/').pop().replace(/\.swift$/, ''));
    const seen = new Set();
    for (const m of swiftCode(readFileSync(file, 'utf8')).matchAll(/[A-Za-z_][A-Za-z0-9_]*/g)) {
      if (seen.has(m[0])) continue;
      seen.add(m[0]);
      check(file, m[0]);
    }
  } else if (file.startsWith('App/Assets.xcassets/')) {
    for (const part of file.slice('App/Assets.xcassets/'.length).split('/')) check(file, part.replace(/\.\w+$/, ''));
  }
}
const catalog = JSON.parse(readFileSync('App/Localizable.xcstrings', 'utf8'));
for (const key of Object.keys(catalog.strings)) check('App/Localizable.xcstrings key', key.split(' ')[0]);

const unique = [...new Set(findings)];
for (const line of unique) console.log(line);
console.log(`english-names: ${unique.length} Indonesian name(s); translations stay in the catalog's values`);
process.exit(unique.length ? 1 : 0);
