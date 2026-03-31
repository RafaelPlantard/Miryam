#if os(iOS) || os(tvOS)
@_spi(Internals) import SnapshotTesting
import Foundation
import SwiftUI
import UIKit

@MainActor
enum SnapshotHelper {
#if os(iOS)
    static let phoneConfig = ViewImageConfig.iPhoneXr(.portrait)
    static let padPortraitConfig = ViewImageConfig.iPadPro11(.portrait)
    static let padLandscapeConfig = ViewImageConfig.iPadPro11(.landscape)
#else
    static let phoneConfig = ViewImageConfig(size: CGSize(width: 414, height: 896))
    static let padPortraitConfig = ViewImageConfig(size: CGSize(width: 834, height: 1_194))
    static let padLandscapeConfig = ViewImageConfig(size: CGSize(width: 1_194, height: 834))
#endif
#if os(tvOS)
    static let tvConfig = ViewImageConfig.tv
#else
    static let tvConfig = ViewImageConfig(size: CGSize(width: 1_920, height: 1_080))
#endif
    static let watchSize = CGSize(width: 198, height: 242)
    static let carPlaySize = CGSize(width: 1_280, height: 720)

    enum Presentation: Sendable {
        case fullScreen
        case bottomSheet(height: CGFloat, cornerRadius: CGFloat = 16, dimOpacity: Double = 0.86)
        case centeredPopover(
            size: CGSize,
            cornerRadius: CGFloat = 20,
            dimOpacity: Double = 0.18
        )
    }

    /// Determines the record mode from the `SNAPSHOT_RECORD` environment variable.
    ///
    /// Set `SNAPSHOT_RECORD=1` or `SNAPSHOT_RECORD=all` to re-record every snapshot.
    /// Set `SNAPSHOT_RECORD=missing` to record only missing snapshots.
    /// When unset or empty the caller-supplied `record` parameter is used as-is.
    private static var environmentRecordMode: SnapshotTestingConfiguration.Record? = {
        guard let value = ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"]?.lowercased(),
              !value.isEmpty
        else { return nil }
        switch value {
        case "1", "true", "all": return .all
        case "missing": return .missing
        case "failed": return .failed
        case "0", "false", "never": return .never
        default: return nil
        }
    }()

    /// Wraps a SwiftUI view in a UIHostingController configured for snapshot testing.
    static func hostingController<V: View>(
        for view: V,
        interfaceStyle: UIUserInterfaceStyle = .light,
        presentation: Presentation = .fullScreen,
        canvasSize: CGSize? = nil
    ) -> UIHostingController<AnyView> {
        let rootView = AnyView(wrap(view, presentation: presentation, canvasSize: canvasSize))
        let controller = UIHostingController(rootView: rootView)
        controller.overrideUserInterfaceStyle = interfaceStyle
        if let canvasSize {
            controller.view.bounds = CGRect(origin: .zero, size: canvasSize)
            controller.preferredContentSize = canvasSize
        }
        return controller
    }

