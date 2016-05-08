/*	Simple command-line kernel prompt useful for
	controlling the kernel and exploring the system interactively.


KEY WORDS
==========
CONSTANTS:	WHITESPACE, NUM_OF_COMMANDS
VARIABLES:	Command, commands, name, description, function_to_execute, number_of_arguments, arguments, command_string, command_line, command_found
FUNCTIONS:	readline, cprintf, execute_command, run_command_prompt, command_kernel_info, command_help, strcmp, strsplit, start_of_kernel, start_of_uninitialized_data_section, end_of_kernel_code_section, end_of_kernel
=====================================================================================================================================================================================================
*/

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>


#include <kern/console.h>
#include <kern/command_prompt.h>
#include <kern/memory_manager.h>
#include <kern/trap.h>
#include <kern/kdebug.h>
#include <kern/user_environment.h>

//Structure for each command
struct Command 
{
	char *name;
	char *description;
	// return -1 to force command prompt to exit
	int (*function_to_execute)(int number_of_arguments, char** arguments);
};

//Functions Declaration
int execute_command(char *command_string);
int command_writemem(int number_of_arguments, char **arguments);
int command_readmem(int number_of_arguments, char **arguments);
int command_readblock(int number_of_arguments, char **arguments);

//Array of commands. (initialized)
struct Command commands[] = 
{
	{ "help", "Display this list of commands", command_help },
	{ "kernel_info", "Display information about the kernel", command_kernel_info },
	{ "writemem", "writes one byte to specific location in given user program" ,command_writemem},
	{ "readmem", "reads one byte from specific location in given user program" ,command_readmem},
	{ "readblock", "reads block of bytes from specific location in given user program" ,command_readblock},	 
	{ "alloc_page", "allocate single page at the given user virtual address" ,command_allocpage},
	{ "rum", "read single byte at the given user virtual address" ,command_readusermem},
	{ "wum", "write single byte at the given user virtual address" ,command_writeusermem},
	{ "meminfo", "show information about the physical memory" ,command_meminfo},
};

//Number of commands = size of the array / size of command structure
#define NUM_OF_COMMANDS (sizeof(commands)/sizeof(commands[0]))

unsigned read_eip();


//invoke the command prompt
void run_command_prompt()
{
	char command_line[1024];

	while (1==1) 
	{
		//get command line
		readline("FOS> ", command_line);
		
		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
				break;
	}
}

/***** Kernel command prompt command interpreter *****/

//define the white-space symbols 
#define WHITESPACE "\t\r\n "

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string)
{
	// Split the command string into whitespace-separated arguments
	int number_of_arguments;

	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];


	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments) ;
	if (number_of_arguments == 0)
		return 0;
	
	// Lookup in the commands array and execute the command
	int command_found = 0;
	int i ;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
	{
		if (strcmp(arguments[0], commands[i].name) == 0)
		{
			command_found = 1;
			break;
		}
	}
	
	if(command_found)
	{
		int return_value;
		return_value = commands[i].function_to_execute(number_of_arguments, arguments);			
		return return_value;
	}
	else
	{
		//if not found, then it's unknown command
		cprintf("Unknown command '%s'\n", arguments[0]);
		return 0;
	}
}

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
	
	cprintf("-------------------\n");
	
	return 0;
}

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments )
{
	extern char start_of_kernel[], end_of_kernel_code_section[], start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n",
		(end_of_kernel-start_of_kernel+1023)/1024);
	return 0;
}

int command_writemem(int number_of_arguments, char **arguments)
{
	char* user_program_name = arguments[1];		
	int address = strtol(arguments[3], NULL, 16);

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
	if(ptr_user_program_info == NULL) return 0;	

	uint32 oldDir = rcr3();
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	unsigned char *ptr = (unsigned char *)(address) ; 

	//Write the given Character
	*ptr = arguments[2][0];
	lcr3(oldDir);	

	return 0;
}

int command_readmem(int number_of_arguments, char **arguments)
{
	char* user_program_name = arguments[1];		
	int address = strtol(arguments[2], NULL, 16);

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
	if(ptr_user_program_info == NULL) return 0;	

	uint32 oldDir = rcr3();
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	unsigned char *ptr = (unsigned char *)(address) ;
	
	//Write the given Character
	cprintf("value at address %x = %c\n", address, *ptr);
	
	lcr3(oldDir);	
	return 0;
}

int command_readblock(int number_of_arguments, char **arguments)
{
	char* user_program_name = arguments[1];	
	int address = strtol(arguments[2], NULL, 16);
	int nBytes = strtol(arguments[3], NULL, 10);
	 
	unsigned char *ptr = (unsigned char *)(address) ;
	//Write the given Character	
		
	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
	if(ptr_user_program_info == NULL) return 0;	

	uint32 oldDir = rcr3();
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	int i;	
	for(i = 0;i<nBytes; i++)
	{
		cprintf("%08x : %02x  %c\n", ptr, *ptr, *ptr);
		ptr++;
	}
	lcr3(oldDir);

	return 0;
}

int command_allocpage(int number_of_arguments, char **arguments)
{
	unsigned int address = strtol(arguments[1], NULL, 16); 
	unsigned char *ptr = (unsigned char *)(address) ;
	
	struct Frame_Info * ptr_frame_info ;
	allocate_frame(&ptr_frame_info);
	
	map_frame(ptr_page_directory, ptr_frame_info, ptr, PERM_WRITEABLE|PERM_USER);
	
	return 0;
}


int command_readusermem(int number_of_arguments, char **arguments)
{
	unsigned int address = strtol(arguments[1], NULL, 16); 
	unsigned char *ptr = (unsigned char *)(address) ;
	
	cprintf("value at address %x = %c\n", ptr, *ptr);
	
	return 0;
}
int command_writeusermem(int number_of_arguments, char **arguments)
{
	unsigned int address = strtol(arguments[1], NULL, 16); 
	unsigned char *ptr = (unsigned char *)(address) ;
	
	*ptr = arguments[2][0];
		
	return 0;
}

int command_meminfo(int number_of_arguments, char **arguments)
{
	cprintf("Free frames = %d\n", calculate_free_frames());
	return 0;
}

