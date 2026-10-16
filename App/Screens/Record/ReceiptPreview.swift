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
                Viewfinder().frame(width: 258, height: 332).padding(.top, 34).frame(
                    maxHeight: .infinity, alignment: .top)
                chip("record.scan.frame", icon: .scan).frame(maxHeight: .infinity, alignment: .bottom).padding(
                    .bottom, 18)
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

/** The four pandan corners of the viewfinder, 32 pt each, 3.5 pt thick, rounded 16 pt. */
private struct Viewfinder: View {
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { corner in
                ViewfinderCorner()
                    .stroke(.pandan, style: StrokeStyle(lineWidth: 3.5, lineCap: .butt))
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(Double(corner) * 90))
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: [.topLeading, .topTrailing, .bottomTrailing, .bottomLeading][corner])
            }
        }
        .accessibilityHidden(true)
    }
}

/** A top-left corner: down the left edge, round the corner, along the top. */
private nonisolated struct ViewfinderCorner: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 1.75
        var path = Path()
        path.move(to: CGPoint(x: inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: inset, y: 16))
        path.addArc(tangent1End: CGPoint(x: inset, y: inset), tangent2End: CGPoint(x: 16, y: inset), radius: 16 - inset)
        path.addLine(to: CGPoint(x: rect.maxX, y: inset))
        return path
    }
}
