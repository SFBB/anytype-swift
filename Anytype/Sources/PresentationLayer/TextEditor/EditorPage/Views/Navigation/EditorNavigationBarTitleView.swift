import Foundation
import UIKit

final class EditorNavigationBarTitleView: UIView {
    
    private let stackView = UIStackView()
    
    private let iconImageView = IconViewUIKit()
    private let titleLabel = UILabel()
    private let lockImageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditorNavigationBarTitleView: ConfigurableView {

    enum Mode {
        struct TitleModel {
            let icon: Icon?
            let title: String?
        }

        case title(TitleModel)
        case modeTitle(String)
    }

    
    func configure(model: Mode) {
        switch model {
        case let .title(titleModel):
            titleLabel.text = titleModel.title
            titleLabel.font = .uxCalloutRegular
            iconImageView.isHidden = titleModel.icon.isNil
            iconImageView.icon = titleModel.icon
        case let .modeTitle(text):
            titleLabel.text = text
            titleLabel.font = .uxTitle1Semibold
            iconImageView.isHidden = true
        }
    }

    func setIsLocked(_ isLocked: Bool) {
        lockImageView.isHidden = !isLocked
    }
    
    /// Parents alpha sets automatically by system when it attaches to NavigationBar. 
    func setAlphaForSubviews(_ alpha: CGFloat) {
        titleLabel.alpha = alpha
        iconImageView.alpha = alpha
        lockImageView.alpha = alpha
    }
    
}

private extension EditorNavigationBarTitleView {
    
    func setupView() {
        titleLabel.textColor = .Text.primary
        titleLabel.numberOfLines = 1
        
        iconImageView.contentMode = .scaleAspectFit
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        lockImageView.image =  UIImage(asset: .TextEditor.lockedObject)
        lockImageView.contentMode = .center
        lockImageView.tintColor = .Button.active
        
        setupLayout()        
    }
    
    func setupLayout() {
        addSubview(stackView) {
            $0.width.lessThanOrEqual(to: 300)
            $0.pinToSuperview()
        }

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(lockImageView)

        iconImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 18, height: 18))
        }

        lockImageView.layoutUsing.anchors {
            $0.size(CGSize(width: 10, height: 18))
        }
    }
}
