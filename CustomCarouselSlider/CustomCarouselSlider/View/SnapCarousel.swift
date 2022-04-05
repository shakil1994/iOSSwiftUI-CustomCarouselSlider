//
//  SnapCarousel.swift
//  CustomCarouselSlider
//
//  Created by Md Shah Alam on 4/3/22.
//

import SwiftUI

// To for Accepting List...
struct SnapCarousel<Content: View, T: Identifiable>: View {
    var content: (T) -> Content
    var list: [T]
    
    //Properties...
    var spacing: CGFloat
    var trailingSpace: CGFloat
    @Binding var index: Int
    
    init(spacing: CGFloat = 15, trailingSpace: CGFloat = 100, index: Binding<Int>, items: [T], @ViewBuilder content: @escaping (T) -> Content){
        self.list = items
        self.spacing = spacing
        self.trailingSpace = trailingSpace
        self._index = index
        self.content = content
    }
    
    //Offset...
    @GestureState var offset: CGFloat = 0
    @State var currentIndex: Int = 0
    
    var body: some View{
        GeometryReader { proxy in
            
            // Setting correct Width for snap Carousel...
            
            // One Sided Snap Carousel...
            let width = proxy.size.width - (trailingSpace - spacing)
            let adjustMentWidth = (trailingSpace / 2) - spacing
            
            HStack(spacing: spacing){
                ForEach(list){ item in
                    content(item).frame(width: proxy.size.width - trailingSpace)
                        .offset(y: getOffset(item: item, width: width))
                }
            }
            
            // Spacing will be horizontal padding...
            .padding(.horizontal, spacing)
            // Setting only after 0th index...
            .offset(x: (CGFloat(currentIndex) * -width) + (currentIndex != 0 ? adjustMentWidth : 0) + offset)
            .gesture (
                DragGesture()
                    .updating($offset, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onEnded({ value in
                        //Updating Current Index...
                        let offsetX = value.translation.width
                        
                        // Were going to convert the translation into progress (0 - 1)
                        // and round the value...
                        // based on the progress increasing or decreasing the currentIndex...
                        
                        let progress = -offsetX / width
                        
                        let roundIndex = progress.rounded()
                        
                        // Setting min...
                        currentIndex = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                        
                        // Updaing index...
                        currentIndex = index
                    })
                    .onChanged({ value in
                        // Updating only index...
                        
                        //Updating Current Index...
                        let offsetX = value.translation.width
                        
                        // Were going to convert the translation into progress (0 - 1)
                        // and round the value...
                        // based on the progress increasing or decreasing the currentIndex...
                        
                        let progress = -offsetX / width
                        
                        let roundIndex = progress.rounded()
                        
                        // Setting min...
                        index = max(min(currentIndex + Int(roundIndex), list.count - 1), 0)
                    })
            )
        }
        
        // Animatting when offset = 0
        .animation(.easeInOut, value: offset == 0)
    }
    
    // Moving View based on scroll Offset...
    func getOffset(item: T, width: CGFloat) -> CGFloat{
        
        // Progress...
        // Shifting Current Item to Top...
        let progress = ((offset < 0 ? offset : -offset) / width) * 60
        
        // Max 60...
        // Then again minus from 60...
        let topOffset = -progress < 60 ? progress : -(progress + 120)
        
        let pervious = getIndex(item: item) - 1 == currentIndex ? (offset < 0 ? topOffset : -topOffset) : 0
        
        let next = getIndex(item: item) + 1 == currentIndex ? (offset < 0 ? -topOffset : topOffset) : 0
        
        // Saftey check between 0 to max list size...
        let checkBetween = currentIndex >= 0 && currentIndex < list.count ? (getIndex(item: item) - 1 == currentIndex ? pervious : next) : 0
        
        // Checking current...
        // If so shifting view to top...
        return getIndex(item: item) == currentIndex ? -60 - topOffset : checkBetween
    }
    
    //Fatching Index...
    func getIndex(item: T) -> Int {
        let index = list.firstIndex { currentIndex in
            return currentIndex.id == item.id
        } ?? 0
        return index
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
