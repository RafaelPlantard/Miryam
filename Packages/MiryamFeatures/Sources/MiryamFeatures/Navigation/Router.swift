import SwiftUI
import MiryamCore

/// Centralized navigation state for the app.
@Observable
@MainActor
public final class Router {
    public var path = NavigationPath()
    public var presentedSheet: AppSheet?

    public init() {}

    public func navigate(to route: AppRoute) {
        path.append(route)
    }

    public func presentSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }

    public func dismissSheet() {
        presentedSheet = nil
    }

    public func popToRoot() {
        path = NavigationPath()
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
