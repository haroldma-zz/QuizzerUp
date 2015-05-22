@interface Question : NSObject {}

@property(readonly, assign) NSString* ID;

// answers array
@property(readonly, assign) NSArray* answers;

// unlike v1.0, there is only a property for the id and not the index
@property(readonly, assign) NSString* correctAnswerID;
// but there is this handy method ;)
-(int)indexForAnswerID:(id)answerID;

@end