import Foundation

enum UITestFixtureLoader {
    static let envPrefix = "MIRYAM_FIXTURE_"

    static func launchEnvironment() -> [String: String] {
        let bundle = Bundle(for: FixtureBundleAnchor.self)
        guard let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) else {
            return [:]
        }

        var env: [String: String] = [:]
        for url in urls {
            let name = url.deletingPathExtension().lastPathComponent
            guard let data = try? Data(contentsOf: url),
                  let json = String(data: data, encoding: .utf8)
            else { continue }
            env["\(envPrefix)\(name)"] = json
        }
        return env
    }

    private final class FixtureBundleAnchor {}
}
