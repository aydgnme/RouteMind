import SwiftUI

struct RegisterView: View {
    
    // MARK: - Properties
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var isAnimating = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @State private var nameValidation: ModernTextField.ValidationState = .none
    @State private var emailValidation: ModernTextField.ValidationState = .none
    @State private var passwordValidation: ModernTextField.ValidationState = .none
    @State private var confirmPasswordValidation: ModernTextField.ValidationState = .none

    // MARK: - Callbacks
    var onBack: () -> Void = {}
    var onRegisterSuccess: () -> Void = {}

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
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.routeTextPrimary)
                        Text("Join us by filling the form below")
                            .font(.title3)
                            .foregroundStyle(Color.routeTextSecondary)
                    }
                    .padding(.top, 60)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 40)

                    VStack(spacing: 20) {
                        ModernTextField(
                            icon: "person.fill",
                            placeholder: "Full Name",
                            text: $fullName,
                            validationState: nameValidation
                        )

                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "Email",
                            text: $email,
                            keyboardType: .emailAddress,
                            validationState: emailValidation
                        )

                        ModernTextField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $password,
                            isSecure: !showPassword,
                            trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                            onTrailingIconTap: { showPassword.toggle() },
                            validationState: passwordValidation
                        )

                        ModernTextField(
                            icon: "lock.fill",
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: !showConfirmPassword,
                            trailingIcon: showConfirmPassword ? "eye.slash.fill" : "eye.fill",
                            onTrailingIconTap: { showConfirmPassword.toggle() },
                            validationState: confirmPasswordValidation
                        )
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    if let error = errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 24)
                            .opacity(isAnimating ? 1 : 0)
                    }

                    PrimaryButton(
                        title: isLoading ? "Registering..." : "Register",
                        icon: "checkmark",
                        style: .primary
                    ) {
                        attemptRegistration()
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

    // MARK: - Registration Logic
    private func attemptRegistration() {
        // Reset validations
        nameValidation = .none
        emailValidation = .none
        passwordValidation = .none
        confirmPasswordValidation = .none
        errorMessage = nil

        var isValid = true

        if fullName.isEmpty {
            nameValidation = .invalid
            isValid = false
        } else {
            nameValidation = .valid
        }

        if !email.contains("@") || email.isEmpty {
            emailValidation = .invalid
            isValid = false
        } else {
            emailValidation = .valid
        }

        if password.count < 6 {
            passwordValidation = .invalid
            isValid = false
        } else {
            passwordValidation = .valid
        }

        if confirmPassword != password || confirmPassword.isEmpty {
            confirmPasswordValidation = .invalid
            isValid = false
        } else {
            confirmPasswordValidation = .valid
        }

        if !isValid {
            errorMessage = "Please fix the highlighted fields."
            return
        }

        // Simulate registration
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
            onRegisterSuccess()
        }
    }
}

#Preview {
    RegisterView()
}
