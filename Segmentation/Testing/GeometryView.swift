    //
    //  GeometryView.swift
    //  Segmentation
    //
    //  Created by Saiful Islam Sagor on 3/11/23.
    //

import SwiftUI

struct GeometryView: View {
    @GestureState var scale: CGFloat = 1.0
    @State var finalScale :CGFloat = 1.0
    @State var startOffset: CGSize = CGSize(width: 0, height: 0)
    @State var offset: CGSize = CGSize(width: 0, height: 0)
    var body: some View {
        
        ZStack{
                
                Color.gray
//                Text("width: \(size.width) height: \(size.height)")
        

                        
                    Circle()
                        .frame(width: 300, height: 300)
                        .border(Color.green, width: 3)
                        .foregroundColor(.yellow)
                        //                .position(x: 0 ,y: 0)
                        .scaleEffect(scale*finalScale)
                        .offset(offset)
//                        .gesture(Drag.simultaneously(with: simpleMagnify))
                        .gesture(Drag)
                        .gesture(simpleMagnify)
            
        }
        .frame(width: 300, height: 300)
        .border(Color.blue, width: 3)
    }
    
    var simpleMagnify: some Gesture {
        MagnificationGesture()
            .updating($scale) { currentState, gestureState, trans in
                gestureState = currentState.magnitude
            }
            .onEnded { value in
                finalScale *=  value.magnitude
                if finalScale < 1 {
                    finalScale = 1.0
                    offset  = .zero
                    startOffset = .zero
                }
        
                
            }
    }
    var Drag: some Gesture {
        DragGesture(minimumDistance: 0)
            
            .onChanged { value in
                if scale*finalScale > 1 {
                    offset.width = startOffset.width + value.translation.width
                    offset.height = startOffset.height + value.translation.height
                }
            }
            .onEnded { value in
                if scale*finalScale > 1 {
                    startOffset = offset
                }
            }
    }
}

struct GeometryView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryView()
    }
}
