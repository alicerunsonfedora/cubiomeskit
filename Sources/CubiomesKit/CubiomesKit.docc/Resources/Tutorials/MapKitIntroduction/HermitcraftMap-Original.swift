import SwiftUI

struct HermitcraftMap: View {
    var body: some View {
        ContentUnavailableView(
            "Welcome to Hermitcraft",
            systemImage: "globe")
        .navigationTitle("Hermitcraft")
    }
}
