//
//  Exception.h
//  Pods
//
//  Created by William on 8/4/21.
//

#ifndef Exception_h
#define Exception_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* Exception_h */
