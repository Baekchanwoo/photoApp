//
//  PostPhotoView.swift
//  photoApp
//
//  Created by 백찬우 on 2022/10/13.
//

import Foundation
import SwiftUI
import PhotosUI

struct Home : View {
    @State var picker = false
    @Binding var images4 : [UIImage]
    
    var body: some View{

        if !images4.isEmpty{
            if picker {
                HStack(spacing: 15){
                    Image(uiImage: images4[0])
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                }
            }
            else {
                ImagePicker(picker: $picker, images4:$images4)
            }

        }
        else{
            ImagePicker(picker: $picker, images4:$images4)
        }
    }
}

struct ImagePicker : UIViewControllerRepresentable {
    
    func makeCoordinator() -> Coordinator {
        return ImagePicker.Coordinator(parent1: self)
    }

    @Binding var picker : Bool
    @Binding var images4 : [UIImage]

    func makeUIViewController(context: Context) -> PHPickerViewController {
        
        var config = PHPickerConfiguration()
        
        config.filter = .images
        
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        
        var parent : ImagePicker
        
        init(parent1: ImagePicker) {
            parent = parent1
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            parent.picker.toggle()
            
            for img in results {
                
                if img.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    
                    img.itemProvider.loadObject(ofClass: UIImage.self) { (image,err) in
                        
                        guard let image1 = image else {
                            print(err)
                            return
                        }
                        
                        self.parent.images4 = []
                        self.parent.images4.append(image1 as! UIImage)
                    }
                    
                }
                else{
                    
                    print("cannot be loaded")
                }
            }
        }
    }
}
