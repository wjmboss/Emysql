## -*- makefile -*-

ERL := erl
ERLC := $(ERL)c

INCLUDE_DIRS := ../include $(wildcard ../deps/*/include)
EBIN_DIRS := $(wildcard ../deps/*/ebin)
ERLC_FLAGS := -W $(INCLUDE_DIRS:../%=-I ../%) $(EBIN_DIRS:%=-pa %) +nowarn_deprecated_type

ifndef no_debug_info
  ERLC_FLAGS += +debug_info
endif

ifdef debug
  ERLC_FLAGS += -Ddebug
endif

## Check if we are on erlang version that has namespaced types
ERL_NT := $(shell escript ../support/ntype_check.escript)
## Check if we are on erlang version that has erlang:timestamp/0
ERL_TS := $(shell escript ../support/timestamp_check.escript)

ifeq ($(ERL_NT),true)
	ERLC_FLAGS += -Dnamespaced_types
endif

ifeq ($(ERL_TS),true)
	ERLC_FLAGS += -Dtimestamp_support
endif

EBIN_DIR := ../ebin
DOC_DIR  := ../doc
EMULATOR := beam

ERL_TEMPLATE := $(wildcard *.et)
ERL_SOURCES  := $(wildcard *.erl)
ERL_HEADERS  := $(wildcard *.hrl) $(wildcard ../include/*.hrl)
ERL_OBJECTS  := $(ERL_SOURCES:%.erl=$(EBIN_DIR)/%.beam)
ERL_TEMPLATES := $(ERL_TEMPLATE:%.et=$(EBIN_DIR)/%.beam)
ERL_OBJECTS_LOCAL := $(ERL_SOURCES:%.erl=./%.$(EMULATOR))
EBIN_FILES = $(ERL_OBJECTS) $(APP_FILES:%.app=../ebin/%.app) $(ERL_TEMPLATES)

$(EBIN_DIR)/%.$(EMULATOR): %.erl $(ERL_HEADERS)
	$(ERLC) $(ERLC_FLAGS) -o $(EBIN_DIR) $<

./%.$(EMULATOR): %.erl	
	$(ERLC) $(ERLC_FLAGS) -o . $<

$(DOC_DIR)/%.html: %.erl
	$(ERL) -noshell -run edoc file $< -run init stop
	mv *.html $(DOC_DIR)
