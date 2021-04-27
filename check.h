/*
  Copyright (c) 2021, Alexey Frunze
  2-clause BSD license.
*/
#ifndef CHECK_H_
#define CHECK_H_

#include <iostream>
#include <sstream>
#include <cstdlib>

struct LogAndAbort
{
  LogAndAbort() = delete;
  LogAndAbort(const char* file, int line) : file_(file), line_(line) {}
  ~LogAndAbort()
  {
    std::cerr << "\n" << oss_.str() << "\n@ " << file_ << ":" << line_ << "\n";    
    exit(EXIT_FAILURE);
  }
  const char* file_;
  int line_;
  std::ostringstream oss_;
};

// This is like assert(), except you may output additional information
// when the condition E is false, e.g.
//   CHECK(0) << 0 << " is false!";
// will output:
//   Check failed: 0
//   0 is false!
//   @ lra86.cpp:1914

#define CHECK(E) \
  if (!(E)) LogAndAbort(__FILE__, __LINE__).oss_ << "Check failed: " #E << "\n"

#endif
