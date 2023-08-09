import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import Kingfisher
import AnytypeCore

final class MentionsViewModel {
    weak var view: MentionsView!
    
    private let documentId: String
    private let spaceId: String
    private let mentionService: MentionObjectsServiceProtocol
    private let pageService: PageServiceProtocol
    private let onSelect: (MentionObject) -> Void
    
    private var searchTask: Task<(), Error>?
    private var searchString = ""
    
    init(
        documentId: String,
        spaceId: String,
        mentionService: MentionObjectsServiceProtocol,
        pageService: PageServiceProtocol,
        onSelect: @escaping (MentionObject) -> Void
    ) {
        self.documentId = documentId
        self.spaceId = spaceId
        self.mentionService = mentionService
        self.pageService = pageService
        self.onSelect = onSelect
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor in
            let mentions = try await mentionService.searchMentions(spaceId: spaceId, text: filterString, excludedObjectIds: [documentId])
            view?.display(mentions.map { .mention($0) }, newObjectName: filterString)
        }
    }
    
    func setFilterString(_ string: String) {
        obtainMentions(filterString: string)
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect(mention)
        view?.dismiss()
    }
    
    func didSelectCreateNewMention() {
        Task { @MainActor in
            guard let newBlockDetails = try? await pageService.createPage(name: searchString, spaceId: spaceId) else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: newBlockDetails.analyticsType, route: .mention)
            let name = searchString.isEmpty ? Loc.untitled : searchString
            let mention = MentionObject(
                id: newBlockDetails.id,
                objectIcon: newBlockDetails.objectIconImageWithPlaceholder,
                name: name,
                description: nil,
                type: nil
            )
            didSelectMention(mention)
        }
    }
}
