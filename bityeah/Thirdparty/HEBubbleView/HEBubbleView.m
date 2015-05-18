//
//  HEBubbleView.m
//  HEBubbleView
//
//  Created by Clemens Hammerl on 19.07.12.
//  Copyright (c) 2012 Clemens Hammerl / Adam Eri. All rights reserved.
//

#import "HEBubbleView.h"
#define BUBBLE_ANIMATION_TIME 0.4
#define BUBBLE_FADE_TIME 0.2
@interface HEBubbleView (private)

-(void)renderBubblesAnimated:(BOOL)animated;
-(void)renderBubblesFromIndex:(NSInteger)start toIndex:(NSInteger)end animated:(BOOL)animated;

-(void)showMenuCalloutWthItems:(NSArray *)menuItems forBubbleItem:(HEBubbleViewItem *)item;

-(void)willShowMenuController;
-(void)didHideMenuController;
-(void)fadeInBubble:(HEBubbleViewItem *)item;
-(void)fadeOutBubble:(HEBubbleViewItem *)item;
-(void)removeItem:(HEBubbleViewItem *)item animated:(BOOL)animated;

@end

@implementation HEBubbleView



-(id)init
{
    return [self initWithFrame:CGRectZero];
}

// initializiation
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    
        self.itemHeight = 20.0;
        self.itemPadding = 2;
        self.lineNumber = 1;

        self.items = [[NSMutableArray alloc] init];
        _reuseQueue = [[NSMutableArray alloc] init];
 
        
        self.selectionStyle = HEBubbleViewSelectionStyleDefault;
        
    }
    
    return  self;
}

//////////////////////////// Public methods /////////////////////////////////
#pragma mark - Public methods

// use items from the queue
-(HEBubbleViewItem *)dequeueItemUsingReuseIdentifier:(NSString *)reuseIdentifier
{
    
    HEBubbleViewItem *reuseItem = nil;
    
    for (HEBubbleViewItem *item in self.reuseQueue) {
        
        if ([item.reuseIdentifier isEqualToString:reuseIdentifier]) {

            reuseItem = item;
            break;
            
        }
        
    }
    
    if (reuseItem != nil) {
        [self.reuseQueue removeObject:reuseItem];
    }
    
    
    [reuseItem prepareItemForReuse];
    
    return reuseItem;
    
}

// reloads all data
-(void)reloadData
{
    NSInteger bubbleCount = 0;
    
    // determine item count
    
    if (self.bubbleDataSource != nil && [self.bubbleDataSource respondsToSelector:@selector(numberOfItemsInBubbleView:)]) {
        bubbleCount = [self.bubbleDataSource numberOfItemsInBubbleView:self];
    }
    
    
    // remove all items
    
    for (HEBubbleViewItem *oldItem in self.items) {
        
        [self.reuseQueue addObject:oldItem];
        [oldItem removeFromSuperview];
        
    }
    
    [self.items removeAllObjects];
    
    
    // add the new items
    
    for (int i = 0; i < bubbleCount; i++) {
        
        
        if (self.bubbleDataSource != nil && [self.bubbleDataSource respondsToSelector:@selector(bubbleView:bubbleItemForIndex:)]) {
            HEBubbleViewItem *bubble = [self.bubbleDataSource bubbleView:self bubbleItemForIndex:i];
            
            [self.items addObject:bubble];
            [bubble setBubbleItemIndex:i];
            bubble.delegate = self;
            bubble.frame = CGRectZero;
            [self addSubview:bubble];
        }
        
    }
    
    // render all items
    
    [self renderBubblesAnimated:NO];
}

// removes an item at the given index. data must be inserted by the datasource
// bevore calling this method
-(void)removeItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    
    if (index < 0 || index >= [self.items count]) {
        NSLog(@"Remove item:- Invalid item index.");
        return;
    }
    
    HEBubbleViewItem *item = [self.items objectAtIndex:index];

    [self.reuseQueue addObject:[self.items objectAtIndex:index]];
    [self.items removeObject:item];
    
    
    [self removeItem:item animated:animated];

}


// insert an item at the end of the list. data must be inserted by the datasource
// bevore calling this method
-(void)addItemAnimated:(BOOL)animated
{
    [self insertItemAtIndex:[self.items count] animated:animated];
}

