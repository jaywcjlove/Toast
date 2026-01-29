import SwiftUI
import Foundation

// MARK: - Toast Manager
@MainActor
@Observable
public final class ToastManager {
    public static let shared = ToastManager()
    
    public var configuration = ToastConfiguration.default
    
    // 按位置分组的Toast列表
    private var toastsByPosition: [ToastPosition: [ToastItem]] = [:]
    
    private init() {}
    
    // 获取指定位置的Toast列表
    public func toasts(for position: ToastPosition) -> [ToastItem] {
        return toastsByPosition[position] ?? []
    }
    
    // 获取所有Toast（为了向后兼容）
    public var toasts: [ToastItem] {
        return toastsByPosition.values.flatMap { $0 }
    }
    
    // MARK: - Core Toast Methods
    public func show(
        id: String = UUID().uuidString,
        type: ToastType,
        message: String,
        icon: Image? = nil,
        customView: AnyView? = nil,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil,
        style: ToastStyle? = nil,
        showProgressBar: Bool = false,
        closeOnTap: Bool = true,
        haptic: ToastHaptic? = nil,
        onAppear: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let toast = ToastItem(
            id: id,
            type: type,
            message: message,
            icon: icon ?? type.defaultIcon,
            customView: customView,
            duration: duration,
            style: style,
            showProgressBar: showProgressBar,
            closeOnTap: closeOnTap,
            haptic: haptic,
            onAppear: onAppear,
            onDismiss: onDismiss
        )
        
        let effectivePosition = position ?? configuration.position
        
        // Remove existing toast with same ID
        dismiss(id: id)
        
        // Add to appropriate position group
        addToastToPosition(toast, position: effectivePosition)
        
        // Trigger haptic feedback
        toast.triggerHaptic()
        
        // Call onAppear
        onAppear?()
        
        // Start timer if needed
        if type != .loading {
            let timerDuration = duration ?? configuration.duration
            if timerDuration > 0 {
                Task {
                    try await Task.sleep(for: .seconds(timerDuration))
                    dismiss(id: toast.id)
                }
            }
        }
        
        // Show with animation
        withAnimation(.spring(response: configuration.animationDuration, dampingFraction: 0.8)) {
            toast.isVisible = true
        }
    }
    
    private func addToastToPosition(_ toast: ToastItem, position: ToastPosition) {
        var toasts = toastsByPosition[position] ?? []
        
        // 根据位置决定插入方式
        switch position.insertionBehavior {
        case .top:
            // Top位置：新消息插入到顶部（数组开头）
            if configuration.reverseOrder {
                toasts.append(toast)
            } else {
                toasts.insert(toast, at: 0)
            }
        case .bottom:
            // Bottom位置：新消息插入到底部（数组末尾）
            if configuration.reverseOrder {
                toasts.insert(toast, at: 0)
            } else {
                toasts.append(toast)
            }
        case .replace:
            // Center位置：只保留最新的
            toasts = [toast]
        }
        
        // 限制最大显示数量
        if toasts.count > configuration.maxVisibleToasts {
            switch position.insertionBehavior {
            case .top:
                toasts = Array(configuration.reverseOrder ? 
                    toasts.suffix(configuration.maxVisibleToasts) :
                    toasts.prefix(configuration.maxVisibleToasts))
            case .bottom:
                toasts = Array(configuration.reverseOrder ? 
                    toasts.prefix(configuration.maxVisibleToasts) :
                    toasts.suffix(configuration.maxVisibleToasts))
            case .replace:
                toasts = Array(toasts.suffix(1))
            }
        }
        
        toastsByPosition[position] = toasts
    }
    
    public func dismiss(id: String? = nil) {
        if let id = id {
            dismissSpecific(id: id)
        } else {
            dismissAll()
        }
    }
    
    private func dismissSpecific(id: String) {
        // 在所有位置组中查找并删除
        for (position, toasts) in toastsByPosition {
            if let index = toasts.firstIndex(where: { $0.id == id }) {
                let toast = toasts[index]
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    toast.isVisible = false
                }
                
                // 从位置列表中移除
                var updatedToasts = toasts
                updatedToasts.remove(at: index)
                toastsByPosition[position] = updatedToasts.isEmpty ? nil : updatedToasts
                
                // 调用回调
                Task {
                    try await Task.sleep(for: .seconds(0.3))
                    await MainActor.run {
                        toast.onDismiss?()
                    }
                }
                
                break
            }
        }
    }
    
    public func dismissAll() {
        let allToasts = toasts
        
        for toast in allToasts {
            withAnimation(.easeInOut(duration: 0.3)) {
                toast.isVisible = false
            }
            
            toast.onDismiss?()
        }
        
        // 清空所有位置组
        Task {
            try await Task.sleep(for: .seconds(0.3))
            await MainActor.run {
                self.toastsByPosition.removeAll()
            }
        }
    }
    
    // MARK: - Convenience Methods
    public func success(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        show(
            id: id,
            type: .success,
            message: message,
            duration: duration,
            position: position,
            haptic: .success
        )
    }
    
    public func error(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        show(
            id: id,
            type: .error,
            message: message,
            duration: duration,
            position: position,
            haptic: .error
        )
    }
    
    public func info(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        show(
            id: id,
            type: .info,
            message: message,
            duration: duration,
            position: position,
            haptic: .light
        )
    }
    
    public func loading(
        _ message: String,
        id: String = UUID().uuidString,
        position: ToastPosition? = nil
    ) {
        show(
            id: id,
            type: .loading,
            message: message,
            duration: 0, // Loading toasts don't auto-dismiss
            position: position,
            showProgressBar: true
        )
    }
    
    public func custom<Content: View>(
        @ViewBuilder content: () -> Content,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        show(
            id: id,
            type: .custom,
            message: "",
            customView: AnyView(content()),
            duration: duration,
            position: position
        )
    }
    
    // MARK: - Promise Support
    public func promise<T>(
        _ promise: @escaping () async throws -> T,
        messages: ToastPromiseMessages,
        id: String = UUID().uuidString,
        position: ToastPosition? = nil
    ) {
        // Show loading toast
        loading(messages.loading, id: id, position: position)
        
        Task {
            do {
                _ = try await promise()
                // Success
                await MainActor.run {
                    self.dismiss(id: id)
                    self.success(messages.success, id: id + "_success", position: position)
                }
            } catch {
                // Error
                await MainActor.run {
                    self.dismiss(id: id)
                    self.error(messages.error, id: id + "_error", position: position)
                }
            }
        }
    }
    
    // MARK: - Hover Support
    public func pauseToast(id: String) {
        guard let toast = toasts.first(where: { $0.id == id }) else { return }
        toast.pauseTimer()
    }
    
    public func resumeToast(id: String) {
        guard let toast = toasts.first(where: { $0.id == id }) else { return }
        toast.resumeTimer()
    }
}