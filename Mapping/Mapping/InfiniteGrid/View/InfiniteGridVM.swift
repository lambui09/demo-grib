//
//  InfiniteGridVM.swift
//  Mapping
//
//  Created by Lê Văn Huy on 6/5/24.
//

import Foundation
import SwiftUI

class InfiniteGridVM: ObservableObject {
	@Published var gScale: CGFloat = 1
	@Published var sInteractionPoint: CGPoint = .zero
	
	private(set) var sSize: CGSize = .zero
	@Published var sTranslation: CGPoint = .zero
	@Published var scaleSpacing: CGFloat = 1.0
	public let sLineSpacing: CGFloat
	public let smallestAllowedLineGap: CGFloat
	public let largestAllowedLineGap: CGFloat
	
	init(baseScale: CGFloat = 1, smallestAllowedLineGap: CGFloat, largestAllowedLineGap: CGFloat) {
		self.sLineSpacing = 40 * baseScale
		self.smallestAllowedLineGap = smallestAllowedLineGap
		self.largestAllowedLineGap = largestAllowedLineGap
	}
	
	public func updateTranslation(newTranslation sTranslation: CGSize) {
		if !(sTranslation.width.isFinite && sTranslation.height.isFinite) {
			return
		}
		self.sTranslation += sTranslation / gScale
	}
	
	public func updateScale(newScale inputScaleMultiplier: CGFloat, sInteractionPoint: CGPoint) {
		guard inputScaleMultiplier.isFinite else { return }

		var scaleMultiplier = inputScaleMultiplier
		if gScale * scaleMultiplier * sLineSpacing < smallestAllowedLineGap {
			scaleMultiplier = smallestAllowedLineGap / (gScale * sLineSpacing)
		} else if gScale * scaleMultiplier * sLineSpacing > largestAllowedLineGap {
			scaleMultiplier = largestAllowedLineGap / (gScale * sLineSpacing)
		}

		let oldInteractionProportion = sInteractionPoint / sSize
		guard oldInteractionProportion.x.isFinite && oldInteractionProportion.y.isFinite else { return }

		let oldDisplayedGridPoints = sSize / gScale
		let newDisplayedGridPoints = sSize / (gScale * scaleMultiplier)
		let deltaDisplayedGridPoints = newDisplayedGridPoints - oldDisplayedGridPoints
		let displacedTopLeftGridPoints = deltaDisplayedGridPoints * oldInteractionProportion

		withAnimation(.easeIn(duration: 0.8)) {
			sTranslation += displacedTopLeftGridPoints
			gScale *= scaleMultiplier
			self.sInteractionPoint = sInteractionPoint
			self.scaleSpacing = calculateScaleSpacing(for: gScale)
		}
	}

	
	public func setScreenSize(_ screenSize: CGSize) {
		// Ensure valid dimensions
		if !(screenSize.width.isFinite && screenSize.height.isFinite) {
			return
		}
		if screenSize.width * screenSize.height < 1 {
			return
		}
		self.sSize = screenSize
	}
	
	private func calculateScaleSpacing(for gScale: CGFloat) -> CGFloat {
		let adjustedLineSpacing = sLineSpacing * gScale * scaleSpacing

		if adjustedLineSpacing >= 256 {
			return (128 / (sLineSpacing * gScale))
		} else if adjustedLineSpacing <= 128 {
			return (256 / (sLineSpacing * gScale))
		} else {
			return scaleSpacing
		}
	}
	
	
	@MainActor
		public func drawGrid() -> Path {
			var path: Path = Path()
			
			if gScale <= .zero {
				return path
			}
			
			let adjustedLineSpacing = sLineSpacing * gScale * scaleSpacing
			
			
			let centerX = sSize.width / 2 + sTranslation.x
			let centerY = sSize.height / 2 + sTranslation.y
			
			path.addArc(center: CGPoint(x: centerX, y: centerY), radius: 5, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: true)
			
			var pos: CGFloat = centerX
			while pos >= 0 {
				path.move(to: CGPoint(x: pos, y: 0))
				path.addLine(to: CGPoint(x: pos, y: sSize.height))
				pos -= adjustedLineSpacing
			}
			pos = centerX + adjustedLineSpacing
			while pos < sSize.width {
				path.move(to: CGPoint(x: pos, y: 0))
				path.addLine(to: CGPoint(x: pos, y: sSize.height))
				pos += adjustedLineSpacing
			}
			
			pos = centerY
			while pos >= 0 {
				path.move(to: CGPoint(x: 0, y: pos))
				path.addLine(to: CGPoint(x: sSize.width, y: pos))
				pos -= adjustedLineSpacing
			}
			pos = centerY + adjustedLineSpacing
			while pos < sSize.height {
				path.move(to: CGPoint(x: 0, y: pos))
				path.addLine(to: CGPoint(x: sSize.width, y: pos))
				pos += adjustedLineSpacing
			}
			
			return path
		}

		@MainActor
		public func drawSmallGrid() -> Path {
			var path: Path = Path()
			
			if gScale <= .zero {
				return path
			}
			
			let smallSquareSpacing = sLineSpacing * gScale * scaleSpacing / 5
			
			let centerX = sSize.width / 2 + sTranslation.x
			let centerY = sSize.height / 2 + sTranslation.y
			
			var pos: CGFloat = centerX
			while pos >= 0 {
				path.move(to: CGPoint(x: pos, y: 0))
				path.addLine(to: CGPoint(x: pos, y: sSize.height))
				pos -= smallSquareSpacing
			}
			pos = centerX + smallSquareSpacing
			while pos < sSize.width {
				path.move(to: CGPoint(x: pos, y: 0))
				path.addLine(to: CGPoint(x: pos, y: sSize.height))
				pos += smallSquareSpacing
			}
			
			pos = centerY
			while pos >= 0 {
				path.move(to: CGPoint(x: 0, y: pos))
				path.addLine(to: CGPoint(x: sSize.width, y: pos))
				pos -= smallSquareSpacing
			}
			pos = centerY + smallSquareSpacing
			while pos < sSize.height {
				path.move(to: CGPoint(x: 0, y: pos))
				path.addLine(to: CGPoint(x: sSize.width, y: pos))
				pos += smallSquareSpacing
			}
			
			return path
		}


}
