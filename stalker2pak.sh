#!/usr/bin/env bash

SCRIPT_FILEPATH="$(realpath "$0")"
SCRIPT_DIRPATH="$(dirname "$SCRIPT_FILEPATH")"

MODS_DIRPATH="$(realpath "$SCRIPT_DIRPATH/..")"

S2_WINDIRPATH='I:\Games\S.T.A.L.K.E.R. 2'
S2_SMM_DIRPATH="$(cygpath "$S2_WINDIRPATH\Stalker2SimpleModMerger")"
S2_PAKCHUNK0_DIRPATH="$(cygpath "$S2_WINDIRPATH\Stalker2\Content\Paks\pak-pakchunk0-Windows")"
S2_TMP_DIRPATH="$(cygpath "$S2_WINDIRPATH/tmp-stalker2pak")"
S2INFO_SOURCE_DIRPATH="$(cygpath "$S2_WINDIRPATH/stalker2-pak-info")"

REPAK_FILEPATH="$(cygpath "$S2_SMM_DIRPATH\repak_cli-x86_64-pc-windows-msvc\repak.exe")"

UNREALREZEN_DIRPATH="$(realpath "$MODS_DIRPATH/UnrealReZen_V01")"

UE4_DDS_TOOLS_FILEPATH="$(realpath "$MODS_DIRPATH/UE4-DDS-Tools-v0.6.1-GUI/GUI.exe")"

AES_KEY='0x33A604DF49A07FFD4A4C919962161F5C35A134D37EFA98DB37A34F6450D7D386'

# 'I:\Games\S.T.A.L.K.E.R. 2\Stalker2SimpleModMerger\repak_cli-x86_64-pc-windows-msvc\repak.exe' unpack

# 'I:\VortexMods\stalker2heartofchornobyl\UnrealReZen_V01\UnrealReZen.exe' -g 'I:\Games\S.T.A.L.K.E.R. 2' -c 'I:\VortexMods\stalker2heartofchornobyl\stalker2-icons\Exports' -e GAME_UE5_1 -o 'I:\VortexMods\stalker2heartofchornobyl\utoc-stalker2-icons\stalker2-icons_P.utoc' -a 0x33A604DF49A07FFD4A4C919962161F5C35A134D37EFA98DB37A34F6450D7D386

function s2source() {
	SOURCE_DIRPATH="$SCRIPT_DIRPATH/src"

	# source

	rm -rf "$SOURCE_DIRPATH"

	# mods

	cd "$S2_PAKCHUNK0_DIRPATH"

	# content

	mkdir -p "$SOURCE_DIRPATH"
	cp --parents $(find "$MODS_DIRPATH" -type f -name '*.pak' ! -path '*/pak-stalker2-pak-source/*' -size -1024M -exec bash -c "cp \"{}\" \"$S2_TMP_DIRPATH/stalker2pak.pak\" && \"$REPAK_FILEPATH\" list \"$S2_TMP_DIRPATH/stalker2pak.pak\"" \; | sort | uniq) "$SOURCE_DIRPATH" 2> /dev/null

	# fin

	cd "$SOURCE_DIRPATH"
	find "Stalker2" -type f

	echo -e '\n'

	find "Stalker2" -type f | wc
}

function s2sleep() {
	read
}

function s2infosource() {
	PAK_PATH="$1"
	PAK_SOURCE_DIRPATH="$S2INFO_SOURCE_DIRPATH/$PAK_PATH"

	cd "$S2_PAKCHUNK0_DIRPATH"

	cp "$MODS_DIRPATH/$PAK_PATH" "$S2_TMP_DIRPATH/stalker2pak.pak"

	mkdir -p "$PAK_SOURCE_DIRPATH"
	cp --parents $("$REPAK_FILEPATH" list "$S2_TMP_DIRPATH/stalker2pak.pak") "$PAK_SOURCE_DIRPATH" 2> /dev/null
}

function s2infopak() {
	PAK_PATH="$1"
	PAK_SOURCE_DIRPATH="$S2INFO_SOURCE_DIRPATH/$PAK_PATH"

	cp "$MODS_DIRPATH/$PAK_PATH" "$S2_TMP_DIRPATH/stalker2pak.pak"
	"$REPAK_FILEPATH" unpack -o "$S2_TMP_DIRPATH/stalker2pak" "$S2_TMP_DIRPATH/stalker2pak.pak"
	mkdir -p "$(dirname "$PAK_SOURCE_DIRPATH")" && mv "$S2_TMP_DIRPATH/stalker2pak" "$PAK_SOURCE_DIRPATH"
}

