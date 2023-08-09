import UIKit

struct ObjectIconImageModel {
    let iconImage: Icon
    let usecase: ObjectIconImageUsecase
    
    var imageGuideline: ImageGuideline? {
        usecase.objectIconImageGuidelineSet.imageGuideline(for: iconImage)
    }
    
    var font: UIFont? {
        usecase.objectIconImageFontSet.imageFont(for: iconImage)
    }
}
