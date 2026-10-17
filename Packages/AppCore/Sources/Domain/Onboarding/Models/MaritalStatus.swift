/** Status Pernikahan (ONB-12): sets the emergency-fund target, 6× single and 9× married. */
package enum MaritalStatus: String, CaseIterable, Hashable, Sendable {
    /** Belum Menikah. */
    case single
    /** Sudah Menikah. */
    case married
}
