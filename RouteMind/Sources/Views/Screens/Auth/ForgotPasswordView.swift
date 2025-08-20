import SwiftUI

struct ForgotPasswordView: View {

    // MARK: - State Properties
    @State private var email = ""
    @State private var emailValidation: ModernTextField.ValidationState = .none
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var message: String? = nil
    @State private var isSuccess = false

    // MARK: - Callbacks
    var onBack: () -> Void = {}
    var onResetSent: () -> Void = {}

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.routePrimary.opacity(0.15),
                    Color.routeBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.routeTextPrimary)
                        Text("Enter your email to receive reset instructions")
                            .font(.title3)
                            .foregroundStyle(Color.routeTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 40)

                    VStack(spacing: 20) {
                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            validationState: emailValidation
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)

                    if let message = message {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(isSuccess ? Color.green : Color.red)
                            .padding(.horizontal, 24)
                            .opacity(isAnimating ? 1 : 0)
                    }

                    PrimaryButton(
                        title: isLoading ? "Sending..." : "Send Reset Link",
                        icon: "paperplane.fill",
                        style: .primary
                    ) {
                        sendResetLink()
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)
                    .disabled(isLoading)
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Color.routeTextPrimary)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }

    // MARK: - Logic
    private func sendResetLink() {
        emailValidation = .none
        message = nil
        isSuccess = false

        guard !email.isEmpty, email.contains("@") else {
            emailValidation = .invalid
            message = "Please enter a valid email address."
            return
        }

        emailValidation = .valid
        isLoading = true

        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false

            if email == "test@example.com" {
                isSuccess = true
                message = "A reset link has been sent to your email."
                onResetSent()
            } else {
                message = "Email not found. Please try again."
                emailValidation = .invalid
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
