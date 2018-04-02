//
//  PlaneCGScreen.mm
//  ios-bridge
//
//  Created by Fredrik on 31.03.18.
//  Copyright © 2018 fwcd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaneCGScreen.h"

PlaneCGScreen::PlaneCGScreen(PlaneCGView* view) {
    this->view = view;
	paintables = std::vector<std::shared_ptr<IPaintable>>();
	mouseListeners = std::vector<std::shared_ptr<MouseListener>>();
	keyListeners = std::vector<std::shared_ptr<KeyListener>>();
}

PlaneCGScreen::PlaneCGScreen(const PlaneCGScreen& screen) {
	view = screen.view;
	paintables = screen.paintables;
	mouseListeners = screen.mouseListeners;
	keyListeners = screen.keyListeners;
}

PlaneCGScreen::~PlaneCGScreen() {
    
}

void PlaneCGScreen::repaintSoon() {
    [view repaint];
}

UIColor* PlaneCGScreen::toUIColor(Color color) {
    CGFloat r = color.getRed() / 255.0;
    CGFloat g = color.getGreen() / 255.0;
    CGFloat b = color.getBlue() / 255.0;
    CGFloat a = color.getAlpha() / 255.0;
	
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

Color PlaneCGScreen::fromUIColor(UIColor* color) {
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    [color getRed:&r green:&g blue:&b alpha:&a];
	
    return Color((int) (r * 255.0), (int) (g * 255.0), (int) (b * 255.0), (int) (a * 255.0));
}

void PlaneCGScreen::setBackground(Color color) {
    [view setBackgroundColor:toUIColor(color)];
}

Color PlaneCGScreen::getBackground() {
    return fromUIColor([view backgroundColor]);
}

float PlaneCGScreen::getWidth() {
    return [view bounds].size.width;
}

float PlaneCGScreen::getHeight() {
    return [view bounds].size.height;
}

void PlaneCGScreen::drawRect(float x, float y, float w, float h, Stroke stroke) {
	[view enqueueRect:[[PlaneBox alloc]
					   initAtX:x
					   andY:y
					   withWidth:w
					   andHeight:h
					   filled:false
					   color:toUIColor(stroke.getColor())]];
}

void PlaneCGScreen::fillRect(float x, float y, float w, float h, Fill fill) {
    [view enqueueRect:[[PlaneBox alloc]
					   initAtX:x
					   andY:y
					   withWidth:w
					   andHeight:h
					   filled:true
					   color:toUIColor(fill.getColor())]];
}

void PlaneCGScreen::drawOval(float x, float y, float w, float h, Stroke stroke) {
    [view enqueueOval:[[PlaneBox alloc]
					   initAtX:x
					   andY:y
					   withWidth:w
					   andHeight:h
					   filled:false
					   color:toUIColor(stroke.getColor())]];
}

void PlaneCGScreen::fillOval(float x, float y, float w, float h, Fill fill) {
    [view enqueueOval:[[PlaneBox alloc]
					   initAtX:x
					   andY:y
					   withWidth:w
					   andHeight:h
					   filled:true
					   color:toUIColor(fill.getColor())]];
}

void PlaneCGScreen::drawImage(std::string filePath, float x, float y, float& returnedW, float& returnedH) {
    // TODO
}

void PlaneCGScreen::drawImageSized(std::string filePath, float x, float y, float w, float h) {
    // TODO
}

void PlaneCGScreen::drawString(std::string str, float x, float y, FontAttributes attribs) {
	NSString* nsStr = [[NSString alloc] initWithCString:str.c_str() encoding:NSUTF8StringEncoding];
	[view enqueueString:[[PlaneString alloc]
						 initAtX:x
						 andY:y
						 value:nsStr
						 size:attribs.getSize()
						 bold:attribs.isBold()
						 italic:attribs.isItalic()
						 underlined:attribs.isUnderlined()
						 color:toUIColor(attribs.getColor())]];
}

float PlaneCGScreen::getStringWidth(std::string str, FontAttributes attribs) {
	return str.length() * attribs.getSize(); // TODO
}

float PlaneCGScreen::getStringHeight(std::string str, FontAttributes attribs) {
	return attribs.getSize(); // TODO
}

void PlaneCGScreen::drawLine(float startX, float startY, float endX, float endY, Stroke stroke) {
	[view enqueueLine:[[PlaneLine alloc]
					   initFromX:startX
					   y:startY
					   toX:endX
					   y:endY
					   withColor:toUIColor(stroke.getColor())]];
}

void PlaneCGScreen::addOnTop(std::shared_ptr<IPaintable> paintable) {
	paintables.push_back(paintable);
}

void PlaneCGScreen::addOnBottom(std::shared_ptr<IPaintable> paintable) {
	paintables.insert(paintables.begin(), paintable);
}

void PlaneCGScreen::remove(std::shared_ptr<IPaintable> paintable) {
	paintables.erase(std::remove(paintables.begin(), paintables.end(), paintable), paintables.end());
}

void PlaneCGScreen::addKeyListener(std::shared_ptr<KeyListener> keyListener) {
	keyListeners.push_back(keyListener);
}

void PlaneCGScreen::addMouseListener(std::shared_ptr<MouseListener> mouseListener) {
	mouseListeners.push_back(mouseListener);
}

void PlaneCGScreen::removeKeyListener(std::shared_ptr<KeyListener> keyListener) {
	keyListeners.erase(std::remove(keyListeners.begin(), keyListeners.end(), keyListener), keyListeners.end());
}

void PlaneCGScreen::removeMouseListener(std::shared_ptr<MouseListener> mouseListener) {
	mouseListeners.erase(std::remove(mouseListeners.begin(), mouseListeners.end(), mouseListener), mouseListeners.end());
}

void PlaneCGScreen::onRender() {
	for (std::shared_ptr<IPaintable> paintable : paintables) {
		paintable->paint(*this);
	}
}

void PlaneCGScreen::onTouchDown(MouseEvent event) {
	for (std::shared_ptr<MouseListener> listener : mouseListeners) {
		listener->fireClick(event);
	}
	repaintSoon();
}

void PlaneCGScreen::onTouchMove(MouseEvent event) {
	for (std::shared_ptr<MouseListener> listener : mouseListeners) {
		listener->fireDrag(event);
	}
	repaintSoon();
}

void PlaneCGScreen::onTouchUp(MouseEvent event) {
	for (std::shared_ptr<MouseListener> listener : mouseListeners) {
		listener->fireRelease(event);
	}
	repaintSoon();
}