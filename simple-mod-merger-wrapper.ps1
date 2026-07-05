mv '..\Stalker2\Content\Paks\~mods\zzzzzzzzzz_MERGED_MOD_P.pak' '..\Stalker2\Content\Paks\~mods\zzzzzzzzzz_MERGED_MOD.pak'

mv '..\Stalker2\Content\Paks\pak-pakchunk0-Windows' '..\Stalker2\Content\Paks\pakchunk0-Windows'

echo 'MERGED MOD and PAKCHUNK0 MOVED'

.\simple_mod_merger.exe

mv '..\Stalker2\Content\Paks\~mods\zzzzzzzzzz_MERGED_MOD.pak' '..\Stalker2\Content\Paks\~mods\zzzzzzzzzz_MERGED_MOD_P.pak'

mv '..\Stalker2\Content\Paks\pakchunk0-Windows' '..\Stalker2\Content\Paks\pak-pakchunk0-Windows'
