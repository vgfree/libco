#include <stdio.h>
#include "libco.h"

static cothread_t g_ctx1 = NULL;
static cothread_t g_ctx2 = NULL;

void do_task(void)
{
	for (int i = 0; i < (1 << 10); i ++) {
		printf("do g_ctx2 %d\n", i);
		co_switch(g_ctx1);
	}
}

int main(int argc, char **argv)
{
	g_ctx1 = co_active();
	g_ctx2 = co_create(4 << 20, do_task);
	for (int i = 0; i < (1 << 10); i ++) {
		printf("do g_ctx1 %d\n", i);
		co_switch(g_ctx2);
	}
	co_delete(g_ctx2);
	return 0;
}
