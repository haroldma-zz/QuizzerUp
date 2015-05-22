@interface Answer : NSObject {}

@property(readonly, assign) NSString* text;
//answer id
@property(retain, nonatomic) NSString* ID;

@end