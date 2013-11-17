//
//  CPPassPaletteConfig.h
//  PassPalette
//
//  Created by wangsw on 9/22/13.
//  Copyright (c) 2013 codingpotato. All rights reserved.
//

#import "CPHelperMacros.h"

#ifndef _CPPassPaletteConfig_h_
#define _CPPassPaletteConfig_h_

#pragma mark - SECTION: Password

#define PASSWORD_MAX_COUNT 8

#define PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(orientation) \
    (deviceRelatedObj(0, 1) + specifiedOrientationRelatedObj(orientation, 1, 0))
    // This was defined to get index for the array _PASSWORD_RADIUS[] according to current devide and orientation

#define PASSWORD_DEVICE_ORIENTATION_RELATED_INDEX \
    PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(currentOrientation())

#define PASSWORD_SPECIFIED_ORIENTATION_RADIUS(orientation) \
    _PASSWORD_RADIUS[PASSWORD_DEVICE_SEPCIFIED_ORIENTATION_RELATED_INDEX(orientation)]

#define PASSWORD_RADIUS \
    PASSWORD_SPECIFIED_ORIENTATION_RADIUS(currentOrientation())

#define PASSWORD_HORIZON_DISTANCE_MULTIPLIER 1.732 // = sqrt(3)
    // distance between left and center passwords: multiplier * radius

#define PASSWORD_SIZE_MULTIPLIER               0.95 // normal size = RADIUS * size multiplier
#define PASSWORD_DRAG_SIZE_MULTIPLIER          1.15 // drag size = RADIUS * drag multiplier
#define PASSWORD_SHINING_SIZE_MULTIPLIER       0.8  // shinning size = normal size * shinning multiplier
#define PASSWORD_UNUSED_CIRCLE_SIZE_MULTIPLIER 0.75 // circle size = normal size * circle multiplier

#define PASSWORD_DEFAULT_ICON @"Add"

#define PASSWORD_GRADIENT_EXPONENT    1.75
#define PASSWORD_GRADIENT_LEVEL_COUNT 10

#define PASSWORD_DASH_REPEAT_COUNT 15
#define PASSWORD_DASH_LINE_WIDTH   5.0

#define PASSWORD_RANGE_DASH_REPEAT_COUNT 50
#define PASSWORD_RANGE_DASH_LINE_WIDTH   5.0

extern const float _PASSWORD_RADIUS[];

extern const float PASSWORD_COLORS[];

extern const char *PASSWORD_ICON_NAMES[];

#pragma mark - SECTION: Help

#define HELP_PAGE_DELAY_TIME 3.0

#define HELP_BUTTON_VIEW_HEIGHT  deviceRelatedObj(60.0, 60.0)
#define HELP_START_BUTTON_HEIGHT deviceRelatedObj(44.0, 44.0)
#define HELP_START_BUTTON_WIDTH  deviceRelatedObj(200.0, 200.0)
#define HELP_PAGE_CONTROL_HEIGHT deviceRelatedObj(44.0, 44.0)
#define HELP_TEXT_HEIGHT         deviceRelatedObj(60.0, 60.0)
#define HELP_TITLE_HEIGHT        deviceRelatedObj(50.0, 50.0)

#endif
