//
//  SuggestionRow.swift
//  ryweather
//
//  Created by Ryan Young on 3/1/25.
//

import SwiftUI

struct SuggestionRow: View {
    var location: LocationModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(location.name), \(location.region)")
            Text(location.country)
                .font(.caption)
        }
    }
}
