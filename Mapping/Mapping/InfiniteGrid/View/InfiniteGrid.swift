//
//  InfiniteGrid.swift
//  Mapping
//
//  Created by Lê Văn Huy on 6/5/24.
//

import SwiftUI
import Combine
struct InfiniteGrid: View {
	
	
	@StateObject var viewModel: InfiniteGridVM = InfiniteGridVM(baseScale: 2, smallestAllowedLineGap: 20, largestAllowedLineGap: 450)
	
	@State private var previousFrameTranslation: CGSize = .zero
	/// The net scale during a magnify gesture.
	@State private var previousFrameScale: CGFloat = 1.0
	/// The shading for the grid lines.
	private let gridShading: GraphicsContext.Shading = .color(.gray)
	/// Thickness of the grid lines.
	private let lineThickness: CGFloat = 1.25
	
	@State var scrollWheelCancellable = Set<AnyCancellable>() // Cancel onDisappear
	/// Latest hash for scrollwheel event to prevent redundant firings.
	@State var eventHash: Int = .zero
	
	
	private var gridDrag: some Gesture {
		DragGesture(minimumDistance: 0)
			.onChanged { update in
				/// Get the distance traveled between frames.
				let currentFrameTranslation: CGSize = update.translation - previousFrameTranslation
				// Update the translation
				viewModel.updateTranslation(newTranslation: currentFrameTranslation)
				// Save the new translation
				previousFrameTranslation = update.translation
			}
			.onEnded { _ in
				previousFrameTranslation = .zero
			}
	}
	
	/// Gesture to scale the grid when using a magnify gesture
	private var gridScale: some Gesture {
		
		
		MagnificationGesture()
			.onChanged { update in
				/// Determine how much larger this frame is
				let currentFrameScale: CGFloat = update.magnitude / previousFrameScale
				// Update the scale
				
				//get interaction point in gesture
				
				viewModel.updateScale(newScale: currentFrameScale, sInteractionPoint: .init(x: viewModel.sSize.width/2, y: viewModel.sSize.height/2))
				// Save the current scale
				previousFrameScale = update.magnitude
			}
			.onEnded { _ in
				
				previousFrameScale = 1
			}
	}
	
    var body: some View {
		ZStack{
			
			
			Canvas { context, size in
				viewModel.setScreenSize(size)
				
				context.stroke(viewModel.drawSmallGrid(), with: .color(.gray), lineWidth: 0.5)
				context.stroke(viewModel.drawGrid(), with: gridShading, lineWidth: lineThickness)
				
			}
			.animation(.linear, value: viewModel.gScale)
			.gesture(gridDrag)
			
		}
		
		.gesture(gridScale)
		.ignoresSafeArea()
    }
}

#Preview {
    InfiniteGrid()
}
