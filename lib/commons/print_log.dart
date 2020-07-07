import 'dart:core';
import 'dart:developer';

//this class is used to print debug logs, set shouldPrintLog=false if you no longer want to print logs
bool shouldPrintLog=true;
printLog(value){
  if(shouldPrintLog==true){
    log("$value");
  }
}

printLogTag(tag,value){
  if(shouldPrintLog==true){
    log("$tag $value");
  }
}