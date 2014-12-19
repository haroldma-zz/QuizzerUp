@interface PSListController
{
	id _specifiers;
}
-(id)specifiers;
-(id)loadSpecifiersFromPlistName:(id)name target:(id)target;
@end
@interface QuizzerUpPrefsListController: PSListController {
}
@end


@implementation QuizzerUpPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"QuizzerUpPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
