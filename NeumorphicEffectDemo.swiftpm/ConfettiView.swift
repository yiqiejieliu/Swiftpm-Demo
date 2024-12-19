import SwiftUI
import CoreMotion

struct ConfettiView: View {
    // 添加运动管理器
    @StateObject private var motionManager = MotionManager()
    
    struct Piece: Identifiable {
        let id = UUID()
        var position: CGPoint
        var zPosition: CGFloat
        var rotation: Double
        var rotationSpeed: Double
        var scale: CGFloat
        var color: Color
        var layer: Int
        var motionMultiplier: CGFloat
        var rotationAxis: SIMD3<Float>
    }
    
    @State private var pieces: [Piece] = []
    let pieceCount = 50
    
    // 添加计时器来更新旋转
    @State private var lastUpdate = Date()
    @State private var displayLink: Timer?
    
    var body: some View {
        Canvas { context, size in
            let sortedPieces = pieces.sorted { $0.zPosition > $1.zPosition }
            
            for piece in sortedPieces {
                let tiltX = motionManager.roll * 100 * piece.motionMultiplier
                let tiltY = motionManager.pitch * 100 * piece.motionMultiplier
                
                let perspective = 500.0 / (500.0 + piece.zPosition)
                let projectedScale = piece.scale * perspective
                
                context.opacity = perspective * 0.8
                context.blendMode = .plusLighter
                
                let path = Path { path in
                    let xScale = abs(cos(Float(Double(piece.rotation))) * piece.rotationAxis.x + 1)
                    let yScale = abs(cos(Float(Double(piece.rotation))) * piece.rotationAxis.y + 1)
                    
                    let width = 20.0 * xScale
                    let height = 20.0 * yScale
                    
                    path.move(to: CGPoint(x: Double(-width)/2, y: Double(-height)/2))
                    path.addLine(to: CGPoint(x: Double(width)/2, y: Double(-height)/2))
                    path.addLine(to: CGPoint(x: 0, y: Double(height)/2))
                    path.closeSubpath()
                }
                
                let projectedX = size.width/2 + (piece.position.x - size.width/2 + tiltX) * perspective
                let projectedY = size.height/2 + (piece.position.y - size.height/2 + tiltY) * perspective
                
                var transform = CGAffineTransform.identity
                transform = transform.translatedBy(x: projectedX, y: projectedY)
                
                let rotationAngle = piece.rotation * Double(piece.rotationAxis.z)
                transform = transform.rotated(by: rotationAngle)
                
                transform = transform.scaledBy(x: projectedScale, y: projectedScale)
                
                let transformedPath = path.applying(transform)
                
                let dotProduct = Float(cos(piece.rotation)) * piece.rotationAxis.y
                let brightness = 0.5 + 0.5 * CGFloat(dotProduct)
                let adjustedColor = piece.color.opacity(brightness)
                
                context.fill(transformedPath, with: .color(adjustedColor))
            }
        }
        .onAppear {
            createPieces()
            motionManager.start()
            displayLink = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
                updateRotations()
            }
        }
        .onDisappear {
            motionManager.stop()
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    private func createPieces() {
        pieces = []
        
        // 修改图层配置，增加半径范围
        let layerConfigs = [
            (count: pieceCount/3, radius: CGFloat(200), zRange: CGFloat(-50)...CGFloat(50), motionMultiplier: CGFloat(0.5)),
            (count: pieceCount/3, radius: CGFloat(300), zRange: CGFloat(-100)...CGFloat(100), motionMultiplier: CGFloat(1.0)),
            (count: pieceCount/3, radius: CGFloat(400), zRange: CGFloat(-150)...CGFloat(150), motionMultiplier: CGFloat(1.5))
        ]
        
        // 使用整个屏幕的宽高，而不是中心点
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for (layerIndex, config) in layerConfigs.enumerated() {
            for _ in 0..<config.count {
                // 直接在屏幕范围内随机生成位置，而不是基于中心点和角度
                let x = CGFloat.random(in: 0...screenWidth)
                let y = CGFloat.random(in: 0...screenHeight)
                
                var axis = SIMD3<Float>(
                    Float.random(in: -1...1),
                    Float.random(in: -1...1),
                    Float.random(in: -1...1)
                )
                let length = sqrt(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
                axis = axis / length
                
                let piece = Piece(
                    position: CGPoint(x: x, y: y),
                    zPosition: CGFloat.random(in: config.zRange),
                    rotation: Double.random(in: 0...2 * .pi),
                    rotationSpeed: Double.random(in: 1.0...2.0),
                    scale: CGFloat.random(in: 0.5...1.5),
                    color: [Color.white, Color.blue, Color.purple, Color.pink]
                        .randomElement() ?? .white,
                    layer: layerIndex,
                    motionMultiplier: config.motionMultiplier,
                    rotationAxis: axis
                )
                
                pieces.append(piece)
            }
        }
    }
    
    private func updateRotations() {
        let currentTime = Date()
        let deltaTime = currentTime.timeIntervalSince(lastUpdate)
        lastUpdate = currentTime
        
        for i in pieces.indices {
            // 直接累加旋转角度，不进行任何重置或取模运算
            pieces[i].rotation += pieces[i].rotationSpeed * deltaTime
        }
    }
}

// 添加运动管理器类
class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    
    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion else { return }
            
            self?.pitch = motion.attitude.pitch
            self?.roll = motion.attitude.roll
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        ConfettiView()
    }
} 
