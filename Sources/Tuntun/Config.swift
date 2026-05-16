import Foundation

@MainActor
final class Config {
    static let shared = Config()
    private let defaults = UserDefaults.standard

    var collapsed: Bool {
        get { defaults.bool(forKey: "collapsed") }
        set { defaults.set(newValue, forKey: "collapsed") }
    }

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: "launchAtLogin") }
        set { defaults.set(newValue, forKey: "launchAtLogin") }
    }
}
