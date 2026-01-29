import SwiftUI
import Foundation

// MARK: - Toast Type
public enum ToastType: String, CaseIterable, Sendable {
    case success = "success"
    case error = "error"
    case info = "info"
    case loading = "loading"
    case custom = "custom"
    
    var defaultIcon: Image {
        switch self {
        case .success:
            return Image(systemName: "checkmark.circle.fill")
        case .error:
            return Image(systemName: "xmark.circle.fill")
        case .info:
            return Image(systemName: "info.circle.fill")
        case .loading:
            return Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
        case .custom:
            return Image(systemName: "circle.fill")
        }
    }
    
    var defaultColor: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .info:
            return .blue
        case .loading:
            return .orange
        case .custom:
            return .primary
        }
    }
}

// MARK: - Toast Position
public enum ToastPosition: Sendable, Hashable {
    // In-app positions (View coordinate system)
    case topLeft
    case topCenter
    case topRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    case center
    case absolute(x: CGFloat, y: CGFloat)
    
    var insertionBehavior: ToastInsertionBehavior {
        switch self {
        case .topLeft, .topCenter, .topRight:
            return .top
        case .bottomLeft, .bottomCenter, .bottomRight:
            return .bottom
        case .center, .absolute:
            return .replace
        }
    }
}

// MARK: - Toast Insertion Behavior
public enum ToastInsertionBehavior: Sendable {
    case top      // 新消息插入顶部，推挤其他消息向下
    case bottom   // 新消息插入底部，推挤其他消息向上
    case replace  // 替换现有消息（center位置）
}

// MARK: - Toast Position Extensions
extension ToastPosition: CaseIterable {
    public static var allCases: [ToastPosition] {
        return [
            .topLeft, .topCenter, .topRight,
            .bottomLeft, .bottomCenter, .bottomRight,
            .center
        ]
    }
}

// MARK: - Toast Theme
public enum ToastTheme: String, CaseIterable, Sendable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

// MARK: - Toast Haptic Feedback
public enum ToastHaptic: Sendable {
    case success
    case warning
    case error
    case light
    case medium
    case heavy
    case soft
    case rigid
}

// MARK: - Toast Style
public struct ToastStyle: Sendable {
    public var backgroundColor: Color?
    public var foregroundColor: Color?
    public var borderColor: Color?
    public var borderWidth: CGFloat?
    public var cornerRadius: CGFloat?
    public var shadowRadius: CGFloat?
    public var shadowOffset: CGSize?
    public var padding: EdgeInsets?
    
    public init(
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        borderColor: Color? = nil,
        borderWidth: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        shadowRadius: CGFloat? = nil,
        shadowOffset: CGSize? = nil,
        padding: EdgeInsets? = nil
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.padding = padding
    }
    
    public static let `default` = ToastStyle(
        backgroundColor: nil,
        foregroundColor: nil,
        cornerRadius: 8,
        shadowRadius: 4,
        shadowOffset: CGSize(width: 0, height: 2),
        padding: EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    )
}

// MARK: - Toast Configuration
public struct ToastConfiguration: Sendable {
    public var position: ToastPosition
    public var duration: TimeInterval
    public var reverseOrder: Bool
    public var gutter: CGFloat
    public var offset: CGSize
    public var maxVisibleToasts: Int
    public var pauseOnHover: Bool
    public var closeButton: Bool
    public var theme: ToastTheme
    public var containerStyle: ToastStyle
    public var enablePushAnimation: Bool
    public var animationDuration: TimeInterval
    public var allowsHitTesting: Bool
    
    public init(
        position: ToastPosition = .topRight,
        duration: TimeInterval = 4.0,
        reverseOrder: Bool = false,
        gutter: CGFloat = 8,
        offset: CGSize = .zero,
        maxVisibleToasts: Int = 5,
        pauseOnHover: Bool = true,
        closeButton: Bool = false,
        theme: ToastTheme = .system,
        containerStyle: ToastStyle = .default,
        enablePushAnimation: Bool = true,
        animationDuration: TimeInterval = 0.5,
        allowsHitTesting: Bool = true
    ) {
        self.position = position
        self.duration = duration
        self.reverseOrder = reverseOrder
        self.gutter = gutter
        self.offset = offset
        self.maxVisibleToasts = maxVisibleToasts
        self.pauseOnHover = pauseOnHover
        self.closeButton = closeButton
        self.theme = theme
        self.containerStyle = containerStyle
        self.enablePushAnimation = enablePushAnimation
        self.animationDuration = animationDuration
        self.allowsHitTesting = allowsHitTesting
    }
    
    public static let `default` = ToastConfiguration()
}

// MARK: - Promise Messages
public struct ToastPromiseMessages: Sendable {
    public var loading: String
    public var success: String
    public var error: String
    
    public init(loading: String, success: String, error: String) {
        self.loading = loading
        self.success = success
        self.error = error
    }
}
