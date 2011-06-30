
#ifndef READ_LOG_H
#define READ_LOG_H

typedef nx_struct read_log_msg {
  nx_uint8_t no_pings;		// order number of ping sent by sourceAddr node
  nx_uint16_t sourceAddr;       // source address of pinging node
  nx_uint16_t sig_val;          // RSSI reading for that ping
} read_log_msg_t;

typedef nx_struct logLine {
    nx_uint8_t no_pings[10];
    nx_uint16_t sourceAddr[10];
    nx_uint16_t sig_val[10];
  } logLine;


enum {
  AM_READ_LOG_MSG = 0x89,
};

#endif
