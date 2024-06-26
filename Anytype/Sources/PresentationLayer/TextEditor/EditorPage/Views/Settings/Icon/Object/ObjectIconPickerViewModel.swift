import Combine
import UIKit
import Services
import AnytypeCore

struct ObjectIconPickerData: Identifiable {
    let document: BaseDocumentProtocol
    var id: String { document.objectId }
}

enum ObjectIconPickerAction {
    enum IconSource {
        case emoji(emojiUnicode: String)
        case upload(itemProvider: NSItemProvider)
    }
    
    case setIcon(IconSource)
    case removeIcon
}

final class ObjectIconPickerViewModel: ObservableObject {
    
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: any ObjectHeaderUploadingServiceProtocol
    
    let mediaPickerContentType: MediaPickerContentType = .images

    @Published private(set) var isRemoveButtonAvailable: Bool = false
    @Published private(set) var detailsLayout: DetailsLayout?
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Private variables
    
    private let document: BaseDocumentProtocol
    private var subscription: AnyCancellable?
        
    // MARK: - Initializer
    
    init(data: ObjectIconPickerData) {
        self.document = data.document
        subscription = document.detailsPublisher
            .receiveOnMain()
            .sink { [weak self] details in
                self?.updateState(details: details)
            }
    }
    
    
    func setEmoji(_ emojiUnicode: String) {
        handleIconAction(document: document, action: .setIcon(.emoji(emojiUnicode: emojiUnicode)))
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        handleIconAction(document: document, action: .setIcon(.upload(itemProvider: itemProvider)))
    }
    
    func removeIcon() {
        handleIconAction(document: document, action: .removeIcon)
    }
    
    // MARK: - Private
    
    private func updateState(details: ObjectDetails) {
        isRemoveButtonAvailable = details.objectIcon != nil
        detailsLayout = details.layoutValue
        isRemoveEnabled = makeIsRemoveEnabled(details: details)
    }
    
    private func makeIsRemoveEnabled(details: ObjectDetails) -> Bool {
        switch detailsLayout {
        case .basic, .set, .collection:
            return true
        case .profile, .participant, .space, .spaceView:
            return details.iconImage.isNotEmpty
        default:
            anytypeAssertionFailure(
                "`ObjectIconPickerViewModel` unavailable",
                info: ["detailsLayout": String(detailsLayout?.rawValue ?? 0)]
            )
            return true
        }
    }
    
    private func handleIconAction(document: BaseDocumentProtocol, action: ObjectIconPickerAction) {
        Task {
            try await objectHeaderUploadingService.handleIconAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: action
            )
        }
    }
}
