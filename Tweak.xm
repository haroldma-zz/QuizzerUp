////////////////////////////
//Interfaces
////////////////////////////

@interface Question : NSObject {}

//index to the correct answer ;)
@property(assign, nonatomic) int correctAnswerIndex;

//answers array
@property(retain, nonatomic) NSMutableArray* answers;

@end

@interface Answer : NSObject {}

//answer id
@property(retain, nonatomic) NSString* ID;

@end

@interface MatchScene : NSObject {}
//called when the user selects an answer. the parameter is for the id.
- (void)playerChoseAnswer:(id)answer;
@end

////////////////////////////
////////////////////////////

//local variable use for storing the current question
Question *currentQuestion;

//Hooking to the match scene (where all the magic happens)
%hook MatchScene

//display the answers (using it to get the question object)
-(void)showAnswersForQuestion:(id)question animationTime:(float)time{
	%orig;

	//update the current question
	currentQuestion = question;
}

//user can now chose an answer, we do it for them ;)
-(void)answerPeriodStarted:(double)started{
	%orig;

	//get the correct answer
	Answer *correctAnswer = [currentQuestion.answers
															objectAtIndex:currentQuestion.correctAnswerIndex];

  //call the following method to select it (passing the id only)
  [self playerChoseAnswer:correctAnswer.ID];
}

%end
