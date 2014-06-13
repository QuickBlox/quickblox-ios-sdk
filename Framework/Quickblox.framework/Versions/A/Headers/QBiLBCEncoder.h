
#ifndef AACELD_ENCODER_H
#define AACELD_ENCODER_H

#include <AudioToolbox/AudioToolbox.h>

/* Opaque structure to keep the internal encoder state. */
typedef struct QBiLBCEncoder_ QBiLBCEncoder;

/* Structure to keep the encoder configuration */
typedef struct QBEncoderProperties_
{
  Float64 samplingRate;
  UInt32  frameSize;
} QBEncoderProperties;


/* Create a new iLBC encoder */
QBiLBCEncoder* CreateiLBCEncoder();

/* Initialize the encoder */
int  InitiLBCEncoder(QBiLBCEncoder* encoder, QBEncoderProperties props);

/* Encode one LPCM frame (512 samples) to one AAC-ELD AU */ 
int  EncodeiLBC(QBiLBCEncoder* encoder, AudioBuffer *inSamples, AudioBuffer *outData);

/* Destroy the encoder and free associated memory */
void DestroyiLBCEncoder(QBiLBCEncoder *encoder);

#endif /* AACELD_ENCODER_H */