// insert an item at the given index. data must be inserted by the datasource
// bevore calling this method
-(void)insertItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    
    
    if (index < 0) {
        index = 0;
    }
    
    if (index > [self.items count]) {
        index = [self.items count];
        
    }

    if (self.bubbleDataSource != nil && [self.bubbleDataSource respondsToSelector:@selector(bubbleView:bubbleItemForIndex:)]) {
        HEBubbleViewItem *bubble = [self.bubbleDataSource bubbleView:self bubbleItemForIndex:index];

        [self.items insertObject:bubble atIndex:index];
        [bubble setBubbleItemIndex:[self.items indexOfObject:bubble]];

        bubble.delegate = self;
        bubble.frame = CGRectZero;
        [self addSubview:bubble];

        bubble.alpha = 0.0;

        for (int i = 0; i < [self.items count]; i++) {
            HEBubbleViewItem *item = [self.items objectAtIndex:i];
            item.index = i;
        }

        if (animated) {
            
            if ([self.items lastObject] == bubble) {

                [self renderBubblesFromIndex:0 toIndex:[self.items count] animated:NO];
                [self fadeInBubble:bubble];
            }else {

                [self renderBubblesFromIndex:0 toIndex:[self.items count] animated:animated];
                [self performSelector:@selector(fadeInBubble:) withObject:bubble afterDelay:BUBBLE_ANIMATION_TIME+BUBBLE_FADE_TIME];
            }

        }else {
            [self renderBubblesFromIndex:0 toIndex:[self.items count] animated:animated];
            bubble.alpha = 1.0;
            //[self renderBubblesAnimated:animated];
        }
    }
}

//////////////////////////// View Logic /////////////////////////////////
#pragma mark - View Logic

// fades in a bubble after creation
-(void)fadeInBubble:(HEBubbleViewItem *)item
{
    [UIView beginAnimations:@"bubbleFadeIn" context:@"bubbleFade"];
    item.alpha = 1.0;
    [UIView commitAnimations];
}

// fades out a bubble after it has been removed
-(void)fadeOutBubble:(HEBubbleViewItem *)item
{
    
    [UIView beginAnimations:@"bubbleFadeOut" context:@"bubbleFade"];
    [UIView setAnimationDuration:BUBBLE_ANIMATION_TIME];
    item.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(removeItem:animated:) withObject:item afterDelay:BUBBLE_ANIMATION_TIME+BUBBLE_FADE_TIME];
    
}


// remove the given item
-(void)removeItem:(HEBubbleViewItem *)item animated:(BOOL)animated
{
    NSInteger index = 0;
    
    [item removeFromSuperview];

    for (HEBubbleViewItem *bubble in self.items) {
     
        bubble.index = index;
        
        index++;
        
    }
    
    [self renderBubblesAnimated:animated];
}

// render bubbles for a given index
-(void)renderBubblesFromIndex:(NSInteger)start toIndex:(NSInteger)end animated:(BOOL)animated
{
    CGFloat nextBubbleX = self.itemPadding;
    CGFloat nextBubbleY = self.itemPadding;
    
    self.lineNumber = 1;
    
    
    for (int i = start; i < end; i++) {

        HEBubbleViewItem *bubble = [self.items objectAtIndex:i];
        [bubble setSelected:NO animated:animated];
        
        if (self.selectionStyle == HEBubbleViewSelectionStyleNone) {
            bubble.highlightTouches = NO;
        }
        
        CGFloat bubbleWidth = [bubble.textLabel.text sizeWithFont:bubble.textLabel.font constrainedToSize:CGSizeMake(100000, self.itemHeight)].width+2*bubble.bubbleTextLabelPadding;
        
        
        // if bubble width is bigger than frame width cut it off...
        
        if (bubbleWidth >= self.frame.size.width-2*self.itemPadding) {
            bubbleWidth = self.frame.size.width-2*self.itemPadding;
            nextBubbleX = self.itemPadding;
            
            if (self.lineNumber == 1) {
                nextBubbleY += 0;
            }else {
               nextBubbleY += (self.itemHeight+self.itemPadding);
            }
            
            
            self.lineNumber++;
            
        }else if ((nextBubbleX + bubbleWidth) > self.frame.size.width-2*self.itemPadding) {
            self.lineNumber++;
            
            nextBubbleX = self.itemPadding;
            
            
            if (self.lineNumber == 1) {
                nextBubbleY += 0;
            }else {
                nextBubbleY += (self.itemHeight+self.itemPadding);
            }
            
            
        }
        
        CGRect bubbleFrame = CGRectMake(nextBubbleX, nextBubbleY, bubbleWidth, self.itemHeight);
        
        
        if (animated) {
            [UIView beginAnimations:@"bubbleRendering" context:@"bubbleItems"];
            [UIView setAnimationDuration:BUBBLE_ANIMATION_TIME];
            bubble.frame = bubbleFrame;
            
            [UIView commitAnimations];
        }else {
        
            bubble.frame = bubbleFrame;
        
        }

        nextBubbleX += bubble.frame.size.width + self.itemPadding;

    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, self.lineNumber * (self.itemHeight + self.itemPadding) + self.itemPadding);
    
    if (self.bubbleDelegate && [self.bubbleDelegate respondsToSelector:@selector(bubbleView:contentSizeDidChanged:)]) {
        [self.bubbleDelegate bubbleView:self contentSizeDidChanged:self.contentSize];
    }
    

}


