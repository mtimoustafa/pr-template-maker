.PHONY: pr

pr:
	ruby -r ./concerns/pr_maker.rb -e ::PrMaker.make_pr
