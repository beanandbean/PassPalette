//
//  CPInteractiveTransition.h
//  PassPalette
//
//  Created by wangyw on 1/4/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@protocol CPInteractiveTransitioning <NSObject>

- (void)updateInteractiveTranstionByTranslation:(CGPoint)translation;
- (void)finishInteractiveTranstion;
- (void)cancelInteractiveTransition;

@end
