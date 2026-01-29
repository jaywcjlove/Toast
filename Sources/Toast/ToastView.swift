import SwiftUI

// MARK: - Toast View
public struct ToastView: View {
    @ObservedObject var toast: ToastItem
    let configuration: ToastConfiguration
    @Environment(\.toastManager) private var manager
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isHovered = false
    @State private var dragOffset: CGSize = .zero
    
    public init(toast: ToastItem, configuration: ToastConfiguration) {
        self.toast = toast
        self.configuration = configuration
    }
    
    public var body: some View {
        Group {
            if let customView = toast.customView {
                customView
            } else {
                defaultToastContent
            }
        }
        .opacity(toast.isVisible ? 1 : 0)
        .scaleEffect(toast.isVisible ? (isHovered ? 1.02 : 1.0) : 0.8)
        .offset(dragOffset)
        .onTapGesture {
            if toast.closeOnTap {
                withAnimation {
                    manager?.dismiss(id: toast.id)
                }
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
            
            if configuration.pauseOnHover {
                if hovering {
                    toast.pauseTimer()
                } else {
                    toast.resumeTimer()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    if abs(value.translation.width) > 100 || abs(value.translation.height) > 50 {
                        withAnimation(.spring()) {
                            manager?.dismiss(id: toast.id)
                        }
                    } else {
                        withAnimation(.spring()) {
                            dragOffset = .zero
                        }
                    }
                }
        )
    }
    
    @ViewBuilder
    private var defaultToastContent: some View {
        HStack(spacing: 12) {
            // Icon
            if let icon = toast.icon {
                icon
                    .foregroundColor(toast.type.defaultColor)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
            }
            
            // Loading indicator for loading type
            if toast.type == .loading {
                ProgressView()
                    .scaleEffect(0.8)
                    .frame(width: 16, height: 16)
            }
            
            // Message
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(effectiveForegroundColor)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            Spacer(minLength: 0)
            
            // Close button
            if configuration.closeButton {
                Button(action: {
                    manager?.dismiss(id: toast.id)
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(effectiveForegroundColor.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 16, height: 16)
            }
        }
        .padding(effectivePadding)
        .background(effectiveBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: effectiveCornerRadius)
                .stroke(effectiveBorderColor, lineWidth: effectiveBorderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: effectiveCornerRadius))
        .shadow(
            color: Color.black.opacity(0.1),
            radius: effectiveShadowRadius,
            x: effectiveShadowOffset.width,
            y: effectiveShadowOffset.height
        )
        .overlay(
            progressBar,
            alignment: .bottom
        )
        .frame(maxWidth: 400)
    }
    
    @ViewBuilder
    private var progressBar: some View {
        if toast.showProgressBar && toast.type == .loading {
            VStack {
                Spacer()
                Rectangle()
                    .fill(toast.type.defaultColor)
                    .frame(height: 2)
                    .opacity(0.3)
                    .overlay(
                        Rectangle()
                            .fill(toast.type.defaultColor)
                            .frame(width: progressBarWidth)
                            .animation(.linear(duration: 0.1), value: toast.progress),
                        alignment: .leading
                    )
            }
        } else if toast.showProgressBar && toast.progress > 0 {
            VStack {
                Spacer()
                Rectangle()
                    .fill(toast.type.defaultColor)
                    .frame(height: 2)
                    .opacity(0.3)
                    .overlay(
                        Rectangle()
                            .fill(toast.type.defaultColor)
                            .frame(width: progressBarWidth)
                            .animation(.linear(duration: 0.1), value: toast.progress),
                        alignment: .leading
                    )
            }
        }
    }
    
    private var progressBarWidth: CGFloat {
        return 400 * toast.progress // Assuming max width of 400
    }
    
    // MARK: - Style Properties
    private var effectiveTheme: ToastTheme {
        configuration.theme == .system ? (colorScheme == .dark ? .dark : .light) : configuration.theme
    }
    
    private var effectiveBackgroundColor: Color {
        if let backgroundColor = toast.style?.backgroundColor {
            return backgroundColor
        }
        if let backgroundColor = configuration.containerStyle.backgroundColor {
            return backgroundColor
        }
        
        switch effectiveTheme {
        case .light:
            return Color(NSColor.controlBackgroundColor)
        case .dark:
            return Color(NSColor.controlBackgroundColor)
        case .system:
            return Color(NSColor.controlBackgroundColor)
        }
    }
    
    private var effectiveForegroundColor: Color {
        if let foregroundColor = toast.style?.foregroundColor {
            return foregroundColor
        }
        if let foregroundColor = configuration.containerStyle.foregroundColor {
            return foregroundColor
        }
        
        switch effectiveTheme {
        case .light:
            return .primary
        case .dark:
            return .primary
        case .system:
            return .primary
        }
    }
    
    private var effectiveBorderColor: Color {
        if let borderColor = toast.style?.borderColor {
            return borderColor
        }
        if let borderColor = configuration.containerStyle.borderColor {
            return borderColor
        }
        return Color.clear
    }
    
    private var effectiveBorderWidth: CGFloat {
        if let borderWidth = toast.style?.borderWidth {
            return borderWidth
        }
        if let borderWidth = configuration.containerStyle.borderWidth {
            return borderWidth
        }
        return 0
    }
    
    private var effectiveCornerRadius: CGFloat {
        if let cornerRadius = toast.style?.cornerRadius {
            return cornerRadius
        }
        if let cornerRadius = configuration.containerStyle.cornerRadius {
            return cornerRadius
        }
        return 8
    }
    
    private var effectiveShadowRadius: CGFloat {
        if let shadowRadius = toast.style?.shadowRadius {
            return shadowRadius
        }
        if let shadowRadius = configuration.containerStyle.shadowRadius {
            return shadowRadius
        }
        return 4
    }
    
    private var effectiveShadowOffset: CGSize {
        if let shadowOffset = toast.style?.shadowOffset {
            return shadowOffset
        }
        if let shadowOffset = configuration.containerStyle.shadowOffset {
            return shadowOffset
        }
        return CGSize(width: 0, height: 2)
    }
    
    private var effectivePadding: EdgeInsets {
        if let padding = toast.style?.padding {
            return padding
        }
        if let padding = configuration.containerStyle.padding {
            return padding
        }
        return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    }
}

// MARK: - Toast Container View
public struct ToastContainerView: View {
    let position: ToastPosition
    let configuration: ToastConfiguration
    @State private var toastManager = ToastManager.shared
    
    public init(position: ToastPosition, configuration: ToastConfiguration = .default) {
        self.position = position
        self.configuration = configuration
    }
    
    public var body: some View {
        let toasts = toastManager.toasts(for: position)
        
        if !toasts.isEmpty {
            VStack(spacing: configuration.gutter) {
                ForEach(toasts) { toast in
                    ToastView(toast: toast, configuration: configuration)
                        .transition(transitionForPosition(position))
                        .id(toast.id)
                }
            }
            .animation(
                configuration.enablePushAnimation ? 
                    .spring(response: configuration.animationDuration, dampingFraction: 0.8) : 
                    .easeInOut(duration: configuration.animationDuration), 
                value: toasts.map(\.id)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignmentForPosition(position))
            .padding(edgeInsetsForPosition(position))
            .allowsHitTesting(true)
        }
    }
    
    private func transitionForPosition(_ position: ToastPosition) -> AnyTransition {
        switch position.insertionBehavior {
        case .top:
            // Top位置：从上方滑入，推挤效果
            return .asymmetric(
                insertion: .offset(y: -50).combined(with: .opacity),
                removal: .opacity.combined(with: .offset(y: -20))
            )
        case .bottom:
            // Bottom位置：从下方滑入，推挤效果
            return .asymmetric(
                insertion: .offset(y: 50).combined(with: .opacity),
                removal: .opacity.combined(with: .offset(y: 20))
            )
        case .replace:
            // Center位置：标准淡入淡出
            return .asymmetric(
                insertion: .scale(scale: 0.8).combined(with: .opacity),
                removal: .opacity.combined(with: .scale(scale: 0.9))
            )
        }
    }
    
    private func alignmentForPosition(_ position: ToastPosition) -> Alignment {
        switch position {
        case .topLeft:
            return .topLeading
        case .topCenter:
            return .top
        case .topRight:
            return .topTrailing
        case .bottomLeft:
            return .bottomLeading
        case .bottomCenter:
            return .bottom
        case .bottomRight:
            return .bottomTrailing
        case .center:
            return .center
        case .absolute:
            return .center
        }
    }
    
    private func edgeInsetsForPosition(_ position: ToastPosition) -> EdgeInsets {
        let offset = configuration.offset
        let padding: CGFloat = 16
        
        switch position {
        case .topLeft, .topCenter, .topRight:
            return EdgeInsets(
                top: padding + offset.height,
                leading: padding + offset.width,
                bottom: 0,
                trailing: padding - offset.width
            )
        case .bottomLeft, .bottomCenter, .bottomRight:
            return EdgeInsets(
                top: 0,
                leading: padding + offset.width,
                bottom: padding - offset.height,
                trailing: padding - offset.width
            )
        case .center:
            return EdgeInsets(
                top: offset.height,
                leading: offset.width,
                bottom: -offset.height,
                trailing: -offset.width
            )
        case .absolute:
            return EdgeInsets()
        }
    }
}