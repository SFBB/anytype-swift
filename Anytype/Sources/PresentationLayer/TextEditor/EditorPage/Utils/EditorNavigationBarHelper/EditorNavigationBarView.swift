import Foundation
import UIKit

final class EditorNavigationBarView: UIView {
    
    private let leftButtonContainer = UIView()
    private let rightButtonContainer = UIView()
    private let titleContainer = UIView()
    private let contentView = UIView()
    
    var leftButton: UIView? {
        didSet {
            leftButtonContainer.removeAllSubviews()
            if let leftButton {
                leftButtonContainer.addSubview(leftButton) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    var rightButton: UIView? {
        didSet {
            rightButtonContainer.removeAllSubviews()
            if let rightButton {
                rightButtonContainer.addSubview(rightButton) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    var titleView: UIView? {
        didSet {
            titleContainer.removeAllSubviews()
            if let titleView {
                titleContainer.addSubview(titleView) {
                    $0.pinToSuperview()
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(contentView) {
            $0.pinToSuperview(insets: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            $0.height.equal(to: 44)
        }
        
        contentView.addSubview(leftButtonContainer) {
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
        }
        
        contentView.addSubview(rightButtonContainer) {
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
        }
        
        contentView.addSubview(titleContainer) {
            $0.centerX.equal(to: contentView.centerXAnchor, priority: .defaultLow)
            $0.centerY.equal(to: contentView.centerYAnchor)
            $0.leading.greaterThanOrEqual(to: leftButtonContainer.trailingAnchor, constant: 8)
            $0.trailing.lessThanOrEqual(to: rightButtonContainer.leadingAnchor, constant: 8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
