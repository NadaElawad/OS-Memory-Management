#ifndef FOS_KERN_MONITOR_H
#define FOS_KERN_MONITOR_H
#ifndef FOS_KERNEL
# error "This is a FOS kernel header; user programs should not #include it"
#endif

// Function to activate the kernel command prompt
void run_command_prompt();

// Declaration of functions that implement command prompt commands.
int command_help(int , char **);
int command_kernel_info(int , char **);
int command_calc_space(int number_of_arguments, char **arguments);
int command_run_program(int argc, char **argv);
int command_allocpage(int , char **);
int command_writeusermem(int , char **);
int command_readusermem(int , char **);
int command_meminfo(int , char **);
#endif	// !FOS_KERN_MONITOR_H
