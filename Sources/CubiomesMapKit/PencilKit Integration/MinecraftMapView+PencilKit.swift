//
//  MinecraftMapView+PencilKit.swift
//  CubiomesKit
//
//  Created by Marquis Kurt on 08-12-2025.
//

#if canImport(UIKit)
import MapKit
import PencilKit
import UIKit

extension MinecraftMapView {
    func setupPencilKitSupportIfAvailable() {
        addSubview(drawingCanvas)

        NSLayoutConstraint.activate([
            drawingCanvas.topAnchor.constraint(equalTo: topAnchor),
            drawingCanvas.leftAnchor.constraint(equalTo: leftAnchor),
            drawingCanvas.rightAnchor.constraint(equalTo: rightAnchor),
            drawingCanvas.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if #available(iOS 18, macOS 15, *) {
            toolPicker.accessoryItem = addDrawingButton
        }
        toolPicker.addObserver(drawingCanvas)
        toolPicker.setVisible(true, forFirstResponder: drawingCanvas)
    }

    func didChangeIsDrawing() {
        drawingCanvas.allowsDrawing = mapConfiguration.allowPencilKitDrawings && isDrawing
        if drawingCanvas.allowsDrawing {
            drawingCanvas.becomeFirstResponder()
        } else {
            drawingCanvas.resignFirstResponder()
        }
    }

    @objc func addCurrentDrawing() {
        let drawing = drawingCanvas.drawing

        let drawingCenter = CGPoint(x: drawing.bounds.midX, y: drawing.bounds.midY)
        let coordinate = convert(drawingCenter, toCoordinateFrom: drawingCanvas)

        let mapRegion = convert(drawing.bounds, toRegionFrom: drawingCanvas)
        let topLeft = CLLocationCoordinate2D(
            latitude: mapRegion.center.latitude + (mapRegion.span.latitudeDelta / 2),
            longitude: mapRegion.center.longitude - (mapRegion.span.longitudeDelta / 2)
        )
        let bottomRight = CLLocationCoordinate2D(
            latitude: mapRegion.center.latitude - (mapRegion.span.latitudeDelta / 2),
            longitude: mapRegion.center.longitude + (mapRegion.span.longitudeDelta / 2)
        )

        let topLeftPoint = MKMapPoint(topLeft)
        let bottomRightPoint = MKMapPoint(bottomRight)

        let mapRect = MKMapRect(
            origin: MKMapPoint(x: min(topLeftPoint.x, bottomRightPoint.x), y: min(topLeftPoint.y, bottomRightPoint.y)),
            size: MKMapSize(
                width: abs(topLeftPoint.x - bottomRightPoint.x),
                height: abs(topLeftPoint.y - bottomRightPoint.y)
            )
        )

        let mapDrawing = MinecraftMapDrawing(drawing: drawing, location: coordinate, mapRect: mapRect)
        drawings?.append(mapDrawing)
        mcMapViewDelegate?.mapView(self, addedDrawing: mapDrawing)

        let overlay = MinecraftDrawingOverlay(model: mapDrawing)
        addOverlay(overlay, level: .aboveLabels)
        
        drawingCanvas.drawing = PKDrawing()
    }
}

#endif
