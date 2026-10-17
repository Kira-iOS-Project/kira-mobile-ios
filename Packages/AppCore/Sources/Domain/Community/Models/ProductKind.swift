/** The kinds of product Etalase lists: the backend's `PRODUCT_KIND` values. */
package enum ProductKind: String, CaseIterable, Codable, Sendable {
    /** A course: "Kursus". */
    case course
    /** A consultation: "Konsultasi". */
    case consultation
    /** An e-book: "E-Book". */
    case ebook
    /** An event, such as a webinar: "Event". */
    case event
}
