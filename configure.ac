#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([xde-setup],[1.1],[bugs@openss7.org],[xde-setup])
AC_REVISION([1.1])

AC_CONFIG_SRCDIR([configure.ac])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([scripts])
AC_USE_SYSTEM_EXTENSIONS
AC_CANONICAL_TARGET

DATE='2017-09-10'
AC_SUBST([DATE])

BRANCH='master'
AC_SUBST([BRANCH])

# Initialize Automake
AM_INIT_AUTOMAKE([gnits 1.14 dist-xz no-dist-gzip std-options -Wall color-tests silent-rules tar-pax])
AM_MAINTAINER_MODE
AM_SILENT_RULES([yes])
AC_PREFIX_DEFAULT([/usr])

# Checks for programs.
AC_PROG_SED
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

AC_ARG_VAR([MARKDOWN],[markdown command. @<:@default=markdown@:>@])
AC_CHECK_PROGS([MARKDOWN],[markdown],[${am_missing_run}markdown],[$PATH])

AC_ARG_VAR([ASCIIDOC],[asciidoc command. @<:@default=asciidoctor@:>@])
AC_CHECK_PROGS([ASCIIDOC],[asciidoctor asciidoc],[${am_missing_run}asciidoctor],[$PATH])

AC_ARG_VAR([ASCIIDOC_BACKEND],[asciidoc backend @<:@default=NONE@:>@])
if test -z "$ASCIIDOC_BACKEND"; then
	case "$ASCIIDOC" in
		asciidoc) ASCIIDOC_BACKEND="--backend=html4" ;;
		asciidoctor) ASCIIDOC_BACKEND="--backend=html5" ;;
		*) AC_MSG_WARN([ASCIIDOC $ASCIIDOC is not supported.]) ;;
	esac
fi

AC_ARG_VAR([ASCIIMAN],[asciidoc to manpage converter. @<:@default=asciidoctor@:>@])
AC_CHECK_PROGS([ASCIIMAN],[asciidoctor a2x],[${am_missing_run}asciidoctor],[$PATH])

AC_ARG_VAR([ASCIIMAN_FORMAT],[asciidoc manpage option @<:@default=NONE@:>@])
if test -z "$ASCIIMAN_FORMAT"; then
	case "$ASCIIMAN" in
		a2x) ASCIIMAN_FORMAT="--format=manpage" ;;
		asciidoctor) ASCIIMAN_FORMAT="--backend=manpage" ;;
		*) AC_MSG_WARN([ASCIIMAN $ASCIIMAN is not supported.]) ;;
	esac
fi

AC_ARG_VAR([LINKS],[links command. @<:@default=lynx@:>@])
AC_CHECK_PROGS([LINKS],[lynx links],[${am_missing_run}lynx],[$PATH])
if test "$LINKS" = "links"; then
	LINKS="links -codepage utf-8"
fi

xdedir='${datadir}/xde'
appldir='${xdedir}/applications'
sessdir='${xdedir}/xsessions'
dirsdir='${xdedir}/desktop-directories'
xdgconfdir='${sysconfdir}/xdg'
xdgdir='${xdgconfdir}/xde'
autodir='${xdgdir}/autostart'
menudir='${xdgdir}/menus'

AC_SUBST([xdedir])
AC_SUBST([appldir])
AC_SUBST([sessdir])
AC_SUBST([dirsdir])
AC_SUBST([xdgconfdir])
AC_SUBST([xdgdir])
AC_SUBST([autodir])
AC_SUBST([menudir])

AC_CONFIG_FILES([Makefile
		 src/xde-setup
		 src/Makefile
		 src/share/Makefile
		 src/xdg/Makefile])
AC_OUTPUT

# vim: set ft=config: