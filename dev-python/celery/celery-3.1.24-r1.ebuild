# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 python3_{4,5} )

inherit distutils-r1 bash-completion-r1

DESCRIPTION="Asynchronous task queue/job queue based on distributed message passing"
HOMEPAGE="http://celeryproject.org/ https://pypi.python.org/pypi/celery"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
# There are a number of other optional 'extras' which overlap with those of kombu, however
# there has been no apparent expression of interest or demand by users for them. See requires.txt
IUSE="doc examples redis sqs test yaml zeromq"

RDEPEND="
	<dev-python/kombu-3.1[${PYTHON_USEDEP}]
	>=dev-python/kombu-3.0.36[${PYTHON_USEDEP}]
	>=dev-python/anyjson-0.3.3[${PYTHON_USEDEP}]
	>=dev-python/billiard-3.3.0.23[${PYTHON_USEDEP}]
	<dev-python/billiard-3.4[${PYTHON_USEDEP}]
	dev-python/pytz[${PYTHON_USEDEP}]
	dev-python/greenlet[${PYTHON_USEDEP}]
"

DEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( ${RDEPEND}
		dev-python/gevent[$(python_gen_usedep python2_7)]
		>=dev-python/mock-1.0.1[${PYTHON_USEDEP}]
		dev-python/nose-cover3[${PYTHON_USEDEP}]
		>=dev-python/pymongo-2.6.2[${PYTHON_USEDEP}]
		dev-python/pyopenssl[${PYTHON_USEDEP}]
		>=dev-python/python-dateutil-2.1[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		dev-python/redis-py[${PYTHON_USEDEP}]
		>=dev-db/redis-2.8.0
		>=dev-python/boto-2.13.3[${PYTHON_USEDEP}]
		>=dev-python/pyzmq-13.1.0[${PYTHON_USEDEP}]
		>=dev-python/pyyaml-3.10[${PYTHON_USEDEP}]
	)
	doc? (
		dev-python/docutils[${PYTHON_USEDEP}]
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/jinja[${PYTHON_USEDEP}]
		dev-python/sqlalchemy[${PYTHON_USEDEP}]
		)"

PATCHES=(
	"${FILESDIR}"/celery-docs.patch
	"${FILESDIR}"/${PN}-3.1.19-test.patch
)

# testsuite needs it own source
DISTUTILS_IN_SOURCE_BUILD=1

python_compile_all() {
	if use doc; then
		mkdir docs/.build || die
		emake -C docs html
	fi
}

python_test() {
	nosetests --verbose || die "Tests failed with ${EPYTHON}"
}

python_install_all() {
	# Main celeryd init.d and conf.d
	newinitd "${FILESDIR}/celery.initd-r2" celery
	newconfd "${FILESDIR}/celery.confd-r2" celery

	use examples && local EXAMPLES=( examples/. )

	use doc && local HTML_DOCS=( docs/.build/html/. )

	newbashcomp extra/bash-completion/celery.bash ${PN}

	distutils-r1_python_install_all
}

pkg_postinst() {
	optfeature "zookeper support" dev-python/kazoo
	optfeature "msgpack support" dev-python/msgpack
	#optfeature "rabbitmq support" dev-python/librabbitmq
	#optfeature "slmq support" dev-python/softlayer_messaging
	optfeature "eventlet support" dev-python/eventlet
	#optfeature "couchbase support" dev-python/couchbase
	optfeature "redis support" dev-db/redis dev-python/redis-py
	optfeature "couchdb support" dev-db/couchdb dev-python/couchdb-python
	optfeature "gevent support" dev-python/gevent
	optfeature "auth support" dev-python/pyopenssl
	optfeature "pyro support" dev-python/pyro:4
	optfeature "yaml support" dev-python/pyyaml
	optfeature "beanstalk support" dev-python/beanstalkc
	optfeature "memcache support" dev-python/pylibmc
	#optfeature "threads support" dev-python/threadpool
	optfeature "mongodb support" dev-python/pymongo
	optfeature "zeromq support" dev-python/pyzmq
	optfeature "sqlalchemy support" dev-python/sqlalchemy
	optfeature "sqs support" dev-python/boto
	#optfeature "cassandra support" dev-python/pycassa
}
