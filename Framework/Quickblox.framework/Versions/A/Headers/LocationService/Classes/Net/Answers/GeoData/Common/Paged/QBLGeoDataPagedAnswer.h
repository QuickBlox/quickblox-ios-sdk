//
//  QBLGeoDataPagedAnswer.h
//  LocationService
//
//  Created by Igor Khomenko on 2/3/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBLGeoDataPagedAnswer : PagedAnswer{
	QBLGeoDataAnswer *geodataAnswer;
    
	NSMutableArray *geodata;
}

@property (nonatomic, retain) NSMutableArray *geodata;

@end
