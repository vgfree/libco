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
BUILD_CFLAGS =		-g -fPIC -std=gnu99  -Wall -Wno-unused-function -Wno-unused-variable
BUILD_LIBS =		-lco -lpthread -lm
BUILD_INC_DIR = 	-I/usr/include -I/usr/local/include -I$(BUILD_PWD)/include
BUILD_LIB_DIR =		-L/usr/local/lib -L/usr/lib -L/usr/libexec -L$(BUILD_PWD)/lib

#######
CC_COMPILER ?=		gcc
LN = 			@$(CC_COMPILER) $(BUILD_CFLAGS) $(CFLAGS) $(DYLIB_CFLAGS) $(BUILD_OPTIMIZE) $(BUILD_INC_DIR)
CC =			$(CC_COMPILER) $(BUILD_CFLAGS) $(CFLAGS) $(BUILD_OPTIMIZE) $(BUILD_INC_DIR) $(BUILD_LIB_DIR)
AR = 			@ar -rcs

#######
TARGET =		libco
TARGET_MAJOR ?=		1
TARGET_MINOR ?= 	0
TARGET_ARNAME =		$(TARGET).a

#SRC =			$(wildcard $(BUILD_PWD)/*.c) $(wildcard $(BUILD_PWD)/*.S)
SRC =			$(BUILD_PWD)/libco.c
_OBJ =			$(patsubst %.c, $(SOBJ_DIR)/%.o, $(notdir $(SRC)))
OBJ =			$(patsubst %.S, $(SOBJ_DIR)/%.o, $(_OBJ))
SOBJ_DIR =		objs
TOBJ_DIR =		lib
IOBJ_DIR =		include

vpath %.c ./	#指定编译需要查找.c文件的目录

#######
BUILD_CFLAGS += -D_GNU_SOURCE -export-dynamic
BUILD_LIB_DIR += -L/usr/local/lib64 -L/usr/lib64

ECHO =			@echo -e
TARGET_DLSUFFIX =	so
TARGET_NAME = 		$(TARGET).$(TARGET_DLSUFFIX)
TARGET_DLNAME =		$(TARGET_NAME).$(TARGET_MAJOR).$(TARGET_MINOR)
TARGET_SONAME = 	$(TARGET_NAME).$(TARGET_MAJOR)
DYLIB_CFLAGS =		-shared -Wl,-soname,$(TARGET_SONAME)

#######
INSTALL_HEAD_FILE = 	@-rm -rf $(IOBJ_DIR); \
			cp -rf $(BUILD_PWD) $(IOBJ_DIR);	\
			find $(IOBJ_DIR) -name "*.c" -exec rm {} \;

INSTALL_DYLIB_FILE = 	@-ln -sf $(TARGET_DLNAME) $(TOBJ_DIR)/$(TARGET_SONAME); \
			ln -sf $(TARGET_SONAME) $(TOBJ_DIR)/$(TARGET_NAME)

#######
define compile_obj
	$(ECHO) $(COLOR_TXT)"\t\t- COMPILE\t===>\t"$(COLOR_OBJ)"$(1:.c=.o)"$(COLOR_NONE)
	@$(CC) -c $(1) -o $(2)
endef

#######
lib: prepare  $(TARGET)

prepare:
	@-if [ ! -d $(SOBJ_DIR) ];then mkdir $(SOBJ_DIR); fi
	@-if [ ! -d $(TOBJ_DIR) ];then mkdir $(TOBJ_DIR); fi
	@-if [ ! -d $(IOBJ_DIR) ];then mkdir $(IOBJ_DIR); fi

$(SOBJ_DIR)/%.o: %.c
	$(call compile_obj, $<, $@)

$(SOBJ_DIR)/%.o: %.S
	$(call compile_obj, $<, $@)


$(TARGET) : $(OBJ)
	$(ECHO) $(COLOR_TXT)"\t\t- ARCHIVE\t===>\t"$(COLOR_TAG)"$(TARGET_ARNAME)"$(COLOR_NONE)
	$(AR) $(TOBJ_DIR)/$(TARGET_ARNAME) $^
	$(ECHO) $(COLOR_TXT)"\t\t- DYNAMIC\t===>\t"$(COLOR_TAG)"$(TARGET_NAME)"$(COLOR_NONE)
	#$(LN) -o $(TOBJ_DIR)/$(TARGET_DLNAME) $^ 
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

install : $(TARGET)
	$(ECHO) $(COLOR_TXT)"\t\t- INSTALL\t===>\t$<"$(COLOR_NONE)
