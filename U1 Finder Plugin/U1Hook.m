/*
 * Ubuntu One Finder Plugin
 * Copyright (C) 2012 - José Expósito <jose.exposito89@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
#import "U1Hook.h"
#import <objc/objc-class.h>

@implementation U1Hook

+ (void)hookMethod:(SEL)oldSelector inClass:(NSString *)className toCallToTheNewMethod:(SEL)newSelector
{
    Class hookedClass = NSClassFromString(className);
    Method oldMethod = class_getInstanceMethod(hookedClass, oldSelector);
    Method newMethod = class_getInstanceMethod(hookedClass, newSelector);
    method_exchangeImplementations(newMethod, oldMethod);
}

+ (void)hookClassMethod:(SEL)oldSelector inClass:(NSString *)className toCallToTheNewMethod:(SEL)newSelector
{
    Class hookedClass = NSClassFromString(className);
    Method oldMethod = class_getClassMethod(hookedClass, oldSelector);
    Method newMethod = class_getClassMethod(hookedClass, newSelector);
    method_exchangeImplementations(newMethod, oldMethod);
}

@end
