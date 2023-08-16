import Foundation
import SwiftUI

struct IconView: View {
    
    let icon: Icon?
    
    @State private var task: Task<Void, Never>?
    @State private var size: CGSize = .zero
    @State private var placeholderImage: UIImage?
    @State private var image: UIImage?
    
    @Environment(\.isEnabled) private var isEnable
    @Environment(\.redactionReasons) var redactionReasons
    
    // MARK: - Public properties
    
    var body: some View {
        ZStack {
            Color.clear.readSize { newSize in
                size = newSize
            }
            if redactionReasons.contains(.placeholder) {
                systemPlaceholder
            } else {
                content
            }
        }
        .onChange(of: isEnable) { _ in
            updateIcon()
        }
        .onChange(of: size) { _ in
            updateIcon()
        }
        .onChange(of: icon) { icon in
            // Icon field from struct contains old value
            updateIcon(icon)
            
        }
        .frame(idealWidth: 30, idealHeight: 30) // Default frame
    }
        
    @ViewBuilder
    private var content: some View {
        if let image {
            Image(uiImage: image)
        } else if let placeholderImage {
            Image(uiImage: placeholderImage)
        } else {
            systemPlaceholder
        }
    }
    
    private var systemPlaceholder: some View {
        // Empty image for native placeholder
        Image(uiImage: UIImage())
            .resizable()
            .frame(width: size.width, height: size.height)
    }
    
    private func updateIcon(_ newIcon: Icon? = nil) {
        task?.cancel()
        guard let icon = newIcon ?? icon else {
            placeholderImage = nil
            image = nil
            return
        }
        task = Task {
            let maker = IconMaker(icon: icon, size: size, iconContext: IconContext(isEnabled: isEnable))
            placeholderImage = maker.makePlaceholder()
            image = await maker.make()
        }
    }
}
