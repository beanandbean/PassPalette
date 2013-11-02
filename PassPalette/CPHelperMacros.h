//
// CPHelperMacros.h
//

#ifndef _HELPER_MACROS_
#define _HELPER_MACROS_

/* Note: 'n_s' is short for 'Type Not Specified' */

#define cstrToObjc(str) \
    /* NSString cstrToObjc(char *str)
     * 
     * *** Category: System ***
     * - Convert c string to NSString.
     * - Note: Using ASCII for string encoding.
     */ \
    [NSString stringWithCString:(str) encoding:NSASCIIStringEncoding]

#define currentOrientation() \
    /* UIInterfaceOrientation currentOrientation() 
     *
     * *** Category: User Interface ***
     * - Get current interface orientation.
     */ \
    ([UIApplication sharedApplication].statusBarOrientation)

#define delayBlock(delay, block) \
    /* void delayBlock(float delay, void (^block)(void))
     *
     * *** Category: System ***
     * - Delay the execution of (block) for (delay) seconds.
     * - Warning: Avoid comma in (block) because it will break the macro.
     */ \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay) * NSEC_PER_SEC)), dispatch_get_main_queue(), (block))

#define deviceRelatedObj(phone, pad) \
    /* n_s deviceRelatedObj(n_s phone, n_s pad)
     *
     * *** Category: User Interface ***
     * - Return (phone) if the app is running on iPhone, and (pad) if iPad.
     */ \
    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? (phone) : (pad))

#define isPointInCircle(center, radius, point) \
    /* BOOL isPointInCircle(CGPoint center, CGFloat radius, CGPoint point)
     *
     * *** Category: Core Graphics ***
     * - Determine if (point) is in the specified circle.
     */ \
    (((point).x - (center).x) * ((point).x - (center).x) + ((point).y - (center).y) * ((point).y - (center).y) <= (radius) * (radius))


#define orientationRelatedObj(landscape, portrait) \
    /* n_s orientationRelatedObj(n_s landscape, n_s portrait) 
     *
     * *** Category: User Interface ***
     * - Return (landscape) if the device is currently landscape, and (portrait) if portrait.
     */ \
    specifiedOrientationRelatedObj(CURRENT_ORIENTATION, (landscape), (portrait))

#define ownCoordinateViewCenter(view) \
    /* CGPoint ownCoordinateViewCenter(UIView *view)
     *
     * *** Category: Core Graphics ***
     * - Return the center point of (view) in its own coordinate system.
     */ \
    CGPointMake((view).frame.size.width / 2, (view).frame.size.height / 2)

#define rectWithCenterAndSize(center, size) \
    /* CGRect rectWithCenterAndSize(CGPoint center, CGSize size)
     *
     * *** Category: Core Graphics ***
     * - Return a CGRect with specified center and size.
     */ \
    CGRectMake((center).x - (size).width / 2, (center).y - (size).height / 2, (size).width, (size).height)

#define rectContainingCircle(center, radius) \
    /* CGRect rectContainingCircle(CGPoint center, CGFloat radius)
     *
     * *** Category: Core Graphics ***
     * - Return a CGRect containing the specified circle.
     */ \
    CGRectMake((center).x - (radius), (center).y - (radius), (radius) * 2, (radius) * 2)

#define specifiedOrientationRelatedObj(orientation, landscape, portrait) \
    /* n_s specifiedOrientationRelatedObj(UIInterfaceOrientation orientation, n_s landscape, n_s portrait)
     *
     * *** Category: User Interface ***
     * - Return (landscape) if (orientation) represents landscape, and (portrait) if portrait.
     */ \
    (UIInterfaceOrientationIsLandscape(orientation) ? (landscape) : (portrait))

#endif
