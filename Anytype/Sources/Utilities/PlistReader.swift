import Foundation
import UIKit

enum PlistReader {
    class BaseReader {
        typealias Output = [String : AnyObject]
        let dictionary: Output?
        
        required init(_ dictionary: Output?) {
            self.dictionary = dictionary
        }
        
        class func read() -> Self? {
            self.init([:])
        }
        
        class func read(_ url: URL?) -> Self? {
            url.flatMap{try? Data.init(contentsOf: $0)}
            .flatMap{try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil)}
            .flatMap{$0 as? Output}
            .flatMap(Self.init)
        }
        
        class func read(_ name: String) -> Self? {
            self.read(Bundle(for: self), name)
        }
        
        class func read(_ bundle: Bundle?, _ name: String) -> Self? {
            bundle.flatMap{$0.url(forResource: name, withExtension: "plist")}.flatMap(self.read)
        }
                
        class func read(_ name: String, _ configuration: String) -> Self? {
            self.read(Bundle(for: self), name, configuration)
        }
        
        class func read(_ bundle: Bundle?, _ name: String, _ configuration: String) -> Self? {
            self.read(bundle, name + "." + configuration)
        }
    }
}

//MARK: Configuration
extension PlistReader {
    enum Configuration: String {
        case Debug
        case Release
        case PublicBeta
    }
}

// MARK: Info.plist reader.
extension PlistReader {
    class BuildConfiguration: BaseReader {
        override class func read() -> Self? {
            .init(Bundle.main.infoDictionary as Output?)
        }
        
        static let current = BuildConfiguration(Bundle.main.infoDictionary as Output?)
        
        var userDefinedSettings: Output? {
            self.dictionary?["UserDefinedSettings"] as? Output
        }
        
        var buildConfigurationName: String? {
            self.userDefinedSettings?["BuildConfigurationName"] as? String
        }
        
        // MARK: Computed
        var buildConfiguration: Configuration? {
            Configuration.init(rawValue: self.buildConfigurationName ?? "")
        }
    }
}

// MARK: Variant reader.
extension PlistReader {
    class VariantReader: BaseReader {
        class func readVariant(_ name: String, _ configuration: Configuration) -> Self? {
            self.read(name, configuration.rawValue)
        }
        class func readVariant(_ name: String) -> Self? {
            // we use build configuration name from plist.
            // we could create BuildConfiguration from info.plist if needed.
            // for our needs we could use BuildConfiguration.current
            self.currentConfiguration().flatMap{self.readVariant(name, $0)}
        }
        class func currentConfiguration() -> Configuration? {
            BuildConfiguration.current.buildConfiguration
        }
        class func isRelease() -> Bool {
            self.currentConfiguration() == .Release
        }
    }
}
