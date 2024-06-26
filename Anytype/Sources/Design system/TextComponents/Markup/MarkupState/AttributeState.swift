import UIKit
import Services

enum AttributeState {
    case disabled
    case applied
    case notApplied

    static func state(
        markup: MarkupType,
        in range: NSRange,
        string: NSAttributedString,
        with restrictions: some BlockRestrictions) -> AttributeState
    {
        guard restrictions.isMarkupAvailable(markup) else { return .disabled }
        guard string.hasMarkup(markup, range: range) else { return .notApplied }
        return .applied
    }

    static func allMarkupAttributesState(
        in range: NSRange,
        string: NSAttributedString,
        with restrictions: some BlockRestrictions
    ) -> [MarkupType: AttributeState] {
        var allAttributesState = [MarkupType: AttributeState]()

        MarkupType.allCases.forEach {
            let value = string.markupValue($0, range: range) ?? $0
            allAttributesState[value] = AttributeState.state(markup: $0, in: range, string: string, with: restrictions)
        }

        return allAttributesState
    }

    static func markupAttributes(document: some BaseDocumentProtocol, infos: [BlockInformation]) -> [MarkupType: AttributeState] {
        let blocksMarkupAttributes = infos.compactMap { blockInformation -> [MarkupType: AttributeState]? in
            guard case let .text(textBlock) = blockInformation.content else { return nil }
            let anytypeText = AttributedTextConverter.asModel(
                document: document,
                text: textBlock.text,
                marks: textBlock.marks,
                style: textBlock.contentType
            )

            let restrictions = BlockRestrictionsBuilder.build(textContentType: textBlock.contentType)

            return AttributeState.allMarkupAttributesState(
                in: anytypeText.attrString.wholeRange,
                string: anytypeText.attrString,
                with: restrictions
            )
        }

        var mergedMarkupAttributes = [MarkupType: AttributeState]()
        blocksMarkupAttributes.forEach { markups in
            markups.forEach { markupKey, value in
                let keyWithSameType = mergedMarkupAttributes.keys
                    .first { $0.sameType(markupKey) }
                
                if keyWithSameType == markupKey {
                    // Same value
                    let existingValue = mergedMarkupAttributes[markupKey]
                    switch (existingValue, value) {
                    case (.disabled, _):
                        break // safe disable
                    case (.notApplied, .applied):
                        break // safe notApplied
                    default:
                        mergedMarkupAttributes[markupKey] = value
                    }
                } else if let keyWithSameType {
                    // Different value for same markup type
                    let existingValue = mergedMarkupAttributes[keyWithSameType]
                    mergedMarkupAttributes[keyWithSameType] = nil
                    switch (existingValue, value) {
                    case (.disabled, _), (_, .disabled):
                        mergedMarkupAttributes[markupKey.typeWithoutValue()] = .disabled
                    default:
                        mergedMarkupAttributes[markupKey.typeWithoutValue()] = .notApplied
                    }
                } else {
                    mergedMarkupAttributes[markupKey] = value
                }
            }
        }

        return mergedMarkupAttributes
    }

    static func alignmentAttributes(from blocks: [BlockInformation]) -> [LayoutAlignment: AttributeState] {
        var alignmentsStates = [LayoutAlignment: AttributeState]()

        blocks.forEach { blockInformation in
            guard case let .text(textBlock) = blockInformation.content else { return }

            let restrictions = BlockRestrictionsBuilder.build(textContentType: textBlock.contentType)

            LayoutAlignment.allCases.forEach {
                guard restrictions.isAlignmentAvailable($0) else {
                    alignmentsStates[$0] = .disabled
                    return
                }

                if alignmentsStates[$0] == .notApplied {
                    return
                } else {
                    alignmentsStates[$0] = blockInformation.horizontalAlignment == $0 ? .applied : .notApplied
                }
            }
        }

        return alignmentsStates
    }
}
