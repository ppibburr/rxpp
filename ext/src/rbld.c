#include <ruby.h>
void load_rb(const char* data)
{
	ruby_init();
  ruby_init_loadpath();

	char* options[] = {"-V", "-erequire ENV['HOME']+'/.local/lib/rxpp/ruby_plugin'", (char*) data };
	void* node = ruby_options(3, options);

	int state;
	if (ruby_executable_node(node, &state))
	{
		state = ruby_exec_node(node);
	}

	if (state)
	{
		/* handle exception, perhaps */
		//printf("fail\n");
	}

	//ruby_cleanup(state);
}

