#if os(iOS) || os(tvOS)
import SwiftUI
import UIKit

@MainActor
enum SnapshotHelper {
    /// Wraps a SwiftUI view in a UIHostingController configured for snapshot testing.
    static func hostingController<V: View>(
        for view: V,
        interfaceStyle: UIUserInterfaceStyle = .light
    ) -> UIHostingController<V> {
        let controller = UIHostingController(rootView: view)
        controller.overrideUserInterfaceStyle = interfaceStyle
        return controller
    }
}

#endif // os(iOS) || os(tvOS)
