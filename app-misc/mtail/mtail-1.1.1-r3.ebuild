# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit eutils python-single-r1

DESCRIPTION="Tail workalike, that performs output colourising"
HOMEPAGE="http://matt.immute.net/src/mtail/"
SRC_URI="http://matt.immute.net/src/mtail/mtail-${PV}.tgz
	http://matt.immute.net/src/mtail/mtailrc-syslog.sample"

LICENSE="HPND"
SLOT="0"
KEYWORDS="alpha amd64 ~mips ppc sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=${PYTHON_DEPS}
REQUIRED_USE=${PYTHON_REQUIRED_USE}

src_prepare() {
	epatch "${FILESDIR}"/${P}-remove-blanks.patch
	python_fix_shebang .
}

src_install() {
	dobin "${PN}"
	dodoc CHANGES "${PN}rc.sample" README "${DISTDIR}"/mtailrc-syslog.sample || die
}
