import SwiftUI

struct TabBarView: View {
    
    @State var tab = 1
    @State private var prevTab = 1
    @StateObject private var classificationViewModel = ClassificationViewModel()
    @StateObject private var imageStorageViewModel = ImageStorageViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            tabs
            
            selectedTab
        }
        .background(
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
        )
    }
}

extension TabBarView {
    
    var tabs: some View {
        TabView(selection: $tab) {
            HistoryView(viewModel: imageStorageViewModel).tag(0)
            
            ExploreView(
                classificationViewModel: classificationViewModel,
                imageStorageViewModel: imageStorageViewModel
            ).tag(1)
            
            InfoView().tag(2)
        }
    }
    
    var selectedTab: some View {
        TabBar(selectedIndex: $tab, prevSelectedIndex: $prevTab, views: [
            TabItem(imageName: "clock"),
            TabItem(imageName: "house"),
            TabItem(imageName: "info.bubble")
        ])
        .barColor(.black.opacity(0.5))
        .selectedColor(.red)
        .unselectedColor(.white)
        .ballColor(.red)
        .cornerRadius(20)
    }
}

struct TabItem: View {
    var imageName: String
    
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
    }
}

