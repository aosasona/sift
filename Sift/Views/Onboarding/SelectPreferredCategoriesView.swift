//
//  SelectPreferredCategoriesView.swift
//  Sift
//
//  Created by Ayodeji Osasona on 24/05/2025.
//

import SwiftUI

struct SelectPreferredCategoriesView: View {
    @State private var selectedCategories: Set<String> = []
    @State private var categories: [String] = []
        
    var body: some View {
        VStack {
            Text("Select at least 3 topics you are interested in")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        // TODO
                    }
                }
            }

        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Select topics")
    }
}

#Preview {
    SelectPreferredCategoriesView()
}
