#!/usr/bin/env node

var mFS = require('fs');
const path = require('path');
var mPath = require('path');

// Base functions

function filenamesToFilepathes(path) {
    return mPath.resolve(path);
}

function jsonFilepathToJSON(jsonFilepath) {
    return JSON.parse(mFS.readFileSync(jsonFilepath, 'utf8'));
}

function arrayConcat(arrayOut, arrayIn) {
    return arrayOut.concat(arrayIn);
}

function structValueOrStruct(structIn, keyName) {
    if (structIn[keyName] === undefined) {
        structIn[keyName] = {};
    }

    return structIn[keyName];
}

function filepathToText(filepath) {
    return mFS.readFileSync(filepath, 'utf8');
}

// Filter functions

function s2zcFilenameToAvailability(s2zcFilename) {
    return s2zcFilename.startsWith('$$') && s2zcFilename.endsWith('.json');
}

// Getters functions

function s2zcObjectToActions(s2zcObject) {
    return s2zcObject.actions;
}

// S2ZonaConfigurator functions

function s2zcModifyActionToFileObjects(s2zcFileObjects, s2zcAction) {
    structOut = s2zcAction.path
        .split('::')
        .reduce(structValueOrStruct, structValueOrStruct(s2zcFileObjects, s2zcAction.file));

    Object.assign(structOut, s2zcAction.values);

    return s2zcFileObjects;
}

function s2zcAddActionToFileObjects(s2zcFileObjects, s2zcAction) {
    parts = s2zcAction.path
        .split('::');

    structOut = parts.slice(0, -1)
        .reduce(structValueOrStruct, structValueOrStruct(s2zcFileObjects, s2zcAction.file));

    structOut[parts[parts.length - 1]] = s2zcAction.value;

    return s2zcFileObjects;
}

function s2zcActionToFileObjects(s2zcFileObjects, s2zcAction) {
    if (s2zcAction.type === 'Modify') {
        return s2zcModifyActionToFileObjects(s2zcFileObjects, s2zcAction);
    }

    if (s2zcAction.type === 'Add') {
        return s2zcAddActionToFileObjects(s2zcFileObjects, s2zcAction);
    }
}

// Other functions

function s2zcValueToCFG(s2zcValue) {
    if (typeof s2zcValue[1] === 'object') {
        return s2zcStructToCFG(s2zcValue);
    } else {
        return '    ' + s2zcValue[0] + ' = ' + s2zcValue[1];
    }
}

function s2zcStructToCFG(s2zcValue) {
    arrayOut = ['    ' + s2zcValue[0] + ' : struct.begin'];
    arrayOut = arrayOut.concat(Object.entries(s2zcValue[1]).map(s2zcValueToCFG));
    arrayOut.push('    struct.end');
    return arrayOut.join('\n');
}

function s2zcFileObjectToCFG(s2zcValue, s2zcFile) {
    arrayOut = [s2zcValue[0] + ' : struct.begin {refurl=../' + mPath.parse(s2zcFile).base + '; refkey=' + s2zcValue[0] + '}'];
    arrayOut = arrayOut.concat(Object.entries(s2zcValue[1]).map(s2zcValueToCFG));
    arrayOut.push('struct.end');
    return arrayOut.join('\n');
}

function s2zcFilepathToFilepath(s2zcFilepath) {
    file = mPath.parse(s2zcFilepath);

    return file.dir + '/' + file.name + '/z_' + file.base;
}

function s2zcFileObjectsToCFG(s2zcObject) {
    return [s2zcFilepathToFilepath(s2zcObject[0]), Object.entries(s2zcObject[1])
        .map(function (s2zcValue) {
            return s2zcFileObjectToCFG(s2zcValue, s2zcObject[0]);
        }).join('\n')];
}

function writeFileSyncMkdir(filepath, content) {
    mFS.mkdirSync(mPath.dirname(filepath), { recursive: true });

    return mFS.writeFileSync(filepath, content, 'utf8');
}

function fileArrayToDirpath(fileArray, dirpath) {
    filepath = path.join(dirpath, fileArray[0]);

    writeFileSyncMkdir(filepath,
        fileArray[1],
        'utf8');

    return filepath;
}

// Wrappers

function s2zcDirpathToFileStruct(dirpath) {
    return mFS.readdirSync(dirpath)
        .filter(s2zcFilenameToAvailability)
        .map(filenamesToFilepathes)
        .map(jsonFilepathToJSON)
        .map(s2zcObjectToActions)
        .reduce(arrayConcat, [])
        .reduce(s2zcActionToFileObjects, {});
}

function s2zcFileStructToCFGDirpath(s2zcFileStruct, s2zcDirpath) {
    return Object.entries(s2zcFileStruct)
        .map(s2zcFileObjectsToCFG)
        .map(function (s2zcCFG) {
            return fileArrayToDirpath(s2zcCFG, s2zcDirpath);
        })
        .map(filepathToText);
}

function configGetS2ZCDirpath() {
    return path.join(path.dirname(__dirname), 'stalker2-zona-configurator-cfg', 'src');
}

function s2zcDirpathToCFGDirpath(dirpath) {
    return s2zcFileStructToCFGDirpath(s2zcDirpathToFileStruct(dirpath),
        configGetS2ZCDirpath())
        .join('\n\n\n')
}

// Functions

mFS.rmSync(configGetS2ZCDirpath(), { recursive: true, force: true });

console.log(s2zcDirpathToCFGDirpath(__dirname));
