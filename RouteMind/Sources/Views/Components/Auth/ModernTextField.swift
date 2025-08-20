import SwiftUI

struct ModernTextField: View {
    
    // MARK: - Properties
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var trailingIcon: String? = nil
    var onTrailingIconTap: (() -> Void)? = nil
    var validationState: ValidationState = .none
    

    // MARK: - Validation State Enum
    enum ValidationState {
        case none
        case valid
        case invalid
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
            if let trailingIcon = trailingIcon, let action = onTrailingIconTap {
                Button(action: action) {
                    Image(systemName: trailingIcon)
                        .foregroundColor(.secondary)
                }
            }
            if validationState != .none {
                Image(systemName: validationIcon)
                    .foregroundColor(validationColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Private Computed Properties
    private var iconColor: Color {
        switch validationState {
        case .invalid:
            return Color.red
        default:
            return Color.accentColor
        }
    }

    // MARK: - Computed Properties for Validation
    private var validationIcon: String {
        switch validationState {
        case .valid:
            return "checkmark.circle.fill"
        case .invalid:
            return "xmark.circle.fill"
        case .none:
            return ""
        }
    }

    private var validationColor: Color {
        switch validationState {
        case .valid:
            return Color.green
        case .invalid:
            return Color.red
        case .none:
            return Color.clear
        }
    }

    // MARK: - Color Computed Propertiess
    private var backgroundColor: Color {
        Color(.secondarySystemBackground)
    }

    private var borderColor: Color {
        switch validationState {
        case .valid:
            return Color.green
        case .invalid:
            return Color.red
        case .none:
            return Color.clear
        }
    }
}
