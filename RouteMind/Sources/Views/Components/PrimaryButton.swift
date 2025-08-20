import SwiftUI

struct PrimaryButton: View {
    
    // MARK: - Properties
    var title: String = "Continue"
    var icon: String? = nil
    var style: ButtonStyle = .primary
    var action: () -> Void = {}
    
    // MARK: - View
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(.semibold)
                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(backgroundColor)
            )
            .foregroundStyle(foregroundColor)
        }
    }

    // MARK: - Private Computed Properties
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.accentColor
        case .secondary:
            return Color(.secondarySystemBackground)
        case .destructive:
            return Color.red
        case .success:
            return Color.green
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive, .success:
            return .white
        case .secondary:
            return Color.routeTextPrimary
        }
    }
    
    // MARK: - Initializers
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case success
    }
}

#Preview {
    PrimaryButton()
}
