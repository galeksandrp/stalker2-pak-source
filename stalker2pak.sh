#!/usr/bin/env bash

SCRIPT_FILEPATH="$(realpath $0)"
SCRIPT_DIRPATH="$(dirname "$SCRIPT_FILEPATH")"

S2_WINDIRPATH='D:\Games\S.T.A.L.K.E.R. 2'
S2_SMM_DIRPATH="$(cygpath "$S2_WINDIRPATH\Stalker2SimpleModMerger")"
REPAK_FILEPATH="$(cygpath "$S2_SMM_DIRPATH\repak_cli-x86_64-pc-windows-msvc\repak.exe")"
S2_PAKCHUNK0_DIRPATH="$(cygpath "$S2_WINDIRPATH\Stalker2\Content\Paks\pakchunk0-Windows")"

MODS_DIRPATH="$(realpath "$SCRIPT_DIRPATH/..")"

S2INFO_SOURCE_DIRPATH="$MODS_DIRPATH/stalker2-pak-info"

function s2source() {
	SOURCE_DIRPATH="$SCRIPT_DIRPATH/src"

	# source

	rm -rf "$SOURCE_DIRPATH"
	cd "$MODS_DIRPATH"

	# mods

	rm stalker2-pak/*.pak

	cd "$S2_PAKCHUNK0_DIRPATH"

	# content

	mkdir -p "$SOURCE_DIRPATH"
	cp --parents $(find "$MODS_DIRPATH" -type f -name '*.pak' -exec bash -c "cp \"{}\" /tmp/stalker2pak.pak && \"$REPAK_FILEPATH\" list /tmp/stalker2pak.pak" \; | sort | uniq) "$SOURCE_DIRPATH" 2> /dev/null

	# fin

	cd "$SOURCE_DIRPATH"
	find "Stalker2" -type f

	# source.pak

	"$REPAK_FILEPATH" pack . "$MODS_DIRPATH/stalker2-pak/source.pak"

	s2sleep
}

function s2sleep() {
	echo sleep
	sleep 30
}

function s2infosource() {
	PAK_PATH="$1"
	PAK_SOURCE_DIRPATH="$S2INFO_SOURCE_DIRPATH/$PAK_PATH"

	cd "$S2_PAKCHUNK0_DIRPATH"

	cp "$MODS_DIRPATH/$PAK_PATH" /tmp/stalker2pak.pak

	mkdir -p "$PAK_SOURCE_DIRPATH"
	cp --parents $("$REPAK_FILEPATH" list /tmp/stalker2pak.pak) "$PAK_SOURCE_DIRPATH" 2> /dev/null
}

function s2infopak() {
	PAK_PATH="$1"
	PAK_SOURCE_DIRPATH="$S2INFO_SOURCE_DIRPATH/$PAK_PATH"

	cp "$MODS_DIRPATH/$PAK_PATH" /tmp/stalker2pak.pak
	"$REPAK_FILEPATH" unpack -o /tmp/stalker2pak /tmp/stalker2pak.pak
	mkdir -p "$(dirname "$PAK_SOURCE_DIRPATH")" && mv /tmp/stalker2pak "$PAK_SOURCE_DIRPATH"
}

function s2info() {
	rm -rf ../stalker2-pak-info/.git
	rm -rf ../stalker2-pak-info/*
	cd "$MODS_DIRPATH"

	find -type f -name '*.pak' -exec "$SCRIPT_FILEPATH" s2infosource "{}" \;

	cd "$S2INFO_SOURCE_DIRPATH"
	git init
	git add .
	git commit -m 'Init'
	rm -rf *

	cd "$MODS_DIRPATH"
	find -type f -name '*.pak' -exec "$SCRIPT_FILEPATH" s2infopak "{}" \;

	cd "$S2INFO_SOURCE_DIRPATH"
	git clean -fd
	git add .
	git commit -m 'Upd'

	gitk
}

cd "$SCRIPT_DIRPATH"
"$@"
