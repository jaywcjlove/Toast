import SwiftUI

// MARK: - Environment Key
private struct ToastManagerKey: EnvironmentKey {
    static let defaultValue: ToastManager? = nil
}

public extension EnvironmentValues {
    var toastManager: ToastManager? {
        get { self[ToastManagerKey.self] }
        set { self[ToastManagerKey.self] = newValue }
    }
}

// MARK: - View Extension for Toast Environment
public extension View {
    /// Adds toast environment to the view hierarchy
    func toastEnvironment(manager: ToastManager = ToastManager.shared) -> some View {
        self.environment(\.toastManager, manager)
    }
    
    /// Adds toast container overlay to display toasts
    func toast(
        configuration: ToastConfiguration = .default,
        manager: ToastManager = ToastManager.shared
    ) -> some View {
        self
            .environment(\.toastManager, manager)
            .overlay(
                // 为所有应用内位置创建容器
                ZStack {
                    ForEach(ToastPosition.allCases, id: \.self) { position in
                        ToastContainerView(position: position, configuration: configuration)
                            .environment(\.toastManager, manager)
                    }
                }
                .allowsHitTesting(false)
            )
            .onAppear {
                Task { @MainActor in
                    manager.configuration = configuration
                }
            }
    }
    
    /// Shows a toast with binding
    func toast<Content: View>(
        isPresented: Binding<Bool>,
        type: ToastType = .info,
        message: String,
        position: ToastPosition? = nil,
        duration: TimeInterval? = nil,
        @ViewBuilder content: @escaping () -> Content = { EmptyView() }
    ) -> some View {
        self.onChange(of: isPresented.wrappedValue) { _, newValue in
            if newValue {
                let manager = ToastManager.shared
                let customView = content()
                
                if customView is EmptyView {
                    manager.show(
                        type: type,
                        message: message,
                        duration: duration,
                        position: position,
                        onDismiss: {
                            isPresented.wrappedValue = false
                        }
                    )
                } else {
                    manager.custom(
                        content: { content() },
                        duration: duration,
                        position: position
                    )
                }
            }
        }
    }
}

// MARK: - Global Toast Functions

// MARK: - Global Toast Function has been moved to Toast.swift

// MARK: - Toast Manager Extension for Global Access
public extension ToastManager {
    /// Global toast function
    static func toast(
        _ message: String,
        type: ToastType = .info,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        shared.show(
            id: id,
            type: type,
            message: message,
            duration: duration,
            position: position
        )
    }
    
    /// Global success toast
    static func success(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        shared.success(message, id: id, duration: duration, position: position)
    }
    
    /// Global error toast
    static func error(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        shared.error(message, id: id, duration: duration, position: position)
    }
    
    /// Global info toast
    static func info(
        _ message: String,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        shared.info(message, id: id, duration: duration, position: position)
    }
    
    /// Global loading toast
    static func loading(
        _ message: String,
        id: String = UUID().uuidString,
        position: ToastPosition? = nil
    ) {
        shared.loading(message, id: id, position: position)
    }
    
    /// Global promise toast
    static func promise<T>(
        _ promise: @escaping () async throws -> T,
        messages: ToastPromiseMessages,
        id: String = UUID().uuidString,
        position: ToastPosition? = nil
    ) {
        shared.promise(promise, messages: messages, id: id, position: position)
    }
    
    /// Global custom toast
    static func custom<Content: View>(
        @ViewBuilder content: () -> Content,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition? = nil
    ) {
        shared.custom(content: content, id: id, duration: duration, position: position)
    }
    
    /// Global dismiss
    static func dismiss(id: String? = nil) {
        shared.dismiss(id: id)
    }
    
    /// Global dismiss all
    static func dismissAll() {
        shared.dismissAll()
    }
}

// MARK: - Swipe to Dismiss Gesture
struct SwipeToDismissModifier: ViewModifier {
    let toast: ToastItem
    let onDismiss: () -> Void
    
    @GestureState private var dragOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .offset(x: dragOffset.width)
            .opacity(1 - abs(Double(dragOffset.width)) / 200.0)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        if abs(value.translation.width) > 100 {
                            onDismiss()
                        }
                    }
            )
    }
}

public extension View {
    func swipeToDismiss(toast: ToastItem, onDismiss: @escaping () -> Void) -> some View {
        self.modifier(SwipeToDismissModifier(toast: toast, onDismiss: onDismiss))
    }
}