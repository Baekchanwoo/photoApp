//
//  EditView.swift
//  photoApp
//
//  Created by 백찬우 on 2022/10/13.
//

import Foundation
import SwiftUI
import Alamofire

struct EditView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var post: Storage
    @Binding var images4 : [UIImage]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("title", text: $post.title)
                    VStack {
                        
                        if !self.images4.isEmpty{
                                HStack(spacing: 15){
                                    
                                    Image(uiImage: self.images4[0])
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                                    
                                    
                                }

                        }
                        else{
                            AsyncImage(url: URL(string: post.document)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 350, height: 350)
                        }
                        
                        NavigationLink(
                            destination: Home(images4:self.$images4)) {
                                
                                Button(action: {
                                }, label: {
                                    Label("이미지 선택", systemImage: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .frame(width: 350, height: 50)
                                })

                            }
                    }

//                    TextField("Post Document", text: $post.document)
                }
            }.listStyle(GroupedListStyle())
                .navigationTitle(Text("수정"))
                .navigationBarItems(leading:Button("취소"){
                    presentationMode.wrappedValue.dismiss()
                    images4=[]
                }, trailing: Button(action: {
                    updatePost()
                    images4=[]
                    
                }, label: {Text("등록")}))
        }
    }
    
    func updatePost() {
        
        /////////
        
        guard let url = URL(string:"\(url_images_string)\(self.post.id)/") else {
            print("app is invalid")
            fatalError("endpoint is not active")
        }
        let postData = self.post
        
        let parameters: [String: Any] = [
            "title": postData.title
        ]

        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]

        AF.upload(multipartFormData: { (multipart) in

            for image in self.images4 {
                if let image = image.jpegData(compressionQuality: 1) {
                    multipart.append(image, withName: "document", fileName: "\(self.post.title).jpg", mimeType: "image/jpeg")
                }
            }

            for (key, value) in parameters {
                multipart.append("\(value)".data(using: .utf8, allowLossyConversion: false)!, withName: "\(key)")
            }
        }, to: url
        ,method: .patch
        ,headers: header).responseJSON(completionHandler: { (response) in

            do{
                let result: Storage = try JSONDecoder().decode(Storage.self, from: response.data!)
                
                self.post = result
                
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()

                }
                return

//                self.posts.append(result)
            }
            catch{
            }
            

            if let err = response.error{
                print(err)
                print("fail")
                return
            }
            else {
                print("success")
            }
        })
        
        self.images4 = []
        guard let url = url_images else {
            print("api is down")
            return
        }
        
        guard let encoded = try? JSONEncoder().encode(postData) else {
            print("failed to encode order")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try?JSONDecoder().decode(Storage.self, from: data){
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()

                    }
                    return
                }
            }
            
        }.resume()
    }
}
