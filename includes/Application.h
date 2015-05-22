#include "AlertService.h"

@interface Application : NSObject {}

+(id)sharedInstance;
@property(retain) AlertService* alertService;
//@property(retain) GameService* gameService;

@end