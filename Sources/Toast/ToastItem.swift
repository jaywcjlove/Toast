import SwiftUI
import Foundation

// MARK: - Toast Item
@MainActor
public final class ToastItem: ObservableObject, Identifiable, Equatable {
    public let id: String
    public let type: ToastType
    public let message: String
    public var icon: Image?
    public var customView: AnyView?
    
    // Configuration
    public var duration: TimeInterval?
    public var style: ToastStyle?
    public var showProgressBar: Bool
    public var closeOnTap: Bool
    public var haptic: ToastHaptic?
    
    // Callbacks
    public var onAppear: (() -> Void)?
    public var onDismiss: (() -> Void)?
    
    // State
    @Published public var isVisible: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var isPaused: Bool = false
    
    public init(
        id: String = UUID().uuidString,
        type: ToastType,
        message: String,
        icon: Image? = nil,
        customView: AnyView? = nil,
        duration: TimeInterval? = nil,
        style: ToastStyle? = nil,
        showProgressBar: Bool = false,
        closeOnTap: Bool = true,
        haptic: ToastHaptic? = nil,
        onAppear: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.icon = icon
        self.customView = customView
        self.duration = duration
        self.style = style
        self.showProgressBar = showProgressBar
        self.closeOnTap = closeOnTap
        self.haptic = haptic
        self.onAppear = onAppear
        self.onDismiss = onDismiss
    }
    
    public func pauseTimer() {
        isPaused = true
    }
    
    public func resumeTimer() {
        isPaused = false
    }
    
    public func triggerHaptic() {
        guard let haptic = haptic else { return }
        
        // macOS暂不支持触觉反馈，保留接口以备将来扩展
        switch haptic {
        case .success, .warning, .error, .light, .medium, .heavy, .soft, .rigid:
            // 可以考虑使用NSSound或其他反馈方式
            break
        }
    }
    
    // MARK: - Equatable
    public nonisolated static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        return lhs.id == rhs.id
    }
    

}

// MARK: - Toast Item Extension for Promise
extension ToastItem {
    @MainActor
    public static func loading(
        id: String = UUID().uuidString,
        message: String,
        showProgressBar: Bool = true
    ) -> ToastItem {
        return ToastItem(
            id: id,
            type: .loading,
            message: message,
            showProgressBar: showProgressBar
        )
    }
    
    @MainActor
    public func updateForSuccess(message: String) {
        Task { @MainActor in
            let newToast = ToastItem(
                id: self.id,
                type: .success,
                message: message,
                duration: self.duration,
                style: self.style,
                closeOnTap: self.closeOnTap,
                haptic: .success,
                onAppear: self.onAppear,
                onDismiss: self.onDismiss
            )
            
            // Copy state
            newToast.isVisible = self.isVisible
            
            // Update self
            // Timer已在ToastManager中管理
        }
    }
    
    @MainActor
    public func updateForError(message: String) {
        Task { @MainActor in
            let newToast = ToastItem(
                id: self.id,
                type: .error,
                message: message,
                duration: self.duration,
                style: self.style,
                closeOnTap: self.closeOnTap,
                haptic: .error,
                onAppear: self.onAppear,
                onDismiss: self.onDismiss
            )
            
            // Copy state
            newToast.isVisible = self.isVisible
            
            // Update self
            // Timer已在ToastManager中管理
        }
    }
}