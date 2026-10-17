/**
 Moves a value between two string vocabularies that spell their cases the same way: a generated
 enum and this package's (or Domain's) enum. The spellings come from one backend constant, so a
 mismatch means the spec and the app disagree; it surfaces as the generic problem rather than a
 crash.
 */
func bridged<Target: RawRepresentable>(_ value: some RawRepresentable<String>) throws -> Target
where Target.RawValue == String {
    guard let target = Target(rawValue: value.rawValue) else { throw AppProblem() }
    return target
}

/** `bridged(_:)` for an optional value: nil stays nil. */
func bridged<Target: RawRepresentable>(_ value: (some RawRepresentable<String>)?) throws -> Target?
where Target.RawValue == String {
    guard let value else { return nil }
    return try bridged(value) as Target
}
