import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            NeumorphicConcaveView()
        }
        .preferredColorScheme(.light)
        .background(Color(hex: "#dbdbdc"))
    }
}

