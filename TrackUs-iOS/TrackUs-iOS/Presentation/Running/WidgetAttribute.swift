//
//  WidgetAttribute.swift
//  TrackUs-iOS
//
//  Created by 석기권 on 6/3/24.
//

import Foundation
import ActivityKit

struct WidgetTestAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
