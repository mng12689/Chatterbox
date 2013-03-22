//
//  NSError+ParseErrorCodes.h
//  Chatterbox
//
//  Created by Michael Ng on 3/21/13.
//  Copyright (c) 2013 Michael Ng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (ParseErrorCodes)

-(NSString *)userFriendlyParseErrorDescription:(BOOL)isUserRelated;
- (void)handleErrorWithAlert:(BOOL)isUserRelated;
@end
