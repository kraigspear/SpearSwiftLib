//
//  MKMapViewExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/18/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import CoreLocation
import Foundation
import MapKit

public protocol MapLocation {
    var coordinate: CLLocationCoordinate2D { get }
    var locationName: String { get }
}

/// Type that can center on a `CLLocationCoordinate2D` with a given ZoomLevel and animation of a series of tiles (animated radar)
public protocol CenterOnCoordinateSettable {
    /// Center on a coordinate and zoom level
    /// - Parameter centerCoordinate: Coordinate to center on
    /// - Parameter span: Zoom level
    /// - Parameter animated: should the change be animated
    func setCenter(on location: MapLocation,
                   span: Double,
                   animated: Bool)
}

extension MKMapView: CenterOnCoordinateSettable {
    public func setCenter(on location: MapLocation,
                          span: Double,
                          animated: Bool) {
        // https://stackoverflow.com/questions/4189621/setting-the-zoom-level-for-a-mkmapview
        let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: span)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        setRegion(region, animated: animated)
        addAnnotation(forLocation: location)
    }

    public func addAnnotation(forLocation location: MapLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = location.locationName
        addAnnotation(annotation)
    }
}
