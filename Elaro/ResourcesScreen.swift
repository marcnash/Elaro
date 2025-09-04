import SwiftUI

struct ResourcesScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Getting Started") {
                    LabeledContent("Independence-first basics", value: "Short primers & tips")
                }
                Section("Recommended Reading") {
                    Text("How to Raise an Adult – Julie Lythcott-Haims")
                    Text("The Self-Driven Child – Stixrud & Johnson")
                    Text("Free-Range Kids – Lenore Skenazy")
                }
            }
            .navigationTitle("Resources")
        }
    }
}
