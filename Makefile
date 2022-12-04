NVIM_BIN ?= nvim
out.txt:
	$(NVIM_BIN) --headless -c 'so main.lua' -c 'qa!'
.PHONY: out.txt
