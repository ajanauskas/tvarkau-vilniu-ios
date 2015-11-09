//
//  UIImagePickerController+OrientationFix.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 08/09/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "UIImagePickerController+OrientationFix.h"

@implementation UIImagePickerController (OrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIInterfaceOrientationMaskAll : UIInterfaceOrientationMaskPortrait;
}

@end
