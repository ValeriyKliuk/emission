BREW := $(shell command -v brew 2> /dev/null)
YARN := $(shell command -v yarn 2> /dev/null)
WATCHMAN := $(shell command -v watchman 2> /dev/null)
CODE := $(shell command -v code 2> /dev/null)

setup:
ifndef BREW
    $(error "Please install homebrew before running `make oss`: https://brew.sh")
endif

ifndef YARN
	@echo "Installing Yarn"
	brew install yarn
endif

ifndef WATCHMAN
	@echo "Installing Watchman"
	brew install pcre
	brew link pcre
	brew install watchman --HEAD
endif

ifndef CODE
	@echo "Installing Visual Studio Code"
	brew cask install visual-studio-code
endif

	@echo "Installing Node Dependencies"
	yarn install

	@echo "Installing Hooks for Styling and Compile-checks"
	echo "#!/bin/sh\nyarn run lint-staged\n" > .git/hooks/pre-commit; chmod +x .git/hooks/pre-commit
	echo "#!/bin/sh\nyarn run type-check\n" > .git/hooks/pre-push; chmod +x .git/hooks/pre-push

	@echo "";
	@echo "";
	@echo "That is all of the dependencies for Emission set up, to run the app:";
	@echo "";
	@echo " - Ensure you have an Artsy account: $$(tput setaf 3)https://www.artsy.net/sign_up$$(tput sgr0)"
	@echo " - Open the folder in VS Code: '$$(tput setaf 3)code .$$(tput sgr0)'"
	@echo " - Start the dev server: '$$(tput setaf 3)yarn start$$(tput sgr0)'"
	@echo " - Open Xcode, and run Emission: '$$(tput setaf 3)open Example/Emission.xcworkspace$$(tput sgr0)'"
	@echo ""
	@echo "Any other details can be found in the README."
	@echo "Enjoy!"
	@echo ""


artsy:
	cd Example && bundle && bundle exec pod install

oss:
	@echo "Installing Cocoa Dependencies"
	cd Example && bundle && bundle exec pod keys set ArtsyAPIClientSecret "3a33d2085cbd1176153f99781bbce7c6" Emission
	cd Example && bundle exec pod keys set ArtsyAPIClientKey "e750db60ac506978fc70"


JQ := $(shell command -v jq 2> /dev/null)
RNVERSION=$(shell cd node_modules/react-native && pod ipc spec React.podspec | jq '.version' -r)
YOGAVERSION=$(shell cd node_modules/react-native/ReactCommon/yoga && pod ipc spec yoga.podspec | jq '.version' -r)
FOLLYVERSION=$(shell cd node_modules/react-native/third-party-podspecs && pod ipc spec Folly.podspec | jq '.version' -r)
DOUBLECONVERSIONVERSION=$(shell cd node_modules/react-native/third-party-podspecs && pod ipc spec DoubleConversion.podspec | jq '.version' -r)
GLOGVERSION=$(shell cd node_modules/react-native/third-party-podspecs && pod ipc spec glog.podspec | jq '.version' -r)
YOGA_SRC_BEFORE=yoga\/\*\*\/\*.{c,h}
YOGA_SRC_AFTER=ReactCommon\/yoga\/yoga\/\*\*\/\*.\{c,h\}

update_specs_repos:
ifndef JQ
		$(error "Please install jq before running `brew install jq`")
endif

	@echo "Updating Artsy specs repo";
	pod repo update artsy

	@echo "Creating folder in artsy specs repo";
	mkdir ~/.cocoapods/repos/artsy/React/$(RNVERSION)
	mkdir ~/.cocoapods/repos/artsy/yoga/$(YOGAVERSION)
	mkdir ~/.cocoapods/repos/artsy/Folly/$(FOLLYVERSION)
	mkdir ~/.cocoapods/repos/artsy/DoubleConversion/$(DOUBLECONVERSIONVERSION)
	mkdir ~/.cocoapods/repos/artsy/glog/$(GLOGVERSION)

	@echo "Putting JSON specs in the folders";
	cd node_modules/react-native && pod ipc spec React.podspec >  ~/.cocoapods/repos/artsy/React/$(RNVERSION)/React.podspec.json
	cd node_modules/react-native/ReactCommon/yoga && pod ipc spec yoga.podspec >  ~/.cocoapods/repos/artsy/yoga/$(YOGAVERSION)/yoga.podspec.json
	cd node_modules/react-native/third-party-podspecs && pod ipc spec Folly.podspec >  ~/.cocoapods/repos/artsy/Folly/$(FOLLYVERSION)/Folly.podspec.json
	cd node_modules/react-native/third-party-podspecs && pod ipc spec DoubleConversion.podspec >  ~/.cocoapods/repos/artsy/DoubleConversion/$(DOUBLECONVERSIONVERSION)/DoubleConversion.podspec.json
	cd node_modules/react-native/third-party-podspecs && pod ipc spec glog.podspec >  ~/.cocoapods/repos/artsy/glog/$(GLOGVERSION)/glog.podspec.json

	@echo "Modifying Yoga to reflect the React Native repo paths"
	sed -i -e 's/$(YOGA_SRC_BEFORE)/$(YOGA_SRC_AFTER)/g' ~/.cocoapods/repos/artsy/Yoga/$(YOGAVERSION)/Yoga.podspec.json

	@echo "Commiting the changes to our shared repo"
	cd ~/.cocoapods/repos/artsy && git add .
	cd ~/.cocoapods/repos/artsy && git commit -m "Shipping a new version of the React deps: v$(RNVERSION) for Emission deploys"
	cd ~/.cocoapods/repos/artsy && git push
