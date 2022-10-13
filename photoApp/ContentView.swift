//
//  ContentView.swift
//  photoApp
//
//  Created by 백찬우 on 2022/10/13.
//

import SwiftUI
import Alamofire
import Foundation
import PhotosUI

var images2 : [UIImage] = []

let url_images_string = "http://3.39.5.144:8000/images/"
let url_images = URL(string:url_images_string)


struct ContentView: View {
    
    @State var posts = [Storage]()
    @State var showAdd = false
    @State var images4 : [UIImage] = []
    @State var showAdd2 = true
    @State var lastId = 0

    var body: some View {
            NavigationView {
                List {
                    ForEach(posts) {item in
                        HStack {
                            NavigationLink(
                                destination: PostDetailView(post: item,images4:$images4)) {
                                Text("\(item.id)")
                                Text(item.title)
                                Spacer()
                                Text("\(item.document)")
                            }

                        }
                    }

                }.onAppear(perform: loadPost)
                .navigationBarTitle("포스팅 목록")
                .navigationBarItems(trailing: Button(action: {showAdd.toggle()}, label: {
                    Image(systemName: "plus.circle")
                }))
                .listStyle(PlainListStyle())
                .sheet(isPresented: $showAdd, content: {
                    PostAddView(function: loadPost,images4: self.$images4, showAdd2: self.$showAdd2, posts: self.$posts)

                })
            }
    }
    
    func loadPost() {
        
        guard let url = url_images else {
            print("api is down")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let response = try?JSONDecoder().decode([Storage].self, from: data) {
                    DispatchQueue.main.async {
                        self.posts = response
                    }
                    return
                }
            }

        }.resume()

    }
}

struct PostAddView: View {
    @Environment(\.presentationMode) var presentationMode
    var function: () -> Void
    @State var title: String = ""
    @State var document: String = ""

    @Binding var images4 : [UIImage]
    @Binding var showAdd2 : Bool
    @Binding var posts : [Storage]

    var body: some View {
        NavigationView{
            List {
                Section {
                    TextField("포스팅 제목", text: $title)
                    VStack {
                        
                        if !self.images4.isEmpty{
                                HStack(spacing: 15){
                                    
                                    Image(uiImage: self.images4[0])
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                                    
                                    
                                }

                        }
                        else{
                            Image(systemName: "camera")
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 30, height: 250)
                        }
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
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("포스팅 추가")
            .navigationBarItems(
                leading: Button("취소") {
                    presentationMode.wrappedValue.dismiss()
                    images4=[]
                },
                trailing:
                            Button(action: {
                                postPost()
                                presentationMode.wrappedValue.dismiss()
                                images4=[]

                            }, label: {
                                Text("이미지 등록")
                            })
                                   
            )

        }
        
    }
    
    func postPost() {

        let parameters: [String: Any] = [
            "title": self.title
        ]
        let url = "\(url_images_string)"

        let header : HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]

        AF.upload(multipartFormData: { (multipart) in

            for image in self.images4 {
                if let image = image.jpegData(compressionQuality: 1) {
                    multipart.append(image, withName: "document", fileName: "\(title).jpg", mimeType: "image/jpeg")
                }
            }

            for (key, value) in parameters {
                multipart.append("\(value)".data(using: .utf8, allowLossyConversion: false)!, withName: "\(key)")
            }
        }, to: url
        ,method: .post
        ,headers: header).responseJSON(completionHandler: { (response) in

            do{
                let result: Storage = try JSONDecoder().decode(Storage.self, from: response.data!)

                self.posts.append(result)
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

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
