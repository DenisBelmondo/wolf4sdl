CONFIG ?= config.default
-include $(CONFIG)


BINARY    ?= bin/wolf3d
PREFIX    ?= /usr/local
MANPREFIX ?= $(PREFIX)

INSTALL         ?= install
INSTALL_PROGRAM ?= $(INSTALL) -m 555 -s
INSTALL_MAN     ?= $(INSTALL) -m 444
INSTALL_DATA    ?= $(INSTALL) -m 444


SDL_CONFIG  ?= pkg-config sdl2 SDL2_mixer
CFLAGS_SDL  ?= $(shell $(SDL_CONFIG) --cflags)
LDFLAGS_SDL ?= $(shell $(SDL_CONFIG) --libs)


CFLAGS += $(CFLAGS_SDL)

CFLAGS += -Wall
#CFLAGS += -W
CFLAGS += -Wpointer-arith
CFLAGS += -Wreturn-type
CFLAGS += -Wwrite-strings
CFLAGS += -Wcast-align


CCFLAGS += $(CFLAGS)
CCFLAGS += -std=gnu99
CCFLAGS += -Werror-implicit-function-declaration
CCFLAGS += -Wimplicit-int
CCFLAGS += -Wsequence-point

CXXFLAGS += $(CFLAGS)

LDFLAGS += $(LDFLAGS_SDL)
ifneq (,$(findstring MINGW,$(shell uname -s)))
LDFLAGS += -static-libgcc
endif

SRCS :=
SRCS += src/dosbox/dbopl.cpp
SRCS += src/id_ca.cpp
SRCS += src/id_in.cpp
SRCS += src/id_pm.cpp
SRCS += src/id_sd.cpp
SRCS += src/id_us_1.cpp
SRCS += src/id_vh.cpp
SRCS += src/id_vl.cpp
SRCS += src/signon.cpp
SRCS += src/wl_act1.cpp
SRCS += src/wl_act2.cpp
SRCS += src/wl_agent.cpp
SRCS += src/wl_atmos.cpp
SRCS += src/wl_cloudsky.cpp
SRCS += src/wl_debug.cpp
SRCS += src/wl_draw.cpp
SRCS += src/wl_floorceiling.cpp
SRCS += src/wl_game.cpp
SRCS += src/wl_inter.cpp
SRCS += src/wl_main.cpp
SRCS += src/wl_menu.cpp
SRCS += src/wl_parallax.cpp
SRCS += src/wl_play.cpp
SRCS += src/wl_state.cpp
SRCS += src/wl_text.cpp
SRCS += src/states.cpp

DEPS = $(filter %.d, $(SRCS:.c=.d) $(SRCS:.cpp=.d))
OBJS = $(filter %.o, $(SRCS:.c=.o) $(SRCS:.cpp=.o))

.SUFFIXES:
.SUFFIXES: .c .cpp .d .o

Q ?= @

all: $(BINARY)

ifndef NO_DEPS
depend: $(DEPS)

ifeq ($(findstring $(MAKECMDGOALS), clean depend Data),)
-include $(DEPS)
endif
endif

$(BINARY): $(OBJS)
	@echo '===> LD $@'
	$(Q)$(CXX) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@

.c.o:
	@echo '===> CC $<'
	$(Q)$(CC) $(CCFLAGS) -c $< -o $@

.cpp.o:
	@echo '===> CXX $<'
	$(Q)$(CXX) $(CXXFLAGS) -c $< -o $@

.c.d:
	@echo '===> DEP $<'
	$(Q)$(CC) $(CCFLAGS) -MM $< | sed 's#^$(@F:%.d=%.o):#$@ $(@:%.d=%.o):#' > $@

.cpp.d:
	@echo '===> DEP $<'
	$(Q)$(CXX) $(CXXFLAGS) -MM $< | sed 's#^$(@F:%.d=%.o):#$@ $(@:%.d=%.o):#' > $@

clean distclean:
	@echo '===> CLEAN'
	$(Q)rm -fr $(DEPS) $(OBJS) $(BINARY) $(BINARY).exe

install: $(BINARY)
	@echo '===> INSTALL'
	$(Q)$(INSTALL) -d $(PREFIX)/bin
	$(Q)$(INSTALL_PROGRAM) $(BINARY) $(PREFIX)/bin
