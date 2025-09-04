import SwiftUI

struct LibraryScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "books.vertical")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                
                Text("Library")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Coming in Phase 2")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("The Library will show action templates filtered by your active Focus Areas. You'll be able to browse, search, and add actions to your Today deck.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LibraryScreen()
}