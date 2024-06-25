//
//  CompareView.swift
//  Compare
//
//  Created by Aanchal Patial on 22/06/24.
//

import SwiftUI
import PhotosUI

struct CompareView: View {

//    @StateObject private let viewModel: CompareBusinessLogic

    @State var firstKeyword: String = ""
    @State var secondKeyword: String = ""
    @State var firstImage: UIImage?
    @State var secondImage: UIImage?
    @State var question: String = ""
    @State var criteria: String = ""

    @State var compareUsingImage = true

    @State var hamburgerSheetPresented = false
    @State var alertPresented = false
    @State var alertPresentedType: AlertType = .requiredTextError

    var imageSpacing: CGFloat = 8
    var freeTrialDays = 1
    @State var criterias = [String]()

    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing

        return NavigationStack {

            Form {

                let toggleText = compareUsingImage ? "Toggle to compare using text" : "Toggle to compare using images"
                Toggle(toggleText, isOn: $compareUsingImage)
                    .foregroundStyle(.secondary)


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
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(content: {
                                ForEach(criterias.indices, id: \.self) { index in
                                    Button {
                                        withAnimation {
                                            criterias.removeAll(where: { $0 == criteria })
                                        }
                                    } label: {
                                        HStack {
                                            Text(criterias[index])
                                            Image(systemName: "xmark")

                                        }
                                    }
                                    .font(.footnote)
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

                    BlackBackgroundButtonView(title: "compare", handler: {
                        guard freeTrialDays > 0 else {
                            alertPresentedType = .premium
                            alertPresented = true
                            return
                        }

                        if compareUsingImage {
                            var bothImagesAdded = !(firstImage == nil || secondImage == nil)
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
                            // TODO: - viewModel call
                        } else {
                            guard !firstKeyword.isEmpty,
                                  !secondKeyword.isEmpty,
                                  !question.isEmpty else {
                                alertPresentedType = .requiredTextError
                                alertPresented = true
                                return
                            }
                            // TODO: - viewModel call
                        }
                    })

                }


            }
            .navigationTitle("compareIt!")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("", systemImage: "line.3.horizontal") {
                        hamburgerSheetPresented = true
                    }
                    .tint(.black)
                    .confirmationDialog("", isPresented: $hamburgerSheetPresented) {
                        Button("Tutorial") {
//                            let tutorial = TutorialViewController()
//                            self.present(tutorial, animated: true)
                        }
                        Button("Logout") {
                            alertPresentedType = .logout
                            alertPresented = true
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("\(freeTrialDays) days left") {
//                        let premiumViewController = PremiumViewController(freePremiumDaysLeft: freePremiumDaysLeft)
//                        present(premiumViewController, animated: true)
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
    //                    KeychainItem.deleteUserIdentifierFromKeychain()
    //                    UserDefaults.standard.reset()
    //                    self.premiumButton.isHidden = false
                    }))
                case .premium:
                    Alert(title: Text(alertPresentedType.title),
                          message: Text(alertPresentedType.message),
                          primaryButton: .default(Text("Buy"), action: {
    //                    let premiumViewController = PremiumViewController(freePremiumDaysLeft: freePremiumDaysLeft)
    //                    present(premiumViewController, animated: true)
                    }), secondaryButton: .destructive(Text("Cancel")))
                default:
                    Alert(title: Text(alertPresentedType.title),
                          message: Text(alertPresentedType.message))
                }

            }
        }

    }
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
        .font(.headline)
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
        .font(.headline)
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
