import SwiftUI

struct LottieView: UIViewRepresentable {
    
    // Properties to hold the animation name, loop mode, and speed
    let animationName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    // Initializer to set up the animation parameters
    init(animationName: String, loopMode: LottieLoopMode = .loop, animationSpeed: CGFloat = 1.0) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
    }
    
    // Create a UIView that will hold the Lottie animation
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // Note: In a real implementation, you would use the Lottie library
        // For now, we'll create a placeholder view
        let placeholderView = createPlaceholderView()
        view.addSubview(placeholderView)
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderView.widthAnchor.constraint(equalTo: view.widthAnchor),
            placeholderView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the view if needed
    }
    
    // Create a placeholder view to simulate the Lottie animation
    private func createPlaceholderView() -> UIView {
        let placeholderView = UIView()
        placeholderView.backgroundColor = UIColor.systemGray5
        
        let label = UILabel()
        label.text = "🎬 \(animationName)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.systemGray
        
        placeholderView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
        ])
        
        return placeholderView
    }
}

// Placeholder for LottieLoopMode enum
enum LottieLoopMode {
    case loop
    case playOnce
    case autoReverse
}

// SwiftUI wrapper for easier use
struct LottieAnimationView: View {
    let animationName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    var body: some View {
        LottieView(
            animationName: animationName,
            loopMode: loopMode,
            animationSpeed: animationSpeed
        )
    }
}

// Predefined animations
struct LoadingAnimation: View {
    var body: some View {
        LottieAnimationView(
            animationName: "loading",
            loopMode: .loop,
            animationSpeed: 1.0
        )
        .frame(width: 100, height: 100)
    }
}

struct SuccessAnimation: View {
    var body: some View {
        LottieAnimationView(
            animationName: "success",
            loopMode: .playOnce,
            animationSpeed: 1.0
        )
        .frame(width: 80, height: 80)
    }
}

struct ErrorAnimation: View {
    var body: some View {
        LottieAnimationView(
            animationName: "error",
            loopMode: .playOnce,
            animationSpeed: 1.0
        )
        .frame(width: 80, height: 80)
    }
}

struct EmptyStateAnimation: View {
    var body: some View {
        LottieAnimationView(
            animationName: "empty_state",
            loopMode: .loop,
            animationSpeed: 0.8
        )
        .frame(width: 200, height: 200)
    }
}
