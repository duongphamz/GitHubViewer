//
//  StatView.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import SwiftUI

struct StatView: View {
    let icon: String
    let count: String
    let label: String
     
    var body: some View {
        VStack {
             Image(systemName: icon)
                 .foregroundColor(.black)
                 .font(.title2)
             Text(count)
                 .font(.headline)
             Text(label)
                 .font(.subheadline)
                 .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatView(icon: "person.2.fill", count: "5+", label: "Follower")
}
