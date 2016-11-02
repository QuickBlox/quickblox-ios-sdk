//
//  Header.h
//  Quickblox
//
//  Created by Injoit on 9/29/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#ifndef Quickblox_QBNullability_h
#define Quickblox_QBNullability_h

///--------------------------------------
/// @name Nullability Annotation Support
///--------------------------------------
#if !__has_feature(nullability)
    #define NS_ASSUME_NONNULL_BEGIN
    #define NS_ASSUME_NONNULL_END
    #define nullable
    #define nonnull
    #define null_unspecified
    #define null_resettable
    #define _Nullable
    #define _Nonnull
    #define __nullable
    #define __nonnull
    #define __null_unspecified
    #define _Nullable
    #define _Nonnull
#endif

// Old nullability logic
#if __has_feature(nullability)
#   define QB_NONNULL nonnull
#   define QB_NONNULL_S __nonnull
#   define QB_NULLABLE nullable
#   define QB_NULLABLE_S __nullable
#   define QB_NULLABLE_PROPERTY nullable,
#   define QB_NONNULL_PROPERTY nonnull,
#else
#   define QB_NONNULL
#   define QB_NONNULL_S
#   define QB_NULLABLE
#   define QB_NULLABLE_S
#   define QB_NULLABLE_PROPERTY
#   define QB_NONNULL_PROPERTY
#endif

#endif /* QBNullability_h */
