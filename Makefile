DESTDIR?=
PREFIX?=	$${HOME}/.local

PROGRAM=	mergedotpkg

all: .PHONY

install: .PHONY
	install -m 0755 "${PROGRAM}" "${DESTDIR}${PREFIX}/bin/${PROGRAM}"
