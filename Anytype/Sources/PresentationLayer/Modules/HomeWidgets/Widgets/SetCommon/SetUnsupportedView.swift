import Foundation
import SwiftUI

struct SetUnsupportedView: View {
    var body: some View {
        Text(Loc.Set.View.unsupportedAlert)
            .anytypeStyle(.relation2Regular)
            .foregroundColor(Color.Dark.sky)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .background(Color.VeryLight.sky)
            .cornerRadius(8, style: .continuous)
    }
}
