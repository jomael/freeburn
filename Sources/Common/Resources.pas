{-----------------------------------------------------------------------------
 Unit Name: Resources
 Author:    Paul Fisher / Andrew Semack
 Purpose:   for language translation
 History:   English Version
-----------------------------------------------------------------------------}

unit Resources;

interface

// there is placed string resources, user can translate it if he would

resourcestring
  resLibname = 'FreeBurner';

// Hardware Setting
  resSetDataHardwareFail  = 'HardWare : Set Data Write Mode Error';
  resSetDataHardwareOK    = 'HardWare : Set Data Write Mode OK!';
  resSetAudioHardwareFail = 'HardWare : Set Audio Write Mode Error';
  resSetAudioHardwareOK   = 'HardWare : Set Audio Write Mode OK';

// Image writing
  resImageSizeError  = 'Error : Error in ISO Image Size';
  resDiskWriteError  = 'Error : Error Writing to Disk';
  resSyncCache       = 'Finished Writing : Sync Cache';
  resSyncCacheError  = 'Error : Error Cannot Sync Cache';
  resCloseTrack      = 'Finished Writing : Closing Track';
  resCloseSession    = 'Finished Writing : Closing Session';
  resFinishISOBurn   = 'Finished Burning ISO CD!';
  resFinishAudioBurn = 'Finished Burning Audio CD!';

  resErasingData   = 'Erasing : Erasing data....';
  resEraseFinish   = 'Erasing : Finished!';

// CDDA
  resUnknownArtist = 'Unknown Artist';
  resUnknownAlbum  = 'Unknown Album';

// DeviceReader
  resGetLastLBA        = 'Get Last Block Address : ';
  resMemAlloc          = 'Allocate Buffer Memory';
  resMemDeAlloc        = 'DeAllocate Buffer Memory';
  resStreamStart       = 'Start Streaming...';
  resTrackStreamStart  = 'Start Streaming Track : ';
  resCloseStream       = 'Close Data Stream';
  resLastAudioLBA      = 'Audio Track End Address : ';
  resSaveWaveToDisk    = 'Save Wave Stream to File';
  resFinishTrackRip    = 'Finished Ripping Track';
  resFinishCDRip       = 'Finished Ripping CD';

//DiscInfo
  resCueInfo    = '  REM Cue File Created by Delphi FreeBurner Dancemammal.com 2005';
  resCueWebInfo = '  REM     Goto www.dancemammal.com for latest source code.';

//ISOunit
  resFileDialogTitle = 'Filename of new ISO9660 Image';
  resISOSaved        = 'ISO Disk Image Saved to HD';

//BIN to ISO
  resNoBinFileFound      = 'Cannot Find BIN File!';
  resBinFileNotRAW       = 'BIN File is not in RAW format';
  resTrackNotSupported   = 'This BIN / Track style is not supported';

//BIN CUE Image
  resOpenCUEError   = 'Error Opening Cue File!';
  resCUESheetFailed = 'Device Rejected CUE Sheet!';
  resCUESheetSent   = 'Device Accepted CUE Sheet!';


implementation

end.
