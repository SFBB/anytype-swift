import Services
import UIKit
import Kingfisher

extension SyncStatus {
    var title: String {
        switch self {
        case .unknown:
            return Loc.preparing
        case .offline:
            return Loc.noConnection
        case .syncing:
            return Loc.syncing
        case .synced:
            return Loc.synced
        case .failed, .incompatibleVersion:
            return Loc.notSyncing
        }
    }
    
    var image: UIImage? {
        guard let color else { return nil }
        return ImageBuilder(
            ImageGuideline(
                size: CGSize(width: 10, height: 10),
                radius: .point(5)
            )
        )
            .setImageColor(color).build()
    }
    
    private var color: UIColor? {
        switch self {
        case .failed, .incompatibleVersion:
            return UIColor.System.red
        case .syncing:
            return UIColor.System.amber100
        case .synced:
            return UIColor.System.green
        case .unknown, .offline:
            return nil
        }
    }
    
}
