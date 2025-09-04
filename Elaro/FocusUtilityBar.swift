import SwiftUI

struct FocusUtilityBar: View {
    @Binding var selectedFocus: FocusArea
    @Binding var depth: FocusDepth
    
    var body: some View {
        HStack(spacing: 12) {
            // Child Chip
            ChildChip()
            
            Spacer()
            
            // Focus Pills (max 2)
            HStack(spacing: 8) {
                ForEach(FocusArea.allCases.prefix(2), id: \.id) { focus in
                    FocusPill(
                        focus: focus,
                        isSelected: selectedFocus == focus,
                        onTap: {
                            selectedFocus = focus
                        },
                        onLongPress: {
                            print("Jump to Monthly Plan for \(focus.displayName)")
                            depth = .month
                        }
                    )
                }
            }
            
            Spacer()
            
            // Bell Button
            BellButton()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - Child Chip

struct ChildChip: View {
    var body: some View {
        Button(action: {
            print("Child chip tapped")
        }) {
            HStack(spacing: 8) {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("A")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                Text("Alex")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.regularMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Child: Alex")
        .accessibilityHint("Tap to switch child")
    }
}

// MARK: - Focus Pill

struct FocusPill: View {
    let focus: FocusArea
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(focus.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? .blue : .clear)
                        .overlay(
                            Capsule()
                                .strokeBorder(.blue, lineWidth: isSelected ? 0 : 1)
                        )
                )
                .foregroundColor(isSelected ? .white : .blue)
        }
        .buttonStyle(.plain)
        .onLongPressGesture {
            onLongPress()
        }
        .accessibilityLabel("Focus: \(focus.displayName)")
        .accessibilityHint(isSelected ? "Selected focus area" : "Tap to select focus area")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Bell Button

struct BellButton: View {
    @State private var hasNotifications = false
    
    var body: some View {
        Button(action: {
            print("Bell button tapped")
        }) {
            Image(systemName: hasNotifications ? "bell.fill" : "bell")
                .font(.title3)
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifications")
        .accessibilityHint("Tap to view notifications")
    }
}

#Preview {
    VStack(spacing: 20) {
        FocusUtilityBar(
            selectedFocus: .constant(.independence),
            depth: .constant(.today)
        )
        
        FocusUtilityBar(
            selectedFocus: .constant(.emotionSkills),
            depth: .constant(.week)
        )
    }
    .padding()
}