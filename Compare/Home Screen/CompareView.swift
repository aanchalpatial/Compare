//
//  CompareView.swift
//  Compare
//
//  Created by Aanchal Patial on 22/06/24.
//

import SwiftUI
import PhotosUI
import Lottie

struct CompareView: View {

//    @StateObject private let viewModel: CompareBusinessLogic

    @State var firstKeyword: String = ""
    @State var secondKeyword: String = ""
    @State var firstImage: UIImage?
    @State var secondImage: UIImage?
    @State var question: String = ""
    @State var criteria: String = ""
    @State var compareUsingImage = false
    @State var hamburgerSheetPresented = false
    @State var alertPresented = false
    @State var alertPresentedType: AlertType = .requiredTextError
    @State var premiumSheetPresented = false
    @State var tutorialSheetPresented = false
    @State var playbackMode = LottiePlaybackMode.paused(at: .currentFrame)

    var comparisonResult = ComparisonResult(introduction: "Cristiano Ronaldo and Lionel Messi are two of the greatest footballers of all time. Both players have achieved incredible success at both the club and international level, and they have both won numerous individual awards. But who is the better player? It's a question that has been debated by fans and pundits for years.", comparisonTable: [
        ["Header","messi", "ronaldo"],
        ["Goals","793", "819"],
        ["Assists","350", "233"],
        ["Trophies","41", "34"],
        ["Ballon d'Or awards","7", "5"],
        ["FIFA World Player of the Year awards","6", "5"],
        ["UEFA Men's Player of the Year awards","4", "3"],
        ["Champions League titles","4", "5"]
      ], conclusion: "Based on the comparison table, it is clear that both Messi and Ronaldo are exceptional players. However, Messi has a slight edge in terms of goals, assists, and trophies. Additionally, Messi has won more individual awards than Ronaldo. Therefore, I believe that Messi is the better player.")

    let imageSpacing: CGFloat = 8
    let freeTrialDays = 1
    @State var criterias = [String]()

    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing

        return NavigationStack {

            Form {

                let toggleText = compareUsingImage ? "Toggle to compare using text" : "Toggle to compare using images"
                Toggle(toggleText, isOn: $compareUsingImage)

                let inputSectionText = compareUsingImage ? "Add images to compare" : "Add keywords to compare"
                Section(inputSectionText) {

                    HStack(spacing: imageSpacing) {
                        if compareUsingImage {
                            BlackBorderImageView(image: $firstImage)
                            Spacer()
                            BlackBorderImageView(image: $secondImage)
                        } else {
                            TextField("First keyword", text: $firstKeyword)
                                .multilineTextAlignment(.leading)
                            Divider()
                            TextField("Second keyword", text: $secondKeyword)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    TextField("Ask your question here", text: $question)

                    HStack {
                        TextField("(Optional) Add criterias here ...", text: $criteria)
                        BlackBorderButtonView(title: "add", width: 60)
                            .onTapGesture {
                                if !criteria.isEmpty {
                                    withAnimation {
                                        criterias.append(criteria)
                                    }
                                } else {
                                    alertPresentedType = .requiredTextError
                                    alertPresented = true
                                }
                            }
                    }

                    if !criterias.isEmpty {
                        CriteriaListView(criterias: $criterias)
                    }

                    BlackBackgroundButtonView(title: "compare", handler: {
                        guard freeTrialDays > 0 else {
                            alertPresentedType = .premium
                            alertPresented = true
                            return
                        }

                        if compareUsingImage {
                            let bothImagesAdded = !(firstImage == nil || secondImage == nil)
                            guard bothImagesAdded else {
                                alertPresentedType = .requiredImageError
                                alertPresented = true
                                return
                            }
                            guard !question.isEmpty else {
                                alertPresentedType = .requiredTextError
                                alertPresented = true
                                return
                            }
                            playbackMode =  .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
                            // TODO: - viewModel call
                        } else {
                            guard !firstKeyword.isEmpty,
                                  !secondKeyword.isEmpty,
                                  !question.isEmpty else {
                                alertPresentedType = .requiredTextError
                                alertPresented = true
                                return
                            }
                            playbackMode =  .playing(.fromProgress(0, toProgress: 1, loopMode: .loop))
                            // TODO: - viewModel call
                        }
                    })
                }

                if playbackMode == .playing(.fromProgress(0, toProgress: 1, loopMode: .loop)) {
                    HStack {
                        Spacer()
                        LottieView(animation: .named("loader-cube"))
                            .playbackMode(playbackMode)
                        Spacer()
                    }
                }


                Section("Introduction") {
                    Text(comparisonResult.introduction)
                }

                Section("Comparison Table") {
                    ForEach(comparisonResult.comparisonTable, id: \.self) { row in
                        GeometryReader { geometry in
                            HStack {
                                ForEach(row, id: \.self) { cell in
                                    Text(cell)
                                        .frame(maxWidth: geometry.size.width * 0.33, alignment: .leading)
                                        .minimumScaleFactor(0.5)
                                    if cell != row.last {
                                        Divider()
                                    }
                                }
                            }
                        }

                    }
                }

                Section("Conclusion") {
                    Text(comparisonResult.conclusion)
                }
            }
            .font(.custom("Verdana", size: 14))
            .navigationTitle("compareIt!")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "line.3.horizontal") {
                        hamburgerSheetPresented = true
                    }
                    .tint(.black)
                    .confirmationDialog("", isPresented: $hamburgerSheetPresented) {
                        Button("Tutorial") {
                            tutorialSheetPresented = true
                        }
                        Button("Logout") {
                            alertPresentedType = .logout
                            alertPresented = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("\(freeTrialDays) days left") {
                        premiumSheetPresented = true
                    }
                }
            }
            .alert(isPresented: $alertPresented) {
                switch alertPresentedType {
                case .logout:
                    Alert(title: Text(alertPresentedType.title),
                          message: Text(alertPresentedType.message),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Yes"), action: {
//                        KeychainItem.deleteUserIdentifierFromKeychain()
//                        UserDefaults.standard.reset()
    //                    self.premiumButton.isHidden = false
                    }))
                case .premium:
                    Alert(title: Text(alertPresentedType.title),
                          message: Text(alertPresentedType.message),
                          primaryButton: .default(Text("Buy"), action: {
                        premiumSheetPresented = true
                    }), secondaryButton: .destructive(Text("Cancel")))
                default:
                    Alert(title: Text(alertPresentedType.title),
                          message: Text(alertPresentedType.message))
                }

            }

        }
        .sheet(isPresented: $premiumSheetPresented) {
            PremiumView(freePremiumDaysLeft: freeTrialDays)
        }
        .sheet(isPresented: $tutorialSheetPresented) {
            TutorialView()
                .presentationBackground(.clear)
        }

    }
}

