//
//  PostDetailView.swift
//  photoApp
//
//  Created by 백찬우 on 2022/10/13.
//

import Foundation
import SwiftUI

struct PostDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var post: Storage
    @State var showEdit = false
    @Binding var images4 : [UIImage]
    
    var body: some View {
        List{
            HStack{
                Text("\(post.id)")
                Spacer()
                Text("\(post.document)")
                
            }
            
            AsyncImage(url: URL(string: post.document)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 350, height: 350)
            
            Section {
                Button(action: {self.deletePost()}, label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("삭제")
                    }
                })
            }
        }.listStyle(GroupedListStyle())
            .navigationTitle(post.title)
            .navigationBarItems(trailing: Button(action: {self.showEdit.toggle()}, label: {
                Text("수정")
                    .sheet(isPresented: $showEdit,content: {
                        EditView(post: $post, images4: $images4)
                    })
            }))
    }
    
    func deletePost() {
        guard let url = URL(string:"\(url_images_string)\(self.post.id)/") else {
            print("api is down")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {

                    DispatchQueue.main.async {
                        print("\(data)")
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    return
                
            }
            
        }.resume()
    }
}
