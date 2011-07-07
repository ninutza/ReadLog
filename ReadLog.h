
#ifndef READ_LOG_H
#define READ_LOG_H

typedef nx_struct read_log_msg {
  nx_uint8_t no_pings;		// order number of ping sent by sourceAddr node
  nx_uint16_t sourceAddr;       // source address of pinging node
  nx_uint16_t sig_val;          // RSSI reading for that ping
  nx_uint8_t vNum;
  nx_uint8_t pNum;
} read_log_msg_t;

typedef nx_struct logLine {
    nx_uint8_t no_pings[10];	// order number (local to the sending node)
    nx_uint16_t sourceAddr[10];
    nx_uint16_t sig_val[10];    // this will contain a concatenated value of data type and data ID if not ping msg
    nx_uint8_t vNum[10];
    nx_uint8_t pNum[10];
  } logLine;



enum {
  AM_READ_LOG_MSG = 0x89,
};

#endif
