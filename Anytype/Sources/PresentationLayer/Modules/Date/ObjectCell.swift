import SwiftUI

struct ObjectCell: View {
    
    let data: ObjectCellData

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            IconView(icon: data.icon)
                .frame(width: 48, height: 48)
                .allowsHitTesting(false)
            
            Spacer.fixedWidth(12)
            
            content
            
            Spacer()
        }
        .padding(.vertical, 12)
        .newDivider()
        .padding(.horizontal, 16)
        .fixTappableArea()
        .onTapGesture {
            data.onTap()
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            AnytypeText(data.title, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
                .frame(height: 20)
            
            Spacer.fixedHeight(2)
            AnytypeText(data.type, style: .relation2Regular)
            .foregroundColor(.Text.secondary)
            .lineLimit(1)
            
            Spacer()
        }
    }
    
}
