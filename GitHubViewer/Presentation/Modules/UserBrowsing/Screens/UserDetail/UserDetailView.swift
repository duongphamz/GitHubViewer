//
//  UserDetailView.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import SwiftUI

struct UserDetailView: View {
    let userName: String
    @StateObject var viewModel: UserDetailViewModel
    @Environment(\.presentationMode) private var presentationMode
    init(userName: String) {
        self.userName = userName
        _viewModel = StateObject(wrappedValue: UserDetailViewModel(userName: userName))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            userInfoSection
            followSection
            blogSection
            Spacer()
        }
        .padding(.all, 8)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("User Details", displayMode: .inline)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.fetchUserDetail()
        }
        .showErrorAlert(isError: $viewModel.isError, errorMessage: viewModel.errorMessage) // Show error alerts if needed
    }
    
    //Custom back button
    private var backButton : some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.black)
            }
        }
    }
    
    // User Information Card Section
    var userInfoSection: some View {
        UserInfoView(
            avatar: viewModel.displayModel?.avatar,
            userName: userName,
            type: .location(viewModel.displayModel?.location)
        )
            .padding()
    }
    
    // Follower & Following Section
    var followSection: some View {
        HStack {
            StatView(
                icon: "person.2.fill",
                count: viewModel.displayModel?.followers ?? "",
                label: "Follower"
            )
            
            StatView(
                icon: "person.crop.circle.badge.plus",
                count: viewModel.displayModel?.following ?? "",
                label: "Following"
            )
        }
        .padding(.horizontal)
    }
    
    // Blog Section
    @ViewBuilder
    var blogSection: some View {
        if let blog = viewModel.displayModel?.blog {
            VStack(alignment: .leading, spacing: 8) {
                Text("Blog")
                    .font(.headline)
                Text(blog)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        if let url = URL(string: blog) {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            .padding(.horizontal)
        }

    }
}

#Preview {
    UserDetailView(userName: "John Smith")
}
