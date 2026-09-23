DESTDIR?=
PREFIX?=	$${HOME}/.local

PROGRAM=	mergedotpkg

all: .PHONY

install: .PHONY
	mkdir "${DESTDIR}${PREFIX}/bin"
	install -m 0755 "${PROGRAM}" "${DESTDIR}${PREFIX}/bin/${PROGRAM}"

test: .PHONY
	(cd tests && kyua test || kyua report --verbose)
