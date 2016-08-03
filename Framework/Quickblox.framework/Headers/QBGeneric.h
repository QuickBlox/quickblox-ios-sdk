//
//  QBGeneric.h
//  Quickblox
//
//  Created by Injoit on 9/29/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#ifndef Quickblox_QBGeneric_h
#define Quickblox_QBGeneric_h

#if __has_feature(objc_generics) || __has_extension(objc_generics)
#  define QB_GENERIC(...) <__VA_ARGS__>
#else
#  define QB_GENERIC(...)
#endif

#endif /* QBGeneric_h */
