#
CC=/usr/bin/g++
CXXFLAGS = -std=c++11 -D_GLIBCXX_USE_CXX11_ABI=0
ARCH := $(shell arch)
SYSTEMC_HOME=/usr/local/SystemC-2.3.0

LINUXLIB := $(shell if [ ${ARCH} = "i686" ]; \
                    then \
                         echo lib-linux; \
                    else \
                         echo lib-linux64; \
                    fi)

INCLUDES = -I$(SYSTEMC_HOME)/include -I.
LIBRARIES = -L. -L$(SYSTEMC_HOME)/$(LINUXLIB) -lsystemc -lm
RPATH = -Wl,-rpath=$(SYSTEMC_HOME)/$(LINUXLIB)

PROGRAM = lab1.x
SRCS    = barrelshift.cpp alu.cpp sc_main.cpp
OBJS    = barrelshift.o alu.o sc_main.o

all : $(PROGRAM)

$(OBJS) : $(SRCS)
	$(CC) $(CXXFLAGS) $(INCLUDES) -c $(SRCS)

$(PROGRAM) : $(OBJS)
	$(CC) $(CXXFLAGS) $(INCLUDES) $(LIBRARIES) $(RPATH) -o $(PROGRAM) $(OBJS)

clean:
	@rm -f $(OBJS) $(PROGRAM) *.cpp~ *.h~

