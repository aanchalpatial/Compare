//
//  BlackBorderImageView.swift
//  Compare
//
//  Created by Aanchal Patial on 04/07/24.
//

import SwiftUI
import PhotosUI

struct BlackBorderImageView: View {
    @State var imagePickerSheetPresented = false
    @State var photosPickerPresented = false
    @State var cameraPresented = false
    @State var firstPhotosPickerItem: PhotosPickerItem?
    @Binding var image: UIImage?
    @State var placeholder: UIImage
    let width: CGFloat = 150
    var body: some View {

        Image(uiImage: image ?? placeholder)
            .if(!(image==nil)) { image in
                image.resizable()
            }
            .frame(width: width, height: width)
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.black)
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

#Preview {
    @State var image: UIImage?
    return BlackBorderImageView(image: $image, placeholder: UIImage(systemName: "plus")!)
}
