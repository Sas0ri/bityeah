//
//  BYDefinitions.h
//  bityeah
//
//  Created by Sasori on 15/5/18.
//  Copyright (c) 2015年 bityeah. All rights reserved.
//

#ifndef bityeah_BYDefinitions_h
#define bityeah_BYDefinitions_h

//设备屏幕尺寸
#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame    (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))
#define kScreen_CenterX  kScreen_Width/2
#define kScreen_CenterY  kScreen_Height/2

#define BaseIOS7 ([UIDevice currentDevice].systemVersion.doubleValue >= 7.0)
#define BaseIOS8 ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)

#define kFrame_Width    self.view.frame.size.width
#define kFrame_Height   self.view.frame.size.height

#ifndef __NO_LOG__
#define NSLog(format, ...) do {                                                                          \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)
#else
# define NSLog(...) {}
#endif

#endif
