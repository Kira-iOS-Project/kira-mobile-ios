import Domain

/** What Catat opens over the chat: Catat Manual, Scan Struk, the voice panel and Paket. */
extension RecordModel {
    /** The pencil in the composer, and Catat Manual on the quota sheet. Never uses AI quota. */
    package func openManual() {
        guard let profile else { return }
        quotaSheet = nil
        manualEntry = ManualEntryModel(profile: profile, dependencies: dependencies) { [weak self] result in
            self?.replace(result.message)
        }
    }

    /** The camera in the composer: Scan Struk, or the quota sheet when the receipts are used up. */
    package func openScanner() {
        guard let profile, let usage else { return }
        guard profile.aiEnabled else {
            showsAIOff = true
            return
        }
        guard !usage.receipts.isExhausted else {
            quotaSheet = sheet(for: .receipts)
            return
        }
        scanner = ReceiptScanModel(
            quota: usage.receipts, dependencies: dependencies,
            onRead: { [weak self] result in
                self?.scanner = nil
                self?.apply(result, quota: .receipts)
            },
            onManual: { [weak self] in
                self?.scanner = nil
                self?.openManual()
            },
            onAIOff: { [weak self] in
                self?.scanner = nil
                self?.aiTurnedOff()
            })
    }

    /**
     The microphone: the voice panel on Kira Plus (CAT-10), the plans on a plan without voice, the
     quota sheet when the month's voice seconds are used up.
     */
    package func openVoice() {
        guard let profile, let usage else { return }
        guard profile.aiEnabled else {
            showsAIOff = true
            return
        }
        guard profile.hasVoice else {
            onOpen(.plans(yearly: false))
            return
        }
        guard !usage.voiceSeconds.isExhausted else {
            quotaSheet = sheet(for: .voice)
            return
        }
        voice = VoiceInputModel(
            transcriber: dependencies.transcriber, clock: dependencies.clock,
            limitSeconds: usage.voiceSeconds.remaining,
            onFinish: { [weak self] text, seconds in
                self?.voice = nil
                Task { await self?.send(text, method: .voice, voiceSeconds: seconds) }
            },
            onCancel: { [weak self] in self?.voice = nil })
    }

    /** Lihat Paket on the quota sheet: only the plans' information, nothing bought. */
    package func openPlans() {
        quotaSheet = nil
        onOpen(.plans(yearly: false))
    }

    /** The list icon: Riwayat (CAT-07). */
    package func openHistory() {
        onOpen(.history)
    }

    /** The help button: Kira Peduli. */
    package func openHelp() {
        onOpen(.care)
    }

    /**
     The server answered CHAT_AI_DISABLED: "Kira AI" was turned off, on another device too. Catat
     takes it as its own setting, so chat, receipts and voice wait, and shows the AI-off notice.
     */
    func aiTurnedOff() {
        if var profile {
            profile.aiEnabled = false
            phase = .loaded(profile)
        }
        showsAIOff = true
    }

    /** "Atur di Data & Privasi" on the AI-off notice. */
    package func openPrivacy() {
        showsAIOff = false
        onOpen(.privacy)
    }
}
