import Services
import ProtobufMessages
import SwiftProtobuf
import UIKit
import AnytypeCore
import Combine

@MainActor
final class MentionsViewModel {
    @Published private(set) var mentions = [MentionDisplayData]()
    let dismissSubject = PassthroughSubject<Void, Never>()
    
    var onSelect: RoutingAction<MentionObject>?
    
    var searchString = ""
    
    private let document: any BaseDocumentProtocol
    @Injected(\.mentionObjectsService)
    private var mentionService: any MentionObjectsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.objectActionsService)
    private var objectService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private var searchTask: Task<(), any Error>?

    private let formatter = DateFormatter.relationDateFormatter
    
    private let router: any EditorRouterProtocol
    
    init(document: some BaseDocumentProtocol, router: some EditorRouterProtocol) {
        self.document = document
        self.router = router
    }
    
    func obtainMentions(filterString: String) {
        searchString = filterString
        searchTask?.cancel()
        searchTask = Task { @MainActor [weak self] in
            guard let self else { return }
            
            var updatedMentions: [MentionDisplayData] = []

            let dateMentions = FeatureFlags.dateAsAnObject ? try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId],
                limitLayout: [.date]
            ) : []
            
            if dateMentions.isNotEmpty {
                updatedMentions.append(.header(title: Loc.dates))
                updatedMentions.append(contentsOf: dateMentions.map { .mention($0) })
                updatedMentions.append(.selectDate)
            }
            
            let objectsMentions = try await mentionService.searchMentions(
                spaceId: document.spaceId,
                text: filterString,
                excludedObjectIds: [document.objectId],
                limitLayout: DetailsLayout.visibleLayoutsWithFiles - [.date]
            )
            
            if objectsMentions.isNotEmpty {
                updatedMentions.append(.header(title: Loc.objects))
                updatedMentions.append(contentsOf: objectsMentions.map { .mention($0) })
            }
            
            mentions = updatedMentions
        }
    }
    
    func setFilterString(_ string: String) {
        obtainMentions(filterString: string)
    }
    
    func didSelectMention(_ mention: MentionObject) {
        onSelect?(mention)
        dismissSubject.send(())
    }
    
    func didSelectCustomDate() {
        router.showDatePicker { [weak self] date in
            self?.createDateObject(with: date)
        }
    }
    
    func didSelectCreateNewMention() {
        Task { @MainActor in
            guard let newBlockDetails = try? await defaultObjectService.createDefaultObject(name: searchString, shouldDeleteEmptyObject: false, spaceId: document.spaceId) else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: newBlockDetails.analyticsType, spaceId: newBlockDetails.spaceId, route: .mention)
            let mention = MentionObject(details: newBlockDetails)
            didSelectMention(mention)
        }
    }
    
    private func createDateObject(with date: Date) {
        Task { @MainActor in
            let title = formatter.string(from: date)
            let dateObjectType = try objectTypeProvider.objectType(uniqueKey: ObjectTypeUniqueKey.date, spaceId: document.spaceId)
            let details = try? await objectService.createObject(
                name: title,
                typeUniqueKey: dateObjectType.uniqueKey,
                shouldDeleteEmptyObject: false,
                shouldSelectType: true,
                shouldSelectTemplate: true,
                spaceId: document.spaceId,
                origin: .none,
                templateId: dateObjectType.defaultTemplateId
            )
            guard let details else { return }
            
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .mention)
            let mention = MentionObject(details: details)
            didSelectMention(mention)
        }
    }
}
