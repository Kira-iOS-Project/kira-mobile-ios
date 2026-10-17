/**
 The frame of Scan Struk: the live camera with the pandan viewfinder and "Paskan Struk di Dalam
 Bingkai", the frozen photo with "Foto Siap Dibaca", or the picked image with its file name. The
 receipt stays paper-light inside the dark screen, since it is the photo itself.
 */
import Features
import SwiftUI
import UIKit

struct ReceiptPreview: View {
    let stage: ReceiptScanModel.Stage
    let camera: any ReceiptCapturing

    var body: some View {
        ZStack {
            Color.artMask
            switch stage {
            case .camera, .reading:
                CameraPreview(camera: camera)
            case .photo(let data):
                still(data)
                chip("record.scan.ready", icon: .check).frame(maxHeight: .infinity, alignment: .bottom).padding(
                    .bottom, 18)
            case .picked(let data, let fileName):
                still(data)
                pickedChip(fileName)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: KiraRadius.extraLarge, style: .continuous))
        .hairline(.hairline, cornerRadius: KiraRadius.extraLarge)
        .frame(maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }

    /** The photo fills the frame without sizing it: a picked image of any shape stays inside. */
    @ViewBuilder private func still(_ data: Data) -> some View {
        if let image = UIImage(data: data) {
            Color.clear.overlay {
                Image(uiImage: image).resizable().scaledToFill()
                    .accessibilityLabel(Text("record.scan.photoLabel"))
            }
        }
    }

    private func pickedChip(_ fileName: String?) -> some View {
        Group {
            if let fileName {
                chip("record.scan.pickedName \(fileName)", icon: .image)
            } else {
                chip("record.scan.picked", icon: .image)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
    }

    private func chip(_ text: LocalizedStringResource, icon: KiraIconName) -> some View {
        HStack(spacing: 6) {
            KiraIcon(icon, size: 16, weight: .semibold).foregroundStyle(.pandan)
            Text(text).font(.footnote.weight(.semibold)).kiraLineHeight(18, size: 13).foregroundStyle(.ink)
        }
        .padding(.leading, 10).padding(.trailing, 14)
        .frame(minHeight: 34)
        .kiraCard(.surfaceRaised, cornerRadius: KiraRadius.full)
    }
}
