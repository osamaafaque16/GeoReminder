//
//  StepCountWidget.swift
//  GeoRemind
//
//  Created by Osama Afaque on 20/12/2025.
//

import SwiftUI

struct StepCountView: View {
    @Binding var stepCount: Int
    var onFetchSteps: () -> Void
    
    @State private var isLoading = false

    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    
                    // 🔄 STEP COUNT / LOADER
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.4)
                    } else {
                        Text("\(stepCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("steps today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
             Button(action: {
                isLoading = true
                onFetchSteps()
                 DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     isLoading = false
                 }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Fetch Steps")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    
}
