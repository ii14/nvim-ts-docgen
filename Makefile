NVIM ?= nvim
out.txt:
	$(NVIM) --headless -c 'so main.lua' -c 'qa!'
.PHONY: out.txt
