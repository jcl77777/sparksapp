import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var breathingGlowOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // 背景漸層 - Pixel Art Style
            LinearGradient(
                gradient: Gradient(colors: AppDesign.Colors.purpleGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // Logo - Pixel Art Style
                Text("✨")
                    .font(.system(size: 100))
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)

                // 主標題 - Monospaced Font
                Text("Sparks")
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .tracking(4)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 2, y: 2)

                // 副標題
                Text("記下讓你心動的瞬間")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                    .opacity(textOpacity)

                // Pixel Art Loading Bar
                PixelLoadingBar()
                    .opacity(breathingGlowOpacity)
            }
        }
        .onAppear {
            startLaunchAnimation()
        }
    }
    
    private func startLaunchAnimation() {
        // 1. Logo 出現動畫
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1.0
            logoScale = 1.0
        }
        
        // 2. 文字出現動畫 (延遲0.5秒)
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            textOpacity = 1.0
        }
        
        // 3. 呼吸光暈出現 (延遲1.0秒)
        withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
            breathingGlowOpacity = 1.0
        }
        
        // 4. Logo 呼吸動畫開始 (延遲1.2秒)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}

// Pixel Art Loading Bar
struct PixelLoadingBar: View {
    @State private var progress: CGFloat = 0.0
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 8) {
            // Loading Bar Container
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.white, lineWidth: 2)
                    )

                // Progress Fill
                RoundedRectangle(cornerRadius: 1)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200 * progress, height: 4)
                    .padding(.leading, 2)
                    .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 0)
            }

            // Loading Dots
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .opacity(isAnimating ? 1.0 : 0.3)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            // Start progress animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                progress = 1.0
            }

            // Start dot animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}