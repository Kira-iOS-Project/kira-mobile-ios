/**
 Scan Struk (canvas ScanStruk, ScanStrukFoto, ScanStrukGaleri; CAT-05, 05b, 05c): always dark.
 The header with the month's receipt quota and the torch, the preview in a rounded frame with the
 pandan viewfinder, then the gallery, the shutter and Ketik Manual; a frozen photo offers Foto Ulang
 or Baca Struk, a picked image Pilih Gambar Lain or Baca Struk.
 */
import Domain
import Features
import PhotosUI
import SwiftUI

struct ReceiptScanScreen: View {
    let model: ReceiptScanModel
    let camera: any ReceiptCapturing
    let onClose: () -> Void
    @State private var pick: PhotosPickerItem?
    @State private var showsPicker = false

    var body: some View {
        VStack(spacing: 14) {
            header
            ReceiptPreview(stage: model.stage, camera: camera)
            controls
        }
        /** The board's bottom padding is the home indicator's alone: the shutter sits on the safe area. */
        .padding(.horizontal, KiraSpacing.screen)
        .background(.surface)
        .environment(\.colorScheme, .dark)
        .photosPicker(isPresented: $showsPicker, selection: $pick, matching: .images)
        .onChange(of: pick) { _, item in
            guard let item else { return }
            Task { await PickedImage.load(item) { model.picked($0, fileName: $1) } }
        }
        .task { await model.appeared() }
        .onDisappear { Task { await model.disappeared() } }
        .modifier(ReceiptScanDialogs(model: model))
    }

    private var isPicked: Bool {
        if case .picked = model.stage { return true }
        return false
    }

    private var header: some View {
        HStack(spacing: KiraSpacing.space4) {
            KiraIconButton(.close, label: "record.scan.close", variant: .outline, action: onClose)
            VStack(spacing: 0) {
                Text("record.scan.title").font(.headline).kiraLineHeight(22, size: 17).accessibilityAddTraits(.isHeader)
                Group {
                    if isPicked {
                        Text("record.scan.fromGallery")
                    } else {
                        Text("record.scan.quota \(model.quota.used) \(model.quota.limit)")
                    }
                }
                .font(.caption).kiraLineHeight(16, size: 12).foregroundStyle(.inkMuted)
            }
            .foregroundStyle(.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, minHeight: KiraSize.tap)
            if isPicked {
                Color.clear.frame(width: KiraSize.tap, height: KiraSize.tap)
            } else {
                TorchButton(isOn: model.isTorchOn) { Task { await model.toggleTorch() } }
            }
        }
    }

    @ViewBuilder private var controls: some View {
        switch model.stage {
        case .camera:
            HStack {
                KiraIconButton(.image, label: "record.scan.gallery", variant: .outline) { showsPicker = true }
                    .frame(maxWidth: .infinity, alignment: .leading)
                ShutterButton { Task { await model.capture() } }
                KiraIconButton(.pencil, label: "record.scan.manual", variant: .outline, action: model.typeManually)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        case .photo:
            ScanButtonPair(
                secondary: KiraButton("record.scan.retake", variant: .secondary, action: model.retake).icon(.refresh),
                primary: readButton(size: .medium))
        case .picked:
            ScanButtonPair(
                secondary: KiraButton("record.scan.pickAnother", variant: .secondary, size: .small) {
                    showsPicker = true
                }
                .icon(.image),
                primary: readButton(size: .small))
        case .reading:
            ProgressView().frame(height: 50).accessibilityLabel(Text("record.scan.reading"))
        }
    }

    private func readButton(size: KiraButton.Size) -> KiraButton {
        KiraButton("record.scan.read", size: size) { Task { await model.read() } }
    }
}

/** The torch: outline like the close button, a lightning bolt, pressed while on. */
private struct TorchButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "bolt.fill" : "bolt")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.ink)
                .frame(width: KiraSize.tap, height: KiraSize.tap)
                .kiraCard(.button, border: .buttonLine, cornerRadius: KiraRadius.full)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("record.scan.torch"))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/** The shutter: an 80 pt ring in ink around a 68 pt disc. */
private struct ShutterButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle().fill(.ink).frame(width: 68, height: 68)
                .padding(4)
                .overlay { Circle().strokeBorder(.ink, lineWidth: 2) }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("record.scan.shutter"))
    }
}

/**
 Retake (or pick another) and Baca Struk, as KiraButtonPair lays them out. Baca Struk keeps the light
 theme's pandan on the dark camera (canvas ScanStrukFoto: its own `data-theme="light"`).
 */
private struct ScanButtonPair: View {
    let secondary: KiraButton
    let primary: KiraButton
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: KiraSpacing.space2) {
                primary.block().environment(\.colorScheme, .light)
                secondary.block()
            }
        } else {
            HStack(spacing: KiraSpacing.space2) {
                secondary.block()
                primary.block().environment(\.colorScheme, .light)
            }
        }
    }
}
