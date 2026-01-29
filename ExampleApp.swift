import SwiftUI
import Toast

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toast() // 启用 Toast 容器
        }
    }
}

struct ContentView: View {
    @State private var showBindingToast = false
    @State private var counter = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Toast 列表式演示")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // 推挤动画演示
                Section("推挤动画演示") {
                    VStack(spacing: 12) {
                        Button("Top 推挤 (连续3个)") {
                            for i in 1...3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                                    toast.success("Top 消息 #\(i)", position: .topCenter)
                                }
                            }
                        }
                        
                        Button("Bottom 推挤 (连续3个)") {
                            for i in 1...3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                                    toast.info("Bottom 消息 #\(i)", position: .bottomCenter)
                                }
                            }
                        }
                        
                        Button("混合位置测试") {
                            toast.success("顶部成功", position: .topRight)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                toast.error("底部错误", position: .bottomLeft)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                toast.info("中心信息", position: .center)
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                // 基础 Toast 类型
                Section("基础 Toast 类型") {
                    VStack(spacing: 12) {
                        Button("成功消息") {
                            counter += 1
                            toast.success("操作成功 #\(counter)！")
                        }
                        
                        Button("错误消息") {
                            counter += 1
                            toast.error("发生错误 #\(counter)")
                        }
                        
                        Button("信息消息") {
                            counter += 1
                            toast.info("提示信息 #\(counter)")
                        }
                        
                        Button("加载消息") {
                            counter += 1
                            toast.loading("加载中... #\(counter)")
                        }
                    }
                }
                .buttonStyle(.bordered)
                
                // 位置测试
                Section("位置测试") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                        ForEach(ToastPosition.allInAppCases, id: \.self) { position in
                            Button(positionName(position)) {
                                toast.info("测试 \(positionName(position))", position: position)
                            }
                            .buttonStyle(.bordered)
                            .font(.caption)
                        }
                    }
                }
                
                // 桌面级通知
                Section("桌面级推挤演示") {
                    VStack(spacing: 12) {
                        Button("桌面Top推挤 (连续3个)") {
                            for i in 1...3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                                    toast.success("桌面Top #\(i)", position: .screenTopRight)
                                }
                            }
                        }
                        
                        Button("桌面Bottom推挤 (连续3个)") {
                            for i in 1...3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                                    toast.info("桌面Bottom #\(i)", position: .screenBottomRight)
                                }
                            }
                        }
                        
                        Button("桌面Center列表") {
                            for i in 1...3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                                    Toast.custom(
                                        content: {
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text("桌面中心 #\(i)")
                                            }
                                            .padding()
                                            .background(Color.purple)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                        },
                                        position: .screenCenter
                                    )
                                }
                            }
                        }
                        
                        Button("屏幕顶部右侧") {
                            toast.success("桌面通知！", position: .screenTopRight)
                        }
                        
                        Button("屏幕中心") {
                            toast.info("屏幕中心通知", position: .screenCenter)
                        }
                        
                        Button("屏幕底部") {
                            toast.error("屏幕底部通知", position: .screenBottomCenter)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                
                // Promise 演示
                Section("Promise 演示") {
                    VStack(spacing: 12) {
                        Button("异步成功") {
                            toast.promise(
                                { 
                                    try await Task.sleep(for: .seconds(2))
                                    return "成功!"
                                },
                                messages: .init(
                                    loading: "处理中...",
                                    success: "处理完成!",
                                    error: "处理失败!"
                                )
                            )
                        }
                        
                        Button("异步失败") {
                            toast.promise(
                                { 
                                    try await Task.sleep(for: .seconds(1.5))
                                    throw NSError(domain: "Demo", code: 1)
                                },
                                messages: .init(
                                    loading: "尝试操作...",
                                    success: "成功!",
                                    error: "操作失败!"
                                )
                            )
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                
                // 自定义 Toast
                Section("自定义 Toast") {
                    Button("自定义设计") {
                        toast.custom {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading) {
                                    Text("自定义 Toast!")
                                        .fontWeight(.bold)
                                    Text("这是一个自定义设计的消息")
                                        .font(.caption)
                                        .opacity(0.8)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                // 控制按钮
                Section("控制") {
                    VStack(spacing: 12) {
                        Button("连续多个消息 (同位置)") {
                            for i in 1...5 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                                    toast.info("消息 #\(i)")
                                }
                            }
                        }
                        
                        Button("清除所有") {
                            toast.dismissAll()
                        }
                        .tint(.red)
                        
                        Toggle("绑定 Toast", isOn: $showBindingToast)
                    }
                }
                .buttonStyle(.bordered)
                
                // 配置控制
                Section("配置演示") {
                    VStack(spacing: 12) {
                        Button("更改全局位置") {
                            Task { @MainActor in
                                let positions: [ToastPosition] = [.topLeft, .topCenter, .topRight, .bottomLeft, .bottomCenter, .bottomRight]
                                toaster.position = positions.randomElement() ?? .topRight
                                toast.info("位置已更改!")
                            }
                        }
                        
                        Button("切换主题") {
                            Task { @MainActor in
                                toaster.theme = toaster.theme == .light ? .dark : .light
                                toast.info("主题已切换!")
                            }
                        }
                        
                        Button("重置配置") {
                            Task { @MainActor in
                                toaster = .default
                                toast.success("配置已重置!")
                            }
                        }
                    }
                }
                .buttonStyle(.bordered)
                .tint(.gray)
            }
            .padding()
        }
        .toast(
            isPresented: $showBindingToast,
            type: .success,
            message: "这个 Toast 绑定到状态!"
        )
    }
    
    private func positionName(_ position: ToastPosition) -> String {
        switch position {
        case .topLeft: return "左上"
        case .topCenter: return "顶部"
        case .topRight: return "右上"
        case .bottomLeft: return "左下"
        case .bottomCenter: return "底部"
        case .bottomRight: return "右下"
        case .center: return "中心"
        case .absolute: return "绝对"
        default: return "其他"
        }
    }
}

// MARK: - Section Helper
private struct Section<Content: View>: View {
    let title: String
    let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .toast()
}