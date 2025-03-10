import SwiftUI

struct DetailsView: View {
    let architectureType: String
    let imageName: String?
    let uiImage: UIImage?
    
    @StateObject var viewModel = InfoViewModel()
    @State private var architectureDescriptions: [String: String] = [:]

    var body: some View {
        VStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.black.opacity(0.8), lineWidth: 4)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1).delay(0.2), value: uiImage)
            } else if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.black.opacity(0.8), lineWidth: 4)
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1).delay(0.2), value: imageName)
            } else {
                Text("No Image Available")
            }

            Text("\(architectureType)")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.6))
                )
                .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 2)
                .padding(.vertical, 20)
            
            if let description = architectureDescriptions[architectureType] {
                Text(description)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.6))
                    )
                    .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 2)
            } else {
                Text("Description not available")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.6))
                    )
                    .shadow(color: .black.opacity(0.8), radius: 5, x: 0, y: 2)
            }

            Spacer()
        }
        .padding()
        .background(
            Image("background4")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            if let descriptions = viewModel.loadDescriptions() {
                architectureDescriptions = descriptions
            }
        }
    }
}

struct ArchitectureDetail: Identifiable {
    let id = UUID()
    let architectureType: String
    let imageName: String?
}
