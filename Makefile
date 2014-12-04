all:
	$(MAKE) ipa
	$(MAKE) app

clean:
	rm -rf build
	rm -rf LPSimpleExample-cal.ipa
	rm -rf LPSimpleExample-cal.app

ipa:
	rm -rf LPSimpleExample-cal.ipa
	./xtc-prepare.sh
	cp xtc-staging/LPSimpleExample-cal.ipa ./

app:
	rm -rf LPSimpleExample-cal.app
	./sim-prepare.sh
