#!/bin/bash

XDE_USE_XDG_HOME=1

here=$(cd `dirname $0`;pwd)

name=blackbox
files="version keys rc"
xtras=""
clone="version"
udirs="backgrounds styles"
menus="menu"

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg}
XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/local/share:/usr/share}

prog=${1:-${XDE_WM_TYPE:-$name}}
if ! which $prog >/dev/null 2>&1; then
	echo "ERROR: cannot find usable $prog program" >&2
	exit 1
fi
vers=${2:-${XDE_WM_VERSION:-$(LANG= $prog -version 2>/dev/null|awk '/Blackbox/{print$2;exit}')}} || vers="0.70.2"
sdir=${XDE_WM_CONFIG_SDIR:-/usr/share/$name}
home="$HOME/.$name"
priv="$XDG_CONFIG_HOME/$name"
[ -n "$XDE_USE_XDG_HOME" ] || priv="$home"

export XDE_WM_TYPE="$name"
export XDE_WM_VERSION="$vers"
export XDE_WM_CONFIG_PRIV="$priv"
export XDE_WM_CONFIG_HOME="$home"
export XDE_WM_CONFIG_SDIR="$sdir"
export XDE_WM_CONFIG_EDIR="$here"

for v in PID TYPE VERSION CONFIG_PRIV CONFIG_HOME CONFIG_SDIR CONFIG_EDIR; do
	eval "echo \"XDE_WM_$v => \$XDE_WM_$v\" >&2"
done

backup() {
	local dir=$1 file=$2 temp=
	[ -f "$dir/$file" ] || return
	temp=$(mktemp -p "$dir" --suffix=".bak" "$file.XXXXXXXX")
	mv -fv "$dir/$file" "$temp"
	return 0
}

editfile() {
	local fname=$1
	temp=$(mktemp -t)
	echo "sed: filtering $fname -> $temp" >&2
	sed -e "s,~/\.$name,$priv,g;s,\$HOME/\.$name,$priv,g;s,~/,$HOME,g" "$fname" >"$temp"
	echo "$temp"
}

makelink() {
	local dir=$1 name=$2 targ=$3 file=
	file="$dir/$name"
	if [ -L "$file" ]; then
		if [ "`readlink $file`" != "$targ" ]; then
			rm -fv "$file"
			ln -sfv "$targ" "$file"
		else
			echo "already linked $targ to $file" >&2
		fi
	else
		backup "$dir" "$name"
		ln -sfv "$targ" "$file"
	fi
	return 0
}

if [ -s "$here/version" ]; then
	cver=$(head -1 "$here/version" 2>/dev/null); echo "cver = $cver" >&2
	iver=$(head -1 "$priv/version" 2>/dev/null); echo "iver = $iver" >&2
	if [ "$cver" != "$iver" ]; then
		prefix="X Desktop Environment:\n\n"
		if [ -n "$iver" ]; then
			zenity --question --text="${prefix}Update $priv from $iver to $cver?" || exit 1
			else
			if [ -d "$priv" ]; then
				zenity --question --text="${prefix}Initialize $priv for $cver?\n(Existing files will be backed up.)" || exit 1
			fi
		fi
	fi
	mkdir -pv "$home"
	mkdir -pv "$priv"
	for d in $udirs; do
		[ -d "$priv/$d" ] || mkdir -pv "$priv/$d"
	done
	# these go in private directory
	for f in $files; do
		[ -f "$here/$f" ] || continue
		case " $clone " in
			*" $f "*)
				if [ ! -f "$priv/$f" ] || ! diff "$here/$f" "$priv/$f" >/dev/null 2>&1; then
					[ -n "$iver" ] || backup "$priv" "$f"
					cp -fv "$here/$f" "$priv/$f"
				fi
				;;
			*)
				temp=`editfile "$here/$f"`
				if [ ! -f "$priv/$f" ] || ! diff "$temp" "$priv/$f" >/dev/null 2>&1; then
					[ -n "$iver" ] || backup "$priv" "$f"
					cp -fv "$temp" "$priv/$f"
				fi
				rm -fv "$temp"
				;;
		esac
	done
	# these go in home dot directory
	for x in $xtras; do
		[ -f "$here/$x" ] || continue
		case " $clone " in
			*" $x "*)
				if [ ! -f "$home/$x" ] || ! diff "$here/$x" "$home/$x" >/dev/null 2>&1; then
					[ -n "$iver" ] || backup "$home" "$x"
					cp -fv "$here/$x" "$home/$x"
				fi
				;;
			*)
				temp=`editfile "$here/$x"`
				if [ ! -f "$home/$x" ] || ! diff "$temp" "$home/$x" >/dev/null 2>&1; then
					[ -n "$iver" ] || backup "$home" "$x"
					cp -fv "$temp" "$home/$x"
				fi
				rm -fv "$temp"
				;;
		esac
	done
	generate=false
	for m in $menus; do
		[ -f "$here/$m" ] || continue
		if [ ! -f "$priv/$m" ]; then
			temp=`editfile "$here/$m"`
			cp -fv "$temp" "$priv/$m"
			rm -fv "$temp"
			generate=true
		fi
	done
	if [ "$generate" = "true" ]; then
		desktop=$(echo "$name"|sed -e 'y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/')
		if which xdg-menugen >/dev/null 2>&1; then
			xdg-menugen --format "$name" --desktop "$desktop" -launch -o "$priv/menu" &
		elif which xde-menugen >/dev/null 2>&1; then
			xde-menugen --format "$name" --desktop "$desktop" -launch -o "$priv/menu" &
		fi
	fi
fi

makelink "$HOME" ".blackboxrc" "$priv/rc"
makelink "$HOME" ".bbmenu"     "$priv/menu"
makelink "$HOME" ".bbkeysrc"   "$priv/keys"

