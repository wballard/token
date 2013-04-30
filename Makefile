
DIFF?=git --no-pager diff --ignore-all-space --color-words --no-index
TOKEN?=./bin/token --directory ./___

.PHONY: test

test: 
	-rm -rf  ./___
	$(TOKEN) init
	echo 'Hi There' | $(TOKEN) data user@sample.com | cat
	$(TOKEN) create user@sample.com | tee /tmp/sampletoken
	$(TOKEN) decode `cat /tmp/sampletoken` \
	| tee /tmp/$@
	$(TOKEN) decode badtoken \
	| tee -a /tmp/$@
	$(DIFF) /tmp/$@ test/expected/$@

test_pass:
	DIFF=cp $(MAKE) test
