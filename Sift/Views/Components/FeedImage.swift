//
//  FeedImage.swift
//  Sift
//
//  Created by Ayodeji Osasona on 25/05/2025.
//

import SwiftUI

struct FeedImage: View {
    var imageURL: String?
    
    var body: some View {
        if let imageURL = imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: ImageSize, height: ImageSize)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } placeholder: {
                ImagePlaceholder()
            }
        } else {
            // Newspaper in gray box
            ImagePlaceholder()
        }
    }
    
    @ViewBuilder
    func ImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.gray.opacity(0.5))
            .frame(width: ImageSize, height: ImageSize)
            .overlay(
                Image(systemName: "newspaper")
                    .foregroundStyle(.white)
                    .font(.system(size: 13))
            )
    }
}

#Preview {
    FeedImage(imageURL: "https://example.com/image.jpg")
}
