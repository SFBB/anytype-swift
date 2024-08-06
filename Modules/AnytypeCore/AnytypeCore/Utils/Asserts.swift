import UIKit
import Logger

enum AssertionError: Error {
    case common(String)
}

public func anytypeAssertionFailure(
    _ message: String,
    info: [String: String] = [:],
    tags: [String: String] = [:],
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line
) {
    logNonFatal(message, info: info, tags: tags, file: file, function: function, line: line)
    #if ENTERPRISE
        if FeatureFlags.showAlertOnAssert {
            Task { @MainActor in showAssertionAlert(message) }
        }
    #endif
}

public func anytypeAssertionFailureWithError(
    _ message: String,
    info: [String: String] = [:],
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line
) -> Error {
    anytypeAssertionFailure(message, info: info, file: file, function: function, line: line)
    return AssertionError.common(message)
}

public func anytypeAssert(
    _ condition: @autoclosure () -> Bool,
    _ message: String,
    info: [String: String] = [:],
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line
) {
    if condition() != true {
        anytypeAssertionFailure(message, info: info, file: file, function: function, line: line)
    }
} 

// MARK:- Private
@MainActor
private func showAssertionAlert(_ message: String) {
    
    let keyWindow = UIApplication.shared.connectedScenes
        .first { $0.activationState == .foregroundActive }
        .flatMap { $0 as? UIWindowScene }?.keyWindow
    
    guard let keyWindow else {
        return
    }
    
    let copyAction = UIAlertAction(title: "Copy assertion", style: .default) { _ in
        UIPasteboard.general.string = message
    }
    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    
    let alert = UIAlertController(title: "Assertion", message: message, preferredStyle: .alert)
    alert.addAction(copyAction)
    alert.addAction(okAction)

    
    DispatchQueue.main.async {
        keyWindow.rootViewController?.topPresentedController.present(alert, animated: true, completion: nil)
    }
}

private func logNonFatal(
    _ message: String,
    info: [String: String] = [:],
    tags: [String: String] = [:],
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line
) {
    AssertionLogger.shared.log(message, info: info, tags: tags, file: "\(file)", function: function, line: line)
}
