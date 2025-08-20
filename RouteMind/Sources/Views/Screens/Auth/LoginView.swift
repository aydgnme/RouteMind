import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    // MARK: - Properties
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var emailValidationState: ModernTextField.ValidationState = .none
    @State private var passwordValidationState: ModernTextField.ValidationState = .none

    @State private var isShowRegister = false
    @State private var isShowForgotPassword = false

    // MARK: - Callbacks
    var onBack: () -> Void = {}
    var onLogin: () -> Void = {}
    var onRegister: () -> Void = {}
    var onForgotPassword: () -> Void = {}

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.routePrimary.opacity(0.15),
                    Color.routeBackground,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text("Welcome Back!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.routeTextPrimary)
                        Text("Sign in to continue")
                            .font(.title3)
                            .foregroundStyle(Color.routeTextSecondary)
                    }
                    .padding(.top, 60)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 40)

                    VStack(spacing: 20) {
                        // MARK: - Input Fields
                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .default,
                            validationState: emailValidationState
                        )
                        ModernTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: !showPassword,
                            trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                            onTrailingIconTap: { showPassword.toggle() },
                            validationState: passwordValidationState
                        )
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .padding(.horizontal, 24)
                    .padding(.top, 48)
                    
                    // MARK: - Validation and Error Messages
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 24)
                            .opacity(isAnimating ? 1 : 0)
                            .offset(y: isAnimating ? 0 : 10)
                    }
                    
                    // MARK: - Actions
                    Button("Forgot Password?") {
                        isShowForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)

                    PrimaryButton(
                        title: isLoading ? "Signing In..." : "Sign In",
                        icon: "arrow.right",
                        style: .primary
                    ) {
                        attemptLogin()
                    }
                    .frame(height: 56)
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .disabled(isLoading)
                    
                    // MARK: - Register and Navigation Links
                    HStack {
                        Text("Don't have an account?")
                            .foregroundStyle(Color.routeTextSecondary)
                        Button("Register") {
                            isShowRegister = true
                        }
                        .foregroundStyle(Color.accentColor)
                    }
                    .font(.subheadline)
                    .padding(.bottom, 32)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 10)

                    // 👇 NavigationLink for Register
                    NavigationLink(
                        destination: RegisterView(),
                        isActive: $isShowRegister
                    ) {
                        EmptyView()
                    }

                    // 👇 NavigationLink for ForgotPassword
                    NavigationLink(
                        destination: ForgotPasswordView(),
                        isActive: $isShowForgotPassword
                    ) {
                        EmptyView()
                    }
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
    
    // MARK: - Attempt Login
    private func attemptLogin() {
        
        // Reset validation states
        emailValidationState = .none
        passwordValidationState = .none
        errorMessage = nil
        
        var isValid = true
        
        if email.isEmpty {
            emailValidationState = .invalid
            isValid = false
        } else {
            emailValidationState = .valid
        }
        
        if password.isEmpty {
            passwordValidationState = .invalid
            isValid = false
        } else {
            passwordValidationState = .valid
        }
        
        if !isValid {
            errorMessage = "Please fill in all fields"
            return
        }
        
        isLoading = true
        
        AuthService.shared.signIn(email: email, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    onLogin()
                case .failure(let error):
                    let nsError = error as NSError
                    switch nsError.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        errorMessage = "Incorrect password"
                        passwordValidationState = .invalid
                    case AuthErrorCode.userNotFound.rawValue:
                        errorMessage = "User not found"
                        emailValidationState = .invalid
                    default:
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
