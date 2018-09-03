COLOR_NONE            = "\x1B[m"
COLOR_GRAY            = "\x1B[1;30m"
COLOR_RED             = "\x1B[1;31m"
COLOR_GREEN           = "\x1B[1;32m"
COLOR_YELLOW          = "\x1B[1;33m"
COLOR_BLUE            = "\x1B[1;34m"
COLOR_PURPLE          = "\x1B[1;35m"
COLOR_CYAN            = "\x1B[1;36m"
COLOR_WHITE           = "\x1B[1;37m"

#######
COLOR_OBJ =	$(COLOR_CYAN)
COLOR_TAG =	$(COLOR_YELLOW)
COLOR_TXT = 	$(COLOR_GREEN)

#######
BUILD_PWD = 		$(shell pwd)
BUILD_HOST =		$(shell uname | tr '[A-Z]' '[a-z]')

#BUILD_OPTIMIZE =	-fprofile-arcs
BUILD_CFLAGS =		-g -fPIC -std=gnu99 -Wall -Wno-unused-function -Wno-unused-variable
BUILD_LIBS =		-lco -lpthread -lm
BUILD_INC_DIR = 	-I/usr/include -I/usr/local/include -I$(BUILD_PWD)/include
BUILD_LIB_DIR =		-L/usr/local/lib -L/usr/lib -L/usr/libexec -L$(BUILD_PWD)/lib

#######
CC_COMPILER ?=		@gcc
LN = 			$(CC_COMPILER) $(BUILD_CFLAGS) $(CFLAGS) $(DYLIB_CFLAGS) $(BUILD_OPTIMIZE) $(BUILD_INC_DIR)
CC =			$(CC_COMPILER) $(BUILD_CFLAGS) $(CFLAGS) $(BUILD_OPTIMIZE) $(BUILD_INC_DIR) $(BUILD_LIB_DIR)
AR = 			@ar -rcs

#######
TOBJ =			libco
TOBJ_MAJOR ?=		1
TOBJ_MINOR ?=		0
TOBJ_ARNAME =		$(TOBJ).a

FOBJ_DIR =		src
SOBJ_DIR =		objs
TOBJ_DIR =		lib
IOBJ_DIR =		include

#######以下是你需要修改添加的#######
#######
#SRC =			$(wildcard $(FOBJ_DIR)/*.c) $(wildcard $(FOBJ_DIR)/*.S)
SRC =			$(FOBJ_DIR)/libco.c
_OBJ =			$(patsubst %.c, $(SOBJ_DIR)/%.o, $(notdir $(SRC)))
OBJ =			$(patsubst %.S, $(SOBJ_DIR)/%.o, $(_OBJ))

vpath %.c $(FOBJ_DIR)/	#指定编译需要查找.c文件的目录

#######
#######以上是你需要修改添加的#######
ifeq ($(BUILD_HOST), darwin)
BUILD_CFLAGS +=
BUILD_LIB_DIR +=

ECHO =			@echo
TOBJ_DLSUFFIX =		dylib
TOBJ_NAME = 		$(TOBJ).$(TOBJ_DLSUFFIX)
TOBJ_DLNAME =		$(TOBJ_NAME)
TOBJ_SONAME =		
DYLIB_CFLAGS =		-dynamiclib
else
ifeq ($(BUILD_HOST), linux)
BUILD_CFLAGS +=		-D_GNU_SOURCE -export-dynamic
BUILD_LIB_DIR +=	-L/usr/local/lib64 -L/usr/lib64

ECHO =			@echo -e
TOBJ_DLSUFFIX =		so
TOBJ_NAME = 		$(TOBJ).$(TOBJ_DLSUFFIX)
TOBJ_DLNAME =		$(TOBJ_NAME).$(TOBJ_MAJOR).$(TOBJ_MINOR)
TOBJ_SONAME =		$(TOBJ_NAME).$(TOBJ_MAJOR)
DYLIB_CFLAGS =		-shared -Wl,-soname,$(TOBJ_SONAME)
endif
endif
#######
INSTALL_HEAD_FILE = 	@-rm -rf $(IOBJ_DIR); \
			cp -rf $(FOBJ_DIR) $(IOBJ_DIR);	\
			find $(IOBJ_DIR) -type f -not -name "*.h" -exec rm -rf {} \;; \
			find $(IOBJ_DIR) -type d -empty -exec rm -rf {} \;

INSTALL_DYLIB_FILE = 	@-ln -sf $(TOBJ_DLNAME) $(TOBJ_DIR)/$(TOBJ_SONAME); \
			ln -sf $(TOBJ_SONAME) $(TOBJ_DIR)/$(TOBJ_NAME)

#######
define compile_obj
	$(ECHO) $(COLOR_TXT)"\t\t- COMPILE\t===>\t"$(COLOR_OBJ)"$(1:.c=.o)"$(COLOR_NONE)
	@$(CC) -c $(1) -o $(2)
endef

#######
all:
	$(CC) $(BUILD_PWD)/example.c -o $(BUILD_PWD)/example $(BUILD_LIBS)

lib: prepare $(TOBJ)

prepare:
	@-if [ ! -d $(SOBJ_DIR) ];then mkdir $(SOBJ_DIR); fi
	@-if [ ! -d $(TOBJ_DIR) ];then mkdir $(TOBJ_DIR); fi
	@-if [ ! -d $(IOBJ_DIR) ];then mkdir $(IOBJ_DIR); fi

$(SOBJ_DIR)/%.o : $(FOBJ_DIR)/%.c
	$(call compile_obj, $<, $@)

$(SOBJ_DIR)/%.o : $(FOBJ_DIR)/%.S
	$(call compile_obj, $<, $@)


$(TOBJ) : $(OBJ)
	$(ECHO) $(COLOR_TXT)"\t\t- ARCHIVE\t===>\t"$(COLOR_TAG)"$(TOBJ_ARNAME)"$(COLOR_NONE)
	$(AR) $(TOBJ_DIR)/$(TOBJ_ARNAME) $^
	$(ECHO) $(COLOR_TXT)"\t\t- DYNAMIC\t===>\t"$(COLOR_TAG)"$(TOBJ_NAME)"$(COLOR_NONE)
	#$(LN) -o $(TOBJ_DIR)/$(TOBJ_DLNAME) $^
	$(INSTALL_HEAD_FILE)
	#$(INSTALL_DYLIB_FILE)
	$(ECHO) $(COLOR_TXT)"\n\tBUILD\t >>> "$(COLOR_RED)"$@"$(COLOR_TXT)" <<< COMPLETE"$(COLOR_NONE)

clean :
	@-rm -rf $(SOBJ_DIR)
	$(ECHO) $(COLOR_TXT)"\n\tCLEAN\t >>> "$(COLOR_RED)"$@"$(COLOR_TXT)" <<< COMPLETE"$(COLOR_NONE)

distclean : clean
	@-rm -rf $(TOBJ_DIR)
	@-rm -rf $(IOBJ_DIR)
	$(ECHO) $(COLOR_TXT)"\n\tCLEAN\t >>> "$(COLOR_RED)"$@"$(COLOR_TXT)" <<< COMPLETE"$(COLOR_NONE)

install : $(TOBJ)
	$(ECHO) $(COLOR_TXT)"\t\t- INSTALL\t===>\t$<"$(COLOR_NONE)
