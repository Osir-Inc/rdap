# Makefile for rdap - Simple RDAP Client
# 
# Usage:
#   make install          - Install to /usr/local/bin (requires sudo)
#   make install-user     - Install to ~/.local/bin (no sudo needed)
#   make uninstall        - Remove from /usr/local/bin
#   make uninstall-user   - Remove from ~/.local/bin

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
DOCDIR ?= $(PREFIX)/share/doc/rdap

USER_PREFIX ?= $(HOME)/.local
USER_BINDIR ?= $(USER_PREFIX)/bin
USER_MANDIR ?= $(USER_PREFIX)/share/man/man1

.PHONY: all install install-user uninstall uninstall-user check

all:
	@echo "rdap - Simple RDAP Client"
	@echo ""
	@echo "Usage:"
	@echo "  make install        - Install system-wide (requires sudo)"
	@echo "  make install-user   - Install for current user only"
	@echo "  make uninstall      - Remove system-wide installation"
	@echo "  make uninstall-user - Remove user installation"
	@echo "  make check          - Verify script syntax"

check:
	@bash -n rdap && echo "Syntax OK"

install: check
	install -d $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)
	install -d $(DESTDIR)$(DOCDIR)
	install -m 755 rdap $(DESTDIR)$(BINDIR)/rdap
	install -m 644 rdap.1 $(DESTDIR)$(MANDIR)/rdap.1
	gzip -f $(DESTDIR)$(MANDIR)/rdap.1
	install -m 644 README.md $(DESTDIR)$(DOCDIR)/README.md
	@echo ""
	@echo "Installed to $(BINDIR)/rdap"
	@echo "Run 'rdap --help' to get started"

install-user: check
	install -d $(USER_BINDIR)
	install -d $(USER_MANDIR)
	install -m 755 rdap $(USER_BINDIR)/rdap
	install -m 644 rdap.1 $(USER_MANDIR)/rdap.1
	gzip -f $(USER_MANDIR)/rdap.1
	@echo ""
	@echo "Installed to $(USER_BINDIR)/rdap"
	@echo ""
	@echo "Make sure $(USER_BINDIR) is in your PATH:"
	@echo '  export PATH="$$HOME/.local/bin:$$PATH"'
	@echo ""
	@echo "Add to ~/.bashrc or ~/.zshrc for persistence"

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/rdap
	rm -f $(DESTDIR)$(MANDIR)/rdap.1.gz
	rm -rf $(DESTDIR)$(DOCDIR)
	@echo "Uninstalled from $(BINDIR)"

uninstall-user:
	rm -f $(USER_BINDIR)/rdap
	rm -f $(USER_MANDIR)/rdap.1.gz
	@echo "Uninstalled from $(USER_BINDIR)"
