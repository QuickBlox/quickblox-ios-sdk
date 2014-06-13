
#ifndef AACELD_DECODER_H
#define AACELD_DECODER_H

#include "QBiLBCEncoder.h"

/* Opaque structure to keep the internal decoder state. */
typedef struct QBiLBCDecoder_ QBiLBCDecoder;

/* Structure to keep the decoder configuration */
typedef struct QBDecoderProperties_
{
  Float64 samplingRate;
  UInt32  frameSize;
} QBDecoderProperties;

/* Create a new iLBC ddecoder */
QBiLBCDecoder* CreateiLBCDecoder();

/* Initialize the decoder */
int  InitiLBCDecoder(QBiLBCDecoder *decoder, QBDecoderProperties props);

/* Decode one AAC-ELD AU to one LPCM frame (512 samples) */ 
int  DecodeiLBC(QBiLBCDecoder *decoder, AudioBuffer *inData, AudioBuffer *outSamples);

/* Destroy the decoder and free associated memory */
void DestroyiLBCDecoder(QBiLBCDecoder *decoder);

#endif /* AACELD_DECODER_H */