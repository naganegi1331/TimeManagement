//
//  SectionHeaderView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//  Refactored: Separated from ActivityEditView.swift for better organization
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
} 