// render all bubbles
-(void)renderBubblesAnimated:(BOOL)animated
{

    [self renderBubblesFromIndex:0 toIndex:[self.items count] animated:animated];
    
}

//////////////////////////// Bubble Item Delegate /////////////////////////////////
#pragma mark - Bubble Item Delegate

// Called after a bubble is selected
-(void)selectedBubbleItem:(HEBubbleViewItem *)item
{

    
    if (item == self.activeBubble) {
        return;
    }
    
    
    switch (self.selectionStyle) {
        case HEBubbleViewSelectionStyleDefault:
            [item setSelected:YES animated:YES];
            break;
        case HEBubbleViewSelectionStyleNone:
            [item setSelected:NO animated:NO];
            break;
        default:
            break;
    }
    
    
    
    if ([self.bubbleDelegate respondsToSelector:@selector(bubbleView:didSelectBubbleItemAtIndex:)]) {
        [self.bubbleDelegate bubbleView:self didSelectBubbleItemAtIndex:item.index];
    }
    
    if ([self.bubbleDelegate respondsToSelector:@selector(bubbleView:shouldShowMenuForBubbleItemAtIndex:)]) {
        
        if ([self.bubbleDelegate bubbleView:self shouldShowMenuForBubbleItemAtIndex:item.index]) {
            
            NSArray *menuItems = nil;
            
            if ([self.bubbleDelegate respondsToSelector:@selector(bubbleView:menuItemsForBubbleItemAtIndex:)]) {
                

                
                menuItems = [self.bubbleDelegate bubbleView:self menuItemsForBubbleItemAtIndex:item.index];
            }
            

            
            if (menuItems) {
                [self showMenuCalloutWthItems:menuItems forBubbleItem:item];
            }
            
            
            
        }
        
    }
}

//////////////////////////// Internal Logic /////////////////////////////////
#pragma mark - Bubble Item Delegate

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


 
-(void)willShowMenuController
{
    self.userInteractionEnabled = NO;
}

-(void)didHideMenuController
{

    self.userInteractionEnabled = YES;
    
    [self.activeBubble setSelected:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([self.bubbleDelegate respondsToSelector:@selector(bubbleView:didHideMenuForButtbleItemAtIndex:)]) {
        [self.bubbleDelegate bubbleView:self didHideMenuForBubbleItemAtIndex:self.activeBubble.index];
    }
    
    self.activeBubble = nil;
    
}

/*
 Dismiss the menucontroller when scrollview is hit
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   
    if ([self.menu isMenuVisible]) {
        [self.menu setMenuVisible:NO animated:YES];
    }
    
    //[self resignFirstResponder];
    
}


// Show the menucontroller with the items provides by the delegate
-(void)showMenuCalloutWthItems:(NSArray *)menuItems forBubbleItem:(HEBubbleViewItem *)item
{

    [self becomeFirstResponder];
    
    self.activeBubble = item;
    
    self.menu = [UIMenuController sharedMenuController];
    self.menu.menuItems = nil;
    self.menu.menuItems = menuItems;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowMenuController) name:UIMenuControllerWillShowMenuNotification object:self.menu];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideMenuController) name:UIMenuControllerDidHideMenuNotification object:self.menu];
    
    [self.menu setTargetRect:item.frame inView:self];
    [self.menu setMenuVisible:YES animated:YES];
    
}


@end
