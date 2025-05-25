//
//  WelcomeView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to Sift!")
                    .font(.system(size: 36, weight: .medium))
                    .padding(.vertical, 6)

                Text("Your feed, enhanced by AI.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                VStack {
                    NavigationLink(destination: SelectPreferredCategoriesView()) {
                        Text("Get Started")
                    }
                    .buttonStyle(.fullWidth)
                }
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView()
}
