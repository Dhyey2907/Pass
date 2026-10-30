import SwiftUI

struct ScannerView: View {
    var body: some View {
        NavigationStack {
            PassEmptyState(
                systemImage: "qrcode.viewfinder",
                title: "Scan a pass",
                message: "Point your camera at someone's pass. code to preview their profile before you save it."
            ) {
                DeferredFeatureNotice(feature: "Scanning")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PassColors.background)
            .navigationTitle("Scan")
        }
    }
}

#Preview {
    ScannerView()
}
