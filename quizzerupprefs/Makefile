ARCHS = armv7 arm64
include theos/makefiles/common.mk

BUNDLE_NAME = QuizzerUpPrefs
QuizzerUpPrefs_FILES = QuizzerUpPrefs.mm
QuizzerUpPrefs_INSTALL_PATH = /Library/PreferenceBundles
QuizzerUpPrefs_FRAMEWORKS = UIKit
QuizzerUpPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/QuizzerUpPrefs.plist$(ECHO_END)
