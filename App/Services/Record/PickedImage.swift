/**
 An image picked in Scan Struk's gallery (CAT-05c): a receipt photo or a transfer screenshot, read
 into memory with its file name ("IMG_2041.jpg") and dropped once read. The picker needs no access
 to the library: the person chooses the one image.
 */
import CoreTransferable
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct PickedImage: Transferable {
    let data: Data
    let fileName: String?

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .image) { received in
            PickedImage(data: try Data(contentsOf: received.file), fileName: received.file.lastPathComponent)
        }
    }

    /** Loads `item` and hands its data and name to `onLoad`; an image that cannot load is skipped. */
    static func load(_ item: PhotosPickerItem, onLoad: (Data, String?) -> Void) async {
        guard let image = try? await item.loadTransferable(type: PickedImage.self) else { return }
        onLoad(image.data, image.fileName)
    }
}
