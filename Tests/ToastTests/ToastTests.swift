import Testing
import SwiftUI
@testable import Toast

@MainActor
@Test func testToastCreation() async throws {
    let toastManager = ToastManager.shared
    let message = "Test message"
    
    toastManager.show(type: .info, message: message)
    
    #expect(toastManager.toasts.count == 1)
    #expect(toastManager.toasts.first?.message == message)
    #expect(toastManager.toasts.first?.type == .info)
    
    // Cleanup
    toastManager.dismissAll()
}

@MainActor
@Test func testToastTypes() async throws {
    let toastManager = ToastManager.shared
    
    toastManager.success("Success message")
    toastManager.error("Error message") 
    toastManager.info("Info message")
    toastManager.loading("Loading message")
    
    #expect(toastManager.toasts.count == 4)
    
    let types = toastManager.toasts.map { $0.type }
    #expect(types.contains(.success))
    #expect(types.contains(.error))
    #expect(types.contains(.info))
    #expect(types.contains(.loading))
    
    // Cleanup
    toastManager.dismissAll()
}

@MainActor
@Test func testToastConfiguration() async throws {
    let toastManager = ToastManager.shared
    let originalConfig = toastManager.configuration
    
    let config = ToastConfiguration(
        position: .bottomCenter,
        duration: 5.0,
        reverseOrder: true,
        maxVisibleToasts: 3
    )
    
    toastManager.configuration = config
    
    #expect(toastManager.configuration.duration == 5.0)
    #expect(toastManager.configuration.reverseOrder == true)
    #expect(toastManager.configuration.maxVisibleToasts == 3)
    
    // Restore
    toastManager.configuration = originalConfig
}

@Test func testToastPositionTypes() async throws {
    #expect(!ToastPosition.topLeft.isDesktopLevel)
    #expect(!ToastPosition.bottomRight.isDesktopLevel)
    #expect(ToastPosition.screenTopLeft.isDesktopLevel)
    #expect(ToastPosition.screenBottomRight.isDesktopLevel)
}

@Test func testToastStyles() async throws {
    let style = ToastStyle(
        backgroundColor: .red,
        foregroundColor: .white,
        cornerRadius: 12,
        padding: EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
    )
    
    #expect(style.backgroundColor == .red)
    #expect(style.foregroundColor == .white)
    #expect(style.cornerRadius == 12)
}

@Test func testPromiseMessages() async throws {
    let messages = ToastPromiseMessages(
        loading: "Loading...",
        success: "Success!",
        error: "Error!"
    )
    
    #expect(messages.loading == "Loading...")
    #expect(messages.success == "Success!")
    #expect(messages.error == "Error!")
}