function s2info() {
	s2source

	echo -e '\n\n'

	s2allpack

	echo -e '\n\n'

	rm -rf "$S2INFO_SOURCE_DIRPATH/.git"
	rm -rf "$S2INFO_SOURCE_DIRPATH/*"
	cd "$MODS_DIRPATH"

	find -type f -name '*.pak' ! -path '*/pak-stalker2-pak-source/*' -size -1024M -exec "$SCRIPT_FILEPATH" s2infosource "{}" \;

	cd "$S2INFO_SOURCE_DIRPATH"

	git init
	git add .
	git commit -m 'Init'
	rm -rf *

	cd "$MODS_DIRPATH"
	find -type f -name '*.pak' ! -path '*/pak-stalker2-pak-source/*' -size -1024M -exec "$SCRIPT_FILEPATH" s2infopak "{}" \;

	cd "$S2INFO_SOURCE_DIRPATH"
	git clean -fd
	git add .
	git commit -m 'Upd'

	gitk
}

function s2allpack() {
	cd "$MODS_DIRPATH"

	find -maxdepth 2 -type d -name 'src' -exec "$SCRIPT_FILEPATH" s2srcpack "$MODS_DIRPATH/{}/.." \;

	echo -e '\n\n'

	find -maxdepth 2 -type d -name 'GameLite' -exec "$SCRIPT_FILEPATH" s2gamelitepack "$MODS_DIRPATH/{}/.." \;

}

function s2exportsallpack() {
	$UE4_DDS_TOOLS_FILEPATH

	cd "$MODS_DIRPATH"

	find -maxdepth 2 -type d -name 'Exports' -exec "$SCRIPT_FILEPATH" s2exportspack "$MODS_DIRPATH/{}/.." \;

	s2sleep
}

function s2exportspack() {
	MOD_DIRPATH="$(realpath "$1")"
	MOD_NAME="$(basename "$MOD_DIRPATH")"
	PAK_NAME="$(echo $MOD_NAME | tr '[:upper:]' '[:lower:]' | sed 's/[^[:alnum:]]/-/g')"
	PAK_DIRPATH="$MODS_DIRPATH/utoc-$PAK_NAME"

	mkdir -p "$PAK_DIRPATH"

	cd "$UNREALREZEN_DIRPATH"

	./UnrealReZen.exe -g "$S2_WINDIRPATH" -c "$MOD_DIRPATH/Exports" -e GAME_UE5_1 -o "$PAK_DIRPATH/${PAK_NAME}_P.utoc" -a "$AES_KEY"
}

function s2gamelitepack() {
	MOD_DIRPATH="$(realpath "$1")"
	MOD_NAME="$(basename "$MOD_DIRPATH")"
	PAK_NAME="$(echo $MOD_NAME | tr '[:upper:]' '[:lower:]' | sed 's/[^[:alnum:]]/-/g')"
	PAK_DIRPATH="$MODS_DIRPATH/pak-$PAK_NAME"

	mkdir -p "$S2_TMP_DIRPATH/Stalker2/Content"

	cp -r "$MOD_DIRPATH/GameLite" "$S2_TMP_DIRPATH/Stalker2/Content"

	cd "$S2_TMP_DIRPATH"

	mkdir -p "$PAK_DIRPATH"

	"$REPAK_FILEPATH" pack . "$PAK_DIRPATH/$PAK_NAME.pak"
}

function s2srcpack() {
	MOD_DIRPATH="$(realpath "$1")"
	MOD_NAME="$(basename "$MOD_DIRPATH")"
	PAK_NAME="$(echo $MOD_NAME | tr '[:upper:]' '[:lower:]' | sed 's/[^[:alnum:]]/-/g')"
	PAK_DIRPATH="$MODS_DIRPATH/pak-$PAK_NAME"

	cd "$MOD_DIRPATH/src"

	mkdir -p "$PAK_DIRPATH"

	"$REPAK_FILEPATH" pack . "$PAK_DIRPATH/$PAK_NAME.pak"
}

cd "$SCRIPT_DIRPATH"

rm -rf "$S2_TMP_DIRPATH"
mkdir -p "$S2_TMP_DIRPATH"
mkdir -p "$S2INFO_SOURCE_DIRPATH"

"$@"
