//
//  LocationMessageSnapshotOptions.swift
//  MessageExample
//
//  Created by 黄中山 on 2017/11/25.
//  Copyright © 2017年 黄中山. All rights reserved.
//

import MapKit

struct LocationMessageSnapshotOptions {
    
    /// Initialize LocationMessageSnapshotOptions with given parameters
    ///
    /// - Parameters:
    ///   - showsBuildings: A Boolean value indicating whether the snapshot image should display buildings.
    ///   - showsPointsOfInterest: A Boolean value indicating whether the snapshot image should display points of interest.
    ///   - span: The span of the snapshot.
    ///   - scale: The scale of the snapshot.
    init(showsBuildings: Bool = false, showsPointsOfInterest: Bool = false, span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0), scale: CGFloat = UIScreen.main.scale) {
        self.showsBuildings = showsBuildings
        self.showsPointsOfInterest = showsPointsOfInterest
        self.span = span
        self.scale = scale
    }
    
    /// A Boolean value indicating whether the snapshot image should display buildings.
    ///
    /// The default value of this property is `false`.
    var showsBuildings: Bool
    
    /// A Boolean value indicating whether the snapshot image should display points of interest.
    ///
    /// The default value of this property is `false`.
    var showsPointsOfInterest: Bool
    
    /// The span of the snapshot.
    ///
    /// The default value of this property uses a width of `0` and height of `0`.
    var span: MKCoordinateSpan
    
    /// The scale of the snapshot.
    ///
    /// The default value of this property uses the `UIScreen.main.scale`.
    var scale: CGFloat
    
}
