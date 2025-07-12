import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var breathingGlowOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/圖示
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                
                // 主標題
                Text("Sparks")
                    .font(.custom("HelveticaNeue-Light", size: 34))
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                    .tracking(2)
                
                // 呼吸光暈效果
                BreathingGlowView()
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

// 適用於 Launch Screen 的簡化呼吸光暈組件
struct BreathingGlowView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 外層光暈
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 140, height: 12)
                .opacity(isAnimating ? 0.6 : 0.1)
                .scaleEffect(x: isAnimating ? 1.2 : 0.8, y: isAnimating ? 1.3 : 0.9)
                .blur(radius: 12)
            
            // 中層光暈
            RoundedRectangle(cornerRadius: 2.5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 130, height: 10)
                .opacity(isAnimating ? 0.5 : 0.15)
                .scaleEffect(x: isAnimating ? 1.15 : 0.8, y: isAnimating ? 1.2 : 0.95)
                .blur(radius: 6)
            
            // 主體線條
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.white.opacity(0.9)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 120, height: 4)
                .opacity(isAnimating ? 0.9 : 0.5)
                .scaleEffect(x: isAnimating ? 1.0 : 0.85, y: 1)
                .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 0)
        }
        .onAppear {
            // 延遲開始呼吸動畫，讓整體 Launch Screen 動畫更順暢
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating.toggle()
                }
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}