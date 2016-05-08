
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
f0100015:	0f 01 15 18 a0 11 00 	lgdtl  0x11a018

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
f0100033:	bc bc 9f 11 f0       	mov    $0xf0119fbc,%esp

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
f0100045:	ba ec d6 14 f0       	mov    $0xf014d6ec,%edx
f010004a:	b8 f2 cb 14 f0       	mov    $0xf014cbf2,%eax
f010004f:	29 c2                	sub    %eax,%edx
f0100051:	89 d0                	mov    %edx,%eax
f0100053:	83 ec 04             	sub    $0x4,%esp
f0100056:	50                   	push   %eax
f0100057:	6a 00                	push   $0x0
f0100059:	68 f2 cb 14 f0       	push   $0xf014cbf2
f010005e:	e8 c0 43 00 00       	call   f0104423 <memset>
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
f0100070:	e8 7e 0b 00 00       	call   f0100bf3 <detect_memory>
	initialize_kernel_VM();
f0100075:	e8 04 1a 00 00       	call   f0101a7e <initialize_kernel_VM>
	initialize_paging();
f010007a:	e8 c3 1d 00 00       	call   f0101e42 <initialize_paging>
	page_check();
f010007f:	e8 3b 0f 00 00       	call   f0100fbf <page_check>

	
	// Lab 3 user environment initialization functions
	env_init();
f0100084:	e8 70 25 00 00       	call   f01025f9 <env_init>
	idt_init();
f0100089:	e8 04 2d 00 00       	call   f0102d92 <idt_init>

	
	// start the kernel command prompt.
	while (1==1)
	{
		cprintf("\nWelcome to the FOS kernel command prompt!\n");
f010008e:	83 ec 0c             	sub    $0xc,%esp
f0100091:	68 20 4a 10 f0       	push   $0xf0104a20
f0100096:	e8 a6 2c 00 00       	call   f0102d41 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
		cprintf("Type 'help' for a list of commands.\n");	
f010009e:	83 ec 0c             	sub    $0xc,%esp
f01000a1:	68 4c 4a 10 f0       	push   $0xf0104a4c
f01000a6:	e8 96 2c 00 00       	call   f0102d41 <cprintf>
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
f01000be:	68 71 4a 10 f0       	push   $0xf0104a71
f01000c3:	e8 79 2c 00 00       	call   f0102d41 <cprintf>
f01000c8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f01000cb:	83 ec 0c             	sub    $0xc,%esp
f01000ce:	68 78 4a 10 f0       	push   $0xf0104a78
f01000d3:	e8 69 2c 00 00       	call   f0102d41 <cprintf>
f01000d8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000db:	83 ec 0c             	sub    $0xc,%esp
f01000de:	68 c0 4a 10 f0       	push   $0xf0104ac0
f01000e3:	e8 59 2c 00 00       	call   f0102d41 <cprintf>
f01000e8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                   !! FCIS says HELLO !!                     !!\n");
f01000eb:	83 ec 0c             	sub    $0xc,%esp
f01000ee:	68 08 4b 10 f0       	push   $0xf0104b08
f01000f3:	e8 49 2c 00 00       	call   f0102d41 <cprintf>
f01000f8:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!                                                             !!\n");
f01000fb:	83 ec 0c             	sub    $0xc,%esp
f01000fe:	68 c0 4a 10 f0       	push   $0xf0104ac0
f0100103:	e8 39 2c 00 00       	call   f0102d41 <cprintf>
f0100108:	83 c4 10             	add    $0x10,%esp
	cprintf("\t\t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
f010010b:	83 ec 0c             	sub    $0xc,%esp
f010010e:	68 78 4a 10 f0       	push   $0xf0104a78
f0100113:	e8 29 2c 00 00       	call   f0102d41 <cprintf>
f0100118:	83 c4 10             	add    $0x10,%esp
	cprintf("\n\n\n\n");	
f010011b:	83 ec 0c             	sub    $0xc,%esp
f010011e:	68 4d 4b 10 f0       	push   $0xf0104b4d
f0100123:	e8 19 2c 00 00       	call   f0102d41 <cprintf>
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
f0100134:	a1 00 cc 14 f0       	mov    0xf014cc00,%eax
f0100139:	85 c0                	test   %eax,%eax
f010013b:	74 02                	je     f010013f <_panic+0x11>
		goto dead;
f010013d:	eb 49                	jmp    f0100188 <_panic+0x5a>
	panicstr = fmt;
f010013f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100142:	a3 00 cc 14 f0       	mov    %eax,0xf014cc00

	va_start(ap, fmt);
f0100147:	8d 45 10             	lea    0x10(%ebp),%eax
f010014a:	83 c0 04             	add    $0x4,%eax
f010014d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cprintf("kernel panic at %s:%d: ", file, line);
f0100150:	83 ec 04             	sub    $0x4,%esp
f0100153:	ff 75 0c             	pushl  0xc(%ebp)
f0100156:	ff 75 08             	pushl  0x8(%ebp)
f0100159:	68 52 4b 10 f0       	push   $0xf0104b52
f010015e:	e8 de 2b 00 00       	call   f0102d41 <cprintf>
f0100163:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f0100166:	8b 45 10             	mov    0x10(%ebp),%eax
f0100169:	83 ec 08             	sub    $0x8,%esp
f010016c:	ff 75 f4             	pushl  -0xc(%ebp)
f010016f:	50                   	push   %eax
f0100170:	e8 a3 2b 00 00       	call   f0102d18 <vcprintf>
f0100175:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f0100178:	83 ec 0c             	sub    $0xc,%esp
f010017b:	68 6a 4b 10 f0       	push   $0xf0104b6a
f0100180:	e8 bc 2b 00 00       	call   f0102d41 <cprintf>
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
f01001a7:	68 6c 4b 10 f0       	push   $0xf0104b6c
f01001ac:	e8 90 2b 00 00       	call   f0102d41 <cprintf>
f01001b1:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
f01001b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01001b7:	83 ec 08             	sub    $0x8,%esp
f01001ba:	ff 75 f4             	pushl  -0xc(%ebp)
f01001bd:	50                   	push   %eax
f01001be:	e8 55 2b 00 00       	call   f0102d18 <vcprintf>
f01001c3:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
f01001c6:	83 ec 0c             	sub    $0xc,%esp
f01001c9:	68 6a 4b 10 f0       	push   $0xf0104b6a
f01001ce:	e8 6e 2b 00 00       	call   f0102d41 <cprintf>
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
f0100221:	a1 20 cc 14 f0       	mov    0xf014cc20,%eax
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
f01002dc:	a3 20 cc 14 f0       	mov    %eax,0xf014cc20
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
f01003f4:	c7 05 24 cc 14 f0 b4 	movl   $0x3b4,0xf014cc24
f01003fb:	03 00 00 
f01003fe:	eb 14                	jmp    f0100414 <cga_init+0x52>
	} else {
		*cp = was;
f0100400:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0100403:	66 8b 45 fa          	mov    -0x6(%ebp),%ax
f0100407:	66 89 02             	mov    %ax,(%edx)
		addr_6845 = CGA_BASE;
f010040a:	c7 05 24 cc 14 f0 d4 	movl   $0x3d4,0xf014cc24
f0100411:	03 00 00 
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100414:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
f0100419:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010041c:	c6 45 e0 0e          	movb   $0xe,-0x20(%ebp)
f0100420:	8a 45 e0             	mov    -0x20(%ebp),%al
f0100423:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100426:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100427:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
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
f0100445:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
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
f0100458:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
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
f0100476:	a3 28 cc 14 f0       	mov    %eax,0xf014cc28
	crt_pos = pos;
f010047b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010047e:	66 a3 2c cc 14 f0    	mov    %ax,0xf014cc2c
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
f01004cb:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f01004d1:	66 85 c0             	test   %ax,%ax
f01004d4:	0f 84 d0 00 00 00    	je     f01005aa <cga_putc+0x123>
			crt_pos--;
f01004da:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f01004e0:	48                   	dec    %eax
f01004e1:	66 a3 2c cc 14 f0    	mov    %ax,0xf014cc2c
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004e7:	8b 15 28 cc 14 f0    	mov    0xf014cc28,%edx
f01004ed:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
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
f010050a:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f0100510:	83 c0 50             	add    $0x50,%eax
f0100513:	66 a3 2c cc 14 f0    	mov    %ax,0xf014cc2c
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100519:	66 8b 0d 2c cc 14 f0 	mov    0xf014cc2c,%cx
f0100520:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f0100526:	bb 50 00 00 00       	mov    $0x50,%ebx
f010052b:	ba 00 00 00 00       	mov    $0x0,%edx
f0100530:	66 f7 f3             	div    %bx
f0100533:	89 d0                	mov    %edx,%eax
f0100535:	29 c1                	sub    %eax,%ecx
f0100537:	89 c8                	mov    %ecx,%eax
f0100539:	66 a3 2c cc 14 f0    	mov    %ax,0xf014cc2c
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
f0100584:	8b 0d 28 cc 14 f0    	mov    0xf014cc28,%ecx
f010058a:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f0100590:	8d 50 01             	lea    0x1(%eax),%edx
f0100593:	66 89 15 2c cc 14 f0 	mov    %dx,0xf014cc2c
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
f01005ab:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f01005b1:	66 3d cf 07          	cmp    $0x7cf,%ax
f01005b5:	76 58                	jbe    f010060f <cga_putc+0x188>
		int i;

		memcpy(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16));
f01005b7:	a1 28 cc 14 f0       	mov    0xf014cc28,%eax
f01005bc:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01005c2:	a1 28 cc 14 f0       	mov    0xf014cc28,%eax
f01005c7:	83 ec 04             	sub    $0x4,%esp
f01005ca:	68 00 0f 00 00       	push   $0xf00
f01005cf:	52                   	push   %edx
f01005d0:	50                   	push   %eax
f01005d1:	e8 7d 3e 00 00       	call   f0104453 <memcpy>
f01005d6:	83 c4 10             	add    $0x10,%esp
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005d9:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
f01005e0:	eb 15                	jmp    f01005f7 <cga_putc+0x170>
			crt_buf[i] = 0x0700 | ' ';
f01005e2:	8b 15 28 cc 14 f0    	mov    0xf014cc28,%edx
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
f0100600:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f0100606:	83 e8 50             	sub    $0x50,%eax
f0100609:	66 a3 2c cc 14 f0    	mov    %ax,0xf014cc2c
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010060f:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
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
f0100622:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f0100628:	66 c1 e8 08          	shr    $0x8,%ax
f010062c:	0f b6 c0             	movzbl %al,%eax
f010062f:	8b 15 24 cc 14 f0    	mov    0xf014cc24,%edx
f0100635:	42                   	inc    %edx
f0100636:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0100639:	88 45 e1             	mov    %al,-0x1f(%ebp)
f010063c:	8a 45 e1             	mov    -0x1f(%ebp),%al
f010063f:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0100642:	ee                   	out    %al,(%dx)
	outb(addr_6845, 15);
f0100643:	a1 24 cc 14 f0       	mov    0xf014cc24,%eax
f0100648:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010064b:	c6 45 e2 0f          	movb   $0xf,-0x1e(%ebp)
f010064f:	8a 45 e2             	mov    -0x1e(%ebp),%al
f0100652:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100655:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos);
f0100656:	66 a1 2c cc 14 f0    	mov    0xf014cc2c,%ax
f010065c:	0f b6 c0             	movzbl %al,%eax
f010065f:	8b 15 24 cc 14 f0    	mov    0xf014cc24,%edx
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
f01006c2:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f01006c7:	83 c8 40             	or     $0x40,%eax
f01006ca:	a3 48 ce 14 f0       	mov    %eax,0xf014ce48
		return 0;
f01006cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d4:	e9 21 01 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (data & 0x80) {
f01006d9:	8a 45 f3             	mov    -0xd(%ebp),%al
f01006dc:	84 c0                	test   %al,%al
f01006de:	79 44                	jns    f0100724 <kbd_proc_data+0xab>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01006e0:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
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
f01006fe:	8a 80 20 a0 11 f0    	mov    -0xfee5fe0(%eax),%al
f0100704:	83 c8 40             	or     $0x40,%eax
f0100707:	0f b6 c0             	movzbl %al,%eax
f010070a:	f7 d0                	not    %eax
f010070c:	89 c2                	mov    %eax,%edx
f010070e:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f0100713:	21 d0                	and    %edx,%eax
f0100715:	a3 48 ce 14 f0       	mov    %eax,0xf014ce48
		return 0;
f010071a:	b8 00 00 00 00       	mov    $0x0,%eax
f010071f:	e9 d6 00 00 00       	jmp    f01007fa <kbd_proc_data+0x181>
	} else if (shift & E0ESC) {
f0100724:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f0100729:	83 e0 40             	and    $0x40,%eax
f010072c:	85 c0                	test   %eax,%eax
f010072e:	74 11                	je     f0100741 <kbd_proc_data+0xc8>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100730:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
		shift &= ~E0ESC;
f0100734:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f0100739:	83 e0 bf             	and    $0xffffffbf,%eax
f010073c:	a3 48 ce 14 f0       	mov    %eax,0xf014ce48
	}

	shift |= shiftcode[data];
f0100741:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100745:	8a 80 20 a0 11 f0    	mov    -0xfee5fe0(%eax),%al
f010074b:	0f b6 d0             	movzbl %al,%edx
f010074e:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f0100753:	09 d0                	or     %edx,%eax
f0100755:	a3 48 ce 14 f0       	mov    %eax,0xf014ce48
	shift ^= togglecode[data];
f010075a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f010075e:	8a 80 20 a1 11 f0    	mov    -0xfee5ee0(%eax),%al
f0100764:	0f b6 d0             	movzbl %al,%edx
f0100767:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f010076c:	31 d0                	xor    %edx,%eax
f010076e:	a3 48 ce 14 f0       	mov    %eax,0xf014ce48

	c = charcode[shift & (CTL | SHIFT)][data];
f0100773:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f0100778:	83 e0 03             	and    $0x3,%eax
f010077b:	8b 14 85 20 a5 11 f0 	mov    -0xfee5ae0(,%eax,4),%edx
f0100782:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
f0100786:	01 d0                	add    %edx,%eax
f0100788:	8a 00                	mov    (%eax),%al
f010078a:	0f b6 c0             	movzbl %al,%eax
f010078d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (shift & CAPSLOCK) {
f0100790:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
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
f01007be:	a1 48 ce 14 f0       	mov    0xf014ce48,%eax
f01007c3:	f7 d0                	not    %eax
f01007c5:	83 e0 06             	and    $0x6,%eax
f01007c8:	85 c0                	test   %eax,%eax
f01007ca:	75 2b                	jne    f01007f7 <kbd_proc_data+0x17e>
f01007cc:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
f01007d3:	75 22                	jne    f01007f7 <kbd_proc_data+0x17e>
		cprintf("Rebooting!\n");
f01007d5:	83 ec 0c             	sub    $0xc,%esp
f01007d8:	68 86 4b 10 f0       	push   $0xf0104b86
f01007dd:	e8 5f 25 00 00       	call   f0102d41 <cprintf>
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
f010082b:	a1 44 ce 14 f0       	mov    0xf014ce44,%eax
f0100830:	8d 50 01             	lea    0x1(%eax),%edx
f0100833:	89 15 44 ce 14 f0    	mov    %edx,0xf014ce44
f0100839:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010083c:	88 90 40 cc 14 f0    	mov    %dl,-0xfeb33c0(%eax)
		if (cons.wpos == CONSBUFSIZE)
f0100842:	a1 44 ce 14 f0       	mov    0xf014ce44,%eax
f0100847:	3d 00 02 00 00       	cmp    $0x200,%eax
f010084c:	75 0a                	jne    f0100858 <cons_intr+0x3d>
			cons.wpos = 0;
f010084e:	c7 05 44 ce 14 f0 00 	movl   $0x0,0xf014ce44
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
f0100879:	8b 15 40 ce 14 f0    	mov    0xf014ce40,%edx
f010087f:	a1 44 ce 14 f0       	mov    0xf014ce44,%eax
f0100884:	39 c2                	cmp    %eax,%edx
f0100886:	74 35                	je     f01008bd <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
f0100888:	a1 40 ce 14 f0       	mov    0xf014ce40,%eax
f010088d:	8d 50 01             	lea    0x1(%eax),%edx
f0100890:	89 15 40 ce 14 f0    	mov    %edx,0xf014ce40
f0100896:	8a 80 40 cc 14 f0    	mov    -0xfeb33c0(%eax),%al
f010089c:	0f b6 c0             	movzbl %al,%eax
f010089f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if (cons.rpos == CONSBUFSIZE)
f01008a2:	a1 40 ce 14 f0       	mov    0xf014ce40,%eax
f01008a7:	3d 00 02 00 00       	cmp    $0x200,%eax
f01008ac:	75 0a                	jne    f01008b8 <cons_getc+0x4f>
			cons.rpos = 0;
f01008ae:	c7 05 40 ce 14 f0 00 	movl   $0x0,0xf014ce40
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
f01008fb:	a1 20 cc 14 f0       	mov    0xf014cc20,%eax
f0100900:	85 c0                	test   %eax,%eax
f0100902:	75 10                	jne    f0100914 <console_initialize+0x2e>
		cprintf("Serial port does not exist!\n");
f0100904:	83 ec 0c             	sub    $0xc,%esp
f0100907:	68 92 4b 10 f0       	push   $0xf0104b92
f010090c:	e8 30 24 00 00       	call   f0102d41 <cprintf>
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
f0100964:	68 05 4c 10 f0       	push   $0xf0104c05
f0100969:	e8 c9 37 00 00       	call   f0104137 <readline>
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
	int number_of_arguments;
	//allocate array of char * of size MAX_ARGUMENTS = 16 found in string.h
	char *arguments[MAX_ARGUMENTS];


	strsplit(command_string, WHITESPACE, arguments, &number_of_arguments) ;
f0100993:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0100996:	50                   	push   %eax
f0100997:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010099a:	50                   	push   %eax
f010099b:	68 0b 4c 10 f0       	push   $0xf0104c0b
f01009a0:	ff 75 08             	pushl  0x8(%ebp)
f01009a3:	e8 33 3d 00 00       	call   f01046db <strsplit>
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
f01009d8:	05 30 a5 11 f0       	add    $0xf011a530,%eax
f01009dd:	8b 10                	mov    (%eax),%edx
f01009df:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	52                   	push   %edx
f01009e6:	50                   	push   %eax
f01009e7:	e8 55 39 00 00       	call   f0104341 <strcmp>
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
f0100a02:	83 f8 01             	cmp    $0x1,%eax
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
f0100a19:	05 38 a5 11 f0       	add    $0xf011a538,%eax
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
f0100a3f:	68 10 4c 10 f0       	push   $0xf0104c10
f0100a44:	e8 f8 22 00 00       	call   f0102d41 <cprintf>
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
f0100a6e:	05 34 a5 11 f0       	add    $0xf011a534,%eax
f0100a73:	8b 10                	mov    (%eax),%edx
f0100a75:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0100a78:	89 c8                	mov    %ecx,%eax
f0100a7a:	01 c0                	add    %eax,%eax
f0100a7c:	01 c8                	add    %ecx,%eax
f0100a7e:	c1 e0 02             	shl    $0x2,%eax
f0100a81:	05 30 a5 11 f0       	add    $0xf011a530,%eax
f0100a86:	8b 00                	mov    (%eax),%eax
f0100a88:	83 ec 04             	sub    $0x4,%esp
f0100a8b:	52                   	push   %edx
f0100a8c:	50                   	push   %eax
f0100a8d:	68 26 4c 10 f0       	push   $0xf0104c26
f0100a92:	e8 aa 22 00 00       	call   f0102d41 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp

//print name and description of each command
int command_help(int number_of_arguments, char **arguments)
{
	int i;
	for (i = 0; i < NUM_OF_COMMANDS; i++)
f0100a9a:	ff 45 f4             	incl   -0xc(%ebp)
f0100a9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100aa0:	83 f8 01             	cmp    $0x1,%eax
f0100aa3:	76 bd                	jbe    f0100a62 <command_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].description);
	
	cprintf("-------------------\n");
f0100aa5:	83 ec 0c             	sub    $0xc,%esp
f0100aa8:	68 2f 4c 10 f0       	push   $0xf0104c2f
f0100aad:	e8 8f 22 00 00       	call   f0102d41 <cprintf>
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
f0100ac5:	68 44 4c 10 f0       	push   $0xf0104c44
f0100aca:	e8 72 22 00 00       	call   f0102d41 <cprintf>
f0100acf:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start Address of the kernel 			%08x (virt)  %08x (phys)\n", start_of_kernel, start_of_kernel - KERNEL_BASE);
f0100ad2:	b8 0c 00 10 00       	mov    $0x10000c,%eax
f0100ad7:	83 ec 04             	sub    $0x4,%esp
f0100ada:	50                   	push   %eax
f0100adb:	68 0c 00 10 f0       	push   $0xf010000c
f0100ae0:	68 60 4c 10 f0       	push   $0xf0104c60
f0100ae5:	e8 57 22 00 00       	call   f0102d41 <cprintf>
f0100aea:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of kernel code  			%08x (virt)  %08x (phys)\n", end_of_kernel_code_section, end_of_kernel_code_section - KERNEL_BASE);
f0100aed:	b8 11 4a 10 00       	mov    $0x104a11,%eax
f0100af2:	83 ec 04             	sub    $0x4,%esp
f0100af5:	50                   	push   %eax
f0100af6:	68 11 4a 10 f0       	push   $0xf0104a11
f0100afb:	68 9c 4c 10 f0       	push   $0xf0104c9c
f0100b00:	e8 3c 22 00 00       	call   f0102d41 <cprintf>
f0100b05:	83 c4 10             	add    $0x10,%esp
	cprintf("  Start addr. of uninitialized data section 	%08x (virt)  %08x (phys)\n", start_of_uninitialized_data_section, start_of_uninitialized_data_section - KERNEL_BASE);
f0100b08:	b8 f2 cb 14 00       	mov    $0x14cbf2,%eax
f0100b0d:	83 ec 04             	sub    $0x4,%esp
f0100b10:	50                   	push   %eax
f0100b11:	68 f2 cb 14 f0       	push   $0xf014cbf2
f0100b16:	68 d8 4c 10 f0       	push   $0xf0104cd8
f0100b1b:	e8 21 22 00 00       	call   f0102d41 <cprintf>
f0100b20:	83 c4 10             	add    $0x10,%esp
	cprintf("  End address of the kernel   			%08x (virt)  %08x (phys)\n", end_of_kernel, end_of_kernel - KERNEL_BASE);
f0100b23:	b8 ec d6 14 00       	mov    $0x14d6ec,%eax
f0100b28:	83 ec 04             	sub    $0x4,%esp
f0100b2b:	50                   	push   %eax
f0100b2c:	68 ec d6 14 f0       	push   $0xf014d6ec
f0100b31:	68 20 4d 10 f0       	push   $0xf0104d20
f0100b36:	e8 06 22 00 00       	call   f0102d41 <cprintf>
f0100b3b:	83 c4 10             	add    $0x10,%esp
	cprintf("Kernel executable memory footprint: %d KB\n",
		(end_of_kernel-start_of_kernel+1023)/1024);
f0100b3e:	b8 ec d6 14 f0       	mov    $0xf014d6ec,%eax
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
f0100b62:	68 5c 4d 10 f0       	push   $0xf0104d5c
f0100b67:	e8 d5 21 00 00       	call   f0102d41 <cprintf>
f0100b6c:	83 c4 10             	add    $0x10,%esp
		(end_of_kernel-start_of_kernel+1023)/1024);
	return 0;
f0100b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100b74:	c9                   	leave  
f0100b75:	c3                   	ret    

f0100b76 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0100b76:	55                   	push   %ebp
f0100b77:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0100b79:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b7c:	8b 15 dc d6 14 f0    	mov    0xf014d6dc,%edx
f0100b82:	29 d0                	sub    %edx,%eax
f0100b84:	c1 f8 02             	sar    $0x2,%eax
f0100b87:	89 c2                	mov    %eax,%edx
f0100b89:	89 d0                	mov    %edx,%eax
f0100b8b:	c1 e0 02             	shl    $0x2,%eax
f0100b8e:	01 d0                	add    %edx,%eax
f0100b90:	c1 e0 02             	shl    $0x2,%eax
f0100b93:	01 d0                	add    %edx,%eax
f0100b95:	c1 e0 02             	shl    $0x2,%eax
f0100b98:	01 d0                	add    %edx,%eax
f0100b9a:	89 c1                	mov    %eax,%ecx
f0100b9c:	c1 e1 08             	shl    $0x8,%ecx
f0100b9f:	01 c8                	add    %ecx,%eax
f0100ba1:	89 c1                	mov    %eax,%ecx
f0100ba3:	c1 e1 10             	shl    $0x10,%ecx
f0100ba6:	01 c8                	add    %ecx,%eax
f0100ba8:	01 c0                	add    %eax,%eax
f0100baa:	01 d0                	add    %edx,%eax
}
f0100bac:	5d                   	pop    %ebp
f0100bad:	c3                   	ret    

f0100bae <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0100bae:	55                   	push   %ebp
f0100baf:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0100bb1:	ff 75 08             	pushl  0x8(%ebp)
f0100bb4:	e8 bd ff ff ff       	call   f0100b76 <to_frame_number>
f0100bb9:	83 c4 04             	add    $0x4,%esp
f0100bbc:	c1 e0 0c             	shl    $0xc,%eax
}
f0100bbf:	c9                   	leave  
f0100bc0:	c3                   	ret    

f0100bc1 <nvram_read>:
{
	sizeof(gdt) - 1, (unsigned long) gdt
};

int nvram_read(int r)
{	
f0100bc1:	55                   	push   %ebp
f0100bc2:	89 e5                	mov    %esp,%ebp
f0100bc4:	53                   	push   %ebx
f0100bc5:	83 ec 04             	sub    $0x4,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bcb:	83 ec 0c             	sub    $0xc,%esp
f0100bce:	50                   	push   %eax
f0100bcf:	e8 b8 20 00 00       	call   f0102c8c <mc146818_read>
f0100bd4:	83 c4 10             	add    $0x10,%esp
f0100bd7:	89 c3                	mov    %eax,%ebx
f0100bd9:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bdc:	40                   	inc    %eax
f0100bdd:	83 ec 0c             	sub    $0xc,%esp
f0100be0:	50                   	push   %eax
f0100be1:	e8 a6 20 00 00       	call   f0102c8c <mc146818_read>
f0100be6:	83 c4 10             	add    $0x10,%esp
f0100be9:	c1 e0 08             	shl    $0x8,%eax
f0100bec:	09 d8                	or     %ebx,%eax
}
f0100bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bf1:	c9                   	leave  
f0100bf2:	c3                   	ret    

f0100bf3 <detect_memory>:
	
void detect_memory()
{
f0100bf3:	55                   	push   %ebp
f0100bf4:	89 e5                	mov    %esp,%ebp
f0100bf6:	83 ec 18             	sub    $0x18,%esp
	// CMOS tells us how many kilobytes there are
	size_of_base_mem = ROUNDDOWN(nvram_read(NVRAM_BASELO)*1024, PAGE_SIZE);
f0100bf9:	83 ec 0c             	sub    $0xc,%esp
f0100bfc:	6a 15                	push   $0x15
f0100bfe:	e8 be ff ff ff       	call   f0100bc1 <nvram_read>
f0100c03:	83 c4 10             	add    $0x10,%esp
f0100c06:	c1 e0 0a             	shl    $0xa,%eax
f0100c09:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c0f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c14:	a3 d4 d6 14 f0       	mov    %eax,0xf014d6d4
	size_of_extended_mem = ROUNDDOWN(nvram_read(NVRAM_EXTLO)*1024, PAGE_SIZE);
f0100c19:	83 ec 0c             	sub    $0xc,%esp
f0100c1c:	6a 17                	push   $0x17
f0100c1e:	e8 9e ff ff ff       	call   f0100bc1 <nvram_read>
f0100c23:	83 c4 10             	add    $0x10,%esp
f0100c26:	c1 e0 0a             	shl    $0xa,%eax
f0100c29:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c34:	a3 cc d6 14 f0       	mov    %eax,0xf014d6cc

	// Calculate the maxmium physical address based on whether
	// or not there is any extended memory.  See comment in ../inc/mmu.h.
	if (size_of_extended_mem)
f0100c39:	a1 cc d6 14 f0       	mov    0xf014d6cc,%eax
f0100c3e:	85 c0                	test   %eax,%eax
f0100c40:	74 11                	je     f0100c53 <detect_memory+0x60>
		maxpa = PHYS_EXTENDED_MEM + size_of_extended_mem;
f0100c42:	a1 cc d6 14 f0       	mov    0xf014d6cc,%eax
f0100c47:	05 00 00 10 00       	add    $0x100000,%eax
f0100c4c:	a3 d0 d6 14 f0       	mov    %eax,0xf014d6d0
f0100c51:	eb 0a                	jmp    f0100c5d <detect_memory+0x6a>
	else
		maxpa = size_of_extended_mem;
f0100c53:	a1 cc d6 14 f0       	mov    0xf014d6cc,%eax
f0100c58:	a3 d0 d6 14 f0       	mov    %eax,0xf014d6d0

	number_of_frames = maxpa / PAGE_SIZE;
f0100c5d:	a1 d0 d6 14 f0       	mov    0xf014d6d0,%eax
f0100c62:	c1 e8 0c             	shr    $0xc,%eax
f0100c65:	a3 c8 d6 14 f0       	mov    %eax,0xf014d6c8

	cprintf("Physical memory: %dK available, ", (int)(maxpa/1024));
f0100c6a:	a1 d0 d6 14 f0       	mov    0xf014d6d0,%eax
f0100c6f:	c1 e8 0a             	shr    $0xa,%eax
f0100c72:	83 ec 08             	sub    $0x8,%esp
f0100c75:	50                   	push   %eax
f0100c76:	68 88 4d 10 f0       	push   $0xf0104d88
f0100c7b:	e8 c1 20 00 00       	call   f0102d41 <cprintf>
f0100c80:	83 c4 10             	add    $0x10,%esp
	cprintf("base = %dK, extended = %dK\n", (int)(size_of_base_mem/1024), (int)(size_of_extended_mem/1024));
f0100c83:	a1 cc d6 14 f0       	mov    0xf014d6cc,%eax
f0100c88:	c1 e8 0a             	shr    $0xa,%eax
f0100c8b:	89 c2                	mov    %eax,%edx
f0100c8d:	a1 d4 d6 14 f0       	mov    0xf014d6d4,%eax
f0100c92:	c1 e8 0a             	shr    $0xa,%eax
f0100c95:	83 ec 04             	sub    $0x4,%esp
f0100c98:	52                   	push   %edx
f0100c99:	50                   	push   %eax
f0100c9a:	68 a9 4d 10 f0       	push   $0xf0104da9
f0100c9f:	e8 9d 20 00 00       	call   f0102d41 <cprintf>
f0100ca4:	83 c4 10             	add    $0x10,%esp
}
f0100ca7:	90                   	nop
f0100ca8:	c9                   	leave  
f0100ca9:	c3                   	ret    

f0100caa <check_boot_pgdir>:
// but it is a pretty good check.
//
uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va);

void check_boot_pgdir()
{
f0100caa:	55                   	push   %ebp
f0100cab:	89 e5                	mov    %esp,%ebp
f0100cad:	83 ec 28             	sub    $0x28,%esp
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
f0100cb0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0100cb7:	8b 15 c8 d6 14 f0    	mov    0xf014d6c8,%edx
f0100cbd:	89 d0                	mov    %edx,%eax
f0100cbf:	01 c0                	add    %eax,%eax
f0100cc1:	01 d0                	add    %edx,%eax
f0100cc3:	c1 e0 02             	shl    $0x2,%eax
f0100cc6:	89 c2                	mov    %eax,%edx
f0100cc8:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100ccb:	01 d0                	add    %edx,%eax
f0100ccd:	48                   	dec    %eax
f0100cce:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100cd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100cd4:	ba 00 00 00 00       	mov    $0x0,%edx
f0100cd9:	f7 75 f0             	divl   -0x10(%ebp)
f0100cdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100cdf:	29 d0                	sub    %edx,%eax
f0100ce1:	89 45 e8             	mov    %eax,-0x18(%ebp)
	for (i = 0; i < n; i += PAGE_SIZE)
f0100ce4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100ceb:	eb 71                	jmp    f0100d5e <check_boot_pgdir+0xb4>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);
f0100ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100cf0:	8d 90 00 00 00 ef    	lea    -0x11000000(%eax),%edx
f0100cf6:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100cfb:	83 ec 08             	sub    $0x8,%esp
f0100cfe:	52                   	push   %edx
f0100cff:	50                   	push   %eax
f0100d00:	e8 f4 01 00 00       	call   f0100ef9 <check_va2pa>
f0100d05:	83 c4 10             	add    $0x10,%esp
f0100d08:	89 c2                	mov    %eax,%edx
f0100d0a:	a1 dc d6 14 f0       	mov    0xf014d6dc,%eax
f0100d0f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d12:	81 7d e4 ff ff ff ef 	cmpl   $0xefffffff,-0x1c(%ebp)
f0100d19:	77 14                	ja     f0100d2f <check_boot_pgdir+0x85>
f0100d1b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d1e:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0100d23:	6a 5e                	push   $0x5e
f0100d25:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100d2a:	e8 ff f3 ff ff       	call   f010012e <_panic>
f0100d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100d32:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d3b:	01 c8                	add    %ecx,%eax
f0100d3d:	39 c2                	cmp    %eax,%edx
f0100d3f:	74 16                	je     f0100d57 <check_boot_pgdir+0xad>
f0100d41:	68 08 4e 10 f0       	push   $0xf0104e08
f0100d46:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100d4b:	6a 5e                	push   $0x5e
f0100d4d:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100d52:	e8 d7 f3 ff ff       	call   f010012e <_panic>
{
	uint32 i, n;

	// check frames_info array
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
f0100d57:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0100d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d61:	3b 45 e8             	cmp    -0x18(%ebp),%eax
f0100d64:	72 87                	jb     f0100ced <check_boot_pgdir+0x43>
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0100d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100d6d:	eb 3d                	jmp    f0100dac <check_boot_pgdir+0x102>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);
f0100d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100d72:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
f0100d78:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100d7d:	83 ec 08             	sub    $0x8,%esp
f0100d80:	52                   	push   %edx
f0100d81:	50                   	push   %eax
f0100d82:	e8 72 01 00 00       	call   f0100ef9 <check_va2pa>
f0100d87:	83 c4 10             	add    $0x10,%esp
f0100d8a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0100d8d:	74 16                	je     f0100da5 <check_boot_pgdir+0xfb>
f0100d8f:	68 80 4e 10 f0       	push   $0xf0104e80
f0100d94:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100d99:	6a 62                	push   $0x62
f0100d9b:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100da0:	e8 89 f3 ff ff       	call   f010012e <_panic>
	n = ROUNDUP(number_of_frames*sizeof(struct Frame_Info), PAGE_SIZE);
	for (i = 0; i < n; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, READ_ONLY_FRAMES_INFO + i) == K_PHYSICAL_ADDRESS(frames_info) + i);

	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
f0100da5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0100dac:	81 7d f4 00 00 00 10 	cmpl   $0x10000000,-0xc(%ebp)
f0100db3:	75 ba                	jne    f0100d6f <check_boot_pgdir+0xc5>
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0100db5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100dbc:	eb 6e                	jmp    f0100e2c <check_boot_pgdir+0x182>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);
f0100dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100dc1:	8d 90 00 80 bf ef    	lea    -0x10408000(%eax),%edx
f0100dc7:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100dcc:	83 ec 08             	sub    $0x8,%esp
f0100dcf:	52                   	push   %edx
f0100dd0:	50                   	push   %eax
f0100dd1:	e8 23 01 00 00       	call   f0100ef9 <check_va2pa>
f0100dd6:	83 c4 10             	add    $0x10,%esp
f0100dd9:	c7 45 e0 00 20 11 f0 	movl   $0xf0112000,-0x20(%ebp)
f0100de0:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0100de7:	77 14                	ja     f0100dfd <check_boot_pgdir+0x153>
f0100de9:	ff 75 e0             	pushl  -0x20(%ebp)
f0100dec:	68 c8 4d 10 f0       	push   $0xf0104dc8
f0100df1:	6a 66                	push   $0x66
f0100df3:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100df8:	e8 31 f3 ff ff       	call   f010012e <_panic>
f0100dfd:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100e00:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
f0100e06:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100e09:	01 ca                	add    %ecx,%edx
f0100e0b:	39 d0                	cmp    %edx,%eax
f0100e0d:	74 16                	je     f0100e25 <check_boot_pgdir+0x17b>
f0100e0f:	68 b8 4e 10 f0       	push   $0xf0104eb8
f0100e14:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100e19:	6a 66                	push   $0x66
f0100e1b:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100e20:	e8 09 f3 ff ff       	call   f010012e <_panic>
	// check phys mem
	for (i = 0; KERNEL_BASE + i != 0; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_BASE + i) == i);

	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
f0100e25:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0100e2c:	81 7d f4 ff 7f 00 00 	cmpl   $0x7fff,-0xc(%ebp)
f0100e33:	76 89                	jbe    f0100dbe <check_boot_pgdir+0x114>
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0100e35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0100e3c:	e9 98 00 00 00       	jmp    f0100ed9 <check_boot_pgdir+0x22f>
		switch (i) {
f0100e41:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100e44:	2d bb 03 00 00       	sub    $0x3bb,%eax
f0100e49:	83 f8 04             	cmp    $0x4,%eax
f0100e4c:	77 29                	ja     f0100e77 <check_boot_pgdir+0x1cd>
		case PDX(VPT):
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
f0100e4e:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100e56:	c1 e2 02             	shl    $0x2,%edx
f0100e59:	01 d0                	add    %edx,%eax
f0100e5b:	8b 00                	mov    (%eax),%eax
f0100e5d:	85 c0                	test   %eax,%eax
f0100e5f:	75 71                	jne    f0100ed2 <check_boot_pgdir+0x228>
f0100e61:	68 2e 4f 10 f0       	push   $0xf0104f2e
f0100e66:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100e6b:	6a 70                	push   $0x70
f0100e6d:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100e72:	e8 b7 f2 ff ff       	call   f010012e <_panic>
			break;
		default:
			if (i >= PDX(KERNEL_BASE))
f0100e77:	81 7d f4 bf 03 00 00 	cmpl   $0x3bf,-0xc(%ebp)
f0100e7e:	76 29                	jbe    f0100ea9 <check_boot_pgdir+0x1ff>
				assert(ptr_page_directory[i]);
f0100e80:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100e85:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100e88:	c1 e2 02             	shl    $0x2,%edx
f0100e8b:	01 d0                	add    %edx,%eax
f0100e8d:	8b 00                	mov    (%eax),%eax
f0100e8f:	85 c0                	test   %eax,%eax
f0100e91:	75 42                	jne    f0100ed5 <check_boot_pgdir+0x22b>
f0100e93:	68 2e 4f 10 f0       	push   $0xf0104f2e
f0100e98:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100e9d:	6a 74                	push   $0x74
f0100e9f:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100ea4:	e8 85 f2 ff ff       	call   f010012e <_panic>
			else				
				assert(ptr_page_directory[i] == 0);
f0100ea9:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0100eae:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100eb1:	c1 e2 02             	shl    $0x2,%edx
f0100eb4:	01 d0                	add    %edx,%eax
f0100eb6:	8b 00                	mov    (%eax),%eax
f0100eb8:	85 c0                	test   %eax,%eax
f0100eba:	74 19                	je     f0100ed5 <check_boot_pgdir+0x22b>
f0100ebc:	68 44 4f 10 f0       	push   $0xf0104f44
f0100ec1:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100ec6:	6a 76                	push   $0x76
f0100ec8:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100ecd:	e8 5c f2 ff ff       	call   f010012e <_panic>
		case PDX(UVPT):
		case PDX(KERNEL_STACK_TOP-1):
		case PDX(UENVS):
		case PDX(READ_ONLY_FRAMES_INFO):			
			assert(ptr_page_directory[i]);
			break;
f0100ed2:	90                   	nop
f0100ed3:	eb 01                	jmp    f0100ed6 <check_boot_pgdir+0x22c>
		default:
			if (i >= PDX(KERNEL_BASE))
				assert(ptr_page_directory[i]);
			else				
				assert(ptr_page_directory[i] == 0);
			break;
f0100ed5:	90                   	nop
	// check kernel stack
	for (i = 0; i < KERNEL_STACK_SIZE; i += PAGE_SIZE)
		assert(check_va2pa(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE + i) == K_PHYSICAL_ADDRESS(ptr_stack_bottom) + i);

	// check for zero/non-zero in PDEs
	for (i = 0; i < NPDENTRIES; i++) {
f0100ed6:	ff 45 f4             	incl   -0xc(%ebp)
f0100ed9:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
f0100ee0:	0f 86 5b ff ff ff    	jbe    f0100e41 <check_boot_pgdir+0x197>
			else				
				assert(ptr_page_directory[i] == 0);
			break;
		}
	}
	cprintf("check_boot_pgdir() succeeded!\n");
f0100ee6:	83 ec 0c             	sub    $0xc,%esp
f0100ee9:	68 60 4f 10 f0       	push   $0xf0104f60
f0100eee:	e8 4e 1e 00 00       	call   f0102d41 <cprintf>
f0100ef3:	83 c4 10             	add    $0x10,%esp
}
f0100ef6:	90                   	nop
f0100ef7:	c9                   	leave  
f0100ef8:	c3                   	ret    

f0100ef9 <check_va2pa>:
// defined by the page directory 'ptr_page_directory'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_boot_pgdir() function; it shouldn't be used elsewhere.

uint32 check_va2pa(uint32 *ptr_page_directory, uint32 va)
{
f0100ef9:	55                   	push   %ebp
f0100efa:	89 e5                	mov    %esp,%ebp
f0100efc:	83 ec 18             	sub    $0x18,%esp
	uint32 *p;

	ptr_page_directory = &ptr_page_directory[PDX(va)];
f0100eff:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f02:	c1 e8 16             	shr    $0x16,%eax
f0100f05:	c1 e0 02             	shl    $0x2,%eax
f0100f08:	01 45 08             	add    %eax,0x8(%ebp)
	if (!(*ptr_page_directory & PERM_PRESENT))
f0100f0b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f0e:	8b 00                	mov    (%eax),%eax
f0100f10:	83 e0 01             	and    $0x1,%eax
f0100f13:	85 c0                	test   %eax,%eax
f0100f15:	75 0a                	jne    f0100f21 <check_va2pa+0x28>
		return ~0;
f0100f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f1c:	e9 87 00 00 00       	jmp    f0100fa8 <check_va2pa+0xaf>
	p = (uint32*) K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(*ptr_page_directory));
f0100f21:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f24:	8b 00                	mov    (%eax),%eax
f0100f26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0100f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f31:	c1 e8 0c             	shr    $0xc,%eax
f0100f34:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100f37:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f0100f3c:	39 45 f0             	cmp    %eax,-0x10(%ebp)
f0100f3f:	72 17                	jb     f0100f58 <check_va2pa+0x5f>
f0100f41:	ff 75 f4             	pushl  -0xc(%ebp)
f0100f44:	68 80 4f 10 f0       	push   $0xf0104f80
f0100f49:	68 89 00 00 00       	push   $0x89
f0100f4e:	68 f9 4d 10 f0       	push   $0xf0104df9
f0100f53:	e8 d6 f1 ff ff       	call   f010012e <_panic>
f0100f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100f5b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f60:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (!(p[PTX(va)] & PERM_PRESENT))
f0100f63:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f66:	c1 e8 0c             	shr    $0xc,%eax
f0100f69:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100f6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0100f75:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f78:	01 d0                	add    %edx,%eax
f0100f7a:	8b 00                	mov    (%eax),%eax
f0100f7c:	83 e0 01             	and    $0x1,%eax
f0100f7f:	85 c0                	test   %eax,%eax
f0100f81:	75 07                	jne    f0100f8a <check_va2pa+0x91>
		return ~0;
f0100f83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100f88:	eb 1e                	jmp    f0100fa8 <check_va2pa+0xaf>
	return EXTRACT_ADDRESS(p[PTX(va)]);
f0100f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100f8d:	c1 e8 0c             	shr    $0xc,%eax
f0100f90:	25 ff 03 00 00       	and    $0x3ff,%eax
f0100f95:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0100f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100f9f:	01 d0                	add    %edx,%eax
f0100fa1:	8b 00                	mov    (%eax),%eax
f0100fa3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}
f0100fa8:	c9                   	leave  
f0100fa9:	c3                   	ret    

f0100faa <tlb_invalidate>:
		
void tlb_invalidate(uint32 *ptr_page_directory, void *virtual_address)
{
f0100faa:	55                   	push   %ebp
f0100fab:	89 e5                	mov    %esp,%ebp
f0100fad:	83 ec 10             	sub    $0x10,%esp
f0100fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100fb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0100fb9:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(virtual_address);
}
f0100fbc:	90                   	nop
f0100fbd:	c9                   	leave  
f0100fbe:	c3                   	ret    

f0100fbf <page_check>:

void page_check()
{
f0100fbf:	55                   	push   %ebp
f0100fc0:	89 e5                	mov    %esp,%ebp
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 24             	sub    $0x24,%esp
	struct Frame_Info *pp, *pp0, *pp1, *pp2;
	struct Linked_List fl;

	// should be able to allocate three frames_info
	pp0 = pp1 = pp2 = 0;
f0100fc6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
f0100fcd:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0100fd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100fd3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100fd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	assert(allocate_frame(&pp0) == 0);
f0100fd9:	83 ec 0c             	sub    $0xc,%esp
f0100fdc:	8d 45 f0             	lea    -0x10(%ebp),%eax
f0100fdf:	50                   	push   %eax
f0100fe0:	e8 e7 10 00 00       	call   f01020cc <allocate_frame>
f0100fe5:	83 c4 10             	add    $0x10,%esp
f0100fe8:	85 c0                	test   %eax,%eax
f0100fea:	74 19                	je     f0101005 <page_check+0x46>
f0100fec:	68 af 4f 10 f0       	push   $0xf0104faf
f0100ff1:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0100ff6:	68 9d 00 00 00       	push   $0x9d
f0100ffb:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101000:	e8 29 f1 ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp1) == 0);
f0101005:	83 ec 0c             	sub    $0xc,%esp
f0101008:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010100b:	50                   	push   %eax
f010100c:	e8 bb 10 00 00       	call   f01020cc <allocate_frame>
f0101011:	83 c4 10             	add    $0x10,%esp
f0101014:	85 c0                	test   %eax,%eax
f0101016:	74 19                	je     f0101031 <page_check+0x72>
f0101018:	68 c9 4f 10 f0       	push   $0xf0104fc9
f010101d:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101022:	68 9e 00 00 00       	push   $0x9e
f0101027:	68 f9 4d 10 f0       	push   $0xf0104df9
f010102c:	e8 fd f0 ff ff       	call   f010012e <_panic>
	assert(allocate_frame(&pp2) == 0);
f0101031:	83 ec 0c             	sub    $0xc,%esp
f0101034:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0101037:	50                   	push   %eax
f0101038:	e8 8f 10 00 00       	call   f01020cc <allocate_frame>
f010103d:	83 c4 10             	add    $0x10,%esp
f0101040:	85 c0                	test   %eax,%eax
f0101042:	74 19                	je     f010105d <page_check+0x9e>
f0101044:	68 e3 4f 10 f0       	push   $0xf0104fe3
f0101049:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010104e:	68 9f 00 00 00       	push   $0x9f
f0101053:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101058:	e8 d1 f0 ff ff       	call   f010012e <_panic>

	assert(pp0);
f010105d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101060:	85 c0                	test   %eax,%eax
f0101062:	75 19                	jne    f010107d <page_check+0xbe>
f0101064:	68 fd 4f 10 f0       	push   $0xf0104ffd
f0101069:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010106e:	68 a1 00 00 00       	push   $0xa1
f0101073:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101078:	e8 b1 f0 ff ff       	call   f010012e <_panic>
	assert(pp1 && pp1 != pp0);
f010107d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101080:	85 c0                	test   %eax,%eax
f0101082:	74 0a                	je     f010108e <page_check+0xcf>
f0101084:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101087:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010108a:	39 c2                	cmp    %eax,%edx
f010108c:	75 19                	jne    f01010a7 <page_check+0xe8>
f010108e:	68 01 50 10 f0       	push   $0xf0105001
f0101093:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101098:	68 a2 00 00 00       	push   $0xa2
f010109d:	68 f9 4d 10 f0       	push   $0xf0104df9
f01010a2:	e8 87 f0 ff ff       	call   f010012e <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01010a7:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01010aa:	85 c0                	test   %eax,%eax
f01010ac:	74 14                	je     f01010c2 <page_check+0x103>
f01010ae:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01010b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01010b4:	39 c2                	cmp    %eax,%edx
f01010b6:	74 0a                	je     f01010c2 <page_check+0x103>
f01010b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01010bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01010be:	39 c2                	cmp    %eax,%edx
f01010c0:	75 19                	jne    f01010db <page_check+0x11c>
f01010c2:	68 14 50 10 f0       	push   $0xf0105014
f01010c7:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01010cc:	68 a3 00 00 00       	push   $0xa3
f01010d1:	68 f9 4d 10 f0       	push   $0xf0104df9
f01010d6:	e8 53 f0 ff ff       	call   f010012e <_panic>

	// temporarily steal the rest of the free frames_info
	fl = free_frame_list;
f01010db:	a1 d8 d6 14 f0       	mov    0xf014d6d8,%eax
f01010e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	LIST_INIT(&free_frame_list);
f01010e3:	c7 05 d8 d6 14 f0 00 	movl   $0x0,0xf014d6d8
f01010ea:	00 00 00 

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f01010ed:	83 ec 0c             	sub    $0xc,%esp
f01010f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010f3:	50                   	push   %eax
f01010f4:	e8 d3 0f 00 00       	call   f01020cc <allocate_frame>
f01010f9:	83 c4 10             	add    $0x10,%esp
f01010fc:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01010ff:	74 19                	je     f010111a <page_check+0x15b>
f0101101:	68 34 50 10 f0       	push   $0xf0105034
f0101106:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010110b:	68 aa 00 00 00       	push   $0xaa
f0101110:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101115:	e8 14 f0 ff ff       	call   f010012e <_panic>

	// there is no free memory, so we can't allocate a page table 
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) < 0);
f010111a:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010111d:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101122:	6a 00                	push   $0x0
f0101124:	6a 00                	push   $0x0
f0101126:	52                   	push   %edx
f0101127:	50                   	push   %eax
f0101128:	e8 ac 11 00 00       	call   f01022d9 <map_frame>
f010112d:	83 c4 10             	add    $0x10,%esp
f0101130:	85 c0                	test   %eax,%eax
f0101132:	78 19                	js     f010114d <page_check+0x18e>
f0101134:	68 54 50 10 f0       	push   $0xf0105054
f0101139:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010113e:	68 ad 00 00 00       	push   $0xad
f0101143:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101148:	e8 e1 ef ff ff       	call   f010012e <_panic>

	// free pp0 and try again: pp0 should be used for page table
	free_frame(pp0);
f010114d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101150:	83 ec 0c             	sub    $0xc,%esp
f0101153:	50                   	push   %eax
f0101154:	e8 da 0f 00 00       	call   f0102133 <free_frame>
f0101159:	83 c4 10             	add    $0x10,%esp
	assert(map_frame(ptr_page_directory, pp1, 0x0, 0) == 0);
f010115c:	8b 55 ec             	mov    -0x14(%ebp),%edx
f010115f:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101164:	6a 00                	push   $0x0
f0101166:	6a 00                	push   $0x0
f0101168:	52                   	push   %edx
f0101169:	50                   	push   %eax
f010116a:	e8 6a 11 00 00       	call   f01022d9 <map_frame>
f010116f:	83 c4 10             	add    $0x10,%esp
f0101172:	85 c0                	test   %eax,%eax
f0101174:	74 19                	je     f010118f <page_check+0x1d0>
f0101176:	68 84 50 10 f0       	push   $0xf0105084
f010117b:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101180:	68 b1 00 00 00       	push   $0xb1
f0101185:	68 f9 4d 10 f0       	push   $0xf0104df9
f010118a:	e8 9f ef ff ff       	call   f010012e <_panic>
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f010118f:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101194:	8b 00                	mov    (%eax),%eax
f0101196:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010119b:	89 c3                	mov    %eax,%ebx
f010119d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01011a0:	83 ec 0c             	sub    $0xc,%esp
f01011a3:	50                   	push   %eax
f01011a4:	e8 05 fa ff ff       	call   f0100bae <to_physical_address>
f01011a9:	83 c4 10             	add    $0x10,%esp
f01011ac:	39 c3                	cmp    %eax,%ebx
f01011ae:	74 19                	je     f01011c9 <page_check+0x20a>
f01011b0:	68 b4 50 10 f0       	push   $0xf01050b4
f01011b5:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01011ba:	68 b2 00 00 00       	push   $0xb2
f01011bf:	68 f9 4d 10 f0       	push   $0xf0104df9
f01011c4:	e8 65 ef ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, 0x0) == to_physical_address(pp1));
f01011c9:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f01011ce:	83 ec 08             	sub    $0x8,%esp
f01011d1:	6a 00                	push   $0x0
f01011d3:	50                   	push   %eax
f01011d4:	e8 20 fd ff ff       	call   f0100ef9 <check_va2pa>
f01011d9:	83 c4 10             	add    $0x10,%esp
f01011dc:	89 c3                	mov    %eax,%ebx
f01011de:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011e1:	83 ec 0c             	sub    $0xc,%esp
f01011e4:	50                   	push   %eax
f01011e5:	e8 c4 f9 ff ff       	call   f0100bae <to_physical_address>
f01011ea:	83 c4 10             	add    $0x10,%esp
f01011ed:	39 c3                	cmp    %eax,%ebx
f01011ef:	74 19                	je     f010120a <page_check+0x24b>
f01011f1:	68 f8 50 10 f0       	push   $0xf01050f8
f01011f6:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01011fb:	68 b3 00 00 00       	push   $0xb3
f0101200:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101205:	e8 24 ef ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f010120a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010120d:	8b 40 08             	mov    0x8(%eax),%eax
f0101210:	66 83 f8 01          	cmp    $0x1,%ax
f0101214:	74 19                	je     f010122f <page_check+0x270>
f0101216:	68 39 51 10 f0       	push   $0xf0105139
f010121b:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101220:	68 b4 00 00 00       	push   $0xb4
f0101225:	68 f9 4d 10 f0       	push   $0xf0104df9
f010122a:	e8 ff ee ff ff       	call   f010012e <_panic>
	assert(pp0->references == 1);
f010122f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101232:	8b 40 08             	mov    0x8(%eax),%eax
f0101235:	66 83 f8 01          	cmp    $0x1,%ax
f0101239:	74 19                	je     f0101254 <page_check+0x295>
f010123b:	68 4e 51 10 f0       	push   $0xf010514e
f0101240:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101245:	68 b5 00 00 00       	push   $0xb5
f010124a:	68 f9 4d 10 f0       	push   $0xf0104df9
f010124f:	e8 da ee ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because pp0 is already allocated for page table
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101254:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101257:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010125c:	6a 00                	push   $0x0
f010125e:	68 00 10 00 00       	push   $0x1000
f0101263:	52                   	push   %edx
f0101264:	50                   	push   %eax
f0101265:	e8 6f 10 00 00       	call   f01022d9 <map_frame>
f010126a:	83 c4 10             	add    $0x10,%esp
f010126d:	85 c0                	test   %eax,%eax
f010126f:	74 19                	je     f010128a <page_check+0x2cb>
f0101271:	68 64 51 10 f0       	push   $0xf0105164
f0101276:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010127b:	68 b8 00 00 00       	push   $0xb8
f0101280:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101285:	e8 a4 ee ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f010128a:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010128f:	83 ec 08             	sub    $0x8,%esp
f0101292:	68 00 10 00 00       	push   $0x1000
f0101297:	50                   	push   %eax
f0101298:	e8 5c fc ff ff       	call   f0100ef9 <check_va2pa>
f010129d:	83 c4 10             	add    $0x10,%esp
f01012a0:	89 c3                	mov    %eax,%ebx
f01012a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01012a5:	83 ec 0c             	sub    $0xc,%esp
f01012a8:	50                   	push   %eax
f01012a9:	e8 00 f9 ff ff       	call   f0100bae <to_physical_address>
f01012ae:	83 c4 10             	add    $0x10,%esp
f01012b1:	39 c3                	cmp    %eax,%ebx
f01012b3:	74 19                	je     f01012ce <page_check+0x30f>
f01012b5:	68 a4 51 10 f0       	push   $0xf01051a4
f01012ba:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01012bf:	68 b9 00 00 00       	push   $0xb9
f01012c4:	68 f9 4d 10 f0       	push   $0xf0104df9
f01012c9:	e8 60 ee ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f01012ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01012d1:	8b 40 08             	mov    0x8(%eax),%eax
f01012d4:	66 83 f8 01          	cmp    $0x1,%ax
f01012d8:	74 19                	je     f01012f3 <page_check+0x334>
f01012da:	68 eb 51 10 f0       	push   $0xf01051eb
f01012df:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01012e4:	68 ba 00 00 00       	push   $0xba
f01012e9:	68 f9 4d 10 f0       	push   $0xf0104df9
f01012ee:	e8 3b ee ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f01012f3:	83 ec 0c             	sub    $0xc,%esp
f01012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01012f9:	50                   	push   %eax
f01012fa:	e8 cd 0d 00 00       	call   f01020cc <allocate_frame>
f01012ff:	83 c4 10             	add    $0x10,%esp
f0101302:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101305:	74 19                	je     f0101320 <page_check+0x361>
f0101307:	68 34 50 10 f0       	push   $0xf0105034
f010130c:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101311:	68 bd 00 00 00       	push   $0xbd
f0101316:	68 f9 4d 10 f0       	push   $0xf0104df9
f010131b:	e8 0e ee ff ff       	call   f010012e <_panic>

	// should be able to map pp2 at PAGE_SIZE because it's already there
	assert(map_frame(ptr_page_directory, pp2, (void*) PAGE_SIZE, 0) == 0);
f0101320:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101323:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101328:	6a 00                	push   $0x0
f010132a:	68 00 10 00 00       	push   $0x1000
f010132f:	52                   	push   %edx
f0101330:	50                   	push   %eax
f0101331:	e8 a3 0f 00 00       	call   f01022d9 <map_frame>
f0101336:	83 c4 10             	add    $0x10,%esp
f0101339:	85 c0                	test   %eax,%eax
f010133b:	74 19                	je     f0101356 <page_check+0x397>
f010133d:	68 64 51 10 f0       	push   $0xf0105164
f0101342:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101347:	68 c0 00 00 00       	push   $0xc0
f010134c:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101351:	e8 d8 ed ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp2));
f0101356:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010135b:	83 ec 08             	sub    $0x8,%esp
f010135e:	68 00 10 00 00       	push   $0x1000
f0101363:	50                   	push   %eax
f0101364:	e8 90 fb ff ff       	call   f0100ef9 <check_va2pa>
f0101369:	83 c4 10             	add    $0x10,%esp
f010136c:	89 c3                	mov    %eax,%ebx
f010136e:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101371:	83 ec 0c             	sub    $0xc,%esp
f0101374:	50                   	push   %eax
f0101375:	e8 34 f8 ff ff       	call   f0100bae <to_physical_address>
f010137a:	83 c4 10             	add    $0x10,%esp
f010137d:	39 c3                	cmp    %eax,%ebx
f010137f:	74 19                	je     f010139a <page_check+0x3db>
f0101381:	68 a4 51 10 f0       	push   $0xf01051a4
f0101386:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010138b:	68 c1 00 00 00       	push   $0xc1
f0101390:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101395:	e8 94 ed ff ff       	call   f010012e <_panic>
	assert(pp2->references == 1);
f010139a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010139d:	8b 40 08             	mov    0x8(%eax),%eax
f01013a0:	66 83 f8 01          	cmp    $0x1,%ax
f01013a4:	74 19                	je     f01013bf <page_check+0x400>
f01013a6:	68 eb 51 10 f0       	push   $0xf01051eb
f01013ab:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01013b0:	68 c2 00 00 00       	push   $0xc2
f01013b5:	68 f9 4d 10 f0       	push   $0xf0104df9
f01013ba:	e8 6f ed ff ff       	call   f010012e <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in map_frame
	assert(allocate_frame(&pp) == E_NO_MEM);
f01013bf:	83 ec 0c             	sub    $0xc,%esp
f01013c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01013c5:	50                   	push   %eax
f01013c6:	e8 01 0d 00 00       	call   f01020cc <allocate_frame>
f01013cb:	83 c4 10             	add    $0x10,%esp
f01013ce:	83 f8 fc             	cmp    $0xfffffffc,%eax
f01013d1:	74 19                	je     f01013ec <page_check+0x42d>
f01013d3:	68 34 50 10 f0       	push   $0xf0105034
f01013d8:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01013dd:	68 c6 00 00 00       	push   $0xc6
f01013e2:	68 f9 4d 10 f0       	push   $0xf0104df9
f01013e7:	e8 42 ed ff ff       	call   f010012e <_panic>

	// should not be able to map at PTSIZE because need free frame for page table
	assert(map_frame(ptr_page_directory, pp0, (void*) PTSIZE, 0) < 0);
f01013ec:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01013ef:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f01013f4:	6a 00                	push   $0x0
f01013f6:	68 00 00 40 00       	push   $0x400000
f01013fb:	52                   	push   %edx
f01013fc:	50                   	push   %eax
f01013fd:	e8 d7 0e 00 00       	call   f01022d9 <map_frame>
f0101402:	83 c4 10             	add    $0x10,%esp
f0101405:	85 c0                	test   %eax,%eax
f0101407:	78 19                	js     f0101422 <page_check+0x463>
f0101409:	68 00 52 10 f0       	push   $0xf0105200
f010140e:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101413:	68 c9 00 00 00       	push   $0xc9
f0101418:	68 f9 4d 10 f0       	push   $0xf0104df9
f010141d:	e8 0c ed ff ff       	call   f010012e <_panic>

	// insert pp1 at PAGE_SIZE (replacing pp2)
	assert(map_frame(ptr_page_directory, pp1, (void*) PAGE_SIZE, 0) == 0);
f0101422:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101425:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010142a:	6a 00                	push   $0x0
f010142c:	68 00 10 00 00       	push   $0x1000
f0101431:	52                   	push   %edx
f0101432:	50                   	push   %eax
f0101433:	e8 a1 0e 00 00       	call   f01022d9 <map_frame>
f0101438:	83 c4 10             	add    $0x10,%esp
f010143b:	85 c0                	test   %eax,%eax
f010143d:	74 19                	je     f0101458 <page_check+0x499>
f010143f:	68 3c 52 10 f0       	push   $0xf010523c
f0101444:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101449:	68 cc 00 00 00       	push   $0xcc
f010144e:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101453:	e8 d6 ec ff ff       	call   f010012e <_panic>

	// should have pp1 at both 0 and PAGE_SIZE, pp2 nowhere, ...
	assert(check_va2pa(ptr_page_directory, 0) == to_physical_address(pp1));
f0101458:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010145d:	83 ec 08             	sub    $0x8,%esp
f0101460:	6a 00                	push   $0x0
f0101462:	50                   	push   %eax
f0101463:	e8 91 fa ff ff       	call   f0100ef9 <check_va2pa>
f0101468:	83 c4 10             	add    $0x10,%esp
f010146b:	89 c3                	mov    %eax,%ebx
f010146d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101470:	83 ec 0c             	sub    $0xc,%esp
f0101473:	50                   	push   %eax
f0101474:	e8 35 f7 ff ff       	call   f0100bae <to_physical_address>
f0101479:	83 c4 10             	add    $0x10,%esp
f010147c:	39 c3                	cmp    %eax,%ebx
f010147e:	74 19                	je     f0101499 <page_check+0x4da>
f0101480:	68 7c 52 10 f0       	push   $0xf010527c
f0101485:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010148a:	68 cf 00 00 00       	push   $0xcf
f010148f:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101494:	e8 95 ec ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f0101499:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010149e:	83 ec 08             	sub    $0x8,%esp
f01014a1:	68 00 10 00 00       	push   $0x1000
f01014a6:	50                   	push   %eax
f01014a7:	e8 4d fa ff ff       	call   f0100ef9 <check_va2pa>
f01014ac:	83 c4 10             	add    $0x10,%esp
f01014af:	89 c3                	mov    %eax,%ebx
f01014b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014b4:	83 ec 0c             	sub    $0xc,%esp
f01014b7:	50                   	push   %eax
f01014b8:	e8 f1 f6 ff ff       	call   f0100bae <to_physical_address>
f01014bd:	83 c4 10             	add    $0x10,%esp
f01014c0:	39 c3                	cmp    %eax,%ebx
f01014c2:	74 19                	je     f01014dd <page_check+0x51e>
f01014c4:	68 bc 52 10 f0       	push   $0xf01052bc
f01014c9:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01014ce:	68 d0 00 00 00       	push   $0xd0
f01014d3:	68 f9 4d 10 f0       	push   $0xf0104df9
f01014d8:	e8 51 ec ff ff       	call   f010012e <_panic>
	// ... and ref counts should reflect this
	assert(pp1->references == 2);
f01014dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01014e0:	8b 40 08             	mov    0x8(%eax),%eax
f01014e3:	66 83 f8 02          	cmp    $0x2,%ax
f01014e7:	74 19                	je     f0101502 <page_check+0x543>
f01014e9:	68 03 53 10 f0       	push   $0xf0105303
f01014ee:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01014f3:	68 d2 00 00 00       	push   $0xd2
f01014f8:	68 f9 4d 10 f0       	push   $0xf0104df9
f01014fd:	e8 2c ec ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f0101502:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101505:	8b 40 08             	mov    0x8(%eax),%eax
f0101508:	66 85 c0             	test   %ax,%ax
f010150b:	74 19                	je     f0101526 <page_check+0x567>
f010150d:	68 18 53 10 f0       	push   $0xf0105318
f0101512:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101517:	68 d3 00 00 00       	push   $0xd3
f010151c:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101521:	e8 08 ec ff ff       	call   f010012e <_panic>

	// pp2 should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp2);
f0101526:	83 ec 0c             	sub    $0xc,%esp
f0101529:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010152c:	50                   	push   %eax
f010152d:	e8 9a 0b 00 00       	call   f01020cc <allocate_frame>
f0101532:	83 c4 10             	add    $0x10,%esp
f0101535:	85 c0                	test   %eax,%eax
f0101537:	75 0a                	jne    f0101543 <page_check+0x584>
f0101539:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010153c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010153f:	39 c2                	cmp    %eax,%edx
f0101541:	74 19                	je     f010155c <page_check+0x59d>
f0101543:	68 30 53 10 f0       	push   $0xf0105330
f0101548:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010154d:	68 d6 00 00 00       	push   $0xd6
f0101552:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101557:	e8 d2 eb ff ff       	call   f010012e <_panic>

	// unmapping pp1 at 0 should keep pp1 at PAGE_SIZE
	unmap_frame(ptr_page_directory, 0x0);
f010155c:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101561:	83 ec 08             	sub    $0x8,%esp
f0101564:	6a 00                	push   $0x0
f0101566:	50                   	push   %eax
f0101567:	e8 80 0e 00 00       	call   f01023ec <unmap_frame>
f010156c:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f010156f:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101574:	83 ec 08             	sub    $0x8,%esp
f0101577:	6a 00                	push   $0x0
f0101579:	50                   	push   %eax
f010157a:	e8 7a f9 ff ff       	call   f0100ef9 <check_va2pa>
f010157f:	83 c4 10             	add    $0x10,%esp
f0101582:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101585:	74 19                	je     f01015a0 <page_check+0x5e1>
f0101587:	68 58 53 10 f0       	push   $0xf0105358
f010158c:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101591:	68 da 00 00 00       	push   $0xda
f0101596:	68 f9 4d 10 f0       	push   $0xf0104df9
f010159b:	e8 8e eb ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == to_physical_address(pp1));
f01015a0:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f01015a5:	83 ec 08             	sub    $0x8,%esp
f01015a8:	68 00 10 00 00       	push   $0x1000
f01015ad:	50                   	push   %eax
f01015ae:	e8 46 f9 ff ff       	call   f0100ef9 <check_va2pa>
f01015b3:	83 c4 10             	add    $0x10,%esp
f01015b6:	89 c3                	mov    %eax,%ebx
f01015b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01015bb:	83 ec 0c             	sub    $0xc,%esp
f01015be:	50                   	push   %eax
f01015bf:	e8 ea f5 ff ff       	call   f0100bae <to_physical_address>
f01015c4:	83 c4 10             	add    $0x10,%esp
f01015c7:	39 c3                	cmp    %eax,%ebx
f01015c9:	74 19                	je     f01015e4 <page_check+0x625>
f01015cb:	68 bc 52 10 f0       	push   $0xf01052bc
f01015d0:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01015d5:	68 db 00 00 00       	push   $0xdb
f01015da:	68 f9 4d 10 f0       	push   $0xf0104df9
f01015df:	e8 4a eb ff ff       	call   f010012e <_panic>
	assert(pp1->references == 1);
f01015e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01015e7:	8b 40 08             	mov    0x8(%eax),%eax
f01015ea:	66 83 f8 01          	cmp    $0x1,%ax
f01015ee:	74 19                	je     f0101609 <page_check+0x64a>
f01015f0:	68 39 51 10 f0       	push   $0xf0105139
f01015f5:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01015fa:	68 dc 00 00 00       	push   $0xdc
f01015ff:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101604:	e8 25 eb ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f0101609:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010160c:	8b 40 08             	mov    0x8(%eax),%eax
f010160f:	66 85 c0             	test   %ax,%ax
f0101612:	74 19                	je     f010162d <page_check+0x66e>
f0101614:	68 18 53 10 f0       	push   $0xf0105318
f0101619:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010161e:	68 dd 00 00 00       	push   $0xdd
f0101623:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101628:	e8 01 eb ff ff       	call   f010012e <_panic>

	// unmapping pp1 at PAGE_SIZE should free it
	unmap_frame(ptr_page_directory, (void*) PAGE_SIZE);
f010162d:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101632:	83 ec 08             	sub    $0x8,%esp
f0101635:	68 00 10 00 00       	push   $0x1000
f010163a:	50                   	push   %eax
f010163b:	e8 ac 0d 00 00       	call   f01023ec <unmap_frame>
f0101640:	83 c4 10             	add    $0x10,%esp
	assert(check_va2pa(ptr_page_directory, 0x0) == ~0);
f0101643:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101648:	83 ec 08             	sub    $0x8,%esp
f010164b:	6a 00                	push   $0x0
f010164d:	50                   	push   %eax
f010164e:	e8 a6 f8 ff ff       	call   f0100ef9 <check_va2pa>
f0101653:	83 c4 10             	add    $0x10,%esp
f0101656:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101659:	74 19                	je     f0101674 <page_check+0x6b5>
f010165b:	68 58 53 10 f0       	push   $0xf0105358
f0101660:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101665:	68 e1 00 00 00       	push   $0xe1
f010166a:	68 f9 4d 10 f0       	push   $0xf0104df9
f010166f:	e8 ba ea ff ff       	call   f010012e <_panic>
	assert(check_va2pa(ptr_page_directory, PAGE_SIZE) == ~0);
f0101674:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101679:	83 ec 08             	sub    $0x8,%esp
f010167c:	68 00 10 00 00       	push   $0x1000
f0101681:	50                   	push   %eax
f0101682:	e8 72 f8 ff ff       	call   f0100ef9 <check_va2pa>
f0101687:	83 c4 10             	add    $0x10,%esp
f010168a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010168d:	74 19                	je     f01016a8 <page_check+0x6e9>
f010168f:	68 84 53 10 f0       	push   $0xf0105384
f0101694:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101699:	68 e2 00 00 00       	push   $0xe2
f010169e:	68 f9 4d 10 f0       	push   $0xf0104df9
f01016a3:	e8 86 ea ff ff       	call   f010012e <_panic>
	assert(pp1->references == 0);
f01016a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01016ab:	8b 40 08             	mov    0x8(%eax),%eax
f01016ae:	66 85 c0             	test   %ax,%ax
f01016b1:	74 19                	je     f01016cc <page_check+0x70d>
f01016b3:	68 b5 53 10 f0       	push   $0xf01053b5
f01016b8:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01016bd:	68 e3 00 00 00       	push   $0xe3
f01016c2:	68 f9 4d 10 f0       	push   $0xf0104df9
f01016c7:	e8 62 ea ff ff       	call   f010012e <_panic>
	assert(pp2->references == 0);
f01016cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01016cf:	8b 40 08             	mov    0x8(%eax),%eax
f01016d2:	66 85 c0             	test   %ax,%ax
f01016d5:	74 19                	je     f01016f0 <page_check+0x731>
f01016d7:	68 18 53 10 f0       	push   $0xf0105318
f01016dc:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01016e1:	68 e4 00 00 00       	push   $0xe4
f01016e6:	68 f9 4d 10 f0       	push   $0xf0104df9
f01016eb:	e8 3e ea ff ff       	call   f010012e <_panic>

	// so it should be returned by allocate_frame
	assert(allocate_frame(&pp) == 0 && pp == pp1);
f01016f0:	83 ec 0c             	sub    $0xc,%esp
f01016f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016f6:	50                   	push   %eax
f01016f7:	e8 d0 09 00 00       	call   f01020cc <allocate_frame>
f01016fc:	83 c4 10             	add    $0x10,%esp
f01016ff:	85 c0                	test   %eax,%eax
f0101701:	75 0a                	jne    f010170d <page_check+0x74e>
f0101703:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101706:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101709:	39 c2                	cmp    %eax,%edx
f010170b:	74 19                	je     f0101726 <page_check+0x767>
f010170d:	68 cc 53 10 f0       	push   $0xf01053cc
f0101712:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101717:	68 e7 00 00 00       	push   $0xe7
f010171c:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101721:	e8 08 ea ff ff       	call   f010012e <_panic>

	// should be no free memory
	assert(allocate_frame(&pp) == E_NO_MEM);
f0101726:	83 ec 0c             	sub    $0xc,%esp
f0101729:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010172c:	50                   	push   %eax
f010172d:	e8 9a 09 00 00       	call   f01020cc <allocate_frame>
f0101732:	83 c4 10             	add    $0x10,%esp
f0101735:	83 f8 fc             	cmp    $0xfffffffc,%eax
f0101738:	74 19                	je     f0101753 <page_check+0x794>
f010173a:	68 34 50 10 f0       	push   $0xf0105034
f010173f:	68 6a 4e 10 f0       	push   $0xf0104e6a
f0101744:	68 ea 00 00 00       	push   $0xea
f0101749:	68 f9 4d 10 f0       	push   $0xf0104df9
f010174e:	e8 db e9 ff ff       	call   f010012e <_panic>

	// forcibly take pp0 back
	assert(EXTRACT_ADDRESS(ptr_page_directory[0]) == to_physical_address(pp0));
f0101753:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101758:	8b 00                	mov    (%eax),%eax
f010175a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010175f:	89 c3                	mov    %eax,%ebx
f0101761:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101764:	83 ec 0c             	sub    $0xc,%esp
f0101767:	50                   	push   %eax
f0101768:	e8 41 f4 ff ff       	call   f0100bae <to_physical_address>
f010176d:	83 c4 10             	add    $0x10,%esp
f0101770:	39 c3                	cmp    %eax,%ebx
f0101772:	74 19                	je     f010178d <page_check+0x7ce>
f0101774:	68 b4 50 10 f0       	push   $0xf01050b4
f0101779:	68 6a 4e 10 f0       	push   $0xf0104e6a
f010177e:	68 ed 00 00 00       	push   $0xed
f0101783:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101788:	e8 a1 e9 ff ff       	call   f010012e <_panic>
	ptr_page_directory[0] = 0;
f010178d:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101792:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->references == 1);
f0101798:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010179b:	8b 40 08             	mov    0x8(%eax),%eax
f010179e:	66 83 f8 01          	cmp    $0x1,%ax
f01017a2:	74 19                	je     f01017bd <page_check+0x7fe>
f01017a4:	68 4e 51 10 f0       	push   $0xf010514e
f01017a9:	68 6a 4e 10 f0       	push   $0xf0104e6a
f01017ae:	68 ef 00 00 00       	push   $0xef
f01017b3:	68 f9 4d 10 f0       	push   $0xf0104df9
f01017b8:	e8 71 e9 ff ff       	call   f010012e <_panic>
	pp0->references = 0;
f01017bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017c0:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)

	// give free list back
	free_frame_list = fl;
f01017c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017c9:	a3 d8 d6 14 f0       	mov    %eax,0xf014d6d8

	// free the frames_info we took
	free_frame(pp0);
f01017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01017d1:	83 ec 0c             	sub    $0xc,%esp
f01017d4:	50                   	push   %eax
f01017d5:	e8 59 09 00 00       	call   f0102133 <free_frame>
f01017da:	83 c4 10             	add    $0x10,%esp
	free_frame(pp1);
f01017dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01017e0:	83 ec 0c             	sub    $0xc,%esp
f01017e3:	50                   	push   %eax
f01017e4:	e8 4a 09 00 00       	call   f0102133 <free_frame>
f01017e9:	83 c4 10             	add    $0x10,%esp
	free_frame(pp2);
f01017ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01017ef:	83 ec 0c             	sub    $0xc,%esp
f01017f2:	50                   	push   %eax
f01017f3:	e8 3b 09 00 00       	call   f0102133 <free_frame>
f01017f8:	83 c4 10             	add    $0x10,%esp

	cprintf("page_check() succeeded!\n");
f01017fb:	83 ec 0c             	sub    $0xc,%esp
f01017fe:	68 f2 53 10 f0       	push   $0xf01053f2
f0101803:	e8 39 15 00 00       	call   f0102d41 <cprintf>
f0101808:	83 c4 10             	add    $0x10,%esp
}
f010180b:	90                   	nop
f010180c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010180f:	c9                   	leave  
f0101810:	c3                   	ret    

f0101811 <turn_on_paging>:

void turn_on_paging()
{
f0101811:	55                   	push   %ebp
f0101812:	89 e5                	mov    %esp,%ebp
f0101814:	83 ec 20             	sub    $0x20,%esp
	// mapping, even though we are turning on paging and reconfiguring
	// segmentation.

	// Map VA 0:4MB same as VA (KERNEL_BASE), i.e. to PA 0:4MB.
	// (Limits our kernel to <4MB)
	ptr_page_directory[0] = ptr_page_directory[PDX(KERNEL_BASE)];
f0101817:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010181c:	8b 15 e4 d6 14 f0    	mov    0xf014d6e4,%edx
f0101822:	8b 92 00 0f 00 00    	mov    0xf00(%edx),%edx
f0101828:	89 10                	mov    %edx,(%eax)

	// Install page table.
	lcr3(phys_page_directory);
f010182a:	a1 e8 d6 14 f0       	mov    0xf014d6e8,%eax
f010182f:	89 45 fc             	mov    %eax,-0x4(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101832:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101835:	0f 22 d8             	mov    %eax,%cr3

static __inline uint32
rcr0(void)
{
	uint32 val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101838:	0f 20 c0             	mov    %cr0,%eax
f010183b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	return val;
f010183e:	8b 45 f4             	mov    -0xc(%ebp),%eax

	// Turn on paging.
	uint32 cr0;
	cr0 = rcr0();
f0101841:	89 45 f8             	mov    %eax,-0x8(%ebp)
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_TS|CR0_EM|CR0_MP;
f0101844:	81 4d f8 2f 00 05 80 	orl    $0x8005002f,-0x8(%ebp)
	cr0 &= ~(CR0_TS|CR0_EM);
f010184b:	83 65 f8 f3          	andl   $0xfffffff3,-0x8(%ebp)
f010184f:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101852:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
lcr0(uint32 val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101855:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101858:	0f 22 c0             	mov    %eax,%cr0

	// Current mapping: KERNEL_BASE+x => x => x.
	// (x < 4MB so uses paging ptr_page_directory[0])

	// Reload all segment registers.
	asm volatile("lgdt gdt_pd");
f010185b:	0f 01 15 90 a5 11 f0 	lgdtl  0xf011a590
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0101862:	b8 23 00 00 00       	mov    $0x23,%eax
f0101867:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0101869:	b8 23 00 00 00       	mov    $0x23,%eax
f010186e:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0101870:	b8 10 00 00 00       	mov    $0x10,%eax
f0101875:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0101877:	b8 10 00 00 00       	mov    $0x10,%eax
f010187c:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010187e:	b8 10 00 00 00       	mov    $0x10,%eax
f0101883:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));  // reload cs
f0101885:	ea 8c 18 10 f0 08 00 	ljmp   $0x8,$0xf010188c
	asm volatile("lldt %%ax" :: "a" (0));
f010188c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101891:	0f 00 d0             	lldt   %ax

	// Final mapping: KERNEL_BASE + x => KERNEL_BASE + x => x.

	// This mapping was only used after paging was turned on but
	// before the segment registers were reloaded.
	ptr_page_directory[0] = 0;
f0101894:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101899:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// Flush the TLB for good measure, to kill the ptr_page_directory[0] mapping.
	lcr3(phys_page_directory);
f010189f:	a1 e8 d6 14 f0       	mov    0xf014d6e8,%eax
f01018a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static __inline void
lcr3(uint32 val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01018a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01018aa:	0f 22 d8             	mov    %eax,%cr3
}
f01018ad:	90                   	nop
f01018ae:	c9                   	leave  
f01018af:	c3                   	ret    

f01018b0 <setup_listing_to_all_page_tables_entries>:

void setup_listing_to_all_page_tables_entries()
{
f01018b0:	55                   	push   %ebp
f01018b1:	89 e5                	mov    %esp,%ebp
f01018b3:	83 ec 18             	sub    $0x18,%esp
	//////////////////////////////////////////////////////////////////////
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address VPT.

	// Permissions: kernel RW, user NONE
	uint32 phys_frame_address = K_PHYSICAL_ADDRESS(ptr_page_directory);
f01018b6:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f01018bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01018be:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f01018c5:	77 17                	ja     f01018de <setup_listing_to_all_page_tables_entries+0x2e>
f01018c7:	ff 75 f4             	pushl  -0xc(%ebp)
f01018ca:	68 c8 4d 10 f0       	push   $0xf0104dc8
f01018cf:	68 39 01 00 00       	push   $0x139
f01018d4:	68 f9 4d 10 f0       	push   $0xf0104df9
f01018d9:	e8 50 e8 ff ff       	call   f010012e <_panic>
f01018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01018e1:	05 00 00 00 10       	add    $0x10000000,%eax
f01018e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
	ptr_page_directory[PDX(VPT)] = CONSTRUCT_ENTRY(phys_frame_address , PERM_PRESENT | PERM_WRITEABLE);
f01018e9:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f01018ee:	05 fc 0e 00 00       	add    $0xefc,%eax
f01018f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01018f6:	83 ca 03             	or     $0x3,%edx
f01018f9:	89 10                	mov    %edx,(%eax)

	// same for UVPT
	//Permissions: kernel R, user R
	ptr_page_directory[PDX(UVPT)] = K_PHYSICAL_ADDRESS(ptr_page_directory)|PERM_USER|PERM_PRESENT;
f01018fb:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101900:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0101906:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f010190b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010190e:	81 7d ec ff ff ff ef 	cmpl   $0xefffffff,-0x14(%ebp)
f0101915:	77 17                	ja     f010192e <setup_listing_to_all_page_tables_entries+0x7e>
f0101917:	ff 75 ec             	pushl  -0x14(%ebp)
f010191a:	68 c8 4d 10 f0       	push   $0xf0104dc8
f010191f:	68 3e 01 00 00       	push   $0x13e
f0101924:	68 f9 4d 10 f0       	push   $0xf0104df9
f0101929:	e8 00 e8 ff ff       	call   f010012e <_panic>
f010192e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101931:	05 00 00 00 10       	add    $0x10000000,%eax
f0101936:	83 c8 05             	or     $0x5,%eax
f0101939:	89 02                	mov    %eax,(%edx)

}
f010193b:	90                   	nop
f010193c:	c9                   	leave  
f010193d:	c3                   	ret    

f010193e <envid2env>:
//   0 on success, -E_BAD_ENV on error.
//   On success, sets *penv to the environment.
//   On error, sets *penv to NULL.
//
int envid2env(int32  envid, struct Env **env_store, bool checkperm)
{
f010193e:	55                   	push   %ebp
f010193f:	89 e5                	mov    %esp,%ebp
f0101941:	83 ec 10             	sub    $0x10,%esp
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0101944:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0101948:	75 15                	jne    f010195f <envid2env+0x21>
		*env_store = curenv;
f010194a:	8b 15 50 ce 14 f0    	mov    0xf014ce50,%edx
f0101950:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101953:	89 10                	mov    %edx,(%eax)
		return 0;
f0101955:	b8 00 00 00 00       	mov    $0x0,%eax
f010195a:	e9 8c 00 00 00       	jmp    f01019eb <envid2env+0xad>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010195f:	8b 15 4c ce 14 f0    	mov    0xf014ce4c,%edx
f0101965:	8b 45 08             	mov    0x8(%ebp),%eax
f0101968:	25 ff 03 00 00       	and    $0x3ff,%eax
f010196d:	89 c1                	mov    %eax,%ecx
f010196f:	89 c8                	mov    %ecx,%eax
f0101971:	c1 e0 02             	shl    $0x2,%eax
f0101974:	01 c8                	add    %ecx,%eax
f0101976:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f010197d:	01 c8                	add    %ecx,%eax
f010197f:	c1 e0 02             	shl    $0x2,%eax
f0101982:	01 d0                	add    %edx,%eax
f0101984:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0101987:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010198a:	8b 40 54             	mov    0x54(%eax),%eax
f010198d:	85 c0                	test   %eax,%eax
f010198f:	74 0b                	je     f010199c <envid2env+0x5e>
f0101991:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101994:	8b 40 4c             	mov    0x4c(%eax),%eax
f0101997:	3b 45 08             	cmp    0x8(%ebp),%eax
f010199a:	74 10                	je     f01019ac <envid2env+0x6e>
		*env_store = 0;
f010199c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010199f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01019a5:	b8 02 00 00 00       	mov    $0x2,%eax
f01019aa:	eb 3f                	jmp    f01019eb <envid2env+0xad>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01019ac:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01019b0:	74 2c                	je     f01019de <envid2env+0xa0>
f01019b2:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01019b7:	39 45 fc             	cmp    %eax,-0x4(%ebp)
f01019ba:	74 22                	je     f01019de <envid2env+0xa0>
f01019bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01019bf:	8b 50 50             	mov    0x50(%eax),%edx
f01019c2:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01019c7:	8b 40 4c             	mov    0x4c(%eax),%eax
f01019ca:	39 c2                	cmp    %eax,%edx
f01019cc:	74 10                	je     f01019de <envid2env+0xa0>
		*env_store = 0;
f01019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01019d7:	b8 02 00 00 00       	mov    $0x2,%eax
f01019dc:	eb 0d                	jmp    f01019eb <envid2env+0xad>
	}

	*env_store = e;
f01019de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01019e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01019e4:	89 10                	mov    %edx,(%eax)
	return 0;
f01019e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01019eb:	c9                   	leave  
f01019ec:	c3                   	ret    

f01019ed <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f01019ed:	55                   	push   %ebp
f01019ee:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f01019f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01019f3:	8b 15 dc d6 14 f0    	mov    0xf014d6dc,%edx
f01019f9:	29 d0                	sub    %edx,%eax
f01019fb:	c1 f8 02             	sar    $0x2,%eax
f01019fe:	89 c2                	mov    %eax,%edx
f0101a00:	89 d0                	mov    %edx,%eax
f0101a02:	c1 e0 02             	shl    $0x2,%eax
f0101a05:	01 d0                	add    %edx,%eax
f0101a07:	c1 e0 02             	shl    $0x2,%eax
f0101a0a:	01 d0                	add    %edx,%eax
f0101a0c:	c1 e0 02             	shl    $0x2,%eax
f0101a0f:	01 d0                	add    %edx,%eax
f0101a11:	89 c1                	mov    %eax,%ecx
f0101a13:	c1 e1 08             	shl    $0x8,%ecx
f0101a16:	01 c8                	add    %ecx,%eax
f0101a18:	89 c1                	mov    %eax,%ecx
f0101a1a:	c1 e1 10             	shl    $0x10,%ecx
f0101a1d:	01 c8                	add    %ecx,%eax
f0101a1f:	01 c0                	add    %eax,%eax
f0101a21:	01 d0                	add    %edx,%eax
}
f0101a23:	5d                   	pop    %ebp
f0101a24:	c3                   	ret    

f0101a25 <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f0101a25:	55                   	push   %ebp
f0101a26:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f0101a28:	ff 75 08             	pushl  0x8(%ebp)
f0101a2b:	e8 bd ff ff ff       	call   f01019ed <to_frame_number>
f0101a30:	83 c4 04             	add    $0x4,%esp
f0101a33:	c1 e0 0c             	shl    $0xc,%eax
}
f0101a36:	c9                   	leave  
f0101a37:	c3                   	ret    

f0101a38 <to_frame_info>:

static inline struct Frame_Info* to_frame_info(uint32 physical_address)
{
f0101a38:	55                   	push   %ebp
f0101a39:	89 e5                	mov    %esp,%ebp
f0101a3b:	83 ec 08             	sub    $0x8,%esp
	if (PPN(physical_address) >= number_of_frames)
f0101a3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a41:	c1 e8 0c             	shr    $0xc,%eax
f0101a44:	89 c2                	mov    %eax,%edx
f0101a46:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f0101a4b:	39 c2                	cmp    %eax,%edx
f0101a4d:	72 14                	jb     f0101a63 <to_frame_info+0x2b>
		panic("to_frame_info called with invalid pa");
f0101a4f:	83 ec 04             	sub    $0x4,%esp
f0101a52:	68 0c 54 10 f0       	push   $0xf010540c
f0101a57:	6a 39                	push   $0x39
f0101a59:	68 31 54 10 f0       	push   $0xf0105431
f0101a5e:	e8 cb e6 ff ff       	call   f010012e <_panic>
	return &frames_info[PPN(physical_address)];
f0101a63:	8b 15 dc d6 14 f0    	mov    0xf014d6dc,%edx
f0101a69:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a6c:	c1 e8 0c             	shr    $0xc,%eax
f0101a6f:	89 c1                	mov    %eax,%ecx
f0101a71:	89 c8                	mov    %ecx,%eax
f0101a73:	01 c0                	add    %eax,%eax
f0101a75:	01 c8                	add    %ecx,%eax
f0101a77:	c1 e0 02             	shl    $0x2,%eax
f0101a7a:	01 d0                	add    %edx,%eax
}
f0101a7c:	c9                   	leave  
f0101a7d:	c3                   	ret    

f0101a7e <initialize_kernel_VM>:
//
// From USER_TOP to USER_LIMIT, the user is allowed to read but not write.
// Above USER_LIMIT the user cannot read (or write).

void initialize_kernel_VM()
{
f0101a7e:	55                   	push   %ebp
f0101a7f:	89 e5                	mov    %esp,%ebp
f0101a81:	83 ec 28             	sub    $0x28,%esp
	//panic("initialize_kernel_VM: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.

	ptr_page_directory = boot_allocate_space(PAGE_SIZE, PAGE_SIZE);
f0101a84:	83 ec 08             	sub    $0x8,%esp
f0101a87:	68 00 10 00 00       	push   $0x1000
f0101a8c:	68 00 10 00 00       	push   $0x1000
f0101a91:	e8 ca 01 00 00       	call   f0101c60 <boot_allocate_space>
f0101a96:	83 c4 10             	add    $0x10,%esp
f0101a99:	a3 e4 d6 14 f0       	mov    %eax,0xf014d6e4
	memset(ptr_page_directory, 0, PAGE_SIZE);
f0101a9e:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101aa3:	83 ec 04             	sub    $0x4,%esp
f0101aa6:	68 00 10 00 00       	push   $0x1000
f0101aab:	6a 00                	push   $0x0
f0101aad:	50                   	push   %eax
f0101aae:	e8 70 29 00 00       	call   f0104423 <memset>
f0101ab3:	83 c4 10             	add    $0x10,%esp
	phys_page_directory = K_PHYSICAL_ADDRESS(ptr_page_directory);
f0101ab6:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101abe:	81 7d f4 ff ff ff ef 	cmpl   $0xefffffff,-0xc(%ebp)
f0101ac5:	77 14                	ja     f0101adb <initialize_kernel_VM+0x5d>
f0101ac7:	ff 75 f4             	pushl  -0xc(%ebp)
f0101aca:	68 4c 54 10 f0       	push   $0xf010544c
f0101acf:	6a 3c                	push   $0x3c
f0101ad1:	68 7d 54 10 f0       	push   $0xf010547d
f0101ad6:	e8 53 e6 ff ff       	call   f010012e <_panic>
f0101adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101ade:	05 00 00 00 10       	add    $0x10000000,%eax
f0101ae3:	a3 e8 d6 14 f0       	mov    %eax,0xf014d6e8
	// Map the kernel stack with VA range :
	//  [KERNEL_STACK_TOP-KERNEL_STACK_SIZE, KERNEL_STACK_TOP), 
	// to physical address : "phys_stack_bottom".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_range(ptr_page_directory, KERNEL_STACK_TOP - KERNEL_STACK_SIZE, KERNEL_STACK_SIZE, K_PHYSICAL_ADDRESS(ptr_stack_bottom), PERM_WRITEABLE) ;
f0101ae8:	c7 45 f0 00 20 11 f0 	movl   $0xf0112000,-0x10(%ebp)
f0101aef:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0101af6:	77 14                	ja     f0101b0c <initialize_kernel_VM+0x8e>
f0101af8:	ff 75 f0             	pushl  -0x10(%ebp)
f0101afb:	68 4c 54 10 f0       	push   $0xf010544c
f0101b00:	6a 44                	push   $0x44
f0101b02:	68 7d 54 10 f0       	push   $0xf010547d
f0101b07:	e8 22 e6 ff ff       	call   f010012e <_panic>
f0101b0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b0f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101b15:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101b1a:	83 ec 0c             	sub    $0xc,%esp
f0101b1d:	6a 02                	push   $0x2
f0101b1f:	52                   	push   %edx
f0101b20:	68 00 80 00 00       	push   $0x8000
f0101b25:	68 00 80 bf ef       	push   $0xefbf8000
f0101b2a:	50                   	push   %eax
f0101b2b:	e8 92 01 00 00       	call   f0101cc2 <boot_map_range>
f0101b30:	83 c4 20             	add    $0x20,%esp
	//      the PA range [0, 2^32 - KERNEL_BASE)
	// We might not have 2^32 - KERNEL_BASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here: 
	boot_map_range(ptr_page_directory, KERNEL_BASE, 0xFFFFFFFF - KERNEL_BASE, 0, PERM_WRITEABLE) ;
f0101b33:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101b38:	83 ec 0c             	sub    $0xc,%esp
f0101b3b:	6a 02                	push   $0x2
f0101b3d:	6a 00                	push   $0x0
f0101b3f:	68 ff ff ff 0f       	push   $0xfffffff
f0101b44:	68 00 00 00 f0       	push   $0xf0000000
f0101b49:	50                   	push   %eax
f0101b4a:	e8 73 01 00 00       	call   f0101cc2 <boot_map_range>
f0101b4f:	83 c4 20             	add    $0x20,%esp
	// Permissions:
	//    - frames_info -- kernel RW, user NONE
	//    - the image mapped at READ_ONLY_FRAMES_INFO  -- kernel R, user R
	// Your code goes here:
	uint32 array_size;
	array_size = number_of_frames * sizeof(struct Frame_Info) ;
f0101b52:	8b 15 c8 d6 14 f0    	mov    0xf014d6c8,%edx
f0101b58:	89 d0                	mov    %edx,%eax
f0101b5a:	01 c0                	add    %eax,%eax
f0101b5c:	01 d0                	add    %edx,%eax
f0101b5e:	c1 e0 02             	shl    $0x2,%eax
f0101b61:	89 45 ec             	mov    %eax,-0x14(%ebp)
	frames_info = boot_allocate_space(array_size, PAGE_SIZE);
f0101b64:	83 ec 08             	sub    $0x8,%esp
f0101b67:	68 00 10 00 00       	push   $0x1000
f0101b6c:	ff 75 ec             	pushl  -0x14(%ebp)
f0101b6f:	e8 ec 00 00 00       	call   f0101c60 <boot_allocate_space>
f0101b74:	83 c4 10             	add    $0x10,%esp
f0101b77:	a3 dc d6 14 f0       	mov    %eax,0xf014d6dc
	boot_map_range(ptr_page_directory, READ_ONLY_FRAMES_INFO, array_size, K_PHYSICAL_ADDRESS(frames_info), PERM_USER) ;
f0101b7c:	a1 dc d6 14 f0       	mov    0xf014d6dc,%eax
f0101b81:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101b84:	81 7d e8 ff ff ff ef 	cmpl   $0xefffffff,-0x18(%ebp)
f0101b8b:	77 14                	ja     f0101ba1 <initialize_kernel_VM+0x123>
f0101b8d:	ff 75 e8             	pushl  -0x18(%ebp)
f0101b90:	68 4c 54 10 f0       	push   $0xf010544c
f0101b95:	6a 5f                	push   $0x5f
f0101b97:	68 7d 54 10 f0       	push   $0xf010547d
f0101b9c:	e8 8d e5 ff ff       	call   f010012e <_panic>
f0101ba1:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101ba4:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101baa:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101baf:	83 ec 0c             	sub    $0xc,%esp
f0101bb2:	6a 04                	push   $0x4
f0101bb4:	52                   	push   %edx
f0101bb5:	ff 75 ec             	pushl  -0x14(%ebp)
f0101bb8:	68 00 00 00 ef       	push   $0xef000000
f0101bbd:	50                   	push   %eax
f0101bbe:	e8 ff 00 00 00       	call   f0101cc2 <boot_map_range>
f0101bc3:	83 c4 20             	add    $0x20,%esp


	// This allows the kernel & user to access any page table entry using a
	// specified VA for each: VPT for kernel and UVPT for User.
	setup_listing_to_all_page_tables_entries();
f0101bc6:	e8 e5 fc ff ff       	call   f01018b0 <setup_listing_to_all_page_tables_entries>
	// Permissions:
	//    - envs itself -- kernel RW, user NONE
	//    - the image of envs mapped at UENVS  -- kernel R, user R
	
	// LAB 3: Your code here.
	int envs_size = NENV * sizeof(struct Env) ;
f0101bcb:	c7 45 e4 00 90 01 00 	movl   $0x19000,-0x1c(%ebp)

	//allocate space for "envs" array aligned on 4KB boundary
	envs = boot_allocate_space(envs_size, PAGE_SIZE);
f0101bd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101bd5:	83 ec 08             	sub    $0x8,%esp
f0101bd8:	68 00 10 00 00       	push   $0x1000
f0101bdd:	50                   	push   %eax
f0101bde:	e8 7d 00 00 00       	call   f0101c60 <boot_allocate_space>
f0101be3:	83 c4 10             	add    $0x10,%esp
f0101be6:	a3 4c ce 14 f0       	mov    %eax,0xf014ce4c

	//make the user to access this array by mapping it to UPAGES linear address (UPAGES is in User/Kernel space)
	boot_map_range(ptr_page_directory, UENVS, envs_size, K_PHYSICAL_ADDRESS(envs), PERM_USER) ;
f0101beb:	a1 4c ce 14 f0       	mov    0xf014ce4c,%eax
f0101bf0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101bf3:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0101bfa:	77 14                	ja     f0101c10 <initialize_kernel_VM+0x192>
f0101bfc:	ff 75 e0             	pushl  -0x20(%ebp)
f0101bff:	68 4c 54 10 f0       	push   $0xf010544c
f0101c04:	6a 75                	push   $0x75
f0101c06:	68 7d 54 10 f0       	push   $0xf010547d
f0101c0b:	e8 1e e5 ff ff       	call   f010012e <_panic>
f0101c10:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101c13:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0101c19:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c1c:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101c21:	83 ec 0c             	sub    $0xc,%esp
f0101c24:	6a 04                	push   $0x4
f0101c26:	51                   	push   %ecx
f0101c27:	52                   	push   %edx
f0101c28:	68 00 00 c0 ee       	push   $0xeec00000
f0101c2d:	50                   	push   %eax
f0101c2e:	e8 8f 00 00 00       	call   f0101cc2 <boot_map_range>
f0101c33:	83 c4 20             	add    $0x20,%esp

	//update permissions of the corresponding entry in page directory to make it USER with PERMISSION read only
	ptr_page_directory[PDX(UENVS)] = ptr_page_directory[PDX(UENVS)]|(PERM_USER|(PERM_PRESENT & (~PERM_WRITEABLE)));
f0101c36:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0101c3b:	05 ec 0e 00 00       	add    $0xeec,%eax
f0101c40:	8b 15 e4 d6 14 f0    	mov    0xf014d6e4,%edx
f0101c46:	81 c2 ec 0e 00 00    	add    $0xeec,%edx
f0101c4c:	8b 12                	mov    (%edx),%edx
f0101c4e:	83 ca 05             	or     $0x5,%edx
f0101c51:	89 10                	mov    %edx,(%eax)


	// Check that the initial page directory has been set up correctly.
	check_boot_pgdir();
f0101c53:	e8 52 f0 ff ff       	call   f0100caa <check_boot_pgdir>
	
	// NOW: Turn off the segmentation by setting the segments' base to 0, and
	// turn on the paging by setting the corresponding flags in control register 0 (cr0)
	turn_on_paging() ;
f0101c58:	e8 b4 fb ff ff       	call   f0101811 <turn_on_paging>
}
f0101c5d:	90                   	nop
f0101c5e:	c9                   	leave  
f0101c5f:	c3                   	ret    

f0101c60 <boot_allocate_space>:
// It's too early to run out of memory.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
// 
void* boot_allocate_space(uint32 size, uint32 align)
{
f0101c60:	55                   	push   %ebp
f0101c61:	89 e5                	mov    %esp,%ebp
f0101c63:	83 ec 10             	sub    $0x10,%esp
	// Initialize ptr_free_mem if this is the first time.
	// 'end_of_kernel' is a symbol automatically generated by the linker,
	// which points to the end of the kernel-
	// i.e., the first virtual address that the linker
	// did not assign to any kernel code or global variables.
	if (ptr_free_mem == 0)
f0101c66:	a1 e0 d6 14 f0       	mov    0xf014d6e0,%eax
f0101c6b:	85 c0                	test   %eax,%eax
f0101c6d:	75 0a                	jne    f0101c79 <boot_allocate_space+0x19>
		ptr_free_mem = end_of_kernel;
f0101c6f:	c7 05 e0 d6 14 f0 ec 	movl   $0xf014d6ec,0xf014d6e0
f0101c76:	d6 14 f0 

	// Your code here:
	//	Step 1: round ptr_free_mem up to be aligned properly
	ptr_free_mem = ROUNDUP(ptr_free_mem, PAGE_SIZE) ;
f0101c79:	c7 45 fc 00 10 00 00 	movl   $0x1000,-0x4(%ebp)
f0101c80:	a1 e0 d6 14 f0       	mov    0xf014d6e0,%eax
f0101c85:	89 c2                	mov    %eax,%edx
f0101c87:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0101c8a:	01 d0                	add    %edx,%eax
f0101c8c:	48                   	dec    %eax
f0101c8d:	89 45 f8             	mov    %eax,-0x8(%ebp)
f0101c90:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101c93:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c98:	f7 75 fc             	divl   -0x4(%ebp)
f0101c9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0101c9e:	29 d0                	sub    %edx,%eax
f0101ca0:	a3 e0 d6 14 f0       	mov    %eax,0xf014d6e0
	
	//	Step 2: save current value of ptr_free_mem as allocated space
	void *ptr_allocated_mem;
	ptr_allocated_mem = ptr_free_mem ;
f0101ca5:	a1 e0 d6 14 f0       	mov    0xf014d6e0,%eax
f0101caa:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//	Step 3: increase ptr_free_mem to record allocation
	ptr_free_mem += size ;
f0101cad:	8b 15 e0 d6 14 f0    	mov    0xf014d6e0,%edx
f0101cb3:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cb6:	01 d0                	add    %edx,%eax
f0101cb8:	a3 e0 d6 14 f0       	mov    %eax,0xf014d6e0

	//	Step 4: return allocated space
	return ptr_allocated_mem ;
f0101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax

}
f0101cc0:	c9                   	leave  
f0101cc1:	c3                   	ret    

f0101cc2 <boot_map_range>:
//
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
f0101cc2:	55                   	push   %ebp
f0101cc3:	89 e5                	mov    %esp,%ebp
f0101cc5:	83 ec 28             	sub    $0x28,%esp
	int i = 0 ;
f0101cc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
f0101ccf:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0101cd6:	8b 55 14             	mov    0x14(%ebp),%edx
f0101cd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101cdc:	01 d0                	add    %edx,%eax
f0101cde:	48                   	dec    %eax
f0101cdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101ce2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101ce5:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cea:	f7 75 f0             	divl   -0x10(%ebp)
f0101ced:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101cf0:	29 d0                	sub    %edx,%eax
f0101cf2:	89 45 14             	mov    %eax,0x14(%ebp)
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f0101cf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0101cfc:	eb 53                	jmp    f0101d51 <boot_map_range+0x8f>
	{
		uint32 *ptr_page_table = boot_get_page_table(ptr_page_directory, virtual_address, 1) ;
f0101cfe:	83 ec 04             	sub    $0x4,%esp
f0101d01:	6a 01                	push   $0x1
f0101d03:	ff 75 0c             	pushl  0xc(%ebp)
f0101d06:	ff 75 08             	pushl  0x8(%ebp)
f0101d09:	e8 4e 00 00 00       	call   f0101d5c <boot_get_page_table>
f0101d0e:	83 c4 10             	add    $0x10,%esp
f0101d11:	89 45 e8             	mov    %eax,-0x18(%ebp)
		uint32 index_page_table = PTX(virtual_address);
f0101d14:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d17:	c1 e8 0c             	shr    $0xc,%eax
f0101d1a:	25 ff 03 00 00       	and    $0x3ff,%eax
f0101d1f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
f0101d22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d25:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101d2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d2f:	01 c2                	add    %eax,%edx
f0101d31:	8b 45 18             	mov    0x18(%ebp),%eax
f0101d34:	0b 45 14             	or     0x14(%ebp),%eax
f0101d37:	83 c8 01             	or     $0x1,%eax
f0101d3a:	89 02                	mov    %eax,(%edx)
		physical_address += PAGE_SIZE ;
f0101d3c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
		virtual_address += PAGE_SIZE ;
f0101d43:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
//
void boot_map_range(uint32 *ptr_page_directory, uint32 virtual_address, uint32 size, uint32 physical_address, int perm)
{
	int i = 0 ;
	physical_address = ROUNDUP(physical_address, PAGE_SIZE) ;
	for (i = 0 ; i < size ; i += PAGE_SIZE)
f0101d4a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
f0101d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d54:	3b 45 10             	cmp    0x10(%ebp),%eax
f0101d57:	72 a5                	jb     f0101cfe <boot_map_range+0x3c>
		uint32 index_page_table = PTX(virtual_address);
		ptr_page_table[index_page_table] = CONSTRUCT_ENTRY(physical_address, perm | PERM_PRESENT) ;
		physical_address += PAGE_SIZE ;
		virtual_address += PAGE_SIZE ;
	}
}
f0101d59:	90                   	nop
f0101d5a:	c9                   	leave  
f0101d5b:	c3                   	ret    

f0101d5c <boot_get_page_table>:
// boot_get_page_table cannot fail.  It's too early to fail.
// This function may ONLY be used during boot time,
// before the free_frame_list has been set up.
//
uint32* boot_get_page_table(uint32 *ptr_page_directory, uint32 virtual_address, int create)
{
f0101d5c:	55                   	push   %ebp
f0101d5d:	89 e5                	mov    %esp,%ebp
f0101d5f:	83 ec 28             	sub    $0x28,%esp
	uint32 index_page_directory = PDX(virtual_address);
f0101d62:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101d65:	c1 e8 16             	shr    $0x16,%eax
f0101d68:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 page_directory_entry = ptr_page_directory[index_page_directory];
f0101d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d6e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101d75:	8b 45 08             	mov    0x8(%ebp),%eax
f0101d78:	01 d0                	add    %edx,%eax
f0101d7a:	8b 00                	mov    (%eax),%eax
f0101d7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	uint32 phys_page_table = EXTRACT_ADDRESS(page_directory_entry);
f0101d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101d82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101d87:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint32 *ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table);
f0101d8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d8d:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101d90:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d93:	c1 e8 0c             	shr    $0xc,%eax
f0101d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101d99:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f0101d9e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0101da1:	72 17                	jb     f0101dba <boot_get_page_table+0x5e>
f0101da3:	ff 75 e8             	pushl  -0x18(%ebp)
f0101da6:	68 94 54 10 f0       	push   $0xf0105494
f0101dab:	68 db 00 00 00       	push   $0xdb
f0101db0:	68 7d 54 10 f0       	push   $0xf010547d
f0101db5:	e8 74 e3 ff ff       	call   f010012e <_panic>
f0101dba:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101dbd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101dc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if (phys_page_table == 0)
f0101dc5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101dc9:	75 72                	jne    f0101e3d <boot_get_page_table+0xe1>
	{
		if (create)
f0101dcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101dcf:	74 65                	je     f0101e36 <boot_get_page_table+0xda>
		{
			ptr_page_table = boot_allocate_space(PAGE_SIZE, PAGE_SIZE) ;
f0101dd1:	83 ec 08             	sub    $0x8,%esp
f0101dd4:	68 00 10 00 00       	push   $0x1000
f0101dd9:	68 00 10 00 00       	push   $0x1000
f0101dde:	e8 7d fe ff ff       	call   f0101c60 <boot_allocate_space>
f0101de3:	83 c4 10             	add    $0x10,%esp
f0101de6:	89 45 e0             	mov    %eax,-0x20(%ebp)
			phys_page_table = K_PHYSICAL_ADDRESS(ptr_page_table);
f0101de9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101dec:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101def:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f0101df6:	77 17                	ja     f0101e0f <boot_get_page_table+0xb3>
f0101df8:	ff 75 dc             	pushl  -0x24(%ebp)
f0101dfb:	68 4c 54 10 f0       	push   $0xf010544c
f0101e00:	68 e1 00 00 00       	push   $0xe1
f0101e05:	68 7d 54 10 f0       	push   $0xf010547d
f0101e0a:	e8 1f e3 ff ff       	call   f010012e <_panic>
f0101e0f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101e12:	05 00 00 00 10       	add    $0x10000000,%eax
f0101e17:	89 45 ec             	mov    %eax,-0x14(%ebp)
			ptr_page_directory[index_page_directory] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_WRITEABLE);
f0101e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e1d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0101e24:	8b 45 08             	mov    0x8(%ebp),%eax
f0101e27:	01 d0                	add    %edx,%eax
f0101e29:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0101e2c:	83 ca 03             	or     $0x3,%edx
f0101e2f:	89 10                	mov    %edx,(%eax)
			return ptr_page_table ;
f0101e31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101e34:	eb 0a                	jmp    f0101e40 <boot_get_page_table+0xe4>
		}
		else
			return 0 ;
f0101e36:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e3b:	eb 03                	jmp    f0101e40 <boot_get_page_table+0xe4>
	}
	return ptr_page_table ;
f0101e3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
f0101e40:	c9                   	leave  
f0101e41:	c3                   	ret    

f0101e42 <initialize_paging>:
// After this point, ONLY use the functions below
// to allocate and deallocate physical memory via the free_frame_list,
// and NEVER use boot_allocate_space() or the related boot-time functions above.
//
void initialize_paging()
{
f0101e42:	55                   	push   %ebp
f0101e43:	89 e5                	mov    %esp,%ebp
f0101e45:	53                   	push   %ebx
f0101e46:	83 ec 24             	sub    $0x24,%esp
	//     Some of it is in use, some is free. Where is the kernel?
	//     Which frames are used for page tables and other data structures?
	//
	// Change the code to reflect this.
	int i;
	LIST_INIT(&free_frame_list);
f0101e49:	c7 05 d8 d6 14 f0 00 	movl   $0x0,0xf014d6d8
f0101e50:	00 00 00 
	
	frames_info[0].references = 1;
f0101e53:	a1 dc d6 14 f0       	mov    0xf014d6dc,%eax
f0101e58:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
f0101e5e:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
f0101e65:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101e68:	05 ff ff 09 00       	add    $0x9ffff,%eax
f0101e6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101e70:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e73:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e78:	f7 75 f0             	divl   -0x10(%ebp)
f0101e7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e7e:	29 d0                	sub    %edx,%eax
f0101e80:	89 45 e8             	mov    %eax,-0x18(%ebp)
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f0101e83:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
f0101e8a:	e9 90 00 00 00       	jmp    f0101f1f <initialize_paging+0xdd>
	{
		frames_info[i].references = 0;
f0101e8f:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101e95:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101e98:	89 d0                	mov    %edx,%eax
f0101e9a:	01 c0                	add    %eax,%eax
f0101e9c:	01 d0                	add    %edx,%eax
f0101e9e:	c1 e0 02             	shl    $0x2,%eax
f0101ea1:	01 c8                	add    %ecx,%eax
f0101ea3:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f0101ea9:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101eaf:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101eb2:	89 d0                	mov    %edx,%eax
f0101eb4:	01 c0                	add    %eax,%eax
f0101eb6:	01 d0                	add    %edx,%eax
f0101eb8:	c1 e0 02             	shl    $0x2,%eax
f0101ebb:	01 c8                	add    %ecx,%eax
f0101ebd:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f0101ec3:	89 10                	mov    %edx,(%eax)
f0101ec5:	8b 00                	mov    (%eax),%eax
f0101ec7:	85 c0                	test   %eax,%eax
f0101ec9:	74 1d                	je     f0101ee8 <initialize_paging+0xa6>
f0101ecb:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f0101ed1:	8b 1d dc d6 14 f0    	mov    0xf014d6dc,%ebx
f0101ed7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0101eda:	89 c8                	mov    %ecx,%eax
f0101edc:	01 c0                	add    %eax,%eax
f0101ede:	01 c8                	add    %ecx,%eax
f0101ee0:	c1 e0 02             	shl    $0x2,%eax
f0101ee3:	01 d8                	add    %ebx,%eax
f0101ee5:	89 42 04             	mov    %eax,0x4(%edx)
f0101ee8:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101eee:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101ef1:	89 d0                	mov    %edx,%eax
f0101ef3:	01 c0                	add    %eax,%eax
f0101ef5:	01 d0                	add    %edx,%eax
f0101ef7:	c1 e0 02             	shl    $0x2,%eax
f0101efa:	01 c8                	add    %ecx,%eax
f0101efc:	a3 d8 d6 14 f0       	mov    %eax,0xf014d6d8
f0101f01:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101f07:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101f0a:	89 d0                	mov    %edx,%eax
f0101f0c:	01 c0                	add    %eax,%eax
f0101f0e:	01 d0                	add    %edx,%eax
f0101f10:	c1 e0 02             	shl    $0x2,%eax
f0101f13:	01 c8                	add    %ecx,%eax
f0101f15:	c7 40 04 d8 d6 14 f0 	movl   $0xf014d6d8,0x4(%eax)
	
	frames_info[0].references = 1;
	
	int range_end = ROUNDUP(PHYS_IO_MEM,PAGE_SIZE);
			
	for (i = 1; i < range_end/PAGE_SIZE; i++)
f0101f1c:	ff 45 f4             	incl   -0xc(%ebp)
f0101f1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101f22:	85 c0                	test   %eax,%eax
f0101f24:	79 05                	jns    f0101f2b <initialize_paging+0xe9>
f0101f26:	05 ff 0f 00 00       	add    $0xfff,%eax
f0101f2b:	c1 f8 0c             	sar    $0xc,%eax
f0101f2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101f31:	0f 8f 58 ff ff ff    	jg     f0101e8f <initialize_paging+0x4d>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f0101f37:	c7 45 f4 a0 00 00 00 	movl   $0xa0,-0xc(%ebp)
f0101f3e:	eb 1d                	jmp    f0101f5d <initialize_paging+0x11b>
	{
		frames_info[i].references = 1;
f0101f40:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101f46:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101f49:	89 d0                	mov    %edx,%eax
f0101f4b:	01 c0                	add    %eax,%eax
f0101f4d:	01 d0                	add    %edx,%eax
f0101f4f:	c1 e0 02             	shl    $0x2,%eax
f0101f52:	01 c8                	add    %ecx,%eax
f0101f54:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
	
	for (i = PHYS_IO_MEM/PAGE_SIZE ; i < PHYS_EXTENDED_MEM/PAGE_SIZE; i++)
f0101f5a:	ff 45 f4             	incl   -0xc(%ebp)
f0101f5d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
f0101f64:	7e da                	jle    f0101f40 <initialize_paging+0xfe>
	{
		frames_info[i].references = 1;
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
f0101f66:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
f0101f6d:	a1 e0 d6 14 f0       	mov    0xf014d6e0,%eax
f0101f72:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101f75:	81 7d e0 ff ff ff ef 	cmpl   $0xefffffff,-0x20(%ebp)
f0101f7c:	77 17                	ja     f0101f95 <initialize_paging+0x153>
f0101f7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101f81:	68 4c 54 10 f0       	push   $0xf010544c
f0101f86:	68 1e 01 00 00       	push   $0x11e
f0101f8b:	68 7d 54 10 f0       	push   $0xf010547d
f0101f90:	e8 99 e1 ff ff       	call   f010012e <_panic>
f0101f95:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101f98:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101f9e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101fa1:	01 d0                	add    %edx,%eax
f0101fa3:	48                   	dec    %eax
f0101fa4:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101fa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101faa:	ba 00 00 00 00       	mov    $0x0,%edx
f0101faf:	f7 75 e4             	divl   -0x1c(%ebp)
f0101fb2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101fb5:	29 d0                	sub    %edx,%eax
f0101fb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f0101fba:	c7 45 f4 00 01 00 00 	movl   $0x100,-0xc(%ebp)
f0101fc1:	eb 1d                	jmp    f0101fe0 <initialize_paging+0x19e>
	{
		frames_info[i].references = 1;
f0101fc3:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0101fc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101fcc:	89 d0                	mov    %edx,%eax
f0101fce:	01 c0                	add    %eax,%eax
f0101fd0:	01 d0                	add    %edx,%eax
f0101fd2:	c1 e0 02             	shl    $0x2,%eax
f0101fd5:	01 c8                	add    %ecx,%eax
f0101fd7:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
		frames_info[i].references = 1;
	}
		
	range_end = ROUNDUP(K_PHYSICAL_ADDRESS(ptr_free_mem), PAGE_SIZE);
	
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
f0101fdd:	ff 45 f4             	incl   -0xc(%ebp)
f0101fe0:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101fe3:	85 c0                	test   %eax,%eax
f0101fe5:	79 05                	jns    f0101fec <initialize_paging+0x1aa>
f0101fe7:	05 ff 0f 00 00       	add    $0xfff,%eax
f0101fec:	c1 f8 0c             	sar    $0xc,%eax
f0101fef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0101ff2:	7f cf                	jg     f0101fc3 <initialize_paging+0x181>
	{
		frames_info[i].references = 1;
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f0101ff4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101ff7:	85 c0                	test   %eax,%eax
f0101ff9:	79 05                	jns    f0102000 <initialize_paging+0x1be>
f0101ffb:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102000:	c1 f8 0c             	sar    $0xc,%eax
f0102003:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102006:	e9 90 00 00 00       	jmp    f010209b <initialize_paging+0x259>
	{
		frames_info[i].references = 0;
f010200b:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0102011:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102014:	89 d0                	mov    %edx,%eax
f0102016:	01 c0                	add    %eax,%eax
f0102018:	01 d0                	add    %edx,%eax
f010201a:	c1 e0 02             	shl    $0x2,%eax
f010201d:	01 c8                	add    %ecx,%eax
f010201f:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
f0102025:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f010202b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010202e:	89 d0                	mov    %edx,%eax
f0102030:	01 c0                	add    %eax,%eax
f0102032:	01 d0                	add    %edx,%eax
f0102034:	c1 e0 02             	shl    $0x2,%eax
f0102037:	01 c8                	add    %ecx,%eax
f0102039:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f010203f:	89 10                	mov    %edx,(%eax)
f0102041:	8b 00                	mov    (%eax),%eax
f0102043:	85 c0                	test   %eax,%eax
f0102045:	74 1d                	je     f0102064 <initialize_paging+0x222>
f0102047:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f010204d:	8b 1d dc d6 14 f0    	mov    0xf014d6dc,%ebx
f0102053:	8b 4d f4             	mov    -0xc(%ebp),%ecx
f0102056:	89 c8                	mov    %ecx,%eax
f0102058:	01 c0                	add    %eax,%eax
f010205a:	01 c8                	add    %ecx,%eax
f010205c:	c1 e0 02             	shl    $0x2,%eax
f010205f:	01 d8                	add    %ebx,%eax
f0102061:	89 42 04             	mov    %eax,0x4(%edx)
f0102064:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f010206a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010206d:	89 d0                	mov    %edx,%eax
f010206f:	01 c0                	add    %eax,%eax
f0102071:	01 d0                	add    %edx,%eax
f0102073:	c1 e0 02             	shl    $0x2,%eax
f0102076:	01 c8                	add    %ecx,%eax
f0102078:	a3 d8 d6 14 f0       	mov    %eax,0xf014d6d8
f010207d:	8b 0d dc d6 14 f0    	mov    0xf014d6dc,%ecx
f0102083:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102086:	89 d0                	mov    %edx,%eax
f0102088:	01 c0                	add    %eax,%eax
f010208a:	01 d0                	add    %edx,%eax
f010208c:	c1 e0 02             	shl    $0x2,%eax
f010208f:	01 c8                	add    %ecx,%eax
f0102091:	c7 40 04 d8 d6 14 f0 	movl   $0xf014d6d8,0x4(%eax)
	for (i = PHYS_EXTENDED_MEM/PAGE_SIZE ; i < range_end/PAGE_SIZE; i++)
	{
		frames_info[i].references = 1;
	}
	
	for (i = range_end/PAGE_SIZE ; i < number_of_frames; i++)
f0102098:	ff 45 f4             	incl   -0xc(%ebp)
f010209b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f010209e:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f01020a3:	39 c2                	cmp    %eax,%edx
f01020a5:	0f 82 60 ff ff ff    	jb     f010200b <initialize_paging+0x1c9>
	{
		frames_info[i].references = 0;
		LIST_INSERT_HEAD(&free_frame_list, &frames_info[i]);
	}
}
f01020ab:	90                   	nop
f01020ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01020af:	c9                   	leave  
f01020b0:	c3                   	ret    

f01020b1 <initialize_frame_info>:
// Initialize a Frame_Info structure.
// The result has null links and 0 references.
// Note that the corresponding physical frame is NOT initialized!
//
void initialize_frame_info(struct Frame_Info *ptr_frame_info)
{
f01020b1:	55                   	push   %ebp
f01020b2:	89 e5                	mov    %esp,%ebp
f01020b4:	83 ec 08             	sub    $0x8,%esp
	memset(ptr_frame_info, 0, sizeof(*ptr_frame_info));
f01020b7:	83 ec 04             	sub    $0x4,%esp
f01020ba:	6a 0c                	push   $0xc
f01020bc:	6a 00                	push   $0x0
f01020be:	ff 75 08             	pushl  0x8(%ebp)
f01020c1:	e8 5d 23 00 00       	call   f0104423 <memset>
f01020c6:	83 c4 10             	add    $0x10,%esp
}
f01020c9:	90                   	nop
f01020ca:	c9                   	leave  
f01020cb:	c3                   	ret    

f01020cc <allocate_frame>:
//   E_NO_MEM -- otherwise
//
// Hint: use LIST_FIRST, LIST_REMOVE, and initialize_frame_info
// Hint: references should not be incremented
int allocate_frame(struct Frame_Info **ptr_frame_info)
{
f01020cc:	55                   	push   %ebp
f01020cd:	89 e5                	mov    %esp,%ebp
f01020cf:	83 ec 08             	sub    $0x8,%esp
	// Fill this function in	
	*ptr_frame_info = LIST_FIRST(&free_frame_list);
f01020d2:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f01020d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01020db:	89 10                	mov    %edx,(%eax)
	if(*ptr_frame_info == NULL)
f01020dd:	8b 45 08             	mov    0x8(%ebp),%eax
f01020e0:	8b 00                	mov    (%eax),%eax
f01020e2:	85 c0                	test   %eax,%eax
f01020e4:	75 07                	jne    f01020ed <allocate_frame+0x21>
		return E_NO_MEM;
f01020e6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01020eb:	eb 44                	jmp    f0102131 <allocate_frame+0x65>
	
	LIST_REMOVE(*ptr_frame_info);
f01020ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01020f0:	8b 00                	mov    (%eax),%eax
f01020f2:	8b 00                	mov    (%eax),%eax
f01020f4:	85 c0                	test   %eax,%eax
f01020f6:	74 12                	je     f010210a <allocate_frame+0x3e>
f01020f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01020fb:	8b 00                	mov    (%eax),%eax
f01020fd:	8b 00                	mov    (%eax),%eax
f01020ff:	8b 55 08             	mov    0x8(%ebp),%edx
f0102102:	8b 12                	mov    (%edx),%edx
f0102104:	8b 52 04             	mov    0x4(%edx),%edx
f0102107:	89 50 04             	mov    %edx,0x4(%eax)
f010210a:	8b 45 08             	mov    0x8(%ebp),%eax
f010210d:	8b 00                	mov    (%eax),%eax
f010210f:	8b 40 04             	mov    0x4(%eax),%eax
f0102112:	8b 55 08             	mov    0x8(%ebp),%edx
f0102115:	8b 12                	mov    (%edx),%edx
f0102117:	8b 12                	mov    (%edx),%edx
f0102119:	89 10                	mov    %edx,(%eax)
	initialize_frame_info(*ptr_frame_info);
f010211b:	8b 45 08             	mov    0x8(%ebp),%eax
f010211e:	8b 00                	mov    (%eax),%eax
f0102120:	83 ec 0c             	sub    $0xc,%esp
f0102123:	50                   	push   %eax
f0102124:	e8 88 ff ff ff       	call   f01020b1 <initialize_frame_info>
f0102129:	83 c4 10             	add    $0x10,%esp
	return 0;
f010212c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102131:	c9                   	leave  
f0102132:	c3                   	ret    

f0102133 <free_frame>:
//
// Return a frame to the free_frame_list.
// (This function should only be called when ptr_frame_info->references reaches 0.)
//
void free_frame(struct Frame_Info *ptr_frame_info)
{
f0102133:	55                   	push   %ebp
f0102134:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	LIST_INSERT_HEAD(&free_frame_list, ptr_frame_info);
f0102136:	8b 15 d8 d6 14 f0    	mov    0xf014d6d8,%edx
f010213c:	8b 45 08             	mov    0x8(%ebp),%eax
f010213f:	89 10                	mov    %edx,(%eax)
f0102141:	8b 45 08             	mov    0x8(%ebp),%eax
f0102144:	8b 00                	mov    (%eax),%eax
f0102146:	85 c0                	test   %eax,%eax
f0102148:	74 0b                	je     f0102155 <free_frame+0x22>
f010214a:	a1 d8 d6 14 f0       	mov    0xf014d6d8,%eax
f010214f:	8b 55 08             	mov    0x8(%ebp),%edx
f0102152:	89 50 04             	mov    %edx,0x4(%eax)
f0102155:	8b 45 08             	mov    0x8(%ebp),%eax
f0102158:	a3 d8 d6 14 f0       	mov    %eax,0xf014d6d8
f010215d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102160:	c7 40 04 d8 d6 14 f0 	movl   $0xf014d6d8,0x4(%eax)
}
f0102167:	90                   	nop
f0102168:	5d                   	pop    %ebp
f0102169:	c3                   	ret    

f010216a <decrement_references>:
//
// Decrement the reference count on a frame
// freeing it if there are no more references.
//
void decrement_references(struct Frame_Info* ptr_frame_info)
{
f010216a:	55                   	push   %ebp
f010216b:	89 e5                	mov    %esp,%ebp
	if (--(ptr_frame_info->references) == 0)
f010216d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102170:	8b 40 08             	mov    0x8(%eax),%eax
f0102173:	48                   	dec    %eax
f0102174:	8b 55 08             	mov    0x8(%ebp),%edx
f0102177:	66 89 42 08          	mov    %ax,0x8(%edx)
f010217b:	8b 45 08             	mov    0x8(%ebp),%eax
f010217e:	8b 40 08             	mov    0x8(%eax),%eax
f0102181:	66 85 c0             	test   %ax,%ax
f0102184:	75 0b                	jne    f0102191 <decrement_references+0x27>
		free_frame(ptr_frame_info);
f0102186:	ff 75 08             	pushl  0x8(%ebp)
f0102189:	e8 a5 ff ff ff       	call   f0102133 <free_frame>
f010218e:	83 c4 04             	add    $0x4,%esp
}
f0102191:	90                   	nop
f0102192:	c9                   	leave  
f0102193:	c3                   	ret    

f0102194 <get_page_table>:
//
// Hint: you can use "to_physical_address()" to turn a Frame_Info*
// into the physical address of the frame it refers to. 

int get_page_table(uint32 *ptr_page_directory, const void *virtual_address, int create, uint32 **ptr_page_table)
{
f0102194:	55                   	push   %ebp
f0102195:	89 e5                	mov    %esp,%ebp
f0102197:	83 ec 28             	sub    $0x28,%esp
	// Fill this function in
	uint32 page_directory_entry = ptr_page_directory[PDX(virtual_address)];
f010219a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010219d:	c1 e8 16             	shr    $0x16,%eax
f01021a0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01021a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01021aa:	01 d0                	add    %edx,%eax
f01021ac:	8b 00                	mov    (%eax),%eax
f01021ae:	89 45 f4             	mov    %eax,-0xc(%ebp)

	*ptr_page_table = K_VIRTUAL_ADDRESS(EXTRACT_ADDRESS(page_directory_entry)) ;
f01021b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01021b4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01021b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01021bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01021bf:	c1 e8 0c             	shr    $0xc,%eax
f01021c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01021c5:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f01021ca:	39 45 ec             	cmp    %eax,-0x14(%ebp)
f01021cd:	72 17                	jb     f01021e6 <get_page_table+0x52>
f01021cf:	ff 75 f0             	pushl  -0x10(%ebp)
f01021d2:	68 94 54 10 f0       	push   $0xf0105494
f01021d7:	68 79 01 00 00       	push   $0x179
f01021dc:	68 7d 54 10 f0       	push   $0xf010547d
f01021e1:	e8 48 df ff ff       	call   f010012e <_panic>
f01021e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01021e9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021ee:	89 c2                	mov    %eax,%edx
f01021f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01021f3:	89 10                	mov    %edx,(%eax)
	
	if (page_directory_entry == 0)
f01021f5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01021f9:	0f 85 d3 00 00 00    	jne    f01022d2 <get_page_table+0x13e>
	{
		if (create)
f01021ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0102203:	0f 84 b9 00 00 00    	je     f01022c2 <get_page_table+0x12e>
		{
			struct Frame_Info* ptr_frame_info;
			int err = allocate_frame(&ptr_frame_info) ;
f0102209:	83 ec 0c             	sub    $0xc,%esp
f010220c:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010220f:	50                   	push   %eax
f0102210:	e8 b7 fe ff ff       	call   f01020cc <allocate_frame>
f0102215:	83 c4 10             	add    $0x10,%esp
f0102218:	89 45 e8             	mov    %eax,-0x18(%ebp)
			if(err == E_NO_MEM)
f010221b:	83 7d e8 fc          	cmpl   $0xfffffffc,-0x18(%ebp)
f010221f:	75 13                	jne    f0102234 <get_page_table+0xa0>
			{
				*ptr_page_table = 0;
f0102221:	8b 45 14             	mov    0x14(%ebp),%eax
f0102224:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
				return E_NO_MEM;
f010222a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010222f:	e9 a3 00 00 00       	jmp    f01022d7 <get_page_table+0x143>
			}

			uint32 phys_page_table = to_physical_address(ptr_frame_info);
f0102234:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102237:	83 ec 0c             	sub    $0xc,%esp
f010223a:	50                   	push   %eax
f010223b:	e8 e5 f7 ff ff       	call   f0101a25 <to_physical_address>
f0102240:	83 c4 10             	add    $0x10,%esp
f0102243:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			*ptr_page_table = K_VIRTUAL_ADDRESS(phys_page_table) ;
f0102246:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102249:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010224c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010224f:	c1 e8 0c             	shr    $0xc,%eax
f0102252:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102255:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f010225a:	39 45 dc             	cmp    %eax,-0x24(%ebp)
f010225d:	72 17                	jb     f0102276 <get_page_table+0xe2>
f010225f:	ff 75 e0             	pushl  -0x20(%ebp)
f0102262:	68 94 54 10 f0       	push   $0xf0105494
f0102267:	68 88 01 00 00       	push   $0x188
f010226c:	68 7d 54 10 f0       	push   $0xf010547d
f0102271:	e8 b8 de ff ff       	call   f010012e <_panic>
f0102276:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102279:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010227e:	89 c2                	mov    %eax,%edx
f0102280:	8b 45 14             	mov    0x14(%ebp),%eax
f0102283:	89 10                	mov    %edx,(%eax)
			
			//initialize new page table by 0's
			memset(*ptr_page_table , 0, PAGE_SIZE);
f0102285:	8b 45 14             	mov    0x14(%ebp),%eax
f0102288:	8b 00                	mov    (%eax),%eax
f010228a:	83 ec 04             	sub    $0x4,%esp
f010228d:	68 00 10 00 00       	push   $0x1000
f0102292:	6a 00                	push   $0x0
f0102294:	50                   	push   %eax
f0102295:	e8 89 21 00 00       	call   f0104423 <memset>
f010229a:	83 c4 10             	add    $0x10,%esp

			ptr_frame_info->references = 1;
f010229d:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01022a0:	66 c7 40 08 01 00    	movw   $0x1,0x8(%eax)
			ptr_page_directory[PDX(virtual_address)] = CONSTRUCT_ENTRY(phys_page_table, PERM_PRESENT | PERM_USER | PERM_WRITEABLE);
f01022a6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01022a9:	c1 e8 16             	shr    $0x16,%eax
f01022ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01022b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01022b6:	01 d0                	add    %edx,%eax
f01022b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01022bb:	83 ca 07             	or     $0x7,%edx
f01022be:	89 10                	mov    %edx,(%eax)
f01022c0:	eb 10                	jmp    f01022d2 <get_page_table+0x13e>
		}
		else
		{
			*ptr_page_table = 0;
f01022c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01022c5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			return 0;
f01022cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01022d0:	eb 05                	jmp    f01022d7 <get_page_table+0x143>
		}
	}	
	return 0;
f01022d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01022d7:	c9                   	leave  
f01022d8:	c3                   	ret    

f01022d9 <map_frame>:
//   E_NO_MEM, if page table couldn't be allocated
//
// Hint: implement using get_page_table() and unmap_frame().
//
int map_frame(uint32 *ptr_page_directory, struct Frame_Info *ptr_frame_info, void *virtual_address, int perm)
{
f01022d9:	55                   	push   %ebp
f01022da:	89 e5                	mov    %esp,%ebp
f01022dc:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 physical_address = to_physical_address(ptr_frame_info);
f01022df:	ff 75 0c             	pushl  0xc(%ebp)
f01022e2:	e8 3e f7 ff ff       	call   f0101a25 <to_physical_address>
f01022e7:	83 c4 04             	add    $0x4,%esp
f01022ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	uint32 *ptr_page_table;
	if( get_page_table(ptr_page_directory, virtual_address, 1, &ptr_page_table) == 0)
f01022ed:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01022f0:	50                   	push   %eax
f01022f1:	6a 01                	push   $0x1
f01022f3:	ff 75 10             	pushl  0x10(%ebp)
f01022f6:	ff 75 08             	pushl  0x8(%ebp)
f01022f9:	e8 96 fe ff ff       	call   f0102194 <get_page_table>
f01022fe:	83 c4 10             	add    $0x10,%esp
f0102301:	85 c0                	test   %eax,%eax
f0102303:	75 71                	jne    f0102376 <map_frame+0x9d>
	{
		uint32 page_table_entry = ptr_page_table[PTX(virtual_address)];
f0102305:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102308:	8b 55 10             	mov    0x10(%ebp),%edx
f010230b:	c1 ea 0c             	shr    $0xc,%edx
f010230e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102314:	c1 e2 02             	shl    $0x2,%edx
f0102317:	01 d0                	add    %edx,%eax
f0102319:	8b 00                	mov    (%eax),%eax
f010231b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		
		
		if( EXTRACT_ADDRESS(page_table_entry) != physical_address)
f010231e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102321:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102326:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f0102329:	74 44                	je     f010236f <map_frame+0x96>
		{
			if( page_table_entry != 0)
f010232b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f010232f:	74 11                	je     f0102342 <map_frame+0x69>
			{				
				unmap_frame(ptr_page_directory , virtual_address);
f0102331:	83 ec 08             	sub    $0x8,%esp
f0102334:	ff 75 10             	pushl  0x10(%ebp)
f0102337:	ff 75 08             	pushl  0x8(%ebp)
f010233a:	e8 ad 00 00 00       	call   f01023ec <unmap_frame>
f010233f:	83 c4 10             	add    $0x10,%esp
			}
			ptr_frame_info->references++;
f0102342:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102345:	8b 40 08             	mov    0x8(%eax),%eax
f0102348:	40                   	inc    %eax
f0102349:	8b 55 0c             	mov    0xc(%ebp),%edx
f010234c:	66 89 42 08          	mov    %ax,0x8(%edx)
			ptr_page_table[PTX(virtual_address)] = CONSTRUCT_ENTRY(physical_address , perm | PERM_PRESENT);
f0102350:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102353:	8b 55 10             	mov    0x10(%ebp),%edx
f0102356:	c1 ea 0c             	shr    $0xc,%edx
f0102359:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010235f:	c1 e2 02             	shl    $0x2,%edx
f0102362:	01 c2                	add    %eax,%edx
f0102364:	8b 45 14             	mov    0x14(%ebp),%eax
f0102367:	0b 45 f4             	or     -0xc(%ebp),%eax
f010236a:	83 c8 01             	or     $0x1,%eax
f010236d:	89 02                	mov    %eax,(%edx)
			
		}		
		return 0;
f010236f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102374:	eb 05                	jmp    f010237b <map_frame+0xa2>
	}	
	return E_NO_MEM;
f0102376:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
}
f010237b:	c9                   	leave  
f010237c:	c3                   	ret    

f010237d <get_frame_info>:
// Return 0 if there is no frame mapped at virtual_address.
//
// Hint: implement using get_page_table() and get_frame_info().
//
struct Frame_Info * get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table)
{
f010237d:	55                   	push   %ebp
f010237e:	89 e5                	mov    %esp,%ebp
f0102380:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in	
	uint32 ret =  get_page_table(ptr_page_directory, virtual_address, 0, ptr_page_table) ;
f0102383:	ff 75 10             	pushl  0x10(%ebp)
f0102386:	6a 00                	push   $0x0
f0102388:	ff 75 0c             	pushl  0xc(%ebp)
f010238b:	ff 75 08             	pushl  0x8(%ebp)
f010238e:	e8 01 fe ff ff       	call   f0102194 <get_page_table>
f0102393:	83 c4 10             	add    $0x10,%esp
f0102396:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if((*ptr_page_table) != 0)
f0102399:	8b 45 10             	mov    0x10(%ebp),%eax
f010239c:	8b 00                	mov    (%eax),%eax
f010239e:	85 c0                	test   %eax,%eax
f01023a0:	74 43                	je     f01023e5 <get_frame_info+0x68>
	{	
		uint32 index_page_table = PTX(virtual_address);
f01023a2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01023a5:	c1 e8 0c             	shr    $0xc,%eax
f01023a8:	25 ff 03 00 00       	and    $0x3ff,%eax
f01023ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
		uint32 page_table_entry = (*ptr_page_table)[index_page_table];
f01023b0:	8b 45 10             	mov    0x10(%ebp),%eax
f01023b3:	8b 00                	mov    (%eax),%eax
f01023b5:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01023b8:	c1 e2 02             	shl    $0x2,%edx
f01023bb:	01 d0                	add    %edx,%eax
f01023bd:	8b 00                	mov    (%eax),%eax
f01023bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if( page_table_entry != 0)	
f01023c2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f01023c6:	74 16                	je     f01023de <get_frame_info+0x61>
			return to_frame_info( EXTRACT_ADDRESS ( page_table_entry ) );
f01023c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01023cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01023d0:	83 ec 0c             	sub    $0xc,%esp
f01023d3:	50                   	push   %eax
f01023d4:	e8 5f f6 ff ff       	call   f0101a38 <to_frame_info>
f01023d9:	83 c4 10             	add    $0x10,%esp
f01023dc:	eb 0c                	jmp    f01023ea <get_frame_info+0x6d>
		return 0;
f01023de:	b8 00 00 00 00       	mov    $0x0,%eax
f01023e3:	eb 05                	jmp    f01023ea <get_frame_info+0x6d>
	}
	return 0;
f01023e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01023ea:	c9                   	leave  
f01023eb:	c3                   	ret    

f01023ec <unmap_frame>:
//
// Hint: implement using get_frame_info(),
// 	tlb_invalidate(), and decrement_references().
//
void unmap_frame(uint32 *ptr_page_directory, void *virtual_address)
{
f01023ec:	55                   	push   %ebp
f01023ed:	89 e5                	mov    %esp,%ebp
f01023ef:	83 ec 18             	sub    $0x18,%esp
	// Fill this function in
	uint32 *ptr_page_table;
	struct Frame_Info* ptr_frame_info = get_frame_info(ptr_page_directory, virtual_address, &ptr_page_table);
f01023f2:	83 ec 04             	sub    $0x4,%esp
f01023f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01023f8:	50                   	push   %eax
f01023f9:	ff 75 0c             	pushl  0xc(%ebp)
f01023fc:	ff 75 08             	pushl  0x8(%ebp)
f01023ff:	e8 79 ff ff ff       	call   f010237d <get_frame_info>
f0102404:	83 c4 10             	add    $0x10,%esp
f0102407:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if( ptr_frame_info != 0 )
f010240a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010240e:	74 39                	je     f0102449 <unmap_frame+0x5d>
	{
		decrement_references(ptr_frame_info);
f0102410:	83 ec 0c             	sub    $0xc,%esp
f0102413:	ff 75 f4             	pushl  -0xc(%ebp)
f0102416:	e8 4f fd ff ff       	call   f010216a <decrement_references>
f010241b:	83 c4 10             	add    $0x10,%esp
		ptr_page_table[PTX(virtual_address)] = 0;
f010241e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102421:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102424:	c1 ea 0c             	shr    $0xc,%edx
f0102427:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f010242d:	c1 e2 02             	shl    $0x2,%edx
f0102430:	01 d0                	add    %edx,%eax
f0102432:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		tlb_invalidate(ptr_page_directory, virtual_address);
f0102438:	83 ec 08             	sub    $0x8,%esp
f010243b:	ff 75 0c             	pushl  0xc(%ebp)
f010243e:	ff 75 08             	pushl  0x8(%ebp)
f0102441:	e8 64 eb ff ff       	call   f0100faa <tlb_invalidate>
f0102446:	83 c4 10             	add    $0x10,%esp
	}	
}
f0102449:	90                   	nop
f010244a:	c9                   	leave  
f010244b:	c3                   	ret    

f010244c <get_page>:
//		or to allocate any necessary page tables.
// 	HINT: 	remember to free the allocated frame if there is no space 
//		for the necessary page tables

int get_page(uint32* ptr_page_directory, void *virtual_address, int perm)
{
f010244c:	55                   	push   %ebp
f010244d:	89 e5                	mov    %esp,%ebp
f010244f:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("get_page function is not completed yet") ;
f0102452:	83 ec 04             	sub    $0x4,%esp
f0102455:	68 c4 54 10 f0       	push   $0xf01054c4
f010245a:	68 12 02 00 00       	push   $0x212
f010245f:	68 7d 54 10 f0       	push   $0xf010547d
f0102464:	e8 c5 dc ff ff       	call   f010012e <_panic>

f0102469 <calculate_required_frames>:
	return 0 ;
}

//[2] calculate_required_frames: 
uint32 calculate_required_frames(uint32* ptr_page_directory, uint32 start_virtual_address, uint32 size)
{
f0102469:	55                   	push   %ebp
f010246a:	89 e5                	mov    %esp,%ebp
f010246c:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("calculate_required_frames function is not completed yet") ;
f010246f:	83 ec 04             	sub    $0x4,%esp
f0102472:	68 ec 54 10 f0       	push   $0xf01054ec
f0102477:	68 29 02 00 00       	push   $0x229
f010247c:	68 7d 54 10 f0       	push   $0xf010547d
f0102481:	e8 a8 dc ff ff       	call   f010012e <_panic>

f0102486 <calculate_free_frames>:


//[3] calculate_free_frames:

uint32 calculate_free_frames()
{
f0102486:	55                   	push   %ebp
f0102487:	89 e5                	mov    %esp,%ebp
f0102489:	83 ec 10             	sub    $0x10,%esp
	// PROJECT 2008: Your code here.
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
f010248c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	LIST_FOREACH(ptr, &free_frame_list)
f0102493:	a1 d8 d6 14 f0       	mov    0xf014d6d8,%eax
f0102498:	89 45 fc             	mov    %eax,-0x4(%ebp)
f010249b:	eb 0b                	jmp    f01024a8 <calculate_free_frames+0x22>
	{
		cnt++ ;
f010249d:	ff 45 f8             	incl   -0x8(%ebp)
	//panic("calculate_free_frames function is not completed yet") ;
	
	//calculate the free frames from the free frame list
	struct Frame_Info *ptr;
	uint32 cnt = 0 ; 
	LIST_FOREACH(ptr, &free_frame_list)
f01024a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01024a3:	8b 00                	mov    (%eax),%eax
f01024a5:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01024a8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f01024ac:	75 ef                	jne    f010249d <calculate_free_frames+0x17>
	{
		cnt++ ;
	}
	return cnt;
f01024ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01024b1:	c9                   	leave  
f01024b2:	c3                   	ret    

f01024b3 <freeMem>:
//	Steps:
//		1) Unmap all mapped pages in the range [virtual_address, virtual_address + size ]
//		2) Free all mapped page tables in this range

void freeMem(uint32* ptr_page_directory, void *virtual_address, uint32 size)
{
f01024b3:	55                   	push   %ebp
f01024b4:	89 e5                	mov    %esp,%ebp
f01024b6:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("freeMem function is not completed yet") ;
f01024b9:	83 ec 04             	sub    $0x4,%esp
f01024bc:	68 24 55 10 f0       	push   $0xf0105524
f01024c1:	68 50 02 00 00       	push   $0x250
f01024c6:	68 7d 54 10 f0       	push   $0xf010547d
f01024cb:	e8 5e dc ff ff       	call   f010012e <_panic>

f01024d0 <allocate_environment>:
//
// Returns 0 on success, < 0 on failure.  Errors include:
//	E_NO_FREE_ENV if all NENVS environments are allocated
//
int allocate_environment(struct Env** e)
{	
f01024d0:	55                   	push   %ebp
f01024d1:	89 e5                	mov    %esp,%ebp
	if (!(*e = LIST_FIRST(&env_free_list)))
f01024d3:	8b 15 54 ce 14 f0    	mov    0xf014ce54,%edx
f01024d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01024dc:	89 10                	mov    %edx,(%eax)
f01024de:	8b 45 08             	mov    0x8(%ebp),%eax
f01024e1:	8b 00                	mov    (%eax),%eax
f01024e3:	85 c0                	test   %eax,%eax
f01024e5:	75 07                	jne    f01024ee <allocate_environment+0x1e>
		return E_NO_FREE_ENV;
f01024e7:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01024ec:	eb 05                	jmp    f01024f3 <allocate_environment+0x23>
	return 0;
f01024ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01024f3:	5d                   	pop    %ebp
f01024f4:	c3                   	ret    

f01024f5 <free_environment>:

// Free the given environment "e", simply by adding it to the free environment list.
void free_environment(struct Env* e)
{
f01024f5:	55                   	push   %ebp
f01024f6:	89 e5                	mov    %esp,%ebp
	curenv = NULL;	
f01024f8:	c7 05 50 ce 14 f0 00 	movl   $0x0,0xf014ce50
f01024ff:	00 00 00 
	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102502:	8b 45 08             	mov    0x8(%ebp),%eax
f0102505:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	LIST_INSERT_HEAD(&env_free_list, e);
f010250c:	8b 15 54 ce 14 f0    	mov    0xf014ce54,%edx
f0102512:	8b 45 08             	mov    0x8(%ebp),%eax
f0102515:	89 50 44             	mov    %edx,0x44(%eax)
f0102518:	8b 45 08             	mov    0x8(%ebp),%eax
f010251b:	8b 40 44             	mov    0x44(%eax),%eax
f010251e:	85 c0                	test   %eax,%eax
f0102520:	74 0e                	je     f0102530 <free_environment+0x3b>
f0102522:	a1 54 ce 14 f0       	mov    0xf014ce54,%eax
f0102527:	8b 55 08             	mov    0x8(%ebp),%edx
f010252a:	83 c2 44             	add    $0x44,%edx
f010252d:	89 50 48             	mov    %edx,0x48(%eax)
f0102530:	8b 45 08             	mov    0x8(%ebp),%eax
f0102533:	a3 54 ce 14 f0       	mov    %eax,0xf014ce54
f0102538:	8b 45 08             	mov    0x8(%ebp),%eax
f010253b:	c7 40 48 54 ce 14 f0 	movl   $0xf014ce54,0x48(%eax)
}
f0102542:	90                   	nop
f0102543:	5d                   	pop    %ebp
f0102544:	c3                   	ret    

f0102545 <initialize_environment>:
// and initialize the kernel portion of the new environment's address space.
// Do NOT (yet) map anything into the user portion
// of the environment's virtual address space.
//
void initialize_environment(struct Env* e, uint32* ptr_user_page_directory)
{	
f0102545:	55                   	push   %ebp
f0102546:	89 e5                	mov    %esp,%ebp
f0102548:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("initialize_environment function is not completed yet") ;
f010254b:	83 ec 04             	sub    $0x4,%esp
f010254e:	68 a8 55 10 f0       	push   $0xf01055a8
f0102553:	6a 77                	push   $0x77
f0102555:	68 dd 55 10 f0       	push   $0xf01055dd
f010255a:	e8 cf db ff ff       	call   f010012e <_panic>

f010255f <program_segment_alloc_map>:
//
// if the allocation failed, return E_NO_MEM 
// otherwise return 0
//
static int program_segment_alloc_map(struct Env *e, void *va, uint32 length)
{
f010255f:	55                   	push   %ebp
f0102560:	89 e5                	mov    %esp,%ebp
f0102562:	83 ec 08             	sub    $0x8,%esp
	//PROJECT 2008: Your code here.	
	panic("program_segment_alloc_map function is not completed yet") ;
f0102565:	83 ec 04             	sub    $0x4,%esp
f0102568:	68 f8 55 10 f0       	push   $0xf01055f8
f010256d:	68 8e 00 00 00       	push   $0x8e
f0102572:	68 dd 55 10 f0       	push   $0xf01055dd
f0102577:	e8 b2 db ff ff       	call   f010012e <_panic>

f010257c <env_create>:
}

//
// Allocates a new env and loads the named user program into it.
struct UserProgramInfo* env_create(char* user_program_name)
{
f010257c:	55                   	push   %ebp
f010257d:	89 e5                	mov    %esp,%ebp
f010257f:	83 ec 28             	sub    $0x28,%esp
	// PROJECT 2008: Your code here.
	panic("env_create function is not completed yet") ;
f0102582:	83 ec 04             	sub    $0x4,%esp
f0102585:	68 30 56 10 f0       	push   $0xf0105630
f010258a:	68 99 00 00 00       	push   $0x99
f010258f:	68 dd 55 10 f0       	push   $0xf01055dd
f0102594:	e8 95 db ff ff       	call   f010012e <_panic>

f0102599 <env_run>:
// Used to run the given environment "e", simply by 
// context switch from curenv to env e.
//  (This function does not return.)
//
void env_run(struct Env *e)
{
f0102599:	55                   	push   %ebp
f010259a:	89 e5                	mov    %esp,%ebp
f010259c:	83 ec 18             	sub    $0x18,%esp
	if(curenv != e)
f010259f:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01025a4:	3b 45 08             	cmp    0x8(%ebp),%eax
f01025a7:	74 25                	je     f01025ce <env_run+0x35>
	{		
		curenv = e ;
f01025a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01025ac:	a3 50 ce 14 f0       	mov    %eax,0xf014ce50
		curenv->env_runs++ ;
f01025b1:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01025b6:	8b 50 58             	mov    0x58(%eax),%edx
f01025b9:	42                   	inc    %edx
f01025ba:	89 50 58             	mov    %edx,0x58(%eax)
		lcr3(curenv->env_cr3) ;	
f01025bd:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01025c2:	8b 40 60             	mov    0x60(%eax),%eax
f01025c5:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01025c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01025cb:	0f 22 d8             	mov    %eax,%cr3
	}	
	env_pop_tf(&(curenv->env_tf));
f01025ce:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01025d3:	83 ec 0c             	sub    $0xc,%esp
f01025d6:	50                   	push   %eax
f01025d7:	e8 89 06 00 00       	call   f0102c65 <env_pop_tf>

f01025dc <env_free>:

//
// Frees environment "e" and all memory it uses.
// 
void env_free(struct Env *e)
{
f01025dc:	55                   	push   %ebp
f01025dd:	89 e5                	mov    %esp,%ebp
f01025df:	83 ec 08             	sub    $0x8,%esp
	// PROJECT 2008: Your code here.
	panic("env_free function is not completed yet") ;
f01025e2:	83 ec 04             	sub    $0x4,%esp
f01025e5:	68 5c 56 10 f0       	push   $0xf010565c
f01025ea:	68 ef 00 00 00       	push   $0xef
f01025ef:	68 dd 55 10 f0       	push   $0xf01055dd
f01025f4:	e8 35 db ff ff       	call   f010012e <_panic>

f01025f9 <env_init>:
// Insert in reverse order, so that the first call to allocate_environment()
// returns envs[0].
//
void
env_init(void)
{	
f01025f9:	55                   	push   %ebp
f01025fa:	89 e5                	mov    %esp,%ebp
f01025fc:	53                   	push   %ebx
f01025fd:	83 ec 10             	sub    $0x10,%esp
	int iEnv = NENV-1;
f0102600:	c7 45 f8 ff 03 00 00 	movl   $0x3ff,-0x8(%ebp)
	for(; iEnv >= 0; iEnv--)
f0102607:	e9 ed 00 00 00       	jmp    f01026f9 <env_init+0x100>
	{
		envs[iEnv].env_status = ENV_FREE;
f010260c:	8b 0d 4c ce 14 f0    	mov    0xf014ce4c,%ecx
f0102612:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102615:	89 d0                	mov    %edx,%eax
f0102617:	c1 e0 02             	shl    $0x2,%eax
f010261a:	01 d0                	add    %edx,%eax
f010261c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102623:	01 d0                	add    %edx,%eax
f0102625:	c1 e0 02             	shl    $0x2,%eax
f0102628:	01 c8                	add    %ecx,%eax
f010262a:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[iEnv].env_id = 0;
f0102631:	8b 0d 4c ce 14 f0    	mov    0xf014ce4c,%ecx
f0102637:	8b 55 f8             	mov    -0x8(%ebp),%edx
f010263a:	89 d0                	mov    %edx,%eax
f010263c:	c1 e0 02             	shl    $0x2,%eax
f010263f:	01 d0                	add    %edx,%eax
f0102641:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102648:	01 d0                	add    %edx,%eax
f010264a:	c1 e0 02             	shl    $0x2,%eax
f010264d:	01 c8                	add    %ecx,%eax
f010264f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
f0102656:	8b 0d 4c ce 14 f0    	mov    0xf014ce4c,%ecx
f010265c:	8b 55 f8             	mov    -0x8(%ebp),%edx
f010265f:	89 d0                	mov    %edx,%eax
f0102661:	c1 e0 02             	shl    $0x2,%eax
f0102664:	01 d0                	add    %edx,%eax
f0102666:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010266d:	01 d0                	add    %edx,%eax
f010266f:	c1 e0 02             	shl    $0x2,%eax
f0102672:	01 c8                	add    %ecx,%eax
f0102674:	8b 15 54 ce 14 f0    	mov    0xf014ce54,%edx
f010267a:	89 50 44             	mov    %edx,0x44(%eax)
f010267d:	8b 40 44             	mov    0x44(%eax),%eax
f0102680:	85 c0                	test   %eax,%eax
f0102682:	74 2a                	je     f01026ae <env_init+0xb5>
f0102684:	8b 15 54 ce 14 f0    	mov    0xf014ce54,%edx
f010268a:	8b 1d 4c ce 14 f0    	mov    0xf014ce4c,%ebx
f0102690:	8b 4d f8             	mov    -0x8(%ebp),%ecx
f0102693:	89 c8                	mov    %ecx,%eax
f0102695:	c1 e0 02             	shl    $0x2,%eax
f0102698:	01 c8                	add    %ecx,%eax
f010269a:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
f01026a1:	01 c8                	add    %ecx,%eax
f01026a3:	c1 e0 02             	shl    $0x2,%eax
f01026a6:	01 d8                	add    %ebx,%eax
f01026a8:	83 c0 44             	add    $0x44,%eax
f01026ab:	89 42 48             	mov    %eax,0x48(%edx)
f01026ae:	8b 0d 4c ce 14 f0    	mov    0xf014ce4c,%ecx
f01026b4:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01026b7:	89 d0                	mov    %edx,%eax
f01026b9:	c1 e0 02             	shl    $0x2,%eax
f01026bc:	01 d0                	add    %edx,%eax
f01026be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01026c5:	01 d0                	add    %edx,%eax
f01026c7:	c1 e0 02             	shl    $0x2,%eax
f01026ca:	01 c8                	add    %ecx,%eax
f01026cc:	a3 54 ce 14 f0       	mov    %eax,0xf014ce54
f01026d1:	8b 0d 4c ce 14 f0    	mov    0xf014ce4c,%ecx
f01026d7:	8b 55 f8             	mov    -0x8(%ebp),%edx
f01026da:	89 d0                	mov    %edx,%eax
f01026dc:	c1 e0 02             	shl    $0x2,%eax
f01026df:	01 d0                	add    %edx,%eax
f01026e1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01026e8:	01 d0                	add    %edx,%eax
f01026ea:	c1 e0 02             	shl    $0x2,%eax
f01026ed:	01 c8                	add    %ecx,%eax
f01026ef:	c7 40 48 54 ce 14 f0 	movl   $0xf014ce54,0x48(%eax)
//
void
env_init(void)
{	
	int iEnv = NENV-1;
	for(; iEnv >= 0; iEnv--)
f01026f6:	ff 4d f8             	decl   -0x8(%ebp)
f01026f9:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f01026fd:	0f 89 09 ff ff ff    	jns    f010260c <env_init+0x13>
	{
		envs[iEnv].env_status = ENV_FREE;
		envs[iEnv].env_id = 0;
		LIST_INSERT_HEAD(&env_free_list, &envs[iEnv]);	
	}
}
f0102703:	90                   	nop
f0102704:	83 c4 10             	add    $0x10,%esp
f0102707:	5b                   	pop    %ebx
f0102708:	5d                   	pop    %ebp
f0102709:	c3                   	ret    

f010270a <complete_environment_initialization>:

void complete_environment_initialization(struct Env* e)
{	
f010270a:	55                   	push   %ebp
f010270b:	89 e5                	mov    %esp,%ebp
f010270d:	83 ec 18             	sub    $0x18,%esp
	//VPT and UVPT map the env's own page table, with
	//different permissions.
	e->env_pgdir[PDX(VPT)]  = e->env_cr3 | PERM_PRESENT | PERM_WRITEABLE;
f0102710:	8b 45 08             	mov    0x8(%ebp),%eax
f0102713:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102716:	8d 90 fc 0e 00 00    	lea    0xefc(%eax),%edx
f010271c:	8b 45 08             	mov    0x8(%ebp),%eax
f010271f:	8b 40 60             	mov    0x60(%eax),%eax
f0102722:	83 c8 03             	or     $0x3,%eax
f0102725:	89 02                	mov    %eax,(%edx)
	e->env_pgdir[PDX(UVPT)] = e->env_cr3 | PERM_PRESENT | PERM_USER;
f0102727:	8b 45 08             	mov    0x8(%ebp),%eax
f010272a:	8b 40 5c             	mov    0x5c(%eax),%eax
f010272d:	8d 90 f4 0e 00 00    	lea    0xef4(%eax),%edx
f0102733:	8b 45 08             	mov    0x8(%ebp),%eax
f0102736:	8b 40 60             	mov    0x60(%eax),%eax
f0102739:	83 c8 05             	or     $0x5,%eax
f010273c:	89 02                	mov    %eax,(%edx)
	
	int32 generation;	
	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010273e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102741:	8b 40 4c             	mov    0x4c(%eax),%eax
f0102744:	05 00 10 00 00       	add    $0x1000,%eax
f0102749:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010274e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	if (generation <= 0)	// Don't create a negative env_id.
f0102751:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0102755:	7f 07                	jg     f010275e <complete_environment_initialization+0x54>
		generation = 1 << ENVGENSHIFT;
f0102757:	c7 45 f4 00 10 00 00 	movl   $0x1000,-0xc(%ebp)
	e->env_id = generation | (e - envs);
f010275e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102761:	8b 15 4c ce 14 f0    	mov    0xf014ce4c,%edx
f0102767:	29 d0                	sub    %edx,%eax
f0102769:	c1 f8 02             	sar    $0x2,%eax
f010276c:	89 c1                	mov    %eax,%ecx
f010276e:	89 c8                	mov    %ecx,%eax
f0102770:	c1 e0 02             	shl    $0x2,%eax
f0102773:	01 c8                	add    %ecx,%eax
f0102775:	c1 e0 07             	shl    $0x7,%eax
f0102778:	29 c8                	sub    %ecx,%eax
f010277a:	c1 e0 03             	shl    $0x3,%eax
f010277d:	01 c8                	add    %ecx,%eax
f010277f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f0102786:	01 d0                	add    %edx,%eax
f0102788:	c1 e0 02             	shl    $0x2,%eax
f010278b:	01 c8                	add    %ecx,%eax
f010278d:	c1 e0 03             	shl    $0x3,%eax
f0102790:	01 c8                	add    %ecx,%eax
f0102792:	89 c2                	mov    %eax,%edx
f0102794:	c1 e2 06             	shl    $0x6,%edx
f0102797:	29 c2                	sub    %eax,%edx
f0102799:	8d 04 12             	lea    (%edx,%edx,1),%eax
f010279c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f010279f:	8d 04 95 00 00 00 00 	lea    0x0(,%edx,4),%eax
f01027a6:	01 c2                	add    %eax,%edx
f01027a8:	8d 04 12             	lea    (%edx,%edx,1),%eax
f01027ab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
f01027ae:	89 d0                	mov    %edx,%eax
f01027b0:	f7 d8                	neg    %eax
f01027b2:	0b 45 f4             	or     -0xc(%ebp),%eax
f01027b5:	89 c2                	mov    %eax,%edx
f01027b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01027ba:	89 50 4c             	mov    %edx,0x4c(%eax)
	
	// Set the basic status variables.
	e->env_parent_id = 0;//parent_id;
f01027bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01027c0:	c7 40 50 00 00 00 00 	movl   $0x0,0x50(%eax)
	e->env_status = ENV_RUNNABLE;
f01027c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01027ca:	c7 40 54 01 00 00 00 	movl   $0x1,0x54(%eax)
	e->env_runs = 0;
f01027d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01027d4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01027db:	8b 45 08             	mov    0x8(%ebp),%eax
f01027de:	83 ec 04             	sub    $0x4,%esp
f01027e1:	6a 44                	push   $0x44
f01027e3:	6a 00                	push   $0x0
f01027e5:	50                   	push   %eax
f01027e6:	e8 38 1c 00 00       	call   f0104423 <memset>
f01027eb:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	e->env_tf.tf_ds = GD_UD | 3;
f01027ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01027f1:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	e->env_tf.tf_es = GD_UD | 3;
f01027f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01027fa:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	e->env_tf.tf_ss = GD_UD | 3;
f0102800:	8b 45 08             	mov    0x8(%ebp),%eax
f0102803:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	e->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102809:	8b 45 08             	mov    0x8(%ebp),%eax
f010280c:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	e->env_tf.tf_cs = GD_UT | 3;
f0102813:	8b 45 08             	mov    0x8(%ebp),%eax
f0102816:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	LIST_REMOVE(e);	
f010281c:	8b 45 08             	mov    0x8(%ebp),%eax
f010281f:	8b 40 44             	mov    0x44(%eax),%eax
f0102822:	85 c0                	test   %eax,%eax
f0102824:	74 0f                	je     f0102835 <complete_environment_initialization+0x12b>
f0102826:	8b 45 08             	mov    0x8(%ebp),%eax
f0102829:	8b 40 44             	mov    0x44(%eax),%eax
f010282c:	8b 55 08             	mov    0x8(%ebp),%edx
f010282f:	8b 52 48             	mov    0x48(%edx),%edx
f0102832:	89 50 48             	mov    %edx,0x48(%eax)
f0102835:	8b 45 08             	mov    0x8(%ebp),%eax
f0102838:	8b 40 48             	mov    0x48(%eax),%eax
f010283b:	8b 55 08             	mov    0x8(%ebp),%edx
f010283e:	8b 52 44             	mov    0x44(%edx),%edx
f0102841:	89 10                	mov    %edx,(%eax)
	return ;
f0102843:	90                   	nop
}
f0102844:	c9                   	leave  
f0102845:	c3                   	ret    

f0102846 <PROGRAM_SEGMENT_NEXT>:

struct ProgramSegment* PROGRAM_SEGMENT_NEXT(struct ProgramSegment* seg, uint8* ptr_program_start)
{
f0102846:	55                   	push   %ebp
f0102847:	89 e5                	mov    %esp,%ebp
f0102849:	83 ec 18             	sub    $0x18,%esp
	int index = (*seg).segment_id++;
f010284c:	8b 45 08             	mov    0x8(%ebp),%eax
f010284f:	8b 40 10             	mov    0x10(%eax),%eax
f0102852:	8d 48 01             	lea    0x1(%eax),%ecx
f0102855:	8b 55 08             	mov    0x8(%ebp),%edx
f0102858:	89 4a 10             	mov    %ecx,0x10(%edx)
f010285b:	89 45 f4             	mov    %eax,-0xc(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f010285e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102861:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102864:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102867:	8b 00                	mov    (%eax),%eax
f0102869:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f010286e:	74 17                	je     f0102887 <PROGRAM_SEGMENT_NEXT+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102870:	83 ec 04             	sub    $0x4,%esp
f0102873:	68 83 56 10 f0       	push   $0xf0105683
f0102878:	68 48 01 00 00       	push   $0x148
f010287d:	68 dd 55 10 f0       	push   $0xf01055dd
f0102882:	e8 a7 d8 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f0102887:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010288a:	8b 50 1c             	mov    0x1c(%eax),%edx
f010288d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102890:	01 d0                	add    %edx,%eax
f0102892:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (ph[(*seg).segment_id].p_type != ELF_PROG_LOAD && ((*seg).segment_id < pELFHDR->e_phnum)) (*seg).segment_id++;	
f0102895:	eb 0f                	jmp    f01028a6 <PROGRAM_SEGMENT_NEXT+0x60>
f0102897:	8b 45 08             	mov    0x8(%ebp),%eax
f010289a:	8b 40 10             	mov    0x10(%eax),%eax
f010289d:	8d 50 01             	lea    0x1(%eax),%edx
f01028a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01028a3:	89 50 10             	mov    %edx,0x10(%eax)
f01028a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01028a9:	8b 40 10             	mov    0x10(%eax),%eax
f01028ac:	c1 e0 05             	shl    $0x5,%eax
f01028af:	89 c2                	mov    %eax,%edx
f01028b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01028b4:	01 d0                	add    %edx,%eax
f01028b6:	8b 00                	mov    (%eax),%eax
f01028b8:	83 f8 01             	cmp    $0x1,%eax
f01028bb:	74 13                	je     f01028d0 <PROGRAM_SEGMENT_NEXT+0x8a>
f01028bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01028c0:	8b 50 10             	mov    0x10(%eax),%edx
f01028c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01028c6:	8b 40 2c             	mov    0x2c(%eax),%eax
f01028c9:	0f b7 c0             	movzwl %ax,%eax
f01028cc:	39 c2                	cmp    %eax,%edx
f01028ce:	72 c7                	jb     f0102897 <PROGRAM_SEGMENT_NEXT+0x51>
	index = (*seg).segment_id;
f01028d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01028d3:	8b 40 10             	mov    0x10(%eax),%eax
f01028d6:	89 45 f4             	mov    %eax,-0xc(%ebp)

	if(index < pELFHDR->e_phnum)
f01028d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01028dc:	8b 40 2c             	mov    0x2c(%eax),%eax
f01028df:	0f b7 c0             	movzwl %ax,%eax
f01028e2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
f01028e5:	7e 63                	jle    f010294a <PROGRAM_SEGMENT_NEXT+0x104>
	{
		(*seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f01028e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01028ea:	c1 e0 05             	shl    $0x5,%eax
f01028ed:	89 c2                	mov    %eax,%edx
f01028ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01028f2:	01 d0                	add    %edx,%eax
f01028f4:	8b 50 04             	mov    0x4(%eax),%edx
f01028f7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01028fa:	01 c2                	add    %eax,%edx
f01028fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01028ff:	89 10                	mov    %edx,(%eax)
		(*seg).size_in_memory =  ph[index].p_memsz;
f0102901:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102904:	c1 e0 05             	shl    $0x5,%eax
f0102907:	89 c2                	mov    %eax,%edx
f0102909:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010290c:	01 d0                	add    %edx,%eax
f010290e:	8b 50 14             	mov    0x14(%eax),%edx
f0102911:	8b 45 08             	mov    0x8(%ebp),%eax
f0102914:	89 50 08             	mov    %edx,0x8(%eax)
		(*seg).size_in_file = ph[index].p_filesz;
f0102917:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010291a:	c1 e0 05             	shl    $0x5,%eax
f010291d:	89 c2                	mov    %eax,%edx
f010291f:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102922:	01 d0                	add    %edx,%eax
f0102924:	8b 50 10             	mov    0x10(%eax),%edx
f0102927:	8b 45 08             	mov    0x8(%ebp),%eax
f010292a:	89 50 04             	mov    %edx,0x4(%eax)
		(*seg).virtual_address = (uint8*)ph[index].p_va;
f010292d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102930:	c1 e0 05             	shl    $0x5,%eax
f0102933:	89 c2                	mov    %eax,%edx
f0102935:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102938:	01 d0                	add    %edx,%eax
f010293a:	8b 40 08             	mov    0x8(%eax),%eax
f010293d:	89 c2                	mov    %eax,%edx
f010293f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102942:	89 50 0c             	mov    %edx,0xc(%eax)
		return seg;
f0102945:	8b 45 08             	mov    0x8(%ebp),%eax
f0102948:	eb 05                	jmp    f010294f <PROGRAM_SEGMENT_NEXT+0x109>
	}
	return 0;
f010294a:	b8 00 00 00 00       	mov    $0x0,%eax
}	
f010294f:	c9                   	leave  
f0102950:	c3                   	ret    

f0102951 <PROGRAM_SEGMENT_FIRST>:

struct ProgramSegment PROGRAM_SEGMENT_FIRST( uint8* ptr_program_start)
{
f0102951:	55                   	push   %ebp
f0102952:	89 e5                	mov    %esp,%ebp
f0102954:	57                   	push   %edi
f0102955:	56                   	push   %esi
f0102956:	53                   	push   %ebx
f0102957:	83 ec 2c             	sub    $0x2c,%esp
	struct ProgramSegment seg;
	seg.segment_id = 0;
f010295a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

	struct Proghdr *ph, *eph; 
	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102961:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102964:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010296a:	8b 00                	mov    (%eax),%eax
f010296c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102971:	74 17                	je     f010298a <PROGRAM_SEGMENT_FIRST+0x39>
		panic("Matafa2nash 3ala Keda"); 
f0102973:	83 ec 04             	sub    $0x4,%esp
f0102976:	68 83 56 10 f0       	push   $0xf0105683
f010297b:	68 61 01 00 00       	push   $0x161
f0102980:	68 dd 55 10 f0       	push   $0xf01055dd
f0102985:	e8 a4 d7 ff ff       	call   f010012e <_panic>
	ph = (struct Proghdr *) ( ((uint8 *) ptr_program_start) + pELFHDR->e_phoff);
f010298a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010298d:	8b 50 1c             	mov    0x1c(%eax),%edx
f0102990:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102993:	01 d0                	add    %edx,%eax
f0102995:	89 45 e0             	mov    %eax,-0x20(%ebp)
	while (ph[(seg).segment_id].p_type != ELF_PROG_LOAD && ((seg).segment_id < pELFHDR->e_phnum)) (seg).segment_id++;
f0102998:	eb 07                	jmp    f01029a1 <PROGRAM_SEGMENT_FIRST+0x50>
f010299a:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010299d:	40                   	inc    %eax
f010299e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01029a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01029a4:	c1 e0 05             	shl    $0x5,%eax
f01029a7:	89 c2                	mov    %eax,%edx
f01029a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029ac:	01 d0                	add    %edx,%eax
f01029ae:	8b 00                	mov    (%eax),%eax
f01029b0:	83 f8 01             	cmp    $0x1,%eax
f01029b3:	74 10                	je     f01029c5 <PROGRAM_SEGMENT_FIRST+0x74>
f01029b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01029b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029bb:	8b 40 2c             	mov    0x2c(%eax),%eax
f01029be:	0f b7 c0             	movzwl %ax,%eax
f01029c1:	39 c2                	cmp    %eax,%edx
f01029c3:	72 d5                	jb     f010299a <PROGRAM_SEGMENT_FIRST+0x49>
	int index = (seg).segment_id;
f01029c5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01029c8:	89 45 dc             	mov    %eax,-0x24(%ebp)

	if(index < pELFHDR->e_phnum)
f01029cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01029ce:	8b 40 2c             	mov    0x2c(%eax),%eax
f01029d1:	0f b7 c0             	movzwl %ax,%eax
f01029d4:	3b 45 dc             	cmp    -0x24(%ebp),%eax
f01029d7:	7e 68                	jle    f0102a41 <PROGRAM_SEGMENT_FIRST+0xf0>
	{	
		(seg).ptr_start = (uint8 *) ptr_program_start + ph[index].p_offset;
f01029d9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029dc:	c1 e0 05             	shl    $0x5,%eax
f01029df:	89 c2                	mov    %eax,%edx
f01029e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029e4:	01 d0                	add    %edx,%eax
f01029e6:	8b 50 04             	mov    0x4(%eax),%edx
f01029e9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029ec:	01 d0                	add    %edx,%eax
f01029ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
		(seg).size_in_memory =  ph[index].p_memsz;
f01029f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01029f4:	c1 e0 05             	shl    $0x5,%eax
f01029f7:	89 c2                	mov    %eax,%edx
f01029f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01029fc:	01 d0                	add    %edx,%eax
f01029fe:	8b 40 14             	mov    0x14(%eax),%eax
f0102a01:	89 45 d0             	mov    %eax,-0x30(%ebp)
		(seg).size_in_file = ph[index].p_filesz;
f0102a04:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a07:	c1 e0 05             	shl    $0x5,%eax
f0102a0a:	89 c2                	mov    %eax,%edx
f0102a0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a0f:	01 d0                	add    %edx,%eax
f0102a11:	8b 40 10             	mov    0x10(%eax),%eax
f0102a14:	89 45 cc             	mov    %eax,-0x34(%ebp)
		(seg).virtual_address = (uint8*)ph[index].p_va;
f0102a17:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102a1a:	c1 e0 05             	shl    $0x5,%eax
f0102a1d:	89 c2                	mov    %eax,%edx
f0102a1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102a22:	01 d0                	add    %edx,%eax
f0102a24:	8b 40 08             	mov    0x8(%eax),%eax
f0102a27:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		return seg;
f0102a2a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a2d:	89 c3                	mov    %eax,%ebx
f0102a2f:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102a32:	ba 05 00 00 00       	mov    $0x5,%edx
f0102a37:	89 df                	mov    %ebx,%edi
f0102a39:	89 c6                	mov    %eax,%esi
f0102a3b:	89 d1                	mov    %edx,%ecx
f0102a3d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102a3f:	eb 1c                	jmp    f0102a5d <PROGRAM_SEGMENT_FIRST+0x10c>
	}
	seg.segment_id = -1;
f0102a41:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
	return seg;
f0102a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a4b:	89 c3                	mov    %eax,%ebx
f0102a4d:	8d 45 c8             	lea    -0x38(%ebp),%eax
f0102a50:	ba 05 00 00 00       	mov    $0x5,%edx
f0102a55:	89 df                	mov    %ebx,%edi
f0102a57:	89 c6                	mov    %eax,%esi
f0102a59:	89 d1                	mov    %edx,%ecx
f0102a5b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
}
f0102a5d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a60:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a63:	5b                   	pop    %ebx
f0102a64:	5e                   	pop    %esi
f0102a65:	5f                   	pop    %edi
f0102a66:	5d                   	pop    %ebp
f0102a67:	c2 04 00             	ret    $0x4

f0102a6a <get_user_program_info>:

struct UserProgramInfo* get_user_program_info(char* user_program_name)
{
f0102a6a:	55                   	push   %ebp
f0102a6b:	89 e5                	mov    %esp,%ebp
f0102a6d:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102a70:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102a77:	eb 23                	jmp    f0102a9c <get_user_program_info+0x32>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
f0102a79:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102a7c:	c1 e0 04             	shl    $0x4,%eax
f0102a7f:	05 a0 a5 11 f0       	add    $0xf011a5a0,%eax
f0102a84:	8b 00                	mov    (%eax),%eax
f0102a86:	83 ec 08             	sub    $0x8,%esp
f0102a89:	50                   	push   %eax
f0102a8a:	ff 75 08             	pushl  0x8(%ebp)
f0102a8d:	e8 af 18 00 00       	call   f0104341 <strcmp>
f0102a92:	83 c4 10             	add    $0x10,%esp
f0102a95:	85 c0                	test   %eax,%eax
f0102a97:	74 0f                	je     f0102aa8 <get_user_program_info+0x3e>
}

struct UserProgramInfo* get_user_program_info(char* user_program_name)
{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102a99:	ff 45 f4             	incl   -0xc(%ebp)
f0102a9c:	a1 f4 a5 11 f0       	mov    0xf011a5f4,%eax
f0102aa1:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102aa4:	7c d3                	jl     f0102a79 <get_user_program_info+0xf>
f0102aa6:	eb 01                	jmp    f0102aa9 <get_user_program_info+0x3f>
		if (strcmp(user_program_name, userPrograms[i].name) == 0)
			break;
f0102aa8:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102aa9:	a1 f4 a5 11 f0       	mov    0xf011a5f4,%eax
f0102aae:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102ab1:	75 1a                	jne    f0102acd <get_user_program_info+0x63>
	{
		cprintf("Unknown user program '%s'\n", user_program_name);
f0102ab3:	83 ec 08             	sub    $0x8,%esp
f0102ab6:	ff 75 08             	pushl  0x8(%ebp)
f0102ab9:	68 99 56 10 f0       	push   $0xf0105699
f0102abe:	e8 7e 02 00 00       	call   f0102d41 <cprintf>
f0102ac3:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102ac6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102acb:	eb 0b                	jmp    f0102ad8 <get_user_program_info+0x6e>
	}

	return &userPrograms[i];
f0102acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ad0:	c1 e0 04             	shl    $0x4,%eax
f0102ad3:	05 a0 a5 11 f0       	add    $0xf011a5a0,%eax
}
f0102ad8:	c9                   	leave  
f0102ad9:	c3                   	ret    

f0102ada <get_user_program_info_by_env>:

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
{
f0102ada:	55                   	push   %ebp
f0102adb:	89 e5                	mov    %esp,%ebp
f0102add:	83 ec 18             	sub    $0x18,%esp
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102ae0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
f0102ae7:	eb 15                	jmp    f0102afe <get_user_program_info_by_env+0x24>
		if (e== userPrograms[i].environment)
f0102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102aec:	c1 e0 04             	shl    $0x4,%eax
f0102aef:	05 ac a5 11 f0       	add    $0xf011a5ac,%eax
f0102af4:	8b 00                	mov    (%eax),%eax
f0102af6:	3b 45 08             	cmp    0x8(%ebp),%eax
f0102af9:	74 0f                	je     f0102b0a <get_user_program_info_by_env+0x30>
}

struct UserProgramInfo* get_user_program_info_by_env(struct Env* e)
{
	int i;
	for (i = 0; i < NUM_USER_PROGS; i++) {
f0102afb:	ff 45 f4             	incl   -0xc(%ebp)
f0102afe:	a1 f4 a5 11 f0       	mov    0xf011a5f4,%eax
f0102b03:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102b06:	7c e1                	jl     f0102ae9 <get_user_program_info_by_env+0xf>
f0102b08:	eb 01                	jmp    f0102b0b <get_user_program_info_by_env+0x31>
		if (e== userPrograms[i].environment)
			break;
f0102b0a:	90                   	nop
	}
	if(i==NUM_USER_PROGS) 
f0102b0b:	a1 f4 a5 11 f0       	mov    0xf011a5f4,%eax
f0102b10:	39 45 f4             	cmp    %eax,-0xc(%ebp)
f0102b13:	75 17                	jne    f0102b2c <get_user_program_info_by_env+0x52>
	{
		cprintf("Unknown user program \n");
f0102b15:	83 ec 0c             	sub    $0xc,%esp
f0102b18:	68 b4 56 10 f0       	push   $0xf01056b4
f0102b1d:	e8 1f 02 00 00       	call   f0102d41 <cprintf>
f0102b22:	83 c4 10             	add    $0x10,%esp
		return 0;
f0102b25:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b2a:	eb 0b                	jmp    f0102b37 <get_user_program_info_by_env+0x5d>
	}

	return &userPrograms[i];
f0102b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b2f:	c1 e0 04             	shl    $0x4,%eax
f0102b32:	05 a0 a5 11 f0       	add    $0xf011a5a0,%eax
}
f0102b37:	c9                   	leave  
f0102b38:	c3                   	ret    

f0102b39 <set_environment_entry_point>:

void set_environment_entry_point(struct UserProgramInfo* ptr_user_program)
{
f0102b39:	55                   	push   %ebp
f0102b3a:	89 e5                	mov    %esp,%ebp
f0102b3c:	83 ec 18             	sub    $0x18,%esp
	uint8* ptr_program_start=ptr_user_program->ptr_start;
f0102b3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b42:	8b 40 08             	mov    0x8(%eax),%eax
f0102b45:	89 45 f4             	mov    %eax,-0xc(%ebp)
	struct Env* e = ptr_user_program->environment;
f0102b48:	8b 45 08             	mov    0x8(%ebp),%eax
f0102b4b:	8b 40 0c             	mov    0xc(%eax),%eax
f0102b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)

	struct Elf * pELFHDR = (struct Elf *)ptr_program_start ; 
f0102b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102b54:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (pELFHDR->e_magic != ELF_MAGIC) 
f0102b57:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b5a:	8b 00                	mov    (%eax),%eax
f0102b5c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
f0102b61:	74 17                	je     f0102b7a <set_environment_entry_point+0x41>
		panic("Matafa2nash 3ala Keda"); 
f0102b63:	83 ec 04             	sub    $0x4,%esp
f0102b66:	68 83 56 10 f0       	push   $0xf0105683
f0102b6b:	68 99 01 00 00       	push   $0x199
f0102b70:	68 dd 55 10 f0       	push   $0xf01055dd
f0102b75:	e8 b4 d5 ff ff       	call   f010012e <_panic>
	e->env_tf.tf_eip = (uint32*)pELFHDR->e_entry ;
f0102b7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102b7d:	8b 40 18             	mov    0x18(%eax),%eax
f0102b80:	89 c2                	mov    %eax,%edx
f0102b82:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102b85:	89 50 30             	mov    %edx,0x30(%eax)
}
f0102b88:	90                   	nop
f0102b89:	c9                   	leave  
f0102b8a:	c3                   	ret    

f0102b8b <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e) 
{
f0102b8b:	55                   	push   %ebp
f0102b8c:	89 e5                	mov    %esp,%ebp
f0102b8e:	83 ec 08             	sub    $0x8,%esp
	env_free(e);
f0102b91:	83 ec 0c             	sub    $0xc,%esp
f0102b94:	ff 75 08             	pushl  0x8(%ebp)
f0102b97:	e8 40 fa ff ff       	call   f01025dc <env_free>
f0102b9c:	83 c4 10             	add    $0x10,%esp

	//cprintf("Destroyed the only environment - nothing more to do!\n");
	while (1)
		run_command_prompt();
f0102b9f:	e8 ad dd ff ff       	call   f0100951 <run_command_prompt>
f0102ba4:	eb f9                	jmp    f0102b9f <env_destroy+0x14>

f0102ba6 <env_run_cmd_prmpt>:
}

void env_run_cmd_prmpt()
{
f0102ba6:	55                   	push   %ebp
f0102ba7:	89 e5                	mov    %esp,%ebp
f0102ba9:	83 ec 18             	sub    $0x18,%esp
	struct UserProgramInfo* upi= get_user_program_info_by_env(curenv);	
f0102bac:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102bb1:	83 ec 0c             	sub    $0xc,%esp
f0102bb4:	50                   	push   %eax
f0102bb5:	e8 20 ff ff ff       	call   f0102ada <get_user_program_info_by_env>
f0102bba:	83 c4 10             	add    $0x10,%esp
f0102bbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&curenv->env_tf, 0, sizeof(curenv->env_tf));
f0102bc0:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102bc5:	83 ec 04             	sub    $0x4,%esp
f0102bc8:	6a 44                	push   $0x44
f0102bca:	6a 00                	push   $0x0
f0102bcc:	50                   	push   %eax
f0102bcd:	e8 51 18 00 00       	call   f0104423 <memset>
f0102bd2:	83 c4 10             	add    $0x10,%esp
	// GD_UD is the user data segment selector in the GDT, and 
	// GD_UT is the user text segment selector (see inc/memlayout.h).
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.
	
	curenv->env_tf.tf_ds = GD_UD | 3;
f0102bd5:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102bda:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
	curenv->env_tf.tf_es = GD_UD | 3;
f0102be0:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102be5:	66 c7 40 20 23 00    	movw   $0x23,0x20(%eax)
	curenv->env_tf.tf_ss = GD_UD | 3;
f0102beb:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102bf0:	66 c7 40 40 23 00    	movw   $0x23,0x40(%eax)
	curenv->env_tf.tf_esp = (uint32*)USTACKTOP;
f0102bf6:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102bfb:	c7 40 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%eax)
	curenv->env_tf.tf_cs = GD_UT | 3;
f0102c02:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0102c07:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
	set_environment_entry_point(upi);
f0102c0d:	83 ec 0c             	sub    $0xc,%esp
f0102c10:	ff 75 f4             	pushl  -0xc(%ebp)
f0102c13:	e8 21 ff ff ff       	call   f0102b39 <set_environment_entry_point>
f0102c18:	83 c4 10             	add    $0x10,%esp
	
	lcr3(K_PHYSICAL_ADDRESS(ptr_page_directory));
f0102c1b:	a1 e4 d6 14 f0       	mov    0xf014d6e4,%eax
f0102c20:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c23:	81 7d f0 ff ff ff ef 	cmpl   $0xefffffff,-0x10(%ebp)
f0102c2a:	77 17                	ja     f0102c43 <env_run_cmd_prmpt+0x9d>
f0102c2c:	ff 75 f0             	pushl  -0x10(%ebp)
f0102c2f:	68 cc 56 10 f0       	push   $0xf01056cc
f0102c34:	68 c4 01 00 00       	push   $0x1c4
f0102c39:	68 dd 55 10 f0       	push   $0xf01055dd
f0102c3e:	e8 eb d4 ff ff       	call   f010012e <_panic>
f0102c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c46:	05 00 00 00 10       	add    $0x10000000,%eax
f0102c4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102c4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102c51:	0f 22 d8             	mov    %eax,%cr3
	
	curenv = NULL;
f0102c54:	c7 05 50 ce 14 f0 00 	movl   $0x0,0xf014ce50
f0102c5b:	00 00 00 
	
	while (1)
		run_command_prompt();
f0102c5e:	e8 ee dc ff ff       	call   f0100951 <run_command_prompt>
f0102c63:	eb f9                	jmp    f0102c5e <env_run_cmd_prmpt+0xb8>

f0102c65 <env_pop_tf>:
// This exits the kernel and starts executing some environment's code.
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102c65:	55                   	push   %ebp
f0102c66:	89 e5                	mov    %esp,%ebp
f0102c68:	83 ec 08             	sub    $0x8,%esp
	__asm __volatile("movl %0,%%esp\n"
f0102c6b:	8b 65 08             	mov    0x8(%ebp),%esp
f0102c6e:	61                   	popa   
f0102c6f:	07                   	pop    %es
f0102c70:	1f                   	pop    %ds
f0102c71:	83 c4 08             	add    $0x8,%esp
f0102c74:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102c75:	83 ec 04             	sub    $0x4,%esp
f0102c78:	68 fd 56 10 f0       	push   $0xf01056fd
f0102c7d:	68 db 01 00 00       	push   $0x1db
f0102c82:	68 dd 55 10 f0       	push   $0xf01055dd
f0102c87:	e8 a2 d4 ff ff       	call   f010012e <_panic>

f0102c8c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102c8c:	55                   	push   %ebp
f0102c8d:	89 e5                	mov    %esp,%ebp
f0102c8f:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0102c92:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c95:	0f b6 c0             	movzbl %al,%eax
f0102c98:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0102c9f:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102ca2:	8a 45 f6             	mov    -0xa(%ebp),%al
f0102ca5:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0102ca8:	ee                   	out    %al,(%dx)
f0102ca9:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)

static __inline uint8
inb(int port)
{
	uint8 data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102cb0:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0102cb3:	89 c2                	mov    %eax,%edx
f0102cb5:	ec                   	in     (%dx),%al
f0102cb6:	88 45 f7             	mov    %al,-0x9(%ebp)
	return data;
f0102cb9:	8a 45 f7             	mov    -0x9(%ebp),%al
	return inb(IO_RTC+1);
f0102cbc:	0f b6 c0             	movzbl %al,%eax
}
f0102cbf:	c9                   	leave  
f0102cc0:	c3                   	ret    

f0102cc1 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102cc1:	55                   	push   %ebp
f0102cc2:	89 e5                	mov    %esp,%ebp
f0102cc4:	83 ec 10             	sub    $0x10,%esp
	outb(IO_RTC, reg);
f0102cc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cca:	0f b6 c0             	movzbl %al,%eax
f0102ccd:	c7 45 fc 70 00 00 00 	movl   $0x70,-0x4(%ebp)
f0102cd4:	88 45 f6             	mov    %al,-0xa(%ebp)
}

static __inline void
outb(int port, uint8 data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102cd7:	8a 45 f6             	mov    -0xa(%ebp),%al
f0102cda:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0102cdd:	ee                   	out    %al,(%dx)
	outb(IO_RTC+1, datum);
f0102cde:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ce1:	0f b6 c0             	movzbl %al,%eax
f0102ce4:	c7 45 f8 71 00 00 00 	movl   $0x71,-0x8(%ebp)
f0102ceb:	88 45 f7             	mov    %al,-0x9(%ebp)
f0102cee:	8a 45 f7             	mov    -0x9(%ebp),%al
f0102cf1:	8b 55 f8             	mov    -0x8(%ebp),%edx
f0102cf4:	ee                   	out    %al,(%dx)
}
f0102cf5:	90                   	nop
f0102cf6:	c9                   	leave  
f0102cf7:	c3                   	ret    

f0102cf8 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102cf8:	55                   	push   %ebp
f0102cf9:	89 e5                	mov    %esp,%ebp
f0102cfb:	83 ec 08             	sub    $0x8,%esp
	cputchar(ch);
f0102cfe:	83 ec 0c             	sub    $0xc,%esp
f0102d01:	ff 75 08             	pushl  0x8(%ebp)
f0102d04:	e8 0e dc ff ff       	call   f0100917 <cputchar>
f0102d09:	83 c4 10             	add    $0x10,%esp
	*cnt++;
f0102d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d0f:	83 c0 04             	add    $0x4,%eax
f0102d12:	89 45 0c             	mov    %eax,0xc(%ebp)
}
f0102d15:	90                   	nop
f0102d16:	c9                   	leave  
f0102d17:	c3                   	ret    

f0102d18 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d18:	55                   	push   %ebp
f0102d19:	89 e5                	mov    %esp,%ebp
f0102d1b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102d1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d25:	ff 75 0c             	pushl  0xc(%ebp)
f0102d28:	ff 75 08             	pushl  0x8(%ebp)
f0102d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d2e:	50                   	push   %eax
f0102d2f:	68 f8 2c 10 f0       	push   $0xf0102cf8
f0102d34:	e8 56 0f 00 00       	call   f0103c8f <vprintfmt>
f0102d39:	83 c4 10             	add    $0x10,%esp
	return cnt;
f0102d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0102d3f:	c9                   	leave  
f0102d40:	c3                   	ret    

f0102d41 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d41:	55                   	push   %ebp
f0102d42:	89 e5                	mov    %esp,%ebp
f0102d44:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d47:	8d 45 0c             	lea    0xc(%ebp),%eax
f0102d4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
f0102d4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d50:	83 ec 08             	sub    $0x8,%esp
f0102d53:	ff 75 f4             	pushl  -0xc(%ebp)
f0102d56:	50                   	push   %eax
f0102d57:	e8 bc ff ff ff       	call   f0102d18 <vcprintf>
f0102d5c:	83 c4 10             	add    $0x10,%esp
f0102d5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
f0102d62:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0102d65:	c9                   	leave  
f0102d66:	c3                   	ret    

f0102d67 <trapname>:
};
extern  void (*PAGE_FAULT)();
extern  void (*SYSCALL_HANDLER)();

static const char *trapname(int trapno)
{
f0102d67:	55                   	push   %ebp
f0102d68:	89 e5                	mov    %esp,%ebp
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0102d6a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d6d:	83 f8 13             	cmp    $0x13,%eax
f0102d70:	77 0c                	ja     f0102d7e <trapname+0x17>
		return excnames[trapno];
f0102d72:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d75:	8b 04 85 40 5a 10 f0 	mov    -0xfefa5c0(,%eax,4),%eax
f0102d7c:	eb 12                	jmp    f0102d90 <trapname+0x29>
	if (trapno == T_SYSCALL)
f0102d7e:	83 7d 08 30          	cmpl   $0x30,0x8(%ebp)
f0102d82:	75 07                	jne    f0102d8b <trapname+0x24>
		return "System call";
f0102d84:	b8 20 57 10 f0       	mov    $0xf0105720,%eax
f0102d89:	eb 05                	jmp    f0102d90 <trapname+0x29>
	return "(unknown trap)";
f0102d8b:	b8 2c 57 10 f0       	mov    $0xf010572c,%eax
}
f0102d90:	5d                   	pop    %ebp
f0102d91:	c3                   	ret    

f0102d92 <idt_init>:


void
idt_init(void)
{
f0102d92:	55                   	push   %ebp
f0102d93:	89 e5                	mov    %esp,%ebp
f0102d95:	83 ec 10             	sub    $0x10,%esp
	extern struct Segdesc gdt[];
	
	// LAB 3: Your code here.
	//initialize idt
	SETGATE(idt[T_PGFLT], 0, GD_KT , &PAGE_FAULT, 0) ;
f0102d98:	b8 f0 32 10 f0       	mov    $0xf01032f0,%eax
f0102d9d:	66 a3 d0 ce 14 f0    	mov    %ax,0xf014ced0
f0102da3:	66 c7 05 d2 ce 14 f0 	movw   $0x8,0xf014ced2
f0102daa:	08 00 
f0102dac:	a0 d4 ce 14 f0       	mov    0xf014ced4,%al
f0102db1:	83 e0 e0             	and    $0xffffffe0,%eax
f0102db4:	a2 d4 ce 14 f0       	mov    %al,0xf014ced4
f0102db9:	a0 d4 ce 14 f0       	mov    0xf014ced4,%al
f0102dbe:	83 e0 1f             	and    $0x1f,%eax
f0102dc1:	a2 d4 ce 14 f0       	mov    %al,0xf014ced4
f0102dc6:	a0 d5 ce 14 f0       	mov    0xf014ced5,%al
f0102dcb:	83 e0 f0             	and    $0xfffffff0,%eax
f0102dce:	83 c8 0e             	or     $0xe,%eax
f0102dd1:	a2 d5 ce 14 f0       	mov    %al,0xf014ced5
f0102dd6:	a0 d5 ce 14 f0       	mov    0xf014ced5,%al
f0102ddb:	83 e0 ef             	and    $0xffffffef,%eax
f0102dde:	a2 d5 ce 14 f0       	mov    %al,0xf014ced5
f0102de3:	a0 d5 ce 14 f0       	mov    0xf014ced5,%al
f0102de8:	83 e0 9f             	and    $0xffffff9f,%eax
f0102deb:	a2 d5 ce 14 f0       	mov    %al,0xf014ced5
f0102df0:	a0 d5 ce 14 f0       	mov    0xf014ced5,%al
f0102df5:	83 c8 80             	or     $0xffffff80,%eax
f0102df8:	a2 d5 ce 14 f0       	mov    %al,0xf014ced5
f0102dfd:	b8 f0 32 10 f0       	mov    $0xf01032f0,%eax
f0102e02:	c1 e8 10             	shr    $0x10,%eax
f0102e05:	66 a3 d6 ce 14 f0    	mov    %ax,0xf014ced6
	SETGATE(idt[T_SYSCALL], 0, GD_KT , &SYSCALL_HANDLER, 3) ;
f0102e0b:	b8 f4 32 10 f0       	mov    $0xf01032f4,%eax
f0102e10:	66 a3 e0 cf 14 f0    	mov    %ax,0xf014cfe0
f0102e16:	66 c7 05 e2 cf 14 f0 	movw   $0x8,0xf014cfe2
f0102e1d:	08 00 
f0102e1f:	a0 e4 cf 14 f0       	mov    0xf014cfe4,%al
f0102e24:	83 e0 e0             	and    $0xffffffe0,%eax
f0102e27:	a2 e4 cf 14 f0       	mov    %al,0xf014cfe4
f0102e2c:	a0 e4 cf 14 f0       	mov    0xf014cfe4,%al
f0102e31:	83 e0 1f             	and    $0x1f,%eax
f0102e34:	a2 e4 cf 14 f0       	mov    %al,0xf014cfe4
f0102e39:	a0 e5 cf 14 f0       	mov    0xf014cfe5,%al
f0102e3e:	83 e0 f0             	and    $0xfffffff0,%eax
f0102e41:	83 c8 0e             	or     $0xe,%eax
f0102e44:	a2 e5 cf 14 f0       	mov    %al,0xf014cfe5
f0102e49:	a0 e5 cf 14 f0       	mov    0xf014cfe5,%al
f0102e4e:	83 e0 ef             	and    $0xffffffef,%eax
f0102e51:	a2 e5 cf 14 f0       	mov    %al,0xf014cfe5
f0102e56:	a0 e5 cf 14 f0       	mov    0xf014cfe5,%al
f0102e5b:	83 c8 60             	or     $0x60,%eax
f0102e5e:	a2 e5 cf 14 f0       	mov    %al,0xf014cfe5
f0102e63:	a0 e5 cf 14 f0       	mov    0xf014cfe5,%al
f0102e68:	83 c8 80             	or     $0xffffff80,%eax
f0102e6b:	a2 e5 cf 14 f0       	mov    %al,0xf014cfe5
f0102e70:	b8 f4 32 10 f0       	mov    $0xf01032f4,%eax
f0102e75:	c1 e8 10             	shr    $0x10,%eax
f0102e78:	66 a3 e6 cf 14 f0    	mov    %ax,0xf014cfe6

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KERNEL_STACK_TOP;
f0102e7e:	c7 05 64 d6 14 f0 00 	movl   $0xefc00000,0xf014d664
f0102e85:	00 c0 ef 
	ts.ts_ss0 = GD_KD;
f0102e88:	66 c7 05 68 d6 14 f0 	movw   $0x10,0xf014d668
f0102e8f:	10 00 

	// Initialize the TSS field of the gdt.
	gdt[GD_TSS >> 3] = SEG16(STS_T32A, (uint32) (&ts),
f0102e91:	66 c7 05 88 a5 11 f0 	movw   $0x68,0xf011a588
f0102e98:	68 00 
f0102e9a:	b8 60 d6 14 f0       	mov    $0xf014d660,%eax
f0102e9f:	66 a3 8a a5 11 f0    	mov    %ax,0xf011a58a
f0102ea5:	b8 60 d6 14 f0       	mov    $0xf014d660,%eax
f0102eaa:	c1 e8 10             	shr    $0x10,%eax
f0102ead:	a2 8c a5 11 f0       	mov    %al,0xf011a58c
f0102eb2:	a0 8d a5 11 f0       	mov    0xf011a58d,%al
f0102eb7:	83 e0 f0             	and    $0xfffffff0,%eax
f0102eba:	83 c8 09             	or     $0x9,%eax
f0102ebd:	a2 8d a5 11 f0       	mov    %al,0xf011a58d
f0102ec2:	a0 8d a5 11 f0       	mov    0xf011a58d,%al
f0102ec7:	83 c8 10             	or     $0x10,%eax
f0102eca:	a2 8d a5 11 f0       	mov    %al,0xf011a58d
f0102ecf:	a0 8d a5 11 f0       	mov    0xf011a58d,%al
f0102ed4:	83 e0 9f             	and    $0xffffff9f,%eax
f0102ed7:	a2 8d a5 11 f0       	mov    %al,0xf011a58d
f0102edc:	a0 8d a5 11 f0       	mov    0xf011a58d,%al
f0102ee1:	83 c8 80             	or     $0xffffff80,%eax
f0102ee4:	a2 8d a5 11 f0       	mov    %al,0xf011a58d
f0102ee9:	a0 8e a5 11 f0       	mov    0xf011a58e,%al
f0102eee:	83 e0 f0             	and    $0xfffffff0,%eax
f0102ef1:	a2 8e a5 11 f0       	mov    %al,0xf011a58e
f0102ef6:	a0 8e a5 11 f0       	mov    0xf011a58e,%al
f0102efb:	83 e0 ef             	and    $0xffffffef,%eax
f0102efe:	a2 8e a5 11 f0       	mov    %al,0xf011a58e
f0102f03:	a0 8e a5 11 f0       	mov    0xf011a58e,%al
f0102f08:	83 e0 df             	and    $0xffffffdf,%eax
f0102f0b:	a2 8e a5 11 f0       	mov    %al,0xf011a58e
f0102f10:	a0 8e a5 11 f0       	mov    0xf011a58e,%al
f0102f15:	83 c8 40             	or     $0x40,%eax
f0102f18:	a2 8e a5 11 f0       	mov    %al,0xf011a58e
f0102f1d:	a0 8e a5 11 f0       	mov    0xf011a58e,%al
f0102f22:	83 e0 7f             	and    $0x7f,%eax
f0102f25:	a2 8e a5 11 f0       	mov    %al,0xf011a58e
f0102f2a:	b8 60 d6 14 f0       	mov    $0xf014d660,%eax
f0102f2f:	c1 e8 18             	shr    $0x18,%eax
f0102f32:	a2 8f a5 11 f0       	mov    %al,0xf011a58f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS >> 3].sd_s = 0;
f0102f37:	a0 8d a5 11 f0       	mov    0xf011a58d,%al
f0102f3c:	83 e0 ef             	and    $0xffffffef,%eax
f0102f3f:	a2 8d a5 11 f0       	mov    %al,0xf011a58d
f0102f44:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
}

static __inline void
ltr(uint16 sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0102f4a:	66 8b 45 fe          	mov    -0x2(%ebp),%ax
f0102f4e:	0f 00 d8             	ltr    %ax

	// Load the TSS
	ltr(GD_TSS);

	// Load the IDT
	asm volatile("lidt idt_pd");
f0102f51:	0f 01 1d f8 a5 11 f0 	lidtl  0xf011a5f8
}
f0102f58:	90                   	nop
f0102f59:	c9                   	leave  
f0102f5a:	c3                   	ret    

f0102f5b <print_trapframe>:

void
print_trapframe(struct Trapframe *tf)
{
f0102f5b:	55                   	push   %ebp
f0102f5c:	89 e5                	mov    %esp,%ebp
f0102f5e:	83 ec 08             	sub    $0x8,%esp
	cprintf("TRAP frame at %p\n", tf);
f0102f61:	83 ec 08             	sub    $0x8,%esp
f0102f64:	ff 75 08             	pushl  0x8(%ebp)
f0102f67:	68 3b 57 10 f0       	push   $0xf010573b
f0102f6c:	e8 d0 fd ff ff       	call   f0102d41 <cprintf>
f0102f71:	83 c4 10             	add    $0x10,%esp
	print_regs(&tf->tf_regs);
f0102f74:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f77:	83 ec 0c             	sub    $0xc,%esp
f0102f7a:	50                   	push   %eax
f0102f7b:	e8 f6 00 00 00       	call   f0103076 <print_regs>
f0102f80:	83 c4 10             	add    $0x10,%esp
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0102f83:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f86:	8b 40 20             	mov    0x20(%eax),%eax
f0102f89:	0f b7 c0             	movzwl %ax,%eax
f0102f8c:	83 ec 08             	sub    $0x8,%esp
f0102f8f:	50                   	push   %eax
f0102f90:	68 4d 57 10 f0       	push   $0xf010574d
f0102f95:	e8 a7 fd ff ff       	call   f0102d41 <cprintf>
f0102f9a:	83 c4 10             	add    $0x10,%esp
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0102f9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fa0:	8b 40 24             	mov    0x24(%eax),%eax
f0102fa3:	0f b7 c0             	movzwl %ax,%eax
f0102fa6:	83 ec 08             	sub    $0x8,%esp
f0102fa9:	50                   	push   %eax
f0102faa:	68 60 57 10 f0       	push   $0xf0105760
f0102faf:	e8 8d fd ff ff       	call   f0102d41 <cprintf>
f0102fb4:	83 c4 10             	add    $0x10,%esp
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0102fb7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fba:	8b 40 28             	mov    0x28(%eax),%eax
f0102fbd:	83 ec 0c             	sub    $0xc,%esp
f0102fc0:	50                   	push   %eax
f0102fc1:	e8 a1 fd ff ff       	call   f0102d67 <trapname>
f0102fc6:	83 c4 10             	add    $0x10,%esp
f0102fc9:	89 c2                	mov    %eax,%edx
f0102fcb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fce:	8b 40 28             	mov    0x28(%eax),%eax
f0102fd1:	83 ec 04             	sub    $0x4,%esp
f0102fd4:	52                   	push   %edx
f0102fd5:	50                   	push   %eax
f0102fd6:	68 73 57 10 f0       	push   $0xf0105773
f0102fdb:	e8 61 fd ff ff       	call   f0102d41 <cprintf>
f0102fe0:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x\n", tf->tf_err);
f0102fe3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fe6:	8b 40 2c             	mov    0x2c(%eax),%eax
f0102fe9:	83 ec 08             	sub    $0x8,%esp
f0102fec:	50                   	push   %eax
f0102fed:	68 85 57 10 f0       	push   $0xf0105785
f0102ff2:	e8 4a fd ff ff       	call   f0102d41 <cprintf>
f0102ff7:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0102ffa:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ffd:	8b 40 30             	mov    0x30(%eax),%eax
f0103000:	83 ec 08             	sub    $0x8,%esp
f0103003:	50                   	push   %eax
f0103004:	68 94 57 10 f0       	push   $0xf0105794
f0103009:	e8 33 fd ff ff       	call   f0102d41 <cprintf>
f010300e:	83 c4 10             	add    $0x10,%esp
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103011:	8b 45 08             	mov    0x8(%ebp),%eax
f0103014:	8b 40 34             	mov    0x34(%eax),%eax
f0103017:	0f b7 c0             	movzwl %ax,%eax
f010301a:	83 ec 08             	sub    $0x8,%esp
f010301d:	50                   	push   %eax
f010301e:	68 a3 57 10 f0       	push   $0xf01057a3
f0103023:	e8 19 fd ff ff       	call   f0102d41 <cprintf>
f0103028:	83 c4 10             	add    $0x10,%esp
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f010302b:	8b 45 08             	mov    0x8(%ebp),%eax
f010302e:	8b 40 38             	mov    0x38(%eax),%eax
f0103031:	83 ec 08             	sub    $0x8,%esp
f0103034:	50                   	push   %eax
f0103035:	68 b6 57 10 f0       	push   $0xf01057b6
f010303a:	e8 02 fd ff ff       	call   f0102d41 <cprintf>
f010303f:	83 c4 10             	add    $0x10,%esp
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103042:	8b 45 08             	mov    0x8(%ebp),%eax
f0103045:	8b 40 3c             	mov    0x3c(%eax),%eax
f0103048:	83 ec 08             	sub    $0x8,%esp
f010304b:	50                   	push   %eax
f010304c:	68 c5 57 10 f0       	push   $0xf01057c5
f0103051:	e8 eb fc ff ff       	call   f0102d41 <cprintf>
f0103056:	83 c4 10             	add    $0x10,%esp
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103059:	8b 45 08             	mov    0x8(%ebp),%eax
f010305c:	8b 40 40             	mov    0x40(%eax),%eax
f010305f:	0f b7 c0             	movzwl %ax,%eax
f0103062:	83 ec 08             	sub    $0x8,%esp
f0103065:	50                   	push   %eax
f0103066:	68 d4 57 10 f0       	push   $0xf01057d4
f010306b:	e8 d1 fc ff ff       	call   f0102d41 <cprintf>
f0103070:	83 c4 10             	add    $0x10,%esp
}
f0103073:	90                   	nop
f0103074:	c9                   	leave  
f0103075:	c3                   	ret    

f0103076 <print_regs>:

void
print_regs(struct PushRegs *regs)
{
f0103076:	55                   	push   %ebp
f0103077:	89 e5                	mov    %esp,%ebp
f0103079:	83 ec 08             	sub    $0x8,%esp
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010307c:	8b 45 08             	mov    0x8(%ebp),%eax
f010307f:	8b 00                	mov    (%eax),%eax
f0103081:	83 ec 08             	sub    $0x8,%esp
f0103084:	50                   	push   %eax
f0103085:	68 e7 57 10 f0       	push   $0xf01057e7
f010308a:	e8 b2 fc ff ff       	call   f0102d41 <cprintf>
f010308f:	83 c4 10             	add    $0x10,%esp
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103092:	8b 45 08             	mov    0x8(%ebp),%eax
f0103095:	8b 40 04             	mov    0x4(%eax),%eax
f0103098:	83 ec 08             	sub    $0x8,%esp
f010309b:	50                   	push   %eax
f010309c:	68 f6 57 10 f0       	push   $0xf01057f6
f01030a1:	e8 9b fc ff ff       	call   f0102d41 <cprintf>
f01030a6:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01030a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01030ac:	8b 40 08             	mov    0x8(%eax),%eax
f01030af:	83 ec 08             	sub    $0x8,%esp
f01030b2:	50                   	push   %eax
f01030b3:	68 05 58 10 f0       	push   $0xf0105805
f01030b8:	e8 84 fc ff ff       	call   f0102d41 <cprintf>
f01030bd:	83 c4 10             	add    $0x10,%esp
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01030c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01030c3:	8b 40 0c             	mov    0xc(%eax),%eax
f01030c6:	83 ec 08             	sub    $0x8,%esp
f01030c9:	50                   	push   %eax
f01030ca:	68 14 58 10 f0       	push   $0xf0105814
f01030cf:	e8 6d fc ff ff       	call   f0102d41 <cprintf>
f01030d4:	83 c4 10             	add    $0x10,%esp
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01030d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01030da:	8b 40 10             	mov    0x10(%eax),%eax
f01030dd:	83 ec 08             	sub    $0x8,%esp
f01030e0:	50                   	push   %eax
f01030e1:	68 23 58 10 f0       	push   $0xf0105823
f01030e6:	e8 56 fc ff ff       	call   f0102d41 <cprintf>
f01030eb:	83 c4 10             	add    $0x10,%esp
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01030ee:	8b 45 08             	mov    0x8(%ebp),%eax
f01030f1:	8b 40 14             	mov    0x14(%eax),%eax
f01030f4:	83 ec 08             	sub    $0x8,%esp
f01030f7:	50                   	push   %eax
f01030f8:	68 32 58 10 f0       	push   $0xf0105832
f01030fd:	e8 3f fc ff ff       	call   f0102d41 <cprintf>
f0103102:	83 c4 10             	add    $0x10,%esp
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103105:	8b 45 08             	mov    0x8(%ebp),%eax
f0103108:	8b 40 18             	mov    0x18(%eax),%eax
f010310b:	83 ec 08             	sub    $0x8,%esp
f010310e:	50                   	push   %eax
f010310f:	68 41 58 10 f0       	push   $0xf0105841
f0103114:	e8 28 fc ff ff       	call   f0102d41 <cprintf>
f0103119:	83 c4 10             	add    $0x10,%esp
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010311c:	8b 45 08             	mov    0x8(%ebp),%eax
f010311f:	8b 40 1c             	mov    0x1c(%eax),%eax
f0103122:	83 ec 08             	sub    $0x8,%esp
f0103125:	50                   	push   %eax
f0103126:	68 50 58 10 f0       	push   $0xf0105850
f010312b:	e8 11 fc ff ff       	call   f0102d41 <cprintf>
f0103130:	83 c4 10             	add    $0x10,%esp
}
f0103133:	90                   	nop
f0103134:	c9                   	leave  
f0103135:	c3                   	ret    

f0103136 <trap_dispatch>:

static void
trap_dispatch(struct Trapframe *tf)
{
f0103136:	55                   	push   %ebp
f0103137:	89 e5                	mov    %esp,%ebp
f0103139:	57                   	push   %edi
f010313a:	56                   	push   %esi
f010313b:	53                   	push   %ebx
f010313c:	83 ec 1c             	sub    $0x1c,%esp
	// Handle processor exceptions.
	// LAB 3: Your code here.
	
	if(tf->tf_trapno == T_PGFLT)
f010313f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103142:	8b 40 28             	mov    0x28(%eax),%eax
f0103145:	83 f8 0e             	cmp    $0xe,%eax
f0103148:	75 13                	jne    f010315d <trap_dispatch+0x27>
	{
		page_fault_handler(tf);
f010314a:	83 ec 0c             	sub    $0xc,%esp
f010314d:	ff 75 08             	pushl  0x8(%ebp)
f0103150:	e8 47 01 00 00       	call   f010329c <page_fault_handler>
f0103155:	83 c4 10             	add    $0x10,%esp
		else {
			env_destroy(curenv);
			return;	
		}
	}
	return;
f0103158:	e9 90 00 00 00       	jmp    f01031ed <trap_dispatch+0xb7>
	
	if(tf->tf_trapno == T_PGFLT)
	{
		page_fault_handler(tf);
	}
	else if (tf->tf_trapno == T_SYSCALL)
f010315d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103160:	8b 40 28             	mov    0x28(%eax),%eax
f0103163:	83 f8 30             	cmp    $0x30,%eax
f0103166:	75 42                	jne    f01031aa <trap_dispatch+0x74>
	{
		uint32 ret = syscall(tf->tf_regs.reg_eax
f0103168:	8b 45 08             	mov    0x8(%ebp),%eax
f010316b:	8b 78 04             	mov    0x4(%eax),%edi
f010316e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103171:	8b 30                	mov    (%eax),%esi
f0103173:	8b 45 08             	mov    0x8(%ebp),%eax
f0103176:	8b 58 10             	mov    0x10(%eax),%ebx
f0103179:	8b 45 08             	mov    0x8(%ebp),%eax
f010317c:	8b 48 18             	mov    0x18(%eax),%ecx
f010317f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103182:	8b 50 14             	mov    0x14(%eax),%edx
f0103185:	8b 45 08             	mov    0x8(%ebp),%eax
f0103188:	8b 40 1c             	mov    0x1c(%eax),%eax
f010318b:	83 ec 08             	sub    $0x8,%esp
f010318e:	57                   	push   %edi
f010318f:	56                   	push   %esi
f0103190:	53                   	push   %ebx
f0103191:	51                   	push   %ecx
f0103192:	52                   	push   %edx
f0103193:	50                   	push   %eax
f0103194:	e8 47 04 00 00       	call   f01035e0 <syscall>
f0103199:	83 c4 20             	add    $0x20,%esp
f010319c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			,tf->tf_regs.reg_edx
			,tf->tf_regs.reg_ecx
			,tf->tf_regs.reg_ebx
			,tf->tf_regs.reg_edi
					,tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f010319f:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01031a5:	89 50 1c             	mov    %edx,0x1c(%eax)
		else {
			env_destroy(curenv);
			return;	
		}
	}
	return;
f01031a8:	eb 43                	jmp    f01031ed <trap_dispatch+0xb7>
		tf->tf_regs.reg_eax = ret;
	}
	else
	{
		// Unexpected trap: The user process or the kernel has a bug.
		print_trapframe(tf);
f01031aa:	83 ec 0c             	sub    $0xc,%esp
f01031ad:	ff 75 08             	pushl  0x8(%ebp)
f01031b0:	e8 a6 fd ff ff       	call   f0102f5b <print_trapframe>
f01031b5:	83 c4 10             	add    $0x10,%esp
		if (tf->tf_cs == GD_KT)
f01031b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01031bb:	8b 40 34             	mov    0x34(%eax),%eax
f01031be:	66 83 f8 08          	cmp    $0x8,%ax
f01031c2:	75 17                	jne    f01031db <trap_dispatch+0xa5>
			panic("unhandled trap in kernel");
f01031c4:	83 ec 04             	sub    $0x4,%esp
f01031c7:	68 5f 58 10 f0       	push   $0xf010585f
f01031cc:	68 8a 00 00 00       	push   $0x8a
f01031d1:	68 78 58 10 f0       	push   $0xf0105878
f01031d6:	e8 53 cf ff ff       	call   f010012e <_panic>
		else {
			env_destroy(curenv);
f01031db:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01031e0:	83 ec 0c             	sub    $0xc,%esp
f01031e3:	50                   	push   %eax
f01031e4:	e8 a2 f9 ff ff       	call   f0102b8b <env_destroy>
f01031e9:	83 c4 10             	add    $0x10,%esp
			return;	
f01031ec:	90                   	nop
		}
	}
	return;
}
f01031ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01031f0:	5b                   	pop    %ebx
f01031f1:	5e                   	pop    %esi
f01031f2:	5f                   	pop    %edi
f01031f3:	5d                   	pop    %ebp
f01031f4:	c3                   	ret    

f01031f5 <trap>:

void
trap(struct Trapframe *tf)
{
f01031f5:	55                   	push   %ebp
f01031f6:	89 e5                	mov    %esp,%ebp
f01031f8:	57                   	push   %edi
f01031f9:	56                   	push   %esi
f01031fa:	53                   	push   %ebx
f01031fb:	83 ec 0c             	sub    $0xc,%esp
	//cprintf("Incoming TRAP frame at %p\n", tf);

	if ((tf->tf_cs & 3) == 3) {
f01031fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0103201:	8b 40 34             	mov    0x34(%eax),%eax
f0103204:	0f b7 c0             	movzwl %ax,%eax
f0103207:	83 e0 03             	and    $0x3,%eax
f010320a:	83 f8 03             	cmp    $0x3,%eax
f010320d:	75 42                	jne    f0103251 <trap+0x5c>
		// Trapped from user mode.
		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		assert(curenv);
f010320f:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0103214:	85 c0                	test   %eax,%eax
f0103216:	75 19                	jne    f0103231 <trap+0x3c>
f0103218:	68 84 58 10 f0       	push   $0xf0105884
f010321d:	68 8b 58 10 f0       	push   $0xf010588b
f0103222:	68 9d 00 00 00       	push   $0x9d
f0103227:	68 78 58 10 f0       	push   $0xf0105878
f010322c:	e8 fd ce ff ff       	call   f010012e <_panic>
		curenv->env_tf = *tf;
f0103231:	8b 15 50 ce 14 f0    	mov    0xf014ce50,%edx
f0103237:	8b 45 08             	mov    0x8(%ebp),%eax
f010323a:	89 c3                	mov    %eax,%ebx
f010323c:	b8 11 00 00 00       	mov    $0x11,%eax
f0103241:	89 d7                	mov    %edx,%edi
f0103243:	89 de                	mov    %ebx,%esi
f0103245:	89 c1                	mov    %eax,%ecx
f0103247:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103249:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f010324e:	89 45 08             	mov    %eax,0x8(%ebp)
	}
	
	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
f0103251:	83 ec 0c             	sub    $0xc,%esp
f0103254:	ff 75 08             	pushl  0x8(%ebp)
f0103257:	e8 da fe ff ff       	call   f0103136 <trap_dispatch>
f010325c:	83 c4 10             	add    $0x10,%esp

        // Return to the current environment, which should be runnable.
        assert(curenv && curenv->env_status == ENV_RUNNABLE);
f010325f:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0103264:	85 c0                	test   %eax,%eax
f0103266:	74 0d                	je     f0103275 <trap+0x80>
f0103268:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f010326d:	8b 40 54             	mov    0x54(%eax),%eax
f0103270:	83 f8 01             	cmp    $0x1,%eax
f0103273:	74 19                	je     f010328e <trap+0x99>
f0103275:	68 a0 58 10 f0       	push   $0xf01058a0
f010327a:	68 8b 58 10 f0       	push   $0xf010588b
f010327f:	68 a7 00 00 00       	push   $0xa7
f0103284:	68 78 58 10 f0       	push   $0xf0105878
f0103289:	e8 a0 ce ff ff       	call   f010012e <_panic>
        env_run(curenv);
f010328e:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0103293:	83 ec 0c             	sub    $0xc,%esp
f0103296:	50                   	push   %eax
f0103297:	e8 fd f2 ff ff       	call   f0102599 <env_run>

f010329c <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010329c:	55                   	push   %ebp
f010329d:	89 e5                	mov    %esp,%ebp
f010329f:	83 ec 18             	sub    $0x18,%esp

static __inline uint32
rcr2(void)
{
	uint32 val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01032a2:	0f 20 d0             	mov    %cr2,%eax
f01032a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	return val;
f01032a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
	uint32 fault_va;

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
f01032ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01032ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01032b1:	8b 50 30             	mov    0x30(%eax),%edx
		curenv->env_id, fault_va, tf->tf_eip);
f01032b4:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
	//   (the 'tf' variable points at 'curenv->env_tf').
	
	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01032b9:	8b 40 4c             	mov    0x4c(%eax),%eax
f01032bc:	52                   	push   %edx
f01032bd:	ff 75 f4             	pushl  -0xc(%ebp)
f01032c0:	50                   	push   %eax
f01032c1:	68 d0 58 10 f0       	push   $0xf01058d0
f01032c6:	e8 76 fa ff ff       	call   f0102d41 <cprintf>
f01032cb:	83 c4 10             	add    $0x10,%esp
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01032ce:	83 ec 0c             	sub    $0xc,%esp
f01032d1:	ff 75 08             	pushl  0x8(%ebp)
f01032d4:	e8 82 fc ff ff       	call   f0102f5b <print_trapframe>
f01032d9:	83 c4 10             	add    $0x10,%esp
	env_destroy(curenv);
f01032dc:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01032e1:	83 ec 0c             	sub    $0xc,%esp
f01032e4:	50                   	push   %eax
f01032e5:	e8 a1 f8 ff ff       	call   f0102b8b <env_destroy>
f01032ea:	83 c4 10             	add    $0x10,%esp
	
}
f01032ed:	90                   	nop
f01032ee:	c9                   	leave  
f01032ef:	c3                   	ret    

f01032f0 <PAGE_FAULT>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER(PAGE_FAULT, T_PGFLT)		
f01032f0:	6a 0e                	push   $0xe
f01032f2:	eb 06                	jmp    f01032fa <_alltraps>

f01032f4 <SYSCALL_HANDLER>:

TRAPHANDLER_NOEC(SYSCALL_HANDLER, T_SYSCALL)
f01032f4:	6a 00                	push   $0x0
f01032f6:	6a 30                	push   $0x30
f01032f8:	eb 00                	jmp    f01032fa <_alltraps>

f01032fa <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:

push %ds 
f01032fa:	1e                   	push   %ds
push %es 
f01032fb:	06                   	push   %es
pushal 	
f01032fc:	60                   	pusha  

mov $(GD_KD), %ax 
f01032fd:	66 b8 10 00          	mov    $0x10,%ax
mov %ax,%ds
f0103301:	8e d8                	mov    %eax,%ds
mov %ax,%es
f0103303:	8e c0                	mov    %eax,%es

push %esp
f0103305:	54                   	push   %esp

call trap
f0103306:	e8 ea fe ff ff       	call   f01031f5 <trap>

pop %ecx /* poping the pointer to the tf from the stack so that the stack top is at the values of the registers posuhed by pusha*/
f010330b:	59                   	pop    %ecx
popal 	
f010330c:	61                   	popa   
pop %es 
f010330d:	07                   	pop    %es
pop %ds    
f010330e:	1f                   	pop    %ds

/*skipping the trap_no and the error code so that the stack top is at the old eip value*/
add $(8),%esp
f010330f:	83 c4 08             	add    $0x8,%esp

iret
f0103312:	cf                   	iret   

f0103313 <to_frame_number>:
void	unmap_frame(uint32 *pgdir, void *va);
struct Frame_Info *get_frame_info(uint32 *ptr_page_directory, void *virtual_address, uint32 **ptr_page_table);
void decrement_references(struct Frame_Info* ptr_frame_info);

static inline uint32 to_frame_number(struct Frame_Info *ptr_frame_info)
{
f0103313:	55                   	push   %ebp
f0103314:	89 e5                	mov    %esp,%ebp
	return ptr_frame_info - frames_info;
f0103316:	8b 45 08             	mov    0x8(%ebp),%eax
f0103319:	8b 15 dc d6 14 f0    	mov    0xf014d6dc,%edx
f010331f:	29 d0                	sub    %edx,%eax
f0103321:	c1 f8 02             	sar    $0x2,%eax
f0103324:	89 c2                	mov    %eax,%edx
f0103326:	89 d0                	mov    %edx,%eax
f0103328:	c1 e0 02             	shl    $0x2,%eax
f010332b:	01 d0                	add    %edx,%eax
f010332d:	c1 e0 02             	shl    $0x2,%eax
f0103330:	01 d0                	add    %edx,%eax
f0103332:	c1 e0 02             	shl    $0x2,%eax
f0103335:	01 d0                	add    %edx,%eax
f0103337:	89 c1                	mov    %eax,%ecx
f0103339:	c1 e1 08             	shl    $0x8,%ecx
f010333c:	01 c8                	add    %ecx,%eax
f010333e:	89 c1                	mov    %eax,%ecx
f0103340:	c1 e1 10             	shl    $0x10,%ecx
f0103343:	01 c8                	add    %ecx,%eax
f0103345:	01 c0                	add    %eax,%eax
f0103347:	01 d0                	add    %edx,%eax
}
f0103349:	5d                   	pop    %ebp
f010334a:	c3                   	ret    

f010334b <to_physical_address>:

static inline uint32 to_physical_address(struct Frame_Info *ptr_frame_info)
{
f010334b:	55                   	push   %ebp
f010334c:	89 e5                	mov    %esp,%ebp
	return to_frame_number(ptr_frame_info) << PGSHIFT;
f010334e:	ff 75 08             	pushl  0x8(%ebp)
f0103351:	e8 bd ff ff ff       	call   f0103313 <to_frame_number>
f0103356:	83 c4 04             	add    $0x4,%esp
f0103359:	c1 e0 0c             	shl    $0xc,%eax
}
f010335c:	c9                   	leave  
f010335d:	c3                   	ret    

f010335e <sys_cputs>:

// Print a string to the system console.
// The string is exactly 'len' characters long.
// Destroys the environment on memory errors.
static void sys_cputs(const char *s, uint32 len)
{
f010335e:	55                   	push   %ebp
f010335f:	89 e5                	mov    %esp,%ebp
f0103361:	83 ec 08             	sub    $0x8,%esp
	// Destroy the environment if not.
	
	// LAB 3: Your code here.

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103364:	83 ec 04             	sub    $0x4,%esp
f0103367:	ff 75 08             	pushl  0x8(%ebp)
f010336a:	ff 75 0c             	pushl  0xc(%ebp)
f010336d:	68 90 5a 10 f0       	push   $0xf0105a90
f0103372:	e8 ca f9 ff ff       	call   f0102d41 <cprintf>
f0103377:	83 c4 10             	add    $0x10,%esp
}
f010337a:	90                   	nop
f010337b:	c9                   	leave  
f010337c:	c3                   	ret    

f010337d <sys_cgetc>:

// Read a character from the system console.
// Returns the character.
static int
sys_cgetc(void)
{
f010337d:	55                   	push   %ebp
f010337e:	89 e5                	mov    %esp,%ebp
f0103380:	83 ec 18             	sub    $0x18,%esp
	int c;

	// The cons_getc() primitive doesn't wait for a character,
	// but the sys_cgetc() system call does.
	while ((c = cons_getc()) == 0)
f0103383:	e8 e1 d4 ff ff       	call   f0100869 <cons_getc>
f0103388:	89 45 f4             	mov    %eax,-0xc(%ebp)
f010338b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f010338f:	74 f2                	je     f0103383 <sys_cgetc+0x6>
		/* do nothing */;

	return c;
f0103391:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0103394:	c9                   	leave  
f0103395:	c3                   	ret    

f0103396 <sys_getenvid>:

// Returns the current environment's envid.
static int32 sys_getenvid(void)
{
f0103396:	55                   	push   %ebp
f0103397:	89 e5                	mov    %esp,%ebp
	return curenv->env_id;
f0103399:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f010339e:	8b 40 4c             	mov    0x4c(%eax),%eax
}
f01033a1:	5d                   	pop    %ebp
f01033a2:	c3                   	ret    

f01033a3 <sys_env_destroy>:
//
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
static int sys_env_destroy(int32  envid)
{
f01033a3:	55                   	push   %ebp
f01033a4:	89 e5                	mov    %esp,%ebp
f01033a6:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01033a9:	83 ec 04             	sub    $0x4,%esp
f01033ac:	6a 01                	push   $0x1
f01033ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
f01033b1:	50                   	push   %eax
f01033b2:	ff 75 08             	pushl  0x8(%ebp)
f01033b5:	e8 84 e5 ff ff       	call   f010193e <envid2env>
f01033ba:	83 c4 10             	add    $0x10,%esp
f01033bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01033c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01033c4:	79 05                	jns    f01033cb <sys_env_destroy+0x28>
		return r;
f01033c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01033c9:	eb 5b                	jmp    f0103426 <sys_env_destroy+0x83>
	if (e == curenv)
f01033cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01033ce:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01033d3:	39 c2                	cmp    %eax,%edx
f01033d5:	75 1b                	jne    f01033f2 <sys_env_destroy+0x4f>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01033d7:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01033dc:	8b 40 4c             	mov    0x4c(%eax),%eax
f01033df:	83 ec 08             	sub    $0x8,%esp
f01033e2:	50                   	push   %eax
f01033e3:	68 95 5a 10 f0       	push   $0xf0105a95
f01033e8:	e8 54 f9 ff ff       	call   f0102d41 <cprintf>
f01033ed:	83 c4 10             	add    $0x10,%esp
f01033f0:	eb 20                	jmp    f0103412 <sys_env_destroy+0x6f>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01033f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01033f5:	8b 50 4c             	mov    0x4c(%eax),%edx
f01033f8:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01033fd:	8b 40 4c             	mov    0x4c(%eax),%eax
f0103400:	83 ec 04             	sub    $0x4,%esp
f0103403:	52                   	push   %edx
f0103404:	50                   	push   %eax
f0103405:	68 b0 5a 10 f0       	push   $0xf0105ab0
f010340a:	e8 32 f9 ff ff       	call   f0102d41 <cprintf>
f010340f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0103412:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103415:	83 ec 0c             	sub    $0xc,%esp
f0103418:	50                   	push   %eax
f0103419:	e8 6d f7 ff ff       	call   f0102b8b <env_destroy>
f010341e:	83 c4 10             	add    $0x10,%esp
	return 0;
f0103421:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103426:	c9                   	leave  
f0103427:	c3                   	ret    

f0103428 <sys_env_sleep>:

static void sys_env_sleep()
{
f0103428:	55                   	push   %ebp
f0103429:	89 e5                	mov    %esp,%ebp
f010342b:	83 ec 08             	sub    $0x8,%esp
	env_run_cmd_prmpt();
f010342e:	e8 73 f7 ff ff       	call   f0102ba6 <env_run_cmd_prmpt>
}
f0103433:	90                   	nop
f0103434:	c9                   	leave  
f0103435:	c3                   	ret    

f0103436 <sys_allocate_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_allocate_page(void *va, int perm)
{
f0103436:	55                   	push   %ebp
f0103437:	89 e5                	mov    %esp,%ebp
f0103439:	83 ec 28             	sub    $0x28,%esp
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!
	
	int r;
	struct Env *e = curenv;
f010343c:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0103441:	89 45 f4             	mov    %eax,-0xc(%ebp)

	//if ((r = envid2env(envid, &e, 1)) < 0)
		//return r;
	
	struct Frame_Info *ptr_frame_info ;
	r = allocate_frame(&ptr_frame_info) ;
f0103444:	83 ec 0c             	sub    $0xc,%esp
f0103447:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010344a:	50                   	push   %eax
f010344b:	e8 7c ec ff ff       	call   f01020cc <allocate_frame>
f0103450:	83 c4 10             	add    $0x10,%esp
f0103453:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f0103456:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f010345a:	75 08                	jne    f0103464 <sys_allocate_page+0x2e>
		return r ;
f010345c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010345f:	e9 cc 00 00 00       	jmp    f0103530 <sys_allocate_page+0xfa>
	
	//check virtual address to be paged_aligned and < USER_TOP
	if ((uint32)va >= USER_TOP || (uint32)va % PAGE_SIZE != 0)
f0103464:	8b 45 08             	mov    0x8(%ebp),%eax
f0103467:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f010346c:	77 0c                	ja     f010347a <sys_allocate_page+0x44>
f010346e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103471:	25 ff 0f 00 00       	and    $0xfff,%eax
f0103476:	85 c0                	test   %eax,%eax
f0103478:	74 0a                	je     f0103484 <sys_allocate_page+0x4e>
		return E_INVAL;
f010347a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010347f:	e9 ac 00 00 00       	jmp    f0103530 <sys_allocate_page+0xfa>
	
	//check permissions to be appropriatess
	if ((perm & (~PERM_AVAILABLE & ~PERM_WRITEABLE)) != (PERM_USER))
f0103484:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103487:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010348c:	83 f8 04             	cmp    $0x4,%eax
f010348f:	74 0a                	je     f010349b <sys_allocate_page+0x65>
		return E_INVAL;
f0103491:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103496:	e9 95 00 00 00       	jmp    f0103530 <sys_allocate_page+0xfa>
	
			
	uint32 physical_address = to_physical_address(ptr_frame_info) ;
f010349b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010349e:	83 ec 0c             	sub    $0xc,%esp
f01034a1:	50                   	push   %eax
f01034a2:	e8 a4 fe ff ff       	call   f010334b <to_physical_address>
f01034a7:	83 c4 10             	add    $0x10,%esp
f01034aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	memset(K_VIRTUAL_ADDRESS(physical_address), 0, PAGE_SIZE);
f01034ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01034b0:	89 45 e8             	mov    %eax,-0x18(%ebp)
f01034b3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01034b6:	c1 e8 0c             	shr    $0xc,%eax
f01034b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01034bc:	a1 c8 d6 14 f0       	mov    0xf014d6c8,%eax
f01034c1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f01034c4:	72 14                	jb     f01034da <sys_allocate_page+0xa4>
f01034c6:	ff 75 e8             	pushl  -0x18(%ebp)
f01034c9:	68 c8 5a 10 f0       	push   $0xf0105ac8
f01034ce:	6a 7a                	push   $0x7a
f01034d0:	68 f7 5a 10 f0       	push   $0xf0105af7
f01034d5:	e8 54 cc ff ff       	call   f010012e <_panic>
f01034da:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01034dd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01034e2:	83 ec 04             	sub    $0x4,%esp
f01034e5:	68 00 10 00 00       	push   $0x1000
f01034ea:	6a 00                	push   $0x0
f01034ec:	50                   	push   %eax
f01034ed:	e8 31 0f 00 00       	call   f0104423 <memset>
f01034f2:	83 c4 10             	add    $0x10,%esp
		
	r = map_frame(e->env_pgdir, ptr_frame_info, va, perm) ;
f01034f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01034fb:	8b 40 5c             	mov    0x5c(%eax),%eax
f01034fe:	ff 75 0c             	pushl  0xc(%ebp)
f0103501:	ff 75 08             	pushl  0x8(%ebp)
f0103504:	52                   	push   %edx
f0103505:	50                   	push   %eax
f0103506:	e8 ce ed ff ff       	call   f01022d9 <map_frame>
f010350b:	83 c4 10             	add    $0x10,%esp
f010350e:	89 45 f0             	mov    %eax,-0x10(%ebp)
	if (r == E_NO_MEM)
f0103511:	83 7d f0 fc          	cmpl   $0xfffffffc,-0x10(%ebp)
f0103515:	75 14                	jne    f010352b <sys_allocate_page+0xf5>
	{
		decrement_references(ptr_frame_info);
f0103517:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010351a:	83 ec 0c             	sub    $0xc,%esp
f010351d:	50                   	push   %eax
f010351e:	e8 47 ec ff ff       	call   f010216a <decrement_references>
f0103523:	83 c4 10             	add    $0x10,%esp
		return r;
f0103526:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103529:	eb 05                	jmp    f0103530 <sys_allocate_page+0xfa>
	}
	return 0 ;
f010352b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103530:	c9                   	leave  
f0103531:	c3                   	ret    

f0103532 <sys_get_page>:
//	E_INVAL if va >= UTOP, or va is not page-aligned.
//	E_INVAL if perm is inappropriate (see above).
//	E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_get_page(void *va, int perm)
{
f0103532:	55                   	push   %ebp
f0103533:	89 e5                	mov    %esp,%ebp
f0103535:	83 ec 08             	sub    $0x8,%esp
	return get_page(curenv->env_pgdir, va, perm) ;
f0103538:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f010353d:	8b 40 5c             	mov    0x5c(%eax),%eax
f0103540:	83 ec 04             	sub    $0x4,%esp
f0103543:	ff 75 0c             	pushl  0xc(%ebp)
f0103546:	ff 75 08             	pushl  0x8(%ebp)
f0103549:	50                   	push   %eax
f010354a:	e8 fd ee ff ff       	call   f010244c <get_page>
f010354f:	83 c4 10             	add    $0x10,%esp
}
f0103552:	c9                   	leave  
f0103553:	c3                   	ret    

f0103554 <sys_map_frame>:
//	-E_INVAL if (perm & PTE_W), but srcva is read-only in srcenvid's
//		address space.
//	-E_NO_MEM if there's no memory to allocate the new page,
//		or to allocate any necessary page tables.
static int sys_map_frame(int32 srcenvid, void *srcva, int32 dstenvid, void *dstva, int perm)
{
f0103554:	55                   	push   %ebp
f0103555:	89 e5                	mov    %esp,%ebp
f0103557:	83 ec 08             	sub    $0x8,%esp
	//   parameters for correctness.
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.
	panic("sys_map_frame not implemented");
f010355a:	83 ec 04             	sub    $0x4,%esp
f010355d:	68 06 5b 10 f0       	push   $0xf0105b06
f0103562:	68 b1 00 00 00       	push   $0xb1
f0103567:	68 f7 5a 10 f0       	push   $0xf0105af7
f010356c:	e8 bd cb ff ff       	call   f010012e <_panic>

f0103571 <sys_unmap_frame>:
// Return 0 on success, < 0 on error.  Errors are:
//	-E_BAD_ENV if environment envid doesn't currently exist,
//		or the caller doesn't have permission to change envid.
//	-E_INVAL if va >= UTOP, or va is not page-aligned.
static int sys_unmap_frame(int32 envid, void *va)
{
f0103571:	55                   	push   %ebp
f0103572:	89 e5                	mov    %esp,%ebp
f0103574:	83 ec 08             	sub    $0x8,%esp
	// Hint: This function is a wrapper around page_remove().
	
	// LAB 4: Your code here.
	panic("sys_page_unmap not implemented");
f0103577:	83 ec 04             	sub    $0x4,%esp
f010357a:	68 24 5b 10 f0       	push   $0xf0105b24
f010357f:	68 c0 00 00 00       	push   $0xc0
f0103584:	68 f7 5a 10 f0       	push   $0xf0105af7
f0103589:	e8 a0 cb ff ff       	call   f010012e <_panic>

f010358e <sys_calculate_required_frames>:
}

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
f010358e:	55                   	push   %ebp
f010358f:	89 e5                	mov    %esp,%ebp
f0103591:	83 ec 08             	sub    $0x8,%esp
	return calculate_required_frames(curenv->env_pgdir, start_virtual_address, size); 
f0103594:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f0103599:	8b 40 5c             	mov    0x5c(%eax),%eax
f010359c:	83 ec 04             	sub    $0x4,%esp
f010359f:	ff 75 0c             	pushl  0xc(%ebp)
f01035a2:	ff 75 08             	pushl  0x8(%ebp)
f01035a5:	50                   	push   %eax
f01035a6:	e8 be ee ff ff       	call   f0102469 <calculate_required_frames>
f01035ab:	83 c4 10             	add    $0x10,%esp
}
f01035ae:	c9                   	leave  
f01035af:	c3                   	ret    

f01035b0 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
f01035b0:	55                   	push   %ebp
f01035b1:	89 e5                	mov    %esp,%ebp
f01035b3:	83 ec 08             	sub    $0x8,%esp
	return calculate_free_frames();
f01035b6:	e8 cb ee ff ff       	call   f0102486 <calculate_free_frames>
}
f01035bb:	c9                   	leave  
f01035bc:	c3                   	ret    

f01035bd <sys_freeMem>:
void sys_freeMem(void* start_virtual_address, uint32 size)
{
f01035bd:	55                   	push   %ebp
f01035be:	89 e5                	mov    %esp,%ebp
f01035c0:	83 ec 08             	sub    $0x8,%esp
	freeMem((uint32*)curenv->env_pgdir, (void*)start_virtual_address, size);
f01035c3:	a1 50 ce 14 f0       	mov    0xf014ce50,%eax
f01035c8:	8b 40 5c             	mov    0x5c(%eax),%eax
f01035cb:	83 ec 04             	sub    $0x4,%esp
f01035ce:	ff 75 0c             	pushl  0xc(%ebp)
f01035d1:	ff 75 08             	pushl  0x8(%ebp)
f01035d4:	50                   	push   %eax
f01035d5:	e8 d9 ee ff ff       	call   f01024b3 <freeMem>
f01035da:	83 c4 10             	add    $0x10,%esp
	return;
f01035dd:	90                   	nop
}
f01035de:	c9                   	leave  
f01035df:	c3                   	ret    

f01035e0 <syscall>:
// Dispatches to the correct kernel function, passing the arguments.
uint32
syscall(uint32 syscallno, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
f01035e0:	55                   	push   %ebp
f01035e1:	89 e5                	mov    %esp,%ebp
f01035e3:	56                   	push   %esi
f01035e4:	53                   	push   %ebx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno)
f01035e5:	83 7d 08 0c          	cmpl   $0xc,0x8(%ebp)
f01035e9:	0f 87 19 01 00 00    	ja     f0103708 <syscall+0x128>
f01035ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01035f2:	c1 e0 02             	shl    $0x2,%eax
f01035f5:	05 44 5b 10 f0       	add    $0xf0105b44,%eax
f01035fa:	8b 00                	mov    (%eax),%eax
f01035fc:	ff e0                	jmp    *%eax
	{
		case SYS_cputs:
			sys_cputs((const char*)a1,a2);
f01035fe:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103601:	83 ec 08             	sub    $0x8,%esp
f0103604:	ff 75 10             	pushl  0x10(%ebp)
f0103607:	50                   	push   %eax
f0103608:	e8 51 fd ff ff       	call   f010335e <sys_cputs>
f010360d:	83 c4 10             	add    $0x10,%esp
			return 0;
f0103610:	b8 00 00 00 00       	mov    $0x0,%eax
f0103615:	e9 f3 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_cgetc:
			return sys_cgetc();
f010361a:	e8 5e fd ff ff       	call   f010337d <sys_cgetc>
f010361f:	e9 e9 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_getenvid:
			return sys_getenvid();
f0103624:	e8 6d fd ff ff       	call   f0103396 <sys_getenvid>
f0103629:	e9 df 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f010362e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103631:	83 ec 0c             	sub    $0xc,%esp
f0103634:	50                   	push   %eax
f0103635:	e8 69 fd ff ff       	call   f01033a3 <sys_env_destroy>
f010363a:	83 c4 10             	add    $0x10,%esp
f010363d:	e9 cb 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_env_sleep:
			sys_env_sleep();
f0103642:	e8 e1 fd ff ff       	call   f0103428 <sys_env_sleep>
			return 0;
f0103647:	b8 00 00 00 00       	mov    $0x0,%eax
f010364c:	e9 bc 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_calc_req_frames:
			return sys_calculate_required_frames(a1, a2);			
f0103651:	83 ec 08             	sub    $0x8,%esp
f0103654:	ff 75 10             	pushl  0x10(%ebp)
f0103657:	ff 75 0c             	pushl  0xc(%ebp)
f010365a:	e8 2f ff ff ff       	call   f010358e <sys_calculate_required_frames>
f010365f:	83 c4 10             	add    $0x10,%esp
f0103662:	e9 a6 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_calc_free_frames:
			return sys_calculate_free_frames();			
f0103667:	e8 44 ff ff ff       	call   f01035b0 <sys_calculate_free_frames>
f010366c:	e9 9c 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_freeMem:
			sys_freeMem((void*)a1, a2);
f0103671:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103674:	83 ec 08             	sub    $0x8,%esp
f0103677:	ff 75 10             	pushl  0x10(%ebp)
f010367a:	50                   	push   %eax
f010367b:	e8 3d ff ff ff       	call   f01035bd <sys_freeMem>
f0103680:	83 c4 10             	add    $0x10,%esp
			return 0;			
f0103683:	b8 00 00 00 00       	mov    $0x0,%eax
f0103688:	e9 80 00 00 00       	jmp    f010370d <syscall+0x12d>
			break;
		//======================
		
		case SYS_allocate_page:
			sys_allocate_page((void*)a1, a2);
f010368d:	8b 55 10             	mov    0x10(%ebp),%edx
f0103690:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103693:	83 ec 08             	sub    $0x8,%esp
f0103696:	52                   	push   %edx
f0103697:	50                   	push   %eax
f0103698:	e8 99 fd ff ff       	call   f0103436 <sys_allocate_page>
f010369d:	83 c4 10             	add    $0x10,%esp
			return 0;
f01036a0:	b8 00 00 00 00       	mov    $0x0,%eax
f01036a5:	eb 66                	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_get_page:
			sys_get_page((void*)a1, a2);
f01036a7:	8b 55 10             	mov    0x10(%ebp),%edx
f01036aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ad:	83 ec 08             	sub    $0x8,%esp
f01036b0:	52                   	push   %edx
f01036b1:	50                   	push   %eax
f01036b2:	e8 7b fe ff ff       	call   f0103532 <sys_get_page>
f01036b7:	83 c4 10             	add    $0x10,%esp
			return 0;
f01036ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01036bf:	eb 4c                	jmp    f010370d <syscall+0x12d>
		break;case SYS_map_frame:
			sys_map_frame(a1, (void*)a2, a3, (void*)a4, a5);
f01036c1:	8b 75 1c             	mov    0x1c(%ebp),%esi
f01036c4:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01036c7:	8b 4d 14             	mov    0x14(%ebp),%ecx
f01036ca:	8b 55 10             	mov    0x10(%ebp),%edx
f01036cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d0:	83 ec 0c             	sub    $0xc,%esp
f01036d3:	56                   	push   %esi
f01036d4:	53                   	push   %ebx
f01036d5:	51                   	push   %ecx
f01036d6:	52                   	push   %edx
f01036d7:	50                   	push   %eax
f01036d8:	e8 77 fe ff ff       	call   f0103554 <sys_map_frame>
f01036dd:	83 c4 20             	add    $0x20,%esp
			return 0;
f01036e0:	b8 00 00 00 00       	mov    $0x0,%eax
f01036e5:	eb 26                	jmp    f010370d <syscall+0x12d>
			break;
		case SYS_unmap_frame:
			sys_unmap_frame(a1, (void*)a2);
f01036e7:	8b 55 10             	mov    0x10(%ebp),%edx
f01036ea:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ed:	83 ec 08             	sub    $0x8,%esp
f01036f0:	52                   	push   %edx
f01036f1:	50                   	push   %eax
f01036f2:	e8 7a fe ff ff       	call   f0103571 <sys_unmap_frame>
f01036f7:	83 c4 10             	add    $0x10,%esp
			return 0;
f01036fa:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ff:	eb 0c                	jmp    f010370d <syscall+0x12d>
			break;
		case NSYSCALLS:	
			return 	-E_INVAL;
f0103701:	b8 03 00 00 00       	mov    $0x3,%eax
f0103706:	eb 05                	jmp    f010370d <syscall+0x12d>
			break;
	}
	//panic("syscall not implemented");
	return -E_INVAL;
f0103708:	b8 03 00 00 00       	mov    $0x3,%eax
}
f010370d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103710:	5b                   	pop    %ebx
f0103711:	5e                   	pop    %esi
f0103712:	5d                   	pop    %ebp
f0103713:	c3                   	ret    

f0103714 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
f0103714:	55                   	push   %ebp
f0103715:	89 e5                	mov    %esp,%ebp
f0103717:	83 ec 20             	sub    $0x20,%esp
	int l = *region_left, r = *region_right, any_matches = 0;
f010371a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010371d:	8b 00                	mov    (%eax),%eax
f010371f:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103722:	8b 45 10             	mov    0x10(%ebp),%eax
f0103725:	8b 00                	mov    (%eax),%eax
f0103727:	89 45 f8             	mov    %eax,-0x8(%ebp)
f010372a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
	while (l <= r) {
f0103731:	e9 ca 00 00 00       	jmp    f0103800 <stab_binsearch+0xec>
		int true_m = (l + r) / 2, m = true_m;
f0103736:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0103739:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010373c:	01 d0                	add    %edx,%eax
f010373e:	89 c2                	mov    %eax,%edx
f0103740:	c1 ea 1f             	shr    $0x1f,%edx
f0103743:	01 d0                	add    %edx,%eax
f0103745:	d1 f8                	sar    %eax
f0103747:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010374a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010374d:	89 45 f0             	mov    %eax,-0x10(%ebp)
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103750:	eb 03                	jmp    f0103755 <stab_binsearch+0x41>
			m--;
f0103752:	ff 4d f0             	decl   -0x10(%ebp)
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103755:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103758:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f010375b:	7c 1e                	jl     f010377b <stab_binsearch+0x67>
f010375d:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103760:	89 d0                	mov    %edx,%eax
f0103762:	01 c0                	add    %eax,%eax
f0103764:	01 d0                	add    %edx,%eax
f0103766:	c1 e0 02             	shl    $0x2,%eax
f0103769:	89 c2                	mov    %eax,%edx
f010376b:	8b 45 08             	mov    0x8(%ebp),%eax
f010376e:	01 d0                	add    %edx,%eax
f0103770:	8a 40 04             	mov    0x4(%eax),%al
f0103773:	0f b6 c0             	movzbl %al,%eax
f0103776:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103779:	75 d7                	jne    f0103752 <stab_binsearch+0x3e>
			m--;
		if (m < l) {	// no match in [l, m]
f010377b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010377e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103781:	7d 09                	jge    f010378c <stab_binsearch+0x78>
			l = true_m + 1;
f0103783:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103786:	40                   	inc    %eax
f0103787:	89 45 fc             	mov    %eax,-0x4(%ebp)
			continue;
f010378a:	eb 74                	jmp    f0103800 <stab_binsearch+0xec>
		}

		// actual binary search
		any_matches = 1;
f010378c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
		if (stabs[m].n_value < addr) {
f0103793:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103796:	89 d0                	mov    %edx,%eax
f0103798:	01 c0                	add    %eax,%eax
f010379a:	01 d0                	add    %edx,%eax
f010379c:	c1 e0 02             	shl    $0x2,%eax
f010379f:	89 c2                	mov    %eax,%edx
f01037a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01037a4:	01 d0                	add    %edx,%eax
f01037a6:	8b 40 08             	mov    0x8(%eax),%eax
f01037a9:	3b 45 18             	cmp    0x18(%ebp),%eax
f01037ac:	73 11                	jae    f01037bf <stab_binsearch+0xab>
			*region_left = m;
f01037ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037b1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01037b4:	89 10                	mov    %edx,(%eax)
			l = true_m + 1;
f01037b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01037b9:	40                   	inc    %eax
f01037ba:	89 45 fc             	mov    %eax,-0x4(%ebp)
f01037bd:	eb 41                	jmp    f0103800 <stab_binsearch+0xec>
		} else if (stabs[m].n_value > addr) {
f01037bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01037c2:	89 d0                	mov    %edx,%eax
f01037c4:	01 c0                	add    %eax,%eax
f01037c6:	01 d0                	add    %edx,%eax
f01037c8:	c1 e0 02             	shl    $0x2,%eax
f01037cb:	89 c2                	mov    %eax,%edx
f01037cd:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d0:	01 d0                	add    %edx,%eax
f01037d2:	8b 40 08             	mov    0x8(%eax),%eax
f01037d5:	3b 45 18             	cmp    0x18(%ebp),%eax
f01037d8:	76 14                	jbe    f01037ee <stab_binsearch+0xda>
			*region_right = m - 1;
f01037da:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037dd:	8d 50 ff             	lea    -0x1(%eax),%edx
f01037e0:	8b 45 10             	mov    0x10(%ebp),%eax
f01037e3:	89 10                	mov    %edx,(%eax)
			r = m - 1;
f01037e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037e8:	48                   	dec    %eax
f01037e9:	89 45 f8             	mov    %eax,-0x8(%ebp)
f01037ec:	eb 12                	jmp    f0103800 <stab_binsearch+0xec>
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01037ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037f1:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01037f4:	89 10                	mov    %edx,(%eax)
			l = m;
f01037f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01037f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
			addr++;
f01037fc:	83 45 18 04          	addl   $0x4,0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uint32*  addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0103800:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0103803:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f0103806:	0f 8e 2a ff ff ff    	jle    f0103736 <stab_binsearch+0x22>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010380c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f0103810:	75 0f                	jne    f0103821 <stab_binsearch+0x10d>
		*region_right = *region_left - 1;
f0103812:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103815:	8b 00                	mov    (%eax),%eax
f0103817:	8d 50 ff             	lea    -0x1(%eax),%edx
f010381a:	8b 45 10             	mov    0x10(%ebp),%eax
f010381d:	89 10                	mov    %edx,(%eax)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f010381f:	eb 3d                	jmp    f010385e <stab_binsearch+0x14a>

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103821:	8b 45 10             	mov    0x10(%ebp),%eax
f0103824:	8b 00                	mov    (%eax),%eax
f0103826:	89 45 fc             	mov    %eax,-0x4(%ebp)
f0103829:	eb 03                	jmp    f010382e <stab_binsearch+0x11a>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f010382b:	ff 4d fc             	decl   -0x4(%ebp)
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f010382e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103831:	8b 00                	mov    (%eax),%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103833:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f0103836:	7d 1e                	jge    f0103856 <stab_binsearch+0x142>
		     l > *region_left && stabs[l].n_type != type;
f0103838:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010383b:	89 d0                	mov    %edx,%eax
f010383d:	01 c0                	add    %eax,%eax
f010383f:	01 d0                	add    %edx,%eax
f0103841:	c1 e0 02             	shl    $0x2,%eax
f0103844:	89 c2                	mov    %eax,%edx
f0103846:	8b 45 08             	mov    0x8(%ebp),%eax
f0103849:	01 d0                	add    %edx,%eax
f010384b:	8a 40 04             	mov    0x4(%eax),%al
f010384e:	0f b6 c0             	movzbl %al,%eax
f0103851:	3b 45 14             	cmp    0x14(%ebp),%eax
f0103854:	75 d5                	jne    f010382b <stab_binsearch+0x117>
		     l--)
			/* do nothing */;
		*region_left = l;
f0103856:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103859:	8b 55 fc             	mov    -0x4(%ebp),%edx
f010385c:	89 10                	mov    %edx,(%eax)
	}
}
f010385e:	90                   	nop
f010385f:	c9                   	leave  
f0103860:	c3                   	ret    

f0103861 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uint32*  addr, struct Eipdebuginfo *info)
{
f0103861:	55                   	push   %ebp
f0103862:	89 e5                	mov    %esp,%ebp
f0103864:	83 ec 38             	sub    $0x38,%esp
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103867:	8b 45 0c             	mov    0xc(%ebp),%eax
f010386a:	c7 00 78 5b 10 f0    	movl   $0xf0105b78,(%eax)
	info->eip_line = 0;
f0103870:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103873:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	info->eip_fn_name = "<unknown>";
f010387a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010387d:	c7 40 08 78 5b 10 f0 	movl   $0xf0105b78,0x8(%eax)
	info->eip_fn_namelen = 9;
f0103884:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103887:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
	info->eip_fn_addr = addr;
f010388e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103891:	8b 55 08             	mov    0x8(%ebp),%edx
f0103894:	89 50 10             	mov    %edx,0x10(%eax)
	info->eip_fn_narg = 0;
f0103897:	8b 45 0c             	mov    0xc(%ebp),%eax
f010389a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

	// Find the relevant set of stabs
	if ((uint32)addr >= USER_LIMIT) {
f01038a1:	8b 45 08             	mov    0x8(%ebp),%eax
f01038a4:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f01038a9:	76 1e                	jbe    f01038c9 <debuginfo_eip+0x68>
		stabs = __STAB_BEGIN__;
f01038ab:	c7 45 f4 d0 5d 10 f0 	movl   $0xf0105dd0,-0xc(%ebp)
		stab_end = __STAB_END__;
f01038b2:	c7 45 f0 80 e0 10 f0 	movl   $0xf010e080,-0x10(%ebp)
		stabstr = __STABSTR_BEGIN__;
f01038b9:	c7 45 ec 81 e0 10 f0 	movl   $0xf010e081,-0x14(%ebp)
		stabstr_end = __STABSTR_END__;
f01038c0:	c7 45 e8 3a 17 11 f0 	movl   $0xf011173a,-0x18(%ebp)
f01038c7:	eb 2a                	jmp    f01038f3 <debuginfo_eip+0x92>
		// The user-application linker script, user/user.ld,
		// puts information about the application's stabs (equivalent
		// to __STAB_BEGIN__, __STAB_END__, __STABSTR_BEGIN__, and
		// __STABSTR_END__) in a structure located at virtual address
		// USTABDATA.
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;
f01038c9:	c7 45 e0 00 00 20 00 	movl   $0x200000,-0x20(%ebp)

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		
		stabs = usd->stabs;
f01038d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038d3:	8b 00                	mov    (%eax),%eax
f01038d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
		stab_end = usd->stab_end;
f01038d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038db:	8b 40 04             	mov    0x4(%eax),%eax
f01038de:	89 45 f0             	mov    %eax,-0x10(%ebp)
		stabstr = usd->stabstr;
f01038e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038e4:	8b 40 08             	mov    0x8(%eax),%eax
f01038e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
		stabstr_end = usd->stabstr_end;
f01038ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038ed:	8b 40 0c             	mov    0xc(%eax),%eax
f01038f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01038f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01038f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
f01038f9:	76 0a                	jbe    f0103905 <debuginfo_eip+0xa4>
f01038fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01038fe:	48                   	dec    %eax
f01038ff:	8a 00                	mov    (%eax),%al
f0103901:	84 c0                	test   %al,%al
f0103903:	74 0a                	je     f010390f <debuginfo_eip+0xae>
		return -1;
f0103905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010390a:	e9 01 02 00 00       	jmp    f0103b10 <debuginfo_eip+0x2af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010390f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103916:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103919:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010391c:	29 c2                	sub    %eax,%edx
f010391e:	89 d0                	mov    %edx,%eax
f0103920:	c1 f8 02             	sar    $0x2,%eax
f0103923:	89 c2                	mov    %eax,%edx
f0103925:	89 d0                	mov    %edx,%eax
f0103927:	c1 e0 02             	shl    $0x2,%eax
f010392a:	01 d0                	add    %edx,%eax
f010392c:	c1 e0 02             	shl    $0x2,%eax
f010392f:	01 d0                	add    %edx,%eax
f0103931:	c1 e0 02             	shl    $0x2,%eax
f0103934:	01 d0                	add    %edx,%eax
f0103936:	89 c1                	mov    %eax,%ecx
f0103938:	c1 e1 08             	shl    $0x8,%ecx
f010393b:	01 c8                	add    %ecx,%eax
f010393d:	89 c1                	mov    %eax,%ecx
f010393f:	c1 e1 10             	shl    $0x10,%ecx
f0103942:	01 c8                	add    %ecx,%eax
f0103944:	01 c0                	add    %eax,%eax
f0103946:	01 d0                	add    %edx,%eax
f0103948:	48                   	dec    %eax
f0103949:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010394c:	ff 75 08             	pushl  0x8(%ebp)
f010394f:	6a 64                	push   $0x64
f0103951:	8d 45 d4             	lea    -0x2c(%ebp),%eax
f0103954:	50                   	push   %eax
f0103955:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0103958:	50                   	push   %eax
f0103959:	ff 75 f4             	pushl  -0xc(%ebp)
f010395c:	e8 b3 fd ff ff       	call   f0103714 <stab_binsearch>
f0103961:	83 c4 14             	add    $0x14,%esp
	if (lfile == 0)
f0103964:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103967:	85 c0                	test   %eax,%eax
f0103969:	75 0a                	jne    f0103975 <debuginfo_eip+0x114>
		return -1;
f010396b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103970:	e9 9b 01 00 00       	jmp    f0103b10 <debuginfo_eip+0x2af>

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103975:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103978:	89 45 d0             	mov    %eax,-0x30(%ebp)
	rfun = rfile;
f010397b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010397e:	89 45 cc             	mov    %eax,-0x34(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0103981:	ff 75 08             	pushl  0x8(%ebp)
f0103984:	6a 24                	push   $0x24
f0103986:	8d 45 cc             	lea    -0x34(%ebp),%eax
f0103989:	50                   	push   %eax
f010398a:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010398d:	50                   	push   %eax
f010398e:	ff 75 f4             	pushl  -0xc(%ebp)
f0103991:	e8 7e fd ff ff       	call   f0103714 <stab_binsearch>
f0103996:	83 c4 14             	add    $0x14,%esp

	if (lfun <= rfun) {
f0103999:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010399c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010399f:	39 c2                	cmp    %eax,%edx
f01039a1:	0f 8f 86 00 00 00    	jg     f0103a2d <debuginfo_eip+0x1cc>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01039a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039aa:	89 c2                	mov    %eax,%edx
f01039ac:	89 d0                	mov    %edx,%eax
f01039ae:	01 c0                	add    %eax,%eax
f01039b0:	01 d0                	add    %edx,%eax
f01039b2:	c1 e0 02             	shl    $0x2,%eax
f01039b5:	89 c2                	mov    %eax,%edx
f01039b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039ba:	01 d0                	add    %edx,%eax
f01039bc:	8b 00                	mov    (%eax),%eax
f01039be:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01039c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01039c4:	29 d1                	sub    %edx,%ecx
f01039c6:	89 ca                	mov    %ecx,%edx
f01039c8:	39 d0                	cmp    %edx,%eax
f01039ca:	73 22                	jae    f01039ee <debuginfo_eip+0x18d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01039cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039cf:	89 c2                	mov    %eax,%edx
f01039d1:	89 d0                	mov    %edx,%eax
f01039d3:	01 c0                	add    %eax,%eax
f01039d5:	01 d0                	add    %edx,%eax
f01039d7:	c1 e0 02             	shl    $0x2,%eax
f01039da:	89 c2                	mov    %eax,%edx
f01039dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01039df:	01 d0                	add    %edx,%eax
f01039e1:	8b 10                	mov    (%eax),%edx
f01039e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01039e6:	01 c2                	add    %eax,%edx
f01039e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01039eb:	89 50 08             	mov    %edx,0x8(%eax)
		info->eip_fn_addr = (uint32*) stabs[lfun].n_value;
f01039ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039f1:	89 c2                	mov    %eax,%edx
f01039f3:	89 d0                	mov    %edx,%eax
f01039f5:	01 c0                	add    %eax,%eax
f01039f7:	01 d0                	add    %edx,%eax
f01039f9:	c1 e0 02             	shl    $0x2,%eax
f01039fc:	89 c2                	mov    %eax,%edx
f01039fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a01:	01 d0                	add    %edx,%eax
f0103a03:	8b 50 08             	mov    0x8(%eax),%edx
f0103a06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a09:	89 50 10             	mov    %edx,0x10(%eax)
		addr = (uint32*)(addr - (info->eip_fn_addr));
f0103a0c:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a12:	8b 40 10             	mov    0x10(%eax),%eax
f0103a15:	29 c2                	sub    %eax,%edx
f0103a17:	89 d0                	mov    %edx,%eax
f0103a19:	c1 f8 02             	sar    $0x2,%eax
f0103a1c:	89 45 08             	mov    %eax,0x8(%ebp)
		// Search within the function definition for the line number.
		lline = lfun;
f0103a1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfun;
f0103a25:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103a28:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a2b:	eb 15                	jmp    f0103a42 <debuginfo_eip+0x1e1>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a30:	8b 55 08             	mov    0x8(%ebp),%edx
f0103a33:	89 50 10             	mov    %edx,0x10(%eax)
		lline = lfile;
f0103a36:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		rline = rfile;
f0103a3c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103a3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103a42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a45:	8b 40 08             	mov    0x8(%eax),%eax
f0103a48:	83 ec 08             	sub    $0x8,%esp
f0103a4b:	6a 3a                	push   $0x3a
f0103a4d:	50                   	push   %eax
f0103a4e:	e8 a4 09 00 00       	call   f01043f7 <strfind>
f0103a53:	83 c4 10             	add    $0x10,%esp
f0103a56:	89 c2                	mov    %eax,%edx
f0103a58:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a5b:	8b 40 08             	mov    0x8(%eax),%eax
f0103a5e:	29 c2                	sub    %eax,%edx
f0103a60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a63:	89 50 0c             	mov    %edx,0xc(%eax)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a66:	eb 03                	jmp    f0103a6b <debuginfo_eip+0x20a>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0103a68:	ff 4d e4             	decl   -0x1c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103a6b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a6e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103a71:	7c 4e                	jl     f0103ac1 <debuginfo_eip+0x260>
	       && stabs[lline].n_type != N_SOL
f0103a73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103a76:	89 d0                	mov    %edx,%eax
f0103a78:	01 c0                	add    %eax,%eax
f0103a7a:	01 d0                	add    %edx,%eax
f0103a7c:	c1 e0 02             	shl    $0x2,%eax
f0103a7f:	89 c2                	mov    %eax,%edx
f0103a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a84:	01 d0                	add    %edx,%eax
f0103a86:	8a 40 04             	mov    0x4(%eax),%al
f0103a89:	3c 84                	cmp    $0x84,%al
f0103a8b:	74 34                	je     f0103ac1 <debuginfo_eip+0x260>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103a8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103a90:	89 d0                	mov    %edx,%eax
f0103a92:	01 c0                	add    %eax,%eax
f0103a94:	01 d0                	add    %edx,%eax
f0103a96:	c1 e0 02             	shl    $0x2,%eax
f0103a99:	89 c2                	mov    %eax,%edx
f0103a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103a9e:	01 d0                	add    %edx,%eax
f0103aa0:	8a 40 04             	mov    0x4(%eax),%al
f0103aa3:	3c 64                	cmp    $0x64,%al
f0103aa5:	75 c1                	jne    f0103a68 <debuginfo_eip+0x207>
f0103aa7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103aaa:	89 d0                	mov    %edx,%eax
f0103aac:	01 c0                	add    %eax,%eax
f0103aae:	01 d0                	add    %edx,%eax
f0103ab0:	c1 e0 02             	shl    $0x2,%eax
f0103ab3:	89 c2                	mov    %eax,%edx
f0103ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ab8:	01 d0                	add    %edx,%eax
f0103aba:	8b 40 08             	mov    0x8(%eax),%eax
f0103abd:	85 c0                	test   %eax,%eax
f0103abf:	74 a7                	je     f0103a68 <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103ac1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ac4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
f0103ac7:	7c 42                	jl     f0103b0b <debuginfo_eip+0x2aa>
f0103ac9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103acc:	89 d0                	mov    %edx,%eax
f0103ace:	01 c0                	add    %eax,%eax
f0103ad0:	01 d0                	add    %edx,%eax
f0103ad2:	c1 e0 02             	shl    $0x2,%eax
f0103ad5:	89 c2                	mov    %eax,%edx
f0103ad7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ada:	01 d0                	add    %edx,%eax
f0103adc:	8b 00                	mov    (%eax),%eax
f0103ade:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103ae1:	8b 55 ec             	mov    -0x14(%ebp),%edx
f0103ae4:	29 d1                	sub    %edx,%ecx
f0103ae6:	89 ca                	mov    %ecx,%edx
f0103ae8:	39 d0                	cmp    %edx,%eax
f0103aea:	73 1f                	jae    f0103b0b <debuginfo_eip+0x2aa>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103aec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103aef:	89 d0                	mov    %edx,%eax
f0103af1:	01 c0                	add    %eax,%eax
f0103af3:	01 d0                	add    %edx,%eax
f0103af5:	c1 e0 02             	shl    $0x2,%eax
f0103af8:	89 c2                	mov    %eax,%edx
f0103afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103afd:	01 d0                	add    %edx,%eax
f0103aff:	8b 10                	mov    (%eax),%edx
f0103b01:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103b04:	01 c2                	add    %eax,%edx
f0103b06:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b09:	89 10                	mov    %edx,(%eax)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	// Your code here.

	
	return 0;
f0103b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103b10:	c9                   	leave  
f0103b11:	c3                   	ret    

f0103b12 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103b12:	55                   	push   %ebp
f0103b13:	89 e5                	mov    %esp,%ebp
f0103b15:	53                   	push   %ebx
f0103b16:	83 ec 14             	sub    $0x14,%esp
f0103b19:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103b1f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b22:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103b25:	8b 45 18             	mov    0x18(%ebp),%eax
f0103b28:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b2d:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103b30:	77 55                	ja     f0103b87 <printnum+0x75>
f0103b32:	3b 55 f4             	cmp    -0xc(%ebp),%edx
f0103b35:	72 05                	jb     f0103b3c <printnum+0x2a>
f0103b37:	3b 45 f0             	cmp    -0x10(%ebp),%eax
f0103b3a:	77 4b                	ja     f0103b87 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103b3c:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0103b3f:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0103b42:	8b 45 18             	mov    0x18(%ebp),%eax
f0103b45:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b4a:	52                   	push   %edx
f0103b4b:	50                   	push   %eax
f0103b4c:	ff 75 f4             	pushl  -0xc(%ebp)
f0103b4f:	ff 75 f0             	pushl  -0x10(%ebp)
f0103b52:	e8 59 0c 00 00       	call   f01047b0 <__udivdi3>
f0103b57:	83 c4 10             	add    $0x10,%esp
f0103b5a:	83 ec 04             	sub    $0x4,%esp
f0103b5d:	ff 75 20             	pushl  0x20(%ebp)
f0103b60:	53                   	push   %ebx
f0103b61:	ff 75 18             	pushl  0x18(%ebp)
f0103b64:	52                   	push   %edx
f0103b65:	50                   	push   %eax
f0103b66:	ff 75 0c             	pushl  0xc(%ebp)
f0103b69:	ff 75 08             	pushl  0x8(%ebp)
f0103b6c:	e8 a1 ff ff ff       	call   f0103b12 <printnum>
f0103b71:	83 c4 20             	add    $0x20,%esp
f0103b74:	eb 1a                	jmp    f0103b90 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103b76:	83 ec 08             	sub    $0x8,%esp
f0103b79:	ff 75 0c             	pushl  0xc(%ebp)
f0103b7c:	ff 75 20             	pushl  0x20(%ebp)
f0103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b82:	ff d0                	call   *%eax
f0103b84:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103b87:	ff 4d 1c             	decl   0x1c(%ebp)
f0103b8a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
f0103b8e:	7f e6                	jg     f0103b76 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103b90:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0103b93:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103b9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103b9e:	53                   	push   %ebx
f0103b9f:	51                   	push   %ecx
f0103ba0:	52                   	push   %edx
f0103ba1:	50                   	push   %eax
f0103ba2:	e8 19 0d 00 00       	call   f01048c0 <__umoddi3>
f0103ba7:	83 c4 10             	add    $0x10,%esp
f0103baa:	05 40 5c 10 f0       	add    $0xf0105c40,%eax
f0103baf:	8a 00                	mov    (%eax),%al
f0103bb1:	0f be c0             	movsbl %al,%eax
f0103bb4:	83 ec 08             	sub    $0x8,%esp
f0103bb7:	ff 75 0c             	pushl  0xc(%ebp)
f0103bba:	50                   	push   %eax
f0103bbb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bbe:	ff d0                	call   *%eax
f0103bc0:	83 c4 10             	add    $0x10,%esp
}
f0103bc3:	90                   	nop
f0103bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103bc7:	c9                   	leave  
f0103bc8:	c3                   	ret    

f0103bc9 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103bc9:	55                   	push   %ebp
f0103bca:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103bcc:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103bd0:	7e 1c                	jle    f0103bee <getuint+0x25>
		return va_arg(*ap, unsigned long long);
f0103bd2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bd5:	8b 00                	mov    (%eax),%eax
f0103bd7:	8d 50 08             	lea    0x8(%eax),%edx
f0103bda:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bdd:	89 10                	mov    %edx,(%eax)
f0103bdf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103be2:	8b 00                	mov    (%eax),%eax
f0103be4:	83 e8 08             	sub    $0x8,%eax
f0103be7:	8b 50 04             	mov    0x4(%eax),%edx
f0103bea:	8b 00                	mov    (%eax),%eax
f0103bec:	eb 40                	jmp    f0103c2e <getuint+0x65>
	else if (lflag)
f0103bee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103bf2:	74 1e                	je     f0103c12 <getuint+0x49>
		return va_arg(*ap, unsigned long);
f0103bf4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bf7:	8b 00                	mov    (%eax),%eax
f0103bf9:	8d 50 04             	lea    0x4(%eax),%edx
f0103bfc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bff:	89 10                	mov    %edx,(%eax)
f0103c01:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c04:	8b 00                	mov    (%eax),%eax
f0103c06:	83 e8 04             	sub    $0x4,%eax
f0103c09:	8b 00                	mov    (%eax),%eax
f0103c0b:	ba 00 00 00 00       	mov    $0x0,%edx
f0103c10:	eb 1c                	jmp    f0103c2e <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
f0103c12:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c15:	8b 00                	mov    (%eax),%eax
f0103c17:	8d 50 04             	lea    0x4(%eax),%edx
f0103c1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c1d:	89 10                	mov    %edx,(%eax)
f0103c1f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c22:	8b 00                	mov    (%eax),%eax
f0103c24:	83 e8 04             	sub    $0x4,%eax
f0103c27:	8b 00                	mov    (%eax),%eax
f0103c29:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103c2e:	5d                   	pop    %ebp
f0103c2f:	c3                   	ret    

f0103c30 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
f0103c30:	55                   	push   %ebp
f0103c31:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103c33:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
f0103c37:	7e 1c                	jle    f0103c55 <getint+0x25>
		return va_arg(*ap, long long);
f0103c39:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c3c:	8b 00                	mov    (%eax),%eax
f0103c3e:	8d 50 08             	lea    0x8(%eax),%edx
f0103c41:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c44:	89 10                	mov    %edx,(%eax)
f0103c46:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c49:	8b 00                	mov    (%eax),%eax
f0103c4b:	83 e8 08             	sub    $0x8,%eax
f0103c4e:	8b 50 04             	mov    0x4(%eax),%edx
f0103c51:	8b 00                	mov    (%eax),%eax
f0103c53:	eb 38                	jmp    f0103c8d <getint+0x5d>
	else if (lflag)
f0103c55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103c59:	74 1a                	je     f0103c75 <getint+0x45>
		return va_arg(*ap, long);
f0103c5b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c5e:	8b 00                	mov    (%eax),%eax
f0103c60:	8d 50 04             	lea    0x4(%eax),%edx
f0103c63:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c66:	89 10                	mov    %edx,(%eax)
f0103c68:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c6b:	8b 00                	mov    (%eax),%eax
f0103c6d:	83 e8 04             	sub    $0x4,%eax
f0103c70:	8b 00                	mov    (%eax),%eax
f0103c72:	99                   	cltd   
f0103c73:	eb 18                	jmp    f0103c8d <getint+0x5d>
	else
		return va_arg(*ap, int);
f0103c75:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c78:	8b 00                	mov    (%eax),%eax
f0103c7a:	8d 50 04             	lea    0x4(%eax),%edx
f0103c7d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c80:	89 10                	mov    %edx,(%eax)
f0103c82:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c85:	8b 00                	mov    (%eax),%eax
f0103c87:	83 e8 04             	sub    $0x4,%eax
f0103c8a:	8b 00                	mov    (%eax),%eax
f0103c8c:	99                   	cltd   
}
f0103c8d:	5d                   	pop    %ebp
f0103c8e:	c3                   	ret    

f0103c8f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103c8f:	55                   	push   %ebp
f0103c90:	89 e5                	mov    %esp,%ebp
f0103c92:	56                   	push   %esi
f0103c93:	53                   	push   %ebx
f0103c94:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103c97:	eb 17                	jmp    f0103cb0 <vprintfmt+0x21>
			if (ch == '\0')
f0103c99:	85 db                	test   %ebx,%ebx
f0103c9b:	0f 84 af 03 00 00    	je     f0104050 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
f0103ca1:	83 ec 08             	sub    $0x8,%esp
f0103ca4:	ff 75 0c             	pushl  0xc(%ebp)
f0103ca7:	53                   	push   %ebx
f0103ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cab:	ff d0                	call   *%eax
f0103cad:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103cb0:	8b 45 10             	mov    0x10(%ebp),%eax
f0103cb3:	8d 50 01             	lea    0x1(%eax),%edx
f0103cb6:	89 55 10             	mov    %edx,0x10(%ebp)
f0103cb9:	8a 00                	mov    (%eax),%al
f0103cbb:	0f b6 d8             	movzbl %al,%ebx
f0103cbe:	83 fb 25             	cmp    $0x25,%ebx
f0103cc1:	75 d6                	jne    f0103c99 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
f0103cc3:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
f0103cc7:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
f0103cce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0103cd5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
f0103cdc:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ce3:	8b 45 10             	mov    0x10(%ebp),%eax
f0103ce6:	8d 50 01             	lea    0x1(%eax),%edx
f0103ce9:	89 55 10             	mov    %edx,0x10(%ebp)
f0103cec:	8a 00                	mov    (%eax),%al
f0103cee:	0f b6 d8             	movzbl %al,%ebx
f0103cf1:	8d 43 dd             	lea    -0x23(%ebx),%eax
f0103cf4:	83 f8 55             	cmp    $0x55,%eax
f0103cf7:	0f 87 2b 03 00 00    	ja     f0104028 <vprintfmt+0x399>
f0103cfd:	8b 04 85 64 5c 10 f0 	mov    -0xfefa39c(,%eax,4),%eax
f0103d04:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
f0103d06:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
f0103d0a:	eb d7                	jmp    f0103ce3 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103d0c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
f0103d10:	eb d1                	jmp    f0103ce3 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103d12:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
f0103d19:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d1c:	89 d0                	mov    %edx,%eax
f0103d1e:	c1 e0 02             	shl    $0x2,%eax
f0103d21:	01 d0                	add    %edx,%eax
f0103d23:	01 c0                	add    %eax,%eax
f0103d25:	01 d8                	add    %ebx,%eax
f0103d27:	83 e8 30             	sub    $0x30,%eax
f0103d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
f0103d2d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103d30:	8a 00                	mov    (%eax),%al
f0103d32:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
f0103d35:	83 fb 2f             	cmp    $0x2f,%ebx
f0103d38:	7e 3e                	jle    f0103d78 <vprintfmt+0xe9>
f0103d3a:	83 fb 39             	cmp    $0x39,%ebx
f0103d3d:	7f 39                	jg     f0103d78 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103d3f:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103d42:	eb d5                	jmp    f0103d19 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103d44:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d47:	83 c0 04             	add    $0x4,%eax
f0103d4a:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d4d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d50:	83 e8 04             	sub    $0x4,%eax
f0103d53:	8b 00                	mov    (%eax),%eax
f0103d55:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
f0103d58:	eb 1f                	jmp    f0103d79 <vprintfmt+0xea>

		case '.':
			if (width < 0)
f0103d5a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d5e:	79 83                	jns    f0103ce3 <vprintfmt+0x54>
				width = 0;
f0103d60:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
f0103d67:	e9 77 ff ff ff       	jmp    f0103ce3 <vprintfmt+0x54>

		case '#':
			altflag = 1;
f0103d6c:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103d73:	e9 6b ff ff ff       	jmp    f0103ce3 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
f0103d78:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103d79:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d7d:	0f 89 60 ff ff ff    	jns    f0103ce3 <vprintfmt+0x54>
				width = precision, precision = -1;
f0103d83:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103d89:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
f0103d90:	e9 4e ff ff ff       	jmp    f0103ce3 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103d95:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
f0103d98:	e9 46 ff ff ff       	jmp    f0103ce3 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103da0:	83 c0 04             	add    $0x4,%eax
f0103da3:	89 45 14             	mov    %eax,0x14(%ebp)
f0103da6:	8b 45 14             	mov    0x14(%ebp),%eax
f0103da9:	83 e8 04             	sub    $0x4,%eax
f0103dac:	8b 00                	mov    (%eax),%eax
f0103dae:	83 ec 08             	sub    $0x8,%esp
f0103db1:	ff 75 0c             	pushl  0xc(%ebp)
f0103db4:	50                   	push   %eax
f0103db5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103db8:	ff d0                	call   *%eax
f0103dba:	83 c4 10             	add    $0x10,%esp
			break;
f0103dbd:	e9 89 02 00 00       	jmp    f010404b <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103dc2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dc5:	83 c0 04             	add    $0x4,%eax
f0103dc8:	89 45 14             	mov    %eax,0x14(%ebp)
f0103dcb:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dce:	83 e8 04             	sub    $0x4,%eax
f0103dd1:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
f0103dd3:	85 db                	test   %ebx,%ebx
f0103dd5:	79 02                	jns    f0103dd9 <vprintfmt+0x14a>
				err = -err;
f0103dd7:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
f0103dd9:	83 fb 07             	cmp    $0x7,%ebx
f0103ddc:	7f 0b                	jg     f0103de9 <vprintfmt+0x15a>
f0103dde:	8b 34 9d 20 5c 10 f0 	mov    -0xfefa3e0(,%ebx,4),%esi
f0103de5:	85 f6                	test   %esi,%esi
f0103de7:	75 19                	jne    f0103e02 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
f0103de9:	53                   	push   %ebx
f0103dea:	68 51 5c 10 f0       	push   $0xf0105c51
f0103def:	ff 75 0c             	pushl  0xc(%ebp)
f0103df2:	ff 75 08             	pushl  0x8(%ebp)
f0103df5:	e8 5e 02 00 00       	call   f0104058 <printfmt>
f0103dfa:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
f0103dfd:	e9 49 02 00 00       	jmp    f010404b <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0103e02:	56                   	push   %esi
f0103e03:	68 5a 5c 10 f0       	push   $0xf0105c5a
f0103e08:	ff 75 0c             	pushl  0xc(%ebp)
f0103e0b:	ff 75 08             	pushl  0x8(%ebp)
f0103e0e:	e8 45 02 00 00       	call   f0104058 <printfmt>
f0103e13:	83 c4 10             	add    $0x10,%esp
			break;
f0103e16:	e9 30 02 00 00       	jmp    f010404b <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103e1b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e1e:	83 c0 04             	add    $0x4,%eax
f0103e21:	89 45 14             	mov    %eax,0x14(%ebp)
f0103e24:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e27:	83 e8 04             	sub    $0x4,%eax
f0103e2a:	8b 30                	mov    (%eax),%esi
f0103e2c:	85 f6                	test   %esi,%esi
f0103e2e:	75 05                	jne    f0103e35 <vprintfmt+0x1a6>
				p = "(null)";
f0103e30:	be 5d 5c 10 f0       	mov    $0xf0105c5d,%esi
			if (width > 0 && padc != '-')
f0103e35:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103e39:	7e 6d                	jle    f0103ea8 <vprintfmt+0x219>
f0103e3b:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
f0103e3f:	74 67                	je     f0103ea8 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103e44:	83 ec 08             	sub    $0x8,%esp
f0103e47:	50                   	push   %eax
f0103e48:	56                   	push   %esi
f0103e49:	e8 0a 04 00 00       	call   f0104258 <strnlen>
f0103e4e:	83 c4 10             	add    $0x10,%esp
f0103e51:	29 45 e4             	sub    %eax,-0x1c(%ebp)
f0103e54:	eb 16                	jmp    f0103e6c <vprintfmt+0x1dd>
					putch(padc, putdat);
f0103e56:	0f be 45 db          	movsbl -0x25(%ebp),%eax
f0103e5a:	83 ec 08             	sub    $0x8,%esp
f0103e5d:	ff 75 0c             	pushl  0xc(%ebp)
f0103e60:	50                   	push   %eax
f0103e61:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e64:	ff d0                	call   *%eax
f0103e66:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103e69:	ff 4d e4             	decl   -0x1c(%ebp)
f0103e6c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103e70:	7f e4                	jg     f0103e56 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103e72:	eb 34                	jmp    f0103ea8 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
f0103e74:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103e78:	74 1c                	je     f0103e96 <vprintfmt+0x207>
f0103e7a:	83 fb 1f             	cmp    $0x1f,%ebx
f0103e7d:	7e 05                	jle    f0103e84 <vprintfmt+0x1f5>
f0103e7f:	83 fb 7e             	cmp    $0x7e,%ebx
f0103e82:	7e 12                	jle    f0103e96 <vprintfmt+0x207>
					putch('?', putdat);
f0103e84:	83 ec 08             	sub    $0x8,%esp
f0103e87:	ff 75 0c             	pushl  0xc(%ebp)
f0103e8a:	6a 3f                	push   $0x3f
f0103e8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e8f:	ff d0                	call   *%eax
f0103e91:	83 c4 10             	add    $0x10,%esp
f0103e94:	eb 0f                	jmp    f0103ea5 <vprintfmt+0x216>
				else
					putch(ch, putdat);
f0103e96:	83 ec 08             	sub    $0x8,%esp
f0103e99:	ff 75 0c             	pushl  0xc(%ebp)
f0103e9c:	53                   	push   %ebx
f0103e9d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ea0:	ff d0                	call   *%eax
f0103ea2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103ea5:	ff 4d e4             	decl   -0x1c(%ebp)
f0103ea8:	89 f0                	mov    %esi,%eax
f0103eaa:	8d 70 01             	lea    0x1(%eax),%esi
f0103ead:	8a 00                	mov    (%eax),%al
f0103eaf:	0f be d8             	movsbl %al,%ebx
f0103eb2:	85 db                	test   %ebx,%ebx
f0103eb4:	74 24                	je     f0103eda <vprintfmt+0x24b>
f0103eb6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103eba:	78 b8                	js     f0103e74 <vprintfmt+0x1e5>
f0103ebc:	ff 4d e0             	decl   -0x20(%ebp)
f0103ebf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103ec3:	79 af                	jns    f0103e74 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103ec5:	eb 13                	jmp    f0103eda <vprintfmt+0x24b>
				putch(' ', putdat);
f0103ec7:	83 ec 08             	sub    $0x8,%esp
f0103eca:	ff 75 0c             	pushl  0xc(%ebp)
f0103ecd:	6a 20                	push   $0x20
f0103ecf:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ed2:	ff d0                	call   *%eax
f0103ed4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103ed7:	ff 4d e4             	decl   -0x1c(%ebp)
f0103eda:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103ede:	7f e7                	jg     f0103ec7 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
f0103ee0:	e9 66 01 00 00       	jmp    f010404b <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103ee5:	83 ec 08             	sub    $0x8,%esp
f0103ee8:	ff 75 e8             	pushl  -0x18(%ebp)
f0103eeb:	8d 45 14             	lea    0x14(%ebp),%eax
f0103eee:	50                   	push   %eax
f0103eef:	e8 3c fd ff ff       	call   f0103c30 <getint>
f0103ef4:	83 c4 10             	add    $0x10,%esp
f0103ef7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103efa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
f0103efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103f03:	85 d2                	test   %edx,%edx
f0103f05:	79 23                	jns    f0103f2a <vprintfmt+0x29b>
				putch('-', putdat);
f0103f07:	83 ec 08             	sub    $0x8,%esp
f0103f0a:	ff 75 0c             	pushl  0xc(%ebp)
f0103f0d:	6a 2d                	push   $0x2d
f0103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f12:	ff d0                	call   *%eax
f0103f14:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
f0103f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0103f1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0103f1d:	f7 d8                	neg    %eax
f0103f1f:	83 d2 00             	adc    $0x0,%edx
f0103f22:	f7 da                	neg    %edx
f0103f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f27:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
f0103f2a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0103f31:	e9 bc 00 00 00       	jmp    f0103ff2 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103f36:	83 ec 08             	sub    $0x8,%esp
f0103f39:	ff 75 e8             	pushl  -0x18(%ebp)
f0103f3c:	8d 45 14             	lea    0x14(%ebp),%eax
f0103f3f:	50                   	push   %eax
f0103f40:	e8 84 fc ff ff       	call   f0103bc9 <getuint>
f0103f45:	83 c4 10             	add    $0x10,%esp
f0103f48:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103f4b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
f0103f4e:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
f0103f55:	e9 98 00 00 00       	jmp    f0103ff2 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0103f5a:	83 ec 08             	sub    $0x8,%esp
f0103f5d:	ff 75 0c             	pushl  0xc(%ebp)
f0103f60:	6a 58                	push   $0x58
f0103f62:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f65:	ff d0                	call   *%eax
f0103f67:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f0103f6a:	83 ec 08             	sub    $0x8,%esp
f0103f6d:	ff 75 0c             	pushl  0xc(%ebp)
f0103f70:	6a 58                	push   $0x58
f0103f72:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f75:	ff d0                	call   *%eax
f0103f77:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
f0103f7a:	83 ec 08             	sub    $0x8,%esp
f0103f7d:	ff 75 0c             	pushl  0xc(%ebp)
f0103f80:	6a 58                	push   $0x58
f0103f82:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f85:	ff d0                	call   *%eax
f0103f87:	83 c4 10             	add    $0x10,%esp
			break;
f0103f8a:	e9 bc 00 00 00       	jmp    f010404b <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
f0103f8f:	83 ec 08             	sub    $0x8,%esp
f0103f92:	ff 75 0c             	pushl  0xc(%ebp)
f0103f95:	6a 30                	push   $0x30
f0103f97:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9a:	ff d0                	call   *%eax
f0103f9c:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
f0103f9f:	83 ec 08             	sub    $0x8,%esp
f0103fa2:	ff 75 0c             	pushl  0xc(%ebp)
f0103fa5:	6a 78                	push   $0x78
f0103fa7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103faa:	ff d0                	call   *%eax
f0103fac:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
f0103faf:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fb2:	83 c0 04             	add    $0x4,%eax
f0103fb5:	89 45 14             	mov    %eax,0x14(%ebp)
f0103fb8:	8b 45 14             	mov    0x14(%ebp),%eax
f0103fbb:	83 e8 04             	sub    $0x4,%eax
f0103fbe:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103fc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
f0103fca:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
f0103fd1:	eb 1f                	jmp    f0103ff2 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103fd3:	83 ec 08             	sub    $0x8,%esp
f0103fd6:	ff 75 e8             	pushl  -0x18(%ebp)
f0103fd9:	8d 45 14             	lea    0x14(%ebp),%eax
f0103fdc:	50                   	push   %eax
f0103fdd:	e8 e7 fb ff ff       	call   f0103bc9 <getuint>
f0103fe2:	83 c4 10             	add    $0x10,%esp
f0103fe5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103fe8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
f0103feb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103ff2:	0f be 55 db          	movsbl -0x25(%ebp),%edx
f0103ff6:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ff9:	83 ec 04             	sub    $0x4,%esp
f0103ffc:	52                   	push   %edx
f0103ffd:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104000:	50                   	push   %eax
f0104001:	ff 75 f4             	pushl  -0xc(%ebp)
f0104004:	ff 75 f0             	pushl  -0x10(%ebp)
f0104007:	ff 75 0c             	pushl  0xc(%ebp)
f010400a:	ff 75 08             	pushl  0x8(%ebp)
f010400d:	e8 00 fb ff ff       	call   f0103b12 <printnum>
f0104012:	83 c4 20             	add    $0x20,%esp
			break;
f0104015:	eb 34                	jmp    f010404b <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104017:	83 ec 08             	sub    $0x8,%esp
f010401a:	ff 75 0c             	pushl  0xc(%ebp)
f010401d:	53                   	push   %ebx
f010401e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104021:	ff d0                	call   *%eax
f0104023:	83 c4 10             	add    $0x10,%esp
			break;
f0104026:	eb 23                	jmp    f010404b <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104028:	83 ec 08             	sub    $0x8,%esp
f010402b:	ff 75 0c             	pushl  0xc(%ebp)
f010402e:	6a 25                	push   $0x25
f0104030:	8b 45 08             	mov    0x8(%ebp),%eax
f0104033:	ff d0                	call   *%eax
f0104035:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104038:	ff 4d 10             	decl   0x10(%ebp)
f010403b:	eb 03                	jmp    f0104040 <vprintfmt+0x3b1>
f010403d:	ff 4d 10             	decl   0x10(%ebp)
f0104040:	8b 45 10             	mov    0x10(%ebp),%eax
f0104043:	48                   	dec    %eax
f0104044:	8a 00                	mov    (%eax),%al
f0104046:	3c 25                	cmp    $0x25,%al
f0104048:	75 f3                	jne    f010403d <vprintfmt+0x3ae>
				/* do nothing */;
			break;
f010404a:	90                   	nop
		}
	}
f010404b:	e9 47 fc ff ff       	jmp    f0103c97 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
f0104050:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0104051:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104054:	5b                   	pop    %ebx
f0104055:	5e                   	pop    %esi
f0104056:	5d                   	pop    %ebp
f0104057:	c3                   	ret    

f0104058 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104058:	55                   	push   %ebp
f0104059:	89 e5                	mov    %esp,%ebp
f010405b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010405e:	8d 45 10             	lea    0x10(%ebp),%eax
f0104061:	83 c0 04             	add    $0x4,%eax
f0104064:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
f0104067:	8b 45 10             	mov    0x10(%ebp),%eax
f010406a:	ff 75 f4             	pushl  -0xc(%ebp)
f010406d:	50                   	push   %eax
f010406e:	ff 75 0c             	pushl  0xc(%ebp)
f0104071:	ff 75 08             	pushl  0x8(%ebp)
f0104074:	e8 16 fc ff ff       	call   f0103c8f <vprintfmt>
f0104079:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
f010407c:	90                   	nop
f010407d:	c9                   	leave  
f010407e:	c3                   	ret    

f010407f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010407f:	55                   	push   %ebp
f0104080:	89 e5                	mov    %esp,%ebp
	b->cnt++;
f0104082:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104085:	8b 40 08             	mov    0x8(%eax),%eax
f0104088:	8d 50 01             	lea    0x1(%eax),%edx
f010408b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010408e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
f0104091:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104094:	8b 10                	mov    (%eax),%edx
f0104096:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104099:	8b 40 04             	mov    0x4(%eax),%eax
f010409c:	39 c2                	cmp    %eax,%edx
f010409e:	73 12                	jae    f01040b2 <sprintputch+0x33>
		*b->buf++ = ch;
f01040a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040a3:	8b 00                	mov    (%eax),%eax
f01040a5:	8d 48 01             	lea    0x1(%eax),%ecx
f01040a8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040ab:	89 0a                	mov    %ecx,(%edx)
f01040ad:	8b 55 08             	mov    0x8(%ebp),%edx
f01040b0:	88 10                	mov    %dl,(%eax)
}
f01040b2:	90                   	nop
f01040b3:	5d                   	pop    %ebp
f01040b4:	c3                   	ret    

f01040b5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01040b5:	55                   	push   %ebp
f01040b6:	89 e5                	mov    %esp,%ebp
f01040b8:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
f01040bb:	8b 45 08             	mov    0x8(%ebp),%eax
f01040be:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01040c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01040c4:	8d 50 ff             	lea    -0x1(%eax),%edx
f01040c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040ca:	01 d0                	add    %edx,%eax
f01040cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01040cf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01040d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01040da:	74 06                	je     f01040e2 <vsnprintf+0x2d>
f01040dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01040e0:	7f 07                	jg     f01040e9 <vsnprintf+0x34>
		return -E_INVAL;
f01040e2:	b8 03 00 00 00       	mov    $0x3,%eax
f01040e7:	eb 20                	jmp    f0104109 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01040e9:	ff 75 14             	pushl  0x14(%ebp)
f01040ec:	ff 75 10             	pushl  0x10(%ebp)
f01040ef:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01040f2:	50                   	push   %eax
f01040f3:	68 7f 40 10 f0       	push   $0xf010407f
f01040f8:	e8 92 fb ff ff       	call   f0103c8f <vprintfmt>
f01040fd:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
f0104100:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104103:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104106:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0104109:	c9                   	leave  
f010410a:	c3                   	ret    

f010410b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010410b:	55                   	push   %ebp
f010410c:	89 e5                	mov    %esp,%ebp
f010410e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104111:	8d 45 10             	lea    0x10(%ebp),%eax
f0104114:	83 c0 04             	add    $0x4,%eax
f0104117:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
f010411a:	8b 45 10             	mov    0x10(%ebp),%eax
f010411d:	ff 75 f4             	pushl  -0xc(%ebp)
f0104120:	50                   	push   %eax
f0104121:	ff 75 0c             	pushl  0xc(%ebp)
f0104124:	ff 75 08             	pushl  0x8(%ebp)
f0104127:	e8 89 ff ff ff       	call   f01040b5 <vsnprintf>
f010412c:	83 c4 10             	add    $0x10,%esp
f010412f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
f0104132:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
f0104135:	c9                   	leave  
f0104136:	c3                   	ret    

f0104137 <readline>:

#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
f0104137:	55                   	push   %ebp
f0104138:	89 e5                	mov    %esp,%ebp
f010413a:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing;
	
	if (prompt != NULL)
f010413d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0104141:	74 13                	je     f0104156 <readline+0x1f>
		cprintf("%s", prompt);
f0104143:	83 ec 08             	sub    $0x8,%esp
f0104146:	ff 75 08             	pushl  0x8(%ebp)
f0104149:	68 bc 5d 10 f0       	push   $0xf0105dbc
f010414e:	e8 ee eb ff ff       	call   f0102d41 <cprintf>
f0104153:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
f0104156:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);	
f010415d:	83 ec 0c             	sub    $0xc,%esp
f0104160:	6a 00                	push   $0x0
f0104162:	e8 e0 c7 ff ff       	call   f0100947 <iscons>
f0104167:	83 c4 10             	add    $0x10,%esp
f010416a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
f010416d:	e8 bc c7 ff ff       	call   f010092e <getchar>
f0104172:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
f0104175:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0104179:	79 22                	jns    f010419d <readline+0x66>
			if (c != -E_EOF)
f010417b:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
f010417f:	0f 84 ad 00 00 00    	je     f0104232 <readline+0xfb>
				cprintf("read error: %e\n", c);			
f0104185:	83 ec 08             	sub    $0x8,%esp
f0104188:	ff 75 ec             	pushl  -0x14(%ebp)
f010418b:	68 bf 5d 10 f0       	push   $0xf0105dbf
f0104190:	e8 ac eb ff ff       	call   f0102d41 <cprintf>
f0104195:	83 c4 10             	add    $0x10,%esp
			return;
f0104198:	e9 95 00 00 00       	jmp    f0104232 <readline+0xfb>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010419d:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
f01041a1:	7e 34                	jle    f01041d7 <readline+0xa0>
f01041a3:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
f01041aa:	7f 2b                	jg     f01041d7 <readline+0xa0>
			if (echoing)
f01041ac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01041b0:	74 0e                	je     f01041c0 <readline+0x89>
				cputchar(c);
f01041b2:	83 ec 0c             	sub    $0xc,%esp
f01041b5:	ff 75 ec             	pushl  -0x14(%ebp)
f01041b8:	e8 5a c7 ff ff       	call   f0100917 <cputchar>
f01041bd:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01041c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01041c3:	8d 50 01             	lea    0x1(%eax),%edx
f01041c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01041c9:	89 c2                	mov    %eax,%edx
f01041cb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041ce:	01 d0                	add    %edx,%eax
f01041d0:	8b 55 ec             	mov    -0x14(%ebp),%edx
f01041d3:	88 10                	mov    %dl,(%eax)
f01041d5:	eb 56                	jmp    f010422d <readline+0xf6>
		} else if (c == '\b' && i > 0) {
f01041d7:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
f01041db:	75 1f                	jne    f01041fc <readline+0xc5>
f01041dd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
f01041e1:	7e 19                	jle    f01041fc <readline+0xc5>
			if (echoing)
f01041e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01041e7:	74 0e                	je     f01041f7 <readline+0xc0>
				cputchar(c);
f01041e9:	83 ec 0c             	sub    $0xc,%esp
f01041ec:	ff 75 ec             	pushl  -0x14(%ebp)
f01041ef:	e8 23 c7 ff ff       	call   f0100917 <cputchar>
f01041f4:	83 c4 10             	add    $0x10,%esp
			i--;
f01041f7:	ff 4d f4             	decl   -0xc(%ebp)
f01041fa:	eb 31                	jmp    f010422d <readline+0xf6>
		} else if (c == '\n' || c == '\r') {
f01041fc:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
f0104200:	74 0a                	je     f010420c <readline+0xd5>
f0104202:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
f0104206:	0f 85 61 ff ff ff    	jne    f010416d <readline+0x36>
			if (echoing)
f010420c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0104210:	74 0e                	je     f0104220 <readline+0xe9>
				cputchar(c);
f0104212:	83 ec 0c             	sub    $0xc,%esp
f0104215:	ff 75 ec             	pushl  -0x14(%ebp)
f0104218:	e8 fa c6 ff ff       	call   f0100917 <cputchar>
f010421d:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
f0104220:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104223:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104226:	01 d0                	add    %edx,%eax
f0104228:	c6 00 00             	movb   $0x0,(%eax)
			return;		
f010422b:	eb 06                	jmp    f0104233 <readline+0xfc>
		}
	}
f010422d:	e9 3b ff ff ff       	jmp    f010416d <readline+0x36>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);			
			return;
f0104232:	90                   	nop
				cputchar(c);
			buf[i] = 0;	
			return;		
		}
	}
}
f0104233:	c9                   	leave  
f0104234:	c3                   	ret    

f0104235 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0104235:	55                   	push   %ebp
f0104236:	89 e5                	mov    %esp,%ebp
f0104238:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
f010423b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0104242:	eb 06                	jmp    f010424a <strlen+0x15>
		n++;
f0104244:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104247:	ff 45 08             	incl   0x8(%ebp)
f010424a:	8b 45 08             	mov    0x8(%ebp),%eax
f010424d:	8a 00                	mov    (%eax),%al
f010424f:	84 c0                	test   %al,%al
f0104251:	75 f1                	jne    f0104244 <strlen+0xf>
		n++;
	return n;
f0104253:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104256:	c9                   	leave  
f0104257:	c3                   	ret    

f0104258 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
f0104258:	55                   	push   %ebp
f0104259:	89 e5                	mov    %esp,%ebp
f010425b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010425e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f0104265:	eb 09                	jmp    f0104270 <strnlen+0x18>
		n++;
f0104267:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010426a:	ff 45 08             	incl   0x8(%ebp)
f010426d:	ff 4d 0c             	decl   0xc(%ebp)
f0104270:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104274:	74 09                	je     f010427f <strnlen+0x27>
f0104276:	8b 45 08             	mov    0x8(%ebp),%eax
f0104279:	8a 00                	mov    (%eax),%al
f010427b:	84 c0                	test   %al,%al
f010427d:	75 e8                	jne    f0104267 <strnlen+0xf>
		n++;
	return n;
f010427f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f0104282:	c9                   	leave  
f0104283:	c3                   	ret    

f0104284 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104284:	55                   	push   %ebp
f0104285:	89 e5                	mov    %esp,%ebp
f0104287:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
f010428a:	8b 45 08             	mov    0x8(%ebp),%eax
f010428d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
f0104290:	90                   	nop
f0104291:	8b 45 08             	mov    0x8(%ebp),%eax
f0104294:	8d 50 01             	lea    0x1(%eax),%edx
f0104297:	89 55 08             	mov    %edx,0x8(%ebp)
f010429a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010429d:	8d 4a 01             	lea    0x1(%edx),%ecx
f01042a0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f01042a3:	8a 12                	mov    (%edx),%dl
f01042a5:	88 10                	mov    %dl,(%eax)
f01042a7:	8a 00                	mov    (%eax),%al
f01042a9:	84 c0                	test   %al,%al
f01042ab:	75 e4                	jne    f0104291 <strcpy+0xd>
		/* do nothing */;
	return ret;
f01042ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
f01042b0:	c9                   	leave  
f01042b1:	c3                   	ret    

f01042b2 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
f01042b2:	55                   	push   %ebp
f01042b3:	89 e5                	mov    %esp,%ebp
f01042b5:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
f01042b8:	8b 45 08             	mov    0x8(%ebp),%eax
f01042bb:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
f01042be:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
f01042c5:	eb 1f                	jmp    f01042e6 <strncpy+0x34>
		*dst++ = *src;
f01042c7:	8b 45 08             	mov    0x8(%ebp),%eax
f01042ca:	8d 50 01             	lea    0x1(%eax),%edx
f01042cd:	89 55 08             	mov    %edx,0x8(%ebp)
f01042d0:	8b 55 0c             	mov    0xc(%ebp),%edx
f01042d3:	8a 12                	mov    (%edx),%dl
f01042d5:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f01042d7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042da:	8a 00                	mov    (%eax),%al
f01042dc:	84 c0                	test   %al,%al
f01042de:	74 03                	je     f01042e3 <strncpy+0x31>
			src++;
f01042e0:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01042e3:	ff 45 fc             	incl   -0x4(%ebp)
f01042e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01042e9:	3b 45 10             	cmp    0x10(%ebp),%eax
f01042ec:	72 d9                	jb     f01042c7 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
f01042ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01042f1:	c9                   	leave  
f01042f2:	c3                   	ret    

f01042f3 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
f01042f3:	55                   	push   %ebp
f01042f4:	89 e5                	mov    %esp,%ebp
f01042f6:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
f01042f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01042fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
f01042ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104303:	74 30                	je     f0104335 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
f0104305:	eb 16                	jmp    f010431d <strlcpy+0x2a>
			*dst++ = *src++;
f0104307:	8b 45 08             	mov    0x8(%ebp),%eax
f010430a:	8d 50 01             	lea    0x1(%eax),%edx
f010430d:	89 55 08             	mov    %edx,0x8(%ebp)
f0104310:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104313:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104316:	89 4d 0c             	mov    %ecx,0xc(%ebp)
f0104319:	8a 12                	mov    (%edx),%dl
f010431b:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f010431d:	ff 4d 10             	decl   0x10(%ebp)
f0104320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104324:	74 09                	je     f010432f <strlcpy+0x3c>
f0104326:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104329:	8a 00                	mov    (%eax),%al
f010432b:	84 c0                	test   %al,%al
f010432d:	75 d8                	jne    f0104307 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
f010432f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104332:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0104335:	8b 55 08             	mov    0x8(%ebp),%edx
f0104338:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010433b:	29 c2                	sub    %eax,%edx
f010433d:	89 d0                	mov    %edx,%eax
}
f010433f:	c9                   	leave  
f0104340:	c3                   	ret    

f0104341 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104341:	55                   	push   %ebp
f0104342:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
f0104344:	eb 06                	jmp    f010434c <strcmp+0xb>
		p++, q++;
f0104346:	ff 45 08             	incl   0x8(%ebp)
f0104349:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f010434c:	8b 45 08             	mov    0x8(%ebp),%eax
f010434f:	8a 00                	mov    (%eax),%al
f0104351:	84 c0                	test   %al,%al
f0104353:	74 0e                	je     f0104363 <strcmp+0x22>
f0104355:	8b 45 08             	mov    0x8(%ebp),%eax
f0104358:	8a 10                	mov    (%eax),%dl
f010435a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010435d:	8a 00                	mov    (%eax),%al
f010435f:	38 c2                	cmp    %al,%dl
f0104361:	74 e3                	je     f0104346 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104363:	8b 45 08             	mov    0x8(%ebp),%eax
f0104366:	8a 00                	mov    (%eax),%al
f0104368:	0f b6 d0             	movzbl %al,%edx
f010436b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010436e:	8a 00                	mov    (%eax),%al
f0104370:	0f b6 c0             	movzbl %al,%eax
f0104373:	29 c2                	sub    %eax,%edx
f0104375:	89 d0                	mov    %edx,%eax
}
f0104377:	5d                   	pop    %ebp
f0104378:	c3                   	ret    

f0104379 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
f0104379:	55                   	push   %ebp
f010437a:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
f010437c:	eb 09                	jmp    f0104387 <strncmp+0xe>
		n--, p++, q++;
f010437e:	ff 4d 10             	decl   0x10(%ebp)
f0104381:	ff 45 08             	incl   0x8(%ebp)
f0104384:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
f0104387:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010438b:	74 17                	je     f01043a4 <strncmp+0x2b>
f010438d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104390:	8a 00                	mov    (%eax),%al
f0104392:	84 c0                	test   %al,%al
f0104394:	74 0e                	je     f01043a4 <strncmp+0x2b>
f0104396:	8b 45 08             	mov    0x8(%ebp),%eax
f0104399:	8a 10                	mov    (%eax),%dl
f010439b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010439e:	8a 00                	mov    (%eax),%al
f01043a0:	38 c2                	cmp    %al,%dl
f01043a2:	74 da                	je     f010437e <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
f01043a4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01043a8:	75 07                	jne    f01043b1 <strncmp+0x38>
		return 0;
f01043aa:	b8 00 00 00 00       	mov    $0x0,%eax
f01043af:	eb 14                	jmp    f01043c5 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01043b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01043b4:	8a 00                	mov    (%eax),%al
f01043b6:	0f b6 d0             	movzbl %al,%edx
f01043b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043bc:	8a 00                	mov    (%eax),%al
f01043be:	0f b6 c0             	movzbl %al,%eax
f01043c1:	29 c2                	sub    %eax,%edx
f01043c3:	89 d0                	mov    %edx,%eax
}
f01043c5:	5d                   	pop    %ebp
f01043c6:	c3                   	ret    

f01043c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01043c7:	55                   	push   %ebp
f01043c8:	89 e5                	mov    %esp,%ebp
f01043ca:	83 ec 04             	sub    $0x4,%esp
f01043cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043d0:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f01043d3:	eb 12                	jmp    f01043e7 <strchr+0x20>
		if (*s == c)
f01043d5:	8b 45 08             	mov    0x8(%ebp),%eax
f01043d8:	8a 00                	mov    (%eax),%al
f01043da:	3a 45 fc             	cmp    -0x4(%ebp),%al
f01043dd:	75 05                	jne    f01043e4 <strchr+0x1d>
			return (char *) s;
f01043df:	8b 45 08             	mov    0x8(%ebp),%eax
f01043e2:	eb 11                	jmp    f01043f5 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01043e4:	ff 45 08             	incl   0x8(%ebp)
f01043e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01043ea:	8a 00                	mov    (%eax),%al
f01043ec:	84 c0                	test   %al,%al
f01043ee:	75 e5                	jne    f01043d5 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
f01043f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043f5:	c9                   	leave  
f01043f6:	c3                   	ret    

f01043f7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01043f7:	55                   	push   %ebp
f01043f8:	89 e5                	mov    %esp,%ebp
f01043fa:	83 ec 04             	sub    $0x4,%esp
f01043fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104400:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
f0104403:	eb 0d                	jmp    f0104412 <strfind+0x1b>
		if (*s == c)
f0104405:	8b 45 08             	mov    0x8(%ebp),%eax
f0104408:	8a 00                	mov    (%eax),%al
f010440a:	3a 45 fc             	cmp    -0x4(%ebp),%al
f010440d:	74 0e                	je     f010441d <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010440f:	ff 45 08             	incl   0x8(%ebp)
f0104412:	8b 45 08             	mov    0x8(%ebp),%eax
f0104415:	8a 00                	mov    (%eax),%al
f0104417:	84 c0                	test   %al,%al
f0104419:	75 ea                	jne    f0104405 <strfind+0xe>
f010441b:	eb 01                	jmp    f010441e <strfind+0x27>
		if (*s == c)
			break;
f010441d:	90                   	nop
	return (char *) s;
f010441e:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104421:	c9                   	leave  
f0104422:	c3                   	ret    

f0104423 <memset>:


void *
memset(void *v, int c, uint32 n)
{
f0104423:	55                   	push   %ebp
f0104424:	89 e5                	mov    %esp,%ebp
f0104426:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
f0104429:	8b 45 08             	mov    0x8(%ebp),%eax
f010442c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
f010442f:	8b 45 10             	mov    0x10(%ebp),%eax
f0104432:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
f0104435:	eb 0e                	jmp    f0104445 <memset+0x22>
		*p++ = c;
f0104437:	8b 45 fc             	mov    -0x4(%ebp),%eax
f010443a:	8d 50 01             	lea    0x1(%eax),%edx
f010443d:	89 55 fc             	mov    %edx,-0x4(%ebp)
f0104440:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104443:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
f0104445:	ff 4d f8             	decl   -0x8(%ebp)
f0104448:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
f010444c:	79 e9                	jns    f0104437 <memset+0x14>
		*p++ = c;

	return v;
f010444e:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104451:	c9                   	leave  
f0104452:	c3                   	ret    

f0104453 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
f0104453:	55                   	push   %ebp
f0104454:	89 e5                	mov    %esp,%ebp
f0104456:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
f0104459:	8b 45 0c             	mov    0xc(%ebp),%eax
f010445c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f010445f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104462:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
f0104465:	eb 16                	jmp    f010447d <memcpy+0x2a>
		*d++ = *s++;
f0104467:	8b 45 f8             	mov    -0x8(%ebp),%eax
f010446a:	8d 50 01             	lea    0x1(%eax),%edx
f010446d:	89 55 f8             	mov    %edx,-0x8(%ebp)
f0104470:	8b 55 fc             	mov    -0x4(%ebp),%edx
f0104473:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104476:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f0104479:	8a 12                	mov    (%edx),%dl
f010447b:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
f010447d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104480:	8d 50 ff             	lea    -0x1(%eax),%edx
f0104483:	89 55 10             	mov    %edx,0x10(%ebp)
f0104486:	85 c0                	test   %eax,%eax
f0104488:	75 dd                	jne    f0104467 <memcpy+0x14>
		*d++ = *s++;

	return dst;
f010448a:	8b 45 08             	mov    0x8(%ebp),%eax
}
f010448d:	c9                   	leave  
f010448e:	c3                   	ret    

f010448f <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
f010448f:	55                   	push   %ebp
f0104490:	89 e5                	mov    %esp,%ebp
f0104492:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
f0104495:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104498:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
f010449b:	8b 45 08             	mov    0x8(%ebp),%eax
f010449e:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
f01044a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01044a4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f01044a7:	73 50                	jae    f01044f9 <memmove+0x6a>
f01044a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01044ac:	8b 45 10             	mov    0x10(%ebp),%eax
f01044af:	01 d0                	add    %edx,%eax
f01044b1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
f01044b4:	76 43                	jbe    f01044f9 <memmove+0x6a>
		s += n;
f01044b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01044b9:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
f01044bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01044bf:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
f01044c2:	eb 10                	jmp    f01044d4 <memmove+0x45>
			*--d = *--s;
f01044c4:	ff 4d f8             	decl   -0x8(%ebp)
f01044c7:	ff 4d fc             	decl   -0x4(%ebp)
f01044ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
f01044cd:	8a 10                	mov    (%eax),%dl
f01044cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01044d2:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f01044d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01044d7:	8d 50 ff             	lea    -0x1(%eax),%edx
f01044da:	89 55 10             	mov    %edx,0x10(%ebp)
f01044dd:	85 c0                	test   %eax,%eax
f01044df:	75 e3                	jne    f01044c4 <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01044e1:	eb 23                	jmp    f0104506 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f01044e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01044e6:	8d 50 01             	lea    0x1(%eax),%edx
f01044e9:	89 55 f8             	mov    %edx,-0x8(%ebp)
f01044ec:	8b 55 fc             	mov    -0x4(%ebp),%edx
f01044ef:	8d 4a 01             	lea    0x1(%edx),%ecx
f01044f2:	89 4d fc             	mov    %ecx,-0x4(%ebp)
f01044f5:	8a 12                	mov    (%edx),%dl
f01044f7:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f01044f9:	8b 45 10             	mov    0x10(%ebp),%eax
f01044fc:	8d 50 ff             	lea    -0x1(%eax),%edx
f01044ff:	89 55 10             	mov    %edx,0x10(%ebp)
f0104502:	85 c0                	test   %eax,%eax
f0104504:	75 dd                	jne    f01044e3 <memmove+0x54>
			*d++ = *s++;

	return dst;
f0104506:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104509:	c9                   	leave  
f010450a:	c3                   	ret    

f010450b <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
f010450b:	55                   	push   %ebp
f010450c:	89 e5                	mov    %esp,%ebp
f010450e:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
f0104511:	8b 45 08             	mov    0x8(%ebp),%eax
f0104514:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
f0104517:	8b 45 0c             	mov    0xc(%ebp),%eax
f010451a:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
f010451d:	eb 2a                	jmp    f0104549 <memcmp+0x3e>
		if (*s1 != *s2)
f010451f:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104522:	8a 10                	mov    (%eax),%dl
f0104524:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104527:	8a 00                	mov    (%eax),%al
f0104529:	38 c2                	cmp    %al,%dl
f010452b:	74 16                	je     f0104543 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
f010452d:	8b 45 fc             	mov    -0x4(%ebp),%eax
f0104530:	8a 00                	mov    (%eax),%al
f0104532:	0f b6 d0             	movzbl %al,%edx
f0104535:	8b 45 f8             	mov    -0x8(%ebp),%eax
f0104538:	8a 00                	mov    (%eax),%al
f010453a:	0f b6 c0             	movzbl %al,%eax
f010453d:	29 c2                	sub    %eax,%edx
f010453f:	89 d0                	mov    %edx,%eax
f0104541:	eb 18                	jmp    f010455b <memcmp+0x50>
		s1++, s2++;
f0104543:	ff 45 fc             	incl   -0x4(%ebp)
f0104546:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
f0104549:	8b 45 10             	mov    0x10(%ebp),%eax
f010454c:	8d 50 ff             	lea    -0x1(%eax),%edx
f010454f:	89 55 10             	mov    %edx,0x10(%ebp)
f0104552:	85 c0                	test   %eax,%eax
f0104554:	75 c9                	jne    f010451f <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104556:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010455b:	c9                   	leave  
f010455c:	c3                   	ret    

f010455d <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
f010455d:	55                   	push   %ebp
f010455e:	89 e5                	mov    %esp,%ebp
f0104560:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
f0104563:	8b 55 08             	mov    0x8(%ebp),%edx
f0104566:	8b 45 10             	mov    0x10(%ebp),%eax
f0104569:	01 d0                	add    %edx,%eax
f010456b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
f010456e:	eb 15                	jmp    f0104585 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104570:	8b 45 08             	mov    0x8(%ebp),%eax
f0104573:	8a 00                	mov    (%eax),%al
f0104575:	0f b6 d0             	movzbl %al,%edx
f0104578:	8b 45 0c             	mov    0xc(%ebp),%eax
f010457b:	0f b6 c0             	movzbl %al,%eax
f010457e:	39 c2                	cmp    %eax,%edx
f0104580:	74 0d                	je     f010458f <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104582:	ff 45 08             	incl   0x8(%ebp)
f0104585:	8b 45 08             	mov    0x8(%ebp),%eax
f0104588:	3b 45 fc             	cmp    -0x4(%ebp),%eax
f010458b:	72 e3                	jb     f0104570 <memfind+0x13>
f010458d:	eb 01                	jmp    f0104590 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
f010458f:	90                   	nop
	return (void *) s;
f0104590:	8b 45 08             	mov    0x8(%ebp),%eax
}
f0104593:	c9                   	leave  
f0104594:	c3                   	ret    

f0104595 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104595:	55                   	push   %ebp
f0104596:	89 e5                	mov    %esp,%ebp
f0104598:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
f010459b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
f01045a2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01045a9:	eb 03                	jmp    f01045ae <strtol+0x19>
		s++;
f01045ab:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01045ae:	8b 45 08             	mov    0x8(%ebp),%eax
f01045b1:	8a 00                	mov    (%eax),%al
f01045b3:	3c 20                	cmp    $0x20,%al
f01045b5:	74 f4                	je     f01045ab <strtol+0x16>
f01045b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01045ba:	8a 00                	mov    (%eax),%al
f01045bc:	3c 09                	cmp    $0x9,%al
f01045be:	74 eb                	je     f01045ab <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
f01045c0:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c3:	8a 00                	mov    (%eax),%al
f01045c5:	3c 2b                	cmp    $0x2b,%al
f01045c7:	75 05                	jne    f01045ce <strtol+0x39>
		s++;
f01045c9:	ff 45 08             	incl   0x8(%ebp)
f01045cc:	eb 13                	jmp    f01045e1 <strtol+0x4c>
	else if (*s == '-')
f01045ce:	8b 45 08             	mov    0x8(%ebp),%eax
f01045d1:	8a 00                	mov    (%eax),%al
f01045d3:	3c 2d                	cmp    $0x2d,%al
f01045d5:	75 0a                	jne    f01045e1 <strtol+0x4c>
		s++, neg = 1;
f01045d7:	ff 45 08             	incl   0x8(%ebp)
f01045da:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01045e1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f01045e5:	74 06                	je     f01045ed <strtol+0x58>
f01045e7:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
f01045eb:	75 20                	jne    f010460d <strtol+0x78>
f01045ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01045f0:	8a 00                	mov    (%eax),%al
f01045f2:	3c 30                	cmp    $0x30,%al
f01045f4:	75 17                	jne    f010460d <strtol+0x78>
f01045f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01045f9:	40                   	inc    %eax
f01045fa:	8a 00                	mov    (%eax),%al
f01045fc:	3c 78                	cmp    $0x78,%al
f01045fe:	75 0d                	jne    f010460d <strtol+0x78>
		s += 2, base = 16;
f0104600:	83 45 08 02          	addl   $0x2,0x8(%ebp)
f0104604:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
f010460b:	eb 28                	jmp    f0104635 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
f010460d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0104611:	75 15                	jne    f0104628 <strtol+0x93>
f0104613:	8b 45 08             	mov    0x8(%ebp),%eax
f0104616:	8a 00                	mov    (%eax),%al
f0104618:	3c 30                	cmp    $0x30,%al
f010461a:	75 0c                	jne    f0104628 <strtol+0x93>
		s++, base = 8;
f010461c:	ff 45 08             	incl   0x8(%ebp)
f010461f:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
f0104626:	eb 0d                	jmp    f0104635 <strtol+0xa0>
	else if (base == 0)
f0104628:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010462c:	75 07                	jne    f0104635 <strtol+0xa0>
		base = 10;
f010462e:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104635:	8b 45 08             	mov    0x8(%ebp),%eax
f0104638:	8a 00                	mov    (%eax),%al
f010463a:	3c 2f                	cmp    $0x2f,%al
f010463c:	7e 19                	jle    f0104657 <strtol+0xc2>
f010463e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104641:	8a 00                	mov    (%eax),%al
f0104643:	3c 39                	cmp    $0x39,%al
f0104645:	7f 10                	jg     f0104657 <strtol+0xc2>
			dig = *s - '0';
f0104647:	8b 45 08             	mov    0x8(%ebp),%eax
f010464a:	8a 00                	mov    (%eax),%al
f010464c:	0f be c0             	movsbl %al,%eax
f010464f:	83 e8 30             	sub    $0x30,%eax
f0104652:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104655:	eb 42                	jmp    f0104699 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
f0104657:	8b 45 08             	mov    0x8(%ebp),%eax
f010465a:	8a 00                	mov    (%eax),%al
f010465c:	3c 60                	cmp    $0x60,%al
f010465e:	7e 19                	jle    f0104679 <strtol+0xe4>
f0104660:	8b 45 08             	mov    0x8(%ebp),%eax
f0104663:	8a 00                	mov    (%eax),%al
f0104665:	3c 7a                	cmp    $0x7a,%al
f0104667:	7f 10                	jg     f0104679 <strtol+0xe4>
			dig = *s - 'a' + 10;
f0104669:	8b 45 08             	mov    0x8(%ebp),%eax
f010466c:	8a 00                	mov    (%eax),%al
f010466e:	0f be c0             	movsbl %al,%eax
f0104671:	83 e8 57             	sub    $0x57,%eax
f0104674:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104677:	eb 20                	jmp    f0104699 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
f0104679:	8b 45 08             	mov    0x8(%ebp),%eax
f010467c:	8a 00                	mov    (%eax),%al
f010467e:	3c 40                	cmp    $0x40,%al
f0104680:	7e 39                	jle    f01046bb <strtol+0x126>
f0104682:	8b 45 08             	mov    0x8(%ebp),%eax
f0104685:	8a 00                	mov    (%eax),%al
f0104687:	3c 5a                	cmp    $0x5a,%al
f0104689:	7f 30                	jg     f01046bb <strtol+0x126>
			dig = *s - 'A' + 10;
f010468b:	8b 45 08             	mov    0x8(%ebp),%eax
f010468e:	8a 00                	mov    (%eax),%al
f0104690:	0f be c0             	movsbl %al,%eax
f0104693:	83 e8 37             	sub    $0x37,%eax
f0104696:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
f0104699:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010469c:	3b 45 10             	cmp    0x10(%ebp),%eax
f010469f:	7d 19                	jge    f01046ba <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
f01046a1:	ff 45 08             	incl   0x8(%ebp)
f01046a4:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01046a7:	0f af 45 10          	imul   0x10(%ebp),%eax
f01046ab:	89 c2                	mov    %eax,%edx
f01046ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01046b0:	01 d0                	add    %edx,%eax
f01046b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
f01046b5:	e9 7b ff ff ff       	jmp    f0104635 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
f01046ba:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01046bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046bf:	74 08                	je     f01046c9 <strtol+0x134>
		*endptr = (char *) s;
f01046c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01046c4:	8b 55 08             	mov    0x8(%ebp),%edx
f01046c7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
f01046c9:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
f01046cd:	74 07                	je     f01046d6 <strtol+0x141>
f01046cf:	8b 45 f8             	mov    -0x8(%ebp),%eax
f01046d2:	f7 d8                	neg    %eax
f01046d4:	eb 03                	jmp    f01046d9 <strtol+0x144>
f01046d6:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
f01046d9:	c9                   	leave  
f01046da:	c3                   	ret    

f01046db <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
f01046db:	55                   	push   %ebp
f01046dc:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
f01046de:	8b 45 14             	mov    0x14(%ebp),%eax
f01046e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
f01046e7:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ea:	8b 00                	mov    (%eax),%eax
f01046ec:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f01046f3:	8b 45 10             	mov    0x10(%ebp),%eax
f01046f6:	01 d0                	add    %edx,%eax
f01046f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f01046fe:	eb 0c                	jmp    f010470c <strsplit+0x31>
			*string++ = 0;
f0104700:	8b 45 08             	mov    0x8(%ebp),%eax
f0104703:	8d 50 01             	lea    0x1(%eax),%edx
f0104706:	89 55 08             	mov    %edx,0x8(%ebp)
f0104709:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
f010470c:	8b 45 08             	mov    0x8(%ebp),%eax
f010470f:	8a 00                	mov    (%eax),%al
f0104711:	84 c0                	test   %al,%al
f0104713:	74 18                	je     f010472d <strsplit+0x52>
f0104715:	8b 45 08             	mov    0x8(%ebp),%eax
f0104718:	8a 00                	mov    (%eax),%al
f010471a:	0f be c0             	movsbl %al,%eax
f010471d:	50                   	push   %eax
f010471e:	ff 75 0c             	pushl  0xc(%ebp)
f0104721:	e8 a1 fc ff ff       	call   f01043c7 <strchr>
f0104726:	83 c4 08             	add    $0x8,%esp
f0104729:	85 c0                	test   %eax,%eax
f010472b:	75 d3                	jne    f0104700 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
f010472d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104730:	8a 00                	mov    (%eax),%al
f0104732:	84 c0                	test   %al,%al
f0104734:	74 5a                	je     f0104790 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
f0104736:	8b 45 14             	mov    0x14(%ebp),%eax
f0104739:	8b 00                	mov    (%eax),%eax
f010473b:	83 f8 0f             	cmp    $0xf,%eax
f010473e:	75 07                	jne    f0104747 <strsplit+0x6c>
		{
			return 0;
f0104740:	b8 00 00 00 00       	mov    $0x0,%eax
f0104745:	eb 66                	jmp    f01047ad <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
f0104747:	8b 45 14             	mov    0x14(%ebp),%eax
f010474a:	8b 00                	mov    (%eax),%eax
f010474c:	8d 48 01             	lea    0x1(%eax),%ecx
f010474f:	8b 55 14             	mov    0x14(%ebp),%edx
f0104752:	89 0a                	mov    %ecx,(%edx)
f0104754:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010475b:	8b 45 10             	mov    0x10(%ebp),%eax
f010475e:	01 c2                	add    %eax,%edx
f0104760:	8b 45 08             	mov    0x8(%ebp),%eax
f0104763:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
f0104765:	eb 03                	jmp    f010476a <strsplit+0x8f>
			string++;
f0104767:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
f010476a:	8b 45 08             	mov    0x8(%ebp),%eax
f010476d:	8a 00                	mov    (%eax),%al
f010476f:	84 c0                	test   %al,%al
f0104771:	74 8b                	je     f01046fe <strsplit+0x23>
f0104773:	8b 45 08             	mov    0x8(%ebp),%eax
f0104776:	8a 00                	mov    (%eax),%al
f0104778:	0f be c0             	movsbl %al,%eax
f010477b:	50                   	push   %eax
f010477c:	ff 75 0c             	pushl  0xc(%ebp)
f010477f:	e8 43 fc ff ff       	call   f01043c7 <strchr>
f0104784:	83 c4 08             	add    $0x8,%esp
f0104787:	85 c0                	test   %eax,%eax
f0104789:	74 dc                	je     f0104767 <strsplit+0x8c>
			string++;
	}
f010478b:	e9 6e ff ff ff       	jmp    f01046fe <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
f0104790:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
f0104791:	8b 45 14             	mov    0x14(%ebp),%eax
f0104794:	8b 00                	mov    (%eax),%eax
f0104796:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
f010479d:	8b 45 10             	mov    0x10(%ebp),%eax
f01047a0:	01 d0                	add    %edx,%eax
f01047a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
f01047a8:	b8 01 00 00 00       	mov    $0x1,%eax
}
f01047ad:	c9                   	leave  
f01047ae:	c3                   	ret    
f01047af:	90                   	nop

f01047b0 <__udivdi3>:
f01047b0:	55                   	push   %ebp
f01047b1:	57                   	push   %edi
f01047b2:	56                   	push   %esi
f01047b3:	53                   	push   %ebx
f01047b4:	83 ec 1c             	sub    $0x1c,%esp
f01047b7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01047bb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01047bf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01047c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01047c7:	89 ca                	mov    %ecx,%edx
f01047c9:	89 f8                	mov    %edi,%eax
f01047cb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01047cf:	85 f6                	test   %esi,%esi
f01047d1:	75 2d                	jne    f0104800 <__udivdi3+0x50>
f01047d3:	39 cf                	cmp    %ecx,%edi
f01047d5:	77 65                	ja     f010483c <__udivdi3+0x8c>
f01047d7:	89 fd                	mov    %edi,%ebp
f01047d9:	85 ff                	test   %edi,%edi
f01047db:	75 0b                	jne    f01047e8 <__udivdi3+0x38>
f01047dd:	b8 01 00 00 00       	mov    $0x1,%eax
f01047e2:	31 d2                	xor    %edx,%edx
f01047e4:	f7 f7                	div    %edi
f01047e6:	89 c5                	mov    %eax,%ebp
f01047e8:	31 d2                	xor    %edx,%edx
f01047ea:	89 c8                	mov    %ecx,%eax
f01047ec:	f7 f5                	div    %ebp
f01047ee:	89 c1                	mov    %eax,%ecx
f01047f0:	89 d8                	mov    %ebx,%eax
f01047f2:	f7 f5                	div    %ebp
f01047f4:	89 cf                	mov    %ecx,%edi
f01047f6:	89 fa                	mov    %edi,%edx
f01047f8:	83 c4 1c             	add    $0x1c,%esp
f01047fb:	5b                   	pop    %ebx
f01047fc:	5e                   	pop    %esi
f01047fd:	5f                   	pop    %edi
f01047fe:	5d                   	pop    %ebp
f01047ff:	c3                   	ret    
f0104800:	39 ce                	cmp    %ecx,%esi
f0104802:	77 28                	ja     f010482c <__udivdi3+0x7c>
f0104804:	0f bd fe             	bsr    %esi,%edi
f0104807:	83 f7 1f             	xor    $0x1f,%edi
f010480a:	75 40                	jne    f010484c <__udivdi3+0x9c>
f010480c:	39 ce                	cmp    %ecx,%esi
f010480e:	72 0a                	jb     f010481a <__udivdi3+0x6a>
f0104810:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0104814:	0f 87 9e 00 00 00    	ja     f01048b8 <__udivdi3+0x108>
f010481a:	b8 01 00 00 00       	mov    $0x1,%eax
f010481f:	89 fa                	mov    %edi,%edx
f0104821:	83 c4 1c             	add    $0x1c,%esp
f0104824:	5b                   	pop    %ebx
f0104825:	5e                   	pop    %esi
f0104826:	5f                   	pop    %edi
f0104827:	5d                   	pop    %ebp
f0104828:	c3                   	ret    
f0104829:	8d 76 00             	lea    0x0(%esi),%esi
f010482c:	31 ff                	xor    %edi,%edi
f010482e:	31 c0                	xor    %eax,%eax
f0104830:	89 fa                	mov    %edi,%edx
f0104832:	83 c4 1c             	add    $0x1c,%esp
f0104835:	5b                   	pop    %ebx
f0104836:	5e                   	pop    %esi
f0104837:	5f                   	pop    %edi
f0104838:	5d                   	pop    %ebp
f0104839:	c3                   	ret    
f010483a:	66 90                	xchg   %ax,%ax
f010483c:	89 d8                	mov    %ebx,%eax
f010483e:	f7 f7                	div    %edi
f0104840:	31 ff                	xor    %edi,%edi
f0104842:	89 fa                	mov    %edi,%edx
f0104844:	83 c4 1c             	add    $0x1c,%esp
f0104847:	5b                   	pop    %ebx
f0104848:	5e                   	pop    %esi
f0104849:	5f                   	pop    %edi
f010484a:	5d                   	pop    %ebp
f010484b:	c3                   	ret    
f010484c:	bd 20 00 00 00       	mov    $0x20,%ebp
f0104851:	89 eb                	mov    %ebp,%ebx
f0104853:	29 fb                	sub    %edi,%ebx
f0104855:	89 f9                	mov    %edi,%ecx
f0104857:	d3 e6                	shl    %cl,%esi
f0104859:	89 c5                	mov    %eax,%ebp
f010485b:	88 d9                	mov    %bl,%cl
f010485d:	d3 ed                	shr    %cl,%ebp
f010485f:	89 e9                	mov    %ebp,%ecx
f0104861:	09 f1                	or     %esi,%ecx
f0104863:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104867:	89 f9                	mov    %edi,%ecx
f0104869:	d3 e0                	shl    %cl,%eax
f010486b:	89 c5                	mov    %eax,%ebp
f010486d:	89 d6                	mov    %edx,%esi
f010486f:	88 d9                	mov    %bl,%cl
f0104871:	d3 ee                	shr    %cl,%esi
f0104873:	89 f9                	mov    %edi,%ecx
f0104875:	d3 e2                	shl    %cl,%edx
f0104877:	8b 44 24 08          	mov    0x8(%esp),%eax
f010487b:	88 d9                	mov    %bl,%cl
f010487d:	d3 e8                	shr    %cl,%eax
f010487f:	09 c2                	or     %eax,%edx
f0104881:	89 d0                	mov    %edx,%eax
f0104883:	89 f2                	mov    %esi,%edx
f0104885:	f7 74 24 0c          	divl   0xc(%esp)
f0104889:	89 d6                	mov    %edx,%esi
f010488b:	89 c3                	mov    %eax,%ebx
f010488d:	f7 e5                	mul    %ebp
f010488f:	39 d6                	cmp    %edx,%esi
f0104891:	72 19                	jb     f01048ac <__udivdi3+0xfc>
f0104893:	74 0b                	je     f01048a0 <__udivdi3+0xf0>
f0104895:	89 d8                	mov    %ebx,%eax
f0104897:	31 ff                	xor    %edi,%edi
f0104899:	e9 58 ff ff ff       	jmp    f01047f6 <__udivdi3+0x46>
f010489e:	66 90                	xchg   %ax,%ax
f01048a0:	8b 54 24 08          	mov    0x8(%esp),%edx
f01048a4:	89 f9                	mov    %edi,%ecx
f01048a6:	d3 e2                	shl    %cl,%edx
f01048a8:	39 c2                	cmp    %eax,%edx
f01048aa:	73 e9                	jae    f0104895 <__udivdi3+0xe5>
f01048ac:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01048af:	31 ff                	xor    %edi,%edi
f01048b1:	e9 40 ff ff ff       	jmp    f01047f6 <__udivdi3+0x46>
f01048b6:	66 90                	xchg   %ax,%ax
f01048b8:	31 c0                	xor    %eax,%eax
f01048ba:	e9 37 ff ff ff       	jmp    f01047f6 <__udivdi3+0x46>
f01048bf:	90                   	nop

f01048c0 <__umoddi3>:
f01048c0:	55                   	push   %ebp
f01048c1:	57                   	push   %edi
f01048c2:	56                   	push   %esi
f01048c3:	53                   	push   %ebx
f01048c4:	83 ec 1c             	sub    $0x1c,%esp
f01048c7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01048cb:	8b 74 24 34          	mov    0x34(%esp),%esi
f01048cf:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01048d3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01048d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048df:	89 f3                	mov    %esi,%ebx
f01048e1:	89 fa                	mov    %edi,%edx
f01048e3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01048e7:	89 34 24             	mov    %esi,(%esp)
f01048ea:	85 c0                	test   %eax,%eax
f01048ec:	75 1a                	jne    f0104908 <__umoddi3+0x48>
f01048ee:	39 f7                	cmp    %esi,%edi
f01048f0:	0f 86 a2 00 00 00    	jbe    f0104998 <__umoddi3+0xd8>
f01048f6:	89 c8                	mov    %ecx,%eax
f01048f8:	89 f2                	mov    %esi,%edx
f01048fa:	f7 f7                	div    %edi
f01048fc:	89 d0                	mov    %edx,%eax
f01048fe:	31 d2                	xor    %edx,%edx
f0104900:	83 c4 1c             	add    $0x1c,%esp
f0104903:	5b                   	pop    %ebx
f0104904:	5e                   	pop    %esi
f0104905:	5f                   	pop    %edi
f0104906:	5d                   	pop    %ebp
f0104907:	c3                   	ret    
f0104908:	39 f0                	cmp    %esi,%eax
f010490a:	0f 87 ac 00 00 00    	ja     f01049bc <__umoddi3+0xfc>
f0104910:	0f bd e8             	bsr    %eax,%ebp
f0104913:	83 f5 1f             	xor    $0x1f,%ebp
f0104916:	0f 84 ac 00 00 00    	je     f01049c8 <__umoddi3+0x108>
f010491c:	bf 20 00 00 00       	mov    $0x20,%edi
f0104921:	29 ef                	sub    %ebp,%edi
f0104923:	89 fe                	mov    %edi,%esi
f0104925:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104929:	89 e9                	mov    %ebp,%ecx
f010492b:	d3 e0                	shl    %cl,%eax
f010492d:	89 d7                	mov    %edx,%edi
f010492f:	89 f1                	mov    %esi,%ecx
f0104931:	d3 ef                	shr    %cl,%edi
f0104933:	09 c7                	or     %eax,%edi
f0104935:	89 e9                	mov    %ebp,%ecx
f0104937:	d3 e2                	shl    %cl,%edx
f0104939:	89 14 24             	mov    %edx,(%esp)
f010493c:	89 d8                	mov    %ebx,%eax
f010493e:	d3 e0                	shl    %cl,%eax
f0104940:	89 c2                	mov    %eax,%edx
f0104942:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104946:	d3 e0                	shl    %cl,%eax
f0104948:	89 44 24 04          	mov    %eax,0x4(%esp)
f010494c:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104950:	89 f1                	mov    %esi,%ecx
f0104952:	d3 e8                	shr    %cl,%eax
f0104954:	09 d0                	or     %edx,%eax
f0104956:	d3 eb                	shr    %cl,%ebx
f0104958:	89 da                	mov    %ebx,%edx
f010495a:	f7 f7                	div    %edi
f010495c:	89 d3                	mov    %edx,%ebx
f010495e:	f7 24 24             	mull   (%esp)
f0104961:	89 c6                	mov    %eax,%esi
f0104963:	89 d1                	mov    %edx,%ecx
f0104965:	39 d3                	cmp    %edx,%ebx
f0104967:	0f 82 87 00 00 00    	jb     f01049f4 <__umoddi3+0x134>
f010496d:	0f 84 91 00 00 00    	je     f0104a04 <__umoddi3+0x144>
f0104973:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104977:	29 f2                	sub    %esi,%edx
f0104979:	19 cb                	sbb    %ecx,%ebx
f010497b:	89 d8                	mov    %ebx,%eax
f010497d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
f0104981:	d3 e0                	shl    %cl,%eax
f0104983:	89 e9                	mov    %ebp,%ecx
f0104985:	d3 ea                	shr    %cl,%edx
f0104987:	09 d0                	or     %edx,%eax
f0104989:	89 e9                	mov    %ebp,%ecx
f010498b:	d3 eb                	shr    %cl,%ebx
f010498d:	89 da                	mov    %ebx,%edx
f010498f:	83 c4 1c             	add    $0x1c,%esp
f0104992:	5b                   	pop    %ebx
f0104993:	5e                   	pop    %esi
f0104994:	5f                   	pop    %edi
f0104995:	5d                   	pop    %ebp
f0104996:	c3                   	ret    
f0104997:	90                   	nop
f0104998:	89 fd                	mov    %edi,%ebp
f010499a:	85 ff                	test   %edi,%edi
f010499c:	75 0b                	jne    f01049a9 <__umoddi3+0xe9>
f010499e:	b8 01 00 00 00       	mov    $0x1,%eax
f01049a3:	31 d2                	xor    %edx,%edx
f01049a5:	f7 f7                	div    %edi
f01049a7:	89 c5                	mov    %eax,%ebp
f01049a9:	89 f0                	mov    %esi,%eax
f01049ab:	31 d2                	xor    %edx,%edx
f01049ad:	f7 f5                	div    %ebp
f01049af:	89 c8                	mov    %ecx,%eax
f01049b1:	f7 f5                	div    %ebp
f01049b3:	89 d0                	mov    %edx,%eax
f01049b5:	e9 44 ff ff ff       	jmp    f01048fe <__umoddi3+0x3e>
f01049ba:	66 90                	xchg   %ax,%ax
f01049bc:	89 c8                	mov    %ecx,%eax
f01049be:	89 f2                	mov    %esi,%edx
f01049c0:	83 c4 1c             	add    $0x1c,%esp
f01049c3:	5b                   	pop    %ebx
f01049c4:	5e                   	pop    %esi
f01049c5:	5f                   	pop    %edi
f01049c6:	5d                   	pop    %ebp
f01049c7:	c3                   	ret    
f01049c8:	3b 04 24             	cmp    (%esp),%eax
f01049cb:	72 06                	jb     f01049d3 <__umoddi3+0x113>
f01049cd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
f01049d1:	77 0f                	ja     f01049e2 <__umoddi3+0x122>
f01049d3:	89 f2                	mov    %esi,%edx
f01049d5:	29 f9                	sub    %edi,%ecx
f01049d7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
f01049db:	89 14 24             	mov    %edx,(%esp)
f01049de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01049e2:	8b 44 24 04          	mov    0x4(%esp),%eax
f01049e6:	8b 14 24             	mov    (%esp),%edx
f01049e9:	83 c4 1c             	add    $0x1c,%esp
f01049ec:	5b                   	pop    %ebx
f01049ed:	5e                   	pop    %esi
f01049ee:	5f                   	pop    %edi
f01049ef:	5d                   	pop    %ebp
f01049f0:	c3                   	ret    
f01049f1:	8d 76 00             	lea    0x0(%esi),%esi
f01049f4:	2b 04 24             	sub    (%esp),%eax
f01049f7:	19 fa                	sbb    %edi,%edx
f01049f9:	89 d1                	mov    %edx,%ecx
f01049fb:	89 c6                	mov    %eax,%esi
f01049fd:	e9 71 ff ff ff       	jmp    f0104973 <__umoddi3+0xb3>
f0104a02:	66 90                	xchg   %ax,%ax
f0104a04:	39 44 24 04          	cmp    %eax,0x4(%esp)
f0104a08:	72 ea                	jb     f01049f4 <__umoddi3+0x134>
f0104a0a:	89 d9                	mov    %ebx,%ecx
f0104a0c:	e9 62 ff ff ff       	jmp    f0104973 <__umoddi3+0xb3>
