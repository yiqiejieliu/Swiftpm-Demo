//
//  NeumorphicConcaveView.swift
//  NeumorphicEffectDemo
//
//  Created by huo huo on 2024/12/16.
//

import SwiftUI

// 存储新拟物效果的参数
struct NeumorphicEffectParameters {
    // 内凹效果参数
    var concaveOpacity: Double = 0.25
    var concaveGradientLocation: Double = 0.5
    
    // 顶部光影参数
    var topLightOpacity: Double = 0.2
    
    // 边缘高光参数
    var edgeHighlightOpacity: Double = 0.5
    var edgeLineWidth: Double = 0.5
    
    // 外部阴影参数
    var outerShadowRadius: Double = 20
    var outerShadowOffset: Double = 20
    
    // 内部阴影参数
    var innerShadowOpacity: Double = 0.1
    var innerShadowOffset: Double = 2
    var innerShadowBlur: Double = 4
    
    // 225度渐变光效参数
    var gradientLightOpacity: Double = 0.1
}

struct NeumorphicConcaveView: View {
    @State private var parameters = NeumorphicEffectParameters()
    @State private var showControls = false
    
    var body: some View {
        VStack {
            // 主视图
            effectView
                .frame(width: 200, height: 200)
                .padding(.top,50)
            
            // 控制面板
            Toggle("显示控制面板", isOn: $showControls)
                .padding()
            
            if showControls {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // 内凹效果控制
                        GroupBox("内凹效果") {
                            VStack {
                                SliderView(value: $parameters.concaveOpacity,
                                         title: "不透明度",
                                         range: 0...1)
                                SliderView(value: $parameters.concaveGradientLocation,
                                         title: "渐变位置",
                                         range: 0...1)
                            }
                        }
                        
                        // 顶部光影控制
                        GroupBox("顶部光影") {
                            SliderView(value: $parameters.topLightOpacity,
                                     title: "不透明度",
                                     range: 0...1)
                        }
                        
                        // 边缘高光控制
                        GroupBox("边缘高光") {
                            VStack {
                                SliderView(value: $parameters.edgeHighlightOpacity,
                                         title: "不透明度",
                                         range: 0...1)
                                SliderView(value: $parameters.edgeLineWidth,
                                         title: "线宽",
                                         range: 0...2)
                            }
                        }
                        
                        // 外部阴影控制
                        GroupBox("外部阴影") {
                            VStack {
                                SliderView(value: $parameters.outerShadowRadius,
                                         title: "阴影半径",
                                         range: 0...40)
                                SliderView(value: $parameters.outerShadowOffset,
                                         title: "阴影偏移",
                                         range: 0...40)
                            }
                        }
                        
                        // 内部阴影控制
                        GroupBox("内部阴影") {
                            VStack {
                                SliderView(value: $parameters.innerShadowOpacity,
                                         title: "不透明度",
                                         range: 0...1)
                                SliderView(value: $parameters.innerShadowOffset,
                                         title: "偏移",
                                         range: 0...10)
                                SliderView(value: $parameters.innerShadowBlur,
                                         title: "模糊",
                                         range: 0...10)
                            }
                        }
                        
                        // 225度渐变光效控制
                        GroupBox("渐变光效") {
                            SliderView(value: $parameters.gradientLightOpacity,
                                     title: "不透明度",
                                     range: 0...1)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    // 主效果视图
    private var effectView: some View {
        RoundedRectangle(cornerRadius: 34)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "cacaca"),
                        Color(hex: "f0f0f0")
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            // 内凹效果
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.black.opacity(parameters.concaveOpacity), location: 0),
                                .init(color: Color.clear, location: parameters.concaveGradientLocation),
                                .init(color: Color.white.opacity(0.1), location: 1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            // 顶部光影
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(parameters.topLightOpacity),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            )
            // 边缘高光
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(parameters.edgeHighlightOpacity),
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: parameters.edgeLineWidth
                    )
            )
            // 外部阴影
            .shadow(color: .white.opacity(0.9),
                   radius: parameters.outerShadowRadius,
                   x: -parameters.outerShadowOffset,
                   y: -parameters.outerShadowOffset)
            .shadow(color: Color.black.opacity(0.2),
                   radius: parameters.outerShadowRadius,
                   x: parameters.outerShadowOffset,
                   y: parameters.outerShadowOffset)
            // 内部阴影
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .stroke(Color.black.opacity(parameters.innerShadowOpacity),
                           lineWidth: 1)
                    .blur(radius: parameters.innerShadowBlur)
                    .offset(x: parameters.innerShadowOffset,
                           y: parameters.innerShadowOffset)
                    .mask(
                        RoundedRectangle(cornerRadius: 34)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black, .clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            // 225度渐变光效
            .overlay(
                RoundedRectangle(cornerRadius: 34)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(parameters.gradientLightOpacity),
                                Color.clear
                            ]),
                            startPoint: UnitPoint(x: 0.2, y: 0.2),
                            endPoint: UnitPoint(x: 0.8, y: 0.8)
                        )
                    )
            )
    }
}

// 滑块组件
struct SliderView: View {
    @Binding var value: Double
    let title: String
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title): \(value, specifier: "%.2f")")
            Slider(value: $value, in: range)
        }
    }
}

// 颜色扩展保持不变
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NeumorphicConcaveView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "e0e0e0"))
}
