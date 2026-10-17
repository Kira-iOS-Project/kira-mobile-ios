/**
 Laporkan Grup (KOM-05, KOM-05d): one reason, a short story (required and roomier for "Lainnya"),
 the privacy promise and the red "Kirim Laporan". Detail Grup owns the form, closes the sheet on a
 result, and shows "Laporan Terkirim" (KOM-05b) or "Laporan Belum Terkirim" (KOM-05c).
 */
import Domain
import Features
import SwiftUI

struct GroupReportSheet: View {
    let model: GroupDetailModel

    var body: some View {
        ScrollView {
            GroupReportForm(form: model.reportForm)
        }
        .scrollBounceBehavior(.basedOnSize)
        .kiraFieldRingRoom()
        KiraButton("community.report.send", variant: .emergency) { Task { await model.sendReport() } }
            .icon(.flag)
            .block()
            .disabled(!model.reportForm.report.canSend || model.reportForm.isSending)
            .padding(.bottom, KiraSpacing.space2)
    }
}

/** The reasons, the story and the privacy promise. */
private struct GroupReportForm: View {
    @Bindable var form: GroupReportModel

    var body: some View {
        VStack(spacing: KiraSpacing.space4) {
            KiraListGroup("community.report.reasons") {
                ForEach(GroupReportReason.allCases, id: \.self) { reason in
                    KiraListRow(Text(reason.title), trailing: .check(form.report.reason == reason)) {
                        form.choose(reason)
                    }
                }
            }
            story
            KiraNotice(.privacy, message: "community.report.privacy")
        }
        .padding(.bottom, KiraSpacing.space2)
    }

    @ViewBuilder private var story: some View {
        let tooLong: LocalizedStringResource? =
            form.report.isStoryTooLong ? "community.report.story.tooLong" : nil
        if form.report.requiresStory {
            KiraField(
                "community.report.story.required", text: $form.report.story,
                prompt: "community.report.story.requiredPrompt"
            )
            .multiline(4)
            .hint("community.report.story.requiredHint")
            .error(tooLong)
        } else {
            KiraField("community.report.story", text: $form.report.story, prompt: "community.report.story.prompt")
                .multiline(2)
                .error(tooLong)
        }
    }
}
