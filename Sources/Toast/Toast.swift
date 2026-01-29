// MARK: - Toast Library
// A lightweight, high-performance Toast system for SwiftUI
// Supports both in-app and macOS desktop display
// API similar to react-hot-toast

import SwiftUI
import Foundation

// MARK: - Main Toast Interface

/// Configuration for all toasts
@MainActor
public var toaster: ToastConfiguration {
    get { ToastManager.shared.configuration }
    set { ToastManager.shared.configuration = newValue }
}

// MARK: - Global Toast Instance
/// 全局 Toast 实例，提供简写API
@MainActor
public let toast = GlobalToast()

/// Global toast instance for simplified API
public struct GlobalToast: Sendable {
    @MainActor
    public func success(_ message: String, duration: TimeInterval? = nil, position: ToastPosition = .topRight) {
        ToastManager.shared.success(message, duration: duration, position: position)
    }
    
    @MainActor
    public func error(_ message: String, duration: TimeInterval? = nil, position: ToastPosition = .topRight) {
        ToastManager.shared.error(message, duration: duration, position: position)
    }
    
    @MainActor
    public func info(_ message: String, duration: TimeInterval? = nil, position: ToastPosition = .topRight) {
        ToastManager.shared.info(message, duration: duration, position: position)
    }
    
    @MainActor
    public func loading(_ message: String, position: ToastPosition = .topRight) {
        ToastManager.shared.loading(message, position: position)
    }
    
    @MainActor
    public func custom<Content: View>(
        duration: TimeInterval? = nil,
        position: ToastPosition = .topRight,
        @ViewBuilder content: @escaping () -> Content
    ) {
        ToastManager.shared.show(
            type: .custom,
            message: "",
            customView: AnyView(content()),
            duration: duration,
            position: position
        )
    }
    
    @MainActor
    public func promise<T>(
        operation: @escaping () async throws -> T,
        messages: ToastPromiseMessages,
        position: ToastPosition = .topRight
    ) {
        ToastManager.shared.promise(operation, messages: messages, position: position)
    }
    
    @MainActor
    public func dismiss(id: String? = nil) {
        ToastManager.shared.dismiss(id: id)
    }
    
    @MainActor
    public func dismissAll() {
        ToastManager.shared.dismissAll()
    }
}

// MARK: - Global Toast Functions
/// 全局 Toast 接口
public struct Toast {
    @MainActor
    public static func success(_ message: String, position: ToastPosition = .topRight) {
        ToastManager.shared.success(message, position: position)
    }
    
    @MainActor
    public static func error(_ message: String, position: ToastPosition = .topRight) {
        ToastManager.shared.error(message, position: position)
    }
    
    @MainActor
    public static func info(_ message: String, position: ToastPosition = .topRight) {
        ToastManager.shared.info(message, position: position)
    }
    
    @MainActor
    public static func loading(_ message: String, position: ToastPosition = .topRight) {
        ToastManager.shared.loading(message, position: position)
    }
    
    @MainActor
    public static func custom<Content: View>(
        @ViewBuilder content: () -> Content,
        id: String = UUID().uuidString,
        duration: TimeInterval? = nil,
        position: ToastPosition = .topRight
    ) {
        ToastManager.shared.custom(
            content: content,
            id: id,
            duration: duration,
            position: position
        )
    }
    
    @MainActor
    public static func promise<T>(
        _ promise: @escaping () async throws -> T,
        messages: ToastPromiseMessages,
        id: String = UUID().uuidString,
        position: ToastPosition = .topRight
    ) {
        ToastManager.shared.promise(
            promise,
            messages: messages,
            id: id,
            position: position
        )
    }
    
    @MainActor
    public static func dismiss(id: String? = nil) {
        ToastManager.shared.dismiss(id: id)
    }
    
    @MainActor
    public static func dismissAll() {
        ToastManager.shared.dismissAll()
    }
}

// MARK: - Example Usage
/*
 
 Basic Usage:
 ```swift
 // Show simple toast
 toast("Hello World")
 
 // Show typed toasts
 toast.success("Success!")
 toast.error("Error occurred")
 toast.info("Information")
 toast.loading("Loading...")
 
 // Dismiss toasts
 toast.dismiss()
 toast.dismissAll()
 ```
 
 Promise Support:
 ```swift
 toast.promise(
     { try await someAsyncOperation() },
     messages: .init(
         loading: "Processing...",
         success: "Completed!",
         error: "Failed!"
     )
 )
 ```
 
 Custom Position:
 ```swift
 toast.success("Success!", position: .topCenter)
 toast.error("Error!", position: .screenTopRight) // Desktop level
 ```
 
 View Integration:
 ```swift
 struct ContentView: View {
     var body: some View {
         VStack {
             Button("Show Toast") {
                 toast("Hello!")
             }
         }
         .toast() // Add toast container
     }
 }
 ```
 
 Configuration:
 ```swift
 // Global configuration
 toaster.position = .topCenter
 toaster.duration = 5.0
 toaster.theme = .dark
 
 // Or pass custom configuration
 .toast(configuration: ToastConfiguration(
     position: .bottomCenter,
     duration: 3.0
 ))
 ```
 
 Custom Toast:
 ```swift
 toast.custom {
     HStack {
         Image(systemName: "star.fill")
         Text("Custom toast!")
     }
     .padding()
     .background(Color.purple)
     .foregroundColor(.white)
     .cornerRadius(8)
 }
 ```
 
 */
