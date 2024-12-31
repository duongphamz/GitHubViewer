//
//  UserInfoView.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import SwiftUI

struct UserInfoView: View {
    enum DisplayType {
        case landingPage(String?)
        case location(String?)
    }
    
    let avatar: String?
    let userName: String?
    let type: DisplayType
    
    var body: some View {
        HStack(alignment: .top) {
            avatarView
            infoView
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .cornerRadius(8)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    var avatarView: some View {
        AsyncImage(url: URL(string: avatar ?? "")) { image in
            image.resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .padding(.all, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.gray.opacity(0.1))
                )
        } placeholder: {
            ProgressView()
        }
        .frame(width: 100, height: 100)
    }
    
    var infoView: some View {
        VStack(alignment: .leading) {
            Text(userName ?? "")
                .font(.headline)
            Divider()
            switch type {
            case .landingPage(let landingPage):
                Text(landingPage ?? "")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                    .underline()
                    .lineLimit(3)
                    .onTapGesture {
                        if let url = URL(string: landingPage ?? "") {
                            UIApplication.shared.open(url)
                        }
                    }
            case .location(let location):
                if let location {
                    Text(Image(systemName: "location.circle"))
                        .foregroundColor(.gray) +
                    Text(" \(location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
        }
        .padding(.leading, 8)
    }
}

#Preview {
    UserInfoView(
        avatar: "https://avatars.githubusercontent.com/u/24771109?s=96&v=4",
        userName: "duong",
        type: .landingPage("https://avatars.githubusercontent.com/u/24771109?s=96&v=4")
    )
}
