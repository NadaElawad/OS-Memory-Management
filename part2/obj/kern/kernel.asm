
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <start_of_kernel-0xc>:
.long MULTIBOOT_HEADER_FLAGS
.long CHECKSUM

.globl		start_of_kernel
start_of_kernel:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 03 00    	add    0x31bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fb                   	sti    
f0100009:	4f                   	dec    %edi
f010000a:	52                   	push   %edx
f010000b:	e4                   	.byte 0xe4

f010000c <start_of_kernel>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 

	# Establish our own GDT in place of the boot loader's temporary GDT.
	lgdt	RELOC(mygdtdesc)		# load descriptor table
f0100015:	0f 01 15 18 b0 11 00 	lgdtl  0x11b018

	# Immediately reload all segment registers (including CS!)
	# with segment selectors from the new GDT.
	movl	$DATA_SEL, %eax			# Data segment selector
f010001c:	b8 10 00 00 00       	mov    $0x10,%eax
	movw	%ax,%ds				# -> DS: Data Segment
f0100021:	8e d8                	mov    %eax,%ds
	movw	%ax,%es				# -> ES: Extra Segment
f0100023:	8e c0                	mov    %eax,%es
	movw	%ax,%ss				# -> SS: Stack Segment
f0100025:	8e d0                	mov    %eax,%ss
	ljmp	$CODE_SEL,$relocated		# reload CS by jumping
f0100027:	ea 2e 00 10 f0 08 00 	ljmp   $0x8,$0xf010002e

f010002e <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002e:	bd 00 00 00 00       	mov    $0x0,%ebp

        # Leave a few words on the stack for the user trap frame
	movl	$(ptr_stack_top-SIZEOF_STRUCT_TRAPFRAME),%esp
f0100033:	bc bc af 11 f0       	mov    $0xf011afbc,%esp

	# now to C code
	call	FOS_initialize
f0100038:	e8 02 00 00 00       	call   f010003f <FOS_initialize>

f010003d <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003d:	eb fe                	jmp    f010003d <spin>

f010003f <FOS_initialize>:



//First ever function called in FOS kernel
void FOS_initialize()
{
f010003f:	55                   	push   %ebp
f0100040:	89 e5                	mov    %esp,%ebp
f0100042:	83 ec 08             	sub    $0x8,%esp
	extern char start_of_uninitialized_data_section[], end_of_kernel[];

	// Before doing anything else,
	// clear the uninitialized global data (BSS) section of our program, from start_of_uninitialized_data_section to end_of_kernel 
	// This ensures that all static/global variables start with zero value.
	memset(start_of_uninitialized_data_section, 0, end_of_kernel - start_of_uninitialized_data_section);
f0100045:	ba 4c e7 14 f0       	mov    $0xf014e74c,%edx
f010004a:	b8 52 dc 14 f0       	mov    $0xf014dc52,%eax
f010004f:	29 c2                	sub    %eax,%edx
f0100051:	89 d0                	mov    %edx,%eax
f0100053:	83 ec 04             	sub    $0x4,%esp
f0100056:	50                   	push   %eax
f0100057:	6a 00                	push   $0x0
f0100059:	68 52 dc 14 f0       	push   $0xf014dc52
f010005e:	e8 42 47 00 00       	call   f01047a5 <memset>
f0100063:	83 c4 10             	add    $0x10,%esp

	// Initialize the console.
	// Can't call cprintf until after we do this!
	console_initialize();
f0100066:	e8 7b 08 00 00       	call   f01008e6 <console_initialize>

	//print welcome message
	print_welcome_message();
f010006b:	e8 45 00 00 00       	call   f01000b5 <print_welcome_message>

	// Lab 2 memory management initialization functions
	detect_memory();
f0100070:	e8 00 0f 00 00       	call   f0100f75 <detect_memory>
	initialize_kernel_VM();
f0100075:	e8 86 1d 00 00       	call   f0101e00 <initialize_kernel_VM>
	initialize_paging();
f010007a:	e8 45 21 00 00       	call   f01021c4 <initialize_paging>
	page_check();
f010007f:	e8 bd 12 00 00       	call   f0101341 <page_check>

	
	// Lab 3 user environment initialization functions
	env_init();
f0100084:	e8 f2 28 00 00       	call   f010297b <env_init>
	idt_init();
f0100089:	e8 86 30 00 00       	call   f0103114 <idt_init>

	
	// start the kernel command prompt.
	while (1==1)
	{
		cprintf("\nWelcome to the FOS kernel command prompt!\n");
f010008e:	83 ec 0c             	sub    $0xc,%esp
f0100091:	68 a0 4d 10 f0       	push   $0xf0104da0
f0100096:	e8 28 30 00 00       	call   f01030c3 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
		cprintf("Type 'help' for a list of commands.\n");	
f010009e:	83 ec 0c             	sub    $0xc,%esp
f01000a1:	68 cc 4d 10 f0       	push   $0xf0104dcc
f01000a6:	e8 18 30 00 00       	call   f01030c3 <cprintf>
f01000ab:	83 c4 10             	add    $0x10,%esp
		run_command_prompt();
f01000ae:	e8 9e 08 00 00       	call   f0100951 <run_command_prompt>
	}
f01000b3:	eb d9                	jmp    f010008e <FOS_initialize+0x4f>

f01000b5 <print_welcome_message>:
}


void print_welcome_message()
{
f01000b5:	55                   	push   %ebp
f01000b6:	89 e5                	mov    %esp,%ebp
f01000b8:	83 ec 08             	sub    $0x8,%esp
	cprintf("\n\n\n");
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	68 f1 4d 10 f0       	push   $0xf0104df1
f01000c3:	e8 fb 2f 00 00       	call   f01030c3 <cprintf>
f01000c8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000cb:	83 ec 0c             	sub    $0xc,%esp
f01000ce:	68 f8 4d 10 f0       	push   $0xf0104df8
f01000d3:	e8 eb 2f 00 00       	call   f01030c3 <cprintf>
f01000d8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000db:	83 ec 0c             	sub    $0xc,%esp
f01000de:	68 40 4e 10 f0       	push   $0xf0104e40
f01000e3:	e8 db 2f 00 00       	call   f01030c3 <cprintf>
f01000e8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                   !! FCIS says HELLO !!                     !!\n");
f01000eb:	83 ec 0c             	sub    $0xc,%esp
f01000ee:	68 88 4e 10 f0       	push   $0xf0104e88
f01000f3:	e8 cb 2f 00 00       	call   f01030c3 <cprintf>
f01000f8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000fb:	83 ec 0c             	sub    $0xc,%esp
f01000fe:	68 40 4e 10 f0       	push   $0xf0104e40
f0100103:	e8 bb 2f 00 00       	call   f01030c3 <cprintf>
f0100108:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f010010b:	83 ec 0c             	sub    $0xc,%esp
f010010e:	68 f8 4d 10 f0       	push   $0xf0104df8
f0100113:	e8 ab 2f 00 00       	call   f01030c3 <cprintf>
f0100118:	83 c4 10             	add    $0x10,%esp
	cprintf("\n\n\n\n");	
f010011b:	83 ec 0c             	sub    $0xc,%esp
f010011e:	68 cd 4e 10 f0       	push   $0xf0104ecd
f0100123:	e8 9b 2f 00 00       	call   f01030c3 <cprintf>
f0100128:	83 c4 10             	add    $0x10,%esp
}
f010012b:	90                   	nop
f010012c:	c9                   	leave  
f010012d:	c3                   	ret    

f010012e <_panic>:
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel command prompt.
 */
void _panic(const char *file, int line, const char *fmt,...)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	if (panicstr)
f0100134:	a1 60 dc 14 f0       	mov    0xf014dc60,%eax
f0100139:	85 c0                	test   %eax,%eax
f010013b:	74 02                	je     f010013f <_panic+0x11>
		goto dead;
f010013d:	eb 49                	jmp    f0100188 <_panic+0x5a>
	panicstr = fmt;
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	a3 60 dc 14 f0       	mov    %eax,0xf014dc60

	va_start(ap, fmt);
f0100147:	8d 45 10             	lea    0x10(%ebp),%eax
f010014a:	83 c0 04             	add    $0x4,%eax
f010014d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	ff 75 0c             	pushl  0xc(%ebp)
f0100156:	ff 75 08             	pushl  0x8(%ebp)
f0100159:	68 d2 4e 10 f0       	push   $0xf0104ed2
f010015e:	e8 60 2f 00 00       	call   f01030c3 <cprintf>
f0100163:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f0100166:	8b 45 10             	mov    0x10(%ebp),%eax
f0100169:	83 ec 08             	sub    $0x8,%esp
f010016c:	ff 75 f4             	pushl  -0xc(%ebp)
f010016f:	50                   	push   %eax
f0100170:	e8 25 2f 00 00       	call   f010309a <vcprintf>
f0100175:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f0100178:	83 ec 0c             	sub    $0xc,%esp
f010017b:	68 ea 4e 10 f0       	push   $0xf0104eea
f0100180:	e8 3e 2f 00 00       	call   f01030c3 <cprintf>
f0100185:	83 c4 10             	add    $0x10,%esp
	va_end(ap);

dead:
	/* break into the kernel command prompt */
	while (1==1)
		run_command_prompt();
f0100188:	e8 c4 07 00 00       	call   f0100951 <run_command_prompt>
f010018d:	eb f9                	jmp    f0100188 <_panic+0x5a>

f010018f <_warn>:
}

/* like panic, but don't enters the kernel command prompt*/
void _warn(const char *file, int line, const char *fmt,...)
{
f010018f:	55                   	push   %ebp
f0100190:	89 e5                	mov    %esp,%ebp
f0100192:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100195:	8d 45 10             	lea    0x10(%ebp),%eax
f0100198:	83 c0 04             	add    $0x4,%eax
f010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel warning at %s:%d: ", file, line);
f010019e:	83 ec 04             	sub    $0x4,%esp
f01001a1:	ff 75 0c             	pushl  0xc(%ebp)
f01001a4:	ff 75 08             	pushl  0x8(%ebp)
f01001a7:	68 ec 4e 10 f0       	push   $0xf0104eec
f01001ac:	e8 12 2f 00 00       	call   f01030c3 <cprintf>
f01001b1:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f01001b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01001b7:	83 ec 08             	sub    $0x8,%esp
f01001ba:	ff 75 f4             	pushl  -0xc(%ebp)
f01001bd:	50                   	push   %eax
f01001be:	e8 d7 2e 00 00       	call   f010309a <vcprintf>
f01001c3:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f01001c6:	83 ec 0c             	sub    $0xc,%esp
f01001c9:	68 ea 4e 10 f0       	push   $0xf0104eea
f01001ce:	e8 f0 2e 00 00       	call   f01030c3 <cprintf>
f01001d3:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
f01001d6:	90                   	nop
f01001d7:	c9                   	leave  
f01001d8:	c3                   	ret    

f01001d9 <serial_proc_data>:

static bool serial_exists;

int
serial_proc_data(void)
{
f01001d9:	55                   	push   %ebp
f01001da:	89 e5                	mov    %esp,%ebp
f01001dc:	83 ec 10             	sub    $0x10,%esp
f01001df:	c7 45 f8 fd 03 00 00 	movl   $0x3fd,-0x8(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01001e9:	89 c2                	mov    %eax,%edx
f01001eb:	ec                   	in     (%dx),%al
f01001ec:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f01001ef:	8a 45 f7             	mov    -0x9(%ebp),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001f2:	0f b6 c0             	movzbl %al,%eax
f01001f5:	83 e0 01             	and    $0x1,%eax
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	75 07                	jne    f0100203 <serial_proc_data+0x2a>
		return -1;
f01001fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100201:	eb 16                	jmp    f0100219 <serial_proc_data+0x40>
f0100203:	c7 45 fc f8 03 00 00 	movl   $0x3f8,-0x4(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010020a:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010020d:	89 c2                	mov    %eax,%edx
f010020f:	ec                   	in     (%dx),%al
f0100210:	88 45 f6             	mov    %al,-0xa(%ebp)
	return data;
f0100213:	8a 45 f6             	mov    -0xa(%ebp),%al
	return inb(COM1+COM_RX);
f0100216:	0f b6 c0             	movzbl %al,%eax
}
f0100219:	c9                   	leave  
f010021a:	c3                   	ret    

f010021b <serial_intr>:

void
serial_intr(void)
{
f010021b:	55                   	push   %ebp
f010021c:	89 e5                	mov    %esp,%ebp
f010021e:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100221:	a1 80 dc 14 f0       	mov    0xf014dc80,%eax
f0100226:	85 c0                	test   %eax,%eax
f0100228:	74 10                	je     f010023a <serial_intr+0x1f>
		cons_intr(serial_proc_data);
f010022a:	83 ec 0c             	sub    $0xc,%esp
f010022d:	68 d9 01 10 f0       	push   $0xf01001d9
f0100232:	e8 e4 05 00 00       	call   f010081b <cons_intr>
f0100237:	83 c4 10             	add    $0x10,%esp
}
f010023a:	90                   	nop
f010023b:	c9                   	leave  
f010023c:	c3                   	ret    

f010023d <serial_init>:

void
serial_init(void)
{
f010023d:	55                   	push   %ebp
f010023e:	89 e5                	mov    %esp,%ebp
f0100240:	83 ec 40             	sub    $0x40,%esp
f0100243:	c7 45 fc fa 03 00 00 	movl   $0x3fa,-0x4(%ebp)
f010024a:	c6 45 ce 00          	movb   $0x0,-0x32(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010024e:	8a 45 ce             	mov    -0x32(%ebp),%al
f0100251:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0100254:	ee                   	out    %al,(%dx)
f0100255:	c7 45 f8 fb 03 00 00 	movl   $0x3fb,-0x8(%ebp)
f010025c:	c6 45 cf 80          	movb   $0x80,-0x31(%ebp)
f0100260:	8a 45 cf             	mov    -0x31(%ebp),%al
f0100263:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0100266:	ee                   	out    %al,(%dx)
f0100267:	c7 45 f4 f8 03 00 00 	movl   $0x3f8,-0xc(%ebp)
f010026e:	c6 45 d0 0c          	movb   $0xc,-0x30(%ebp)
f0100272:	8a 45 d0             	mov    -0x30(%ebp),%al
f0100275:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100278:	ee                   	out    %al,(%dx)
f0100279:	c7 45 f0 f9 03 00 00 	movl   $0x3f9,-0x10(%ebp)
f0100280:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
f0100284:	8a 45 d1             	mov    -0x2f(%ebp),%al
f0100287:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010028a:	ee                   	out    %al,(%dx)
f010028b:	c7 45 ec fb 03 00 00 	movl   $0x3fb,-0x14(%ebp)
f0100292:	c6 45 d2 03          	movb   $0x3,-0x2e(%ebp)
f0100296:	8a 45 d2             	mov    -0x2e(%ebp),%al
f0100299:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010029c:	ee                   	out    %al,(%dx)
f010029d:	c7 45 e8 fc 03 00 00 	movl   $0x3fc,-0x18(%ebp)
f01002a4:	c6 45 d3 00          	movb   $0x0,-0x2d(%ebp)
f01002a8:	8a 45 d3             	mov    -0x2d(%ebp),%al
f01002ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01002ae:	ee                   	out    %al,(%dx)
f01002af:	c7 45 e4 f9 03 00 00 	movl   $0x3f9,-0x1c(%ebp)
f01002b6:	c6 45 d4 01          	movb   $0x1,-0x2c(%ebp)
f01002ba:	8a 45 d4             	mov    -0x2c(%ebp),%al
f01002bd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01002c0:	ee                   	out    %al,(%dx)
f01002c1:	c7 45 e0 fd 03 00 00 	movl   $0x3fd,-0x20(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01002cb:	89 c2                	mov    %eax,%edx
f01002cd:	ec                   	in     (%dx),%al
f01002ce:	88 45 d5             	mov    %al,-0x2b(%ebp)
	return data;
f01002d1:	8a 45 d5             	mov    -0x2b(%ebp),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01002d4:	3c ff                	cmp    $0xff,%al
f01002d6:	0f 95 c0             	setne  %al
f01002d9:	0f b6 c0             	movzbl %al,%eax
f01002dc:	a3 80 dc 14 f0       	mov    %eax,0xf014dc80
f01002e1:	c7 45 dc fa 03 00 00 	movl   $0x3fa,-0x24(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01002eb:	89 c2                	mov    %eax,%edx
f01002ed:	ec                   	in     (%dx),%al
f01002ee:	88 45 d6             	mov    %al,-0x2a(%ebp)
f01002f1:	c7 45 d8 f8 03 00 00 	movl   $0x3f8,-0x28(%ebp)
f01002f8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01002fb:	89 c2                	mov    %eax,%edx
f01002fd:	ec                   	in     (%dx),%al
f01002fe:	88 45 d7             	mov    %al,-0x29(%ebp)
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

}
f0100301:	90                   	nop
f0100302:	c9                   	leave  
f0100303:	c3                   	ret    

f0100304 <delay>:
// page.

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100304:	55                   	push   %ebp
f0100305:	89 e5                	mov    %esp,%ebp
f0100307:	83 ec 20             	sub    $0x20,%esp
f010030a:	c7 45 fc 84 00 00 00 	movl   $0x84,-0x4(%ebp)
f0100311:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100314:	89 c2                	mov    %eax,%edx
f0100316:	ec                   	in     (%dx),%al
f0100317:	88 45 ec             	mov    %al,-0x14(%ebp)
f010031a:	c7 45 f8 84 00 00 00 	movl   $0x84,-0x8(%ebp)
f0100321:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0100324:	89 c2                	mov    %eax,%edx
f0100326:	ec                   	in     (%dx),%al
f0100327:	88 45 ed             	mov    %al,-0x13(%ebp)
f010032a:	c7 45 f4 84 00 00 00 	movl   $0x84,-0xc(%ebp)
f0100331:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100334:	89 c2                	mov    %eax,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	88 45 ee             	mov    %al,-0x12(%ebp)
f010033a:	c7 45 f0 84 00 00 00 	movl   $0x84,-0x10(%ebp)
f0100341:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100344:	89 c2                	mov    %eax,%edx
f0100346:	ec                   	in     (%dx),%al
f0100347:	88 45 ef             	mov    %al,-0x11(%ebp)
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010034a:	90                   	nop
f010034b:	c9                   	leave  
f010034c:	c3                   	ret    

f010034d <lpt_putc>:

static void
lpt_putc(int c)
{
f010034d:	55                   	push   %ebp
f010034e:	89 e5                	mov    %esp,%ebp
f0100350:	83 ec 20             	sub    $0x20,%esp
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 2800; i++) //12800
f0100353:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f010035a:	eb 08                	jmp    f0100364 <lpt_putc+0x17>
		delay();
f010035c:	e8 a3 ff ff ff       	call   f0100304 <delay>
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 2800; i++) //12800
f0100361:	ff 45 fc             	incl   -0x4(%ebp)
f0100364:	c7 45 ec 79 03 00 00 	movl   $0x379,-0x14(%ebp)
f010036b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010036e:	89 c2                	mov    %eax,%edx
f0100370:	ec                   	in     (%dx),%al
f0100371:	88 45 eb             	mov    %al,-0x15(%ebp)
	return data;
f0100374:	8a 45 eb             	mov    -0x15(%ebp),%al
f0100377:	84 c0                	test   %al,%al
f0100379:	78 09                	js     f0100384 <lpt_putc+0x37>
f010037b:	81 7d fc ef 0a 00 00 	cmpl   $0xaef,-0x4(%ebp)
f0100382:	7e d8                	jle    f010035c <lpt_putc+0xf>
		delay();
	outb(0x378+0, c);
f0100384:	8b 45 08             	mov    0x8(%ebp),%eax
f0100387:	0f b6 c0             	movzbl %al,%eax
f010038a:	c7 45 f4 78 03 00 00 	movl   $0x378,-0xc(%ebp)
f0100391:	88 45 e8             	mov    %al,-0x18(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100394:	8a 45 e8             	mov    -0x18(%ebp),%al
f0100397:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010039a:	ee                   	out    %al,(%dx)
f010039b:	c7 45 f0 7a 03 00 00 	movl   $0x37a,-0x10(%ebp)
f01003a2:	c6 45 e9 0d          	movb   $0xd,-0x17(%ebp)
f01003a6:	8a 45 e9             	mov    -0x17(%ebp),%al
f01003a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01003ac:	ee                   	out    %al,(%dx)
f01003ad:	c7 45 f8 7a 03 00 00 	movl   $0x37a,-0x8(%ebp)
f01003b4:	c6 45 ea 08          	movb   $0x8,-0x16(%ebp)
f01003b8:	8a 45 ea             	mov    -0x16(%ebp),%al
f01003bb:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01003be:	ee                   	out    %al,(%dx)
	outb(0x378+2, 0x08|0x04|0x01);
	outb(0x378+2, 0x08);
}
f01003bf:	90                   	nop
f01003c0:	c9                   	leave  
f01003c1:	c3                   	ret    

f01003c2 <cga_init>:
static uint16 *crt_buf;
static uint16 crt_pos;

void
cga_init(void)
{
f01003c2:	55                   	push   %ebp
f01003c3:	89 e5                	mov    %esp,%ebp
f01003c5:	83 ec 20             	sub    $0x20,%esp
	volatile uint16 *cp;
	uint16 was;
	unsigned pos;

	cp = (uint16*) (KERNEL_BASE + CGA_BUF);
f01003c8:	c7 45 fc 00 80 0b f0 	movl   $0xf00b8000,-0x4(%ebp)
	was = *cp;
f01003cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003d2:	66 8b 00             	mov    (%eax),%ax
f01003d5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
	*cp = (uint16) 0xA55A;
f01003d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003dc:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01003e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01003e4:	66 8b 00             	mov    (%eax),%ax
f01003e7:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01003eb:	74 13                	je     f0100400 <cga_init+0x3e>
		cp = (uint16*) (KERNEL_BASE + MONO_BUF);
f01003ed:	c7 45 fc 00 00 0b f0 	movl   $0xf00b0000,-0x4(%ebp)
		addr_6845 = MONO_BASE;
f01003f4:	c7 05 84 dc 14 f0 b4 	movl   $0x3b4,0xf014dc84
f01003fb:	03 00 00 
f01003fe:	eb 14                	jmp    f0100414 <cga_init+0x52>
	} else {
		*cp = was;
f0100400:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0100403:	66 8b 45 fa          	mov    -0x6(%ebp),%ax
f0100407:	66 89 02             	mov    %ax,(%edx)
		addr_6845 = CGA_BASE;
f010040a:	c7 05 84 dc 14 f0 d4 	movl   $0x3d4,0xf014dc84
f0100411:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100414:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f0100419:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010041c:	c6 45 e0 0e          	movb   $0xe,-0x20(%ebp)
f0100420:	8a 45 e0             	mov    -0x20(%ebp),%al
f0100423:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100426:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100427:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f010042c:	40                   	inc    %eax
f010042d:	89 45 ec             	mov    %eax,-0x14(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100430:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100433:	89 c2                	mov    %eax,%edx
f0100435:	ec                   	in     (%dx),%al
f0100436:	88 45 e1             	mov    %al,-0x1f(%ebp)
	return data;
f0100439:	8a 45 e1             	mov    -0x1f(%ebp),%al
f010043c:	0f b6 c0             	movzbl %al,%eax
f010043f:	c1 e0 08             	shl    $0x8,%eax
f0100442:	89 45 f0             	mov    %eax,-0x10(%ebp)
	outb(addr_6845, 15);
f0100445:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f010044a:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010044d:	c6 45 e2 0f          	movb   $0xf,-0x1e(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100451:	8a 45 e2             	mov    -0x1e(%ebp),%al
f0100454:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100457:	ee                   	out    %al,(%dx)
	pos |= inb(addr_6845 + 1);
f0100458:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f010045d:	40                   	inc    %eax
f010045e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100461:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100464:	89 c2                	mov    %eax,%edx
f0100466:	ec                   	in     (%dx),%al
f0100467:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f010046a:	8a 45 e3             	mov    -0x1d(%ebp),%al
f010046d:	0f b6 c0             	movzbl %al,%eax
f0100470:	09 45 f0             	or     %eax,-0x10(%ebp)

	crt_buf = (uint16*) cp;
f0100473:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100476:	a3 88 dc 14 f0       	mov    %eax,0xf014dc88
	crt_pos = pos;
f010047b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010047e:	66 a3 8c dc 14 f0    	mov    %ax,0xf014dc8c
}
f0100484:	90                   	nop
f0100485:	c9                   	leave  
f0100486:	c3                   	ret    

f0100487 <cga_putc>:



void
cga_putc(int c)
{
f0100487:	55                   	push   %ebp
f0100488:	89 e5                	mov    %esp,%ebp
f010048a:	53                   	push   %ebx
f010048b:	83 ec 24             	sub    $0x24,%esp
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010048e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100491:	b0 00                	mov    $0x0,%al
f0100493:	85 c0                	test   %eax,%eax
f0100495:	75 07                	jne    f010049e <cga_putc+0x17>
		c |= 0x0700;
f0100497:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)

	switch (c & 0xff) {
f010049e:	8b 45 08             	mov    0x8(%ebp),%eax
f01004a1:	0f b6 c0             	movzbl %al,%eax
f01004a4:	83 f8 09             	cmp    $0x9,%eax
f01004a7:	0f 84 94 00 00 00    	je     f0100541 <cga_putc+0xba>
f01004ad:	83 f8 09             	cmp    $0x9,%eax
f01004b0:	7f 0a                	jg     f01004bc <cga_putc+0x35>
f01004b2:	83 f8 08             	cmp    $0x8,%eax
f01004b5:	74 14                	je     f01004cb <cga_putc+0x44>
f01004b7:	e9 c8 00 00 00       	jmp    f0100584 <cga_putc+0xfd>
f01004bc:	83 f8 0a             	cmp    $0xa,%eax
f01004bf:	74 49                	je     f010050a <cga_putc+0x83>
f01004c1:	83 f8 0d             	cmp    $0xd,%eax
f01004c4:	74 53                	je     f0100519 <cga_putc+0x92>
f01004c6:	e9 b9 00 00 00       	jmp    f0100584 <cga_putc+0xfd>
	case '\b':
		if (crt_pos > 0) {
f01004cb:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f01004d1:	66 85 c0             	test   %ax,%ax
f01004d4:	0f 84 d0 00 00 00    	je     f01005aa <cga_putc+0x123>
			crt_pos--;
f01004da:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f01004e0:	48                   	dec    %eax
f01004e1:	66 a3 8c dc 14 f0    	mov    %ax,0xf014dc8c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e7:	8b 15 88 dc 14 f0    	mov    0xf014dc88,%edx
f01004ed:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f01004f3:	0f b7 c0             	movzwl %ax,%eax
f01004f6:	01 c0                	add    %eax,%eax
f01004f8:	01 c2                	add    %eax,%edx
f01004fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01004fd:	b0 00                	mov    $0x0,%al
f01004ff:	83 c8 20             	or     $0x20,%eax
f0100502:	66 89 02             	mov    %ax,(%edx)
		}
		break;
f0100505:	e9 a0 00 00 00       	jmp    f01005aa <cga_putc+0x123>
	case '\n':
		crt_pos += CRT_COLS;
f010050a:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f0100510:	83 c0 50             	add    $0x50,%eax
f0100513:	66 a3 8c dc 14 f0    	mov    %ax,0xf014dc8c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100519:	66 8b 0d 8c dc 14 f0 	mov    0xf014dc8c,%cx
f0100520:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f0100526:	bb 50 00 00 00       	mov    $0x50,%ebx
f010052b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100530:	66 f7 f3             	div    %bx
f0100533:	89 d0                	mov    %edx,%eax
f0100535:	29 c1                	sub    %eax,%ecx
f0100537:	89 c8                	mov    %ecx,%eax
f0100539:	66 a3 8c dc 14 f0    	mov    %ax,0xf014dc8c
		break;
f010053f:	eb 6a                	jmp    f01005ab <cga_putc+0x124>
	case '\t':
		cons_putc(' ');
f0100541:	83 ec 0c             	sub    $0xc,%esp
f0100544:	6a 20                	push   $0x20
f0100546:	e8 79 03 00 00       	call   f01008c4 <cons_putc>
f010054b:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f010054e:	83 ec 0c             	sub    $0xc,%esp
f0100551:	6a 20                	push   $0x20
f0100553:	e8 6c 03 00 00       	call   f01008c4 <cons_putc>
f0100558:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f010055b:	83 ec 0c             	sub    $0xc,%esp
f010055e:	6a 20                	push   $0x20
f0100560:	e8 5f 03 00 00       	call   f01008c4 <cons_putc>
f0100565:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f0100568:	83 ec 0c             	sub    $0xc,%esp
f010056b:	6a 20                	push   $0x20
f010056d:	e8 52 03 00 00       	call   f01008c4 <cons_putc>
f0100572:	83 c4 10             	add    $0x10,%esp
		cons_putc(' ');
f0100575:	83 ec 0c             	sub    $0xc,%esp
f0100578:	6a 20                	push   $0x20
f010057a:	e8 45 03 00 00       	call   f01008c4 <cons_putc>
f010057f:	83 c4 10             	add    $0x10,%esp
		break;
f0100582:	eb 27                	jmp    f01005ab <cga_putc+0x124>
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100584:	8b 0d 88 dc 14 f0    	mov    0xf014dc88,%ecx
f010058a:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f0100590:	8d 50 01             	lea    0x1(%eax),%edx
f0100593:	66 89 15 8c dc 14 f0 	mov    %dx,0xf014dc8c
f010059a:	0f b7 c0             	movzwl %ax,%eax
f010059d:	01 c0                	add    %eax,%eax
f010059f:	8d 14 01             	lea    (%ecx,%eax,1),%edx
f01005a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01005a5:	66 89 02             	mov    %ax,(%edx)
		break;
f01005a8:	eb 01                	jmp    f01005ab <cga_putc+0x124>
	case '\b':
		if (crt_pos > 0) {
			crt_pos--;
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
		}
		break;
f01005aa:	90                   	nop
		crt_buf[crt_pos++] = c;		/* write the character */
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01005ab:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f01005b1:	66 3d cf 07          	cmp    $0x7cf,%ax
f01005b5:	76 58                	jbe    f010060f <cga_putc+0x188>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
f01005b7:	a1 88 dc 14 f0       	mov    0xf014dc88,%eax
f01005bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c2:	a1 88 dc 14 f0       	mov    0xf014dc88,%eax
f01005c7:	83 ec 04             	sub    $0x4,%esp
f01005ca:	68 00 0f 00 00       	push   $0xf00
f01005cf:	52                   	push   %edx
f01005d0:	50                   	push   %eax
f01005d1:	e8 ff 41 00 00       	call   f01047d5 <memcpy>
f01005d6:	83 c4 10             	add    $0x10,%esp
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f01005e0:	eb 15                	jmp    f01005f7 <cga_putc+0x170>
			crt_buf[i] = 0x0700 | ' ';
f01005e2:	8b 15 88 dc 14 f0    	mov    0xf014dc88,%edx
f01005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01005eb:	01 c0                	add    %eax,%eax
f01005ed:	01 d0                	add    %edx,%eax
f01005ef:	66 c7 00 20 07       	movw   $0x720,(%eax)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005f4:	ff 45 f4             	incl   -0xc(%ebp)
f01005f7:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
f01005fe:	7e e2                	jle    f01005e2 <cga_putc+0x15b>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100600:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f0100606:	83 e8 50             	sub    $0x50,%eax
f0100609:	66 a3 8c dc 14 f0    	mov    %ax,0xf014dc8c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010060f:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f0100614:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100617:	c6 45 e0 0e          	movb   $0xe,-0x20(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010061b:	8a 45 e0             	mov    -0x20(%ebp),%al
f010061e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100621:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100622:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f0100628:	66 c1 e8 08          	shr    $0x8,%ax
f010062c:	0f b6 c0             	movzbl %al,%eax
f010062f:	8b 15 84 dc 14 f0    	mov    0xf014dc84,%edx
f0100635:	42                   	inc    %edx
f0100636:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0100639:	88 45 e1             	mov    %al,-0x1f(%ebp)
f010063c:	8a 45 e1             	mov    -0x1f(%ebp),%al
f010063f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100642:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100643:	a1 84 dc 14 f0       	mov    0xf014dc84,%eax
f0100648:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010064b:	c6 45 e2 0f          	movb   $0xf,-0x1e(%ebp)
f010064f:	8a 45 e2             	mov    -0x1e(%ebp),%al
f0100652:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100656:	66 a1 8c dc 14 f0    	mov    0xf014dc8c,%ax
f010065c:	0f b6 c0             	movzbl %al,%eax
f010065f:	8b 15 84 dc 14 f0    	mov    0xf014dc84,%edx
f0100665:	42                   	inc    %edx
f0100666:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100669:	88 45 e3             	mov    %al,-0x1d(%ebp)
f010066c:	8a 45 e3             	mov    -0x1d(%ebp),%al
f010066f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100672:	ee                   	out    %al,(%dx)
}
f0100673:	90                   	nop
f0100674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100677:	c9                   	leave  
f0100678:	c3                   	ret    

f0100679 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	83 ec 28             	sub    $0x28,%esp
f010067f:	c7 45 e4 64 00 00 00 	movl   $0x64,-0x1c(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100686:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100689:	89 c2                	mov    %eax,%edx
f010068b:	ec                   	in     (%dx),%al
f010068c:	88 45 e3             	mov    %al,-0x1d(%ebp)
	return data;
f010068f:	8a 45 e3             	mov    -0x1d(%ebp),%al
	int c;
	uint8 data;
	static uint32 shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100692:	0f b6 c0             	movzbl %al,%eax
f0100695:	83 e0 01             	and    $0x1,%eax
f0100698:	85 c0                	test   %eax,%eax
f010069a:	75 0a                	jne    f01006a6 <kbd_proc_data+0x2d>
		return -1;
f010069c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01006a1:	e9 54 01 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
f01006a6:	c7 45 ec 60 00 00 00 	movl   $0x60,-0x14(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01006b0:	89 c2                	mov    %eax,%edx
f01006b2:	ec                   	in     (%dx),%al
f01006b3:	88 45 e2             	mov    %al,-0x1e(%ebp)
	return data;
f01006b6:	8a 45 e2             	mov    -0x1e(%ebp),%al

	data = inb(KBDATAP);
f01006b9:	88 45 f3             	mov    %al,-0xd(%ebp)

	if (data == 0xE0) {
f01006bc:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
f01006c0:	75 17                	jne    f01006d9 <kbd_proc_data+0x60>
		// E0 escape character
		shift |= E0ESC;
f01006c2:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f01006c7:	83 c8 40             	or     $0x40,%eax
f01006ca:	a3 a8 de 14 f0       	mov    %eax,0xf014dea8
		return 0;
f01006cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d4:	e9 21 01 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (data & 0x80) {
f01006d9:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006dc:	84 c0                	test   %al,%al
f01006de:	79 44                	jns    f0100724 <kbd_proc_data+0xab>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006e0:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f01006e5:	83 e0 40             	and    $0x40,%eax
f01006e8:	85 c0                	test   %eax,%eax
f01006ea:	75 08                	jne    f01006f4 <kbd_proc_data+0x7b>
f01006ec:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006ef:	83 e0 7f             	and    $0x7f,%eax
f01006f2:	eb 03                	jmp    f01006f7 <kbd_proc_data+0x7e>
f01006f4:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006f7:	88 45 f3             	mov    %al,-0xd(%ebp)
		shift &= ~(shiftcode[data] | E0ESC);
f01006fa:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f01006fe:	8a 80 20 b0 11 f0    	mov    -0xfee4fe0(%eax),%al
f0100704:	83 c8 40             	or     $0x40,%eax
f0100707:	0f b6 c0             	movzbl %al,%eax
f010070a:	f7 d0                	not    %eax
f010070c:	89 c2                	mov    %eax,%edx
f010070e:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100713:	21 d0                	and    %edx,%eax
f0100715:	a3 a8 de 14 f0       	mov    %eax,0xf014dea8
		return 0;
f010071a:	b8 00 00 00 00       	mov    $0x0,%eax
f010071f:	e9 d6 00 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (shift & E0ESC) {
f0100724:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100729:	83 e0 40             	and    $0x40,%eax
f010072c:	85 c0                	test   %eax,%eax
f010072e:	74 11                	je     f0100741 <kbd_proc_data+0xc8>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100730:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f0100734:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100739:	83 e0 bf             	and    $0xffffffbf,%eax
f010073c:	a3 a8 de 14 f0       	mov    %eax,0xf014dea8
	}

	shift |= shiftcode[data];
f0100741:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100745:	8a 80 20 b0 11 f0    	mov    -0xfee4fe0(%eax),%al
f010074b:	0f b6 d0             	movzbl %al,%edx
f010074e:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100753:	09 d0                	or     %edx,%eax
f0100755:	a3 a8 de 14 f0       	mov    %eax,0xf014dea8
	shift ^= togglecode[data];
f010075a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010075e:	8a 80 20 b1 11 f0    	mov    -0xfee4ee0(%eax),%al
f0100764:	0f b6 d0             	movzbl %al,%edx
f0100767:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f010076c:	31 d0                	xor    %edx,%eax
f010076e:	a3 a8 de 14 f0       	mov    %eax,0xf014dea8

	c = charcode[shift & (CTL | SHIFT)][data];
f0100773:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100778:	83 e0 03             	and    $0x3,%eax
f010077b:	8b 14 85 20 b5 11 f0 	mov    -0xfee4ae0(,%eax,4),%edx
f0100782:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100786:	01 d0                	add    %edx,%eax
f0100788:	8a 00                	mov    (%eax),%al
f010078a:	0f b6 c0             	movzbl %al,%eax
f010078d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f0100790:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f0100795:	83 e0 08             	and    $0x8,%eax
f0100798:	85 c0                	test   %eax,%eax
f010079a:	74 22                	je     f01007be <kbd_proc_data+0x145>
		if ('a' <= c && c <= 'z')
f010079c:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
f01007a0:	7e 0c                	jle    f01007ae <kbd_proc_data+0x135>
f01007a2:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
f01007a6:	7f 06                	jg     f01007ae <kbd_proc_data+0x135>
			c += 'A' - 'a';
f01007a8:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
f01007ac:	eb 10                	jmp    f01007be <kbd_proc_data+0x145>
		else if ('A' <= c && c <= 'Z')
f01007ae:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
f01007b2:	7e 0a                	jle    f01007be <kbd_proc_data+0x145>
f01007b4:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
f01007b8:	7f 04                	jg     f01007be <kbd_proc_data+0x145>
			c += 'a' - 'A';
f01007ba:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007be:	a1 a8 de 14 f0       	mov    0xf014dea8,%eax
f01007c3:	f7 d0                	not    %eax
f01007c5:	83 e0 06             	and    $0x6,%eax
f01007c8:	85 c0                	test   %eax,%eax
f01007ca:	75 2b                	jne    f01007f7 <kbd_proc_data+0x17e>
f01007cc:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f01007d3:	75 22                	jne    f01007f7 <kbd_proc_data+0x17e>
		cprintf("Rebooting!\n");
f01007d5:	83 ec 0c             	sub    $0xc,%esp
f01007d8:	68 06 4f 10 f0       	push   $0xf0104f06
f01007dd:	e8 e1 28 00 00       	call   f01030c3 <cprintf>
f01007e2:	83 c4 10             	add    $0x10,%esp
f01007e5:	c7 45 e8 92 00 00 00 	movl   $0x92,-0x18(%ebp)
f01007ec:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007f0:	8a 45 e1             	mov    -0x1f(%ebp),%al
f01007f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01007f6:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01007fa:	c9                   	leave  
f01007fb:	c3                   	ret    

f01007fc <kbd_intr>:

void
kbd_intr(void)
{
f01007fc:	55                   	push   %ebp
f01007fd:	89 e5                	mov    %esp,%ebp
f01007ff:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100802:	83 ec 0c             	sub    $0xc,%esp
f0100805:	68 79 06 10 f0       	push   $0xf0100679
f010080a:	e8 0c 00 00 00       	call   f010081b <cons_intr>
f010080f:	83 c4 10             	add    $0x10,%esp
}
f0100812:	90                   	nop
f0100813:	c9                   	leave  
f0100814:	c3                   	ret    

f0100815 <kbd_init>:

void
kbd_init(void)
{
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
}
f0100818:	90                   	nop
f0100819:	5d                   	pop    %ebp
f010081a:	c3                   	ret    

f010081b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
void
cons_intr(int (*proc)(void))
{
f010081b:	55                   	push   %ebp
f010081c:	89 e5                	mov    %esp,%ebp
f010081e:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = (*proc)()) != -1) {
f0100821:	eb 35                	jmp    f0100858 <cons_intr+0x3d>
		if (c == 0)
f0100823:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100827:	75 02                	jne    f010082b <cons_intr+0x10>
			continue;
f0100829:	eb 2d                	jmp    f0100858 <cons_intr+0x3d>
		cons.buf[cons.wpos++] = c;
f010082b:	a1 a4 de 14 f0       	mov    0xf014dea4,%eax
f0100830:	8d 50 01             	lea    0x1(%eax),%edx
f0100833:	89 15 a4 de 14 f0    	mov    %edx,0xf014dea4
f0100839:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010083c:	88 90 a0 dc 14 f0    	mov    %dl,-0xfeb2360(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100842:	a1 a4 de 14 f0       	mov    0xf014dea4,%eax
f0100847:	3d 00 02 00 00       	cmp    $0x200,%eax
f010084c:	75 0a                	jne    f0100858 <cons_intr+0x3d>
			cons.wpos = 0;
f010084e:	c7 05 a4 de 14 f0 00 	movl   $0x0,0xf014dea4
f0100855:	00 00 00 
void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100858:	8b 45 08             	mov    0x8(%ebp),%eax
f010085b:	ff d0                	call   *%eax
f010085d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100860:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
f0100864:	75 bd                	jne    f0100823 <cons_intr+0x8>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100866:	90                   	nop
f0100867:	c9                   	leave  
f0100868:	c3                   	ret    

f0100869 <cons_getc>:

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100869:	55                   	push   %ebp
f010086a:	89 e5                	mov    %esp,%ebp
f010086c:	83 ec 18             	sub    $0x18,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010086f:	e8 a7 f9 ff ff       	call   f010021b <serial_intr>
	kbd_intr();
f0100874:	e8 83 ff ff ff       	call   f01007fc <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100879:	8b 15 a0 de 14 f0    	mov    0xf014dea0,%edx
f010087f:	a1 a4 de 14 f0       	mov    0xf014dea4,%eax
f0100884:	39 c2                	cmp    %eax,%edx
f0100886:	74 35                	je     f01008bd <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
f0100888:	a1 a0 de 14 f0       	mov    0xf014dea0,%eax
f010088d:	8d 50 01             	lea    0x1(%eax),%edx
f0100890:	89 15 a0 de 14 f0    	mov    %edx,0xf014dea0
f0100896:	8a 80 a0 dc 14 f0    	mov    -0xfeb2360(%eax),%al
f010089c:	0f b6 c0             	movzbl %al,%eax
f010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f01008a2:	a1 a0 de 14 f0       	mov    0xf014dea0,%eax
f01008a7:	3d 00 02 00 00       	cmp    $0x200,%eax
f01008ac:	75 0a                	jne    f01008b8 <cons_getc+0x4f>
			cons.rpos = 0;
f01008ae:	c7 05 a0 de 14 f0 00 	movl   $0x0,0xf014dea0
f01008b5:	00 00 00 
		return c;
f01008b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01008bb:	eb 05                	jmp    f01008c2 <cons_getc+0x59>
	}
	return 0;
f01008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01008c2:	c9                   	leave  
f01008c3:	c3                   	ret    

f01008c4 <cons_putc>:

// output a character to the console
void
cons_putc(int c)
{
f01008c4:	55                   	push   %ebp
f01008c5:	89 e5                	mov    %esp,%ebp
f01008c7:	83 ec 08             	sub    $0x8,%esp
	lpt_putc(c);
f01008ca:	ff 75 08             	pushl  0x8(%ebp)
f01008cd:	e8 7b fa ff ff       	call   f010034d <lpt_putc>
f01008d2:	83 c4 04             	add    $0x4,%esp
	cga_putc(c);
f01008d5:	83 ec 0c             	sub    $0xc,%esp
f01008d8:	ff 75 08             	pushl  0x8(%ebp)
f01008db:	e8 a7 fb ff ff       	call   f0100487 <cga_putc>
f01008e0:	83 c4 10             	add    $0x10,%esp
}
f01008e3:	90                   	nop
f01008e4:	c9                   	leave  
f01008e5:	c3                   	ret    

f01008e6 <console_initialize>:

// initialize the console devices
void
console_initialize(void)
{
f01008e6:	55                   	push   %ebp
f01008e7:	89 e5                	mov    %esp,%ebp
f01008e9:	83 ec 08             	sub    $0x8,%esp
	cga_init();
f01008ec:	e8 d1 fa ff ff       	call   f01003c2 <cga_init>
	kbd_init();
f01008f1:	e8 1f ff ff ff       	call   f0100815 <kbd_init>
	serial_init();
f01008f6:	e8 42 f9 ff ff       	call   f010023d <serial_init>

	if (!serial_exists)
f01008fb:	a1 80 dc 14 f0       	mov    0xf014dc80,%eax
f0100900:	85 c0                	test   %eax,%eax
f0100902:	75 10                	jne    f0100914 <console_initialize+0x2e>
		cprintf("Serial port does not exist!\n");
f0100904:	83 ec 0c             	sub    $0xc,%esp
f0100907:	68 12 4f 10 f0       	push   $0xf0104f12
f010090c:	e8 b2 27 00 00       	call   f01030c3 <cprintf>
f0100911:	83 c4 10             	add    $0x10,%esp
}
f0100914:	90                   	nop
f0100915:	c9                   	leave  
f0100916:	c3                   	ret    

f0100917 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100917:	55                   	push   %ebp
f0100918:	89 e5                	mov    %esp,%ebp
f010091a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010091d:	83 ec 0c             	sub    $0xc,%esp
f0100920:	ff 75 08             	pushl  0x8(%ebp)
f0100923:	e8 9c ff ff ff       	call   f01008c4 <cons_putc>
f0100928:	83 c4 10             	add    $0x10,%esp
}
f010092b:	90                   	nop
f010092c:	c9                   	leave  
f010092d:	c3                   	ret    

f010092e <getchar>:

int
getchar(void)
{
f010092e:	55                   	push   %ebp
f010092f:	89 e5                	mov    %esp,%ebp
f0100931:	83 ec 18             	sub    $0x18,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100934:	e8 30 ff ff ff       	call   f0100869 <cons_getc>
f0100939:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010093c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100940:	74 f2                	je     f0100934 <getchar+0x6>
		/* do nothing */;
	return c;
f0100942:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0100945:	c9                   	leave  
f0100946:	c3                   	ret    

f0100947 <iscons>:

int
iscons(int fdnum)
{
f0100947:	55                   	push   %ebp
f0100948:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
f010094a:	b8 01 00 00 00       	mov    $0x1,%eax
}
f010094f:	5d                   	pop    %ebp
f0100950:	c3                   	ret    

f0100951 <run_command_prompt>:
unsigned read_eip();


//invoke the command prompt
void run_command_prompt()
{
f0100951:	55                   	push   %ebp
f0100952:	89 e5                	mov    %esp,%ebp
f0100954:	81 ec 08 04 00 00    	sub    $0x408,%esp
	char command_line[1024];

	while (1==1) 
	{
		//get command line
		readline("FOS> ", command_line);
f010095a:	83 ec 08             	sub    $0x8,%esp
f010095d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
f0100963:	50                   	push   %eax
f0100964:	68 47 51 10 f0       	push   $0xf0105147
f0100969:	e8 4b 3b 00 00       	call   f01044b9 <readline>
f010096e:	83 c4 10             	add    $0x10,%esp
		
		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
f0100971:	83 ec 0c             	sub    $0xc,%esp
f0100974:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
f010097a:	50                   	push   %eax
f010097b:	e8 0d 00 00 00       	call   f010098d <execute_command>
f0100980:	83 c4 10             	add    $0x10,%esp
f0100983:	85 c0                	test   %eax,%eax
f0100985:	78 02                	js     f0100989 <run_command_prompt+0x38>
				break;
	}
f0100987:	eb d1                	jmp    f010095a <run_command_prompt+0x9>
		readline("FOS> ", command_line);
		
		//parse and execute the command
		if (command_line != NULL)
			if (execute_command(command_line) < 0)
				break;
f0100989:	90                   	nop
	}
}
f010098a:	90                   	nop
f010098b:	c9                   	leave  
f010098c:	c3                   	ret    

f010098d <execute_command>:
#define WHITESPACE "\t\r\n "

//Function to parse any command and execute it 
//(simply by calling its corresponding function)
int execute_command(char *command_string)
{
f010098d:	55                   	push   %ebp
f010098e:	89 e5                	mov    %esp,%ebp
f0100990:	83 ec 58             	sub    $0x58,%esp

	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];


	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments) ;
f0100993:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0100996:	50                   	push   %eax
f0100997:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010099a:	50                   	push   %eax
f010099b:	68 4d 51 10 f0       	push   $0xf010514d
f01009a0:	ff 75 08             	pushl  0x8(%ebp)
f01009a3:	e8 b5 40 00 00       	call   f0104a5d <strsplit>
f01009a8:	83 c4 10             	add    $0x10,%esp
	if (number_of_arguments == 0)
f01009ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01009ae:	85 c0                	test   %eax,%eax
f01009b0:	75 0a                	jne    f01009bc <execute_command+0x2f>
		return 0;
f01009b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01009b7:	e9 95 00 00 00       	jmp    f0100a51 <execute_command+0xc4>
	
	// Lookup in the commands array and execute the command
	int command_found = 0;
f01009bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i ;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f01009c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f01009ca:	eb 33                	jmp    f01009ff <execute_command+0x72>
	{
		if (strcmp(arguments[0], commands[i].name) == 0)
f01009cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01009cf:	89 d0                	mov    %edx,%eax
f01009d1:	01 c0                	add    %eax,%eax
f01009d3:	01 d0                	add    %edx,%eax
f01009d5:	c1 e0 02             	shl    $0x2,%eax
f01009d8:	05 40 b5 11 f0       	add    $0xf011b540,%eax
f01009dd:	8b 10                	mov    (%eax),%edx
f01009df:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	52                   	push   %edx
f01009e6:	50                   	push   %eax
f01009e7:	e8 d7 3c 00 00       	call   f01046c3 <strcmp>
f01009ec:	83 c4 10             	add    $0x10,%esp
f01009ef:	85 c0                	test   %eax,%eax
f01009f1:	75 09                	jne    f01009fc <execute_command+0x6f>
		{
			command_found = 1;
f01009f3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
			break;
f01009fa:	eb 0b                	jmp    f0100a07 <execute_command+0x7a>
		return 0;
	
	// Lookup in the commands array and execute the command
	int command_found = 0;
	int i ;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f01009fc:	ff 45 f0             	incl   -0x10(%ebp)
f01009ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a02:	83 f8 08             	cmp    $0x8,%eax
f0100a05:	76 c5                	jbe    f01009cc <execute_command+0x3f>
			command_found = 1;
			break;
		}
	}
	
	if(command_found)
f0100a07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0100a0b:	74 2b                	je     f0100a38 <execute_command+0xab>
	{
		int return_value;
		return_value = commands[i].function_to_execute(number_of_arguments, arguments);			
f0100a0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0100a10:	89 d0                	mov    %edx,%eax
f0100a12:	01 c0                	add    %eax,%eax
f0100a14:	01 d0                	add    %edx,%eax
f0100a16:	c1 e0 02             	shl    $0x2,%eax
f0100a19:	05 48 b5 11 f0       	add    $0xf011b548,%eax
f0100a1e:	8b 00                	mov    (%eax),%eax
f0100a20:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a23:	83 ec 08             	sub    $0x8,%esp
f0100a26:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100a29:	51                   	push   %ecx
f0100a2a:	52                   	push   %edx
f0100a2b:	ff d0                	call   *%eax
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	89 45 ec             	mov    %eax,-0x14(%ebp)
		return return_value;
f0100a33:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100a36:	eb 19                	jmp    f0100a51 <execute_command+0xc4>
	}
	else
	{
		//if not found, then it's unknown command
		cprintf("Unknown command '%s'\n", arguments[0]);
f0100a38:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a3b:	83 ec 08             	sub    $0x8,%esp
f0100a3e:	50                   	push   %eax
f0100a3f:	68 52 51 10 f0       	push   $0xf0105152
f0100a44:	e8 7a 26 00 00       	call   f01030c3 <cprintf>
f0100a49:	83 c4 10             	add    $0x10,%esp
		return 0;
f0100a4c:	b8 00 00 00 00       	mov    $0x0,%eax
	}
}
f0100a51:	c9                   	leave  
f0100a52:	c3                   	ret    

f0100a53 <command_help>:

/***** Implementations of basic kernel command prompt commands *****/

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
f0100a53:	55                   	push   %ebp
f0100a54:	89 e5                	mov    %esp,%ebp
f0100a56:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100a59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100a60:	eb 3b                	jmp    f0100a9d <command_help+0x4a>
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
f0100a62:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100a65:	89 d0                	mov    %edx,%eax
f0100a67:	01 c0                	add    %eax,%eax
f0100a69:	01 d0                	add    %edx,%eax
f0100a6b:	c1 e0 02             	shl    $0x2,%eax
f0100a6e:	05 44 b5 11 f0       	add    $0xf011b544,%eax
f0100a73:	8b 10                	mov    (%eax),%edx
f0100a75:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0100a78:	89 c8                	mov    %ecx,%eax
f0100a7a:	01 c0                	add    %eax,%eax
f0100a7c:	01 c8                	add    %ecx,%eax
f0100a7e:	c1 e0 02             	shl    $0x2,%eax
f0100a81:	05 40 b5 11 f0       	add    $0xf011b540,%eax
f0100a86:	8b 00                	mov    (%eax),%eax
f0100a88:	83 ec 04             	sub    $0x4,%esp
f0100a8b:	52                   	push   %edx
f0100a8c:	50                   	push   %eax
f0100a8d:	68 68 51 10 f0       	push   $0xf0105168
f0100a92:	e8 2c 26 00 00       	call   f01030c3 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100a9a:	ff 45 f4             	incl   -0xc(%ebp)
f0100a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aa0:	83 f8 08             	cmp    $0x8,%eax
f0100aa3:	76 bd                	jbe    f0100a62 <command_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
	
	cprintf("-------------------\n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 71 51 10 f0       	push   $0xf0105171
f0100aad:	e8 11 26 00 00       	call   f01030c3 <cprintf>
f0100ab2:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f0100ab5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100aba:	c9                   	leave  
f0100abb:	c3                   	ret    

f0100abc <command_kernel_info>:

//print information about kernel addresses and kernel size
int command_kernel_info(int number_of_arguments, char **arguments )
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 08             	sub    $0x8,%esp
	extern char start_of_kernel[], end_of_kernel_code_section[], start_of_uninitialized_data_section[], end_of_kernel[];

	cprintf("Special kernel symbols:\n");
f0100ac2:	83 ec 0c             	sub    $0xc,%esp
f0100ac5:	68 86 51 10 f0       	push   $0xf0105186
f0100aca:	e8 f4 25 00 00       	call   f01030c3 <cprintf>
f0100acf:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
f0100ad2:	b8 0c 00 10 00       	mov    $0x10000c,%eax
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	50                   	push   %eax
f0100adb:	68 0c 00 10 f0       	push   $0xf010000c
f0100ae0:	68 a0 51 10 f0       	push   $0xf01051a0
f0100ae5:	e8 d9 25 00 00       	call   f01030c3 <cprintf>
f0100aea:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
f0100aed:	b8 95 4d 10 00       	mov    $0x104d95,%eax
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	50                   	push   %eax
f0100af6:	68 95 4d 10 f0       	push   $0xf0104d95
f0100afb:	68 dc 51 10 f0       	push   $0xf01051dc
f0100b00:	e8 be 25 00 00       	call   f01030c3 <cprintf>
f0100b05:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
f0100b08:	b8 52 dc 14 00       	mov    $0x14dc52,%eax
f0100b0d:	83 ec 04             	sub    $0x4,%esp
f0100b10:	50                   	push   %eax
f0100b11:	68 52 dc 14 f0       	push   $0xf014dc52
f0100b16:	68 18 52 10 f0       	push   $0xf0105218
f0100b1b:	e8 a3 25 00 00       	call   f01030c3 <cprintf>
f0100b20:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
f0100b23:	b8 4c e7 14 00       	mov    $0x14e74c,%eax
f0100b28:	83 ec 04             	sub    $0x4,%esp
f0100b2b:	50                   	push   %eax
f0100b2c:	68 4c e7 14 f0       	push   $0xf014e74c
f0100b31:	68 60 52 10 f0       	push   $0xf0105260
f0100b36:	e8 88 25 00 00       	call   f01030c3 <cprintf>
f0100b3b:	83 c4 10             	add    $0x10,%esp
	cprintf("Kernel executable memory footprint: %d KB\n",
		(end_of_kernel-start_of_kernel+1023)/1024);
f0100b3e:	b8 4c e7 14 f0       	mov    $0xf014e74c,%eax
f0100b43:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100b49:	b8 0c 00 10 f0       	mov    $0xf010000c,%eax
f0100b4e:	29 c2                	sub    %eax,%edx
f0100b50:	89 d0                	mov    %edx,%eax
	cprintf("Special kernel symbols:\n");
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
	cprintf("Kernel executable memory footprint: %d KB\n",
f0100b52:	85 c0                	test   %eax,%eax
f0100b54:	79 05                	jns    f0100b5b <command_kernel_info+0x9f>
f0100b56:	05 ff 03 00 00       	add    $0x3ff,%eax
f0100b5b:	c1 f8 0a             	sar    $0xa,%eax
f0100b5e:	83 ec 08             	sub    $0x8,%esp
f0100b61:	50                   	push   %eax
f0100b62:	68 9c 52 10 f0       	push   $0xf010529c
f0100b67:	e8 57 25 00 00       	call   f01030c3 <cprintf>
f0100b6c:	83 c4 10             	add    $0x10,%esp
		(end_of_kernel-start_of_kernel+1023)/1024);
	return 0;
f0100b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b74:	c9                   	leave  
f0100b75:	c3                   	ret    

f0100b76 <command_writemem>:

int command_writemem(int number_of_arguments, char **arguments)
{
f0100b76:	55                   	push   %ebp
f0100b77:	89 e5                	mov    %esp,%ebp
f0100b79:	83 ec 38             	sub    $0x38,%esp
	char* user_program_name = arguments[1];		
f0100b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b7f:	8b 40 04             	mov    0x4(%eax),%eax
f0100b82:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int address = strtol(arguments[3], NULL, 16);
f0100b85:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b88:	83 c0 0c             	add    $0xc,%eax
f0100b8b:	8b 00                	mov    (%eax),%eax
f0100b8d:	83 ec 04             	sub    $0x4,%esp
f0100b90:	6a 10                	push   $0x10
f0100b92:	6a 00                	push   $0x0
f0100b94:	50                   	push   %eax
f0100b95:	e8 7d 3d 00 00       	call   f0104917 <strtol>
f0100b9a:	83 c4 10             	add    $0x10,%esp
f0100b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
f0100ba0:	83 ec 0c             	sub    $0xc,%esp
f0100ba3:	ff 75 f4             	pushl  -0xc(%ebp)
f0100ba6:	e8 41 22 00 00       	call   f0102dec <get_user_program_info>
f0100bab:	83 c4 10             	add    $0x10,%esp
f0100bae:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(ptr_user_program_info == NULL) return 0;	
f0100bb1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100bb5:	75 07                	jne    f0100bbe <command_writemem+0x48>
f0100bb7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bbc:	eb 71                	jmp    f0100c2f <command_writemem+0xb9>

static __inline uint32
rcr3(void)
{
	uint32 val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0100bbe:	0f 20 d8             	mov    %cr3,%eax
f0100bc1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return val;
f0100bc4:	8b 45 d4             	mov    -0x2c(%ebp),%eax

	uint32 oldDir = rcr3();
f0100bc7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f0100bca:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100bcd:	8b 40 0c             	mov    0xc(%eax),%eax
f0100bd0:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100bd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100bd6:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0100bdd:	77 17                	ja     f0100bf6 <command_writemem+0x80>
f0100bdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0100be2:	68 c8 52 10 f0       	push   $0xf01052c8
f0100be7:	68 a3 00 00 00       	push   $0xa3
f0100bec:	68 f9 52 10 f0       	push   $0xf01052f9
f0100bf1:	e8 38 f5 ff ff       	call   f010012e <_panic>
f0100bf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bf9:	05 00 00 00 10       	add    $0x10000000,%eax
f0100bfe:	89 45 d8             	mov    %eax,-0x28(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100c01:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100c04:	0f 22 d8             	mov    %eax,%cr3

	unsigned char *ptr = (unsigned char *)(address) ; 
f0100c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c0a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	//Write the given Character
	*ptr = arguments[2][0];
f0100c0d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c10:	83 c0 08             	add    $0x8,%eax
f0100c13:	8b 00                	mov    (%eax),%eax
f0100c15:	8a 00                	mov    (%eax),%al
f0100c17:	88 c2                	mov    %al,%dl
f0100c19:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100c1c:	88 10                	mov    %dl,(%eax)
f0100c1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c21:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0100c24:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100c27:	0f 22 d8             	mov    %eax,%cr3
	lcr3(oldDir);	

	return 0;
f0100c2a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c2f:	c9                   	leave  
f0100c30:	c3                   	ret    

f0100c31 <command_readmem>:

int command_readmem(int number_of_arguments, char **arguments)
{
f0100c31:	55                   	push   %ebp
f0100c32:	89 e5                	mov    %esp,%ebp
f0100c34:	83 ec 38             	sub    $0x38,%esp
	char* user_program_name = arguments[1];		
f0100c37:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c3a:	8b 40 04             	mov    0x4(%eax),%eax
f0100c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int address = strtol(arguments[2], NULL, 16);
f0100c40:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c43:	83 c0 08             	add    $0x8,%eax
f0100c46:	8b 00                	mov    (%eax),%eax
f0100c48:	83 ec 04             	sub    $0x4,%esp
f0100c4b:	6a 10                	push   $0x10
f0100c4d:	6a 00                	push   $0x0
f0100c4f:	50                   	push   %eax
f0100c50:	e8 c2 3c 00 00       	call   f0104917 <strtol>
f0100c55:	83 c4 10             	add    $0x10,%esp
f0100c58:	89 45 f0             	mov    %eax,-0x10(%ebp)

	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
f0100c5b:	83 ec 0c             	sub    $0xc,%esp
f0100c5e:	ff 75 f4             	pushl  -0xc(%ebp)
f0100c61:	e8 86 21 00 00       	call   f0102dec <get_user_program_info>
f0100c66:	83 c4 10             	add    $0x10,%esp
f0100c69:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(ptr_user_program_info == NULL) return 0;	
f0100c6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100c70:	75 07                	jne    f0100c79 <command_readmem+0x48>
f0100c72:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c77:	eb 7c                	jmp    f0100cf5 <command_readmem+0xc4>

static __inline uint32
rcr3(void)
{
	uint32 val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0100c79:	0f 20 d8             	mov    %cr3,%eax
f0100c7c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	return val;
f0100c7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax

	uint32 oldDir = rcr3();
f0100c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f0100c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100c88:	8b 40 0c             	mov    0xc(%eax),%eax
f0100c8b:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100c8e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100c91:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0100c98:	77 17                	ja     f0100cb1 <command_readmem+0x80>
f0100c9a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100c9d:	68 c8 52 10 f0       	push   $0xf01052c8
f0100ca2:	68 b7 00 00 00       	push   $0xb7
f0100ca7:	68 f9 52 10 f0       	push   $0xf01052f9
f0100cac:	e8 7d f4 ff ff       	call   f010012e <_panic>
f0100cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cb4:	05 00 00 00 10       	add    $0x10000000,%eax
f0100cb9:	89 45 d8             	mov    %eax,-0x28(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100cbc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cbf:	0f 22 d8             	mov    %eax,%cr3

	unsigned char *ptr = (unsigned char *)(address) ;
f0100cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100cc5:	89 45 dc             	mov    %eax,-0x24(%ebp)
	
	//Write the given Character
	cprintf("value at address %x = %c\n", address, *ptr);
f0100cc8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ccb:	8a 00                	mov    (%eax),%al
f0100ccd:	0f b6 c0             	movzbl %al,%eax
f0100cd0:	83 ec 04             	sub    $0x4,%esp
f0100cd3:	50                   	push   %eax
f0100cd4:	ff 75 f0             	pushl  -0x10(%ebp)
f0100cd7:	68 0f 53 10 f0       	push   $0xf010530f
f0100cdc:	e8 e2 23 00 00       	call   f01030c3 <cprintf>
f0100ce1:	83 c4 10             	add    $0x10,%esp
f0100ce4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ce7:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0100cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100ced:	0f 22 d8             	mov    %eax,%cr3
	
	lcr3(oldDir);	
	return 0;
f0100cf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cf5:	c9                   	leave  
f0100cf6:	c3                   	ret    

f0100cf7 <command_readblock>:

int command_readblock(int number_of_arguments, char **arguments)
{
f0100cf7:	55                   	push   %ebp
f0100cf8:	89 e5                	mov    %esp,%ebp
f0100cfa:	83 ec 38             	sub    $0x38,%esp
	char* user_program_name = arguments[1];	
f0100cfd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d00:	8b 40 04             	mov    0x4(%eax),%eax
f0100d03:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int address = strtol(arguments[2], NULL, 16);
f0100d06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d09:	83 c0 08             	add    $0x8,%eax
f0100d0c:	8b 00                	mov    (%eax),%eax
f0100d0e:	83 ec 04             	sub    $0x4,%esp
f0100d11:	6a 10                	push   $0x10
f0100d13:	6a 00                	push   $0x0
f0100d15:	50                   	push   %eax
f0100d16:	e8 fc 3b 00 00       	call   f0104917 <strtol>
f0100d1b:	83 c4 10             	add    $0x10,%esp
f0100d1e:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int nBytes = strtol(arguments[3], NULL, 10);
f0100d21:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100d24:	83 c0 0c             	add    $0xc,%eax
f0100d27:	8b 00                	mov    (%eax),%eax
f0100d29:	83 ec 04             	sub    $0x4,%esp
f0100d2c:	6a 0a                	push   $0xa
f0100d2e:	6a 00                	push   $0x0
f0100d30:	50                   	push   %eax
f0100d31:	e8 e1 3b 00 00       	call   f0104917 <strtol>
f0100d36:	83 c4 10             	add    $0x10,%esp
f0100d39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	 
	unsigned char *ptr = (unsigned char *)(address) ;
f0100d3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//Write the given Character	
		
	struct UserProgramInfo* ptr_user_program_info = get_user_program_info(user_program_name);
f0100d42:	83 ec 0c             	sub    $0xc,%esp
f0100d45:	ff 75 ec             	pushl  -0x14(%ebp)
f0100d48:	e8 9f 20 00 00       	call   f0102dec <get_user_program_info>
f0100d4d:	83 c4 10             	add    $0x10,%esp
f0100d50:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if(ptr_user_program_info == NULL) return 0;	
f0100d53:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100d57:	75 0a                	jne    f0100d63 <command_readblock+0x6c>
f0100d59:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d5e:	e9 93 00 00 00       	jmp    f0100df6 <command_readblock+0xff>

static __inline uint32
rcr3(void)
{
	uint32 val;
	__asm __volatile("movl %%cr3,%0" : "=r" (val));
f0100d63:	0f 20 d8             	mov    %cr3,%eax
f0100d66:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return val;
f0100d69:	8b 45 cc             	mov    -0x34(%ebp),%eax

	uint32 oldDir = rcr3();
f0100d6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));
f0100d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d72:	8b 40 0c             	mov    0xc(%eax),%eax
f0100d75:	8b 40 5c             	mov    0x5c(%eax),%eax
f0100d78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0100d7b:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0100d82:	77 17                	ja     f0100d9b <command_readblock+0xa4>
f0100d84:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100d87:	68 c8 52 10 f0       	push   $0xf01052c8
f0100d8c:	68 cf 00 00 00       	push   $0xcf
f0100d91:	68 f9 52 10 f0       	push   $0xf01052f9
f0100d96:	e8 93 f3 ff ff       	call   f010012e <_panic>
f0100d9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100d9e:	05 00 00 00 10       	add    $0x10000000,%eax
f0100da3:	89 45 dc             	mov    %eax,-0x24(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100da6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100da9:	0f 22 d8             	mov    %eax,%cr3

	int i;	
	for(i = 0;i<nBytes; i++)
f0100dac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0100db3:	eb 28                	jmp    f0100ddd <command_readblock+0xe6>
	{
		cprintf("%08x : %02x  %c\n", ptr, *ptr, *ptr);
f0100db5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100db8:	8a 00                	mov    (%eax),%al
f0100dba:	0f b6 d0             	movzbl %al,%edx
f0100dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100dc0:	8a 00                	mov    (%eax),%al
f0100dc2:	0f b6 c0             	movzbl %al,%eax
f0100dc5:	52                   	push   %edx
f0100dc6:	50                   	push   %eax
f0100dc7:	ff 75 f4             	pushl  -0xc(%ebp)
f0100dca:	68 29 53 10 f0       	push   $0xf0105329
f0100dcf:	e8 ef 22 00 00       	call   f01030c3 <cprintf>
f0100dd4:	83 c4 10             	add    $0x10,%esp
		ptr++;
f0100dd7:	ff 45 f4             	incl   -0xc(%ebp)

	uint32 oldDir = rcr3();
	lcr3((uint32) K_PHYSICAL_ADDRESS( ptr_user_program_info->environment->env_pgdir));

	int i;	
	for(i = 0;i<nBytes; i++)
f0100dda:	ff 45 f0             	incl   -0x10(%ebp)
f0100ddd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100de0:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f0100de3:	7c d0                	jl     f0100db5 <command_readblock+0xbe>
f0100de5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100de8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100deb:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100dee:	0f 22 d8             	mov    %eax,%cr3
		cprintf("%08x : %02x  %c\n", ptr, *ptr, *ptr);
		ptr++;
	}
	lcr3(oldDir);

	return 0;
f0100df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100df6:	c9                   	leave  
f0100df7:	c3                   	ret    

f0100df8 <command_allocpage>:

int command_allocpage(int number_of_arguments, char **arguments)
{
f0100df8:	55                   	push   %ebp
f0100df9:	89 e5                	mov    %esp,%ebp
f0100dfb:	83 ec 18             	sub    $0x18,%esp
	unsigned int address = strtol(arguments[1], NULL, 16); 
f0100dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e01:	83 c0 04             	add    $0x4,%eax
f0100e04:	8b 00                	mov    (%eax),%eax
f0100e06:	83 ec 04             	sub    $0x4,%esp
f0100e09:	6a 10                	push   $0x10
f0100e0b:	6a 00                	push   $0x0
f0100e0d:	50                   	push   %eax
f0100e0e:	e8 04 3b 00 00       	call   f0104917 <strtol>
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	89 45 f4             	mov    %eax,-0xc(%ebp)
	unsigned char *ptr = (unsigned char *)(address) ;
f0100e19:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	struct Frame_Info * ptr_frame_info ;
	allocate_frame(&ptr_frame_info);
f0100e1f:	83 ec 0c             	sub    $0xc,%esp
f0100e22:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100e25:	50                   	push   %eax
f0100e26:	e8 23 16 00 00       	call   f010244e <allocate_frame>
f0100e2b:	83 c4 10             	add    $0x10,%esp
	
	map_frame(ptr_page_directory, ptr_frame_info, ptr, PERM_WRITEABLE|PERM_USER);
f0100e2e:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100e31:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0100e36:	6a 06                	push   $0x6
f0100e38:	ff 75 f0             	pushl  -0x10(%ebp)
f0100e3b:	52                   	push   %edx
f0100e3c:	50                   	push   %eax
f0100e3d:	e8 19 18 00 00       	call   f010265b <map_frame>
f0100e42:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f0100e45:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e4a:	c9                   	leave  
f0100e4b:	c3                   	ret    

f0100e4c <command_readusermem>:


int command_readusermem(int number_of_arguments, char **arguments)
{
f0100e4c:	55                   	push   %ebp
f0100e4d:	89 e5                	mov    %esp,%ebp
f0100e4f:	83 ec 18             	sub    $0x18,%esp
	unsigned int address = strtol(arguments[1], NULL, 16); 
f0100e52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e55:	83 c0 04             	add    $0x4,%eax
f0100e58:	8b 00                	mov    (%eax),%eax
f0100e5a:	83 ec 04             	sub    $0x4,%esp
f0100e5d:	6a 10                	push   $0x10
f0100e5f:	6a 00                	push   $0x0
f0100e61:	50                   	push   %eax
f0100e62:	e8 b0 3a 00 00       	call   f0104917 <strtol>
f0100e67:	83 c4 10             	add    $0x10,%esp
f0100e6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	unsigned char *ptr = (unsigned char *)(address) ;
f0100e6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e70:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	cprintf("value at address %x = %c\n", ptr, *ptr);
f0100e73:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100e76:	8a 00                	mov    (%eax),%al
f0100e78:	0f b6 c0             	movzbl %al,%eax
f0100e7b:	83 ec 04             	sub    $0x4,%esp
f0100e7e:	50                   	push   %eax
f0100e7f:	ff 75 f0             	pushl  -0x10(%ebp)
f0100e82:	68 0f 53 10 f0       	push   $0xf010530f
f0100e87:	e8 37 22 00 00       	call   f01030c3 <cprintf>
f0100e8c:	83 c4 10             	add    $0x10,%esp
	
	return 0;
f0100e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100e94:	c9                   	leave  
f0100e95:	c3                   	ret    

f0100e96 <command_writeusermem>:
int command_writeusermem(int number_of_arguments, char **arguments)
{
f0100e96:	55                   	push   %ebp
f0100e97:	89 e5                	mov    %esp,%ebp
f0100e99:	83 ec 18             	sub    $0x18,%esp
	unsigned int address = strtol(arguments[1], NULL, 16); 
f0100e9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e9f:	83 c0 04             	add    $0x4,%eax
f0100ea2:	8b 00                	mov    (%eax),%eax
f0100ea4:	83 ec 04             	sub    $0x4,%esp
f0100ea7:	6a 10                	push   $0x10
f0100ea9:	6a 00                	push   $0x0
f0100eab:	50                   	push   %eax
f0100eac:	e8 66 3a 00 00       	call   f0104917 <strtol>
f0100eb1:	83 c4 10             	add    $0x10,%esp
f0100eb4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	unsigned char *ptr = (unsigned char *)(address) ;
f0100eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100eba:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	*ptr = arguments[2][0];
f0100ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ec0:	83 c0 08             	add    $0x8,%eax
f0100ec3:	8b 00                	mov    (%eax),%eax
f0100ec5:	8a 00                	mov    (%eax),%al
f0100ec7:	88 c2                	mov    %al,%dl
f0100ec9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ecc:	88 10                	mov    %dl,(%eax)
		
	return 0;
f0100ece:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ed3:	c9                   	leave  
f0100ed4:	c3                   	ret    

f0100ed5 <command_meminfo>:

int command_meminfo(int number_of_arguments, char **arguments)
{
f0100ed5:	55                   	push   %ebp
f0100ed6:	89 e5                	mov    %esp,%ebp
f0100ed8:	83 ec 08             	sub    $0x8,%esp
	cprintf("Free frames = %d\n", calculate_free_frames());
f0100edb:	e8 28 19 00 00       	call   f0102808 <calculate_free_frames>
f0100ee0:	83 ec 08             	sub    $0x8,%esp
f0100ee3:	50                   	push   %eax
f0100ee4:	68 3a 53 10 f0       	push   $0xf010533a
f0100ee9:	e8 d5 21 00 00       	call   f01030c3 <cprintf>
f0100eee:	83 c4 10             	add    $0x10,%esp
	return 0;
f0100ef1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ef6:	c9                   	leave  
f0100ef7:	c3                   	ret    

f0100ef8 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0100ef8:	55                   	push   %ebp
f0100ef9:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0100efb:	8b 45 08             	mov    0x8(%ebp),%eax
f0100efe:	8b 15 3c e7 14 f0    	mov    0xf014e73c,%edx
f0100f04:	29 d0                	sub    %edx,%eax
f0100f06:	c1 f8 02             	sar    $0x2,%eax
f0100f09:	89 c2                	mov    %eax,%edx
f0100f0b:	89 d0                	mov    %edx,%eax
f0100f0d:	c1 e0 02             	shl    $0x2,%eax
f0100f10:	01 d0                	add    %edx,%eax
f0100f12:	c1 e0 02             	shl    $0x2,%eax
f0100f15:	01 d0                	add    %edx,%eax
f0100f17:	c1 e0 02             	shl    $0x2,%eax
f0100f1a:	01 d0                	add    %edx,%eax
f0100f1c:	89 c1                	mov    %eax,%ecx
f0100f1e:	c1 e1 08             	shl    $0x8,%ecx
f0100f21:	01 c8                	add    %ecx,%eax
f0100f23:	89 c1                	mov    %eax,%ecx
f0100f25:	c1 e1 10             	shl    $0x10,%ecx
f0100f28:	01 c8                	add    %ecx,%eax
f0100f2a:	01 c0                	add    %eax,%eax
f0100f2c:	01 d0                	add    %edx,%eax
}
f0100f2e:	5d                   	pop    %ebp
f0100f2f:	c3                   	ret    

f0100f30 <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0100f30:	55                   	push   %ebp
f0100f31:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0100f33:	ff 75 08             	pushl  0x8(%ebp)
f0100f36:	e8 bd ff ff ff       	call   f0100ef8 <to_frame_number>
f0100f3b:	83 c4 04             	add    $0x4,%esp
f0100f3e:	c1 e0 0c             	shl    $0xc,%eax
}
f0100f41:	c9                   	leave  
f0100f42:	c3                   	ret    

f0100f43 <nvram_read>:
{
	sizeof(gdt) - 1, (unsigned long) gdt
};

int nvram_read(int r)
{	
f0100f43:	55                   	push   %ebp
f0100f44:	89 e5                	mov    %esp,%ebp
f0100f46:	53                   	push   %ebx
f0100f47:	83 ec 04             	sub    $0x4,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100f4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f4d:	83 ec 0c             	sub    $0xc,%esp
f0100f50:	50                   	push   %eax
f0100f51:	e8 b8 20 00 00       	call   f010300e <mc146818_read>
f0100f56:	83 c4 10             	add    $0x10,%esp
f0100f59:	89 c3                	mov    %eax,%ebx
f0100f5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f5e:	40                   	inc    %eax
f0100f5f:	83 ec 0c             	sub    $0xc,%esp
f0100f62:	50                   	push   %eax
f0100f63:	e8 a6 20 00 00       	call   f010300e <mc146818_read>
f0100f68:	83 c4 10             	add    $0x10,%esp
f0100f6b:	c1 e0 08             	shl    $0x8,%eax
f0100f6e:	09 d8                	or     %ebx,%eax
}
f0100f70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f73:	c9                   	leave  
f0100f74:	c3                   	ret    

f0100f75 <detect_memory>:
	
void detect_memory()
{
f0100f75:	55                   	push   %ebp
f0100f76:	89 e5                	mov    %esp,%ebp
f0100f78:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	size_of_base_mem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PAGE_SIZE);
f0100f7b:	83 ec 0c             	sub    $0xc,%esp
f0100f7e:	6a 15                	push   $0x15
f0100f80:	e8 be ff ff ff       	call   f0100f43 <nvram_read>
f0100f85:	83 c4 10             	add    $0x10,%esp
f0100f88:	c1 e0 0a             	shl    $0xa,%eax
f0100f8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f96:	a3 34 e7 14 f0       	mov    %eax,0xf014e734
	size_of_extended_mem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PAGE_SIZE);
f0100f9b:	83 ec 0c             	sub    $0xc,%esp
f0100f9e:	6a 17                	push   $0x17
f0100fa0:	e8 9e ff ff ff       	call   f0100f43 <nvram_read>
f0100fa5:	83 c4 10             	add    $0x10,%esp
f0100fa8:	c1 e0 0a             	shl    $0xa,%eax
f0100fab:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100fb1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fb6:	a3 2c e7 14 f0       	mov    %eax,0xf014e72c

	// Calculate the maxmium physical address based on whether
	// or not there is any extended memory.  See comment in ../inc/mmu.h.
	if (size_of_extended_mem)
f0100fbb:	a1 2c e7 14 f0       	mov    0xf014e72c,%eax
f0100fc0:	85 c0                	test   %eax,%eax
f0100fc2:	74 11                	je     f0100fd5 <detect_memory+0x60>
		maxpa = PHYS_EXTENDED_MEM + size_of_extended_mem;
f0100fc4:	a1 2c e7 14 f0       	mov    0xf014e72c,%eax
f0100fc9:	05 00 00 10 00       	add    $0x100000,%eax
f0100fce:	a3 30 e7 14 f0       	mov    %eax,0xf014e730
f0100fd3:	eb 0a                	jmp    f0100fdf <detect_memory+0x6a>
	else
		maxpa = size_of_extended_mem;
f0100fd5:	a1 2c e7 14 f0       	mov    0xf014e72c,%eax
f0100fda:	a3 30 e7 14 f0       	mov    %eax,0xf014e730

	number_of_frames = maxpa / PAGE_SIZE;
f0100fdf:	a1 30 e7 14 f0       	mov    0xf014e730,%eax
f0100fe4:	c1 e8 0c             	shr    $0xc,%eax
f0100fe7:	a3 28 e7 14 f0       	mov    %eax,0xf014e728

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100fec:	a1 30 e7 14 f0       	mov    0xf014e730,%eax
f0100ff1:	c1 e8 0a             	shr    $0xa,%eax
f0100ff4:	83 ec 08             	sub    $0x8,%esp
f0100ff7:	50                   	push   %eax
f0100ff8:	68 4c 53 10 f0       	push   $0xf010534c
f0100ffd:	e8 c1 20 00 00       	call   f01030c3 <cprintf>
f0101002:	83 c4 10             	add    $0x10,%esp
	cprintf("base = %dK, extended = %dK\n", (int)(size_of_base_mem/1024), (int)(size_of_extended_mem/1024));
f0101005:	a1 2c e7 14 f0       	mov    0xf014e72c,%eax
f010100a:	c1 e8 0a             	shr    $0xa,%eax
f010100d:	89 c2                	mov    %eax,%edx
f010100f:	a1 34 e7 14 f0       	mov    0xf014e734,%eax
f0101014:	c1 e8 0a             	shr    $0xa,%eax
f0101017:	83 ec 04             	sub    $0x4,%esp
f010101a:	52                   	push   %edx
f010101b:	50                   	push   %eax
f010101c:	68 6d 53 10 f0       	push   $0xf010536d
f0101021:	e8 9d 20 00 00       	call   f01030c3 <cprintf>
f0101026:	83 c4 10             	add    $0x10,%esp
}
f0101029:	90                   	nop
f010102a:	c9                   	leave  
f010102b:	c3                   	ret    

f010102c <check_boot_pgdir>:
// but it is a pretty good check.
//
uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va);

void check_boot_pgdir()
{
f010102c:	55                   	push   %ebp
f010102d:	89 e5                	mov    %esp,%ebp
f010102f:	83 ec 28             	sub    $0x28,%esp
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
f0101032:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0101039:	8b 15 28 e7 14 f0    	mov    0xf014e728,%edx
f010103f:	89 d0                	mov    %edx,%eax
f0101041:	01 c0                	add    %eax,%eax
f0101043:	01 d0                	add    %edx,%eax
f0101045:	c1 e0 02             	shl    $0x2,%eax
f0101048:	89 c2                	mov    %eax,%edx
f010104a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010104d:	01 d0                	add    %edx,%eax
f010104f:	48                   	dec    %eax
f0101050:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101053:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101056:	ba 00 00 00 00       	mov    $0x0,%edx
f010105b:	f7 75 f0             	divl   -0x10(%ebp)
f010105e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101061:	29 d0                	sub    %edx,%eax
f0101063:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; i < n; i += PAGE_SIZE)
f0101066:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010106d:	eb 71                	jmp    f01010e0 <check_boot_pgdir+0xb4>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);
f010106f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101072:	8d 90 00 00 00 ef    	lea    -0x11000000(%eax),%edx
f0101078:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f010107d:	83 ec 08             	sub    $0x8,%esp
f0101080:	52                   	push   %edx
f0101081:	50                   	push   %eax
f0101082:	e8 f4 01 00 00       	call   f010127b <check_va2pa>
f0101087:	83 c4 10             	add    $0x10,%esp
f010108a:	89 c2                	mov    %eax,%edx
f010108c:	a1 3c e7 14 f0       	mov    0xf014e73c,%eax
f0101091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101094:	81 7d e4 ff ff ff ef 	cmpl   $0xefffffff,-0x1c(%ebp)
f010109b:	77 14                	ja     f01010b1 <check_boot_pgdir+0x85>
f010109d:	ff 75 e4             	pushl  -0x1c(%ebp)
f01010a0:	68 8c 53 10 f0       	push   $0xf010538c
f01010a5:	6a 5e                	push   $0x5e
f01010a7:	68 bd 53 10 f0       	push   $0xf01053bd
f01010ac:	e8 7d f0 ff ff       	call   f010012e <_panic>
f01010b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010b4:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f01010ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010bd:	01 c8                	add    %ecx,%eax
f01010bf:	39 c2                	cmp    %eax,%edx
f01010c1:	74 16                	je     f01010d9 <check_boot_pgdir+0xad>
f01010c3:	68 cc 53 10 f0       	push   $0xf01053cc
f01010c8:	68 2e 54 10 f0       	push   $0xf010542e
f01010cd:	6a 5e                	push   $0x5e
f01010cf:	68 bd 53 10 f0       	push   $0xf01053bd
f01010d4:	e8 55 f0 ff ff       	call   f010012e <_panic>
{
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
f01010d9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01010e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010e3:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f01010e6:	72 87                	jb     f010106f <check_boot_pgdir+0x43>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f01010e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01010ef:	eb 3d                	jmp    f010112e <check_boot_pgdir+0x102>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);
f01010f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010f4:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f01010fa:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01010ff:	83 ec 08             	sub    $0x8,%esp
f0101102:	52                   	push   %edx
f0101103:	50                   	push   %eax
f0101104:	e8 72 01 00 00       	call   f010127b <check_va2pa>
f0101109:	83 c4 10             	add    $0x10,%esp
f010110c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f010110f:	74 16                	je     f0101127 <check_boot_pgdir+0xfb>
f0101111:	68 44 54 10 f0       	push   $0xf0105444
f0101116:	68 2e 54 10 f0       	push   $0xf010542e
f010111b:	6a 62                	push   $0x62
f010111d:	68 bd 53 10 f0       	push   $0xf01053bd
f0101122:	e8 07 f0 ff ff       	call   f010012e <_panic>
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0101127:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f010112e:	81 7d f4 00 00 00 10 	cmpl   $0x10000000,-0xc(%ebp)
f0101135:	75 ba                	jne    f01010f1 <check_boot_pgdir+0xc5>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0101137:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010113e:	eb 6e                	jmp    f01011ae <check_boot_pgdir+0x182>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);
f0101140:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101143:	8d 90 00 80 bf ef    	lea    -0x10408000(%eax),%edx
f0101149:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f010114e:	83 ec 08             	sub    $0x8,%esp
f0101151:	52                   	push   %edx
f0101152:	50                   	push   %eax
f0101153:	e8 23 01 00 00       	call   f010127b <check_va2pa>
f0101158:	83 c4 10             	add    $0x10,%esp
f010115b:	c7 45 e0 00 30 11 f0 	movl   $0xf0113000,-0x20(%ebp)
f0101162:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0101169:	77 14                	ja     f010117f <check_boot_pgdir+0x153>
f010116b:	ff 75 e0             	pushl  -0x20(%ebp)
f010116e:	68 8c 53 10 f0       	push   $0xf010538c
f0101173:	6a 66                	push   $0x66
f0101175:	68 bd 53 10 f0       	push   $0xf01053bd
f010117a:	e8 af ef ff ff       	call   f010012e <_panic>
f010117f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101182:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
f0101188:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010118b:	01 ca                	add    %ecx,%edx
f010118d:	39 d0                	cmp    %edx,%eax
f010118f:	74 16                	je     f01011a7 <check_boot_pgdir+0x17b>
f0101191:	68 7c 54 10 f0       	push   $0xf010547c
f0101196:	68 2e 54 10 f0       	push   $0xf010542e
f010119b:	6a 66                	push   $0x66
f010119d:	68 bd 53 10 f0       	push   $0xf01053bd
f01011a2:	e8 87 ef ff ff       	call   f010012e <_panic>
	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f01011a7:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01011ae:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f01011b5:	76 89                	jbe    f0101140 <check_boot_pgdir+0x114>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f01011b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f01011be:	e9 98 00 00 00       	jmp    f010125b <check_boot_pgdir+0x22f>
		switch (i) {
f01011c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c6:	2d bb 03 00 00       	sub    $0x3bb,%eax
f01011cb:	83 f8 04             	cmp    $0x4,%eax
f01011ce:	77 29                	ja     f01011f9 <check_boot_pgdir+0x1cd>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
f01011d0:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01011d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01011d8:	c1 e2 02             	shl    $0x2,%edx
f01011db:	01 d0                	add    %edx,%eax
f01011dd:	8b 00                	mov    (%eax),%eax
f01011df:	85 c0                	test   %eax,%eax
f01011e1:	75 71                	jne    f0101254 <check_boot_pgdir+0x228>
f01011e3:	68 f2 54 10 f0       	push   $0xf01054f2
f01011e8:	68 2e 54 10 f0       	push   $0xf010542e
f01011ed:	6a 70                	push   $0x70
f01011ef:	68 bd 53 10 f0       	push   $0xf01053bd
f01011f4:	e8 35 ef ff ff       	call   f010012e <_panic>
			break;
		default:
			if (i >= PDX(KERNEL_BASE))
f01011f9:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f0101200:	76 29                	jbe    f010122b <check_boot_pgdir+0x1ff>
				assert(ptr_page_directory[i]);
f0101202:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101207:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010120a:	c1 e2 02             	shl    $0x2,%edx
f010120d:	01 d0                	add    %edx,%eax
f010120f:	8b 00                	mov    (%eax),%eax
f0101211:	85 c0                	test   %eax,%eax
f0101213:	75 42                	jne    f0101257 <check_boot_pgdir+0x22b>
f0101215:	68 f2 54 10 f0       	push   $0xf01054f2
f010121a:	68 2e 54 10 f0       	push   $0xf010542e
f010121f:	6a 74                	push   $0x74
f0101221:	68 bd 53 10 f0       	push   $0xf01053bd
f0101226:	e8 03 ef ff ff       	call   f010012e <_panic>
			else				
				assert(ptr_page_directory[i] == 0);
f010122b:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101230:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101233:	c1 e2 02             	shl    $0x2,%edx
f0101236:	01 d0                	add    %edx,%eax
f0101238:	8b 00                	mov    (%eax),%eax
f010123a:	85 c0                	test   %eax,%eax
f010123c:	74 19                	je     f0101257 <check_boot_pgdir+0x22b>
f010123e:	68 08 55 10 f0       	push   $0xf0105508
f0101243:	68 2e 54 10 f0       	push   $0xf010542e
f0101248:	6a 76                	push   $0x76
f010124a:	68 bd 53 10 f0       	push   $0xf01053bd
f010124f:	e8 da ee ff ff       	call   f010012e <_panic>
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
			break;
f0101254:	90                   	nop
f0101255:	eb 01                	jmp    f0101258 <check_boot_pgdir+0x22c>
		default:
			if (i >= PDX(KERNEL_BASE))
				assert(ptr_page_directory[i]);
			else				
				assert(ptr_page_directory[i] == 0);
			break;
f0101257:	90                   	nop
	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0101258:	ff 45 f4             	incl   -0xc(%ebp)
f010125b:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0101262:	0f 86 5b ff ff ff    	jbe    f01011c3 <check_boot_pgdir+0x197>
			else				
				assert(ptr_page_directory[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0101268:	83 ec 0c             	sub    $0xc,%esp
f010126b:	68 24 55 10 f0       	push   $0xf0105524
f0101270:	e8 4e 1e 00 00       	call   f01030c3 <cprintf>
f0101275:	83 c4 10             	add    $0x10,%esp
}
f0101278:	90                   	nop
f0101279:	c9                   	leave  
f010127a:	c3                   	ret    

f010127b <check_va2pa>:
// defined by the page directory 'ptr_page_directory'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va)
{
f010127b:	55                   	push   %ebp
f010127c:	89 e5                	mov    %esp,%ebp
f010127e:	83 ec 18             	sub    $0x18,%esp
	uint32 *p;

	ptr_page_directory = &ptr_page_directory[PDX(va)];
f0101281:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101284:	c1 e8 16             	shr    $0x16,%eax
f0101287:	c1 e0 02             	shl    $0x2,%eax
f010128a:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*ptr_page_directory & PERM_PRESENT))
f010128d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101290:	8b 00                	mov    (%eax),%eax
f0101292:	83 e0 01             	and    $0x1,%eax
f0101295:	85 c0                	test   %eax,%eax
f0101297:	75 0a                	jne    f01012a3 <check_va2pa+0x28>
		return ~0;
f0101299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010129e:	e9 87 00 00 00       	jmp    f010132a <check_va2pa+0xaf>
	p = (uint32*) K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(*ptr_page_directory));
f01012a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01012a6:	8b 00                	mov    (%eax),%eax
f01012a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01012ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01012b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012b3:	c1 e8 0c             	shr    $0xc,%eax
f01012b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01012b9:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f01012be:	39 45 f0             	cmp    %eax,-0x10(%ebp)
f01012c1:	72 17                	jb     f01012da <check_va2pa+0x5f>
f01012c3:	ff 75 f4             	pushl  -0xc(%ebp)
f01012c6:	68 44 55 10 f0       	push   $0xf0105544
f01012cb:	68 89 00 00 00       	push   $0x89
f01012d0:	68 bd 53 10 f0       	push   $0xf01053bd
f01012d5:	e8 54 ee ff ff       	call   f010012e <_panic>
f01012da:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01012dd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (!(p[PTX(va)] & PERM_PRESENT))
f01012e5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01012e8:	c1 e8 0c             	shr    $0xc,%eax
f01012eb:	25 ff 03 00 00       	and    $0x3ff,%eax
f01012f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01012f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01012fa:	01 d0                	add    %edx,%eax
f01012fc:	8b 00                	mov    (%eax),%eax
f01012fe:	83 e0 01             	and    $0x1,%eax
f0101301:	85 c0                	test   %eax,%eax
f0101303:	75 07                	jne    f010130c <check_va2pa+0x91>
		return ~0;
f0101305:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010130a:	eb 1e                	jmp    f010132a <check_va2pa+0xaf>
	return EXTRACT_ADDRESS(p[PTX(va)]);
f010130c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010130f:	c1 e8 0c             	shr    $0xc,%eax
f0101312:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101317:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010131e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101321:	01 d0                	add    %edx,%eax
f0101323:	8b 00                	mov    (%eax),%eax
f0101325:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f010132a:	c9                   	leave  
f010132b:	c3                   	ret    

f010132c <tlb_invalidate>:
		
void tlb_invalidate(uint32 *ptr_page_directory, void *virtual_address)
{
f010132c:	55                   	push   %ebp
f010132d:	89 e5                	mov    %esp,%ebp
f010132f:	83 ec 10             	sub    $0x10,%esp
f0101332:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101335:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101338:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010133b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(virtual_address);
}
f010133e:	90                   	nop
f010133f:	c9                   	leave  
f0101340:	c3                   	ret    

f0101341 <page_check>:

void page_check()
{
f0101341:	55                   	push   %ebp
f0101342:	89 e5                	mov    %esp,%ebp
f0101344:	53                   	push   %ebx
f0101345:	83 ec 24             	sub    $0x24,%esp
	struct Frame_Info *pp, *pp0, *pp1, *pp2;
	struct Linked_List fl;

	// should be able to allocate three frames_info
	pp0 = pp1 = pp2 = 0;
f0101348:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f010134f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101352:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101355:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101358:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(allocate_frame(&pp0) == 0);
f010135b:	83 ec 0c             	sub    $0xc,%esp
f010135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0101361:	50                   	push   %eax
f0101362:	e8 e7 10 00 00       	call   f010244e <allocate_frame>
f0101367:	83 c4 10             	add    $0x10,%esp
f010136a:	85 c0                	test   %eax,%eax
f010136c:	74 19                	je     f0101387 <page_check+0x46>
f010136e:	68 73 55 10 f0       	push   $0xf0105573
f0101373:	68 2e 54 10 f0       	push   $0xf010542e
f0101378:	68 9d 00 00 00       	push   $0x9d
f010137d:	68 bd 53 10 f0       	push   $0xf01053bd
f0101382:	e8 a7 ed ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp1) == 0);
f0101387:	83 ec 0c             	sub    $0xc,%esp
f010138a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010138d:	50                   	push   %eax
f010138e:	e8 bb 10 00 00       	call   f010244e <allocate_frame>
f0101393:	83 c4 10             	add    $0x10,%esp
f0101396:	85 c0                	test   %eax,%eax
f0101398:	74 19                	je     f01013b3 <page_check+0x72>
f010139a:	68 8d 55 10 f0       	push   $0xf010558d
f010139f:	68 2e 54 10 f0       	push   $0xf010542e
f01013a4:	68 9e 00 00 00       	push   $0x9e
f01013a9:	68 bd 53 10 f0       	push   $0xf01053bd
f01013ae:	e8 7b ed ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp2) == 0);
f01013b3:	83 ec 0c             	sub    $0xc,%esp
f01013b6:	8d 45 e8             	lea    -0x18(%ebp),%eax
f01013b9:	50                   	push   %eax
f01013ba:	e8 8f 10 00 00       	call   f010244e <allocate_frame>
f01013bf:	83 c4 10             	add    $0x10,%esp
f01013c2:	85 c0                	test   %eax,%eax
f01013c4:	74 19                	je     f01013df <page_check+0x9e>
f01013c6:	68 a7 55 10 f0       	push   $0xf01055a7
f01013cb:	68 2e 54 10 f0       	push   $0xf010542e
f01013d0:	68 9f 00 00 00       	push   $0x9f
f01013d5:	68 bd 53 10 f0       	push   $0xf01053bd
f01013da:	e8 4f ed ff ff       	call   f010012e <_panic>

	assert(pp0);
f01013df:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01013e2:	85 c0                	test   %eax,%eax
f01013e4:	75 19                	jne    f01013ff <page_check+0xbe>
f01013e6:	68 c1 55 10 f0       	push   $0xf01055c1
f01013eb:	68 2e 54 10 f0       	push   $0xf010542e
f01013f0:	68 a1 00 00 00       	push   $0xa1
f01013f5:	68 bd 53 10 f0       	push   $0xf01053bd
f01013fa:	e8 2f ed ff ff       	call   f010012e <_panic>
	assert(pp1 && pp1 != pp0);
f01013ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101402:	85 c0                	test   %eax,%eax
f0101404:	74 0a                	je     f0101410 <page_check+0xcf>
f0101406:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101409:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010140c:	39 c2                	cmp    %eax,%edx
f010140e:	75 19                	jne    f0101429 <page_check+0xe8>
f0101410:	68 c5 55 10 f0       	push   $0xf01055c5
f0101415:	68 2e 54 10 f0       	push   $0xf010542e
f010141a:	68 a2 00 00 00       	push   $0xa2
f010141f:	68 bd 53 10 f0       	push   $0xf01053bd
f0101424:	e8 05 ed ff ff       	call   f010012e <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101429:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010142c:	85 c0                	test   %eax,%eax
f010142e:	74 14                	je     f0101444 <page_check+0x103>
f0101430:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101433:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101436:	39 c2                	cmp    %eax,%edx
f0101438:	74 0a                	je     f0101444 <page_check+0x103>
f010143a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010143d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101440:	39 c2                	cmp    %eax,%edx
f0101442:	75 19                	jne    f010145d <page_check+0x11c>
f0101444:	68 d8 55 10 f0       	push   $0xf01055d8
f0101449:	68 2e 54 10 f0       	push   $0xf010542e
f010144e:	68 a3 00 00 00       	push   $0xa3
f0101453:	68 bd 53 10 f0       	push   $0xf01053bd
f0101458:	e8 d1 ec ff ff       	call   f010012e <_panic>

	// temporarily steal the rest of the free frames_info
	fl = free_frame_list;
f010145d:	a1 38 e7 14 f0       	mov    0xf014e738,%eax
f0101462:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	LIST_INIT(&free_frame_list);
f0101465:	c7 05 38 e7 14 f0 00 	movl   $0x0,0xf014e738
f010146c:	00 00 00 

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f010146f:	83 ec 0c             	sub    $0xc,%esp
f0101472:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101475:	50                   	push   %eax
f0101476:	e8 d3 0f 00 00       	call   f010244e <allocate_frame>
f010147b:	83 c4 10             	add    $0x10,%esp
f010147e:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101481:	74 19                	je     f010149c <page_check+0x15b>
f0101483:	68 f8 55 10 f0       	push   $0xf01055f8
f0101488:	68 2e 54 10 f0       	push   $0xf010542e
f010148d:	68 aa 00 00 00       	push   $0xaa
f0101492:	68 bd 53 10 f0       	push   $0xf01053bd
f0101497:	e8 92 ec ff ff       	call   f010012e <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) < 0);
f010149c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010149f:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01014a4:	6a 00                	push   $0x0
f01014a6:	6a 00                	push   $0x0
f01014a8:	52                   	push   %edx
f01014a9:	50                   	push   %eax
f01014aa:	e8 ac 11 00 00       	call   f010265b <map_frame>
f01014af:	83 c4 10             	add    $0x10,%esp
f01014b2:	85 c0                	test   %eax,%eax
f01014b4:	78 19                	js     f01014cf <page_check+0x18e>
f01014b6:	68 18 56 10 f0       	push   $0xf0105618
f01014bb:	68 2e 54 10 f0       	push   $0xf010542e
f01014c0:	68 ad 00 00 00       	push   $0xad
f01014c5:	68 bd 53 10 f0       	push   $0xf01053bd
f01014ca:	e8 5f ec ff ff       	call   f010012e <_panic>

	// free pp0 and try again: pp0 should be used for page table
	free_frame(pp0);
f01014cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01014d2:	83 ec 0c             	sub    $0xc,%esp
f01014d5:	50                   	push   %eax
f01014d6:	e8 da 0f 00 00       	call   f01024b5 <free_frame>
f01014db:	83 c4 10             	add    $0x10,%esp
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) == 0);
f01014de:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01014e1:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01014e6:	6a 00                	push   $0x0
f01014e8:	6a 00                	push   $0x0
f01014ea:	52                   	push   %edx
f01014eb:	50                   	push   %eax
f01014ec:	e8 6a 11 00 00       	call   f010265b <map_frame>
f01014f1:	83 c4 10             	add    $0x10,%esp
f01014f4:	85 c0                	test   %eax,%eax
f01014f6:	74 19                	je     f0101511 <page_check+0x1d0>
f01014f8:	68 48 56 10 f0       	push   $0xf0105648
f01014fd:	68 2e 54 10 f0       	push   $0xf010542e
f0101502:	68 b1 00 00 00       	push   $0xb1
f0101507:	68 bd 53 10 f0       	push   $0xf01053bd
f010150c:	e8 1d ec ff ff       	call   f010012e <_panic>
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101511:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101516:	8b 00                	mov    (%eax),%eax
f0101518:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010151d:	89 c3                	mov    %eax,%ebx
f010151f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101522:	83 ec 0c             	sub    $0xc,%esp
f0101525:	50                   	push   %eax
f0101526:	e8 05 fa ff ff       	call   f0100f30 <to_physical_address>
f010152b:	83 c4 10             	add    $0x10,%esp
f010152e:	39 c3                	cmp    %eax,%ebx
f0101530:	74 19                	je     f010154b <page_check+0x20a>
f0101532:	68 78 56 10 f0       	push   $0xf0105678
f0101537:	68 2e 54 10 f0       	push   $0xf010542e
f010153c:	68 b2 00 00 00       	push   $0xb2
f0101541:	68 bd 53 10 f0       	push   $0xf01053bd
f0101546:	e8 e3 eb ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, 0x0) == to_physical_address(pp1));
f010154b:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101550:	83 ec 08             	sub    $0x8,%esp
f0101553:	6a 00                	push   $0x0
f0101555:	50                   	push   %eax
f0101556:	e8 20 fd ff ff       	call   f010127b <check_va2pa>
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	89 c3                	mov    %eax,%ebx
f0101560:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101563:	83 ec 0c             	sub    $0xc,%esp
f0101566:	50                   	push   %eax
f0101567:	e8 c4 f9 ff ff       	call   f0100f30 <to_physical_address>
f010156c:	83 c4 10             	add    $0x10,%esp
f010156f:	39 c3                	cmp    %eax,%ebx
f0101571:	74 19                	je     f010158c <page_check+0x24b>
f0101573:	68 bc 56 10 f0       	push   $0xf01056bc
f0101578:	68 2e 54 10 f0       	push   $0xf010542e
f010157d:	68 b3 00 00 00       	push   $0xb3
f0101582:	68 bd 53 10 f0       	push   $0xf01053bd
f0101587:	e8 a2 eb ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f010158c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010158f:	8b 40 08             	mov    0x8(%eax),%eax
f0101592:	66 83 f8 01          	cmp    $0x1,%ax
f0101596:	74 19                	je     f01015b1 <page_check+0x270>
f0101598:	68 fd 56 10 f0       	push   $0xf01056fd
f010159d:	68 2e 54 10 f0       	push   $0xf010542e
f01015a2:	68 b4 00 00 00       	push   $0xb4
f01015a7:	68 bd 53 10 f0       	push   $0xf01053bd
f01015ac:	e8 7d eb ff ff       	call   f010012e <_panic>
	assert(pp0->references == 1);
f01015b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01015b4:	8b 40 08             	mov    0x8(%eax),%eax
f01015b7:	66 83 f8 01          	cmp    $0x1,%ax
f01015bb:	74 19                	je     f01015d6 <page_check+0x295>
f01015bd:	68 12 57 10 f0       	push   $0xf0105712
f01015c2:	68 2e 54 10 f0       	push   $0xf010542e
f01015c7:	68 b5 00 00 00       	push   $0xb5
f01015cc:	68 bd 53 10 f0       	push   $0xf01053bd
f01015d1:	e8 58 eb ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because pp0 is already allocated for page table
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f01015d6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01015d9:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01015de:	6a 00                	push   $0x0
f01015e0:	68 00 10 00 00       	push   $0x1000
f01015e5:	52                   	push   %edx
f01015e6:	50                   	push   %eax
f01015e7:	e8 6f 10 00 00       	call   f010265b <map_frame>
f01015ec:	83 c4 10             	add    $0x10,%esp
f01015ef:	85 c0                	test   %eax,%eax
f01015f1:	74 19                	je     f010160c <page_check+0x2cb>
f01015f3:	68 28 57 10 f0       	push   $0xf0105728
f01015f8:	68 2e 54 10 f0       	push   $0xf010542e
f01015fd:	68 b8 00 00 00       	push   $0xb8
f0101602:	68 bd 53 10 f0       	push   $0xf01053bd
f0101607:	e8 22 eb ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f010160c:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101611:	83 ec 08             	sub    $0x8,%esp
f0101614:	68 00 10 00 00       	push   $0x1000
f0101619:	50                   	push   %eax
f010161a:	e8 5c fc ff ff       	call   f010127b <check_va2pa>
f010161f:	83 c4 10             	add    $0x10,%esp
f0101622:	89 c3                	mov    %eax,%ebx
f0101624:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101627:	83 ec 0c             	sub    $0xc,%esp
f010162a:	50                   	push   %eax
f010162b:	e8 00 f9 ff ff       	call   f0100f30 <to_physical_address>
f0101630:	83 c4 10             	add    $0x10,%esp
f0101633:	39 c3                	cmp    %eax,%ebx
f0101635:	74 19                	je     f0101650 <page_check+0x30f>
f0101637:	68 68 57 10 f0       	push   $0xf0105768
f010163c:	68 2e 54 10 f0       	push   $0xf010542e
f0101641:	68 b9 00 00 00       	push   $0xb9
f0101646:	68 bd 53 10 f0       	push   $0xf01053bd
f010164b:	e8 de ea ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f0101650:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101653:	8b 40 08             	mov    0x8(%eax),%eax
f0101656:	66 83 f8 01          	cmp    $0x1,%ax
f010165a:	74 19                	je     f0101675 <page_check+0x334>
f010165c:	68 af 57 10 f0       	push   $0xf01057af
f0101661:	68 2e 54 10 f0       	push   $0xf010542e
f0101666:	68 ba 00 00 00       	push   $0xba
f010166b:	68 bd 53 10 f0       	push   $0xf01053bd
f0101670:	e8 b9 ea ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101675:	83 ec 0c             	sub    $0xc,%esp
f0101678:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010167b:	50                   	push   %eax
f010167c:	e8 cd 0d 00 00       	call   f010244e <allocate_frame>
f0101681:	83 c4 10             	add    $0x10,%esp
f0101684:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101687:	74 19                	je     f01016a2 <page_check+0x361>
f0101689:	68 f8 55 10 f0       	push   $0xf01055f8
f010168e:	68 2e 54 10 f0       	push   $0xf010542e
f0101693:	68 bd 00 00 00       	push   $0xbd
f0101698:	68 bd 53 10 f0       	push   $0xf01053bd
f010169d:	e8 8c ea ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because it's already there
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f01016a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01016a5:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01016aa:	6a 00                	push   $0x0
f01016ac:	68 00 10 00 00       	push   $0x1000
f01016b1:	52                   	push   %edx
f01016b2:	50                   	push   %eax
f01016b3:	e8 a3 0f 00 00       	call   f010265b <map_frame>
f01016b8:	83 c4 10             	add    $0x10,%esp
f01016bb:	85 c0                	test   %eax,%eax
f01016bd:	74 19                	je     f01016d8 <page_check+0x397>
f01016bf:	68 28 57 10 f0       	push   $0xf0105728
f01016c4:	68 2e 54 10 f0       	push   $0xf010542e
f01016c9:	68 c0 00 00 00       	push   $0xc0
f01016ce:	68 bd 53 10 f0       	push   $0xf01053bd
f01016d3:	e8 56 ea ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f01016d8:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01016dd:	83 ec 08             	sub    $0x8,%esp
f01016e0:	68 00 10 00 00       	push   $0x1000
f01016e5:	50                   	push   %eax
f01016e6:	e8 90 fb ff ff       	call   f010127b <check_va2pa>
f01016eb:	83 c4 10             	add    $0x10,%esp
f01016ee:	89 c3                	mov    %eax,%ebx
f01016f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01016f3:	83 ec 0c             	sub    $0xc,%esp
f01016f6:	50                   	push   %eax
f01016f7:	e8 34 f8 ff ff       	call   f0100f30 <to_physical_address>
f01016fc:	83 c4 10             	add    $0x10,%esp
f01016ff:	39 c3                	cmp    %eax,%ebx
f0101701:	74 19                	je     f010171c <page_check+0x3db>
f0101703:	68 68 57 10 f0       	push   $0xf0105768
f0101708:	68 2e 54 10 f0       	push   $0xf010542e
f010170d:	68 c1 00 00 00       	push   $0xc1
f0101712:	68 bd 53 10 f0       	push   $0xf01053bd
f0101717:	e8 12 ea ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f010171c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010171f:	8b 40 08             	mov    0x8(%eax),%eax
f0101722:	66 83 f8 01          	cmp    $0x1,%ax
f0101726:	74 19                	je     f0101741 <page_check+0x400>
f0101728:	68 af 57 10 f0       	push   $0xf01057af
f010172d:	68 2e 54 10 f0       	push   $0xf010542e
f0101732:	68 c2 00 00 00       	push   $0xc2
f0101737:	68 bd 53 10 f0       	push   $0xf01053bd
f010173c:	e8 ed e9 ff ff       	call   f010012e <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in map_frame
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101741:	83 ec 0c             	sub    $0xc,%esp
f0101744:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101747:	50                   	push   %eax
f0101748:	e8 01 0d 00 00       	call   f010244e <allocate_frame>
f010174d:	83 c4 10             	add    $0x10,%esp
f0101750:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101753:	74 19                	je     f010176e <page_check+0x42d>
f0101755:	68 f8 55 10 f0       	push   $0xf01055f8
f010175a:	68 2e 54 10 f0       	push   $0xf010542e
f010175f:	68 c6 00 00 00       	push   $0xc6
f0101764:	68 bd 53 10 f0       	push   $0xf01053bd
f0101769:	e8 c0 e9 ff ff       	call   f010012e <_panic>

	// should not be able to map at PTSIZE because need free frame for page table
	assert(map_frame(ptr_page_directory, pp0, (void*) PTSIZE, 0) < 0);
f010176e:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101771:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101776:	6a 00                	push   $0x0
f0101778:	68 00 00 40 00       	push   $0x400000
f010177d:	52                   	push   %edx
f010177e:	50                   	push   %eax
f010177f:	e8 d7 0e 00 00       	call   f010265b <map_frame>
f0101784:	83 c4 10             	add    $0x10,%esp
f0101787:	85 c0                	test   %eax,%eax
f0101789:	78 19                	js     f01017a4 <page_check+0x463>
f010178b:	68 c4 57 10 f0       	push   $0xf01057c4
f0101790:	68 2e 54 10 f0       	push   $0xf010542e
f0101795:	68 c9 00 00 00       	push   $0xc9
f010179a:	68 bd 53 10 f0       	push   $0xf01053bd
f010179f:	e8 8a e9 ff ff       	call   f010012e <_panic>

	// insert pp1 at PAGE_SIZE (replacing pp2)
	assert(map_frame(ptr_page_directory, pp1, (void*) PAGE_SIZE, 0) == 0);
f01017a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01017a7:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01017ac:	6a 00                	push   $0x0
f01017ae:	68 00 10 00 00       	push   $0x1000
f01017b3:	52                   	push   %edx
f01017b4:	50                   	push   %eax
f01017b5:	e8 a1 0e 00 00       	call   f010265b <map_frame>
f01017ba:	83 c4 10             	add    $0x10,%esp
f01017bd:	85 c0                	test   %eax,%eax
f01017bf:	74 19                	je     f01017da <page_check+0x499>
f01017c1:	68 00 58 10 f0       	push   $0xf0105800
f01017c6:	68 2e 54 10 f0       	push   $0xf010542e
f01017cb:	68 cc 00 00 00       	push   $0xcc
f01017d0:	68 bd 53 10 f0       	push   $0xf01053bd
f01017d5:	e8 54 e9 ff ff       	call   f010012e <_panic>

	// should have pp1 at both 0 and PAGE_SIZE, pp2 nowhere, ...
	assert(check_va2pa(ptr_page_directory, 0) == to_physical_address(pp1));
f01017da:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01017df:	83 ec 08             	sub    $0x8,%esp
f01017e2:	6a 00                	push   $0x0
f01017e4:	50                   	push   %eax
f01017e5:	e8 91 fa ff ff       	call   f010127b <check_va2pa>
f01017ea:	83 c4 10             	add    $0x10,%esp
f01017ed:	89 c3                	mov    %eax,%ebx
f01017ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017f2:	83 ec 0c             	sub    $0xc,%esp
f01017f5:	50                   	push   %eax
f01017f6:	e8 35 f7 ff ff       	call   f0100f30 <to_physical_address>
f01017fb:	83 c4 10             	add    $0x10,%esp
f01017fe:	39 c3                	cmp    %eax,%ebx
f0101800:	74 19                	je     f010181b <page_check+0x4da>
f0101802:	68 40 58 10 f0       	push   $0xf0105840
f0101807:	68 2e 54 10 f0       	push   $0xf010542e
f010180c:	68 cf 00 00 00       	push   $0xcf
f0101811:	68 bd 53 10 f0       	push   $0xf01053bd
f0101816:	e8 13 e9 ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f010181b:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101820:	83 ec 08             	sub    $0x8,%esp
f0101823:	68 00 10 00 00       	push   $0x1000
f0101828:	50                   	push   %eax
f0101829:	e8 4d fa ff ff       	call   f010127b <check_va2pa>
f010182e:	83 c4 10             	add    $0x10,%esp
f0101831:	89 c3                	mov    %eax,%ebx
f0101833:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101836:	83 ec 0c             	sub    $0xc,%esp
f0101839:	50                   	push   %eax
f010183a:	e8 f1 f6 ff ff       	call   f0100f30 <to_physical_address>
f010183f:	83 c4 10             	add    $0x10,%esp
f0101842:	39 c3                	cmp    %eax,%ebx
f0101844:	74 19                	je     f010185f <page_check+0x51e>
f0101846:	68 80 58 10 f0       	push   $0xf0105880
f010184b:	68 2e 54 10 f0       	push   $0xf010542e
f0101850:	68 d0 00 00 00       	push   $0xd0
f0101855:	68 bd 53 10 f0       	push   $0xf01053bd
f010185a:	e8 cf e8 ff ff       	call   f010012e <_panic>
	// ... and ref counts should reflect this
	assert(pp1->references == 2);
f010185f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101862:	8b 40 08             	mov    0x8(%eax),%eax
f0101865:	66 83 f8 02          	cmp    $0x2,%ax
f0101869:	74 19                	je     f0101884 <page_check+0x543>
f010186b:	68 c7 58 10 f0       	push   $0xf01058c7
f0101870:	68 2e 54 10 f0       	push   $0xf010542e
f0101875:	68 d2 00 00 00       	push   $0xd2
f010187a:	68 bd 53 10 f0       	push   $0xf01053bd
f010187f:	e8 aa e8 ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f0101884:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101887:	8b 40 08             	mov    0x8(%eax),%eax
f010188a:	66 85 c0             	test   %ax,%ax
f010188d:	74 19                	je     f01018a8 <page_check+0x567>
f010188f:	68 dc 58 10 f0       	push   $0xf01058dc
f0101894:	68 2e 54 10 f0       	push   $0xf010542e
f0101899:	68 d3 00 00 00       	push   $0xd3
f010189e:	68 bd 53 10 f0       	push   $0xf01053bd
f01018a3:	e8 86 e8 ff ff       	call   f010012e <_panic>

	// pp2 should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp2);
f01018a8:	83 ec 0c             	sub    $0xc,%esp
f01018ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01018ae:	50                   	push   %eax
f01018af:	e8 9a 0b 00 00       	call   f010244e <allocate_frame>
f01018b4:	83 c4 10             	add    $0x10,%esp
f01018b7:	85 c0                	test   %eax,%eax
f01018b9:	75 0a                	jne    f01018c5 <page_check+0x584>
f01018bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01018be:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01018c1:	39 c2                	cmp    %eax,%edx
f01018c3:	74 19                	je     f01018de <page_check+0x59d>
f01018c5:	68 f4 58 10 f0       	push   $0xf01058f4
f01018ca:	68 2e 54 10 f0       	push   $0xf010542e
f01018cf:	68 d6 00 00 00       	push   $0xd6
f01018d4:	68 bd 53 10 f0       	push   $0xf01053bd
f01018d9:	e8 50 e8 ff ff       	call   f010012e <_panic>

	// unmapping pp1 at 0 should keep pp1 at PAGE_SIZE
	unmap_frame(ptr_page_directory, 0x0);
f01018de:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01018e3:	83 ec 08             	sub    $0x8,%esp
f01018e6:	6a 00                	push   $0x0
f01018e8:	50                   	push   %eax
f01018e9:	e8 80 0e 00 00       	call   f010276e <unmap_frame>
f01018ee:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f01018f1:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01018f6:	83 ec 08             	sub    $0x8,%esp
f01018f9:	6a 00                	push   $0x0
f01018fb:	50                   	push   %eax
f01018fc:	e8 7a f9 ff ff       	call   f010127b <check_va2pa>
f0101901:	83 c4 10             	add    $0x10,%esp
f0101904:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101907:	74 19                	je     f0101922 <page_check+0x5e1>
f0101909:	68 1c 59 10 f0       	push   $0xf010591c
f010190e:	68 2e 54 10 f0       	push   $0xf010542e
f0101913:	68 da 00 00 00       	push   $0xda
f0101918:	68 bd 53 10 f0       	push   $0xf01053bd
f010191d:	e8 0c e8 ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101922:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101927:	83 ec 08             	sub    $0x8,%esp
f010192a:	68 00 10 00 00       	push   $0x1000
f010192f:	50                   	push   %eax
f0101930:	e8 46 f9 ff ff       	call   f010127b <check_va2pa>
f0101935:	83 c4 10             	add    $0x10,%esp
f0101938:	89 c3                	mov    %eax,%ebx
f010193a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010193d:	83 ec 0c             	sub    $0xc,%esp
f0101940:	50                   	push   %eax
f0101941:	e8 ea f5 ff ff       	call   f0100f30 <to_physical_address>
f0101946:	83 c4 10             	add    $0x10,%esp
f0101949:	39 c3                	cmp    %eax,%ebx
f010194b:	74 19                	je     f0101966 <page_check+0x625>
f010194d:	68 80 58 10 f0       	push   $0xf0105880
f0101952:	68 2e 54 10 f0       	push   $0xf010542e
f0101957:	68 db 00 00 00       	push   $0xdb
f010195c:	68 bd 53 10 f0       	push   $0xf01053bd
f0101961:	e8 c8 e7 ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f0101966:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101969:	8b 40 08             	mov    0x8(%eax),%eax
f010196c:	66 83 f8 01          	cmp    $0x1,%ax
f0101970:	74 19                	je     f010198b <page_check+0x64a>
f0101972:	68 fd 56 10 f0       	push   $0xf01056fd
f0101977:	68 2e 54 10 f0       	push   $0xf010542e
f010197c:	68 dc 00 00 00       	push   $0xdc
f0101981:	68 bd 53 10 f0       	push   $0xf01053bd
f0101986:	e8 a3 e7 ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f010198b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010198e:	8b 40 08             	mov    0x8(%eax),%eax
f0101991:	66 85 c0             	test   %ax,%ax
f0101994:	74 19                	je     f01019af <page_check+0x66e>
f0101996:	68 dc 58 10 f0       	push   $0xf01058dc
f010199b:	68 2e 54 10 f0       	push   $0xf010542e
f01019a0:	68 dd 00 00 00       	push   $0xdd
f01019a5:	68 bd 53 10 f0       	push   $0xf01053bd
f01019aa:	e8 7f e7 ff ff       	call   f010012e <_panic>

	// unmapping pp1 at PAGE_SIZE should free it
	unmap_frame(ptr_page_directory, (void*) PAGE_SIZE);
f01019af:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01019b4:	83 ec 08             	sub    $0x8,%esp
f01019b7:	68 00 10 00 00       	push   $0x1000
f01019bc:	50                   	push   %eax
f01019bd:	e8 ac 0d 00 00       	call   f010276e <unmap_frame>
f01019c2:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f01019c5:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01019ca:	83 ec 08             	sub    $0x8,%esp
f01019cd:	6a 00                	push   $0x0
f01019cf:	50                   	push   %eax
f01019d0:	e8 a6 f8 ff ff       	call   f010127b <check_va2pa>
f01019d5:	83 c4 10             	add    $0x10,%esp
f01019d8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01019db:	74 19                	je     f01019f6 <page_check+0x6b5>
f01019dd:	68 1c 59 10 f0       	push   $0xf010591c
f01019e2:	68 2e 54 10 f0       	push   $0xf010542e
f01019e7:	68 e1 00 00 00       	push   $0xe1
f01019ec:	68 bd 53 10 f0       	push   $0xf01053bd
f01019f1:	e8 38 e7 ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == ~0);
f01019f6:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f01019fb:	83 ec 08             	sub    $0x8,%esp
f01019fe:	68 00 10 00 00       	push   $0x1000
f0101a03:	50                   	push   %eax
f0101a04:	e8 72 f8 ff ff       	call   f010127b <check_va2pa>
f0101a09:	83 c4 10             	add    $0x10,%esp
f0101a0c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101a0f:	74 19                	je     f0101a2a <page_check+0x6e9>
f0101a11:	68 48 59 10 f0       	push   $0xf0105948
f0101a16:	68 2e 54 10 f0       	push   $0xf010542e
f0101a1b:	68 e2 00 00 00       	push   $0xe2
f0101a20:	68 bd 53 10 f0       	push   $0xf01053bd
f0101a25:	e8 04 e7 ff ff       	call   f010012e <_panic>
	assert(pp1->references == 0);
f0101a2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a2d:	8b 40 08             	mov    0x8(%eax),%eax
f0101a30:	66 85 c0             	test   %ax,%ax
f0101a33:	74 19                	je     f0101a4e <page_check+0x70d>
f0101a35:	68 79 59 10 f0       	push   $0xf0105979
f0101a3a:	68 2e 54 10 f0       	push   $0xf010542e
f0101a3f:	68 e3 00 00 00       	push   $0xe3
f0101a44:	68 bd 53 10 f0       	push   $0xf01053bd
f0101a49:	e8 e0 e6 ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f0101a4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101a51:	8b 40 08             	mov    0x8(%eax),%eax
f0101a54:	66 85 c0             	test   %ax,%ax
f0101a57:	74 19                	je     f0101a72 <page_check+0x731>
f0101a59:	68 dc 58 10 f0       	push   $0xf01058dc
f0101a5e:	68 2e 54 10 f0       	push   $0xf010542e
f0101a63:	68 e4 00 00 00       	push   $0xe4
f0101a68:	68 bd 53 10 f0       	push   $0xf01053bd
f0101a6d:	e8 bc e6 ff ff       	call   f010012e <_panic>

	// so it should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp1);
f0101a72:	83 ec 0c             	sub    $0xc,%esp
f0101a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101a78:	50                   	push   %eax
f0101a79:	e8 d0 09 00 00       	call   f010244e <allocate_frame>
f0101a7e:	83 c4 10             	add    $0x10,%esp
f0101a81:	85 c0                	test   %eax,%eax
f0101a83:	75 0a                	jne    f0101a8f <page_check+0x74e>
f0101a85:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101a8b:	39 c2                	cmp    %eax,%edx
f0101a8d:	74 19                	je     f0101aa8 <page_check+0x767>
f0101a8f:	68 90 59 10 f0       	push   $0xf0105990
f0101a94:	68 2e 54 10 f0       	push   $0xf010542e
f0101a99:	68 e7 00 00 00       	push   $0xe7
f0101a9e:	68 bd 53 10 f0       	push   $0xf01053bd
f0101aa3:	e8 86 e6 ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101aa8:	83 ec 0c             	sub    $0xc,%esp
f0101aab:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101aae:	50                   	push   %eax
f0101aaf:	e8 9a 09 00 00       	call   f010244e <allocate_frame>
f0101ab4:	83 c4 10             	add    $0x10,%esp
f0101ab7:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101aba:	74 19                	je     f0101ad5 <page_check+0x794>
f0101abc:	68 f8 55 10 f0       	push   $0xf01055f8
f0101ac1:	68 2e 54 10 f0       	push   $0xf010542e
f0101ac6:	68 ea 00 00 00       	push   $0xea
f0101acb:	68 bd 53 10 f0       	push   $0xf01053bd
f0101ad0:	e8 59 e6 ff ff       	call   f010012e <_panic>

	// forcibly take pp0 back
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101ad5:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101ada:	8b 00                	mov    (%eax),%eax
f0101adc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101ae1:	89 c3                	mov    %eax,%ebx
f0101ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101ae6:	83 ec 0c             	sub    $0xc,%esp
f0101ae9:	50                   	push   %eax
f0101aea:	e8 41 f4 ff ff       	call   f0100f30 <to_physical_address>
f0101aef:	83 c4 10             	add    $0x10,%esp
f0101af2:	39 c3                	cmp    %eax,%ebx
f0101af4:	74 19                	je     f0101b0f <page_check+0x7ce>
f0101af6:	68 78 56 10 f0       	push   $0xf0105678
f0101afb:	68 2e 54 10 f0       	push   $0xf010542e
f0101b00:	68 ed 00 00 00       	push   $0xed
f0101b05:	68 bd 53 10 f0       	push   $0xf01053bd
f0101b0a:	e8 1f e6 ff ff       	call   f010012e <_panic>
	ptr_page_directory[0] = 0;
f0101b0f:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101b14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->references == 1);
f0101b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b1d:	8b 40 08             	mov    0x8(%eax),%eax
f0101b20:	66 83 f8 01          	cmp    $0x1,%ax
f0101b24:	74 19                	je     f0101b3f <page_check+0x7fe>
f0101b26:	68 12 57 10 f0       	push   $0xf0105712
f0101b2b:	68 2e 54 10 f0       	push   $0xf010542e
f0101b30:	68 ef 00 00 00       	push   $0xef
f0101b35:	68 bd 53 10 f0       	push   $0xf01053bd
f0101b3a:	e8 ef e5 ff ff       	call   f010012e <_panic>
	pp0->references = 0;
f0101b3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b42:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	free_frame_list = fl;
f0101b48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101b4b:	a3 38 e7 14 f0       	mov    %eax,0xf014e738

	// free the frames_info we took
	free_frame(pp0);
f0101b50:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b53:	83 ec 0c             	sub    $0xc,%esp
f0101b56:	50                   	push   %eax
f0101b57:	e8 59 09 00 00       	call   f01024b5 <free_frame>
f0101b5c:	83 c4 10             	add    $0x10,%esp
	free_frame(pp1);
f0101b5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101b62:	83 ec 0c             	sub    $0xc,%esp
f0101b65:	50                   	push   %eax
f0101b66:	e8 4a 09 00 00       	call   f01024b5 <free_frame>
f0101b6b:	83 c4 10             	add    $0x10,%esp
	free_frame(pp2);
f0101b6e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101b71:	83 ec 0c             	sub    $0xc,%esp
f0101b74:	50                   	push   %eax
f0101b75:	e8 3b 09 00 00       	call   f01024b5 <free_frame>
f0101b7a:	83 c4 10             	add    $0x10,%esp

	cprintf("page_check() succeeded!\n");
f0101b7d:	83 ec 0c             	sub    $0xc,%esp
f0101b80:	68 b6 59 10 f0       	push   $0xf01059b6
f0101b85:	e8 39 15 00 00       	call   f01030c3 <cprintf>
f0101b8a:	83 c4 10             	add    $0x10,%esp
}
f0101b8d:	90                   	nop
f0101b8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101b91:	c9                   	leave  
f0101b92:	c3                   	ret    

f0101b93 <turn_on_paging>:

void turn_on_paging()
{
f0101b93:	55                   	push   %ebp
f0101b94:	89 e5                	mov    %esp,%ebp
f0101b96:	83 ec 20             	sub    $0x20,%esp
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA (KERNEL_BASE), i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	ptr_page_directory[0] = ptr_page_directory[PDX(KERNEL_BASE)];
f0101b99:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101b9e:	8b 15 44 e7 14 f0    	mov    0xf014e744,%edx
f0101ba4:	8b 92 00 0f 00 00    	mov    0xf00(%edx),%edx
f0101baa:	89 10                	mov    %edx,(%eax)

	// Install page table.
	lcr3(phys_page_directory);
f0101bac:	a1 48 e7 14 f0       	mov    0xf014e748,%eax
f0101bb1:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101bb4:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101bb7:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32
rcr0(void)
{
	uint32 val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101bba:	0f 20 c0             	mov    %cr0,%eax
f0101bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f0101bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax

	// Turn on paging.
	uint32 cr0;
	cr0 = rcr0();
f0101bc3:	89 45 f8             	mov    %eax,-0x8(%ebp)
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0101bc6:	81 4d f8 2f 00 05 80 	orl    $0x8005002f,-0x8(%ebp)
	cr0 &= ~(CR0_TS|CR0_EM);
f0101bcd:	83 65 f8 f3          	andl   $0xfffffff3,-0x8(%ebp)
f0101bd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr0(uint32 val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101bda:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNEL_BASE+x => x => x.
	// (x < 4MB so uses paging ptr_page_directory[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f0101bdd:	0f 01 15 f0 b5 11 f0 	lgdtl  0xf011b5f0
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0101be4:	b8 23 00 00 00       	mov    $0x23,%eax
f0101be9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0101beb:	b8 23 00 00 00       	mov    $0x23,%eax
f0101bf0:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0101bf2:	b8 10 00 00 00       	mov    $0x10,%eax
f0101bf7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0101bf9:	b8 10 00 00 00       	mov    $0x10,%eax
f0101bfe:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0101c00:	b8 10 00 00 00       	mov    $0x10,%eax
f0101c05:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0101c07:	ea 0e 1c 10 f0 08 00 	ljmp   $0x8,$0xf0101c0e
	asm volatile("lldt %%ax" :: "a" (0));
f0101c0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101c13:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNEL_BASE + x => KERNEL_BASE + x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	ptr_page_directory[0] = 0;
f0101c16:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101c1b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// Flush the TLB for good measure, to kill the ptr_page_directory[0] mapping.
	lcr3(phys_page_directory);
f0101c21:	a1 48 e7 14 f0       	mov    0xf014e748,%eax
f0101c26:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101c29:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101c2c:	0f 22 d8             	mov    %eax,%cr3
}
f0101c2f:	90                   	nop
f0101c30:	c9                   	leave  
f0101c31:	c3                   	ret    

f0101c32 <setup_listing_to_all_page_tables_entries>:

void setup_listing_to_all_page_tables_entries()
{
f0101c32:	55                   	push   %ebp
f0101c33:	89 e5                	mov    %esp,%ebp
f0101c35:	83 ec 18             	sub    $0x18,%esp
	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.

	// Permissions: kernel RW, user NONE
	uint32 phys_frame_address = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0101c38:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101c3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101c40:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f0101c47:	77 17                	ja     f0101c60 <setup_listing_to_all_page_tables_entries+0x2e>
f0101c49:	ff 75 f4             	pushl  -0xc(%ebp)
f0101c4c:	68 8c 53 10 f0       	push   $0xf010538c
f0101c51:	68 39 01 00 00       	push   $0x139
f0101c56:	68 bd 53 10 f0       	push   $0xf01053bd
f0101c5b:	e8 ce e4 ff ff       	call   f010012e <_panic>
f0101c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c63:	05 00 00 00 10       	add    $0x10000000,%eax
f0101c68:	89 45 f0             	mov    %eax,-0x10(%ebp)
	ptr_page_directory[PDX(VPT)] = CONSTRUCT_ENTRY(phys_frame_address , PERM_PRESENT | PERM_WRITEABLE);
f0101c6b:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101c70:	05 fc 0e 00 00       	add    $0xefc,%eax
f0101c75:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0101c78:	83 ca 03             	or     $0x3,%edx
f0101c7b:	89 10                	mov    %edx,(%eax)

	// same for UVPT
	//Permissions: kernel R, user R
	ptr_page_directory[PDX(UVPT)] = K_PHYSICAL_ADDRESS(ptr_page_directory)|PERM_USER|PERM_PRESENT;
f0101c7d:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101c82:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0101c88:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101c8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101c90:	81 7d ec ff ff ff ef 	cmpl   $0xefffffff,-0x14(%ebp)
f0101c97:	77 17                	ja     f0101cb0 <setup_listing_to_all_page_tables_entries+0x7e>
f0101c99:	ff 75 ec             	pushl  -0x14(%ebp)
f0101c9c:	68 8c 53 10 f0       	push   $0xf010538c
f0101ca1:	68 3e 01 00 00       	push   $0x13e
f0101ca6:	68 bd 53 10 f0       	push   $0xf01053bd
f0101cab:	e8 7e e4 ff ff       	call   f010012e <_panic>
f0101cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cb3:	05 00 00 00 10       	add    $0x10000000,%eax
f0101cb8:	83 c8 05             	or     $0x5,%eax
f0101cbb:	89 02                	mov    %eax,(%edx)

}
f0101cbd:	90                   	nop
f0101cbe:	c9                   	leave  
f0101cbf:	c3                   	ret    

f0101cc0 <envid2env>:
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int envid2env(int32  envid, struct Env **env_store, bool checkperm)
{
f0101cc0:	55                   	push   %ebp
f0101cc1:	89 e5                	mov    %esp,%ebp
f0101cc3:	83 ec 10             	sub    $0x10,%esp
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0101cc6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101cca:	75 15                	jne    f0101ce1 <envid2env+0x21>
		*env_store = curenv;
f0101ccc:	8b 15 b0 de 14 f0    	mov    0xf014deb0,%edx
f0101cd2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101cd5:	89 10                	mov    %edx,(%eax)
		return 0;
f0101cd7:	b8 00 00 00 00       	mov    $0x0,%eax
f0101cdc:	e9 8c 00 00 00       	jmp    f0101d6d <envid2env+0xad>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0101ce1:	8b 15 ac de 14 f0    	mov    0xf014deac,%edx
f0101ce7:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cea:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101cef:	89 c1                	mov    %eax,%ecx
f0101cf1:	89 c8                	mov    %ecx,%eax
f0101cf3:	c1 e0 02             	shl    $0x2,%eax
f0101cf6:	01 c8                	add    %ecx,%eax
f0101cf8:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0101cff:	01 c8                	add    %ecx,%eax
f0101d01:	c1 e0 02             	shl    $0x2,%eax
f0101d04:	01 d0                	add    %edx,%eax
f0101d06:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0101d09:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101d0c:	8b 40 54             	mov    0x54(%eax),%eax
f0101d0f:	85 c0                	test   %eax,%eax
f0101d11:	74 0b                	je     f0101d1e <envid2env+0x5e>
f0101d13:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101d16:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101d19:	3b 45 08             	cmp    0x8(%ebp),%eax
f0101d1c:	74 10                	je     f0101d2e <envid2env+0x6e>
		*env_store = 0;
f0101d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0101d27:	b8 02 00 00 00       	mov    $0x2,%eax
f0101d2c:	eb 3f                	jmp    f0101d6d <envid2env+0xad>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0101d2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101d32:	74 2c                	je     f0101d60 <envid2env+0xa0>
f0101d34:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0101d39:	39 45 fc             	cmp    %eax,-0x4(%ebp)
f0101d3c:	74 22                	je     f0101d60 <envid2env+0xa0>
f0101d3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101d41:	8b 50 50             	mov    0x50(%eax),%edx
f0101d44:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0101d49:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101d4c:	39 c2                	cmp    %eax,%edx
f0101d4e:	74 10                	je     f0101d60 <envid2env+0xa0>
		*env_store = 0;
f0101d50:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0101d59:	b8 02 00 00 00       	mov    $0x2,%eax
f0101d5e:	eb 0d                	jmp    f0101d6d <envid2env+0xad>
	}

	*env_store = e;
f0101d60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d63:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0101d66:	89 10                	mov    %edx,(%eax)
	return 0;
f0101d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101d6d:	c9                   	leave  
f0101d6e:	c3                   	ret    

f0101d6f <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0101d6f:	55                   	push   %ebp
f0101d70:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0101d72:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d75:	8b 15 3c e7 14 f0    	mov    0xf014e73c,%edx
f0101d7b:	29 d0                	sub    %edx,%eax
f0101d7d:	c1 f8 02             	sar    $0x2,%eax
f0101d80:	89 c2                	mov    %eax,%edx
f0101d82:	89 d0                	mov    %edx,%eax
f0101d84:	c1 e0 02             	shl    $0x2,%eax
f0101d87:	01 d0                	add    %edx,%eax
f0101d89:	c1 e0 02             	shl    $0x2,%eax
f0101d8c:	01 d0                	add    %edx,%eax
f0101d8e:	c1 e0 02             	shl    $0x2,%eax
f0101d91:	01 d0                	add    %edx,%eax
f0101d93:	89 c1                	mov    %eax,%ecx
f0101d95:	c1 e1 08             	shl    $0x8,%ecx
f0101d98:	01 c8                	add    %ecx,%eax
f0101d9a:	89 c1                	mov    %eax,%ecx
f0101d9c:	c1 e1 10             	shl    $0x10,%ecx
f0101d9f:	01 c8                	add    %ecx,%eax
f0101da1:	01 c0                	add    %eax,%eax
f0101da3:	01 d0                	add    %edx,%eax
}
f0101da5:	5d                   	pop    %ebp
f0101da6:	c3                   	ret    

f0101da7 <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101da7:	55                   	push   %ebp
f0101da8:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0101daa:	ff 75 08             	pushl  0x8(%ebp)
f0101dad:	e8 bd ff ff ff       	call   f0101d6f <to_frame_number>
f0101db2:	83 c4 04             	add    $0x4,%esp
f0101db5:	c1 e0 0c             	shl    $0xc,%eax
}
f0101db8:	c9                   	leave  
f0101db9:	c3                   	ret    

f0101dba <to_frame_info>:

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0101dba:	55                   	push   %ebp
f0101dbb:	89 e5                	mov    %esp,%ebp
f0101dbd:	83 ec 08             	sub    $0x8,%esp
	if (PPN(physical_address) >= number_of_frames)
f0101dc0:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dc3:	c1 e8 0c             	shr    $0xc,%eax
f0101dc6:	89 c2                	mov    %eax,%edx
f0101dc8:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f0101dcd:	39 c2                	cmp    %eax,%edx
f0101dcf:	72 14                	jb     f0101de5 <to_frame_info+0x2b>
		panic("to_frame_info called with invalid pa");
f0101dd1:	83 ec 04             	sub    $0x4,%esp
f0101dd4:	68 d0 59 10 f0       	push   $0xf01059d0
f0101dd9:	6a 39                	push   $0x39
f0101ddb:	68 f5 59 10 f0       	push   $0xf01059f5
f0101de0:	e8 49 e3 ff ff       	call   f010012e <_panic>
	return &frames_info[PPN(physical_address)];
f0101de5:	8b 15 3c e7 14 f0    	mov    0xf014e73c,%edx
f0101deb:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dee:	c1 e8 0c             	shr    $0xc,%eax
f0101df1:	89 c1                	mov    %eax,%ecx
f0101df3:	89 c8                	mov    %ecx,%eax
f0101df5:	01 c0                	add    %eax,%eax
f0101df7:	01 c8                	add    %ecx,%eax
f0101df9:	c1 e0 02             	shl    $0x2,%eax
f0101dfc:	01 d0                	add    %edx,%eax
}
f0101dfe:	c9                   	leave  
f0101dff:	c3                   	ret    

f0101e00 <initialize_kernel_VM>:
//
// From USER_TOP to USER_LIMIT, the user is allowed to read but not write.
// Above USER_LIMIT the user cannot read (or write).

void initialize_kernel_VM()
{
f0101e00:	55                   	push   %ebp
f0101e01:	89 e5                	mov    %esp,%ebp
f0101e03:	83 ec 28             	sub    $0x28,%esp
	//panic("initialize_kernel_VM: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	ptr_page_directory = boot_allocate_space(PAGE_SIZE, PAGE_SIZE);
f0101e06:	83 ec 08             	sub    $0x8,%esp
f0101e09:	68 00 10 00 00       	push   $0x1000
f0101e0e:	68 00 10 00 00       	push   $0x1000
f0101e13:	e8 ca 01 00 00       	call   f0101fe2 <boot_allocate_space>
f0101e18:	83 c4 10             	add    $0x10,%esp
f0101e1b:	a3 44 e7 14 f0       	mov    %eax,0xf014e744
	memset(ptr_page_directory, 0, PAGE_SIZE);
f0101e20:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101e25:	83 ec 04             	sub    $0x4,%esp
f0101e28:	68 00 10 00 00       	push   $0x1000
f0101e2d:	6a 00                	push   $0x0
f0101e2f:	50                   	push   %eax
f0101e30:	e8 70 29 00 00       	call   f01047a5 <memset>
f0101e35:	83 c4 10             	add    $0x10,%esp
	phys_page_directory = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0101e38:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101e3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101e40:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f0101e47:	77 14                	ja     f0101e5d <initialize_kernel_VM+0x5d>
f0101e49:	ff 75 f4             	pushl  -0xc(%ebp)
f0101e4c:	68 10 5a 10 f0       	push   $0xf0105a10
f0101e51:	6a 3c                	push   $0x3c
f0101e53:	68 41 5a 10 f0       	push   $0xf0105a41
f0101e58:	e8 d1 e2 ff ff       	call   f010012e <_panic>
f0101e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e60:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e65:	a3 48 e7 14 f0       	mov    %eax,0xf014e748
	// Map the kernel stack with VA range :
	//  [KERNEL_STACK_TOP-KERNEL_STACK_SIZE, KERNEL_STACK_TOP), 
	// to physical address : "phys_stack_bottom".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_range(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE, K_PHYSICAL_ADDRESS(ptr_stack_bottom), PERM_WRITEABLE) ;
f0101e6a:	c7 45 f0 00 30 11 f0 	movl   $0xf0113000,-0x10(%ebp)
f0101e71:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0101e78:	77 14                	ja     f0101e8e <initialize_kernel_VM+0x8e>
f0101e7a:	ff 75 f0             	pushl  -0x10(%ebp)
f0101e7d:	68 10 5a 10 f0       	push   $0xf0105a10
f0101e82:	6a 44                	push   $0x44
f0101e84:	68 41 5a 10 f0       	push   $0xf0105a41
f0101e89:	e8 a0 e2 ff ff       	call   f010012e <_panic>
f0101e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101e91:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101e97:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101e9c:	83 ec 0c             	sub    $0xc,%esp
f0101e9f:	6a 02                	push   $0x2
f0101ea1:	52                   	push   %edx
f0101ea2:	68 00 80 00 00       	push   $0x8000
f0101ea7:	68 00 80 bf ef       	push   $0xefbf8000
f0101eac:	50                   	push   %eax
f0101ead:	e8 92 01 00 00       	call   f0102044 <boot_map_range>
f0101eb2:	83 c4 20             	add    $0x20,%esp
	//      the PA range [0, 2^32 - KERNEL_BASE)
	// We might not have 2^32 - KERNEL_BASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_range(ptr_page_directory, KERNEL_BASE, 0xFFFFFFFF - KERNEL_BASE, 0, PERM_WRITEABLE) ;
f0101eb5:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101eba:	83 ec 0c             	sub    $0xc,%esp
f0101ebd:	6a 02                	push   $0x2
f0101ebf:	6a 00                	push   $0x0
f0101ec1:	68 ff ff ff 0f       	push   $0xfffffff
f0101ec6:	68 00 00 00 f0       	push   $0xf0000000
f0101ecb:	50                   	push   %eax
f0101ecc:	e8 73 01 00 00       	call   f0102044 <boot_map_range>
f0101ed1:	83 c4 20             	add    $0x20,%esp
	// Permissions:
	//    - frames_info -- kernel RW, user NONE
	//    - the image mapped at READ_ONLY_FRAMES_INFO  -- kernel R, user R
	// Your code goes here:
	uint32 array_size;
	array_size = number_of_frames * sizeof(struct Frame_Info) ;
f0101ed4:	8b 15 28 e7 14 f0    	mov    0xf014e728,%edx
f0101eda:	89 d0                	mov    %edx,%eax
f0101edc:	01 c0                	add    %eax,%eax
f0101ede:	01 d0                	add    %edx,%eax
f0101ee0:	c1 e0 02             	shl    $0x2,%eax
f0101ee3:	89 45 ec             	mov    %eax,-0x14(%ebp)
	frames_info = boot_allocate_space(array_size, PAGE_SIZE);
f0101ee6:	83 ec 08             	sub    $0x8,%esp
f0101ee9:	68 00 10 00 00       	push   $0x1000
f0101eee:	ff 75 ec             	pushl  -0x14(%ebp)
f0101ef1:	e8 ec 00 00 00       	call   f0101fe2 <boot_allocate_space>
f0101ef6:	83 c4 10             	add    $0x10,%esp
f0101ef9:	a3 3c e7 14 f0       	mov    %eax,0xf014e73c
	boot_map_range(ptr_page_directory, READ_ONLY_FRAMES_INFO, array_size, K_PHYSICAL_ADDRESS(frames_info), PERM_USER) ;
f0101efe:	a1 3c e7 14 f0       	mov    0xf014e73c,%eax
f0101f03:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101f06:	81 7d e8 ff ff ff ef 	cmpl   $0xefffffff,-0x18(%ebp)
f0101f0d:	77 14                	ja     f0101f23 <initialize_kernel_VM+0x123>
f0101f0f:	ff 75 e8             	pushl  -0x18(%ebp)
f0101f12:	68 10 5a 10 f0       	push   $0xf0105a10
f0101f17:	6a 5f                	push   $0x5f
f0101f19:	68 41 5a 10 f0       	push   $0xf0105a41
f0101f1e:	e8 0b e2 ff ff       	call   f010012e <_panic>
f0101f23:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101f26:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101f2c:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101f31:	83 ec 0c             	sub    $0xc,%esp
f0101f34:	6a 04                	push   $0x4
f0101f36:	52                   	push   %edx
f0101f37:	ff 75 ec             	pushl  -0x14(%ebp)
f0101f3a:	68 00 00 00 ef       	push   $0xef000000
f0101f3f:	50                   	push   %eax
f0101f40:	e8 ff 00 00 00       	call   f0102044 <boot_map_range>
f0101f45:	83 c4 20             	add    $0x20,%esp


	// This allows the kernel & user to access any page table entry using a
	// specified VA for each: VPT for kernel and UVPT for User.
	setup_listing_to_all_page_tables_entries();
f0101f48:	e8 e5 fc ff ff       	call   f0101c32 <setup_listing_to_all_page_tables_entries>
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	
	// LAB 3: Your code here.
	int envs_size = NENV * sizeof(struct Env) ;
f0101f4d:	c7 45 e4 00 90 01 00 	movl   $0x19000,-0x1c(%ebp)

	//allocate space for "envs" array aligned on 4KB boundary
	envs = boot_allocate_space(envs_size, PAGE_SIZE);
f0101f54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101f57:	83 ec 08             	sub    $0x8,%esp
f0101f5a:	68 00 10 00 00       	push   $0x1000
f0101f5f:	50                   	push   %eax
f0101f60:	e8 7d 00 00 00       	call   f0101fe2 <boot_allocate_space>
f0101f65:	83 c4 10             	add    $0x10,%esp
f0101f68:	a3 ac de 14 f0       	mov    %eax,0xf014deac

	//make the user to access this array by mapping it to UPAGES linear address (UPAGES is in User/Kernel space)
	boot_map_range(ptr_page_directory, UENVS, envs_size, K_PHYSICAL_ADDRESS(envs), PERM_USER) ;
f0101f6d:	a1 ac de 14 f0       	mov    0xf014deac,%eax
f0101f72:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101f75:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0101f7c:	77 14                	ja     f0101f92 <initialize_kernel_VM+0x192>
f0101f7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101f81:	68 10 5a 10 f0       	push   $0xf0105a10
f0101f86:	6a 75                	push   $0x75
f0101f88:	68 41 5a 10 f0       	push   $0xf0105a41
f0101f8d:	e8 9c e1 ff ff       	call   f010012e <_panic>
f0101f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101f95:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0101f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101f9e:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101fa3:	83 ec 0c             	sub    $0xc,%esp
f0101fa6:	6a 04                	push   $0x4
f0101fa8:	51                   	push   %ecx
f0101fa9:	52                   	push   %edx
f0101faa:	68 00 00 c0 ee       	push   $0xeec00000
f0101faf:	50                   	push   %eax
f0101fb0:	e8 8f 00 00 00       	call   f0102044 <boot_map_range>
f0101fb5:	83 c4 20             	add    $0x20,%esp

	//update permissions of the corresponding entry in page directory to make it USER with PERMISSION read only
	ptr_page_directory[PDX(UENVS)] = ptr_page_directory[PDX(UENVS)]|(PERM_USER|(PERM_PRESENT & (~PERM_WRITEABLE)));
f0101fb8:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0101fbd:	05 ec 0e 00 00       	add    $0xeec,%eax
f0101fc2:	8b 15 44 e7 14 f0    	mov    0xf014e744,%edx
f0101fc8:	81 c2 ec 0e 00 00    	add    $0xeec,%edx
f0101fce:	8b 12                	mov    (%edx),%edx
f0101fd0:	83 ca 05             	or     $0x5,%edx
f0101fd3:	89 10                	mov    %edx,(%eax)


	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();
f0101fd5:	e8 52 f0 ff ff       	call   f010102c <check_boot_pgdir>
	
	// NOW: Turn off the segmentation by setting the segments' base to 0, and
	// turn on the paging by setting the corresponding flags in control register 0 (cr0)
	turn_on_paging() ;
f0101fda:	e8 b4 fb ff ff       	call   f0101b93 <turn_on_paging>
}
f0101fdf:	90                   	nop
f0101fe0:	c9                   	leave  
f0101fe1:	c3                   	ret    

f0101fe2 <boot_allocate_space>:
// It's too early to run out of memory.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
// 
void* boot_allocate_space(uint32 size, uint32 align)
{
f0101fe2:	55                   	push   %ebp
f0101fe3:	89 e5                	mov    %esp,%ebp
f0101fe5:	83 ec 10             	sub    $0x10,%esp
	// Initialize ptr_free_mem if this is the first time.
	// 'end_of_kernel' is a symbol automatically generated by the linker,
	// which points to the end of the kernel-
	// i.e., the first virtual address that the linker
	// did not assign to any kernel code or global variables.
	if (ptr_free_mem == 0)
f0101fe8:	a1 40 e7 14 f0       	mov    0xf014e740,%eax
f0101fed:	85 c0                	test   %eax,%eax
f0101fef:	75 0a                	jne    f0101ffb <boot_allocate_space+0x19>
		ptr_free_mem = end_of_kernel;
f0101ff1:	c7 05 40 e7 14 f0 4c 	movl   $0xf014e74c,0xf014e740
f0101ff8:	e7 14 f0 

	// Your code here:
	//	Step 1: round ptr_free_mem up to be aligned properly
	ptr_free_mem = ROUNDUP(ptr_free_mem, PAGE_SIZE) ;
f0101ffb:	c7 45 fc 00 10 00 00 	movl   $0x1000,-0x4(%ebp)
f0102002:	a1 40 e7 14 f0       	mov    0xf014e740,%eax
f0102007:	89 c2                	mov    %eax,%edx
f0102009:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010200c:	01 d0                	add    %edx,%eax
f010200e:	48                   	dec    %eax
f010200f:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0102012:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0102015:	ba 00 00 00 00       	mov    $0x0,%edx
f010201a:	f7 75 fc             	divl   -0x4(%ebp)
f010201d:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0102020:	29 d0                	sub    %edx,%eax
f0102022:	a3 40 e7 14 f0       	mov    %eax,0xf014e740
	
	//	Step 2: save current value of ptr_free_mem as allocated space
	void *ptr_allocated_mem;
	ptr_allocated_mem = ptr_free_mem ;
f0102027:	a1 40 e7 14 f0       	mov    0xf014e740,%eax
f010202c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//	Step 3: increase ptr_free_mem to record allocation
	ptr_free_mem += size ;
f010202f:	8b 15 40 e7 14 f0    	mov    0xf014e740,%edx
f0102035:	8b 45 08             	mov    0x8(%ebp),%eax
f0102038:	01 d0                	add    %edx,%eax
f010203a:	a3 40 e7 14 f0       	mov    %eax,0xf014e740

	//	Step 4: return allocated space
	return ptr_allocated_mem ;
f010203f:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
f0102042:	c9                   	leave  
f0102043:	c3                   	ret    

f0102044 <boot_map_range>:
//
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
f0102044:	55                   	push   %ebp
f0102045:	89 e5                	mov    %esp,%ebp
f0102047:	83 ec 28             	sub    $0x28,%esp
	int i = 0 ;
f010204a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
f0102051:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0102058:	8b 55 14             	mov    0x14(%ebp),%edx
f010205b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010205e:	01 d0                	add    %edx,%eax
f0102060:	48                   	dec    %eax
f0102061:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102064:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102067:	ba 00 00 00 00       	mov    $0x0,%edx
f010206c:	f7 75 f0             	divl   -0x10(%ebp)
f010206f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102072:	29 d0                	sub    %edx,%eax
f0102074:	89 45 14             	mov    %eax,0x14(%ebp)
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f0102077:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f010207e:	eb 53                	jmp    f01020d3 <boot_map_range+0x8f>
	{
		uint32 *ptr_page_table = boot_get_page_table(ptr_page_directory, virtual_address, 1) ;
f0102080:	83 ec 04             	sub    $0x4,%esp
f0102083:	6a 01                	push   $0x1
f0102085:	ff 75 0c             	pushl  0xc(%ebp)
f0102088:	ff 75 08             	pushl  0x8(%ebp)
f010208b:	e8 4e 00 00 00       	call   f01020de <boot_get_page_table>
f0102090:	83 c4 10             	add    $0x10,%esp
f0102093:	89 45 e8             	mov    %eax,-0x18(%ebp)
		uint32 index_page_table = PTX(virtual_address);
f0102096:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102099:	c1 e8 0c             	shr    $0xc,%eax
f010209c:	25 ff 03 00 00       	and    $0x3ff,%eax
f01020a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
f01020a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01020a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01020ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01020b1:	01 c2                	add    %eax,%edx
f01020b3:	8b 45 18             	mov    0x18(%ebp),%eax
f01020b6:	0b 45 14             	or     0x14(%ebp),%eax
f01020b9:	83 c8 01             	or     $0x1,%eax
f01020bc:	89 02                	mov    %eax,(%edx)
		physical_address += PAGE_SIZE ;
f01020be:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
		virtual_address += PAGE_SIZE ;
f01020c5:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
	int i = 0 ;
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f01020cc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f01020d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020d6:	3b 45 10             	cmp    0x10(%ebp),%eax
f01020d9:	72 a5                	jb     f0102080 <boot_map_range+0x3c>
		uint32 index_page_table = PTX(virtual_address);
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
		physical_address += PAGE_SIZE ;
		virtual_address += PAGE_SIZE ;
	}
}
f01020db:	90                   	nop
f01020dc:	c9                   	leave  
f01020dd:	c3                   	ret    

f01020de <boot_get_page_table>:
// boot_get_page_table cannot fail.  It's too early to fail.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
uint32* boot_get_page_table(uint32 *ptr_page_directory, uint32 virtual_address, int create)
{
f01020de:	55                   	push   %ebp
f01020df:	89 e5                	mov    %esp,%ebp
f01020e1:	83 ec 28             	sub    $0x28,%esp
	uint32 index_page_directory = PDX(virtual_address);
f01020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01020e7:	c1 e8 16             	shr    $0x16,%eax
f01020ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 page_directory_entry = ptr_page_directory[index_page_directory];
f01020ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01020f0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01020f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01020fa:	01 d0                	add    %edx,%eax
f01020fc:	8b 00                	mov    (%eax),%eax
f01020fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	uint32 phys_page_table = EXTRACT_ADDRESS(page_directory_entry);
f0102101:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102104:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102109:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 *ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table);
f010210c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010210f:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102112:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102115:	c1 e8 0c             	shr    $0xc,%eax
f0102118:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010211b:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f0102120:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0102123:	72 17                	jb     f010213c <boot_get_page_table+0x5e>
f0102125:	ff 75 e8             	pushl  -0x18(%ebp)
f0102128:	68 58 5a 10 f0       	push   $0xf0105a58
f010212d:	68 db 00 00 00       	push   $0xdb
f0102132:	68 41 5a 10 f0       	push   $0xf0105a41
f0102137:	e8 f2 df ff ff       	call   f010012e <_panic>
f010213c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010213f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102144:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (phys_page_table == 0)
f0102147:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f010214b:	75 72                	jne    f01021bf <boot_get_page_table+0xe1>
	{
		if (create)
f010214d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102151:	74 65                	je     f01021b8 <boot_get_page_table+0xda>
		{
			ptr_page_table = boot_allocate_space(PAGE_SIZE, PAGE_SIZE) ;
f0102153:	83 ec 08             	sub    $0x8,%esp
f0102156:	68 00 10 00 00       	push   $0x1000
f010215b:	68 00 10 00 00       	push   $0x1000
f0102160:	e8 7d fe ff ff       	call   f0101fe2 <boot_allocate_space>
f0102165:	83 c4 10             	add    $0x10,%esp
f0102168:	89 45 e0             	mov    %eax,-0x20(%ebp)
			phys_page_table = K_PHYSICAL_ADDRESS(ptr_page_table);
f010216b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010216e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102171:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f0102178:	77 17                	ja     f0102191 <boot_get_page_table+0xb3>
f010217a:	ff 75 dc             	pushl  -0x24(%ebp)
f010217d:	68 10 5a 10 f0       	push   $0xf0105a10
f0102182:	68 e1 00 00 00       	push   $0xe1
f0102187:	68 41 5a 10 f0       	push   $0xf0105a41
f010218c:	e8 9d df ff ff       	call   f010012e <_panic>
f0102191:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102194:	05 00 00 00 10       	add    $0x10000000,%eax
f0102199:	89 45 ec             	mov    %eax,-0x14(%ebp)
			ptr_page_directory[index_page_directory] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_WRITEABLE);
f010219c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010219f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01021a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01021a9:	01 d0                	add    %edx,%eax
f01021ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01021ae:	83 ca 03             	or     $0x3,%edx
f01021b1:	89 10                	mov    %edx,(%eax)
			return ptr_page_table ;
f01021b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01021b6:	eb 0a                	jmp    f01021c2 <boot_get_page_table+0xe4>
		}
		else
			return 0 ;
f01021b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01021bd:	eb 03                	jmp    f01021c2 <boot_get_page_table+0xe4>
	}
	return ptr_page_table ;
f01021bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
f01021c2:	c9                   	leave  
f01021c3:	c3                   	ret    

f01021c4 <initialize_paging>:
// After this point, ONLY use the functions below
// to allocate and deallocate physical memory via the free_frame_list,
// and NEVER use boot_allocate_space() or the related boot-time functions above.
//
void initialize_paging()
{
f01021c4:	55                   	push   %ebp
f01021c5:	89 e5                	mov    %esp,%ebp
f01021c7:	53                   	push   %ebx
f01021c8:	83 ec 24             	sub    $0x24,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which frames are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&free_frame_list);
f01021cb:	c7 05 38 e7 14 f0 00 	movl   $0x0,0xf014e738
f01021d2:	00 00 00 
	
	frames_info[0].references = 1;
f01021d5:	a1 3c e7 14 f0       	mov    0xf014e73c,%eax
f01021da:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
f01021e0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f01021e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01021ea:	05 ff ff 09 00       	add    $0x9ffff,%eax
f01021ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01021f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01021f5:	ba 00 00 00 00       	mov    $0x0,%edx
f01021fa:	f7 75 f0             	divl   -0x10(%ebp)
f01021fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102200:	29 d0                	sub    %edx,%eax
f0102202:	89 45 e8             	mov    %eax,-0x18(%ebp)
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f0102205:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
f010220c:	e9 90 00 00 00       	jmp    f01022a1 <initialize_paging+0xdd>
	{
		frames_info[i].references = 0;
f0102211:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102217:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010221a:	89 d0                	mov    %edx,%eax
f010221c:	01 c0                	add    %eax,%eax
f010221e:	01 d0                	add    %edx,%eax
f0102220:	c1 e0 02             	shl    $0x2,%eax
f0102223:	01 c8                	add    %ecx,%eax
f0102225:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f010222b:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102231:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102234:	89 d0                	mov    %edx,%eax
f0102236:	01 c0                	add    %eax,%eax
f0102238:	01 d0                	add    %edx,%eax
f010223a:	c1 e0 02             	shl    $0x2,%eax
f010223d:	01 c8                	add    %ecx,%eax
f010223f:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f0102245:	89 10                	mov    %edx,(%eax)
f0102247:	8b 00                	mov    (%eax),%eax
f0102249:	85 c0                	test   %eax,%eax
f010224b:	74 1d                	je     f010226a <initialize_paging+0xa6>
f010224d:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f0102253:	8b 1d 3c e7 14 f0    	mov    0xf014e73c,%ebx
f0102259:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f010225c:	89 c8                	mov    %ecx,%eax
f010225e:	01 c0                	add    %eax,%eax
f0102260:	01 c8                	add    %ecx,%eax
f0102262:	c1 e0 02             	shl    $0x2,%eax
f0102265:	01 d8                	add    %ebx,%eax
f0102267:	89 42 04             	mov    %eax,0x4(%edx)
f010226a:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102270:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102273:	89 d0                	mov    %edx,%eax
f0102275:	01 c0                	add    %eax,%eax
f0102277:	01 d0                	add    %edx,%eax
f0102279:	c1 e0 02             	shl    $0x2,%eax
f010227c:	01 c8                	add    %ecx,%eax
f010227e:	a3 38 e7 14 f0       	mov    %eax,0xf014e738
f0102283:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102289:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010228c:	89 d0                	mov    %edx,%eax
f010228e:	01 c0                	add    %eax,%eax
f0102290:	01 d0                	add    %edx,%eax
f0102292:	c1 e0 02             	shl    $0x2,%eax
f0102295:	01 c8                	add    %ecx,%eax
f0102297:	c7 40 04 38 e7 14 f0 	movl   $0xf014e738,0x4(%eax)
	
	frames_info[0].references = 1;
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f010229e:	ff 45 f4             	incl   -0xc(%ebp)
f01022a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01022a4:	85 c0                	test   %eax,%eax
f01022a6:	79 05                	jns    f01022ad <initialize_paging+0xe9>
f01022a8:	05 ff 0f 00 00       	add    $0xfff,%eax
f01022ad:	c1 f8 0c             	sar    $0xc,%eax
f01022b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01022b3:	0f 8f 58 ff ff ff    	jg     f0102211 <initialize_paging+0x4d>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f01022b9:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%ebp)
f01022c0:	eb 1d                	jmp    f01022df <initialize_paging+0x11b>
	{
		frames_info[i].references = 1;
f01022c2:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f01022c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01022cb:	89 d0                	mov    %edx,%eax
f01022cd:	01 c0                	add    %eax,%eax
f01022cf:	01 d0                	add    %edx,%eax
f01022d1:	c1 e0 02             	shl    $0x2,%eax
f01022d4:	01 c8                	add    %ecx,%eax
f01022d6:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f01022dc:	ff 45 f4             	incl   -0xc(%ebp)
f01022df:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
f01022e6:	7e da                	jle    f01022c2 <initialize_paging+0xfe>
	{
		frames_info[i].references = 1;
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
f01022e8:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
f01022ef:	a1 40 e7 14 f0       	mov    0xf014e740,%eax
f01022f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01022f7:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f01022fe:	77 17                	ja     f0102317 <initialize_paging+0x153>
f0102300:	ff 75 e0             	pushl  -0x20(%ebp)
f0102303:	68 10 5a 10 f0       	push   $0xf0105a10
f0102308:	68 1e 01 00 00       	push   $0x11e
f010230d:	68 41 5a 10 f0       	push   $0xf0105a41
f0102312:	e8 17 de ff ff       	call   f010012e <_panic>
f0102317:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010231a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102320:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102323:	01 d0                	add    %edx,%eax
f0102325:	48                   	dec    %eax
f0102326:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102329:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010232c:	ba 00 00 00 00       	mov    $0x0,%edx
f0102331:	f7 75 e4             	divl   -0x1c(%ebp)
f0102334:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102337:	29 d0                	sub    %edx,%eax
f0102339:	89 45 e8             	mov    %eax,-0x18(%ebp)
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f010233c:	c7 45 f4 00 01 00 00 	movl   $0x100,-0xc(%ebp)
f0102343:	eb 1d                	jmp    f0102362 <initialize_paging+0x19e>
	{
		frames_info[i].references = 1;
f0102345:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f010234b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010234e:	89 d0                	mov    %edx,%eax
f0102350:	01 c0                	add    %eax,%eax
f0102352:	01 d0                	add    %edx,%eax
f0102354:	c1 e0 02             	shl    $0x2,%eax
f0102357:	01 c8                	add    %ecx,%eax
f0102359:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		frames_info[i].references = 1;
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f010235f:	ff 45 f4             	incl   -0xc(%ebp)
f0102362:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102365:	85 c0                	test   %eax,%eax
f0102367:	79 05                	jns    f010236e <initialize_paging+0x1aa>
f0102369:	05 ff 0f 00 00       	add    $0xfff,%eax
f010236e:	c1 f8 0c             	sar    $0xc,%eax
f0102371:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102374:	7f cf                	jg     f0102345 <initialize_paging+0x181>
	{
		frames_info[i].references = 1;
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f0102376:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102379:	85 c0                	test   %eax,%eax
f010237b:	79 05                	jns    f0102382 <initialize_paging+0x1be>
f010237d:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102382:	c1 f8 0c             	sar    $0xc,%eax
f0102385:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102388:	e9 90 00 00 00       	jmp    f010241d <initialize_paging+0x259>
	{
		frames_info[i].references = 0;
f010238d:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102393:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102396:	89 d0                	mov    %edx,%eax
f0102398:	01 c0                	add    %eax,%eax
f010239a:	01 d0                	add    %edx,%eax
f010239c:	c1 e0 02             	shl    $0x2,%eax
f010239f:	01 c8                	add    %ecx,%eax
f01023a1:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f01023a7:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f01023ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01023b0:	89 d0                	mov    %edx,%eax
f01023b2:	01 c0                	add    %eax,%eax
f01023b4:	01 d0                	add    %edx,%eax
f01023b6:	c1 e0 02             	shl    $0x2,%eax
f01023b9:	01 c8                	add    %ecx,%eax
f01023bb:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f01023c1:	89 10                	mov    %edx,(%eax)
f01023c3:	8b 00                	mov    (%eax),%eax
f01023c5:	85 c0                	test   %eax,%eax
f01023c7:	74 1d                	je     f01023e6 <initialize_paging+0x222>
f01023c9:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f01023cf:	8b 1d 3c e7 14 f0    	mov    0xf014e73c,%ebx
f01023d5:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f01023d8:	89 c8                	mov    %ecx,%eax
f01023da:	01 c0                	add    %eax,%eax
f01023dc:	01 c8                	add    %ecx,%eax
f01023de:	c1 e0 02             	shl    $0x2,%eax
f01023e1:	01 d8                	add    %ebx,%eax
f01023e3:	89 42 04             	mov    %eax,0x4(%edx)
f01023e6:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f01023ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01023ef:	89 d0                	mov    %edx,%eax
f01023f1:	01 c0                	add    %eax,%eax
f01023f3:	01 d0                	add    %edx,%eax
f01023f5:	c1 e0 02             	shl    $0x2,%eax
f01023f8:	01 c8                	add    %ecx,%eax
f01023fa:	a3 38 e7 14 f0       	mov    %eax,0xf014e738
f01023ff:	8b 0d 3c e7 14 f0    	mov    0xf014e73c,%ecx
f0102405:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102408:	89 d0                	mov    %edx,%eax
f010240a:	01 c0                	add    %eax,%eax
f010240c:	01 d0                	add    %edx,%eax
f010240e:	c1 e0 02             	shl    $0x2,%eax
f0102411:	01 c8                	add    %ecx,%eax
f0102413:	c7 40 04 38 e7 14 f0 	movl   $0xf014e738,0x4(%eax)
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
	{
		frames_info[i].references = 1;
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f010241a:	ff 45 f4             	incl   -0xc(%ebp)
f010241d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102420:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f0102425:	39 c2                	cmp    %eax,%edx
f0102427:	0f 82 60 ff ff ff    	jb     f010238d <initialize_paging+0x1c9>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
}
f010242d:	90                   	nop
f010242e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102431:	c9                   	leave  
f0102432:	c3                   	ret    

f0102433 <initialize_frame_info>:
// Initialize a Frame_Info structure.
// The result has null links and 0 references.
// Note that the corresponding physical frame is NOT initialized!
//
void initialize_frame_info(struct Frame_Info *ptr_frame_info)
{
f0102433:	55                   	push   %ebp
f0102434:	89 e5                	mov    %esp,%ebp
f0102436:	83 ec 08             	sub    $0x8,%esp
	memset(ptr_frame_info, 0, sizeof(*ptr_frame_info));
f0102439:	83 ec 04             	sub    $0x4,%esp
f010243c:	6a 0c                	push   $0xc
f010243e:	6a 00                	push   $0x0
f0102440:	ff 75 08             	pushl  0x8(%ebp)
f0102443:	e8 5d 23 00 00       	call   f01047a5 <memset>
f0102448:	83 c4 10             	add    $0x10,%esp
}
f010244b:	90                   	nop
f010244c:	c9                   	leave  
f010244d:	c3                   	ret    

f010244e <allocate_frame>:
//   E_NO_MEM -- otherwise
//
// Hint: use LIST_FIRST, LIST_REMOVE, and initialize_frame_info
// Hint: references should not be incremented
int allocate_frame(struct Frame_Info **ptr_frame_info)
{
f010244e:	55                   	push   %ebp
f010244f:	89 e5                	mov    %esp,%ebp
f0102451:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in	
	*ptr_frame_info = LIST_FIRST(&free_frame_list);
f0102454:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f010245a:	8b 45 08             	mov    0x8(%ebp),%eax
f010245d:	89 10                	mov    %edx,(%eax)
	if(*ptr_frame_info == NULL)
f010245f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102462:	8b 00                	mov    (%eax),%eax
f0102464:	85 c0                	test   %eax,%eax
f0102466:	75 07                	jne    f010246f <allocate_frame+0x21>
		return E_NO_MEM;
f0102468:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010246d:	eb 44                	jmp    f01024b3 <allocate_frame+0x65>
	
	LIST_REMOVE(*ptr_frame_info);
f010246f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102472:	8b 00                	mov    (%eax),%eax
f0102474:	8b 00                	mov    (%eax),%eax
f0102476:	85 c0                	test   %eax,%eax
f0102478:	74 12                	je     f010248c <allocate_frame+0x3e>
f010247a:	8b 45 08             	mov    0x8(%ebp),%eax
f010247d:	8b 00                	mov    (%eax),%eax
f010247f:	8b 00                	mov    (%eax),%eax
f0102481:	8b 55 08             	mov    0x8(%ebp),%edx
f0102484:	8b 12                	mov    (%edx),%edx
f0102486:	8b 52 04             	mov    0x4(%edx),%edx
f0102489:	89 50 04             	mov    %edx,0x4(%eax)
f010248c:	8b 45 08             	mov    0x8(%ebp),%eax
f010248f:	8b 00                	mov    (%eax),%eax
f0102491:	8b 40 04             	mov    0x4(%eax),%eax
f0102494:	8b 55 08             	mov    0x8(%ebp),%edx
f0102497:	8b 12                	mov    (%edx),%edx
f0102499:	8b 12                	mov    (%edx),%edx
f010249b:	89 10                	mov    %edx,(%eax)
	initialize_frame_info(*ptr_frame_info);
f010249d:	8b 45 08             	mov    0x8(%ebp),%eax
f01024a0:	8b 00                	mov    (%eax),%eax
f01024a2:	83 ec 0c             	sub    $0xc,%esp
f01024a5:	50                   	push   %eax
f01024a6:	e8 88 ff ff ff       	call   f0102433 <initialize_frame_info>
f01024ab:	83 c4 10             	add    $0x10,%esp
	return 0;
f01024ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01024b3:	c9                   	leave  
f01024b4:	c3                   	ret    

f01024b5 <free_frame>:
//
// Return a frame to the free_frame_list.
// (This function should only be called when ptr_frame_info->references reaches 0.)
//
void free_frame(struct Frame_Info *ptr_frame_info)
{
f01024b5:	55                   	push   %ebp
f01024b6:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	LIST_INSERT_HEAD(&free_frame_list, ptr_frame_info);
f01024b8:	8b 15 38 e7 14 f0    	mov    0xf014e738,%edx
f01024be:	8b 45 08             	mov    0x8(%ebp),%eax
f01024c1:	89 10                	mov    %edx,(%eax)
f01024c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01024c6:	8b 00                	mov    (%eax),%eax
f01024c8:	85 c0                	test   %eax,%eax
f01024ca:	74 0b                	je     f01024d7 <free_frame+0x22>
f01024cc:	a1 38 e7 14 f0       	mov    0xf014e738,%eax
f01024d1:	8b 55 08             	mov    0x8(%ebp),%edx
f01024d4:	89 50 04             	mov    %edx,0x4(%eax)
f01024d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01024da:	a3 38 e7 14 f0       	mov    %eax,0xf014e738
f01024df:	8b 45 08             	mov    0x8(%ebp),%eax
f01024e2:	c7 40 04 38 e7 14 f0 	movl   $0xf014e738,0x4(%eax)
}
f01024e9:	90                   	nop
f01024ea:	5d                   	pop    %ebp
f01024eb:	c3                   	ret    

f01024ec <decrement_references>:
//
// Decrement the reference count on a frame
// freeing it if there are no more references.
//
void decrement_references(struct Frame_Info* ptr_frame_info)
{
f01024ec:	55                   	push   %ebp
f01024ed:	89 e5                	mov    %esp,%ebp
	if (--(ptr_frame_info->references) == 0)
f01024ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01024f2:	8b 40 08             	mov    0x8(%eax),%eax
f01024f5:	48                   	dec    %eax
f01024f6:	8b 55 08             	mov    0x8(%ebp),%edx
f01024f9:	66 89 42 08          	mov    %ax,0x8(%edx)
f01024fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0102500:	8b 40 08             	mov    0x8(%eax),%eax
f0102503:	66 85 c0             	test   %ax,%ax
f0102506:	75 0b                	jne    f0102513 <decrement_references+0x27>
		free_frame(ptr_frame_info);
f0102508:	ff 75 08             	pushl  0x8(%ebp)
f010250b:	e8 a5 ff ff ff       	call   f01024b5 <free_frame>
f0102510:	83 c4 04             	add    $0x4,%esp
}
f0102513:	90                   	nop
f0102514:	c9                   	leave  
f0102515:	c3                   	ret    

f0102516 <get_page_table>:
//
// Hint: you can use "to_physical_address()" to turn a Frame_Info*
// into the physical address of the frame it refers to. 

int get_page_table(uint32 *ptr_page_directory, const void *virtual_address, int create, uint32 **ptr_page_table)
{
f0102516:	55                   	push   %ebp
f0102517:	89 e5                	mov    %esp,%ebp
f0102519:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	uint32 page_directory_entry = ptr_page_directory[PDX(virtual_address)];
f010251c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010251f:	c1 e8 16             	shr    $0x16,%eax
f0102522:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102529:	8b 45 08             	mov    0x8(%ebp),%eax
f010252c:	01 d0                	add    %edx,%eax
f010252e:	8b 00                	mov    (%eax),%eax
f0102530:	89 45 f4             	mov    %eax,-0xc(%ebp)

	*ptr_page_table = K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(page_directory_entry)) ;
f0102533:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102536:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010253b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010253e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102541:	c1 e8 0c             	shr    $0xc,%eax
f0102544:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102547:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f010254c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f010254f:	72 17                	jb     f0102568 <get_page_table+0x52>
f0102551:	ff 75 f0             	pushl  -0x10(%ebp)
f0102554:	68 58 5a 10 f0       	push   $0xf0105a58
f0102559:	68 79 01 00 00       	push   $0x179
f010255e:	68 41 5a 10 f0       	push   $0xf0105a41
f0102563:	e8 c6 db ff ff       	call   f010012e <_panic>
f0102568:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010256b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102570:	89 c2                	mov    %eax,%edx
f0102572:	8b 45 14             	mov    0x14(%ebp),%eax
f0102575:	89 10                	mov    %edx,(%eax)
	
	if (page_directory_entry == 0)
f0102577:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010257b:	0f 85 d3 00 00 00    	jne    f0102654 <get_page_table+0x13e>
	{
		if (create)
f0102581:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102585:	0f 84 b9 00 00 00    	je     f0102644 <get_page_table+0x12e>
		{
			struct Frame_Info* ptr_frame_info;
			int err = allocate_frame(&ptr_frame_info) ;
f010258b:	83 ec 0c             	sub    $0xc,%esp
f010258e:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0102591:	50                   	push   %eax
f0102592:	e8 b7 fe ff ff       	call   f010244e <allocate_frame>
f0102597:	83 c4 10             	add    $0x10,%esp
f010259a:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if(err == E_NO_MEM)
f010259d:	83 7d e8 fc          	cmpl   $0xfffffffc,-0x18(%ebp)
f01025a1:	75 13                	jne    f01025b6 <get_page_table+0xa0>
			{
				*ptr_page_table = 0;
f01025a3:	8b 45 14             	mov    0x14(%ebp),%eax
f01025a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
				return E_NO_MEM;
f01025ac:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01025b1:	e9 a3 00 00 00       	jmp    f0102659 <get_page_table+0x143>
			}

			uint32 phys_page_table = to_physical_address(ptr_frame_info);
f01025b6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01025b9:	83 ec 0c             	sub    $0xc,%esp
f01025bc:	50                   	push   %eax
f01025bd:	e8 e5 f7 ff ff       	call   f0101da7 <to_physical_address>
f01025c2:	83 c4 10             	add    $0x10,%esp
f01025c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table) ;
f01025c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01025cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01025ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01025d1:	c1 e8 0c             	shr    $0xc,%eax
f01025d4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01025d7:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f01025dc:	39 45 dc             	cmp    %eax,-0x24(%ebp)
f01025df:	72 17                	jb     f01025f8 <get_page_table+0xe2>
f01025e1:	ff 75 e0             	pushl  -0x20(%ebp)
f01025e4:	68 58 5a 10 f0       	push   $0xf0105a58
f01025e9:	68 88 01 00 00       	push   $0x188
f01025ee:	68 41 5a 10 f0       	push   $0xf0105a41
f01025f3:	e8 36 db ff ff       	call   f010012e <_panic>
f01025f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01025fb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102600:	89 c2                	mov    %eax,%edx
f0102602:	8b 45 14             	mov    0x14(%ebp),%eax
f0102605:	89 10                	mov    %edx,(%eax)
			
			//initialize new page table by 0's
			memset(*ptr_page_table , 0, PAGE_SIZE);
f0102607:	8b 45 14             	mov    0x14(%ebp),%eax
f010260a:	8b 00                	mov    (%eax),%eax
f010260c:	83 ec 04             	sub    $0x4,%esp
f010260f:	68 00 10 00 00       	push   $0x1000
f0102614:	6a 00                	push   $0x0
f0102616:	50                   	push   %eax
f0102617:	e8 89 21 00 00       	call   f01047a5 <memset>
f010261c:	83 c4 10             	add    $0x10,%esp

			ptr_frame_info->references = 1;
f010261f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102622:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
			ptr_page_directory[PDX(virtual_address)] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_USER | PERM_WRITEABLE);
f0102628:	8b 45 0c             	mov    0xc(%ebp),%eax
f010262b:	c1 e8 16             	shr    $0x16,%eax
f010262e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102635:	8b 45 08             	mov    0x8(%ebp),%eax
f0102638:	01 d0                	add    %edx,%eax
f010263a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010263d:	83 ca 07             	or     $0x7,%edx
f0102640:	89 10                	mov    %edx,(%eax)
f0102642:	eb 10                	jmp    f0102654 <get_page_table+0x13e>
		}
		else
		{
			*ptr_page_table = 0;
f0102644:	8b 45 14             	mov    0x14(%ebp),%eax
f0102647:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return 0;
f010264d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102652:	eb 05                	jmp    f0102659 <get_page_table+0x143>
		}
	}	
	return 0;
f0102654:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102659:	c9                   	leave  
f010265a:	c3                   	ret    

f010265b <map_frame>:
//   E_NO_MEM, if page table couldn't be allocated
//
// Hint: implement using get_page_table() and unmap_frame().
//
int map_frame(uint32 *ptr_page_directory, struct Frame_Info *ptr_frame_info, void *virtual_address, int perm)
{
f010265b:	55                   	push   %ebp
f010265c:	89 e5                	mov    %esp,%ebp
f010265e:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 physical_address = to_physical_address(ptr_frame_info);
f0102661:	ff 75 0c             	pushl  0xc(%ebp)
f0102664:	e8 3e f7 ff ff       	call   f0101da7 <to_physical_address>
f0102669:	83 c4 04             	add    $0x4,%esp
f010266c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 *ptr_page_table;
	if( get_page_table(ptr_page_directory, virtual_address, 1, &ptr_page_table) == 0)
f010266f:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102672:	50                   	push   %eax
f0102673:	6a 01                	push   $0x1
f0102675:	ff 75 10             	pushl  0x10(%ebp)
f0102678:	ff 75 08             	pushl  0x8(%ebp)
f010267b:	e8 96 fe ff ff       	call   f0102516 <get_page_table>
f0102680:	83 c4 10             	add    $0x10,%esp
f0102683:	85 c0                	test   %eax,%eax
f0102685:	75 71                	jne    f01026f8 <map_frame+0x9d>
	{
		uint32 page_table_entry = ptr_page_table[PTX(virtual_address)];
f0102687:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010268a:	8b 55 10             	mov    0x10(%ebp),%edx
f010268d:	c1 ea 0c             	shr    $0xc,%edx
f0102690:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102696:	c1 e2 02             	shl    $0x2,%edx
f0102699:	01 d0                	add    %edx,%eax
f010269b:	8b 00                	mov    (%eax),%eax
f010269d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		
		
		if( EXTRACT_ADDRESS(page_table_entry) != physical_address)
f01026a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01026a3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026a8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01026ab:	74 44                	je     f01026f1 <map_frame+0x96>
		{
			if( page_table_entry != 0)
f01026ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01026b1:	74 11                	je     f01026c4 <map_frame+0x69>
			{				
				unmap_frame(ptr_page_directory , virtual_address);
f01026b3:	83 ec 08             	sub    $0x8,%esp
f01026b6:	ff 75 10             	pushl  0x10(%ebp)
f01026b9:	ff 75 08             	pushl  0x8(%ebp)
f01026bc:	e8 ad 00 00 00       	call   f010276e <unmap_frame>
f01026c1:	83 c4 10             	add    $0x10,%esp
			}
			ptr_frame_info->references++;
f01026c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026c7:	8b 40 08             	mov    0x8(%eax),%eax
f01026ca:	40                   	inc    %eax
f01026cb:	8b 55 0c             	mov    0xc(%ebp),%edx
f01026ce:	66 89 42 08          	mov    %ax,0x8(%edx)
			ptr_page_table[PTX(virtual_address)] = CONSTRUCT_ENTRY(physical_address , perm | PERM_PRESENT);
f01026d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01026d5:	8b 55 10             	mov    0x10(%ebp),%edx
f01026d8:	c1 ea 0c             	shr    $0xc,%edx
f01026db:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01026e1:	c1 e2 02             	shl    $0x2,%edx
f01026e4:	01 c2                	add    %eax,%edx
f01026e6:	8b 45 14             	mov    0x14(%ebp),%eax
f01026e9:	0b 45 f4             	or     -0xc(%ebp),%eax
f01026ec:	83 c8 01             	or     $0x1,%eax
f01026ef:	89 02                	mov    %eax,(%edx)
			
		}		
		return 0;
f01026f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01026f6:	eb 05                	jmp    f01026fd <map_frame+0xa2>
	}	
	return E_NO_MEM;
f01026f8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f01026fd:	c9                   	leave  
f01026fe:	c3                   	ret    

f01026ff <get_frame_info>:
// Return 0 if there is no frame mapped at virtual_address.
//
// Hint: implement using get_page_table() and get_frame_info().
//
struct Frame_Info * get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table)
{
f01026ff:	55                   	push   %ebp
f0102700:	89 e5                	mov    %esp,%ebp
f0102702:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in	
	uint32 ret =  get_page_table(ptr_page_directory, virtual_address, 0, ptr_page_table) ;
f0102705:	ff 75 10             	pushl  0x10(%ebp)
f0102708:	6a 00                	push   $0x0
f010270a:	ff 75 0c             	pushl  0xc(%ebp)
f010270d:	ff 75 08             	pushl  0x8(%ebp)
f0102710:	e8 01 fe ff ff       	call   f0102516 <get_page_table>
f0102715:	83 c4 10             	add    $0x10,%esp
f0102718:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if((*ptr_page_table) != 0)
f010271b:	8b 45 10             	mov    0x10(%ebp),%eax
f010271e:	8b 00                	mov    (%eax),%eax
f0102720:	85 c0                	test   %eax,%eax
f0102722:	74 43                	je     f0102767 <get_frame_info+0x68>
	{	
		uint32 index_page_table = PTX(virtual_address);
f0102724:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102727:	c1 e8 0c             	shr    $0xc,%eax
f010272a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010272f:	89 45 f0             	mov    %eax,-0x10(%ebp)
		uint32 page_table_entry = (*ptr_page_table)[index_page_table];
f0102732:	8b 45 10             	mov    0x10(%ebp),%eax
f0102735:	8b 00                	mov    (%eax),%eax
f0102737:	8b 55 f0             	mov    -0x10(%ebp),%edx
f010273a:	c1 e2 02             	shl    $0x2,%edx
f010273d:	01 d0                	add    %edx,%eax
f010273f:	8b 00                	mov    (%eax),%eax
f0102741:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if( page_table_entry != 0)	
f0102744:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102748:	74 16                	je     f0102760 <get_frame_info+0x61>
			return to_frame_info( EXTRACT_ADDRESS ( page_table_entry ) );
f010274a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010274d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102752:	83 ec 0c             	sub    $0xc,%esp
f0102755:	50                   	push   %eax
f0102756:	e8 5f f6 ff ff       	call   f0101dba <to_frame_info>
f010275b:	83 c4 10             	add    $0x10,%esp
f010275e:	eb 0c                	jmp    f010276c <get_frame_info+0x6d>
		return 0;
f0102760:	b8 00 00 00 00       	mov    $0x0,%eax
f0102765:	eb 05                	jmp    f010276c <get_frame_info+0x6d>
	}
	return 0;
f0102767:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010276c:	c9                   	leave  
f010276d:	c3                   	ret    

f010276e <unmap_frame>:
//
// Hint: implement using get_frame_info(),
// 	tlb_invalidate(), and decrement_references().
//
void unmap_frame(uint32 *ptr_page_directory, void *virtual_address)
{
f010276e:	55                   	push   %ebp
f010276f:	89 e5                	mov    %esp,%ebp
f0102771:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 *ptr_page_table;
	struct Frame_Info* ptr_frame_info = get_frame_info(ptr_page_directory, virtual_address, &ptr_page_table);
f0102774:	83 ec 04             	sub    $0x4,%esp
f0102777:	8d 45 f0             	lea    -0x10(%ebp),%eax
f010277a:	50                   	push   %eax
f010277b:	ff 75 0c             	pushl  0xc(%ebp)
f010277e:	ff 75 08             	pushl  0x8(%ebp)
f0102781:	e8 79 ff ff ff       	call   f01026ff <get_frame_info>
f0102786:	83 c4 10             	add    $0x10,%esp
f0102789:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if( ptr_frame_info != 0 )
f010278c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102790:	74 39                	je     f01027cb <unmap_frame+0x5d>
	{
		decrement_references(ptr_frame_info);
f0102792:	83 ec 0c             	sub    $0xc,%esp
f0102795:	ff 75 f4             	pushl  -0xc(%ebp)
f0102798:	e8 4f fd ff ff       	call   f01024ec <decrement_references>
f010279d:	83 c4 10             	add    $0x10,%esp
		ptr_page_table[PTX(virtual_address)] = 0;
f01027a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01027a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01027a6:	c1 ea 0c             	shr    $0xc,%edx
f01027a9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01027af:	c1 e2 02             	shl    $0x2,%edx
f01027b2:	01 d0                	add    %edx,%eax
f01027b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(ptr_page_directory, virtual_address);
f01027ba:	83 ec 08             	sub    $0x8,%esp
f01027bd:	ff 75 0c             	pushl  0xc(%ebp)
f01027c0:	ff 75 08             	pushl  0x8(%ebp)
f01027c3:	e8 64 eb ff ff       	call   f010132c <tlb_invalidate>
f01027c8:	83 c4 10             	add    $0x10,%esp
	}	
}
f01027cb:	90                   	nop
f01027cc:	c9                   	leave  
f01027cd:	c3                   	ret    

f01027ce <get_page>:
//		or to allocate any necessary page tables.
// 	HINT: 	remember to free the allocated frame if there is no space 
//		for the necessary page tables

int get_page(uint32* ptr_page_directory, void *virtual_address, int perm)
{
f01027ce:	55                   	push   %ebp
f01027cf:	89 e5                	mov    %esp,%ebp
f01027d1:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("get_page function is not completed yet") ;
f01027d4:	83 ec 04             	sub    $0x4,%esp
f01027d7:	68 88 5a 10 f0       	push   $0xf0105a88
f01027dc:	68 12 02 00 00       	push   $0x212
f01027e1:	68 41 5a 10 f0       	push   $0xf0105a41
f01027e6:	e8 43 d9 ff ff       	call   f010012e <_panic>

f01027eb <calculate_required_frames>:
	return 0 ;
}

//[2] calculate_required_frames: 
uint32 calculate_required_frames(uint32* ptr_page_directory, uint32 start_virtual_address, uint32 size)
{
f01027eb:	55                   	push   %ebp
f01027ec:	89 e5                	mov    %esp,%ebp
f01027ee:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("calculate_required_frames function is not completed yet") ;
f01027f1:	83 ec 04             	sub    $0x4,%esp
f01027f4:	68 b0 5a 10 f0       	push   $0xf0105ab0
f01027f9:	68 29 02 00 00       	push   $0x229
f01027fe:	68 41 5a 10 f0       	push   $0xf0105a41
f0102803:	e8 26 d9 ff ff       	call   f010012e <_panic>

f0102808 <calculate_free_frames>:


//[3] calculate_free_frames:

uint32 calculate_free_frames()
{
f0102808:	55                   	push   %ebp
f0102809:	89 e5                	mov    %esp,%ebp
f010280b:	83 ec 10             	sub    $0x10,%esp
	// PROJECT 2008: Your code here.
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
f010280e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	LIST_FOREACH(ptr, &free_frame_list)
f0102815:	a1 38 e7 14 f0       	mov    0xf014e738,%eax
f010281a:	89 45 fc             	mov    %eax,-0x4(%ebp)
f010281d:	eb 0b                	jmp    f010282a <calculate_free_frames+0x22>
	{
		cnt++ ;
f010281f:	ff 45 f8             	incl   -0x8(%ebp)
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
	LIST_FOREACH(ptr, &free_frame_list)
f0102822:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0102825:	8b 00                	mov    (%eax),%eax
f0102827:	89 45 fc             	mov    %eax,-0x4(%ebp)
f010282a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f010282e:	75 ef                	jne    f010281f <calculate_free_frames+0x17>
	{
		cnt++ ;
	}
	return cnt;
f0102830:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0102833:	c9                   	leave  
f0102834:	c3                   	ret    

f0102835 <freeMem>:
//	Steps:
//		1) Unmap all mapped pages in the range [virtual_address, virtual_address + size ]
//		2) Free all mapped page tables in this range

void freeMem(uint32* ptr_page_directory, void *virtual_address, uint32 size)
{
f0102835:	55                   	push   %ebp
f0102836:	89 e5                	mov    %esp,%ebp
f0102838:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("freeMem function is not completed yet") ;
f010283b:	83 ec 04             	sub    $0x4,%esp
f010283e:	68 e8 5a 10 f0       	push   $0xf0105ae8
f0102843:	68 50 02 00 00       	push   $0x250
f0102848:	68 41 5a 10 f0       	push   $0xf0105a41
f010284d:	e8 dc d8 ff ff       	call   f010012e <_panic>

f0102852 <allocate_environment>:
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	E_NO_FREE_ENV if all NENVS environments are allocated
//
int allocate_environment(struct Env** e)
{	
f0102852:	55                   	push   %ebp
f0102853:	89 e5                	mov    %esp,%ebp
	if (!(*e = LIST_FIRST(&env_free_list)))
f0102855:	8b 15 b4 de 14 f0    	mov    0xf014deb4,%edx
f010285b:	8b 45 08             	mov    0x8(%ebp),%eax
f010285e:	89 10                	mov    %edx,(%eax)
f0102860:	8b 45 08             	mov    0x8(%ebp),%eax
f0102863:	8b 00                	mov    (%eax),%eax
f0102865:	85 c0                	test   %eax,%eax
f0102867:	75 07                	jne    f0102870 <allocate_environment+0x1e>
		return E_NO_FREE_ENV;
f0102869:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010286e:	eb 05                	jmp    f0102875 <allocate_environment+0x23>
	return 0;
f0102870:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102875:	5d                   	pop    %ebp
f0102876:	c3                   	ret    

f0102877 <free_environment>:

// Free the given environment "e", simply by adding it to the free environment list.
void free_environment(struct Env* e)
{
f0102877:	55                   	push   %ebp
f0102878:	89 e5                	mov    %esp,%ebp
	curenv = NULL;	
f010287a:	c7 05 b0 de 14 f0 00 	movl   $0x0,0xf014deb0
f0102881:	00 00 00 
	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102884:	8b 45 08             	mov    0x8(%ebp),%eax
f0102887:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	LIST_INSERT_HEAD(&env_free_list, e);
f010288e:	8b 15 b4 de 14 f0    	mov    0xf014deb4,%edx
f0102894:	8b 45 08             	mov    0x8(%ebp),%eax
f0102897:	89 50 44             	mov    %edx,0x44(%eax)
f010289a:	8b 45 08             	mov    0x8(%ebp),%eax
f010289d:	8b 40 44             	mov    0x44(%eax),%eax
f01028a0:	85 c0                	test   %eax,%eax
f01028a2:	74 0e                	je     f01028b2 <free_environment+0x3b>
f01028a4:	a1 b4 de 14 f0       	mov    0xf014deb4,%eax
f01028a9:	8b 55 08             	mov    0x8(%ebp),%edx
f01028ac:	83 c2 44             	add    $0x44,%edx
f01028af:	89 50 48             	mov    %edx,0x48(%eax)
f01028b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01028b5:	a3 b4 de 14 f0       	mov    %eax,0xf014deb4
f01028ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01028bd:	c7 40 48 b4 de 14 f0 	movl   $0xf014deb4,0x48(%eax)
}
f01028c4:	90                   	nop
f01028c5:	5d                   	pop    %ebp
f01028c6:	c3                   	ret    

f01028c7 <initialize_environment>:
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
void initialize_environment(struct Env* e, uint32* ptr_user_page_directory)
{	
f01028c7:	55                   	push   %ebp
f01028c8:	89 e5                	mov    %esp,%ebp
f01028ca:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("initialize_environment function is not completed yet") ;
f01028cd:	83 ec 04             	sub    $0x4,%esp
f01028d0:	68 6c 5b 10 f0       	push   $0xf0105b6c
f01028d5:	6a 77                	push   $0x77
f01028d7:	68 a1 5b 10 f0       	push   $0xf0105ba1
f01028dc:	e8 4d d8 ff ff       	call   f010012e <_panic>

f01028e1 <program_segment_alloc_map>:
//
// if the allocation failed, return E_NO_MEM 
// otherwise return 0
//
static int program_segment_alloc_map(struct Env *e, void *va, uint32 length)
{
f01028e1:	55                   	push   %ebp
f01028e2:	89 e5                	mov    %esp,%ebp
f01028e4:	83 ec 08             	sub    $0x8,%esp
	//PROJECT 2008: Your code here.	
	panic("program_segment_alloc_map function is not completed yet") ;
f01028e7:	83 ec 04             	sub    $0x4,%esp
f01028ea:	68 bc 5b 10 f0       	push   $0xf0105bbc
f01028ef:	68 8e 00 00 00       	push   $0x8e
f01028f4:	68 a1 5b 10 f0       	push   $0xf0105ba1
f01028f9:	e8 30 d8 ff ff       	call   f010012e <_panic>

f01028fe <env_create>:
}

//
// Allocates a new env and loads the named user program into it.
struct UserProgramInfo* env_create(char* user_program_name)
{
f01028fe:	55                   	push   %ebp
f01028ff:	89 e5                	mov    %esp,%ebp
f0102901:	83 ec 28             	sub    $0x28,%esp
	// PROJECT 2008: Your code here.
	panic("env_create function is not completed yet") ;
f0102904:	83 ec 04             	sub    $0x4,%esp
f0102907:	68 f4 5b 10 f0       	push   $0xf0105bf4
f010290c:	68 99 00 00 00       	push   $0x99
f0102911:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102916:	e8 13 d8 ff ff       	call   f010012e <_panic>

f010291b <env_run>:
// Used to run the given environment "e", simply by 
// context switch from curenv to env e.
//  (This function does not return.)
//
void env_run(struct Env *e)
{
f010291b:	55                   	push   %ebp
f010291c:	89 e5                	mov    %esp,%ebp
f010291e:	83 ec 18             	sub    $0x18,%esp
	if(curenv != e)
f0102921:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102926:	3b 45 08             	cmp    0x8(%ebp),%eax
f0102929:	74 25                	je     f0102950 <env_run+0x35>
	{		
		curenv = e ;
f010292b:	8b 45 08             	mov    0x8(%ebp),%eax
f010292e:	a3 b0 de 14 f0       	mov    %eax,0xf014deb0
		curenv->env_runs++ ;
f0102933:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102938:	8b 50 58             	mov    0x58(%eax),%edx
f010293b:	42                   	inc    %edx
f010293c:	89 50 58             	mov    %edx,0x58(%eax)
		lcr3(curenv->env_cr3) ;	
f010293f:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102944:	8b 40 60             	mov    0x60(%eax),%eax
f0102947:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010294a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010294d:	0f 22 d8             	mov    %eax,%cr3
	}	
	env_pop_tf(&(curenv->env_tf));
f0102950:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102955:	83 ec 0c             	sub    $0xc,%esp
f0102958:	50                   	push   %eax
f0102959:	e8 89 06 00 00       	call   f0102fe7 <env_pop_tf>

f010295e <env_free>:

//
// Frees environment "e" and all memory it uses.
// 
void env_free(struct Env *e)
{
f010295e:	55                   	push   %ebp
f010295f:	89 e5                	mov    %esp,%ebp
f0102961:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("env_free function is not completed yet") ;
f0102964:	83 ec 04             	sub    $0x4,%esp
f0102967:	68 20 5c 10 f0       	push   $0xf0105c20
f010296c:	68 ef 00 00 00       	push   $0xef
f0102971:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102976:	e8 b3 d7 ff ff       	call   f010012e <_panic>

f010297b <env_init>:
// Insert in reverse order, so that the first call to allocate_environment()
// returns envs[0].
//
void
env_init(void)
{	
f010297b:	55                   	push   %ebp
f010297c:	89 e5                	mov    %esp,%ebp
f010297e:	53                   	push   %ebx
f010297f:	83 ec 10             	sub    $0x10,%esp
	int iEnv = NENV-1;
f0102982:	c7 45 f8 ff 03 00 00 	movl   $0x3ff,-0x8(%ebp)
	for(; iEnv >= 0; iEnv--)
f0102989:	e9 ed 00 00 00       	jmp    f0102a7b <env_init+0x100>
	{
		envs[iEnv].env_status = ENV_FREE;
f010298e:	8b 0d ac de 14 f0    	mov    0xf014deac,%ecx
f0102994:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102997:	89 d0                	mov    %edx,%eax
f0102999:	c1 e0 02             	shl    $0x2,%eax
f010299c:	01 d0                	add    %edx,%eax
f010299e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01029a5:	01 d0                	add    %edx,%eax
f01029a7:	c1 e0 02             	shl    $0x2,%eax
f01029aa:	01 c8                	add    %ecx,%eax
f01029ac:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[iEnv].env_id = 0;
f01029b3:	8b 0d ac de 14 f0    	mov    0xf014deac,%ecx
f01029b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01029bc:	89 d0                	mov    %edx,%eax
f01029be:	c1 e0 02             	shl    $0x2,%eax
f01029c1:	01 d0                	add    %edx,%eax
f01029c3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01029ca:	01 d0                	add    %edx,%eax
f01029cc:	c1 e0 02             	shl    $0x2,%eax
f01029cf:	01 c8                	add    %ecx,%eax
f01029d1:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
f01029d8:	8b 0d ac de 14 f0    	mov    0xf014deac,%ecx
f01029de:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01029e1:	89 d0                	mov    %edx,%eax
f01029e3:	c1 e0 02             	shl    $0x2,%eax
f01029e6:	01 d0                	add    %edx,%eax
f01029e8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01029ef:	01 d0                	add    %edx,%eax
f01029f1:	c1 e0 02             	shl    $0x2,%eax
f01029f4:	01 c8                	add    %ecx,%eax
f01029f6:	8b 15 b4 de 14 f0    	mov    0xf014deb4,%edx
f01029fc:	89 50 44             	mov    %edx,0x44(%eax)
f01029ff:	8b 40 44             	mov    0x44(%eax),%eax
f0102a02:	85 c0                	test   %eax,%eax
f0102a04:	74 2a                	je     f0102a30 <env_init+0xb5>
f0102a06:	8b 15 b4 de 14 f0    	mov    0xf014deb4,%edx
f0102a0c:	8b 1d ac de 14 f0    	mov    0xf014deac,%ebx
f0102a12:	8b 4d f8             	mov    -0x8(%ebp),%ecx
f0102a15:	89 c8                	mov    %ecx,%eax
f0102a17:	c1 e0 02             	shl    $0x2,%eax
f0102a1a:	01 c8                	add    %ecx,%eax
f0102a1c:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f0102a23:	01 c8                	add    %ecx,%eax
f0102a25:	c1 e0 02             	shl    $0x2,%eax
f0102a28:	01 d8                	add    %ebx,%eax
f0102a2a:	83 c0 44             	add    $0x44,%eax
f0102a2d:	89 42 48             	mov    %eax,0x48(%edx)
f0102a30:	8b 0d ac de 14 f0    	mov    0xf014deac,%ecx
f0102a36:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102a39:	89 d0                	mov    %edx,%eax
f0102a3b:	c1 e0 02             	shl    $0x2,%eax
f0102a3e:	01 d0                	add    %edx,%eax
f0102a40:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102a47:	01 d0                	add    %edx,%eax
f0102a49:	c1 e0 02             	shl    $0x2,%eax
f0102a4c:	01 c8                	add    %ecx,%eax
f0102a4e:	a3 b4 de 14 f0       	mov    %eax,0xf014deb4
f0102a53:	8b 0d ac de 14 f0    	mov    0xf014deac,%ecx
f0102a59:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102a5c:	89 d0                	mov    %edx,%eax
f0102a5e:	c1 e0 02             	shl    $0x2,%eax
f0102a61:	01 d0                	add    %edx,%eax
f0102a63:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102a6a:	01 d0                	add    %edx,%eax
f0102a6c:	c1 e0 02             	shl    $0x2,%eax
f0102a6f:	01 c8                	add    %ecx,%eax
f0102a71:	c7 40 48 b4 de 14 f0 	movl   $0xf014deb4,0x48(%eax)
//
void
env_init(void)
{	
	int iEnv = NENV-1;
	for(; iEnv >= 0; iEnv--)
f0102a78:	ff 4d f8             	decl   -0x8(%ebp)
f0102a7b:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f0102a7f:	0f 89 09 ff ff ff    	jns    f010298e <env_init+0x13>
	{
		envs[iEnv].env_status = ENV_FREE;
		envs[iEnv].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
	}
}
f0102a85:	90                   	nop
f0102a86:	83 c4 10             	add    $0x10,%esp
f0102a89:	5b                   	pop    %ebx
f0102a8a:	5d                   	pop    %ebp
f0102a8b:	c3                   	ret    

f0102a8c <complete_environment_initialization>:

void complete_environment_initialization(struct Env* e)
{	
f0102a8c:	55                   	push   %ebp
f0102a8d:	89 e5                	mov    %esp,%ebp
f0102a8f:	83 ec 18             	sub    $0x18,%esp
	//VPT and UVPT map the env's own page table, with
	//different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PERM_PRESENT | PERM_WRITEABLE;
f0102a92:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a95:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102a98:	8d 90 fc 0e 00 00    	lea    0xefc(%eax),%edx
f0102a9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aa1:	8b 40 60             	mov    0x60(%eax),%eax
f0102aa4:	83 c8 03             	or     $0x3,%eax
f0102aa7:	89 02                	mov    %eax,(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PERM_PRESENT | PERM_USER;
f0102aa9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102aac:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102aaf:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0102ab5:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ab8:	8b 40 60             	mov    0x60(%eax),%eax
f0102abb:	83 c8 05             	or     $0x5,%eax
f0102abe:	89 02                	mov    %eax,(%edx)
	
	int32 generation;	
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ac0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ac3:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102ac6:	05 00 10 00 00       	add    $0x1000,%eax
f0102acb:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102ad0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f0102ad3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102ad7:	7f 07                	jg     f0102ae0 <complete_environment_initialization+0x54>
		generation = 1 << ENVGENSHIFT;
f0102ad9:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f0102ae0:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ae3:	8b 15 ac de 14 f0    	mov    0xf014deac,%edx
f0102ae9:	29 d0                	sub    %edx,%eax
f0102aeb:	c1 f8 02             	sar    $0x2,%eax
f0102aee:	89 c1                	mov    %eax,%ecx
f0102af0:	89 c8                	mov    %ecx,%eax
f0102af2:	c1 e0 02             	shl    $0x2,%eax
f0102af5:	01 c8                	add    %ecx,%eax
f0102af7:	c1 e0 07             	shl    $0x7,%eax
f0102afa:	29 c8                	sub    %ecx,%eax
f0102afc:	c1 e0 03             	shl    $0x3,%eax
f0102aff:	01 c8                	add    %ecx,%eax
f0102b01:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102b08:	01 d0                	add    %edx,%eax
f0102b0a:	c1 e0 02             	shl    $0x2,%eax
f0102b0d:	01 c8                	add    %ecx,%eax
f0102b0f:	c1 e0 03             	shl    $0x3,%eax
f0102b12:	01 c8                	add    %ecx,%eax
f0102b14:	89 c2                	mov    %eax,%edx
f0102b16:	c1 e2 06             	shl    $0x6,%edx
f0102b19:	29 c2                	sub    %eax,%edx
f0102b1b:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102b1e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f0102b21:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
f0102b28:	01 c2                	add    %eax,%edx
f0102b2a:	8d 04 12             	lea    (%edx,%edx,1),%eax
f0102b2d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f0102b30:	89 d0                	mov    %edx,%eax
f0102b32:	f7 d8                	neg    %eax
f0102b34:	0b 45 f4             	or     -0xc(%ebp),%eax
f0102b37:	89 c2                	mov    %eax,%edx
f0102b39:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b3c:	89 50 4c             	mov    %edx,0x4c(%eax)
	
	// Set the basic status variables.
	e->env_parent_id = 0;//parent_id;
f0102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b42:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f0102b49:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b4c:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
	e->env_runs = 0;
f0102b53:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b56:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102b5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b60:	83 ec 04             	sub    $0x4,%esp
f0102b63:	6a 44                	push   $0x44
f0102b65:	6a 00                	push   $0x0
f0102b67:	50                   	push   %eax
f0102b68:	e8 38 1c 00 00       	call   f01047a5 <memset>
f0102b6d:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	e->env_tf.tf_ds = GD_UD | 3;
f0102b70:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b73:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f0102b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b7c:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0102b82:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b85:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102b8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b8e:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0102b95:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b98:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e);	
f0102b9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ba1:	8b 40 44             	mov    0x44(%eax),%eax
f0102ba4:	85 c0                	test   %eax,%eax
f0102ba6:	74 0f                	je     f0102bb7 <complete_environment_initialization+0x12b>
f0102ba8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bab:	8b 40 44             	mov    0x44(%eax),%eax
f0102bae:	8b 55 08             	mov    0x8(%ebp),%edx
f0102bb1:	8b 52 48             	mov    0x48(%edx),%edx
f0102bb4:	89 50 48             	mov    %edx,0x48(%eax)
f0102bb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bba:	8b 40 48             	mov    0x48(%eax),%eax
f0102bbd:	8b 55 08             	mov    0x8(%ebp),%edx
f0102bc0:	8b 52 44             	mov    0x44(%edx),%edx
f0102bc3:	89 10                	mov    %edx,(%eax)
	return ;
f0102bc5:	90                   	nop
}
f0102bc6:	c9                   	leave  
f0102bc7:	c3                   	ret    

f0102bc8 <PROGRAM_SEGMENT_NEXT>:

struct ProgramSegment* PROGRAM_SEGMENT_NEXT(struct ProgramSegment* seg, uint8* ptr_program_start)
{
f0102bc8:	55                   	push   %ebp
f0102bc9:	89 e5                	mov    %esp,%ebp
f0102bcb:	83 ec 18             	sub    $0x18,%esp
	int index = (*seg).segment_id++;
f0102bce:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bd1:	8b 40 10             	mov    0x10(%eax),%eax
f0102bd4:	8d 48 01             	lea    0x1(%eax),%ecx
f0102bd7:	8b 55 08             	mov    0x8(%ebp),%edx
f0102bda:	89 4a 10             	mov    %ecx,0x10(%edx)
f0102bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102be0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102be3:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102be9:	8b 00                	mov    (%eax),%eax
f0102beb:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102bf0:	74 17                	je     f0102c09 <PROGRAM_SEGMENT_NEXT+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102bf2:	83 ec 04             	sub    $0x4,%esp
f0102bf5:	68 47 5c 10 f0       	push   $0xf0105c47
f0102bfa:	68 48 01 00 00       	push   $0x148
f0102bff:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102c04:	e8 25 d5 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c0c:	8b 50 1c             	mov    0x1c(%eax),%edx
f0102c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c12:	01 d0                	add    %edx,%eax
f0102c14:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (ph[(*seg).segment_id].p_type != ELF_PROG_LOAD && ((*seg).segment_id < pELFHDR->e_phnum)) (*seg).segment_id++;	
f0102c17:	eb 0f                	jmp    f0102c28 <PROGRAM_SEGMENT_NEXT+0x60>
f0102c19:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c1c:	8b 40 10             	mov    0x10(%eax),%eax
f0102c1f:	8d 50 01             	lea    0x1(%eax),%edx
f0102c22:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c25:	89 50 10             	mov    %edx,0x10(%eax)
f0102c28:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c2b:	8b 40 10             	mov    0x10(%eax),%eax
f0102c2e:	c1 e0 05             	shl    $0x5,%eax
f0102c31:	89 c2                	mov    %eax,%edx
f0102c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c36:	01 d0                	add    %edx,%eax
f0102c38:	8b 00                	mov    (%eax),%eax
f0102c3a:	83 f8 01             	cmp    $0x1,%eax
f0102c3d:	74 13                	je     f0102c52 <PROGRAM_SEGMENT_NEXT+0x8a>
f0102c3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c42:	8b 50 10             	mov    0x10(%eax),%edx
f0102c45:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c48:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102c4b:	0f b7 c0             	movzwl %ax,%eax
f0102c4e:	39 c2                	cmp    %eax,%edx
f0102c50:	72 c7                	jb     f0102c19 <PROGRAM_SEGMENT_NEXT+0x51>
	index = (*seg).segment_id;
f0102c52:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c55:	8b 40 10             	mov    0x10(%eax),%eax
f0102c58:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(index < pELFHDR->e_phnum)
f0102c5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c5e:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102c61:	0f b7 c0             	movzwl %ax,%eax
f0102c64:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102c67:	7e 63                	jle    f0102ccc <PROGRAM_SEGMENT_NEXT+0x104>
	{
		(*seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f0102c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c6c:	c1 e0 05             	shl    $0x5,%eax
f0102c6f:	89 c2                	mov    %eax,%edx
f0102c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c74:	01 d0                	add    %edx,%eax
f0102c76:	8b 50 04             	mov    0x4(%eax),%edx
f0102c79:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c7c:	01 c2                	add    %eax,%edx
f0102c7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c81:	89 10                	mov    %edx,(%eax)
		(*seg).size_in_memory =  ph[index].p_memsz;
f0102c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c86:	c1 e0 05             	shl    $0x5,%eax
f0102c89:	89 c2                	mov    %eax,%edx
f0102c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c8e:	01 d0                	add    %edx,%eax
f0102c90:	8b 50 14             	mov    0x14(%eax),%edx
f0102c93:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c96:	89 50 08             	mov    %edx,0x8(%eax)
		(*seg).size_in_file = ph[index].p_filesz;
f0102c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c9c:	c1 e0 05             	shl    $0x5,%eax
f0102c9f:	89 c2                	mov    %eax,%edx
f0102ca1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ca4:	01 d0                	add    %edx,%eax
f0102ca6:	8b 50 10             	mov    0x10(%eax),%edx
f0102ca9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cac:	89 50 04             	mov    %edx,0x4(%eax)
		(*seg).virtual_address = (uint8*)ph[index].p_va;
f0102caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cb2:	c1 e0 05             	shl    $0x5,%eax
f0102cb5:	89 c2                	mov    %eax,%edx
f0102cb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102cba:	01 d0                	add    %edx,%eax
f0102cbc:	8b 40 08             	mov    0x8(%eax),%eax
f0102cbf:	89 c2                	mov    %eax,%edx
f0102cc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cc4:	89 50 0c             	mov    %edx,0xc(%eax)
		return seg;
f0102cc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cca:	eb 05                	jmp    f0102cd1 <PROGRAM_SEGMENT_NEXT+0x109>
	}
	return 0;
f0102ccc:	b8 00 00 00 00       	mov    $0x0,%eax
}	
f0102cd1:	c9                   	leave  
f0102cd2:	c3                   	ret    

f0102cd3 <PROGRAM_SEGMENT_FIRST>:

struct ProgramSegment PROGRAM_SEGMENT_FIRST( uint8* ptr_program_start)
{
f0102cd3:	55                   	push   %ebp
f0102cd4:	89 e5                	mov    %esp,%ebp
f0102cd6:	57                   	push   %edi
f0102cd7:	56                   	push   %esi
f0102cd8:	53                   	push   %ebx
f0102cd9:	83 ec 2c             	sub    $0x2c,%esp
	struct ProgramSegment seg;
	seg.segment_id = 0;
f0102cdc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ce6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102ce9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cec:	8b 00                	mov    (%eax),%eax
f0102cee:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102cf3:	74 17                	je     f0102d0c <PROGRAM_SEGMENT_FIRST+0x39>
		panic("Matafa2nash 3ala Keda"); 
f0102cf5:	83 ec 04             	sub    $0x4,%esp
f0102cf8:	68 47 5c 10 f0       	push   $0xf0105c47
f0102cfd:	68 61 01 00 00       	push   $0x161
f0102d02:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102d07:	e8 22 d4 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102d0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d0f:	8b 50 1c             	mov    0x1c(%eax),%edx
f0102d12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d15:	01 d0                	add    %edx,%eax
f0102d17:	89 45 e0             	mov    %eax,-0x20(%ebp)
	while (ph[(seg).segment_id].p_type != ELF_PROG_LOAD && ((seg).segment_id < pELFHDR->e_phnum)) (seg).segment_id++;
f0102d1a:	eb 07                	jmp    f0102d23 <PROGRAM_SEGMENT_FIRST+0x50>
f0102d1c:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d1f:	40                   	inc    %eax
f0102d20:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d23:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d26:	c1 e0 05             	shl    $0x5,%eax
f0102d29:	89 c2                	mov    %eax,%edx
f0102d2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d2e:	01 d0                	add    %edx,%eax
f0102d30:	8b 00                	mov    (%eax),%eax
f0102d32:	83 f8 01             	cmp    $0x1,%eax
f0102d35:	74 10                	je     f0102d47 <PROGRAM_SEGMENT_FIRST+0x74>
f0102d37:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d3d:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102d40:	0f b7 c0             	movzwl %ax,%eax
f0102d43:	39 c2                	cmp    %eax,%edx
f0102d45:	72 d5                	jb     f0102d1c <PROGRAM_SEGMENT_FIRST+0x49>
	int index = (seg).segment_id;
f0102d47:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102d4a:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if(index < pELFHDR->e_phnum)
f0102d4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d50:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102d53:	0f b7 c0             	movzwl %ax,%eax
f0102d56:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f0102d59:	7e 68                	jle    f0102dc3 <PROGRAM_SEGMENT_FIRST+0xf0>
	{	
		(seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f0102d5b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d5e:	c1 e0 05             	shl    $0x5,%eax
f0102d61:	89 c2                	mov    %eax,%edx
f0102d63:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d66:	01 d0                	add    %edx,%eax
f0102d68:	8b 50 04             	mov    0x4(%eax),%edx
f0102d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d6e:	01 d0                	add    %edx,%eax
f0102d70:	89 45 c8             	mov    %eax,-0x38(%ebp)
		(seg).size_in_memory =  ph[index].p_memsz;
f0102d73:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d76:	c1 e0 05             	shl    $0x5,%eax
f0102d79:	89 c2                	mov    %eax,%edx
f0102d7b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d7e:	01 d0                	add    %edx,%eax
f0102d80:	8b 40 14             	mov    0x14(%eax),%eax
f0102d83:	89 45 d0             	mov    %eax,-0x30(%ebp)
		(seg).size_in_file = ph[index].p_filesz;
f0102d86:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d89:	c1 e0 05             	shl    $0x5,%eax
f0102d8c:	89 c2                	mov    %eax,%edx
f0102d8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102d91:	01 d0                	add    %edx,%eax
f0102d93:	8b 40 10             	mov    0x10(%eax),%eax
f0102d96:	89 45 cc             	mov    %eax,-0x34(%ebp)
		(seg).virtual_address = (uint8*)ph[index].p_va;
f0102d99:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102d9c:	c1 e0 05             	shl    $0x5,%eax
f0102d9f:	89 c2                	mov    %eax,%edx
f0102da1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102da4:	01 d0                	add    %edx,%eax
f0102da6:	8b 40 08             	mov    0x8(%eax),%eax
f0102da9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		return seg;
f0102dac:	8b 45 08             	mov    0x8(%ebp),%eax
f0102daf:	89 c3                	mov    %eax,%ebx
f0102db1:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102db4:	ba 05 00 00 00       	mov    $0x5,%edx
f0102db9:	89 df                	mov    %ebx,%edi
f0102dbb:	89 c6                	mov    %eax,%esi
f0102dbd:	89 d1                	mov    %edx,%ecx
f0102dbf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102dc1:	eb 1c                	jmp    f0102ddf <PROGRAM_SEGMENT_FIRST+0x10c>
	}
	seg.segment_id = -1;
f0102dc3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
	return seg;
f0102dca:	8b 45 08             	mov    0x8(%ebp),%eax
f0102dcd:	89 c3                	mov    %eax,%ebx
f0102dcf:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102dd2:	ba 05 00 00 00       	mov    $0x5,%edx
f0102dd7:	89 df                	mov    %ebx,%edi
f0102dd9:	89 c6                	mov    %eax,%esi
f0102ddb:	89 d1                	mov    %edx,%ecx
f0102ddd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}
f0102ddf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102de5:	5b                   	pop    %ebx
f0102de6:	5e                   	pop    %esi
f0102de7:	5f                   	pop    %edi
f0102de8:	5d                   	pop    %ebp
f0102de9:	c2 04 00             	ret    $0x4

f0102dec <get_user_program_info>:

struct UserProgramInfo* get_user_program_info(char* user_program_name)
{
f0102dec:	55                   	push   %ebp
f0102ded:	89 e5                	mov    %esp,%ebp
f0102def:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102df2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102df9:	eb 23                	jmp    f0102e1e <get_user_program_info+0x32>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
f0102dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102dfe:	c1 e0 04             	shl    $0x4,%eax
f0102e01:	05 00 b6 11 f0       	add    $0xf011b600,%eax
f0102e06:	8b 00                	mov    (%eax),%eax
f0102e08:	83 ec 08             	sub    $0x8,%esp
f0102e0b:	50                   	push   %eax
f0102e0c:	ff 75 08             	pushl  0x8(%ebp)
f0102e0f:	e8 af 18 00 00       	call   f01046c3 <strcmp>
f0102e14:	83 c4 10             	add    $0x10,%esp
f0102e17:	85 c0                	test   %eax,%eax
f0102e19:	74 0f                	je     f0102e2a <get_user_program_info+0x3e>
}

struct UserProgramInfo* get_user_program_info(char* user_program_name)
{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102e1b:	ff 45 f4             	incl   -0xc(%ebp)
f0102e1e:	a1 54 b6 11 f0       	mov    0xf011b654,%eax
f0102e23:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102e26:	7c d3                	jl     f0102dfb <get_user_program_info+0xf>
f0102e28:	eb 01                	jmp    f0102e2b <get_user_program_info+0x3f>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
			break;
f0102e2a:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102e2b:	a1 54 b6 11 f0       	mov    0xf011b654,%eax
f0102e30:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102e33:	75 1a                	jne    f0102e4f <get_user_program_info+0x63>
	{
		cprintf("Unknown user program '%s'\n", user_program_name);
f0102e35:	83 ec 08             	sub    $0x8,%esp
f0102e38:	ff 75 08             	pushl  0x8(%ebp)
f0102e3b:	68 5d 5c 10 f0       	push   $0xf0105c5d
f0102e40:	e8 7e 02 00 00       	call   f01030c3 <cprintf>
f0102e45:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102e48:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e4d:	eb 0b                	jmp    f0102e5a <get_user_program_info+0x6e>
	}

	return &userPrograms[i];
f0102e4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102e52:	c1 e0 04             	shl    $0x4,%eax
f0102e55:	05 00 b6 11 f0       	add    $0xf011b600,%eax
}
f0102e5a:	c9                   	leave  
f0102e5b:	c3                   	ret    

f0102e5c <get_user_program_info_by_env>:

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
{
f0102e5c:	55                   	push   %ebp
f0102e5d:	89 e5                	mov    %esp,%ebp
f0102e5f:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102e62:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102e69:	eb 15                	jmp    f0102e80 <get_user_program_info_by_env+0x24>
		if (e== userPrograms[i].environment)
f0102e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102e6e:	c1 e0 04             	shl    $0x4,%eax
f0102e71:	05 0c b6 11 f0       	add    $0xf011b60c,%eax
f0102e76:	8b 00                	mov    (%eax),%eax
f0102e78:	3b 45 08             	cmp    0x8(%ebp),%eax
f0102e7b:	74 0f                	je     f0102e8c <get_user_program_info_by_env+0x30>
}

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102e7d:	ff 45 f4             	incl   -0xc(%ebp)
f0102e80:	a1 54 b6 11 f0       	mov    0xf011b654,%eax
f0102e85:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102e88:	7c e1                	jl     f0102e6b <get_user_program_info_by_env+0xf>
f0102e8a:	eb 01                	jmp    f0102e8d <get_user_program_info_by_env+0x31>
		if (e== userPrograms[i].environment)
			break;
f0102e8c:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102e8d:	a1 54 b6 11 f0       	mov    0xf011b654,%eax
f0102e92:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102e95:	75 17                	jne    f0102eae <get_user_program_info_by_env+0x52>
	{
		cprintf("Unknown user program \n");
f0102e97:	83 ec 0c             	sub    $0xc,%esp
f0102e9a:	68 78 5c 10 f0       	push   $0xf0105c78
f0102e9f:	e8 1f 02 00 00       	call   f01030c3 <cprintf>
f0102ea4:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102ea7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102eac:	eb 0b                	jmp    f0102eb9 <get_user_program_info_by_env+0x5d>
	}

	return &userPrograms[i];
f0102eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102eb1:	c1 e0 04             	shl    $0x4,%eax
f0102eb4:	05 00 b6 11 f0       	add    $0xf011b600,%eax
}
f0102eb9:	c9                   	leave  
f0102eba:	c3                   	ret    

f0102ebb <set_environment_entry_point>:

void set_environment_entry_point(struct UserProgramInfo* ptr_user_program)
{
f0102ebb:	55                   	push   %ebp
f0102ebc:	89 e5                	mov    %esp,%ebp
f0102ebe:	83 ec 18             	sub    $0x18,%esp
	uint8* ptr_program_start=ptr_user_program->ptr_start;
f0102ec1:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ec4:	8b 40 08             	mov    0x8(%eax),%eax
f0102ec7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Env* e = ptr_user_program->environment;
f0102eca:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ecd:	8b 40 0c             	mov    0xc(%eax),%eax
f0102ed0:	89 45 f0             	mov    %eax,-0x10(%ebp)

	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ed6:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102ed9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102edc:	8b 00                	mov    (%eax),%eax
f0102ede:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102ee3:	74 17                	je     f0102efc <set_environment_entry_point+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102ee5:	83 ec 04             	sub    $0x4,%esp
f0102ee8:	68 47 5c 10 f0       	push   $0xf0105c47
f0102eed:	68 99 01 00 00       	push   $0x199
f0102ef2:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102ef7:	e8 32 d2 ff ff       	call   f010012e <_panic>
	e->env_tf.tf_eip = (uint32*)pELFHDR->e_entry ;
f0102efc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102eff:	8b 40 18             	mov    0x18(%eax),%eax
f0102f02:	89 c2                	mov    %eax,%edx
f0102f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102f07:	89 50 30             	mov    %edx,0x30(%eax)
}
f0102f0a:	90                   	nop
f0102f0b:	c9                   	leave  
f0102f0c:	c3                   	ret    

f0102f0d <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102f0d:	55                   	push   %ebp
f0102f0e:	89 e5                	mov    %esp,%ebp
f0102f10:	83 ec 08             	sub    $0x8,%esp
	env_free(e);
f0102f13:	83 ec 0c             	sub    $0xc,%esp
f0102f16:	ff 75 08             	pushl  0x8(%ebp)
f0102f19:	e8 40 fa ff ff       	call   f010295e <env_free>
f0102f1e:	83 c4 10             	add    $0x10,%esp

	//cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
		run_command_prompt();
f0102f21:	e8 2b da ff ff       	call   f0100951 <run_command_prompt>
f0102f26:	eb f9                	jmp    f0102f21 <env_destroy+0x14>

f0102f28 <env_run_cmd_prmpt>:
}

void env_run_cmd_prmpt()
{
f0102f28:	55                   	push   %ebp
f0102f29:	89 e5                	mov    %esp,%ebp
f0102f2b:	83 ec 18             	sub    $0x18,%esp
	struct UserProgramInfo* upi= get_user_program_info_by_env(curenv);	
f0102f2e:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f33:	83 ec 0c             	sub    $0xc,%esp
f0102f36:	50                   	push   %eax
f0102f37:	e8 20 ff ff ff       	call   f0102e5c <get_user_program_info_by_env>
f0102f3c:	83 c4 10             	add    $0x10,%esp
f0102f3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&curenv->env_tf, 0, sizeof(curenv->env_tf));
f0102f42:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f47:	83 ec 04             	sub    $0x4,%esp
f0102f4a:	6a 44                	push   $0x44
f0102f4c:	6a 00                	push   $0x0
f0102f4e:	50                   	push   %eax
f0102f4f:	e8 51 18 00 00       	call   f01047a5 <memset>
f0102f54:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	curenv->env_tf.tf_ds = GD_UD | 3;
f0102f57:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f5c:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	curenv->env_tf.tf_es = GD_UD | 3;
f0102f62:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f67:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	curenv->env_tf.tf_ss = GD_UD | 3;
f0102f6d:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f72:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	curenv->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102f78:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f7d:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	curenv->env_tf.tf_cs = GD_UT | 3;
f0102f84:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0102f89:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	set_environment_entry_point(upi);
f0102f8f:	83 ec 0c             	sub    $0xc,%esp
f0102f92:	ff 75 f4             	pushl  -0xc(%ebp)
f0102f95:	e8 21 ff ff ff       	call   f0102ebb <set_environment_entry_point>
f0102f9a:	83 c4 10             	add    $0x10,%esp
	
	lcr3(K_PHYSICAL_ADDRESS(ptr_page_directory));
f0102f9d:	a1 44 e7 14 f0       	mov    0xf014e744,%eax
f0102fa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102fa5:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0102fac:	77 17                	ja     f0102fc5 <env_run_cmd_prmpt+0x9d>
f0102fae:	ff 75 f0             	pushl  -0x10(%ebp)
f0102fb1:	68 90 5c 10 f0       	push   $0xf0105c90
f0102fb6:	68 c4 01 00 00       	push   $0x1c4
f0102fbb:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0102fc0:	e8 69 d1 ff ff       	call   f010012e <_panic>
f0102fc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102fc8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102fd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102fd3:	0f 22 d8             	mov    %eax,%cr3
	
	curenv = NULL;
f0102fd6:	c7 05 b0 de 14 f0 00 	movl   $0x0,0xf014deb0
f0102fdd:	00 00 00 
	
	while (1)
		run_command_prompt();
f0102fe0:	e8 6c d9 ff ff       	call   f0100951 <run_command_prompt>
f0102fe5:	eb f9                	jmp    f0102fe0 <env_run_cmd_prmpt+0xb8>

f0102fe7 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102fe7:	55                   	push   %ebp
f0102fe8:	89 e5                	mov    %esp,%ebp
f0102fea:	83 ec 08             	sub    $0x8,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102fed:	8b 65 08             	mov    0x8(%ebp),%esp
f0102ff0:	61                   	popa   
f0102ff1:	07                   	pop    %es
f0102ff2:	1f                   	pop    %ds
f0102ff3:	83 c4 08             	add    $0x8,%esp
f0102ff6:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102ff7:	83 ec 04             	sub    $0x4,%esp
f0102ffa:	68 c1 5c 10 f0       	push   $0xf0105cc1
f0102fff:	68 db 01 00 00       	push   $0x1db
f0103004:	68 a1 5b 10 f0       	push   $0xf0105ba1
f0103009:	e8 20 d1 ff ff       	call   f010012e <_panic>

f010300e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010300e:	55                   	push   %ebp
f010300f:	89 e5                	mov    %esp,%ebp
f0103011:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0103014:	8b 45 08             	mov    0x8(%ebp),%eax
f0103017:	0f b6 c0             	movzbl %al,%eax
f010301a:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0103021:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103024:	8a 45 f6             	mov    -0xa(%ebp),%al
f0103027:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010302a:	ee                   	out    %al,(%dx)
f010302b:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103032:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103035:	89 c2                	mov    %eax,%edx
f0103037:	ec                   	in     (%dx),%al
f0103038:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f010303b:	8a 45 f7             	mov    -0x9(%ebp),%al
	return inb(IO_RTC+1);
f010303e:	0f b6 c0             	movzbl %al,%eax
}
f0103041:	c9                   	leave  
f0103042:	c3                   	ret    

f0103043 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103043:	55                   	push   %ebp
f0103044:	89 e5                	mov    %esp,%ebp
f0103046:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0103049:	8b 45 08             	mov    0x8(%ebp),%eax
f010304c:	0f b6 c0             	movzbl %al,%eax
f010304f:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0103056:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103059:	8a 45 f6             	mov    -0xa(%ebp),%al
f010305c:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010305f:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0103060:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103063:	0f b6 c0             	movzbl %al,%eax
f0103066:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)
f010306d:	88 45 f7             	mov    %al,-0x9(%ebp)
f0103070:	8a 45 f7             	mov    -0x9(%ebp),%al
f0103073:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0103076:	ee                   	out    %al,(%dx)
}
f0103077:	90                   	nop
f0103078:	c9                   	leave  
f0103079:	c3                   	ret    

f010307a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010307a:	55                   	push   %ebp
f010307b:	89 e5                	mov    %esp,%ebp
f010307d:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f0103080:	83 ec 0c             	sub    $0xc,%esp
f0103083:	ff 75 08             	pushl  0x8(%ebp)
f0103086:	e8 8c d8 ff ff       	call   f0100917 <cputchar>
f010308b:	83 c4 10             	add    $0x10,%esp
	*cnt++;
f010308e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103091:	83 c0 04             	add    $0x4,%eax
f0103094:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0103097:	90                   	nop
f0103098:	c9                   	leave  
f0103099:	c3                   	ret    

f010309a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010309a:	55                   	push   %ebp
f010309b:	89 e5                	mov    %esp,%ebp
f010309d:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01030a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01030a7:	ff 75 0c             	pushl  0xc(%ebp)
f01030aa:	ff 75 08             	pushl  0x8(%ebp)
f01030ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01030b0:	50                   	push   %eax
f01030b1:	68 7a 30 10 f0       	push   $0xf010307a
f01030b6:	e8 56 0f 00 00       	call   f0104011 <vprintfmt>
f01030bb:	83 c4 10             	add    $0x10,%esp
	return cnt;
f01030be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01030c1:	c9                   	leave  
f01030c2:	c3                   	ret    

f01030c3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01030c3:	55                   	push   %ebp
f01030c4:	89 e5                	mov    %esp,%ebp
f01030c6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01030c9:	8d 45 0c             	lea    0xc(%ebp),%eax
f01030cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
f01030cf:	8b 45 08             	mov    0x8(%ebp),%eax
f01030d2:	83 ec 08             	sub    $0x8,%esp
f01030d5:	ff 75 f4             	pushl  -0xc(%ebp)
f01030d8:	50                   	push   %eax
f01030d9:	e8 bc ff ff ff       	call   f010309a <vcprintf>
f01030de:	83 c4 10             	add    $0x10,%esp
f01030e1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
f01030e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f01030e7:	c9                   	leave  
f01030e8:	c3                   	ret    

f01030e9 <trapname>:
};
extern  void (*PAGE_FAULT)();
extern  void (*SYSCALL_HANDLER)();

static const char *trapname(int trapno)
{
f01030e9:	55                   	push   %ebp
f01030ea:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01030ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01030ef:	83 f8 13             	cmp    $0x13,%eax
f01030f2:	77 0c                	ja     f0103100 <trapname+0x17>
		return excnames[trapno];
f01030f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030f7:	8b 04 85 00 60 10 f0 	mov    -0xfefa000(,%eax,4),%eax
f01030fe:	eb 12                	jmp    f0103112 <trapname+0x29>
	if (trapno == T_SYSCALL)
f0103100:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f0103104:	75 07                	jne    f010310d <trapname+0x24>
		return "System call";
f0103106:	b8 e0 5c 10 f0       	mov    $0xf0105ce0,%eax
f010310b:	eb 05                	jmp    f0103112 <trapname+0x29>
	return "(unknown trap)";
f010310d:	b8 ec 5c 10 f0       	mov    $0xf0105cec,%eax
}
f0103112:	5d                   	pop    %ebp
f0103113:	c3                   	ret    

f0103114 <idt_init>:


void
idt_init(void)
{
f0103114:	55                   	push   %ebp
f0103115:	89 e5                	mov    %esp,%ebp
f0103117:	83 ec 10             	sub    $0x10,%esp
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	//initialize idt
	SETGATE(idt[T_PGFLT], 0, GD_KT , &PAGE_FAULT, 0) ;
f010311a:	b8 72 36 10 f0       	mov    $0xf0103672,%eax
f010311f:	66 a3 30 df 14 f0    	mov    %ax,0xf014df30
f0103125:	66 c7 05 32 df 14 f0 	movw   $0x8,0xf014df32
f010312c:	08 00 
f010312e:	a0 34 df 14 f0       	mov    0xf014df34,%al
f0103133:	83 e0 e0             	and    $0xffffffe0,%eax
f0103136:	a2 34 df 14 f0       	mov    %al,0xf014df34
f010313b:	a0 34 df 14 f0       	mov    0xf014df34,%al
f0103140:	83 e0 1f             	and    $0x1f,%eax
f0103143:	a2 34 df 14 f0       	mov    %al,0xf014df34
f0103148:	a0 35 df 14 f0       	mov    0xf014df35,%al
f010314d:	83 e0 f0             	and    $0xfffffff0,%eax
f0103150:	83 c8 0e             	or     $0xe,%eax
f0103153:	a2 35 df 14 f0       	mov    %al,0xf014df35
f0103158:	a0 35 df 14 f0       	mov    0xf014df35,%al
f010315d:	83 e0 ef             	and    $0xffffffef,%eax
f0103160:	a2 35 df 14 f0       	mov    %al,0xf014df35
f0103165:	a0 35 df 14 f0       	mov    0xf014df35,%al
f010316a:	83 e0 9f             	and    $0xffffff9f,%eax
f010316d:	a2 35 df 14 f0       	mov    %al,0xf014df35
f0103172:	a0 35 df 14 f0       	mov    0xf014df35,%al
f0103177:	83 c8 80             	or     $0xffffff80,%eax
f010317a:	a2 35 df 14 f0       	mov    %al,0xf014df35
f010317f:	b8 72 36 10 f0       	mov    $0xf0103672,%eax
f0103184:	c1 e8 10             	shr    $0x10,%eax
f0103187:	66 a3 36 df 14 f0    	mov    %ax,0xf014df36
	SETGATE(idt[T_SYSCALL], 0, GD_KT , &SYSCALL_HANDLER, 3) ;
f010318d:	b8 76 36 10 f0       	mov    $0xf0103676,%eax
f0103192:	66 a3 40 e0 14 f0    	mov    %ax,0xf014e040
f0103198:	66 c7 05 42 e0 14 f0 	movw   $0x8,0xf014e042
f010319f:	08 00 
f01031a1:	a0 44 e0 14 f0       	mov    0xf014e044,%al
f01031a6:	83 e0 e0             	and    $0xffffffe0,%eax
f01031a9:	a2 44 e0 14 f0       	mov    %al,0xf014e044
f01031ae:	a0 44 e0 14 f0       	mov    0xf014e044,%al
f01031b3:	83 e0 1f             	and    $0x1f,%eax
f01031b6:	a2 44 e0 14 f0       	mov    %al,0xf014e044
f01031bb:	a0 45 e0 14 f0       	mov    0xf014e045,%al
f01031c0:	83 e0 f0             	and    $0xfffffff0,%eax
f01031c3:	83 c8 0e             	or     $0xe,%eax
f01031c6:	a2 45 e0 14 f0       	mov    %al,0xf014e045
f01031cb:	a0 45 e0 14 f0       	mov    0xf014e045,%al
f01031d0:	83 e0 ef             	and    $0xffffffef,%eax
f01031d3:	a2 45 e0 14 f0       	mov    %al,0xf014e045
f01031d8:	a0 45 e0 14 f0       	mov    0xf014e045,%al
f01031dd:	83 c8 60             	or     $0x60,%eax
f01031e0:	a2 45 e0 14 f0       	mov    %al,0xf014e045
f01031e5:	a0 45 e0 14 f0       	mov    0xf014e045,%al
f01031ea:	83 c8 80             	or     $0xffffff80,%eax
f01031ed:	a2 45 e0 14 f0       	mov    %al,0xf014e045
f01031f2:	b8 76 36 10 f0       	mov    $0xf0103676,%eax
f01031f7:	c1 e8 10             	shr    $0x10,%eax
f01031fa:	66 a3 46 e0 14 f0    	mov    %ax,0xf014e046

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KERNEL_STACK_TOP;
f0103200:	c7 05 c4 e6 14 f0 00 	movl   $0xefc00000,0xf014e6c4
f0103207:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f010320a:	66 c7 05 c8 e6 14 f0 	movw   $0x10,0xf014e6c8
f0103211:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32) (&ts),
f0103213:	66 c7 05 e8 b5 11 f0 	movw   $0x68,0xf011b5e8
f010321a:	68 00 
f010321c:	b8 c0 e6 14 f0       	mov    $0xf014e6c0,%eax
f0103221:	66 a3 ea b5 11 f0    	mov    %ax,0xf011b5ea
f0103227:	b8 c0 e6 14 f0       	mov    $0xf014e6c0,%eax
f010322c:	c1 e8 10             	shr    $0x10,%eax
f010322f:	a2 ec b5 11 f0       	mov    %al,0xf011b5ec
f0103234:	a0 ed b5 11 f0       	mov    0xf011b5ed,%al
f0103239:	83 e0 f0             	and    $0xfffffff0,%eax
f010323c:	83 c8 09             	or     $0x9,%eax
f010323f:	a2 ed b5 11 f0       	mov    %al,0xf011b5ed
f0103244:	a0 ed b5 11 f0       	mov    0xf011b5ed,%al
f0103249:	83 c8 10             	or     $0x10,%eax
f010324c:	a2 ed b5 11 f0       	mov    %al,0xf011b5ed
f0103251:	a0 ed b5 11 f0       	mov    0xf011b5ed,%al
f0103256:	83 e0 9f             	and    $0xffffff9f,%eax
f0103259:	a2 ed b5 11 f0       	mov    %al,0xf011b5ed
f010325e:	a0 ed b5 11 f0       	mov    0xf011b5ed,%al
f0103263:	83 c8 80             	or     $0xffffff80,%eax
f0103266:	a2 ed b5 11 f0       	mov    %al,0xf011b5ed
f010326b:	a0 ee b5 11 f0       	mov    0xf011b5ee,%al
f0103270:	83 e0 f0             	and    $0xfffffff0,%eax
f0103273:	a2 ee b5 11 f0       	mov    %al,0xf011b5ee
f0103278:	a0 ee b5 11 f0       	mov    0xf011b5ee,%al
f010327d:	83 e0 ef             	and    $0xffffffef,%eax
f0103280:	a2 ee b5 11 f0       	mov    %al,0xf011b5ee
f0103285:	a0 ee b5 11 f0       	mov    0xf011b5ee,%al
f010328a:	83 e0 df             	and    $0xffffffdf,%eax
f010328d:	a2 ee b5 11 f0       	mov    %al,0xf011b5ee
f0103292:	a0 ee b5 11 f0       	mov    0xf011b5ee,%al
f0103297:	83 c8 40             	or     $0x40,%eax
f010329a:	a2 ee b5 11 f0       	mov    %al,0xf011b5ee
f010329f:	a0 ee b5 11 f0       	mov    0xf011b5ee,%al
f01032a4:	83 e0 7f             	and    $0x7f,%eax
f01032a7:	a2 ee b5 11 f0       	mov    %al,0xf011b5ee
f01032ac:	b8 c0 e6 14 f0       	mov    $0xf014e6c0,%eax
f01032b1:	c1 e8 18             	shr    $0x18,%eax
f01032b4:	a2 ef b5 11 f0       	mov    %al,0xf011b5ef
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f01032b9:	a0 ed b5 11 f0       	mov    0xf011b5ed,%al
f01032be:	83 e0 ef             	and    $0xffffffef,%eax
f01032c1:	a2 ed b5 11 f0       	mov    %al,0xf011b5ed
f01032c6:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static __inline void
ltr(uint16 sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01032cc:	66 8b 45 fe          	mov    -0x2(%ebp),%ax
f01032d0:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f01032d3:	0f 01 1d 58 b6 11 f0 	lidtl  0xf011b658
}
f01032da:	90                   	nop
f01032db:	c9                   	leave  
f01032dc:	c3                   	ret    

f01032dd <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f01032dd:	55                   	push   %ebp
f01032de:	89 e5                	mov    %esp,%ebp
f01032e0:	83 ec 08             	sub    $0x8,%esp
	cprintf("TRAP frame at %p\n", tf);
f01032e3:	83 ec 08             	sub    $0x8,%esp
f01032e6:	ff 75 08             	pushl  0x8(%ebp)
f01032e9:	68 fb 5c 10 f0       	push   $0xf0105cfb
f01032ee:	e8 d0 fd ff ff       	call   f01030c3 <cprintf>
f01032f3:	83 c4 10             	add    $0x10,%esp
	print_regs(&tf->tf_regs);
f01032f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f9:	83 ec 0c             	sub    $0xc,%esp
f01032fc:	50                   	push   %eax
f01032fd:	e8 f6 00 00 00       	call   f01033f8 <print_regs>
f0103302:	83 c4 10             	add    $0x10,%esp
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103305:	8b 45 08             	mov    0x8(%ebp),%eax
f0103308:	8b 40 20             	mov    0x20(%eax),%eax
f010330b:	0f b7 c0             	movzwl %ax,%eax
f010330e:	83 ec 08             	sub    $0x8,%esp
f0103311:	50                   	push   %eax
f0103312:	68 0d 5d 10 f0       	push   $0xf0105d0d
f0103317:	e8 a7 fd ff ff       	call   f01030c3 <cprintf>
f010331c:	83 c4 10             	add    $0x10,%esp
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010331f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103322:	8b 40 24             	mov    0x24(%eax),%eax
f0103325:	0f b7 c0             	movzwl %ax,%eax
f0103328:	83 ec 08             	sub    $0x8,%esp
f010332b:	50                   	push   %eax
f010332c:	68 20 5d 10 f0       	push   $0xf0105d20
f0103331:	e8 8d fd ff ff       	call   f01030c3 <cprintf>
f0103336:	83 c4 10             	add    $0x10,%esp
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103339:	8b 45 08             	mov    0x8(%ebp),%eax
f010333c:	8b 40 28             	mov    0x28(%eax),%eax
f010333f:	83 ec 0c             	sub    $0xc,%esp
f0103342:	50                   	push   %eax
f0103343:	e8 a1 fd ff ff       	call   f01030e9 <trapname>
f0103348:	83 c4 10             	add    $0x10,%esp
f010334b:	89 c2                	mov    %eax,%edx
f010334d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103350:	8b 40 28             	mov    0x28(%eax),%eax
f0103353:	83 ec 04             	sub    $0x4,%esp
f0103356:	52                   	push   %edx
f0103357:	50                   	push   %eax
f0103358:	68 33 5d 10 f0       	push   $0xf0105d33
f010335d:	e8 61 fd ff ff       	call   f01030c3 <cprintf>
f0103362:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x\n", tf->tf_err);
f0103365:	8b 45 08             	mov    0x8(%ebp),%eax
f0103368:	8b 40 2c             	mov    0x2c(%eax),%eax
f010336b:	83 ec 08             	sub    $0x8,%esp
f010336e:	50                   	push   %eax
f010336f:	68 45 5d 10 f0       	push   $0xf0105d45
f0103374:	e8 4a fd ff ff       	call   f01030c3 <cprintf>
f0103379:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010337c:	8b 45 08             	mov    0x8(%ebp),%eax
f010337f:	8b 40 30             	mov    0x30(%eax),%eax
f0103382:	83 ec 08             	sub    $0x8,%esp
f0103385:	50                   	push   %eax
f0103386:	68 54 5d 10 f0       	push   $0xf0105d54
f010338b:	e8 33 fd ff ff       	call   f01030c3 <cprintf>
f0103390:	83 c4 10             	add    $0x10,%esp
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103393:	8b 45 08             	mov    0x8(%ebp),%eax
f0103396:	8b 40 34             	mov    0x34(%eax),%eax
f0103399:	0f b7 c0             	movzwl %ax,%eax
f010339c:	83 ec 08             	sub    $0x8,%esp
f010339f:	50                   	push   %eax
f01033a0:	68 63 5d 10 f0       	push   $0xf0105d63
f01033a5:	e8 19 fd ff ff       	call   f01030c3 <cprintf>
f01033aa:	83 c4 10             	add    $0x10,%esp
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01033ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01033b0:	8b 40 38             	mov    0x38(%eax),%eax
f01033b3:	83 ec 08             	sub    $0x8,%esp
f01033b6:	50                   	push   %eax
f01033b7:	68 76 5d 10 f0       	push   $0xf0105d76
f01033bc:	e8 02 fd ff ff       	call   f01030c3 <cprintf>
f01033c1:	83 c4 10             	add    $0x10,%esp
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f01033c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01033c7:	8b 40 3c             	mov    0x3c(%eax),%eax
f01033ca:	83 ec 08             	sub    $0x8,%esp
f01033cd:	50                   	push   %eax
f01033ce:	68 85 5d 10 f0       	push   $0xf0105d85
f01033d3:	e8 eb fc ff ff       	call   f01030c3 <cprintf>
f01033d8:	83 c4 10             	add    $0x10,%esp
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01033db:	8b 45 08             	mov    0x8(%ebp),%eax
f01033de:	8b 40 40             	mov    0x40(%eax),%eax
f01033e1:	0f b7 c0             	movzwl %ax,%eax
f01033e4:	83 ec 08             	sub    $0x8,%esp
f01033e7:	50                   	push   %eax
f01033e8:	68 94 5d 10 f0       	push   $0xf0105d94
f01033ed:	e8 d1 fc ff ff       	call   f01030c3 <cprintf>
f01033f2:	83 c4 10             	add    $0x10,%esp
}
f01033f5:	90                   	nop
f01033f6:	c9                   	leave  
f01033f7:	c3                   	ret    

f01033f8 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f01033f8:	55                   	push   %ebp
f01033f9:	89 e5                	mov    %esp,%ebp
f01033fb:	83 ec 08             	sub    $0x8,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01033fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103401:	8b 00                	mov    (%eax),%eax
f0103403:	83 ec 08             	sub    $0x8,%esp
f0103406:	50                   	push   %eax
f0103407:	68 a7 5d 10 f0       	push   $0xf0105da7
f010340c:	e8 b2 fc ff ff       	call   f01030c3 <cprintf>
f0103411:	83 c4 10             	add    $0x10,%esp
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103414:	8b 45 08             	mov    0x8(%ebp),%eax
f0103417:	8b 40 04             	mov    0x4(%eax),%eax
f010341a:	83 ec 08             	sub    $0x8,%esp
f010341d:	50                   	push   %eax
f010341e:	68 b6 5d 10 f0       	push   $0xf0105db6
f0103423:	e8 9b fc ff ff       	call   f01030c3 <cprintf>
f0103428:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010342b:	8b 45 08             	mov    0x8(%ebp),%eax
f010342e:	8b 40 08             	mov    0x8(%eax),%eax
f0103431:	83 ec 08             	sub    $0x8,%esp
f0103434:	50                   	push   %eax
f0103435:	68 c5 5d 10 f0       	push   $0xf0105dc5
f010343a:	e8 84 fc ff ff       	call   f01030c3 <cprintf>
f010343f:	83 c4 10             	add    $0x10,%esp
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103442:	8b 45 08             	mov    0x8(%ebp),%eax
f0103445:	8b 40 0c             	mov    0xc(%eax),%eax
f0103448:	83 ec 08             	sub    $0x8,%esp
f010344b:	50                   	push   %eax
f010344c:	68 d4 5d 10 f0       	push   $0xf0105dd4
f0103451:	e8 6d fc ff ff       	call   f01030c3 <cprintf>
f0103456:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103459:	8b 45 08             	mov    0x8(%ebp),%eax
f010345c:	8b 40 10             	mov    0x10(%eax),%eax
f010345f:	83 ec 08             	sub    $0x8,%esp
f0103462:	50                   	push   %eax
f0103463:	68 e3 5d 10 f0       	push   $0xf0105de3
f0103468:	e8 56 fc ff ff       	call   f01030c3 <cprintf>
f010346d:	83 c4 10             	add    $0x10,%esp
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103470:	8b 45 08             	mov    0x8(%ebp),%eax
f0103473:	8b 40 14             	mov    0x14(%eax),%eax
f0103476:	83 ec 08             	sub    $0x8,%esp
f0103479:	50                   	push   %eax
f010347a:	68 f2 5d 10 f0       	push   $0xf0105df2
f010347f:	e8 3f fc ff ff       	call   f01030c3 <cprintf>
f0103484:	83 c4 10             	add    $0x10,%esp
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103487:	8b 45 08             	mov    0x8(%ebp),%eax
f010348a:	8b 40 18             	mov    0x18(%eax),%eax
f010348d:	83 ec 08             	sub    $0x8,%esp
f0103490:	50                   	push   %eax
f0103491:	68 01 5e 10 f0       	push   $0xf0105e01
f0103496:	e8 28 fc ff ff       	call   f01030c3 <cprintf>
f010349b:	83 c4 10             	add    $0x10,%esp
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010349e:	8b 45 08             	mov    0x8(%ebp),%eax
f01034a1:	8b 40 1c             	mov    0x1c(%eax),%eax
f01034a4:	83 ec 08             	sub    $0x8,%esp
f01034a7:	50                   	push   %eax
f01034a8:	68 10 5e 10 f0       	push   $0xf0105e10
f01034ad:	e8 11 fc ff ff       	call   f01030c3 <cprintf>
f01034b2:	83 c4 10             	add    $0x10,%esp
}
f01034b5:	90                   	nop
f01034b6:	c9                   	leave  
f01034b7:	c3                   	ret    

f01034b8 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f01034b8:	55                   	push   %ebp
f01034b9:	89 e5                	mov    %esp,%ebp
f01034bb:	57                   	push   %edi
f01034bc:	56                   	push   %esi
f01034bd:	53                   	push   %ebx
f01034be:	83 ec 1c             	sub    $0x1c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if(tf->tf_trapno == T_PGFLT)
f01034c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c4:	8b 40 28             	mov    0x28(%eax),%eax
f01034c7:	83 f8 0e             	cmp    $0xe,%eax
f01034ca:	75 13                	jne    f01034df <trap_dispatch+0x27>
	{
		page_fault_handler(tf);
f01034cc:	83 ec 0c             	sub    $0xc,%esp
f01034cf:	ff 75 08             	pushl  0x8(%ebp)
f01034d2:	e8 47 01 00 00       	call   f010361e <page_fault_handler>
f01034d7:	83 c4 10             	add    $0x10,%esp
		else {
			env_destroy(curenv);
			return;	
		}
	}
	return;
f01034da:	e9 90 00 00 00       	jmp    f010356f <trap_dispatch+0xb7>
	
	if(tf->tf_trapno == T_PGFLT)
	{
		page_fault_handler(tf);
	}
	else if (tf->tf_trapno == T_SYSCALL)
f01034df:	8b 45 08             	mov    0x8(%ebp),%eax
f01034e2:	8b 40 28             	mov    0x28(%eax),%eax
f01034e5:	83 f8 30             	cmp    $0x30,%eax
f01034e8:	75 42                	jne    f010352c <trap_dispatch+0x74>
	{
		uint32 ret = syscall(tf->tf_regs.reg_eax
f01034ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01034ed:	8b 78 04             	mov    0x4(%eax),%edi
f01034f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f3:	8b 30                	mov    (%eax),%esi
f01034f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f8:	8b 58 10             	mov    0x10(%eax),%ebx
f01034fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01034fe:	8b 48 18             	mov    0x18(%eax),%ecx
f0103501:	8b 45 08             	mov    0x8(%ebp),%eax
f0103504:	8b 50 14             	mov    0x14(%eax),%edx
f0103507:	8b 45 08             	mov    0x8(%ebp),%eax
f010350a:	8b 40 1c             	mov    0x1c(%eax),%eax
f010350d:	83 ec 08             	sub    $0x8,%esp
f0103510:	57                   	push   %edi
f0103511:	56                   	push   %esi
f0103512:	53                   	push   %ebx
f0103513:	51                   	push   %ecx
f0103514:	52                   	push   %edx
f0103515:	50                   	push   %eax
f0103516:	e8 47 04 00 00       	call   f0103962 <syscall>
f010351b:	83 c4 20             	add    $0x20,%esp
f010351e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			,tf->tf_regs.reg_edx
			,tf->tf_regs.reg_ecx
			,tf->tf_regs.reg_ebx
			,tf->tf_regs.reg_edi
					,tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f0103521:	8b 45 08             	mov    0x8(%ebp),%eax
f0103524:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103527:	89 50 1c             	mov    %edx,0x1c(%eax)
		else {
			env_destroy(curenv);
			return;	
		}
	}
	return;
f010352a:	eb 43                	jmp    f010356f <trap_dispatch+0xb7>
		tf->tf_regs.reg_eax = ret;
	}
	else
	{
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f010352c:	83 ec 0c             	sub    $0xc,%esp
f010352f:	ff 75 08             	pushl  0x8(%ebp)
f0103532:	e8 a6 fd ff ff       	call   f01032dd <print_trapframe>
f0103537:	83 c4 10             	add    $0x10,%esp
		if (tf->tf_cs == GD_KT)
f010353a:	8b 45 08             	mov    0x8(%ebp),%eax
f010353d:	8b 40 34             	mov    0x34(%eax),%eax
f0103540:	66 83 f8 08          	cmp    $0x8,%ax
f0103544:	75 17                	jne    f010355d <trap_dispatch+0xa5>
			panic("unhandled trap in kernel");
f0103546:	83 ec 04             	sub    $0x4,%esp
f0103549:	68 1f 5e 10 f0       	push   $0xf0105e1f
f010354e:	68 8a 00 00 00       	push   $0x8a
f0103553:	68 38 5e 10 f0       	push   $0xf0105e38
f0103558:	e8 d1 cb ff ff       	call   f010012e <_panic>
		else {
			env_destroy(curenv);
f010355d:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103562:	83 ec 0c             	sub    $0xc,%esp
f0103565:	50                   	push   %eax
f0103566:	e8 a2 f9 ff ff       	call   f0102f0d <env_destroy>
f010356b:	83 c4 10             	add    $0x10,%esp
			return;	
f010356e:	90                   	nop
		}
	}
	return;
}
f010356f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103572:	5b                   	pop    %ebx
f0103573:	5e                   	pop    %esi
f0103574:	5f                   	pop    %edi
f0103575:	5d                   	pop    %ebp
f0103576:	c3                   	ret    

f0103577 <trap>:

void
trap(struct Trapframe *tf)
{
f0103577:	55                   	push   %ebp
f0103578:	89 e5                	mov    %esp,%ebp
f010357a:	57                   	push   %edi
f010357b:	56                   	push   %esi
f010357c:	53                   	push   %ebx
f010357d:	83 ec 0c             	sub    $0xc,%esp
	//cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
f0103580:	8b 45 08             	mov    0x8(%ebp),%eax
f0103583:	8b 40 34             	mov    0x34(%eax),%eax
f0103586:	0f b7 c0             	movzwl %ax,%eax
f0103589:	83 e0 03             	and    $0x3,%eax
f010358c:	83 f8 03             	cmp    $0x3,%eax
f010358f:	75 42                	jne    f01035d3 <trap+0x5c>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f0103591:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103596:	85 c0                	test   %eax,%eax
f0103598:	75 19                	jne    f01035b3 <trap+0x3c>
f010359a:	68 44 5e 10 f0       	push   $0xf0105e44
f010359f:	68 4b 5e 10 f0       	push   $0xf0105e4b
f01035a4:	68 9d 00 00 00       	push   $0x9d
f01035a9:	68 38 5e 10 f0       	push   $0xf0105e38
f01035ae:	e8 7b cb ff ff       	call   f010012e <_panic>
		curenv->env_tf = *tf;
f01035b3:	8b 15 b0 de 14 f0    	mov    0xf014deb0,%edx
f01035b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01035bc:	89 c3                	mov    %eax,%ebx
f01035be:	b8 11 00 00 00       	mov    $0x11,%eax
f01035c3:	89 d7                	mov    %edx,%edi
f01035c5:	89 de                	mov    %ebx,%esi
f01035c7:	89 c1                	mov    %eax,%ecx
f01035c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01035cb:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f01035d0:	89 45 08             	mov    %eax,0x8(%ebp)
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f01035d3:	83 ec 0c             	sub    $0xc,%esp
f01035d6:	ff 75 08             	pushl  0x8(%ebp)
f01035d9:	e8 da fe ff ff       	call   f01034b8 <trap_dispatch>
f01035de:	83 c4 10             	add    $0x10,%esp

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f01035e1:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f01035e6:	85 c0                	test   %eax,%eax
f01035e8:	74 0d                	je     f01035f7 <trap+0x80>
f01035ea:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f01035ef:	8b 40 54             	mov    0x54(%eax),%eax
f01035f2:	83 f8 01             	cmp    $0x1,%eax
f01035f5:	74 19                	je     f0103610 <trap+0x99>
f01035f7:	68 60 5e 10 f0       	push   $0xf0105e60
f01035fc:	68 4b 5e 10 f0       	push   $0xf0105e4b
f0103601:	68 a7 00 00 00       	push   $0xa7
f0103606:	68 38 5e 10 f0       	push   $0xf0105e38
f010360b:	e8 1e cb ff ff       	call   f010012e <_panic>
        env_run(curenv);
f0103610:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103615:	83 ec 0c             	sub    $0xc,%esp
f0103618:	50                   	push   %eax
f0103619:	e8 fd f2 ff ff       	call   f010291b <env_run>

f010361e <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010361e:	55                   	push   %ebp
f010361f:	89 e5                	mov    %esp,%ebp
f0103621:	83 ec 18             	sub    $0x18,%esp

static __inline uint32
rcr2(void)
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103624:	0f 20 d0             	mov    %cr2,%eax
f0103627:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return val;
f010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
	uint32 fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f010362d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103630:	8b 45 08             	mov    0x8(%ebp),%eax
f0103633:	8b 50 30             	mov    0x30(%eax),%edx
		curenv->env_id, fault_va, tf->tf_eip);
f0103636:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010363b:	8b 40 4c             	mov    0x4c(%eax),%eax
f010363e:	52                   	push   %edx
f010363f:	ff 75 f4             	pushl  -0xc(%ebp)
f0103642:	50                   	push   %eax
f0103643:	68 90 5e 10 f0       	push   $0xf0105e90
f0103648:	e8 76 fa ff ff       	call   f01030c3 <cprintf>
f010364d:	83 c4 10             	add    $0x10,%esp
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103650:	83 ec 0c             	sub    $0xc,%esp
f0103653:	ff 75 08             	pushl  0x8(%ebp)
f0103656:	e8 82 fc ff ff       	call   f01032dd <print_trapframe>
f010365b:	83 c4 10             	add    $0x10,%esp
	env_destroy(curenv);
f010365e:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103663:	83 ec 0c             	sub    $0xc,%esp
f0103666:	50                   	push   %eax
f0103667:	e8 a1 f8 ff ff       	call   f0102f0d <env_destroy>
f010366c:	83 c4 10             	add    $0x10,%esp
	
}
f010366f:	90                   	nop
f0103670:	c9                   	leave  
f0103671:	c3                   	ret    

f0103672 <PAGE_FAULT>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER(PAGE_FAULT, T_PGFLT)		
f0103672:	6a 0e                	push   $0xe
f0103674:	eb 06                	jmp    f010367c <_alltraps>

f0103676 <SYSCALL_HANDLER>:

TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL)
f0103676:	6a 00                	push   $0x0
f0103678:	6a 30                	push   $0x30
f010367a:	eb 00                	jmp    f010367c <_alltraps>

f010367c <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:

push %ds 
f010367c:	1e                   	push   %ds
push %es 
f010367d:	06                   	push   %es
pushal 	
f010367e:	60                   	pusha  

mov $(GD_KD), %ax 
f010367f:	66 b8 10 00          	mov    $0x10,%ax
mov %ax,%ds
f0103683:	8e d8                	mov    %eax,%ds
mov %ax,%es
f0103685:	8e c0                	mov    %eax,%es

push %esp
f0103687:	54                   	push   %esp

call trap
f0103688:	e8 ea fe ff ff       	call   f0103577 <trap>

pop %ecx /* poping the pointer to the tf from the stack so that the stack top is at the values of the registers posuhed by pusha*/
f010368d:	59                   	pop    %ecx
popal 	
f010368e:	61                   	popa   
pop %es 
f010368f:	07                   	pop    %es
pop %ds    
f0103690:	1f                   	pop    %ds

/*skipping the trap_no and the error code so that the stack top is at the old eip value*/
add $(8),%esp
f0103691:	83 c4 08             	add    $0x8,%esp

iret
f0103694:	cf                   	iret   

f0103695 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0103695:	55                   	push   %ebp
f0103696:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0103698:	8b 45 08             	mov    0x8(%ebp),%eax
f010369b:	8b 15 3c e7 14 f0    	mov    0xf014e73c,%edx
f01036a1:	29 d0                	sub    %edx,%eax
f01036a3:	c1 f8 02             	sar    $0x2,%eax
f01036a6:	89 c2                	mov    %eax,%edx
f01036a8:	89 d0                	mov    %edx,%eax
f01036aa:	c1 e0 02             	shl    $0x2,%eax
f01036ad:	01 d0                	add    %edx,%eax
f01036af:	c1 e0 02             	shl    $0x2,%eax
f01036b2:	01 d0                	add    %edx,%eax
f01036b4:	c1 e0 02             	shl    $0x2,%eax
f01036b7:	01 d0                	add    %edx,%eax
f01036b9:	89 c1                	mov    %eax,%ecx
f01036bb:	c1 e1 08             	shl    $0x8,%ecx
f01036be:	01 c8                	add    %ecx,%eax
f01036c0:	89 c1                	mov    %eax,%ecx
f01036c2:	c1 e1 10             	shl    $0x10,%ecx
f01036c5:	01 c8                	add    %ecx,%eax
f01036c7:	01 c0                	add    %eax,%eax
f01036c9:	01 d0                	add    %edx,%eax
}
f01036cb:	5d                   	pop    %ebp
f01036cc:	c3                   	ret    

f01036cd <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f01036cd:	55                   	push   %ebp
f01036ce:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f01036d0:	ff 75 08             	pushl  0x8(%ebp)
f01036d3:	e8 bd ff ff ff       	call   f0103695 <to_frame_number>
f01036d8:	83 c4 04             	add    $0x4,%esp
f01036db:	c1 e0 0c             	shl    $0xc,%eax
}
f01036de:	c9                   	leave  
f01036df:	c3                   	ret    

f01036e0 <sys_cputs>:

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void sys_cputs(const char *s, uint32 len)
{
f01036e0:	55                   	push   %ebp
f01036e1:	89 e5                	mov    %esp,%ebp
f01036e3:	83 ec 08             	sub    $0x8,%esp
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01036e6:	83 ec 04             	sub    $0x4,%esp
f01036e9:	ff 75 08             	pushl  0x8(%ebp)
f01036ec:	ff 75 0c             	pushl  0xc(%ebp)
f01036ef:	68 50 60 10 f0       	push   $0xf0106050
f01036f4:	e8 ca f9 ff ff       	call   f01030c3 <cprintf>
f01036f9:	83 c4 10             	add    $0x10,%esp
}
f01036fc:	90                   	nop
f01036fd:	c9                   	leave  
f01036fe:	c3                   	ret    

f01036ff <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	83 ec 18             	sub    $0x18,%esp
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f0103705:	e8 5f d1 ff ff       	call   f0100869 <cons_getc>
f010370a:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010370d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103711:	74 f2                	je     f0103705 <sys_cgetc+0x6>
		/* do nothing */;

	return c;
f0103713:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0103716:	c9                   	leave  
f0103717:	c3                   	ret    

f0103718 <sys_getenvid>:

// Returns the current environment's envid.
static int32 sys_getenvid(void)
{
f0103718:	55                   	push   %ebp
f0103719:	89 e5                	mov    %esp,%ebp
	return curenv->env_id;
f010371b:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103720:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f0103723:	5d                   	pop    %ebp
f0103724:	c3                   	ret    

f0103725 <sys_env_destroy>:
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int sys_env_destroy(int32  envid)
{
f0103725:	55                   	push   %ebp
f0103726:	89 e5                	mov    %esp,%ebp
f0103728:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010372b:	83 ec 04             	sub    $0x4,%esp
f010372e:	6a 01                	push   $0x1
f0103730:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0103733:	50                   	push   %eax
f0103734:	ff 75 08             	pushl  0x8(%ebp)
f0103737:	e8 84 e5 ff ff       	call   f0101cc0 <envid2env>
f010373c:	83 c4 10             	add    $0x10,%esp
f010373f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0103742:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103746:	79 05                	jns    f010374d <sys_env_destroy+0x28>
		return r;
f0103748:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010374b:	eb 5b                	jmp    f01037a8 <sys_env_destroy+0x83>
	if (e == curenv)
f010374d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103750:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f0103755:	39 c2                	cmp    %eax,%edx
f0103757:	75 1b                	jne    f0103774 <sys_env_destroy+0x4f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103759:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f010375e:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103761:	83 ec 08             	sub    $0x8,%esp
f0103764:	50                   	push   %eax
f0103765:	68 55 60 10 f0       	push   $0xf0106055
f010376a:	e8 54 f9 ff ff       	call   f01030c3 <cprintf>
f010376f:	83 c4 10             	add    $0x10,%esp
f0103772:	eb 20                	jmp    f0103794 <sys_env_destroy+0x6f>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103774:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103777:	8b 50 4c             	mov    0x4c(%eax),%edx
f010377a:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f010377f:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103782:	83 ec 04             	sub    $0x4,%esp
f0103785:	52                   	push   %edx
f0103786:	50                   	push   %eax
f0103787:	68 70 60 10 f0       	push   $0xf0106070
f010378c:	e8 32 f9 ff ff       	call   f01030c3 <cprintf>
f0103791:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103794:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103797:	83 ec 0c             	sub    $0xc,%esp
f010379a:	50                   	push   %eax
f010379b:	e8 6d f7 ff ff       	call   f0102f0d <env_destroy>
f01037a0:	83 c4 10             	add    $0x10,%esp
	return 0;
f01037a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037a8:	c9                   	leave  
f01037a9:	c3                   	ret    

f01037aa <sys_env_sleep>:

static void sys_env_sleep()
{
f01037aa:	55                   	push   %ebp
f01037ab:	89 e5                	mov    %esp,%ebp
f01037ad:	83 ec 08             	sub    $0x8,%esp
	env_run_cmd_prmpt();
f01037b0:	e8 73 f7 ff ff       	call   f0102f28 <env_run_cmd_prmpt>
}
f01037b5:	90                   	nop
f01037b6:	c9                   	leave  
f01037b7:	c3                   	ret    

f01037b8 <sys_allocate_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_allocate_page(void *va, int perm)
{
f01037b8:	55                   	push   %ebp
f01037b9:	89 e5                	mov    %esp,%ebp
f01037bb:	83 ec 28             	sub    $0x28,%esp
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	int r;
	struct Env *e = curenv;
f01037be:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f01037c3:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//if ((r = envid2env(envid, &e, 1)) < 0)
		//return r;
	
	struct Frame_Info *ptr_frame_info ;
	r = allocate_frame(&ptr_frame_info) ;
f01037c6:	83 ec 0c             	sub    $0xc,%esp
f01037c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01037cc:	50                   	push   %eax
f01037cd:	e8 7c ec ff ff       	call   f010244e <allocate_frame>
f01037d2:	83 c4 10             	add    $0x10,%esp
f01037d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f01037d8:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f01037dc:	75 08                	jne    f01037e6 <sys_allocate_page+0x2e>
		return r ;
f01037de:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037e1:	e9 cc 00 00 00       	jmp    f01038b2 <sys_allocate_page+0xfa>
	
	//check virtual address to be paged_aligned and < USER_TOP
	if ((uint32)va >= USER_TOP || (uint32)va % PAGE_SIZE != 0)
f01037e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e9:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01037ee:	77 0c                	ja     f01037fc <sys_allocate_page+0x44>
f01037f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f3:	25 ff 0f 00 00       	and    $0xfff,%eax
f01037f8:	85 c0                	test   %eax,%eax
f01037fa:	74 0a                	je     f0103806 <sys_allocate_page+0x4e>
		return E_INVAL;
f01037fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103801:	e9 ac 00 00 00       	jmp    f01038b2 <sys_allocate_page+0xfa>
	
	//check permissions to be appropriatess
	if ((perm & (~PERM_AVAILABLE & ~PERM_WRITEABLE)) != (PERM_USER))
f0103806:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103809:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010380e:	83 f8 04             	cmp    $0x4,%eax
f0103811:	74 0a                	je     f010381d <sys_allocate_page+0x65>
		return E_INVAL;
f0103813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103818:	e9 95 00 00 00       	jmp    f01038b2 <sys_allocate_page+0xfa>
	
			
	uint32 physical_address = to_physical_address(ptr_frame_info) ;
f010381d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103820:	83 ec 0c             	sub    $0xc,%esp
f0103823:	50                   	push   %eax
f0103824:	e8 a4 fe ff ff       	call   f01036cd <to_physical_address>
f0103829:	83 c4 10             	add    $0x10,%esp
f010382c:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	memset(K_VIRTUAL_ADDRESS(physical_address), 0, PAGE_SIZE);
f010382f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103832:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0103835:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103838:	c1 e8 0c             	shr    $0xc,%eax
f010383b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010383e:	a1 28 e7 14 f0       	mov    0xf014e728,%eax
f0103843:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103846:	72 14                	jb     f010385c <sys_allocate_page+0xa4>
f0103848:	ff 75 e8             	pushl  -0x18(%ebp)
f010384b:	68 88 60 10 f0       	push   $0xf0106088
f0103850:	6a 7a                	push   $0x7a
f0103852:	68 b7 60 10 f0       	push   $0xf01060b7
f0103857:	e8 d2 c8 ff ff       	call   f010012e <_panic>
f010385c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010385f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103864:	83 ec 04             	sub    $0x4,%esp
f0103867:	68 00 10 00 00       	push   $0x1000
f010386c:	6a 00                	push   $0x0
f010386e:	50                   	push   %eax
f010386f:	e8 31 0f 00 00       	call   f01047a5 <memset>
f0103874:	83 c4 10             	add    $0x10,%esp
		
	r = map_frame(e->env_pgdir, ptr_frame_info, va, perm) ;
f0103877:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010387a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010387d:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103880:	ff 75 0c             	pushl  0xc(%ebp)
f0103883:	ff 75 08             	pushl  0x8(%ebp)
f0103886:	52                   	push   %edx
f0103887:	50                   	push   %eax
f0103888:	e8 ce ed ff ff       	call   f010265b <map_frame>
f010388d:	83 c4 10             	add    $0x10,%esp
f0103890:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f0103893:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f0103897:	75 14                	jne    f01038ad <sys_allocate_page+0xf5>
	{
		decrement_references(ptr_frame_info);
f0103899:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010389c:	83 ec 0c             	sub    $0xc,%esp
f010389f:	50                   	push   %eax
f01038a0:	e8 47 ec ff ff       	call   f01024ec <decrement_references>
f01038a5:	83 c4 10             	add    $0x10,%esp
		return r;
f01038a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01038ab:	eb 05                	jmp    f01038b2 <sys_allocate_page+0xfa>
	}
	return 0 ;
f01038ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01038b2:	c9                   	leave  
f01038b3:	c3                   	ret    

f01038b4 <sys_get_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_get_page(void *va, int perm)
{
f01038b4:	55                   	push   %ebp
f01038b5:	89 e5                	mov    %esp,%ebp
f01038b7:	83 ec 08             	sub    $0x8,%esp
	return get_page(curenv->env_pgdir, va, perm) ;
f01038ba:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f01038bf:	8b 40 5c             	mov    0x5c(%eax),%eax
f01038c2:	83 ec 04             	sub    $0x4,%esp
f01038c5:	ff 75 0c             	pushl  0xc(%ebp)
f01038c8:	ff 75 08             	pushl  0x8(%ebp)
f01038cb:	50                   	push   %eax
f01038cc:	e8 fd ee ff ff       	call   f01027ce <get_page>
f01038d1:	83 c4 10             	add    $0x10,%esp
}
f01038d4:	c9                   	leave  
f01038d5:	c3                   	ret    

f01038d6 <sys_map_frame>:
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_map_frame(int32 srcenvid, void *srcva, int32 dstenvid, void *dstva, int perm)
{
f01038d6:	55                   	push   %ebp
f01038d7:	89 e5                	mov    %esp,%ebp
f01038d9:	83 ec 08             	sub    $0x8,%esp
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	panic("sys_map_frame not implemented");
f01038dc:	83 ec 04             	sub    $0x4,%esp
f01038df:	68 c6 60 10 f0       	push   $0xf01060c6
f01038e4:	68 b1 00 00 00       	push   $0xb1
f01038e9:	68 b7 60 10 f0       	push   $0xf01060b7
f01038ee:	e8 3b c8 ff ff       	call   f010012e <_panic>

f01038f3 <sys_unmap_frame>:
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int sys_unmap_frame(int32 envid, void *va)
{
f01038f3:	55                   	push   %ebp
f01038f4:	89 e5                	mov    %esp,%ebp
f01038f6:	83 ec 08             	sub    $0x8,%esp
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	panic("sys_page_unmap not implemented");
f01038f9:	83 ec 04             	sub    $0x4,%esp
f01038fc:	68 e4 60 10 f0       	push   $0xf01060e4
f0103901:	68 c0 00 00 00       	push   $0xc0
f0103906:	68 b7 60 10 f0       	push   $0xf01060b7
f010390b:	e8 1e c8 ff ff       	call   f010012e <_panic>

f0103910 <sys_calculate_required_frames>:
}

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
f0103910:	55                   	push   %ebp
f0103911:	89 e5                	mov    %esp,%ebp
f0103913:	83 ec 08             	sub    $0x8,%esp
	return calculate_required_frames(curenv->env_pgdir, start_virtual_address, size); 
f0103916:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f010391b:	8b 40 5c             	mov    0x5c(%eax),%eax
f010391e:	83 ec 04             	sub    $0x4,%esp
f0103921:	ff 75 0c             	pushl  0xc(%ebp)
f0103924:	ff 75 08             	pushl  0x8(%ebp)
f0103927:	50                   	push   %eax
f0103928:	e8 be ee ff ff       	call   f01027eb <calculate_required_frames>
f010392d:	83 c4 10             	add    $0x10,%esp
}
f0103930:	c9                   	leave  
f0103931:	c3                   	ret    

f0103932 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
f0103932:	55                   	push   %ebp
f0103933:	89 e5                	mov    %esp,%ebp
f0103935:	83 ec 08             	sub    $0x8,%esp
	return calculate_free_frames();
f0103938:	e8 cb ee ff ff       	call   f0102808 <calculate_free_frames>
}
f010393d:	c9                   	leave  
f010393e:	c3                   	ret    

f010393f <sys_freeMem>:
void sys_freeMem(void* start_virtual_address, uint32 size)
{
f010393f:	55                   	push   %ebp
f0103940:	89 e5                	mov    %esp,%ebp
f0103942:	83 ec 08             	sub    $0x8,%esp
	freeMem((uint32*)curenv->env_pgdir, (void*)start_virtual_address, size);
f0103945:	a1 b0 de 14 f0       	mov    0xf014deb0,%eax
f010394a:	8b 40 5c             	mov    0x5c(%eax),%eax
f010394d:	83 ec 04             	sub    $0x4,%esp
f0103950:	ff 75 0c             	pushl  0xc(%ebp)
f0103953:	ff 75 08             	pushl  0x8(%ebp)
f0103956:	50                   	push   %eax
f0103957:	e8 d9 ee ff ff       	call   f0102835 <freeMem>
f010395c:	83 c4 10             	add    $0x10,%esp
	return;
f010395f:	90                   	nop
}
f0103960:	c9                   	leave  
f0103961:	c3                   	ret    

f0103962 <syscall>:
// Dispatches to the correct kernel function, passing the arguments.
uint32
syscall(uint32 syscallno, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
f0103962:	55                   	push   %ebp
f0103963:	89 e5                	mov    %esp,%ebp
f0103965:	56                   	push   %esi
f0103966:	53                   	push   %ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno)
f0103967:	83 7d 08 0c          	cmpl   $0xc,0x8(%ebp)
f010396b:	0f 87 19 01 00 00    	ja     f0103a8a <syscall+0x128>
f0103971:	8b 45 08             	mov    0x8(%ebp),%eax
f0103974:	c1 e0 02             	shl    $0x2,%eax
f0103977:	05 04 61 10 f0       	add    $0xf0106104,%eax
f010397c:	8b 00                	mov    (%eax),%eax
f010397e:	ff e0                	jmp    *%eax
	{
		case SYS_cputs:
			sys_cputs((const char*)a1,a2);
f0103980:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103983:	83 ec 08             	sub    $0x8,%esp
f0103986:	ff 75 10             	pushl  0x10(%ebp)
f0103989:	50                   	push   %eax
f010398a:	e8 51 fd ff ff       	call   f01036e0 <sys_cputs>
f010398f:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103992:	b8 00 00 00 00       	mov    $0x0,%eax
f0103997:	e9 f3 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_cgetc:
			return sys_cgetc();
f010399c:	e8 5e fd ff ff       	call   f01036ff <sys_cgetc>
f01039a1:	e9 e9 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_getenvid:
			return sys_getenvid();
f01039a6:	e8 6d fd ff ff       	call   f0103718 <sys_getenvid>
f01039ab:	e9 df 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f01039b0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039b3:	83 ec 0c             	sub    $0xc,%esp
f01039b6:	50                   	push   %eax
f01039b7:	e8 69 fd ff ff       	call   f0103725 <sys_env_destroy>
f01039bc:	83 c4 10             	add    $0x10,%esp
f01039bf:	e9 cb 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_env_sleep:
			sys_env_sleep();
f01039c4:	e8 e1 fd ff ff       	call   f01037aa <sys_env_sleep>
			return 0;
f01039c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01039ce:	e9 bc 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_calc_req_frames:
			return sys_calculate_required_frames(a1, a2);			
f01039d3:	83 ec 08             	sub    $0x8,%esp
f01039d6:	ff 75 10             	pushl  0x10(%ebp)
f01039d9:	ff 75 0c             	pushl  0xc(%ebp)
f01039dc:	e8 2f ff ff ff       	call   f0103910 <sys_calculate_required_frames>
f01039e1:	83 c4 10             	add    $0x10,%esp
f01039e4:	e9 a6 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_calc_free_frames:
			return sys_calculate_free_frames();			
f01039e9:	e8 44 ff ff ff       	call   f0103932 <sys_calculate_free_frames>
f01039ee:	e9 9c 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_freeMem:
			sys_freeMem((void*)a1, a2);
f01039f3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039f6:	83 ec 08             	sub    $0x8,%esp
f01039f9:	ff 75 10             	pushl  0x10(%ebp)
f01039fc:	50                   	push   %eax
f01039fd:	e8 3d ff ff ff       	call   f010393f <sys_freeMem>
f0103a02:	83 c4 10             	add    $0x10,%esp
			return 0;			
f0103a05:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a0a:	e9 80 00 00 00       	jmp    f0103a8f <syscall+0x12d>
			break;
		//======================
		
		case SYS_allocate_page:
			sys_allocate_page((void*)a1, a2);
f0103a0f:	8b 55 10             	mov    0x10(%ebp),%edx
f0103a12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a15:	83 ec 08             	sub    $0x8,%esp
f0103a18:	52                   	push   %edx
f0103a19:	50                   	push   %eax
f0103a1a:	e8 99 fd ff ff       	call   f01037b8 <sys_allocate_page>
f0103a1f:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103a22:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a27:	eb 66                	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_get_page:
			sys_get_page((void*)a1, a2);
f0103a29:	8b 55 10             	mov    0x10(%ebp),%edx
f0103a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a2f:	83 ec 08             	sub    $0x8,%esp
f0103a32:	52                   	push   %edx
f0103a33:	50                   	push   %eax
f0103a34:	e8 7b fe ff ff       	call   f01038b4 <sys_get_page>
f0103a39:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103a3c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a41:	eb 4c                	jmp    f0103a8f <syscall+0x12d>
		break;case SYS_map_frame:
			sys_map_frame(a1, (void*)a2, a3, (void*)a4, a5);
f0103a43:	8b 75 1c             	mov    0x1c(%ebp),%esi
f0103a46:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0103a49:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0103a4c:	8b 55 10             	mov    0x10(%ebp),%edx
f0103a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a52:	83 ec 0c             	sub    $0xc,%esp
f0103a55:	56                   	push   %esi
f0103a56:	53                   	push   %ebx
f0103a57:	51                   	push   %ecx
f0103a58:	52                   	push   %edx
f0103a59:	50                   	push   %eax
f0103a5a:	e8 77 fe ff ff       	call   f01038d6 <sys_map_frame>
f0103a5f:	83 c4 20             	add    $0x20,%esp
			return 0;
f0103a62:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a67:	eb 26                	jmp    f0103a8f <syscall+0x12d>
			break;
		case SYS_unmap_frame:
			sys_unmap_frame(a1, (void*)a2);
f0103a69:	8b 55 10             	mov    0x10(%ebp),%edx
f0103a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a6f:	83 ec 08             	sub    $0x8,%esp
f0103a72:	52                   	push   %edx
f0103a73:	50                   	push   %eax
f0103a74:	e8 7a fe ff ff       	call   f01038f3 <sys_unmap_frame>
f0103a79:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103a7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a81:	eb 0c                	jmp    f0103a8f <syscall+0x12d>
			break;
		case NSYSCALLS:	
			return 	-E_INVAL;
f0103a83:	b8 03 00 00 00       	mov    $0x3,%eax
f0103a88:	eb 05                	jmp    f0103a8f <syscall+0x12d>
			break;
	}
	//panic("syscall not implemented");
	return -E_INVAL;
f0103a8a:	b8 03 00 00 00       	mov    $0x3,%eax
}
f0103a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103a92:	5b                   	pop    %ebx
f0103a93:	5e                   	pop    %esi
f0103a94:	5d                   	pop    %ebp
f0103a95:	c3                   	ret    

f0103a96 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
f0103a96:	55                   	push   %ebp
f0103a97:	89 e5                	mov    %esp,%ebp
f0103a99:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f0103a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a9f:	8b 00                	mov    (%eax),%eax
f0103aa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103aa4:	8b 45 10             	mov    0x10(%ebp),%eax
f0103aa7:	8b 00                	mov    (%eax),%eax
f0103aa9:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0103aac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
	while (l <= r) {
f0103ab3:	e9 ca 00 00 00       	jmp    f0103b82 <stab_binsearch+0xec>
		int true_m = (l + r) / 2, m = true_m;
f0103ab8:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103abb:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0103abe:	01 d0                	add    %edx,%eax
f0103ac0:	89 c2                	mov    %eax,%edx
f0103ac2:	c1 ea 1f             	shr    $0x1f,%edx
f0103ac5:	01 d0                	add    %edx,%eax
f0103ac7:	d1 f8                	sar    %eax
f0103ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103acc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103acf:	89 45 f0             	mov    %eax,-0x10(%ebp)
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ad2:	eb 03                	jmp    f0103ad7 <stab_binsearch+0x41>
			m--;
f0103ad4:	ff 4d f0             	decl   -0x10(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103ada:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103add:	7c 1e                	jl     f0103afd <stab_binsearch+0x67>
f0103adf:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103ae2:	89 d0                	mov    %edx,%eax
f0103ae4:	01 c0                	add    %eax,%eax
f0103ae6:	01 d0                	add    %edx,%eax
f0103ae8:	c1 e0 02             	shl    $0x2,%eax
f0103aeb:	89 c2                	mov    %eax,%edx
f0103aed:	8b 45 08             	mov    0x8(%ebp),%eax
f0103af0:	01 d0                	add    %edx,%eax
f0103af2:	8a 40 04             	mov    0x4(%eax),%al
f0103af5:	0f b6 c0             	movzbl %al,%eax
f0103af8:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103afb:	75 d7                	jne    f0103ad4 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f0103afd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b00:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103b03:	7d 09                	jge    f0103b0e <stab_binsearch+0x78>
			l = true_m + 1;
f0103b05:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b08:	40                   	inc    %eax
f0103b09:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f0103b0c:	eb 74                	jmp    f0103b82 <stab_binsearch+0xec>
		}

		// actual binary search
		any_matches = 1;
f0103b0e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f0103b15:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b18:	89 d0                	mov    %edx,%eax
f0103b1a:	01 c0                	add    %eax,%eax
f0103b1c:	01 d0                	add    %edx,%eax
f0103b1e:	c1 e0 02             	shl    $0x2,%eax
f0103b21:	89 c2                	mov    %eax,%edx
f0103b23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b26:	01 d0                	add    %edx,%eax
f0103b28:	8b 40 08             	mov    0x8(%eax),%eax
f0103b2b:	3b 45 18             	cmp    0x18(%ebp),%eax
f0103b2e:	73 11                	jae    f0103b41 <stab_binsearch+0xab>
			*region_left = m;
f0103b30:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b33:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b36:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f0103b38:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b3b:	40                   	inc    %eax
f0103b3c:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103b3f:	eb 41                	jmp    f0103b82 <stab_binsearch+0xec>
		} else if (stabs[m].n_value > addr) {
f0103b41:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b44:	89 d0                	mov    %edx,%eax
f0103b46:	01 c0                	add    %eax,%eax
f0103b48:	01 d0                	add    %edx,%eax
f0103b4a:	c1 e0 02             	shl    $0x2,%eax
f0103b4d:	89 c2                	mov    %eax,%edx
f0103b4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b52:	01 d0                	add    %edx,%eax
f0103b54:	8b 40 08             	mov    0x8(%eax),%eax
f0103b57:	3b 45 18             	cmp    0x18(%ebp),%eax
f0103b5a:	76 14                	jbe    f0103b70 <stab_binsearch+0xda>
			*region_right = m - 1;
f0103b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b5f:	8d 50 ff             	lea    -0x1(%eax),%edx
f0103b62:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b65:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f0103b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b6a:	48                   	dec    %eax
f0103b6b:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0103b6e:	eb 12                	jmp    f0103b82 <stab_binsearch+0xec>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103b70:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b73:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103b76:	89 10                	mov    %edx,(%eax)
			l = m;
f0103b78:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f0103b7e:	83 45 18 04          	addl   $0x4,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103b82:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0103b85:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0103b88:	0f 8e 2a ff ff ff    	jle    f0103ab8 <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103b8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103b92:	75 0f                	jne    f0103ba3 <stab_binsearch+0x10d>
		*region_right = *region_left - 1;
f0103b94:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b97:	8b 00                	mov    (%eax),%eax
f0103b99:	8d 50 ff             	lea    -0x1(%eax),%edx
f0103b9c:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b9f:	89 10                	mov    %edx,(%eax)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103ba1:	eb 3d                	jmp    f0103be0 <stab_binsearch+0x14a>

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103ba3:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ba6:	8b 00                	mov    (%eax),%eax
f0103ba8:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103bab:	eb 03                	jmp    f0103bb0 <stab_binsearch+0x11a>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0103bad:	ff 4d fc             	decl   -0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0103bb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bb3:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103bb5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103bb8:	7d 1e                	jge    f0103bd8 <stab_binsearch+0x142>
		     l > *region_left && stabs[l].n_type != type;
f0103bba:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103bbd:	89 d0                	mov    %edx,%eax
f0103bbf:	01 c0                	add    %eax,%eax
f0103bc1:	01 d0                	add    %edx,%eax
f0103bc3:	c1 e0 02             	shl    $0x2,%eax
f0103bc6:	89 c2                	mov    %eax,%edx
f0103bc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bcb:	01 d0                	add    %edx,%eax
f0103bcd:	8a 40 04             	mov    0x4(%eax),%al
f0103bd0:	0f b6 c0             	movzbl %al,%eax
f0103bd3:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103bd6:	75 d5                	jne    f0103bad <stab_binsearch+0x117>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bdb:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103bde:	89 10                	mov    %edx,(%eax)
	}
}
f0103be0:	90                   	nop
f0103be1:	c9                   	leave  
f0103be2:	c3                   	ret    

f0103be3 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uint32*  addr, struct Eipdebuginfo *info)
{
f0103be3:	55                   	push   %ebp
f0103be4:	89 e5                	mov    %esp,%ebp
f0103be6:	83 ec 38             	sub    $0x38,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103be9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bec:	c7 00 38 61 10 f0    	movl   $0xf0106138,(%eax)
	info->eip_line = 0;
f0103bf2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bf5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f0103bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bff:	c7 40 08 38 61 10 f0 	movl   $0xf0106138,0x8(%eax)
	info->eip_fn_namelen = 9;
f0103c06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c09:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f0103c10:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c13:	8b 55 08             	mov    0x8(%ebp),%edx
f0103c16:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0103c19:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c1c:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if ((uint32)addr >= USER_LIMIT) {
f0103c23:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c26:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f0103c2b:	76 1e                	jbe    f0103c4b <debuginfo_eip+0x68>
		stabs = __STAB_BEGIN__;
f0103c2d:	c7 45 f4 90 63 10 f0 	movl   $0xf0106390,-0xc(%ebp)
		stab_end = __STAB_END__;
f0103c34:	c7 45 f0 08 ee 10 f0 	movl   $0xf010ee08,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0103c3b:	c7 45 ec 09 ee 10 f0 	movl   $0xf010ee09,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f0103c42:	c7 45 e8 41 26 11 f0 	movl   $0xf0112641,-0x18(%ebp)
f0103c49:	eb 2a                	jmp    f0103c75 <debuginfo_eip+0x92>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f0103c4b:	c7 45 e0 00 00 20 00 	movl   $0x200000,-0x20(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f0103c52:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c55:	8b 00                	mov    (%eax),%eax
f0103c57:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f0103c5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c5d:	8b 40 04             	mov    0x4(%eax),%eax
f0103c60:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f0103c63:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c66:	8b 40 08             	mov    0x8(%eax),%eax
f0103c69:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f0103c6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103c6f:	8b 40 0c             	mov    0xc(%eax),%eax
f0103c72:	89 45 e8             	mov    %eax,-0x18(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103c75:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103c78:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f0103c7b:	76 0a                	jbe    f0103c87 <debuginfo_eip+0xa4>
f0103c7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103c80:	48                   	dec    %eax
f0103c81:	8a 00                	mov    (%eax),%al
f0103c83:	84 c0                	test   %al,%al
f0103c85:	74 0a                	je     f0103c91 <debuginfo_eip+0xae>
		return -1;
f0103c87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103c8c:	e9 01 02 00 00       	jmp    f0103e92 <debuginfo_eip+0x2af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103c91:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c9e:	29 c2                	sub    %eax,%edx
f0103ca0:	89 d0                	mov    %edx,%eax
f0103ca2:	c1 f8 02             	sar    $0x2,%eax
f0103ca5:	89 c2                	mov    %eax,%edx
f0103ca7:	89 d0                	mov    %edx,%eax
f0103ca9:	c1 e0 02             	shl    $0x2,%eax
f0103cac:	01 d0                	add    %edx,%eax
f0103cae:	c1 e0 02             	shl    $0x2,%eax
f0103cb1:	01 d0                	add    %edx,%eax
f0103cb3:	c1 e0 02             	shl    $0x2,%eax
f0103cb6:	01 d0                	add    %edx,%eax
f0103cb8:	89 c1                	mov    %eax,%ecx
f0103cba:	c1 e1 08             	shl    $0x8,%ecx
f0103cbd:	01 c8                	add    %ecx,%eax
f0103cbf:	89 c1                	mov    %eax,%ecx
f0103cc1:	c1 e1 10             	shl    $0x10,%ecx
f0103cc4:	01 c8                	add    %ecx,%eax
f0103cc6:	01 c0                	add    %eax,%eax
f0103cc8:	01 d0                	add    %edx,%eax
f0103cca:	48                   	dec    %eax
f0103ccb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103cce:	ff 75 08             	pushl  0x8(%ebp)
f0103cd1:	6a 64                	push   $0x64
f0103cd3:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0103cd6:	50                   	push   %eax
f0103cd7:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103cda:	50                   	push   %eax
f0103cdb:	ff 75 f4             	pushl  -0xc(%ebp)
f0103cde:	e8 b3 fd ff ff       	call   f0103a96 <stab_binsearch>
f0103ce3:	83 c4 14             	add    $0x14,%esp
	if (lfile == 0)
f0103ce6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ce9:	85 c0                	test   %eax,%eax
f0103ceb:	75 0a                	jne    f0103cf7 <debuginfo_eip+0x114>
		return -1;
f0103ced:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103cf2:	e9 9b 01 00 00       	jmp    f0103e92 <debuginfo_eip+0x2af>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103cf7:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103cfa:	89 45 d0             	mov    %eax,-0x30(%ebp)
	rfun = rfile;
f0103cfd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d00:	89 45 cc             	mov    %eax,-0x34(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103d03:	ff 75 08             	pushl  0x8(%ebp)
f0103d06:	6a 24                	push   $0x24
f0103d08:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0103d0b:	50                   	push   %eax
f0103d0c:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0103d0f:	50                   	push   %eax
f0103d10:	ff 75 f4             	pushl  -0xc(%ebp)
f0103d13:	e8 7e fd ff ff       	call   f0103a96 <stab_binsearch>
f0103d18:	83 c4 14             	add    $0x14,%esp

	if (lfun <= rfun) {
f0103d1b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0103d1e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103d21:	39 c2                	cmp    %eax,%edx
f0103d23:	0f 8f 86 00 00 00    	jg     f0103daf <debuginfo_eip+0x1cc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103d29:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d2c:	89 c2                	mov    %eax,%edx
f0103d2e:	89 d0                	mov    %edx,%eax
f0103d30:	01 c0                	add    %eax,%eax
f0103d32:	01 d0                	add    %edx,%eax
f0103d34:	c1 e0 02             	shl    $0x2,%eax
f0103d37:	89 c2                	mov    %eax,%edx
f0103d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d3c:	01 d0                	add    %edx,%eax
f0103d3e:	8b 00                	mov    (%eax),%eax
f0103d40:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103d43:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103d46:	29 d1                	sub    %edx,%ecx
f0103d48:	89 ca                	mov    %ecx,%edx
f0103d4a:	39 d0                	cmp    %edx,%eax
f0103d4c:	73 22                	jae    f0103d70 <debuginfo_eip+0x18d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103d4e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d51:	89 c2                	mov    %eax,%edx
f0103d53:	89 d0                	mov    %edx,%eax
f0103d55:	01 c0                	add    %eax,%eax
f0103d57:	01 d0                	add    %edx,%eax
f0103d59:	c1 e0 02             	shl    $0x2,%eax
f0103d5c:	89 c2                	mov    %eax,%edx
f0103d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d61:	01 d0                	add    %edx,%eax
f0103d63:	8b 10                	mov    (%eax),%edx
f0103d65:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103d68:	01 c2                	add    %eax,%edx
f0103d6a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d6d:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = (uint32*) stabs[lfun].n_value;
f0103d70:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103d73:	89 c2                	mov    %eax,%edx
f0103d75:	89 d0                	mov    %edx,%eax
f0103d77:	01 c0                	add    %eax,%eax
f0103d79:	01 d0                	add    %edx,%eax
f0103d7b:	c1 e0 02             	shl    $0x2,%eax
f0103d7e:	89 c2                	mov    %eax,%edx
f0103d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103d83:	01 d0                	add    %edx,%eax
f0103d85:	8b 50 08             	mov    0x8(%eax),%edx
f0103d88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d8b:	89 50 10             	mov    %edx,0x10(%eax)
		addr = (uint32*)(addr - (info->eip_fn_addr));
f0103d8e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103d91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d94:	8b 40 10             	mov    0x10(%eax),%eax
f0103d97:	29 c2                	sub    %eax,%edx
f0103d99:	89 d0                	mov    %edx,%eax
f0103d9b:	c1 f8 02             	sar    $0x2,%eax
f0103d9e:	89 45 08             	mov    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103da1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfun;
f0103da7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103daa:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103dad:	eb 15                	jmp    f0103dc4 <debuginfo_eip+0x1e1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103daf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103db2:	8b 55 08             	mov    0x8(%ebp),%edx
f0103db5:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0103db8:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103dbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfile;
f0103dbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103dc1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103dc7:	8b 40 08             	mov    0x8(%eax),%eax
f0103dca:	83 ec 08             	sub    $0x8,%esp
f0103dcd:	6a 3a                	push   $0x3a
f0103dcf:	50                   	push   %eax
f0103dd0:	e8 a4 09 00 00       	call   f0104779 <strfind>
f0103dd5:	83 c4 10             	add    $0x10,%esp
f0103dd8:	89 c2                	mov    %eax,%edx
f0103dda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ddd:	8b 40 08             	mov    0x8(%eax),%eax
f0103de0:	29 c2                	sub    %eax,%edx
f0103de2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103de5:	89 50 0c             	mov    %edx,0xc(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103de8:	eb 03                	jmp    f0103ded <debuginfo_eip+0x20a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103dea:	ff 4d e4             	decl   -0x1c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103ded:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103df0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103df3:	7c 4e                	jl     f0103e43 <debuginfo_eip+0x260>
	       && stabs[lline].n_type != N_SOL
f0103df5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103df8:	89 d0                	mov    %edx,%eax
f0103dfa:	01 c0                	add    %eax,%eax
f0103dfc:	01 d0                	add    %edx,%eax
f0103dfe:	c1 e0 02             	shl    $0x2,%eax
f0103e01:	89 c2                	mov    %eax,%edx
f0103e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e06:	01 d0                	add    %edx,%eax
f0103e08:	8a 40 04             	mov    0x4(%eax),%al
f0103e0b:	3c 84                	cmp    $0x84,%al
f0103e0d:	74 34                	je     f0103e43 <debuginfo_eip+0x260>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103e0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e12:	89 d0                	mov    %edx,%eax
f0103e14:	01 c0                	add    %eax,%eax
f0103e16:	01 d0                	add    %edx,%eax
f0103e18:	c1 e0 02             	shl    $0x2,%eax
f0103e1b:	89 c2                	mov    %eax,%edx
f0103e1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e20:	01 d0                	add    %edx,%eax
f0103e22:	8a 40 04             	mov    0x4(%eax),%al
f0103e25:	3c 64                	cmp    $0x64,%al
f0103e27:	75 c1                	jne    f0103dea <debuginfo_eip+0x207>
f0103e29:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e2c:	89 d0                	mov    %edx,%eax
f0103e2e:	01 c0                	add    %eax,%eax
f0103e30:	01 d0                	add    %edx,%eax
f0103e32:	c1 e0 02             	shl    $0x2,%eax
f0103e35:	89 c2                	mov    %eax,%edx
f0103e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e3a:	01 d0                	add    %edx,%eax
f0103e3c:	8b 40 08             	mov    0x8(%eax),%eax
f0103e3f:	85 c0                	test   %eax,%eax
f0103e41:	74 a7                	je     f0103dea <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103e43:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e46:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103e49:	7c 42                	jl     f0103e8d <debuginfo_eip+0x2aa>
f0103e4b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e4e:	89 d0                	mov    %edx,%eax
f0103e50:	01 c0                	add    %eax,%eax
f0103e52:	01 d0                	add    %edx,%eax
f0103e54:	c1 e0 02             	shl    $0x2,%eax
f0103e57:	89 c2                	mov    %eax,%edx
f0103e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e5c:	01 d0                	add    %edx,%eax
f0103e5e:	8b 00                	mov    (%eax),%eax
f0103e60:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103e63:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103e66:	29 d1                	sub    %edx,%ecx
f0103e68:	89 ca                	mov    %ecx,%edx
f0103e6a:	39 d0                	cmp    %edx,%eax
f0103e6c:	73 1f                	jae    f0103e8d <debuginfo_eip+0x2aa>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103e6e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103e71:	89 d0                	mov    %edx,%eax
f0103e73:	01 c0                	add    %eax,%eax
f0103e75:	01 d0                	add    %edx,%eax
f0103e77:	c1 e0 02             	shl    $0x2,%eax
f0103e7a:	89 c2                	mov    %eax,%edx
f0103e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e7f:	01 d0                	add    %edx,%eax
f0103e81:	8b 10                	mov    (%eax),%edx
f0103e83:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103e86:	01 c2                	add    %eax,%edx
f0103e88:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e8b:	89 10                	mov    %edx,(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f0103e8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103e92:	c9                   	leave  
f0103e93:	c3                   	ret    

f0103e94 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103e94:	55                   	push   %ebp
f0103e95:	89 e5                	mov    %esp,%ebp
f0103e97:	53                   	push   %ebx
f0103e98:	83 ec 14             	sub    $0x14,%esp
f0103e9b:	8b 45 10             	mov    0x10(%ebp),%eax
f0103e9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103ea1:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ea4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103ea7:	8b 45 18             	mov    0x18(%ebp),%eax
f0103eaa:	ba 00 00 00 00       	mov    $0x0,%edx
f0103eaf:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103eb2:	77 55                	ja     f0103f09 <printnum+0x75>
f0103eb4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103eb7:	72 05                	jb     f0103ebe <printnum+0x2a>
f0103eb9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0103ebc:	77 4b                	ja     f0103f09 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103ebe:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0103ec1:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103ec4:	8b 45 18             	mov    0x18(%ebp),%eax
f0103ec7:	ba 00 00 00 00       	mov    $0x0,%edx
f0103ecc:	52                   	push   %edx
f0103ecd:	50                   	push   %eax
f0103ece:	ff 75 f4             	pushl  -0xc(%ebp)
f0103ed1:	ff 75 f0             	pushl  -0x10(%ebp)
f0103ed4:	e8 5b 0c 00 00       	call   f0104b34 <__udivdi3>
f0103ed9:	83 c4 10             	add    $0x10,%esp
f0103edc:	83 ec 04             	sub    $0x4,%esp
f0103edf:	ff 75 20             	pushl  0x20(%ebp)
f0103ee2:	53                   	push   %ebx
f0103ee3:	ff 75 18             	pushl  0x18(%ebp)
f0103ee6:	52                   	push   %edx
f0103ee7:	50                   	push   %eax
f0103ee8:	ff 75 0c             	pushl  0xc(%ebp)
f0103eeb:	ff 75 08             	pushl  0x8(%ebp)
f0103eee:	e8 a1 ff ff ff       	call   f0103e94 <printnum>
f0103ef3:	83 c4 20             	add    $0x20,%esp
f0103ef6:	eb 1a                	jmp    f0103f12 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ef8:	83 ec 08             	sub    $0x8,%esp
f0103efb:	ff 75 0c             	pushl  0xc(%ebp)
f0103efe:	ff 75 20             	pushl  0x20(%ebp)
f0103f01:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f04:	ff d0                	call   *%eax
f0103f06:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103f09:	ff 4d 1c             	decl   0x1c(%ebp)
f0103f0c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f0103f10:	7f e6                	jg     f0103ef8 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103f12:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0103f15:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103f1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103f20:	53                   	push   %ebx
f0103f21:	51                   	push   %ecx
f0103f22:	52                   	push   %edx
f0103f23:	50                   	push   %eax
f0103f24:	e8 1b 0d 00 00       	call   f0104c44 <__umoddi3>
f0103f29:	83 c4 10             	add    $0x10,%esp
f0103f2c:	05 00 62 10 f0       	add    $0xf0106200,%eax
f0103f31:	8a 00                	mov    (%eax),%al
f0103f33:	0f be c0             	movsbl %al,%eax
f0103f36:	83 ec 08             	sub    $0x8,%esp
f0103f39:	ff 75 0c             	pushl  0xc(%ebp)
f0103f3c:	50                   	push   %eax
f0103f3d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f40:	ff d0                	call   *%eax
f0103f42:	83 c4 10             	add    $0x10,%esp
}
f0103f45:	90                   	nop
f0103f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103f49:	c9                   	leave  
f0103f4a:	c3                   	ret    

f0103f4b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103f4b:	55                   	push   %ebp
f0103f4c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103f4e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103f52:	7e 1c                	jle    f0103f70 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
f0103f54:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f57:	8b 00                	mov    (%eax),%eax
f0103f59:	8d 50 08             	lea    0x8(%eax),%edx
f0103f5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f5f:	89 10                	mov    %edx,(%eax)
f0103f61:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f64:	8b 00                	mov    (%eax),%eax
f0103f66:	83 e8 08             	sub    $0x8,%eax
f0103f69:	8b 50 04             	mov    0x4(%eax),%edx
f0103f6c:	8b 00                	mov    (%eax),%eax
f0103f6e:	eb 40                	jmp    f0103fb0 <getuint+0x65>
	else if (lflag)
f0103f70:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103f74:	74 1e                	je     f0103f94 <getuint+0x49>
		return va_arg(*ap, unsigned long);
f0103f76:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f79:	8b 00                	mov    (%eax),%eax
f0103f7b:	8d 50 04             	lea    0x4(%eax),%edx
f0103f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f81:	89 10                	mov    %edx,(%eax)
f0103f83:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f86:	8b 00                	mov    (%eax),%eax
f0103f88:	83 e8 04             	sub    $0x4,%eax
f0103f8b:	8b 00                	mov    (%eax),%eax
f0103f8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103f92:	eb 1c                	jmp    f0103fb0 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
f0103f94:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f97:	8b 00                	mov    (%eax),%eax
f0103f99:	8d 50 04             	lea    0x4(%eax),%edx
f0103f9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9f:	89 10                	mov    %edx,(%eax)
f0103fa1:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fa4:	8b 00                	mov    (%eax),%eax
f0103fa6:	83 e8 04             	sub    $0x4,%eax
f0103fa9:	8b 00                	mov    (%eax),%eax
f0103fab:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103fb0:	5d                   	pop    %ebp
f0103fb1:	c3                   	ret    

f0103fb2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103fb2:	55                   	push   %ebp
f0103fb3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103fb5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103fb9:	7e 1c                	jle    f0103fd7 <getint+0x25>
		return va_arg(*ap, long long);
f0103fbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fbe:	8b 00                	mov    (%eax),%eax
f0103fc0:	8d 50 08             	lea    0x8(%eax),%edx
f0103fc3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fc6:	89 10                	mov    %edx,(%eax)
f0103fc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fcb:	8b 00                	mov    (%eax),%eax
f0103fcd:	83 e8 08             	sub    $0x8,%eax
f0103fd0:	8b 50 04             	mov    0x4(%eax),%edx
f0103fd3:	8b 00                	mov    (%eax),%eax
f0103fd5:	eb 38                	jmp    f010400f <getint+0x5d>
	else if (lflag)
f0103fd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103fdb:	74 1a                	je     f0103ff7 <getint+0x45>
		return va_arg(*ap, long);
f0103fdd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe0:	8b 00                	mov    (%eax),%eax
f0103fe2:	8d 50 04             	lea    0x4(%eax),%edx
f0103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fe8:	89 10                	mov    %edx,(%eax)
f0103fea:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fed:	8b 00                	mov    (%eax),%eax
f0103fef:	83 e8 04             	sub    $0x4,%eax
f0103ff2:	8b 00                	mov    (%eax),%eax
f0103ff4:	99                   	cltd   
f0103ff5:	eb 18                	jmp    f010400f <getint+0x5d>
	else
		return va_arg(*ap, int);
f0103ff7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ffa:	8b 00                	mov    (%eax),%eax
f0103ffc:	8d 50 04             	lea    0x4(%eax),%edx
f0103fff:	8b 45 08             	mov    0x8(%ebp),%eax
f0104002:	89 10                	mov    %edx,(%eax)
f0104004:	8b 45 08             	mov    0x8(%ebp),%eax
f0104007:	8b 00                	mov    (%eax),%eax
f0104009:	83 e8 04             	sub    $0x4,%eax
f010400c:	8b 00                	mov    (%eax),%eax
f010400e:	99                   	cltd   
}
f010400f:	5d                   	pop    %ebp
f0104010:	c3                   	ret    

f0104011 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104011:	55                   	push   %ebp
f0104012:	89 e5                	mov    %esp,%ebp
f0104014:	56                   	push   %esi
f0104015:	53                   	push   %ebx
f0104016:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104019:	eb 17                	jmp    f0104032 <vprintfmt+0x21>
			if (ch == '\0')
f010401b:	85 db                	test   %ebx,%ebx
f010401d:	0f 84 af 03 00 00    	je     f01043d2 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
f0104023:	83 ec 08             	sub    $0x8,%esp
f0104026:	ff 75 0c             	pushl  0xc(%ebp)
f0104029:	53                   	push   %ebx
f010402a:	8b 45 08             	mov    0x8(%ebp),%eax
f010402d:	ff d0                	call   *%eax
f010402f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104032:	8b 45 10             	mov    0x10(%ebp),%eax
f0104035:	8d 50 01             	lea    0x1(%eax),%edx
f0104038:	89 55 10             	mov    %edx,0x10(%ebp)
f010403b:	8a 00                	mov    (%eax),%al
f010403d:	0f b6 d8             	movzbl %al,%ebx
f0104040:	83 fb 25             	cmp    $0x25,%ebx
f0104043:	75 d6                	jne    f010401b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0104045:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0104049:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f0104050:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104057:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f010405e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104065:	8b 45 10             	mov    0x10(%ebp),%eax
f0104068:	8d 50 01             	lea    0x1(%eax),%edx
f010406b:	89 55 10             	mov    %edx,0x10(%ebp)
f010406e:	8a 00                	mov    (%eax),%al
f0104070:	0f b6 d8             	movzbl %al,%ebx
f0104073:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0104076:	83 f8 55             	cmp    $0x55,%eax
f0104079:	0f 87 2b 03 00 00    	ja     f01043aa <vprintfmt+0x399>
f010407f:	8b 04 85 24 62 10 f0 	mov    -0xfef9ddc(,%eax,4),%eax
f0104086:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0104088:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f010408c:	eb d7                	jmp    f0104065 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f010408e:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f0104092:	eb d1                	jmp    f0104065 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104094:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f010409b:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010409e:	89 d0                	mov    %edx,%eax
f01040a0:	c1 e0 02             	shl    $0x2,%eax
f01040a3:	01 d0                	add    %edx,%eax
f01040a5:	01 c0                	add    %eax,%eax
f01040a7:	01 d8                	add    %ebx,%eax
f01040a9:	83 e8 30             	sub    $0x30,%eax
f01040ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f01040af:	8b 45 10             	mov    0x10(%ebp),%eax
f01040b2:	8a 00                	mov    (%eax),%al
f01040b4:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f01040b7:	83 fb 2f             	cmp    $0x2f,%ebx
f01040ba:	7e 3e                	jle    f01040fa <vprintfmt+0xe9>
f01040bc:	83 fb 39             	cmp    $0x39,%ebx
f01040bf:	7f 39                	jg     f01040fa <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01040c1:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01040c4:	eb d5                	jmp    f010409b <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01040c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01040c9:	83 c0 04             	add    $0x4,%eax
f01040cc:	89 45 14             	mov    %eax,0x14(%ebp)
f01040cf:	8b 45 14             	mov    0x14(%ebp),%eax
f01040d2:	83 e8 04             	sub    $0x4,%eax
f01040d5:	8b 00                	mov    (%eax),%eax
f01040d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f01040da:	eb 1f                	jmp    f01040fb <vprintfmt+0xea>

		case '.':
			if (width < 0)
f01040dc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01040e0:	79 83                	jns    f0104065 <vprintfmt+0x54>
				width = 0;
f01040e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f01040e9:	e9 77 ff ff ff       	jmp    f0104065 <vprintfmt+0x54>

		case '#':
			altflag = 1;
f01040ee:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01040f5:	e9 6b ff ff ff       	jmp    f0104065 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
f01040fa:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01040fb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01040ff:	0f 89 60 ff ff ff    	jns    f0104065 <vprintfmt+0x54>
				width = precision, precision = -1;
f0104105:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104108:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010410b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f0104112:	e9 4e ff ff ff       	jmp    f0104065 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104117:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
f010411a:	e9 46 ff ff ff       	jmp    f0104065 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010411f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104122:	83 c0 04             	add    $0x4,%eax
f0104125:	89 45 14             	mov    %eax,0x14(%ebp)
f0104128:	8b 45 14             	mov    0x14(%ebp),%eax
f010412b:	83 e8 04             	sub    $0x4,%eax
f010412e:	8b 00                	mov    (%eax),%eax
f0104130:	83 ec 08             	sub    $0x8,%esp
f0104133:	ff 75 0c             	pushl  0xc(%ebp)
f0104136:	50                   	push   %eax
f0104137:	8b 45 08             	mov    0x8(%ebp),%eax
f010413a:	ff d0                	call   *%eax
f010413c:	83 c4 10             	add    $0x10,%esp
			break;
f010413f:	e9 89 02 00 00       	jmp    f01043cd <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104144:	8b 45 14             	mov    0x14(%ebp),%eax
f0104147:	83 c0 04             	add    $0x4,%eax
f010414a:	89 45 14             	mov    %eax,0x14(%ebp)
f010414d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104150:	83 e8 04             	sub    $0x4,%eax
f0104153:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f0104155:	85 db                	test   %ebx,%ebx
f0104157:	79 02                	jns    f010415b <vprintfmt+0x14a>
				err = -err;
f0104159:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f010415b:	83 fb 07             	cmp    $0x7,%ebx
f010415e:	7f 0b                	jg     f010416b <vprintfmt+0x15a>
f0104160:	8b 34 9d e0 61 10 f0 	mov    -0xfef9e20(,%ebx,4),%esi
f0104167:	85 f6                	test   %esi,%esi
f0104169:	75 19                	jne    f0104184 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
f010416b:	53                   	push   %ebx
f010416c:	68 11 62 10 f0       	push   $0xf0106211
f0104171:	ff 75 0c             	pushl  0xc(%ebp)
f0104174:	ff 75 08             	pushl  0x8(%ebp)
f0104177:	e8 5e 02 00 00       	call   f01043da <printfmt>
f010417c:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
f010417f:	e9 49 02 00 00       	jmp    f01043cd <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0104184:	56                   	push   %esi
f0104185:	68 1a 62 10 f0       	push   $0xf010621a
f010418a:	ff 75 0c             	pushl  0xc(%ebp)
f010418d:	ff 75 08             	pushl  0x8(%ebp)
f0104190:	e8 45 02 00 00       	call   f01043da <printfmt>
f0104195:	83 c4 10             	add    $0x10,%esp
			break;
f0104198:	e9 30 02 00 00       	jmp    f01043cd <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010419d:	8b 45 14             	mov    0x14(%ebp),%eax
f01041a0:	83 c0 04             	add    $0x4,%eax
f01041a3:	89 45 14             	mov    %eax,0x14(%ebp)
f01041a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01041a9:	83 e8 04             	sub    $0x4,%eax
f01041ac:	8b 30                	mov    (%eax),%esi
f01041ae:	85 f6                	test   %esi,%esi
f01041b0:	75 05                	jne    f01041b7 <vprintfmt+0x1a6>
				p = "(null)";
f01041b2:	be 1d 62 10 f0       	mov    $0xf010621d,%esi
			if (width > 0 && padc != '-')
f01041b7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041bb:	7e 6d                	jle    f010422a <vprintfmt+0x219>
f01041bd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f01041c1:	74 67                	je     f010422a <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
f01041c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041c6:	83 ec 08             	sub    $0x8,%esp
f01041c9:	50                   	push   %eax
f01041ca:	56                   	push   %esi
f01041cb:	e8 0a 04 00 00       	call   f01045da <strnlen>
f01041d0:	83 c4 10             	add    $0x10,%esp
f01041d3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f01041d6:	eb 16                	jmp    f01041ee <vprintfmt+0x1dd>
					putch(padc, putdat);
f01041d8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f01041dc:	83 ec 08             	sub    $0x8,%esp
f01041df:	ff 75 0c             	pushl  0xc(%ebp)
f01041e2:	50                   	push   %eax
f01041e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01041e6:	ff d0                	call   *%eax
f01041e8:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01041eb:	ff 4d e4             	decl   -0x1c(%ebp)
f01041ee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01041f2:	7f e4                	jg     f01041d8 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01041f4:	eb 34                	jmp    f010422a <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
f01041f6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01041fa:	74 1c                	je     f0104218 <vprintfmt+0x207>
f01041fc:	83 fb 1f             	cmp    $0x1f,%ebx
f01041ff:	7e 05                	jle    f0104206 <vprintfmt+0x1f5>
f0104201:	83 fb 7e             	cmp    $0x7e,%ebx
f0104204:	7e 12                	jle    f0104218 <vprintfmt+0x207>
					putch('?', putdat);
f0104206:	83 ec 08             	sub    $0x8,%esp
f0104209:	ff 75 0c             	pushl  0xc(%ebp)
f010420c:	6a 3f                	push   $0x3f
f010420e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104211:	ff d0                	call   *%eax
f0104213:	83 c4 10             	add    $0x10,%esp
f0104216:	eb 0f                	jmp    f0104227 <vprintfmt+0x216>
				else
					putch(ch, putdat);
f0104218:	83 ec 08             	sub    $0x8,%esp
f010421b:	ff 75 0c             	pushl  0xc(%ebp)
f010421e:	53                   	push   %ebx
f010421f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104222:	ff d0                	call   *%eax
f0104224:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104227:	ff 4d e4             	decl   -0x1c(%ebp)
f010422a:	89 f0                	mov    %esi,%eax
f010422c:	8d 70 01             	lea    0x1(%eax),%esi
f010422f:	8a 00                	mov    (%eax),%al
f0104231:	0f be d8             	movsbl %al,%ebx
f0104234:	85 db                	test   %ebx,%ebx
f0104236:	74 24                	je     f010425c <vprintfmt+0x24b>
f0104238:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010423c:	78 b8                	js     f01041f6 <vprintfmt+0x1e5>
f010423e:	ff 4d e0             	decl   -0x20(%ebp)
f0104241:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104245:	79 af                	jns    f01041f6 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104247:	eb 13                	jmp    f010425c <vprintfmt+0x24b>
				putch(' ', putdat);
f0104249:	83 ec 08             	sub    $0x8,%esp
f010424c:	ff 75 0c             	pushl  0xc(%ebp)
f010424f:	6a 20                	push   $0x20
f0104251:	8b 45 08             	mov    0x8(%ebp),%eax
f0104254:	ff d0                	call   *%eax
f0104256:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104259:	ff 4d e4             	decl   -0x1c(%ebp)
f010425c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104260:	7f e7                	jg     f0104249 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
f0104262:	e9 66 01 00 00       	jmp    f01043cd <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104267:	83 ec 08             	sub    $0x8,%esp
f010426a:	ff 75 e8             	pushl  -0x18(%ebp)
f010426d:	8d 45 14             	lea    0x14(%ebp),%eax
f0104270:	50                   	push   %eax
f0104271:	e8 3c fd ff ff       	call   f0103fb2 <getint>
f0104276:	83 c4 10             	add    $0x10,%esp
f0104279:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010427c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f010427f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104282:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104285:	85 d2                	test   %edx,%edx
f0104287:	79 23                	jns    f01042ac <vprintfmt+0x29b>
				putch('-', putdat);
f0104289:	83 ec 08             	sub    $0x8,%esp
f010428c:	ff 75 0c             	pushl  0xc(%ebp)
f010428f:	6a 2d                	push   $0x2d
f0104291:	8b 45 08             	mov    0x8(%ebp),%eax
f0104294:	ff d0                	call   *%eax
f0104296:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
f0104299:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010429c:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010429f:	f7 d8                	neg    %eax
f01042a1:	83 d2 00             	adc    $0x0,%edx
f01042a4:	f7 da                	neg    %edx
f01042a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01042a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f01042ac:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f01042b3:	e9 bc 00 00 00       	jmp    f0104374 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01042b8:	83 ec 08             	sub    $0x8,%esp
f01042bb:	ff 75 e8             	pushl  -0x18(%ebp)
f01042be:	8d 45 14             	lea    0x14(%ebp),%eax
f01042c1:	50                   	push   %eax
f01042c2:	e8 84 fc ff ff       	call   f0103f4b <getuint>
f01042c7:	83 c4 10             	add    $0x10,%esp
f01042ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01042cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f01042d0:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f01042d7:	e9 98 00 00 00       	jmp    f0104374 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01042dc:	83 ec 08             	sub    $0x8,%esp
f01042df:	ff 75 0c             	pushl  0xc(%ebp)
f01042e2:	6a 58                	push   $0x58
f01042e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01042e7:	ff d0                	call   *%eax
f01042e9:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f01042ec:	83 ec 08             	sub    $0x8,%esp
f01042ef:	ff 75 0c             	pushl  0xc(%ebp)
f01042f2:	6a 58                	push   $0x58
f01042f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01042f7:	ff d0                	call   *%eax
f01042f9:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f01042fc:	83 ec 08             	sub    $0x8,%esp
f01042ff:	ff 75 0c             	pushl  0xc(%ebp)
f0104302:	6a 58                	push   $0x58
f0104304:	8b 45 08             	mov    0x8(%ebp),%eax
f0104307:	ff d0                	call   *%eax
f0104309:	83 c4 10             	add    $0x10,%esp
			break;
f010430c:	e9 bc 00 00 00       	jmp    f01043cd <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
f0104311:	83 ec 08             	sub    $0x8,%esp
f0104314:	ff 75 0c             	pushl  0xc(%ebp)
f0104317:	6a 30                	push   $0x30
f0104319:	8b 45 08             	mov    0x8(%ebp),%eax
f010431c:	ff d0                	call   *%eax
f010431e:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
f0104321:	83 ec 08             	sub    $0x8,%esp
f0104324:	ff 75 0c             	pushl  0xc(%ebp)
f0104327:	6a 78                	push   $0x78
f0104329:	8b 45 08             	mov    0x8(%ebp),%eax
f010432c:	ff d0                	call   *%eax
f010432e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
f0104331:	8b 45 14             	mov    0x14(%ebp),%eax
f0104334:	83 c0 04             	add    $0x4,%eax
f0104337:	89 45 14             	mov    %eax,0x14(%ebp)
f010433a:	8b 45 14             	mov    0x14(%ebp),%eax
f010433d:	83 e8 04             	sub    $0x4,%eax
f0104340:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104342:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
f010434c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f0104353:	eb 1f                	jmp    f0104374 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0104355:	83 ec 08             	sub    $0x8,%esp
f0104358:	ff 75 e8             	pushl  -0x18(%ebp)
f010435b:	8d 45 14             	lea    0x14(%ebp),%eax
f010435e:	50                   	push   %eax
f010435f:	e8 e7 fb ff ff       	call   f0103f4b <getuint>
f0104364:	83 c4 10             	add    $0x10,%esp
f0104367:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010436a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f010436d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104374:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0104378:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010437b:	83 ec 04             	sub    $0x4,%esp
f010437e:	52                   	push   %edx
f010437f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104382:	50                   	push   %eax
f0104383:	ff 75 f4             	pushl  -0xc(%ebp)
f0104386:	ff 75 f0             	pushl  -0x10(%ebp)
f0104389:	ff 75 0c             	pushl  0xc(%ebp)
f010438c:	ff 75 08             	pushl  0x8(%ebp)
f010438f:	e8 00 fb ff ff       	call   f0103e94 <printnum>
f0104394:	83 c4 20             	add    $0x20,%esp
			break;
f0104397:	eb 34                	jmp    f01043cd <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104399:	83 ec 08             	sub    $0x8,%esp
f010439c:	ff 75 0c             	pushl  0xc(%ebp)
f010439f:	53                   	push   %ebx
f01043a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01043a3:	ff d0                	call   *%eax
f01043a5:	83 c4 10             	add    $0x10,%esp
			break;
f01043a8:	eb 23                	jmp    f01043cd <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01043aa:	83 ec 08             	sub    $0x8,%esp
f01043ad:	ff 75 0c             	pushl  0xc(%ebp)
f01043b0:	6a 25                	push   $0x25
f01043b2:	8b 45 08             	mov    0x8(%ebp),%eax
f01043b5:	ff d0                	call   *%eax
f01043b7:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
f01043ba:	ff 4d 10             	decl   0x10(%ebp)
f01043bd:	eb 03                	jmp    f01043c2 <vprintfmt+0x3b1>
f01043bf:	ff 4d 10             	decl   0x10(%ebp)
f01043c2:	8b 45 10             	mov    0x10(%ebp),%eax
f01043c5:	48                   	dec    %eax
f01043c6:	8a 00                	mov    (%eax),%al
f01043c8:	3c 25                	cmp    $0x25,%al
f01043ca:	75 f3                	jne    f01043bf <vprintfmt+0x3ae>
				/* do nothing */;
			break;
f01043cc:	90                   	nop
		}
	}
f01043cd:	e9 47 fc ff ff       	jmp    f0104019 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
f01043d2:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f01043d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01043d6:	5b                   	pop    %ebx
f01043d7:	5e                   	pop    %esi
f01043d8:	5d                   	pop    %ebp
f01043d9:	c3                   	ret    

f01043da <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01043da:	55                   	push   %ebp
f01043db:	89 e5                	mov    %esp,%ebp
f01043dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01043e0:	8d 45 10             	lea    0x10(%ebp),%eax
f01043e3:	83 c0 04             	add    $0x4,%eax
f01043e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f01043e9:	8b 45 10             	mov    0x10(%ebp),%eax
f01043ec:	ff 75 f4             	pushl  -0xc(%ebp)
f01043ef:	50                   	push   %eax
f01043f0:	ff 75 0c             	pushl  0xc(%ebp)
f01043f3:	ff 75 08             	pushl  0x8(%ebp)
f01043f6:	e8 16 fc ff ff       	call   f0104011 <vprintfmt>
f01043fb:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
f01043fe:	90                   	nop
f01043ff:	c9                   	leave  
f0104400:	c3                   	ret    

f0104401 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104401:	55                   	push   %ebp
f0104402:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f0104404:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104407:	8b 40 08             	mov    0x8(%eax),%eax
f010440a:	8d 50 01             	lea    0x1(%eax),%edx
f010440d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104410:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f0104413:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104416:	8b 10                	mov    (%eax),%edx
f0104418:	8b 45 0c             	mov    0xc(%ebp),%eax
f010441b:	8b 40 04             	mov    0x4(%eax),%eax
f010441e:	39 c2                	cmp    %eax,%edx
f0104420:	73 12                	jae    f0104434 <sprintputch+0x33>
		*b->buf++ = ch;
f0104422:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104425:	8b 00                	mov    (%eax),%eax
f0104427:	8d 48 01             	lea    0x1(%eax),%ecx
f010442a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010442d:	89 0a                	mov    %ecx,(%edx)
f010442f:	8b 55 08             	mov    0x8(%ebp),%edx
f0104432:	88 10                	mov    %dl,(%eax)
}
f0104434:	90                   	nop
f0104435:	5d                   	pop    %ebp
f0104436:	c3                   	ret    

f0104437 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104437:	55                   	push   %ebp
f0104438:	89 e5                	mov    %esp,%ebp
f010443a:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f010443d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104440:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104443:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104446:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104449:	8b 45 08             	mov    0x8(%ebp),%eax
f010444c:	01 d0                	add    %edx,%eax
f010444e:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104458:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010445c:	74 06                	je     f0104464 <vsnprintf+0x2d>
f010445e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104462:	7f 07                	jg     f010446b <vsnprintf+0x34>
		return -E_INVAL;
f0104464:	b8 03 00 00 00       	mov    $0x3,%eax
f0104469:	eb 20                	jmp    f010448b <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010446b:	ff 75 14             	pushl  0x14(%ebp)
f010446e:	ff 75 10             	pushl  0x10(%ebp)
f0104471:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104474:	50                   	push   %eax
f0104475:	68 01 44 10 f0       	push   $0xf0104401
f010447a:	e8 92 fb ff ff       	call   f0104011 <vprintfmt>
f010447f:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
f0104482:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104485:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104488:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f010448b:	c9                   	leave  
f010448c:	c3                   	ret    

f010448d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010448d:	55                   	push   %ebp
f010448e:	89 e5                	mov    %esp,%ebp
f0104490:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104493:	8d 45 10             	lea    0x10(%ebp),%eax
f0104496:	83 c0 04             	add    $0x4,%eax
f0104499:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f010449c:	8b 45 10             	mov    0x10(%ebp),%eax
f010449f:	ff 75 f4             	pushl  -0xc(%ebp)
f01044a2:	50                   	push   %eax
f01044a3:	ff 75 0c             	pushl  0xc(%ebp)
f01044a6:	ff 75 08             	pushl  0x8(%ebp)
f01044a9:	e8 89 ff ff ff       	call   f0104437 <vsnprintf>
f01044ae:	83 c4 10             	add    $0x10,%esp
f01044b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
f01044b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f01044b7:	c9                   	leave  
f01044b8:	c3                   	ret    

f01044b9 <readline>:

#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
f01044b9:	55                   	push   %ebp
f01044ba:	89 e5                	mov    %esp,%ebp
f01044bc:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing;
	
	if (prompt != NULL)
f01044bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01044c3:	74 13                	je     f01044d8 <readline+0x1f>
		cprintf("%s", prompt);
f01044c5:	83 ec 08             	sub    $0x8,%esp
f01044c8:	ff 75 08             	pushl  0x8(%ebp)
f01044cb:	68 7c 63 10 f0       	push   $0xf010637c
f01044d0:	e8 ee eb ff ff       	call   f01030c3 <cprintf>
f01044d5:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
f01044d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);	
f01044df:	83 ec 0c             	sub    $0xc,%esp
f01044e2:	6a 00                	push   $0x0
f01044e4:	e8 5e c4 ff ff       	call   f0100947 <iscons>
f01044e9:	83 c4 10             	add    $0x10,%esp
f01044ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
f01044ef:	e8 3a c4 ff ff       	call   f010092e <getchar>
f01044f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f01044f7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01044fb:	79 22                	jns    f010451f <readline+0x66>
			if (c != -E_EOF)
f01044fd:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
f0104501:	0f 84 ad 00 00 00    	je     f01045b4 <readline+0xfb>
				cprintf("read error: %e\n", c);			
f0104507:	83 ec 08             	sub    $0x8,%esp
f010450a:	ff 75 ec             	pushl  -0x14(%ebp)
f010450d:	68 7f 63 10 f0       	push   $0xf010637f
f0104512:	e8 ac eb ff ff       	call   f01030c3 <cprintf>
f0104517:	83 c4 10             	add    $0x10,%esp
			return;
f010451a:	e9 95 00 00 00       	jmp    f01045b4 <readline+0xfb>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010451f:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f0104523:	7e 34                	jle    f0104559 <readline+0xa0>
f0104525:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f010452c:	7f 2b                	jg     f0104559 <readline+0xa0>
			if (echoing)
f010452e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104532:	74 0e                	je     f0104542 <readline+0x89>
				cputchar(c);
f0104534:	83 ec 0c             	sub    $0xc,%esp
f0104537:	ff 75 ec             	pushl  -0x14(%ebp)
f010453a:	e8 d8 c3 ff ff       	call   f0100917 <cputchar>
f010453f:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104545:	8d 50 01             	lea    0x1(%eax),%edx
f0104548:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010454b:	89 c2                	mov    %eax,%edx
f010454d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104550:	01 d0                	add    %edx,%eax
f0104552:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0104555:	88 10                	mov    %dl,(%eax)
f0104557:	eb 56                	jmp    f01045af <readline+0xf6>
		} else if (c == '\b' && i > 0) {
f0104559:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f010455d:	75 1f                	jne    f010457e <readline+0xc5>
f010455f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0104563:	7e 19                	jle    f010457e <readline+0xc5>
			if (echoing)
f0104565:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104569:	74 0e                	je     f0104579 <readline+0xc0>
				cputchar(c);
f010456b:	83 ec 0c             	sub    $0xc,%esp
f010456e:	ff 75 ec             	pushl  -0x14(%ebp)
f0104571:	e8 a1 c3 ff ff       	call   f0100917 <cputchar>
f0104576:	83 c4 10             	add    $0x10,%esp
			i--;
f0104579:	ff 4d f4             	decl   -0xc(%ebp)
f010457c:	eb 31                	jmp    f01045af <readline+0xf6>
		} else if (c == '\n' || c == '\r') {
f010457e:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0104582:	74 0a                	je     f010458e <readline+0xd5>
f0104584:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f0104588:	0f 85 61 ff ff ff    	jne    f01044ef <readline+0x36>
			if (echoing)
f010458e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104592:	74 0e                	je     f01045a2 <readline+0xe9>
				cputchar(c);
f0104594:	83 ec 0c             	sub    $0xc,%esp
f0104597:	ff 75 ec             	pushl  -0x14(%ebp)
f010459a:	e8 78 c3 ff ff       	call   f0100917 <cputchar>
f010459f:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
f01045a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01045a5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01045a8:	01 d0                	add    %edx,%eax
f01045aa:	c6 00 00             	movb   $0x0,(%eax)
			return;		
f01045ad:	eb 06                	jmp    f01045b5 <readline+0xfc>
		}
	}
f01045af:	e9 3b ff ff ff       	jmp    f01044ef <readline+0x36>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);			
			return;
f01045b4:	90                   	nop
				cputchar(c);
			buf[i] = 0;	
			return;		
		}
	}
}
f01045b5:	c9                   	leave  
f01045b6:	c3                   	ret    

f01045b7 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f01045b7:	55                   	push   %ebp
f01045b8:	89 e5                	mov    %esp,%ebp
f01045ba:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f01045bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01045c4:	eb 06                	jmp    f01045cc <strlen+0x15>
		n++;
f01045c6:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01045c9:	ff 45 08             	incl   0x8(%ebp)
f01045cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01045cf:	8a 00                	mov    (%eax),%al
f01045d1:	84 c0                	test   %al,%al
f01045d3:	75 f1                	jne    f01045c6 <strlen+0xf>
		n++;
	return n;
f01045d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01045d8:	c9                   	leave  
f01045d9:	c3                   	ret    

f01045da <strnlen>:

int
strnlen(const char *s, uint32 size)
{
f01045da:	55                   	push   %ebp
f01045db:	89 e5                	mov    %esp,%ebp
f01045dd:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01045e7:	eb 09                	jmp    f01045f2 <strnlen+0x18>
		n++;
f01045e9:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01045ec:	ff 45 08             	incl   0x8(%ebp)
f01045ef:	ff 4d 0c             	decl   0xc(%ebp)
f01045f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01045f6:	74 09                	je     f0104601 <strnlen+0x27>
f01045f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01045fb:	8a 00                	mov    (%eax),%al
f01045fd:	84 c0                	test   %al,%al
f01045ff:	75 e8                	jne    f01045e9 <strnlen+0xf>
		n++;
	return n;
f0104601:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104604:	c9                   	leave  
f0104605:	c3                   	ret    

f0104606 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104606:	55                   	push   %ebp
f0104607:	89 e5                	mov    %esp,%ebp
f0104609:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f010460c:	8b 45 08             	mov    0x8(%ebp),%eax
f010460f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f0104612:	90                   	nop
f0104613:	8b 45 08             	mov    0x8(%ebp),%eax
f0104616:	8d 50 01             	lea    0x1(%eax),%edx
f0104619:	89 55 08             	mov    %edx,0x8(%ebp)
f010461c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010461f:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104622:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0104625:	8a 12                	mov    (%edx),%dl
f0104627:	88 10                	mov    %dl,(%eax)
f0104629:	8a 00                	mov    (%eax),%al
f010462b:	84 c0                	test   %al,%al
f010462d:	75 e4                	jne    f0104613 <strcpy+0xd>
		/* do nothing */;
	return ret;
f010462f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104632:	c9                   	leave  
f0104633:	c3                   	ret    

f0104634 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
f0104634:	55                   	push   %ebp
f0104635:	89 e5                	mov    %esp,%ebp
f0104637:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
f010463a:	8b 45 08             	mov    0x8(%ebp),%eax
f010463d:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f0104640:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0104647:	eb 1f                	jmp    f0104668 <strncpy+0x34>
		*dst++ = *src;
f0104649:	8b 45 08             	mov    0x8(%ebp),%eax
f010464c:	8d 50 01             	lea    0x1(%eax),%edx
f010464f:	89 55 08             	mov    %edx,0x8(%ebp)
f0104652:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104655:	8a 12                	mov    (%edx),%dl
f0104657:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0104659:	8b 45 0c             	mov    0xc(%ebp),%eax
f010465c:	8a 00                	mov    (%eax),%al
f010465e:	84 c0                	test   %al,%al
f0104660:	74 03                	je     f0104665 <strncpy+0x31>
			src++;
f0104662:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104665:	ff 45 fc             	incl   -0x4(%ebp)
f0104668:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010466b:	3b 45 10             	cmp    0x10(%ebp),%eax
f010466e:	72 d9                	jb     f0104649 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f0104670:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0104673:	c9                   	leave  
f0104674:	c3                   	ret    

f0104675 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
f0104675:	55                   	push   %ebp
f0104676:	89 e5                	mov    %esp,%ebp
f0104678:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f010467b:	8b 45 08             	mov    0x8(%ebp),%eax
f010467e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f0104681:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104685:	74 30                	je     f01046b7 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
f0104687:	eb 16                	jmp    f010469f <strlcpy+0x2a>
			*dst++ = *src++;
f0104689:	8b 45 08             	mov    0x8(%ebp),%eax
f010468c:	8d 50 01             	lea    0x1(%eax),%edx
f010468f:	89 55 08             	mov    %edx,0x8(%ebp)
f0104692:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104695:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104698:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f010469b:	8a 12                	mov    (%edx),%dl
f010469d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010469f:	ff 4d 10             	decl   0x10(%ebp)
f01046a2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01046a6:	74 09                	je     f01046b1 <strlcpy+0x3c>
f01046a8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046ab:	8a 00                	mov    (%eax),%al
f01046ad:	84 c0                	test   %al,%al
f01046af:	75 d8                	jne    f0104689 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f01046b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01046b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01046b7:	8b 55 08             	mov    0x8(%ebp),%edx
f01046ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01046bd:	29 c2                	sub    %eax,%edx
f01046bf:	89 d0                	mov    %edx,%eax
}
f01046c1:	c9                   	leave  
f01046c2:	c3                   	ret    

f01046c3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01046c3:	55                   	push   %ebp
f01046c4:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f01046c6:	eb 06                	jmp    f01046ce <strcmp+0xb>
		p++, q++;
f01046c8:	ff 45 08             	incl   0x8(%ebp)
f01046cb:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01046ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01046d1:	8a 00                	mov    (%eax),%al
f01046d3:	84 c0                	test   %al,%al
f01046d5:	74 0e                	je     f01046e5 <strcmp+0x22>
f01046d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01046da:	8a 10                	mov    (%eax),%dl
f01046dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046df:	8a 00                	mov    (%eax),%al
f01046e1:	38 c2                	cmp    %al,%dl
f01046e3:	74 e3                	je     f01046c8 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01046e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01046e8:	8a 00                	mov    (%eax),%al
f01046ea:	0f b6 d0             	movzbl %al,%edx
f01046ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046f0:	8a 00                	mov    (%eax),%al
f01046f2:	0f b6 c0             	movzbl %al,%eax
f01046f5:	29 c2                	sub    %eax,%edx
f01046f7:	89 d0                	mov    %edx,%eax
}
f01046f9:	5d                   	pop    %ebp
f01046fa:	c3                   	ret    

f01046fb <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
f01046fb:	55                   	push   %ebp
f01046fc:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f01046fe:	eb 09                	jmp    f0104709 <strncmp+0xe>
		n--, p++, q++;
f0104700:	ff 4d 10             	decl   0x10(%ebp)
f0104703:	ff 45 08             	incl   0x8(%ebp)
f0104706:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
f0104709:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010470d:	74 17                	je     f0104726 <strncmp+0x2b>
f010470f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104712:	8a 00                	mov    (%eax),%al
f0104714:	84 c0                	test   %al,%al
f0104716:	74 0e                	je     f0104726 <strncmp+0x2b>
f0104718:	8b 45 08             	mov    0x8(%ebp),%eax
f010471b:	8a 10                	mov    (%eax),%dl
f010471d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104720:	8a 00                	mov    (%eax),%al
f0104722:	38 c2                	cmp    %al,%dl
f0104724:	74 da                	je     f0104700 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f0104726:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010472a:	75 07                	jne    f0104733 <strncmp+0x38>
		return 0;
f010472c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104731:	eb 14                	jmp    f0104747 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104733:	8b 45 08             	mov    0x8(%ebp),%eax
f0104736:	8a 00                	mov    (%eax),%al
f0104738:	0f b6 d0             	movzbl %al,%edx
f010473b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010473e:	8a 00                	mov    (%eax),%al
f0104740:	0f b6 c0             	movzbl %al,%eax
f0104743:	29 c2                	sub    %eax,%edx
f0104745:	89 d0                	mov    %edx,%eax
}
f0104747:	5d                   	pop    %ebp
f0104748:	c3                   	ret    

f0104749 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104749:	55                   	push   %ebp
f010474a:	89 e5                	mov    %esp,%ebp
f010474c:	83 ec 04             	sub    $0x4,%esp
f010474f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104752:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0104755:	eb 12                	jmp    f0104769 <strchr+0x20>
		if (*s == c)
f0104757:	8b 45 08             	mov    0x8(%ebp),%eax
f010475a:	8a 00                	mov    (%eax),%al
f010475c:	3a 45 fc             	cmp    -0x4(%ebp),%al
f010475f:	75 05                	jne    f0104766 <strchr+0x1d>
			return (char *) s;
f0104761:	8b 45 08             	mov    0x8(%ebp),%eax
f0104764:	eb 11                	jmp    f0104777 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104766:	ff 45 08             	incl   0x8(%ebp)
f0104769:	8b 45 08             	mov    0x8(%ebp),%eax
f010476c:	8a 00                	mov    (%eax),%al
f010476e:	84 c0                	test   %al,%al
f0104770:	75 e5                	jne    f0104757 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f0104772:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104777:	c9                   	leave  
f0104778:	c3                   	ret    

f0104779 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104779:	55                   	push   %ebp
f010477a:	89 e5                	mov    %esp,%ebp
f010477c:	83 ec 04             	sub    $0x4,%esp
f010477f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104782:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0104785:	eb 0d                	jmp    f0104794 <strfind+0x1b>
		if (*s == c)
f0104787:	8b 45 08             	mov    0x8(%ebp),%eax
f010478a:	8a 00                	mov    (%eax),%al
f010478c:	3a 45 fc             	cmp    -0x4(%ebp),%al
f010478f:	74 0e                	je     f010479f <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104791:	ff 45 08             	incl   0x8(%ebp)
f0104794:	8b 45 08             	mov    0x8(%ebp),%eax
f0104797:	8a 00                	mov    (%eax),%al
f0104799:	84 c0                	test   %al,%al
f010479b:	75 ea                	jne    f0104787 <strfind+0xe>
f010479d:	eb 01                	jmp    f01047a0 <strfind+0x27>
		if (*s == c)
			break;
f010479f:	90                   	nop
	return (char *) s;
f01047a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01047a3:	c9                   	leave  
f01047a4:	c3                   	ret    

f01047a5 <memset>:


void *
memset(void *v, int c, uint32 n)
{
f01047a5:	55                   	push   %ebp
f01047a6:	89 e5                	mov    %esp,%ebp
f01047a8:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
f01047ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01047ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
f01047b1:	8b 45 10             	mov    0x10(%ebp),%eax
f01047b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
f01047b7:	eb 0e                	jmp    f01047c7 <memset+0x22>
		*p++ = c;
f01047b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01047bc:	8d 50 01             	lea    0x1(%eax),%edx
f01047bf:	89 55 fc             	mov    %edx,-0x4(%ebp)
f01047c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01047c5:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f01047c7:	ff 4d f8             	decl   -0x8(%ebp)
f01047ca:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f01047ce:	79 e9                	jns    f01047b9 <memset+0x14>
		*p++ = c;

	return v;
f01047d0:	8b 45 08             	mov    0x8(%ebp),%eax
}
f01047d3:	c9                   	leave  
f01047d4:	c3                   	ret    

f01047d5 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
f01047d5:	55                   	push   %ebp
f01047d6:	89 e5                	mov    %esp,%ebp
f01047d8:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f01047db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01047de:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f01047e1:	8b 45 08             	mov    0x8(%ebp),%eax
f01047e4:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
f01047e7:	eb 16                	jmp    f01047ff <memcpy+0x2a>
		*d++ = *s++;
f01047e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01047ec:	8d 50 01             	lea    0x1(%eax),%edx
f01047ef:	89 55 f8             	mov    %edx,-0x8(%ebp)
f01047f2:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01047f5:	8d 4a 01             	lea    0x1(%edx),%ecx
f01047f8:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f01047fb:	8a 12                	mov    (%edx),%dl
f01047fd:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f01047ff:	8b 45 10             	mov    0x10(%ebp),%eax
f0104802:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104805:	89 55 10             	mov    %edx,0x10(%ebp)
f0104808:	85 c0                	test   %eax,%eax
f010480a:	75 dd                	jne    f01047e9 <memcpy+0x14>
		*d++ = *s++;

	return dst;
f010480c:	8b 45 08             	mov    0x8(%ebp),%eax
}
f010480f:	c9                   	leave  
f0104810:	c3                   	ret    

f0104811 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
f0104811:	55                   	push   %ebp
f0104812:	89 e5                	mov    %esp,%ebp
f0104814:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
f0104817:	8b 45 0c             	mov    0xc(%ebp),%eax
f010481a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f010481d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104820:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
f0104823:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104826:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0104829:	73 50                	jae    f010487b <memmove+0x6a>
f010482b:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010482e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104831:	01 d0                	add    %edx,%eax
f0104833:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0104836:	76 43                	jbe    f010487b <memmove+0x6a>
		s += n;
f0104838:	8b 45 10             	mov    0x10(%ebp),%eax
f010483b:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
f010483e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104841:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
f0104844:	eb 10                	jmp    f0104856 <memmove+0x45>
			*--d = *--s;
f0104846:	ff 4d f8             	decl   -0x8(%ebp)
f0104849:	ff 4d fc             	decl   -0x4(%ebp)
f010484c:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010484f:	8a 10                	mov    (%eax),%dl
f0104851:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104854:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0104856:	8b 45 10             	mov    0x10(%ebp),%eax
f0104859:	8d 50 ff             	lea    -0x1(%eax),%edx
f010485c:	89 55 10             	mov    %edx,0x10(%ebp)
f010485f:	85 c0                	test   %eax,%eax
f0104861:	75 e3                	jne    f0104846 <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104863:	eb 23                	jmp    f0104888 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0104865:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104868:	8d 50 01             	lea    0x1(%eax),%edx
f010486b:	89 55 f8             	mov    %edx,-0x8(%ebp)
f010486e:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104871:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104874:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f0104877:	8a 12                	mov    (%edx),%dl
f0104879:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f010487b:	8b 45 10             	mov    0x10(%ebp),%eax
f010487e:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104881:	89 55 10             	mov    %edx,0x10(%ebp)
f0104884:	85 c0                	test   %eax,%eax
f0104886:	75 dd                	jne    f0104865 <memmove+0x54>
			*d++ = *s++;

	return dst;
f0104888:	8b 45 08             	mov    0x8(%ebp),%eax
}
f010488b:	c9                   	leave  
f010488c:	c3                   	ret    

f010488d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
f010488d:	55                   	push   %ebp
f010488e:	89 e5                	mov    %esp,%ebp
f0104890:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
f0104893:	8b 45 08             	mov    0x8(%ebp),%eax
f0104896:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
f0104899:	8b 45 0c             	mov    0xc(%ebp),%eax
f010489c:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f010489f:	eb 2a                	jmp    f01048cb <memcmp+0x3e>
		if (*s1 != *s2)
f01048a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01048a4:	8a 10                	mov    (%eax),%dl
f01048a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01048a9:	8a 00                	mov    (%eax),%al
f01048ab:	38 c2                	cmp    %al,%dl
f01048ad:	74 16                	je     f01048c5 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
f01048af:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01048b2:	8a 00                	mov    (%eax),%al
f01048b4:	0f b6 d0             	movzbl %al,%edx
f01048b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01048ba:	8a 00                	mov    (%eax),%al
f01048bc:	0f b6 c0             	movzbl %al,%eax
f01048bf:	29 c2                	sub    %eax,%edx
f01048c1:	89 d0                	mov    %edx,%eax
f01048c3:	eb 18                	jmp    f01048dd <memcmp+0x50>
		s1++, s2++;
f01048c5:	ff 45 fc             	incl   -0x4(%ebp)
f01048c8:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
f01048cb:	8b 45 10             	mov    0x10(%ebp),%eax
f01048ce:	8d 50 ff             	lea    -0x1(%eax),%edx
f01048d1:	89 55 10             	mov    %edx,0x10(%ebp)
f01048d4:	85 c0                	test   %eax,%eax
f01048d6:	75 c9                	jne    f01048a1 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01048d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01048dd:	c9                   	leave  
f01048de:	c3                   	ret    

f01048df <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
f01048df:	55                   	push   %ebp
f01048e0:	89 e5                	mov    %esp,%ebp
f01048e2:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f01048e5:	8b 55 08             	mov    0x8(%ebp),%edx
f01048e8:	8b 45 10             	mov    0x10(%ebp),%eax
f01048eb:	01 d0                	add    %edx,%eax
f01048ed:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f01048f0:	eb 15                	jmp    f0104907 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f01048f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01048f5:	8a 00                	mov    (%eax),%al
f01048f7:	0f b6 d0             	movzbl %al,%edx
f01048fa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01048fd:	0f b6 c0             	movzbl %al,%eax
f0104900:	39 c2                	cmp    %eax,%edx
f0104902:	74 0d                	je     f0104911 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104904:	ff 45 08             	incl   0x8(%ebp)
f0104907:	8b 45 08             	mov    0x8(%ebp),%eax
f010490a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f010490d:	72 e3                	jb     f01048f2 <memfind+0x13>
f010490f:	eb 01                	jmp    f0104912 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
f0104911:	90                   	nop
	return (void *) s;
f0104912:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104915:	c9                   	leave  
f0104916:	c3                   	ret    

f0104917 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104917:	55                   	push   %ebp
f0104918:	89 e5                	mov    %esp,%ebp
f010491a:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f010491d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f0104924:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010492b:	eb 03                	jmp    f0104930 <strtol+0x19>
		s++;
f010492d:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104930:	8b 45 08             	mov    0x8(%ebp),%eax
f0104933:	8a 00                	mov    (%eax),%al
f0104935:	3c 20                	cmp    $0x20,%al
f0104937:	74 f4                	je     f010492d <strtol+0x16>
f0104939:	8b 45 08             	mov    0x8(%ebp),%eax
f010493c:	8a 00                	mov    (%eax),%al
f010493e:	3c 09                	cmp    $0x9,%al
f0104940:	74 eb                	je     f010492d <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104942:	8b 45 08             	mov    0x8(%ebp),%eax
f0104945:	8a 00                	mov    (%eax),%al
f0104947:	3c 2b                	cmp    $0x2b,%al
f0104949:	75 05                	jne    f0104950 <strtol+0x39>
		s++;
f010494b:	ff 45 08             	incl   0x8(%ebp)
f010494e:	eb 13                	jmp    f0104963 <strtol+0x4c>
	else if (*s == '-')
f0104950:	8b 45 08             	mov    0x8(%ebp),%eax
f0104953:	8a 00                	mov    (%eax),%al
f0104955:	3c 2d                	cmp    $0x2d,%al
f0104957:	75 0a                	jne    f0104963 <strtol+0x4c>
		s++, neg = 1;
f0104959:	ff 45 08             	incl   0x8(%ebp)
f010495c:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104963:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104967:	74 06                	je     f010496f <strtol+0x58>
f0104969:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f010496d:	75 20                	jne    f010498f <strtol+0x78>
f010496f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104972:	8a 00                	mov    (%eax),%al
f0104974:	3c 30                	cmp    $0x30,%al
f0104976:	75 17                	jne    f010498f <strtol+0x78>
f0104978:	8b 45 08             	mov    0x8(%ebp),%eax
f010497b:	40                   	inc    %eax
f010497c:	8a 00                	mov    (%eax),%al
f010497e:	3c 78                	cmp    $0x78,%al
f0104980:	75 0d                	jne    f010498f <strtol+0x78>
		s += 2, base = 16;
f0104982:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f0104986:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010498d:	eb 28                	jmp    f01049b7 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
f010498f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104993:	75 15                	jne    f01049aa <strtol+0x93>
f0104995:	8b 45 08             	mov    0x8(%ebp),%eax
f0104998:	8a 00                	mov    (%eax),%al
f010499a:	3c 30                	cmp    $0x30,%al
f010499c:	75 0c                	jne    f01049aa <strtol+0x93>
		s++, base = 8;
f010499e:	ff 45 08             	incl   0x8(%ebp)
f01049a1:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f01049a8:	eb 0d                	jmp    f01049b7 <strtol+0xa0>
	else if (base == 0)
f01049aa:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01049ae:	75 07                	jne    f01049b7 <strtol+0xa0>
		base = 10;
f01049b0:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01049b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ba:	8a 00                	mov    (%eax),%al
f01049bc:	3c 2f                	cmp    $0x2f,%al
f01049be:	7e 19                	jle    f01049d9 <strtol+0xc2>
f01049c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01049c3:	8a 00                	mov    (%eax),%al
f01049c5:	3c 39                	cmp    $0x39,%al
f01049c7:	7f 10                	jg     f01049d9 <strtol+0xc2>
			dig = *s - '0';
f01049c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01049cc:	8a 00                	mov    (%eax),%al
f01049ce:	0f be c0             	movsbl %al,%eax
f01049d1:	83 e8 30             	sub    $0x30,%eax
f01049d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01049d7:	eb 42                	jmp    f0104a1b <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
f01049d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01049dc:	8a 00                	mov    (%eax),%al
f01049de:	3c 60                	cmp    $0x60,%al
f01049e0:	7e 19                	jle    f01049fb <strtol+0xe4>
f01049e2:	8b 45 08             	mov    0x8(%ebp),%eax
f01049e5:	8a 00                	mov    (%eax),%al
f01049e7:	3c 7a                	cmp    $0x7a,%al
f01049e9:	7f 10                	jg     f01049fb <strtol+0xe4>
			dig = *s - 'a' + 10;
f01049eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ee:	8a 00                	mov    (%eax),%al
f01049f0:	0f be c0             	movsbl %al,%eax
f01049f3:	83 e8 57             	sub    $0x57,%eax
f01049f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01049f9:	eb 20                	jmp    f0104a1b <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
f01049fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01049fe:	8a 00                	mov    (%eax),%al
f0104a00:	3c 40                	cmp    $0x40,%al
f0104a02:	7e 39                	jle    f0104a3d <strtol+0x126>
f0104a04:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a07:	8a 00                	mov    (%eax),%al
f0104a09:	3c 5a                	cmp    $0x5a,%al
f0104a0b:	7f 30                	jg     f0104a3d <strtol+0x126>
			dig = *s - 'A' + 10;
f0104a0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a10:	8a 00                	mov    (%eax),%al
f0104a12:	0f be c0             	movsbl %al,%eax
f0104a15:	83 e8 37             	sub    $0x37,%eax
f0104a18:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0104a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a1e:	3b 45 10             	cmp    0x10(%ebp),%eax
f0104a21:	7d 19                	jge    f0104a3c <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
f0104a23:	ff 45 08             	incl   0x8(%ebp)
f0104a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104a29:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104a2d:	89 c2                	mov    %eax,%edx
f0104a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a32:	01 d0                	add    %edx,%eax
f0104a34:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f0104a37:	e9 7b ff ff ff       	jmp    f01049b7 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
f0104a3c:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104a3d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104a41:	74 08                	je     f0104a4b <strtol+0x134>
		*endptr = (char *) s;
f0104a43:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104a46:	8b 55 08             	mov    0x8(%ebp),%edx
f0104a49:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f0104a4b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f0104a4f:	74 07                	je     f0104a58 <strtol+0x141>
f0104a51:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104a54:	f7 d8                	neg    %eax
f0104a56:	eb 03                	jmp    f0104a5b <strtol+0x144>
f0104a58:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f0104a5b:	c9                   	leave  
f0104a5c:	c3                   	ret    

f0104a5d <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
f0104a5d:	55                   	push   %ebp
f0104a5e:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
f0104a60:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
f0104a69:	8b 45 14             	mov    0x14(%ebp),%eax
f0104a6c:	8b 00                	mov    (%eax),%eax
f0104a6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104a75:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a78:	01 d0                	add    %edx,%eax
f0104a7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f0104a80:	eb 0c                	jmp    f0104a8e <strsplit+0x31>
			*string++ = 0;
f0104a82:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a85:	8d 50 01             	lea    0x1(%eax),%edx
f0104a88:	89 55 08             	mov    %edx,0x8(%ebp)
f0104a8b:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f0104a8e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a91:	8a 00                	mov    (%eax),%al
f0104a93:	84 c0                	test   %al,%al
f0104a95:	74 18                	je     f0104aaf <strsplit+0x52>
f0104a97:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a9a:	8a 00                	mov    (%eax),%al
f0104a9c:	0f be c0             	movsbl %al,%eax
f0104a9f:	50                   	push   %eax
f0104aa0:	ff 75 0c             	pushl  0xc(%ebp)
f0104aa3:	e8 a1 fc ff ff       	call   f0104749 <strchr>
f0104aa8:	83 c4 08             	add    $0x8,%esp
f0104aab:	85 c0                	test   %eax,%eax
f0104aad:	75 d3                	jne    f0104a82 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
f0104aaf:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ab2:	8a 00                	mov    (%eax),%al
f0104ab4:	84 c0                	test   %al,%al
f0104ab6:	74 5a                	je     f0104b12 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
f0104ab8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104abb:	8b 00                	mov    (%eax),%eax
f0104abd:	83 f8 0f             	cmp    $0xf,%eax
f0104ac0:	75 07                	jne    f0104ac9 <strsplit+0x6c>
		{
			return 0;
f0104ac2:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ac7:	eb 66                	jmp    f0104b2f <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
f0104ac9:	8b 45 14             	mov    0x14(%ebp),%eax
f0104acc:	8b 00                	mov    (%eax),%eax
f0104ace:	8d 48 01             	lea    0x1(%eax),%ecx
f0104ad1:	8b 55 14             	mov    0x14(%ebp),%edx
f0104ad4:	89 0a                	mov    %ecx,(%edx)
f0104ad6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104add:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ae0:	01 c2                	add    %eax,%edx
f0104ae2:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ae5:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
f0104ae7:	eb 03                	jmp    f0104aec <strsplit+0x8f>
			string++;
f0104ae9:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
f0104aec:	8b 45 08             	mov    0x8(%ebp),%eax
f0104aef:	8a 00                	mov    (%eax),%al
f0104af1:	84 c0                	test   %al,%al
f0104af3:	74 8b                	je     f0104a80 <strsplit+0x23>
f0104af5:	8b 45 08             	mov    0x8(%ebp),%eax
f0104af8:	8a 00                	mov    (%eax),%al
f0104afa:	0f be c0             	movsbl %al,%eax
f0104afd:	50                   	push   %eax
f0104afe:	ff 75 0c             	pushl  0xc(%ebp)
f0104b01:	e8 43 fc ff ff       	call   f0104749 <strchr>
f0104b06:	83 c4 08             	add    $0x8,%esp
f0104b09:	85 c0                	test   %eax,%eax
f0104b0b:	74 dc                	je     f0104ae9 <strsplit+0x8c>
			string++;
	}
f0104b0d:	e9 6e ff ff ff       	jmp    f0104a80 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
f0104b12:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
f0104b13:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b16:	8b 00                	mov    (%eax),%eax
f0104b18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0104b1f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b22:	01 d0                	add    %edx,%eax
f0104b24:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
f0104b2a:	b8 01 00 00 00       	mov    $0x1,%eax
}
f0104b2f:	c9                   	leave  
f0104b30:	c3                   	ret    
f0104b31:	66 90                	xchg   %ax,%ax
f0104b33:	90                   	nop

f0104b34 <__udivdi3>:
f0104b34:	55                   	push   %ebp
f0104b35:	57                   	push   %edi
f0104b36:	56                   	push   %esi
f0104b37:	53                   	push   %ebx
f0104b38:	83 ec 1c             	sub    $0x1c,%esp
f0104b3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0104b3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0104b43:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104b47:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104b4b:	89 ca                	mov    %ecx,%edx
f0104b4d:	89 f8                	mov    %edi,%eax
f0104b4f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0104b53:	85 f6                	test   %esi,%esi
f0104b55:	75 2d                	jne    f0104b84 <__udivdi3+0x50>
f0104b57:	39 cf                	cmp    %ecx,%edi
f0104b59:	77 65                	ja     f0104bc0 <__udivdi3+0x8c>
f0104b5b:	89 fd                	mov    %edi,%ebp
f0104b5d:	85 ff                	test   %edi,%edi
f0104b5f:	75 0b                	jne    f0104b6c <__udivdi3+0x38>
f0104b61:	b8 01 00 00 00       	mov    $0x1,%eax
f0104b66:	31 d2                	xor    %edx,%edx
f0104b68:	f7 f7                	div    %edi
f0104b6a:	89 c5                	mov    %eax,%ebp
f0104b6c:	31 d2                	xor    %edx,%edx
f0104b6e:	89 c8                	mov    %ecx,%eax
f0104b70:	f7 f5                	div    %ebp
f0104b72:	89 c1                	mov    %eax,%ecx
f0104b74:	89 d8                	mov    %ebx,%eax
f0104b76:	f7 f5                	div    %ebp
f0104b78:	89 cf                	mov    %ecx,%edi
f0104b7a:	89 fa                	mov    %edi,%edx
f0104b7c:	83 c4 1c             	add    $0x1c,%esp
f0104b7f:	5b                   	pop    %ebx
f0104b80:	5e                   	pop    %esi
f0104b81:	5f                   	pop    %edi
f0104b82:	5d                   	pop    %ebp
f0104b83:	c3                   	ret    
f0104b84:	39 ce                	cmp    %ecx,%esi
f0104b86:	77 28                	ja     f0104bb0 <__udivdi3+0x7c>
f0104b88:	0f bd fe             	bsr    %esi,%edi
f0104b8b:	83 f7 1f             	xor    $0x1f,%edi
f0104b8e:	75 40                	jne    f0104bd0 <__udivdi3+0x9c>
f0104b90:	39 ce                	cmp    %ecx,%esi
f0104b92:	72 0a                	jb     f0104b9e <__udivdi3+0x6a>
f0104b94:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104b98:	0f 87 9e 00 00 00    	ja     f0104c3c <__udivdi3+0x108>
f0104b9e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ba3:	89 fa                	mov    %edi,%edx
f0104ba5:	83 c4 1c             	add    $0x1c,%esp
f0104ba8:	5b                   	pop    %ebx
f0104ba9:	5e                   	pop    %esi
f0104baa:	5f                   	pop    %edi
f0104bab:	5d                   	pop    %ebp
f0104bac:	c3                   	ret    
f0104bad:	8d 76 00             	lea    0x0(%esi),%esi
f0104bb0:	31 ff                	xor    %edi,%edi
f0104bb2:	31 c0                	xor    %eax,%eax
f0104bb4:	89 fa                	mov    %edi,%edx
f0104bb6:	83 c4 1c             	add    $0x1c,%esp
f0104bb9:	5b                   	pop    %ebx
f0104bba:	5e                   	pop    %esi
f0104bbb:	5f                   	pop    %edi
f0104bbc:	5d                   	pop    %ebp
f0104bbd:	c3                   	ret    
f0104bbe:	66 90                	xchg   %ax,%ax
f0104bc0:	89 d8                	mov    %ebx,%eax
f0104bc2:	f7 f7                	div    %edi
f0104bc4:	31 ff                	xor    %edi,%edi
f0104bc6:	89 fa                	mov    %edi,%edx
f0104bc8:	83 c4 1c             	add    $0x1c,%esp
f0104bcb:	5b                   	pop    %ebx
f0104bcc:	5e                   	pop    %esi
f0104bcd:	5f                   	pop    %edi
f0104bce:	5d                   	pop    %ebp
f0104bcf:	c3                   	ret    
f0104bd0:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104bd5:	89 eb                	mov    %ebp,%ebx
f0104bd7:	29 fb                	sub    %edi,%ebx
f0104bd9:	89 f9                	mov    %edi,%ecx
f0104bdb:	d3 e6                	shl    %cl,%esi
f0104bdd:	89 c5                	mov    %eax,%ebp
f0104bdf:	88 d9                	mov    %bl,%cl
f0104be1:	d3 ed                	shr    %cl,%ebp
f0104be3:	89 e9                	mov    %ebp,%ecx
f0104be5:	09 f1                	or     %esi,%ecx
f0104be7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104beb:	89 f9                	mov    %edi,%ecx
f0104bed:	d3 e0                	shl    %cl,%eax
f0104bef:	89 c5                	mov    %eax,%ebp
f0104bf1:	89 d6                	mov    %edx,%esi
f0104bf3:	88 d9                	mov    %bl,%cl
f0104bf5:	d3 ee                	shr    %cl,%esi
f0104bf7:	89 f9                	mov    %edi,%ecx
f0104bf9:	d3 e2                	shl    %cl,%edx
f0104bfb:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104bff:	88 d9                	mov    %bl,%cl
f0104c01:	d3 e8                	shr    %cl,%eax
f0104c03:	09 c2                	or     %eax,%edx
f0104c05:	89 d0                	mov    %edx,%eax
f0104c07:	89 f2                	mov    %esi,%edx
f0104c09:	f7 74 24 0c          	divl   0xc(%esp)
f0104c0d:	89 d6                	mov    %edx,%esi
f0104c0f:	89 c3                	mov    %eax,%ebx
f0104c11:	f7 e5                	mul    %ebp
f0104c13:	39 d6                	cmp    %edx,%esi
f0104c15:	72 19                	jb     f0104c30 <__udivdi3+0xfc>
f0104c17:	74 0b                	je     f0104c24 <__udivdi3+0xf0>
f0104c19:	89 d8                	mov    %ebx,%eax
f0104c1b:	31 ff                	xor    %edi,%edi
f0104c1d:	e9 58 ff ff ff       	jmp    f0104b7a <__udivdi3+0x46>
f0104c22:	66 90                	xchg   %ax,%ax
f0104c24:	8b 54 24 08          	mov    0x8(%esp),%edx
f0104c28:	89 f9                	mov    %edi,%ecx
f0104c2a:	d3 e2                	shl    %cl,%edx
f0104c2c:	39 c2                	cmp    %eax,%edx
f0104c2e:	73 e9                	jae    f0104c19 <__udivdi3+0xe5>
f0104c30:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0104c33:	31 ff                	xor    %edi,%edi
f0104c35:	e9 40 ff ff ff       	jmp    f0104b7a <__udivdi3+0x46>
f0104c3a:	66 90                	xchg   %ax,%ax
f0104c3c:	31 c0                	xor    %eax,%eax
f0104c3e:	e9 37 ff ff ff       	jmp    f0104b7a <__udivdi3+0x46>
f0104c43:	90                   	nop

f0104c44 <__umoddi3>:
f0104c44:	55                   	push   %ebp
f0104c45:	57                   	push   %edi
f0104c46:	56                   	push   %esi
f0104c47:	53                   	push   %ebx
f0104c48:	83 ec 1c             	sub    $0x1c,%esp
f0104c4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0104c4f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0104c57:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0104c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104c5f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104c63:	89 f3                	mov    %esi,%ebx
f0104c65:	89 fa                	mov    %edi,%edx
f0104c67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104c6b:	89 34 24             	mov    %esi,(%esp)
f0104c6e:	85 c0                	test   %eax,%eax
f0104c70:	75 1a                	jne    f0104c8c <__umoddi3+0x48>
f0104c72:	39 f7                	cmp    %esi,%edi
f0104c74:	0f 86 a2 00 00 00    	jbe    f0104d1c <__umoddi3+0xd8>
f0104c7a:	89 c8                	mov    %ecx,%eax
f0104c7c:	89 f2                	mov    %esi,%edx
f0104c7e:	f7 f7                	div    %edi
f0104c80:	89 d0                	mov    %edx,%eax
f0104c82:	31 d2                	xor    %edx,%edx
f0104c84:	83 c4 1c             	add    $0x1c,%esp
f0104c87:	5b                   	pop    %ebx
f0104c88:	5e                   	pop    %esi
f0104c89:	5f                   	pop    %edi
f0104c8a:	5d                   	pop    %ebp
f0104c8b:	c3                   	ret    
f0104c8c:	39 f0                	cmp    %esi,%eax
f0104c8e:	0f 87 ac 00 00 00    	ja     f0104d40 <__umoddi3+0xfc>
f0104c94:	0f bd e8             	bsr    %eax,%ebp
f0104c97:	83 f5 1f             	xor    $0x1f,%ebp
f0104c9a:	0f 84 ac 00 00 00    	je     f0104d4c <__umoddi3+0x108>
f0104ca0:	bf 20 00 00 00       	mov    $0x20,%edi
f0104ca5:	29 ef                	sub    %ebp,%edi
f0104ca7:	89 fe                	mov    %edi,%esi
f0104ca9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104cad:	89 e9                	mov    %ebp,%ecx
f0104caf:	d3 e0                	shl    %cl,%eax
f0104cb1:	89 d7                	mov    %edx,%edi
f0104cb3:	89 f1                	mov    %esi,%ecx
f0104cb5:	d3 ef                	shr    %cl,%edi
f0104cb7:	09 c7                	or     %eax,%edi
f0104cb9:	89 e9                	mov    %ebp,%ecx
f0104cbb:	d3 e2                	shl    %cl,%edx
f0104cbd:	89 14 24             	mov    %edx,(%esp)
f0104cc0:	89 d8                	mov    %ebx,%eax
f0104cc2:	d3 e0                	shl    %cl,%eax
f0104cc4:	89 c2                	mov    %eax,%edx
f0104cc6:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104cca:	d3 e0                	shl    %cl,%eax
f0104ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cd0:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104cd4:	89 f1                	mov    %esi,%ecx
f0104cd6:	d3 e8                	shr    %cl,%eax
f0104cd8:	09 d0                	or     %edx,%eax
f0104cda:	d3 eb                	shr    %cl,%ebx
f0104cdc:	89 da                	mov    %ebx,%edx
f0104cde:	f7 f7                	div    %edi
f0104ce0:	89 d3                	mov    %edx,%ebx
f0104ce2:	f7 24 24             	mull   (%esp)
f0104ce5:	89 c6                	mov    %eax,%esi
f0104ce7:	89 d1                	mov    %edx,%ecx
f0104ce9:	39 d3                	cmp    %edx,%ebx
f0104ceb:	0f 82 87 00 00 00    	jb     f0104d78 <__umoddi3+0x134>
f0104cf1:	0f 84 91 00 00 00    	je     f0104d88 <__umoddi3+0x144>
f0104cf7:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104cfb:	29 f2                	sub    %esi,%edx
f0104cfd:	19 cb                	sbb    %ecx,%ebx
f0104cff:	89 d8                	mov    %ebx,%eax
f0104d01:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0104d05:	d3 e0                	shl    %cl,%eax
f0104d07:	89 e9                	mov    %ebp,%ecx
f0104d09:	d3 ea                	shr    %cl,%edx
f0104d0b:	09 d0                	or     %edx,%eax
f0104d0d:	89 e9                	mov    %ebp,%ecx
f0104d0f:	d3 eb                	shr    %cl,%ebx
f0104d11:	89 da                	mov    %ebx,%edx
f0104d13:	83 c4 1c             	add    $0x1c,%esp
f0104d16:	5b                   	pop    %ebx
f0104d17:	5e                   	pop    %esi
f0104d18:	5f                   	pop    %edi
f0104d19:	5d                   	pop    %ebp
f0104d1a:	c3                   	ret    
f0104d1b:	90                   	nop
f0104d1c:	89 fd                	mov    %edi,%ebp
f0104d1e:	85 ff                	test   %edi,%edi
f0104d20:	75 0b                	jne    f0104d2d <__umoddi3+0xe9>
f0104d22:	b8 01 00 00 00       	mov    $0x1,%eax
f0104d27:	31 d2                	xor    %edx,%edx
f0104d29:	f7 f7                	div    %edi
f0104d2b:	89 c5                	mov    %eax,%ebp
f0104d2d:	89 f0                	mov    %esi,%eax
f0104d2f:	31 d2                	xor    %edx,%edx
f0104d31:	f7 f5                	div    %ebp
f0104d33:	89 c8                	mov    %ecx,%eax
f0104d35:	f7 f5                	div    %ebp
f0104d37:	89 d0                	mov    %edx,%eax
f0104d39:	e9 44 ff ff ff       	jmp    f0104c82 <__umoddi3+0x3e>
f0104d3e:	66 90                	xchg   %ax,%ax
f0104d40:	89 c8                	mov    %ecx,%eax
f0104d42:	89 f2                	mov    %esi,%edx
f0104d44:	83 c4 1c             	add    $0x1c,%esp
f0104d47:	5b                   	pop    %ebx
f0104d48:	5e                   	pop    %esi
f0104d49:	5f                   	pop    %edi
f0104d4a:	5d                   	pop    %ebp
f0104d4b:	c3                   	ret    
f0104d4c:	3b 04 24             	cmp    (%esp),%eax
f0104d4f:	72 06                	jb     f0104d57 <__umoddi3+0x113>
f0104d51:	3b 7c 24 04          	cmp    0x4(%esp),%edi
f0104d55:	77 0f                	ja     f0104d66 <__umoddi3+0x122>
f0104d57:	89 f2                	mov    %esi,%edx
f0104d59:	29 f9                	sub    %edi,%ecx
f0104d5b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f0104d5f:	89 14 24             	mov    %edx,(%esp)
f0104d62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104d66:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104d6a:	8b 14 24             	mov    (%esp),%edx
f0104d6d:	83 c4 1c             	add    $0x1c,%esp
f0104d70:	5b                   	pop    %ebx
f0104d71:	5e                   	pop    %esi
f0104d72:	5f                   	pop    %edi
f0104d73:	5d                   	pop    %ebp
f0104d74:	c3                   	ret    
f0104d75:	8d 76 00             	lea    0x0(%esi),%esi
f0104d78:	2b 04 24             	sub    (%esp),%eax
f0104d7b:	19 fa                	sbb    %edi,%edx
f0104d7d:	89 d1                	mov    %edx,%ecx
f0104d7f:	89 c6                	mov    %eax,%esi
f0104d81:	e9 71 ff ff ff       	jmp    f0104cf7 <__umoddi3+0xb3>
f0104d86:	66 90                	xchg   %ax,%ax
f0104d88:	39 44 24 04          	cmp    %eax,0x4(%esp)
f0104d8c:	72 ea                	jb     f0104d78 <__umoddi3+0x134>
f0104d8e:	89 d9                	mov    %ebx,%ecx
f0104d90:	e9 62 ff ff ff       	jmp    f0104cf7 <__umoddi3+0xb3>
