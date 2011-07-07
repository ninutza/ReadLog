
#include <Timer.h>
#include <UserButton.h>
#include "ReadLog.h"

module ReadLogC {
  uses {
    interface SplitControl as AMControl;
    interface Boot;
    interface AMSend;
    interface Packet;
    interface Leds;
    interface Timer<TMilli> as ReadTimer;

    interface LogRead;    
    interface LogWrite;

    interface Notify<button_state_t>;
  }
}


implementation {

  message_t packet;
  logLine log_line;
  nx_uint8_t index;  

  event void Boot.booted() {
    call Notify.enable();
    call AMControl.start();
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      call Leds.led2Off();
      call ReadTimer.startOneShot(500);
    }
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      index = 10;
      call ReadTimer.startOneShot(500);
      // initiate reading log, let ReadDone send messages via serial port
      

    }
  }

  event void ReadTimer.fired()
  {
    if(index == 10) { // all previous log info has been transmitted, read next log line
      call Leds.led0On();

      if (call LogRead.read(&log_line, sizeof(logLine)) != SUCCESS) { 
	// not critical, so no error handling
      }
    }
    else { // a log message has been read, only partially transmitted
      read_log_msg_t* send_log = (read_log_msg_t*)call Packet.getPayload(&packet, sizeof(read_log_msg_t));

      send_log->no_pings = log_line.no_pings[index];		
      send_log->sourceAddr = log_line.sourceAddr[index];       
      send_log->sig_val = log_line.sig_val[index];
      send_log->vNum = log_line.vNum[index];
      send_log->pNum = log_line.pNum[index];

      index++;

      call Leds.led2On();

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(read_log_msg_t)) == SUCCESS) {
        // successful send of serial message
      }

    }

  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Notify.notify( button_state_t state ) {
    if ( state == BUTTON_PRESSED ) {
      // call to erase the log, stop timer if on
      call ReadTimer.stop();

      call Leds.led1Toggle();

      call LogWrite.erase();
    } else if ( state == BUTTON_RELEASED ) {
      // do nothing, program is done
    }
  }

  event void LogRead.readDone(void* buf, storage_len_t len, error_t err) {


    if ( (len == sizeof(logLine)) && (buf == &log_line) ) { 	// a log entry was correctly read
      // set index to 0 and reset transmission timer
      index = 0;
      call ReadTimer.startOneShot(500);
    }
    else {  // log was finished reading
      call Leds.led0Off();
    }

  }

  event void LogRead.seekDone(error_t err) {
  }

  event void LogWrite.eraseDone(error_t err) {
    // send a blank message to serial to confirm erasure
      read_log_msg_t* send_log = (read_log_msg_t*)call Packet.getPayload(&packet, sizeof(read_log_msg_t));

      send_log->no_pings = 0;		
      send_log->sourceAddr = 0;       
      send_log->sig_val = 0;
      send_log->vNum = 0;
      send_log->pNum = 0;

      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(read_log_msg_t)) == SUCCESS) {
        // successful send of serial message
      }
    
  }

  event void LogWrite.appendDone(void* buf, storage_len_t len, bool recordsLost, error_t err) {
  }

  event void LogWrite.syncDone(error_t err) {
  }
  

}