struct BackgroundCleanerView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CompareView()
}

struct BlackBackgroundButtonView: View {
    let title: String
    let handler: () -> Void

    var body: some View {
        Button {
            handler()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .fontWeight(.medium)
        .foregroundStyle(.white)
        .padding(8)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct BlackBorderButtonView: View {
    let title: String
    var width: CGFloat = .infinity

    var body: some View {
        Button {
        } label: {
            Text(title)
                .frame(maxWidth: width)
        }
        .fontWeight(.medium)
        .foregroundStyle(.black)
        .padding(8)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke()
        }
    }
}

struct BlackBorderImageView: View {
    @State var imagePickerSheetPresented = false
    @State var photosPickerPresented = false
    @State var cameraPresented = false
    @State var firstPhotosPickerItem: PhotosPickerItem?
    @Binding var image: UIImage?
    var width: CGFloat = 150
    var body: some View {

        Image(uiImage: image ?? UIImage(systemName: "plus")!)
            .if(!(image==nil)) { image in
                image.resizable()
            }
            .frame(width: width, height: width)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.placeholder)
            }
            .onTapGesture {
                imagePickerSheetPresented = true
            }
            .confirmationDialog("", isPresented: $imagePickerSheetPresented) {
                Button("Camera") {
                    cameraPresented = true
                }
                Button("Photo Library") {
                    photosPickerPresented = true
                }
            }
            .photosPicker(isPresented: $photosPickerPresented, selection: $firstPhotosPickerItem, matching: .images)
            .fullScreenCover(isPresented: $cameraPresented) {
                AccessCameraView(selectedImage: $image)
            }
            .onChange(of: firstPhotosPickerItem) { _, _ in
                Task {
                    if let photosPickerItem = firstPhotosPickerItem,
                       let data = try? await photosPickerItem.loadTransferable(type: Data.self),
                       let pickedImage = UIImage(data: data) {
                        image = pickedImage
                    }
                    firstPhotosPickerItem = nil
                }
            }
    }
}

struct CriteriaListView: View {
    @Binding var criterias: [String]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(content: {
                ForEach(criterias.indices, id: \.self) { index in
                    Button {
                        withAnimation {
                            criterias.removeAll(where: { $0 == criterias[index] })
                        }
                    } label: {
                        HStack {
                            Text(criterias[index])
                            Image(systemName: "xmark")
                            
                        }
                    }
                    .foregroundStyle(.black)
                    .padding(6)
                    .background(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                    }
                }
            })
        }
    }
}
