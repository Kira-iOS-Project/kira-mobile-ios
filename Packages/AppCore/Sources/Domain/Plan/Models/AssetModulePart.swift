/**
 The parts of an asset-class module (REN-08), "Bagian N dari 4". The module opens on part 2, the
 board ModulKelasAset; part 1 has no board. Every part has the board's layout: titled sections in
 one card, the education notice, and the button at the bottom, which finishes the module on the
 last part.
 */
package enum AssetModulePart: Int, CaseIterable, Hashable, Sendable {
    /** Part 2: Apa Itu, Risikonya, Cocok untuk, Cara Mengecek (the board). */
    case basics = 2
    /** Part 3: when the money can be taken out, and the shortest time it suits. */
    case holding
    /** Part 4: who oversees or guarantees it, and what to check before starting. */
    case oversight

    /** The module's parts, part 1 included. */
    package static let total = 4

    /** "Bagian N dari 4". */
    package var number: Int { rawValue }

    /** The part after this one, nil on the last (whose button finishes the module). */
    package var next: Self? { Self(rawValue: rawValue + 1) }
}
