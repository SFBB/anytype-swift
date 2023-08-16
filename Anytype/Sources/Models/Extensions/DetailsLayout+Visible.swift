import Services

extension DetailsLayout {
    static var visibleLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .note, .profile, .set, .todo]
    static var supportedForEditLayouts: [DetailsLayout] = [.basic, .bookmark, .collection, .file, .image, .note, .profile, .set, .todo]
}


// For editor

extension DetailsLayout {
    static var editorLayouts: [DetailsLayout] = [
        .note,
        .basic,
        .profile,
        .todo
    ]
    
    static var fileLayouts: [DetailsLayout] = [
        .file,
        .image
    ]
    
    static var systemLayouts: [DetailsLayout] = [
        .objectType,
        .relation,
        .relationOption,
        .relationOptionList,
        .dashboard,
        .database
    ]
    
    static var pageLayouts: [DetailsLayout] = [
        .basic,
        .profile,
        .todo,
        .note,
        .bookmark
    ]
    
    static var fileAndSystemLayouts: [DetailsLayout] = fileLayouts + systemLayouts
    static var layoutsWithoutTemplate: [DetailsLayout] = [
        .note,
        .set,
        .collection,
        .bookmark
    ] + fileAndSystemLayouts
}
