    //
    //  GestureView.swift
    //  Segmentation
    //
    //  Created by Saiful Islam Sagor on 2/11/23.
    //

import SwiftUI

struct GestureView: View {
    @GestureState var fingerLocation: CGPoint? = nil
    
    @State var centerLocation: CGPoint = CGPoint(x: 137, y: 205)
    @State var location: CGPoint = CGPoint(x: 137, y: 205)
    @GestureState var isInteracting: Bool = false
    
    @GestureState var scale: CGFloat = 1.0
    @State var finalScale: CGFloat = 1.0
    
    @GestureState var startLocation : CGPoint? = nil
    var fingerDrag: some Gesture {
        DragGesture(coordinateSpace: .global)
            .updating($fingerLocation){ currentlocation,fingerlocation, _ in
                fingerlocation = currentlocation.location
            }
    }
    
    var Drag: some Gesture{
        DragGesture(coordinateSpace: .global)
            .updating($isInteracting){_, value, _ in
                value = true
            }
            .onChanged{ value in
                let newlocation = CGPoint(x: centerLocation.x + value.translation.width , y: centerLocation.y + value.translation.height)
                location = newlocation
            }
            .onEnded { value in
                centerLocation.x += value.translation.width
                centerLocation.y += value.translation.height
            }
    }

    
    var simpleMagnify: some Gesture {
        MagnificationGesture()
            .updating($scale) { currentState, gestureState, trans in
                gestureState = currentState.magnitude
            }
            .updating($isInteracting) { _, value, _ in
                value = true
            }
            .onEnded { value in
                finalScale *=  value
                if finalScale < 1 {
                    finalScale = 1.0
                }
                
            }
    }
    
    var body: some View {
        ZStack {
            Color.green
            GeometryReader {
                let size = $0.size
                
                Image("51")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                //can use geometry reader here
                    .scaleEffect(scale * finalScale)
                    .frame(width: size.width, height: size.height)
                    .position(location)
                    .clipped()
                    .gesture(simpleMagnify.simultaneously(with: Drag))
                
//                if let fingerLocation = fingerLocation {
//                    Circle()
//                        .stroke(Color.red, lineWidth: 3)
//                        .frame(width: 100,height: 100)
//                        .position(fingerLocation)
//                        .overlay{
//                            VStack{
//                                Text("\(fingerLocation.x)\t \(fingerLocation.y)")
//                                Text("width: \(size.width)\t height: \(size.height)")
//                            }
//
//                        }
//                }
            }
                //                .coordinateSpace(name: "GestureView")
        }.frame(width: UIScreen.main.bounds.width - 100 , height: UIScreen.main.bounds.height/2)
        
        
    }
}

struct GestureView_Previews: PreviewProvider {
    static var previews: some View {
        GestureView()
    }
}
