@interface MatchLogic : NSObject {}
-(void)endMatch;
-(void)endRound;
-(void)playerChoseAnswer:(id)answer;
-(id)showCorrectAnswerForRound:(int)round question:(id)question;
@end