    @ViewBuilder
    private static func wrap<V: View>(
        _ view: V,
        presentation: Presentation,
        canvasSize: CGSize?
    ) -> some View {
        switch presentation {
        case .fullScreen:
            view
        case let .bottomSheet(height, cornerRadius, dimOpacity):
            ZStack(alignment: .bottom) {
                Color.black.opacity(dimOpacity)

                view
                    .frame(maxWidth: .infinity, alignment: .top)
                    .frame(height: height, alignment: .top)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    )
            }
            .frame(
                width: canvasSize?.width,
                height: canvasSize?.height,
                alignment: .bottom
            )
            .ignoresSafeArea()
        case let .centeredPopover(size, cornerRadius, dimOpacity):
            ZStack {
                Color.black.opacity(dimOpacity)

                view
                    .frame(width: size.width, height: size.height, alignment: .top)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .shadow(color: .black.opacity(0.18), radius: 24, y: 8)
            }
            .frame(
                width: canvasSize?.width,
                height: canvasSize?.height,
                alignment: .center
            )
            .ignoresSafeArea()
        }
    }

    private static func performSnapshot<Value, Format>(
        of value: @autoclosure () throws -> Value,
        as snapshotting: Snapshotting<Value, Format>,
        named name: String? = nil,
        record: SnapshotTestingConfiguration.Record? = nil,
        timeout: TimeInterval = 5,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let fileUrl = URL(fileURLWithPath: "\(filePath)", isDirectory: false)
        let fileName = fileUrl.deletingPathExtension().lastPathComponent
        let snapshotDir = fileUrl
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(fileName)
            .path

        // Environment variable overrides the caller-supplied record parameter.
        let effectiveRecord = Self.environmentRecordMode ?? record

        let failure = verifySnapshot(
            of: try value(),
            as: snapshotting,
            named: name,
            record: effectiveRecord,
            snapshotDirectory: snapshotDir,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
        guard let message = failure else { return }
        if let effectiveRecord, effectiveRecord != .never {
            return
        }
        recordIssue(
            message,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }

    /// Asserts a snapshot with an explicit `snapshotDirectory` computed from `#filePath`.
    ///
    /// Workaround for SnapshotTesting path resolution issues when test sources
    /// live inside SPM packages but the test target is generated by XcodeGen.
    /// See: https://github.com/pointfreeco/swift-snapshot-testing/discussions/553
    static func assertSnapshot<Value, Format>(
        of value: @autoclosure () throws -> Value,
        as snapshotting: Snapshotting<Value, Format>,
        named name: String? = nil,
        record: SnapshotTestingConfiguration.Record? = nil,
        timeout: TimeInterval = 5,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        performSnapshot(
            of: try value(),
            as: snapshotting,
            named: name,
            record: record,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }

    static func assertSnapshot(
        of value: @autoclosure () throws -> UIViewController,
        as snapshotting: Snapshotting<UIViewController, UIImage>,
        named name: String? = nil,
        record: SnapshotTestingConfiguration.Record? = nil,
        timeout: TimeInterval = 5,
        fileID: StaticString = #fileID,
        file filePath: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        let controller: UIViewController
        do {
            controller = try value()
        } catch {
            recordIssue(
                "Failed to build snapshot controller: \(error)",
                fileID: fileID,
                filePath: filePath,
                line: line,
                column: column
            )
            return
        }

        performSnapshot(
            of: controller,
            as: snapshotting,
            named: name,
            record: record,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )

        performSnapshot(
            of: accessibilityTreeDescription(for: controller),
            as: Snapshotting<String, String>.lines,
            named: accessibilitySnapshotName(for: name),
            record: record,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }

    private static func accessibilitySnapshotName(for name: String?) -> String {
        if let name, !name.isEmpty {
            return "\(name)-accessibility"
        }
        return "accessibility"
    }

    private static func accessibilityTreeDescription(for controller: UIViewController) -> String {
        controller.loadViewIfNeeded()
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let header = "UIViewController<\(type(of: controller))>"
        let body = accessibilityTreeLines(for: controller.view, depth: 0)
        return ([header] + body).joined(separator: "\n")
    }

    private static func accessibilityTreeLines(for view: UIView, depth: Int) -> [String] {
        guard !view.isHidden, view.alpha > 0.01 else { return [] }

        let indent = String(repeating: "  ", count: depth)
        var lines: [String] = []

        if let summary = accessibilitySummary(for: view) {
            lines.append("\(indent)\(summary)")
        }

        for subview in view.subviews {
            lines.append(contentsOf: accessibilityTreeLines(for: subview, depth: depth + 1))
        }

        return lines
    }

    private static func accessibilitySummary(for view: UIView) -> String? {
        let identifier = view.accessibilityIdentifier?.trimmingCharacters(in: .whitespacesAndNewlines)
        let label = view.accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = view.accessibilityValue?.trimmingCharacters(in: .whitespacesAndNewlines)

        let shouldEmit =
            view.isAccessibilityElement ||
            !(identifier?.isEmpty ?? true) ||
            !(label?.isEmpty ?? true) ||
            !(value?.isEmpty ?? true)

        guard shouldEmit else { return nil }

        var parts = [String(describing: type(of: view))]
        if let identifier, !identifier.isEmpty {
            parts.append("id=\"\(identifier)\"")
        }
        if let label, !label.isEmpty {
            parts.append("label=\"\(label)\"")
        }
        if let value, !value.isEmpty {
            parts.append("value=\"\(value)\"")
        }
        if view.isAccessibilityElement {
            parts.append("element=true")
        }

        return parts.joined(separator: " ")
    }
}

#endif // os(iOS) || os(tvOS)
