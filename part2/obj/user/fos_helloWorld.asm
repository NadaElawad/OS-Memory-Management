
obj/user/fos_helloWorld:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	mov $0, %eax
  800020:	b8 00 00 00 00       	mov    $0x0,%eax
	cmpl $USTACKTOP, %esp
  800025:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  80002b:	75 04                	jne    800031 <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  80002d:	6a 00                	push   $0x0
	pushl $0
  80002f:	6a 00                	push   $0x0

00800031 <args_exist>:

args_exist:
	call libmain
  800031:	e8 1b 00 00 00       	call   800051 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
// hello, world
#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 08             	sub    $0x8,%esp
	cprintf("HELLO WORLD , FOS IS SAYING HI :D:D:D\n");	
  80003e:	83 ec 0c             	sub    $0xc,%esp
  800041:	68 20 11 80 00       	push   $0x801120
  800046:	e8 1e 01 00 00       	call   800169 <cprintf>
  80004b:	83 c4 10             	add    $0x10,%esp
}
  80004e:	90                   	nop
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  800057:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  80005e:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800061:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800065:	7e 0a                	jle    800071 <libmain+0x20>
		binaryname = argv[0];
  800067:	8b 45 0c             	mov    0xc(%ebp),%eax
  80006a:	8b 00                	mov    (%eax),%eax
  80006c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  800071:	83 ec 08             	sub    $0x8,%esp
  800074:	ff 75 0c             	pushl  0xc(%ebp)
  800077:	ff 75 08             	pushl  0x8(%ebp)
  80007a:	e8 b9 ff ff ff       	call   800038 <_main>
  80007f:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  800082:	e8 19 00 00 00       	call   8000a0 <sleep>
}
  800087:	90                   	nop
  800088:	c9                   	leave  
  800089:	c3                   	ret    

0080008a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008a:	55                   	push   %ebp
  80008b:	89 e5                	mov    %esp,%ebp
  80008d:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  800090:	83 ec 0c             	sub    $0xc,%esp
  800093:	6a 00                	push   $0x0
  800095:	e8 f5 0c 00 00       	call   800d8f <sys_env_destroy>
  80009a:	83 c4 10             	add    $0x10,%esp
}
  80009d:	90                   	nop
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sleep>:

void
sleep(void)
{	
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  8000a6:	e8 18 0d 00 00       	call   800dc3 <sys_env_sleep>
}
  8000ab:	90                   	nop
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8000b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000b7:	8b 00                	mov    (%eax),%eax
  8000b9:	8d 48 01             	lea    0x1(%eax),%ecx
  8000bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000bf:	89 0a                	mov    %ecx,(%edx)
  8000c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c4:	88 d1                	mov    %dl,%cl
  8000c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8000c9:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8000cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000d0:	8b 00                	mov    (%eax),%eax
  8000d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d7:	75 23                	jne    8000fc <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  8000d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dc:	8b 00                	mov    (%eax),%eax
  8000de:	89 c2                	mov    %eax,%edx
  8000e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e3:	83 c0 08             	add    $0x8,%eax
  8000e6:	83 ec 08             	sub    $0x8,%esp
  8000e9:	52                   	push   %edx
  8000ea:	50                   	push   %eax
  8000eb:	e8 69 0c 00 00       	call   800d59 <sys_cputs>
  8000f0:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  8000f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8000fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ff:	8b 40 04             	mov    0x4(%eax),%eax
  800102:	8d 50 01             	lea    0x1(%eax),%edx
  800105:	8b 45 0c             	mov    0xc(%ebp),%eax
  800108:	89 50 04             	mov    %edx,0x4(%eax)
}
  80010b:	90                   	nop
  80010c:	c9                   	leave  
  80010d:	c3                   	ret    

0080010e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800117:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011e:	00 00 00 
	b.cnt = 0;
  800121:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800128:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800137:	50                   	push   %eax
  800138:	68 ae 00 80 00       	push   $0x8000ae
  80013d:	e8 ca 01 00 00       	call   80030c <vprintfmt>
  800142:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  800145:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80014b:	83 ec 08             	sub    $0x8,%esp
  80014e:	50                   	push   %eax
  80014f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800155:	83 c0 08             	add    $0x8,%eax
  800158:	50                   	push   %eax
  800159:	e8 fb 0b 00 00       	call   800d59 <sys_cputs>
  80015e:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  800161:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800167:	c9                   	leave  
  800168:	c3                   	ret    

00800169 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800169:	55                   	push   %ebp
  80016a:	89 e5                	mov    %esp,%ebp
  80016c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800172:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  800175:	8b 45 08             	mov    0x8(%ebp),%eax
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	ff 75 f4             	pushl  -0xc(%ebp)
  80017e:	50                   	push   %eax
  80017f:	e8 8a ff ff ff       	call   80010e <vcprintf>
  800184:	83 c4 10             	add    $0x10,%esp
  800187:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  80018a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80018f:	55                   	push   %ebp
  800190:	89 e5                	mov    %esp,%ebp
  800192:	53                   	push   %ebx
  800193:	83 ec 14             	sub    $0x14,%esp
  800196:	8b 45 10             	mov    0x10(%ebp),%eax
  800199:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80019c:	8b 45 14             	mov    0x14(%ebp),%eax
  80019f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a2:	8b 45 18             	mov    0x18(%ebp),%eax
  8001a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001aa:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001ad:	77 55                	ja     800204 <printnum+0x75>
  8001af:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001b2:	72 05                	jb     8001b9 <printnum+0x2a>
  8001b4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001b7:	77 4b                	ja     800204 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b9:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8001bc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bf:	8b 45 18             	mov    0x18(%ebp),%eax
  8001c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c7:	52                   	push   %edx
  8001c8:	50                   	push   %eax
  8001c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8001cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8001cf:	e8 dc 0c 00 00       	call   800eb0 <__udivdi3>
  8001d4:	83 c4 10             	add    $0x10,%esp
  8001d7:	83 ec 04             	sub    $0x4,%esp
  8001da:	ff 75 20             	pushl  0x20(%ebp)
  8001dd:	53                   	push   %ebx
  8001de:	ff 75 18             	pushl  0x18(%ebp)
  8001e1:	52                   	push   %edx
  8001e2:	50                   	push   %eax
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	ff 75 08             	pushl  0x8(%ebp)
  8001e9:	e8 a1 ff ff ff       	call   80018f <printnum>
  8001ee:	83 c4 20             	add    $0x20,%esp
  8001f1:	eb 1a                	jmp    80020d <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	ff 75 0c             	pushl  0xc(%ebp)
  8001f9:	ff 75 20             	pushl  0x20(%ebp)
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	ff d0                	call   *%eax
  800201:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800204:	ff 4d 1c             	decl   0x1c(%ebp)
  800207:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80020b:	7f e6                	jg     8001f3 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80020d:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800210:	bb 00 00 00 00       	mov    $0x0,%ebx
  800215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800218:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80021b:	53                   	push   %ebx
  80021c:	51                   	push   %ecx
  80021d:	52                   	push   %edx
  80021e:	50                   	push   %eax
  80021f:	e8 9c 0d 00 00       	call   800fc0 <__umoddi3>
  800224:	83 c4 10             	add    $0x10,%esp
  800227:	05 00 12 80 00       	add    $0x801200,%eax
  80022c:	8a 00                	mov    (%eax),%al
  80022e:	0f be c0             	movsbl %al,%eax
  800231:	83 ec 08             	sub    $0x8,%esp
  800234:	ff 75 0c             	pushl  0xc(%ebp)
  800237:	50                   	push   %eax
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	ff d0                	call   *%eax
  80023d:	83 c4 10             	add    $0x10,%esp
}
  800240:	90                   	nop
  800241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800244:	c9                   	leave  
  800245:	c3                   	ret    

00800246 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800246:	55                   	push   %ebp
  800247:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800249:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80024d:	7e 1c                	jle    80026b <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  80024f:	8b 45 08             	mov    0x8(%ebp),%eax
  800252:	8b 00                	mov    (%eax),%eax
  800254:	8d 50 08             	lea    0x8(%eax),%edx
  800257:	8b 45 08             	mov    0x8(%ebp),%eax
  80025a:	89 10                	mov    %edx,(%eax)
  80025c:	8b 45 08             	mov    0x8(%ebp),%eax
  80025f:	8b 00                	mov    (%eax),%eax
  800261:	83 e8 08             	sub    $0x8,%eax
  800264:	8b 50 04             	mov    0x4(%eax),%edx
  800267:	8b 00                	mov    (%eax),%eax
  800269:	eb 40                	jmp    8002ab <getuint+0x65>
	else if (lflag)
  80026b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80026f:	74 1e                	je     80028f <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800271:	8b 45 08             	mov    0x8(%ebp),%eax
  800274:	8b 00                	mov    (%eax),%eax
  800276:	8d 50 04             	lea    0x4(%eax),%edx
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	89 10                	mov    %edx,(%eax)
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	8b 00                	mov    (%eax),%eax
  800283:	83 e8 04             	sub    $0x4,%eax
  800286:	8b 00                	mov    (%eax),%eax
  800288:	ba 00 00 00 00       	mov    $0x0,%edx
  80028d:	eb 1c                	jmp    8002ab <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	8b 00                	mov    (%eax),%eax
  800294:	8d 50 04             	lea    0x4(%eax),%edx
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	89 10                	mov    %edx,(%eax)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	8b 00                	mov    (%eax),%eax
  8002a1:	83 e8 04             	sub    $0x4,%eax
  8002a4:	8b 00                	mov    (%eax),%eax
  8002a6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b0:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002b4:	7e 1c                	jle    8002d2 <getint+0x25>
		return va_arg(*ap, long long);
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	8b 00                	mov    (%eax),%eax
  8002bb:	8d 50 08             	lea    0x8(%eax),%edx
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 10                	mov    %edx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	8b 00                	mov    (%eax),%eax
  8002c8:	83 e8 08             	sub    $0x8,%eax
  8002cb:	8b 50 04             	mov    0x4(%eax),%edx
  8002ce:	8b 00                	mov    (%eax),%eax
  8002d0:	eb 38                	jmp    80030a <getint+0x5d>
	else if (lflag)
  8002d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002d6:	74 1a                	je     8002f2 <getint+0x45>
		return va_arg(*ap, long);
  8002d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002db:	8b 00                	mov    (%eax),%eax
  8002dd:	8d 50 04             	lea    0x4(%eax),%edx
  8002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e3:	89 10                	mov    %edx,(%eax)
  8002e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e8:	8b 00                	mov    (%eax),%eax
  8002ea:	83 e8 04             	sub    $0x4,%eax
  8002ed:	8b 00                	mov    (%eax),%eax
  8002ef:	99                   	cltd   
  8002f0:	eb 18                	jmp    80030a <getint+0x5d>
	else
		return va_arg(*ap, int);
  8002f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f5:	8b 00                	mov    (%eax),%eax
  8002f7:	8d 50 04             	lea    0x4(%eax),%edx
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	89 10                	mov    %edx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	8b 00                	mov    (%eax),%eax
  800304:	83 e8 04             	sub    $0x4,%eax
  800307:	8b 00                	mov    (%eax),%eax
  800309:	99                   	cltd   
}
  80030a:	5d                   	pop    %ebp
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	56                   	push   %esi
  800310:	53                   	push   %ebx
  800311:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	eb 17                	jmp    80032d <vprintfmt+0x21>
			if (ch == '\0')
  800316:	85 db                	test   %ebx,%ebx
  800318:	0f 84 af 03 00 00    	je     8006cd <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  80031e:	83 ec 08             	sub    $0x8,%esp
  800321:	ff 75 0c             	pushl  0xc(%ebp)
  800324:	53                   	push   %ebx
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	ff d0                	call   *%eax
  80032a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80032d:	8b 45 10             	mov    0x10(%ebp),%eax
  800330:	8d 50 01             	lea    0x1(%eax),%edx
  800333:	89 55 10             	mov    %edx,0x10(%ebp)
  800336:	8a 00                	mov    (%eax),%al
  800338:	0f b6 d8             	movzbl %al,%ebx
  80033b:	83 fb 25             	cmp    $0x25,%ebx
  80033e:	75 d6                	jne    800316 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800340:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800344:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80034b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800352:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800359:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800360:	8b 45 10             	mov    0x10(%ebp),%eax
  800363:	8d 50 01             	lea    0x1(%eax),%edx
  800366:	89 55 10             	mov    %edx,0x10(%ebp)
  800369:	8a 00                	mov    (%eax),%al
  80036b:	0f b6 d8             	movzbl %al,%ebx
  80036e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800371:	83 f8 55             	cmp    $0x55,%eax
  800374:	0f 87 2b 03 00 00    	ja     8006a5 <vprintfmt+0x399>
  80037a:	8b 04 85 24 12 80 00 	mov    0x801224(,%eax,4),%eax
  800381:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800387:	eb d7                	jmp    800360 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800389:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80038d:	eb d1                	jmp    800360 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800396:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800399:	89 d0                	mov    %edx,%eax
  80039b:	c1 e0 02             	shl    $0x2,%eax
  80039e:	01 d0                	add    %edx,%eax
  8003a0:	01 c0                	add    %eax,%eax
  8003a2:	01 d8                	add    %ebx,%eax
  8003a4:	83 e8 30             	sub    $0x30,%eax
  8003a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ad:	8a 00                	mov    (%eax),%al
  8003af:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003b2:	83 fb 2f             	cmp    $0x2f,%ebx
  8003b5:	7e 3e                	jle    8003f5 <vprintfmt+0xe9>
  8003b7:	83 fb 39             	cmp    $0x39,%ebx
  8003ba:	7f 39                	jg     8003f5 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bc:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003bf:	eb d5                	jmp    800396 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c4:	83 c0 04             	add    $0x4,%eax
  8003c7:	89 45 14             	mov    %eax,0x14(%ebp)
  8003ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cd:	83 e8 04             	sub    $0x4,%eax
  8003d0:	8b 00                	mov    (%eax),%eax
  8003d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8003d5:	eb 1f                	jmp    8003f6 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  8003d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003db:	79 83                	jns    800360 <vprintfmt+0x54>
				width = 0;
  8003dd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8003e4:	e9 77 ff ff ff       	jmp    800360 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  8003e9:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8003f0:	e9 6b ff ff ff       	jmp    800360 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  8003f5:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003f6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fa:	0f 89 60 ff ff ff    	jns    800360 <vprintfmt+0x54>
				width = precision, precision = -1;
  800400:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800406:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80040d:	e9 4e ff ff ff       	jmp    800360 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800412:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800415:	e9 46 ff ff ff       	jmp    800360 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041a:	8b 45 14             	mov    0x14(%ebp),%eax
  80041d:	83 c0 04             	add    $0x4,%eax
  800420:	89 45 14             	mov    %eax,0x14(%ebp)
  800423:	8b 45 14             	mov    0x14(%ebp),%eax
  800426:	83 e8 04             	sub    $0x4,%eax
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	50                   	push   %eax
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
  800435:	ff d0                	call   *%eax
  800437:	83 c4 10             	add    $0x10,%esp
			break;
  80043a:	e9 89 02 00 00       	jmp    8006c8 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	83 c0 04             	add    $0x4,%eax
  800445:	89 45 14             	mov    %eax,0x14(%ebp)
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	83 e8 04             	sub    $0x4,%eax
  80044e:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800450:	85 db                	test   %ebx,%ebx
  800452:	79 02                	jns    800456 <vprintfmt+0x14a>
				err = -err;
  800454:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  800456:	83 fb 07             	cmp    $0x7,%ebx
  800459:	7f 0b                	jg     800466 <vprintfmt+0x15a>
  80045b:	8b 34 9d e0 11 80 00 	mov    0x8011e0(,%ebx,4),%esi
  800462:	85 f6                	test   %esi,%esi
  800464:	75 19                	jne    80047f <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  800466:	53                   	push   %ebx
  800467:	68 11 12 80 00       	push   $0x801211
  80046c:	ff 75 0c             	pushl  0xc(%ebp)
  80046f:	ff 75 08             	pushl  0x8(%ebp)
  800472:	e8 5e 02 00 00       	call   8006d5 <printfmt>
  800477:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80047a:	e9 49 02 00 00       	jmp    8006c8 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80047f:	56                   	push   %esi
  800480:	68 1a 12 80 00       	push   $0x80121a
  800485:	ff 75 0c             	pushl  0xc(%ebp)
  800488:	ff 75 08             	pushl  0x8(%ebp)
  80048b:	e8 45 02 00 00       	call   8006d5 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			break;
  800493:	e9 30 02 00 00       	jmp    8006c8 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800498:	8b 45 14             	mov    0x14(%ebp),%eax
  80049b:	83 c0 04             	add    $0x4,%eax
  80049e:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	83 e8 04             	sub    $0x4,%eax
  8004a7:	8b 30                	mov    (%eax),%esi
  8004a9:	85 f6                	test   %esi,%esi
  8004ab:	75 05                	jne    8004b2 <vprintfmt+0x1a6>
				p = "(null)";
  8004ad:	be 1d 12 80 00       	mov    $0x80121d,%esi
			if (width > 0 && padc != '-')
  8004b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004b6:	7e 6d                	jle    800525 <vprintfmt+0x219>
  8004b8:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8004bc:	74 67                	je     800525 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	50                   	push   %eax
  8004c5:	56                   	push   %esi
  8004c6:	e8 0c 03 00 00       	call   8007d7 <strnlen>
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8004d1:	eb 16                	jmp    8004e9 <vprintfmt+0x1dd>
					putch(padc, putdat);
  8004d3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8004d7:	83 ec 08             	sub    $0x8,%esp
  8004da:	ff 75 0c             	pushl  0xc(%ebp)
  8004dd:	50                   	push   %eax
  8004de:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e1:	ff d0                	call   *%eax
  8004e3:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e6:	ff 4d e4             	decl   -0x1c(%ebp)
  8004e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ed:	7f e4                	jg     8004d3 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ef:	eb 34                	jmp    800525 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f5:	74 1c                	je     800513 <vprintfmt+0x207>
  8004f7:	83 fb 1f             	cmp    $0x1f,%ebx
  8004fa:	7e 05                	jle    800501 <vprintfmt+0x1f5>
  8004fc:	83 fb 7e             	cmp    $0x7e,%ebx
  8004ff:	7e 12                	jle    800513 <vprintfmt+0x207>
					putch('?', putdat);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	ff 75 0c             	pushl  0xc(%ebp)
  800507:	6a 3f                	push   $0x3f
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	ff d0                	call   *%eax
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	eb 0f                	jmp    800522 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800513:	83 ec 08             	sub    $0x8,%esp
  800516:	ff 75 0c             	pushl  0xc(%ebp)
  800519:	53                   	push   %ebx
  80051a:	8b 45 08             	mov    0x8(%ebp),%eax
  80051d:	ff d0                	call   *%eax
  80051f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800522:	ff 4d e4             	decl   -0x1c(%ebp)
  800525:	89 f0                	mov    %esi,%eax
  800527:	8d 70 01             	lea    0x1(%eax),%esi
  80052a:	8a 00                	mov    (%eax),%al
  80052c:	0f be d8             	movsbl %al,%ebx
  80052f:	85 db                	test   %ebx,%ebx
  800531:	74 24                	je     800557 <vprintfmt+0x24b>
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	78 b8                	js     8004f1 <vprintfmt+0x1e5>
  800539:	ff 4d e0             	decl   -0x20(%ebp)
  80053c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800540:	79 af                	jns    8004f1 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800542:	eb 13                	jmp    800557 <vprintfmt+0x24b>
				putch(' ', putdat);
  800544:	83 ec 08             	sub    $0x8,%esp
  800547:	ff 75 0c             	pushl  0xc(%ebp)
  80054a:	6a 20                	push   $0x20
  80054c:	8b 45 08             	mov    0x8(%ebp),%eax
  80054f:	ff d0                	call   *%eax
  800551:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800554:	ff 4d e4             	decl   -0x1c(%ebp)
  800557:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80055b:	7f e7                	jg     800544 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  80055d:	e9 66 01 00 00       	jmp    8006c8 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	ff 75 e8             	pushl  -0x18(%ebp)
  800568:	8d 45 14             	lea    0x14(%ebp),%eax
  80056b:	50                   	push   %eax
  80056c:	e8 3c fd ff ff       	call   8002ad <getint>
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800577:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80057a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80057d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800580:	85 d2                	test   %edx,%edx
  800582:	79 23                	jns    8005a7 <vprintfmt+0x29b>
				putch('-', putdat);
  800584:	83 ec 08             	sub    $0x8,%esp
  800587:	ff 75 0c             	pushl  0xc(%ebp)
  80058a:	6a 2d                	push   $0x2d
  80058c:	8b 45 08             	mov    0x8(%ebp),%eax
  80058f:	ff d0                	call   *%eax
  800591:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  800594:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800597:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80059a:	f7 d8                	neg    %eax
  80059c:	83 d2 00             	adc    $0x0,%edx
  80059f:	f7 da                	neg    %edx
  8005a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005a7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005ae:	e9 bc 00 00 00       	jmp    80066f <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 e8             	pushl  -0x18(%ebp)
  8005b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bc:	50                   	push   %eax
  8005bd:	e8 84 fc ff ff       	call   800246 <getuint>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005c8:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8005cb:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005d2:	e9 98 00 00 00       	jmp    80066f <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005d7:	83 ec 08             	sub    $0x8,%esp
  8005da:	ff 75 0c             	pushl  0xc(%ebp)
  8005dd:	6a 58                	push   $0x58
  8005df:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e2:	ff d0                	call   *%eax
  8005e4:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	ff 75 0c             	pushl  0xc(%ebp)
  8005ed:	6a 58                	push   $0x58
  8005ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f2:	ff d0                	call   *%eax
  8005f4:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  8005f7:	83 ec 08             	sub    $0x8,%esp
  8005fa:	ff 75 0c             	pushl  0xc(%ebp)
  8005fd:	6a 58                	push   $0x58
  8005ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800602:	ff d0                	call   *%eax
  800604:	83 c4 10             	add    $0x10,%esp
			break;
  800607:	e9 bc 00 00 00       	jmp    8006c8 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	ff 75 0c             	pushl  0xc(%ebp)
  800612:	6a 30                	push   $0x30
  800614:	8b 45 08             	mov    0x8(%ebp),%eax
  800617:	ff d0                	call   *%eax
  800619:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	6a 78                	push   $0x78
  800624:	8b 45 08             	mov    0x8(%ebp),%eax
  800627:	ff d0                	call   *%eax
  800629:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	83 c0 04             	add    $0x4,%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	83 e8 04             	sub    $0x4,%eax
  80063b:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80063d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800640:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  800647:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  80064e:	eb 1f                	jmp    80066f <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	ff 75 e8             	pushl  -0x18(%ebp)
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	50                   	push   %eax
  80065a:	e8 e7 fb ff ff       	call   800246 <getuint>
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800665:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800668:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066f:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800673:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	52                   	push   %edx
  80067a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80067d:	50                   	push   %eax
  80067e:	ff 75 f4             	pushl  -0xc(%ebp)
  800681:	ff 75 f0             	pushl  -0x10(%ebp)
  800684:	ff 75 0c             	pushl  0xc(%ebp)
  800687:	ff 75 08             	pushl  0x8(%ebp)
  80068a:	e8 00 fb ff ff       	call   80018f <printnum>
  80068f:	83 c4 20             	add    $0x20,%esp
			break;
  800692:	eb 34                	jmp    8006c8 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800694:	83 ec 08             	sub    $0x8,%esp
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	53                   	push   %ebx
  80069b:	8b 45 08             	mov    0x8(%ebp),%eax
  80069e:	ff d0                	call   *%eax
  8006a0:	83 c4 10             	add    $0x10,%esp
			break;
  8006a3:	eb 23                	jmp    8006c8 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	6a 25                	push   $0x25
  8006ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b0:	ff d0                	call   *%eax
  8006b2:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b5:	ff 4d 10             	decl   0x10(%ebp)
  8006b8:	eb 03                	jmp    8006bd <vprintfmt+0x3b1>
  8006ba:	ff 4d 10             	decl   0x10(%ebp)
  8006bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8006c0:	48                   	dec    %eax
  8006c1:	8a 00                	mov    (%eax),%al
  8006c3:	3c 25                	cmp    $0x25,%al
  8006c5:	75 f3                	jne    8006ba <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  8006c7:	90                   	nop
		}
	}
  8006c8:	e9 47 fc ff ff       	jmp    800314 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  8006cd:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5d                   	pop    %ebp
  8006d4:	c3                   	ret    

008006d5 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8006db:	8d 45 10             	lea    0x10(%ebp),%eax
  8006de:	83 c0 04             	add    $0x4,%eax
  8006e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  8006e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8006ea:	50                   	push   %eax
  8006eb:	ff 75 0c             	pushl  0xc(%ebp)
  8006ee:	ff 75 08             	pushl  0x8(%ebp)
  8006f1:	e8 16 fc ff ff       	call   80030c <vprintfmt>
  8006f6:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  8006f9:	90                   	nop
  8006fa:	c9                   	leave  
  8006fb:	c3                   	ret    

008006fc <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8006ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800702:	8b 40 08             	mov    0x8(%eax),%eax
  800705:	8d 50 01             	lea    0x1(%eax),%edx
  800708:	8b 45 0c             	mov    0xc(%ebp),%eax
  80070b:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80070e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800711:	8b 10                	mov    (%eax),%edx
  800713:	8b 45 0c             	mov    0xc(%ebp),%eax
  800716:	8b 40 04             	mov    0x4(%eax),%eax
  800719:	39 c2                	cmp    %eax,%edx
  80071b:	73 12                	jae    80072f <sprintputch+0x33>
		*b->buf++ = ch;
  80071d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800720:	8b 00                	mov    (%eax),%eax
  800722:	8d 48 01             	lea    0x1(%eax),%ecx
  800725:	8b 55 0c             	mov    0xc(%ebp),%edx
  800728:	89 0a                	mov    %ecx,(%edx)
  80072a:	8b 55 08             	mov    0x8(%ebp),%edx
  80072d:	88 10                	mov    %dl,(%eax)
}
  80072f:	90                   	nop
  800730:	5d                   	pop    %ebp
  800731:	c3                   	ret    

00800732 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800741:	8d 50 ff             	lea    -0x1(%eax),%edx
  800744:	8b 45 08             	mov    0x8(%ebp),%eax
  800747:	01 d0                	add    %edx,%eax
  800749:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800757:	74 06                	je     80075f <vsnprintf+0x2d>
  800759:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80075d:	7f 07                	jg     800766 <vsnprintf+0x34>
		return -E_INVAL;
  80075f:	b8 03 00 00 00       	mov    $0x3,%eax
  800764:	eb 20                	jmp    800786 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800766:	ff 75 14             	pushl  0x14(%ebp)
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	68 fc 06 80 00       	push   $0x8006fc
  800775:	e8 92 fb ff ff       	call   80030c <vprintfmt>
  80077a:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  80077d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800780:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800783:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800786:	c9                   	leave  
  800787:	c3                   	ret    

00800788 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078e:	8d 45 10             	lea    0x10(%ebp),%eax
  800791:	83 c0 04             	add    $0x4,%eax
  800794:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800797:	8b 45 10             	mov    0x10(%ebp),%eax
  80079a:	ff 75 f4             	pushl  -0xc(%ebp)
  80079d:	50                   	push   %eax
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	ff 75 08             	pushl  0x8(%ebp)
  8007a4:	e8 89 ff ff ff       	call   800732 <vsnprintf>
  8007a9:	83 c4 10             	add    $0x10,%esp
  8007ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8007af:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ba:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007c1:	eb 06                	jmp    8007c9 <strlen+0x15>
		n++;
  8007c3:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	ff 45 08             	incl   0x8(%ebp)
  8007c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cc:	8a 00                	mov    (%eax),%al
  8007ce:	84 c0                	test   %al,%al
  8007d0:	75 f1                	jne    8007c3 <strlen+0xf>
		n++;
	return n;
  8007d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8007e4:	eb 09                	jmp    8007ef <strnlen+0x18>
		n++;
  8007e6:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e9:	ff 45 08             	incl   0x8(%ebp)
  8007ec:	ff 4d 0c             	decl   0xc(%ebp)
  8007ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007f3:	74 09                	je     8007fe <strnlen+0x27>
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8a 00                	mov    (%eax),%al
  8007fa:	84 c0                	test   %al,%al
  8007fc:	75 e8                	jne    8007e6 <strnlen+0xf>
		n++;
	return n;
  8007fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800809:	8b 45 08             	mov    0x8(%ebp),%eax
  80080c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80080f:	90                   	nop
  800810:	8b 45 08             	mov    0x8(%ebp),%eax
  800813:	8d 50 01             	lea    0x1(%eax),%edx
  800816:	89 55 08             	mov    %edx,0x8(%ebp)
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80081f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800822:	8a 12                	mov    (%edx),%dl
  800824:	88 10                	mov    %dl,(%eax)
  800826:	8a 00                	mov    (%eax),%al
  800828:	84 c0                	test   %al,%al
  80082a:	75 e4                	jne    800810 <strcpy+0xd>
		/* do nothing */;
	return ret;
  80082c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80082f:	c9                   	leave  
  800830:	c3                   	ret    

00800831 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800837:	8b 45 08             	mov    0x8(%ebp),%eax
  80083a:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80083d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800844:	eb 1f                	jmp    800865 <strncpy+0x34>
		*dst++ = *src;
  800846:	8b 45 08             	mov    0x8(%ebp),%eax
  800849:	8d 50 01             	lea    0x1(%eax),%edx
  80084c:	89 55 08             	mov    %edx,0x8(%ebp)
  80084f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800852:	8a 12                	mov    (%edx),%dl
  800854:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	8a 00                	mov    (%eax),%al
  80085b:	84 c0                	test   %al,%al
  80085d:	74 03                	je     800862 <strncpy+0x31>
			src++;
  80085f:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800862:	ff 45 fc             	incl   -0x4(%ebp)
  800865:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800868:	3b 45 10             	cmp    0x10(%ebp),%eax
  80086b:	72 d9                	jb     800846 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  80086d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800870:	c9                   	leave  
  800871:	c3                   	ret    

00800872 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  80087e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800882:	74 30                	je     8008b4 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800884:	eb 16                	jmp    80089c <strlcpy+0x2a>
			*dst++ = *src++;
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8d 50 01             	lea    0x1(%eax),%edx
  80088c:	89 55 08             	mov    %edx,0x8(%ebp)
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	8d 4a 01             	lea    0x1(%edx),%ecx
  800895:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800898:	8a 12                	mov    (%edx),%dl
  80089a:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089c:	ff 4d 10             	decl   0x10(%ebp)
  80089f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008a3:	74 09                	je     8008ae <strlcpy+0x3c>
  8008a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a8:	8a 00                	mov    (%eax),%al
  8008aa:	84 c0                	test   %al,%al
  8008ac:	75 d8                	jne    800886 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8008b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ba:	29 c2                	sub    %eax,%edx
  8008bc:	89 d0                	mov    %edx,%eax
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  8008c3:	eb 06                	jmp    8008cb <strcmp+0xb>
		p++, q++;
  8008c5:	ff 45 08             	incl   0x8(%ebp)
  8008c8:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8a 00                	mov    (%eax),%al
  8008d0:	84 c0                	test   %al,%al
  8008d2:	74 0e                	je     8008e2 <strcmp+0x22>
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	8a 10                	mov    (%eax),%dl
  8008d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dc:	8a 00                	mov    (%eax),%al
  8008de:	38 c2                	cmp    %al,%dl
  8008e0:	74 e3                	je     8008c5 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e5:	8a 00                	mov    (%eax),%al
  8008e7:	0f b6 d0             	movzbl %al,%edx
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	8a 00                	mov    (%eax),%al
  8008ef:	0f b6 c0             	movzbl %al,%eax
  8008f2:	29 c2                	sub    %eax,%edx
  8008f4:	89 d0                	mov    %edx,%eax
}
  8008f6:	5d                   	pop    %ebp
  8008f7:	c3                   	ret    

008008f8 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  8008fb:	eb 09                	jmp    800906 <strncmp+0xe>
		n--, p++, q++;
  8008fd:	ff 4d 10             	decl   0x10(%ebp)
  800900:	ff 45 08             	incl   0x8(%ebp)
  800903:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800906:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80090a:	74 17                	je     800923 <strncmp+0x2b>
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	8a 00                	mov    (%eax),%al
  800911:	84 c0                	test   %al,%al
  800913:	74 0e                	je     800923 <strncmp+0x2b>
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8a 10                	mov    (%eax),%dl
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	8a 00                	mov    (%eax),%al
  80091f:	38 c2                	cmp    %al,%dl
  800921:	74 da                	je     8008fd <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800923:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800927:	75 07                	jne    800930 <strncmp+0x38>
		return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
  80092e:	eb 14                	jmp    800944 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800930:	8b 45 08             	mov    0x8(%ebp),%eax
  800933:	8a 00                	mov    (%eax),%al
  800935:	0f b6 d0             	movzbl %al,%edx
  800938:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093b:	8a 00                	mov    (%eax),%al
  80093d:	0f b6 c0             	movzbl %al,%eax
  800940:	29 c2                	sub    %eax,%edx
  800942:	89 d0                	mov    %edx,%eax
}
  800944:	5d                   	pop    %ebp
  800945:	c3                   	ret    

00800946 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 04             	sub    $0x4,%esp
  80094c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800952:	eb 12                	jmp    800966 <strchr+0x20>
		if (*s == c)
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8a 00                	mov    (%eax),%al
  800959:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80095c:	75 05                	jne    800963 <strchr+0x1d>
			return (char *) s;
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	eb 11                	jmp    800974 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800963:	ff 45 08             	incl   0x8(%ebp)
  800966:	8b 45 08             	mov    0x8(%ebp),%eax
  800969:	8a 00                	mov    (%eax),%al
  80096b:	84 c0                	test   %al,%al
  80096d:	75 e5                	jne    800954 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  80096f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800974:	c9                   	leave  
  800975:	c3                   	ret    

00800976 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	83 ec 04             	sub    $0x4,%esp
  80097c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800982:	eb 0d                	jmp    800991 <strfind+0x1b>
		if (*s == c)
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8a 00                	mov    (%eax),%al
  800989:	3a 45 fc             	cmp    -0x4(%ebp),%al
  80098c:	74 0e                	je     80099c <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098e:	ff 45 08             	incl   0x8(%ebp)
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8a 00                	mov    (%eax),%al
  800996:	84 c0                	test   %al,%al
  800998:	75 ea                	jne    800984 <strfind+0xe>
  80099a:	eb 01                	jmp    80099d <strfind+0x27>
		if (*s == c)
			break;
  80099c:	90                   	nop
	return (char *) s;
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  8009b4:	eb 0e                	jmp    8009c4 <memset+0x22>
		*p++ = c;
  8009b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009b9:	8d 50 01             	lea    0x1(%eax),%edx
  8009bc:	89 55 fc             	mov    %edx,-0x4(%ebp)
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c2:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  8009c4:	ff 4d f8             	decl   -0x8(%ebp)
  8009c7:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  8009cb:	79 e9                	jns    8009b6 <memset+0x14>
		*p++ = c;

	return v;
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    

008009d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  8009d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009db:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  8009e4:	eb 16                	jmp    8009fc <memcpy+0x2a>
		*d++ = *s++;
  8009e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8009e9:	8d 50 01             	lea    0x1(%eax),%edx
  8009ec:	89 55 f8             	mov    %edx,-0x8(%ebp)
  8009ef:	8b 55 fc             	mov    -0x4(%ebp),%edx
  8009f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009f5:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  8009f8:	8a 12                	mov    (%edx),%dl
  8009fa:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a02:	89 55 10             	mov    %edx,0x10(%ebp)
  800a05:	85 c0                	test   %eax,%eax
  800a07:	75 dd                	jne    8009e6 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a17:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800a20:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a23:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a26:	73 50                	jae    800a78 <memmove+0x6a>
  800a28:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	01 d0                	add    %edx,%eax
  800a30:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a33:	76 43                	jbe    800a78 <memmove+0x6a>
		s += n;
  800a35:	8b 45 10             	mov    0x10(%ebp),%eax
  800a38:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800a3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3e:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800a41:	eb 10                	jmp    800a53 <memmove+0x45>
			*--d = *--s;
  800a43:	ff 4d f8             	decl   -0x8(%ebp)
  800a46:	ff 4d fc             	decl   -0x4(%ebp)
  800a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a4c:	8a 10                	mov    (%eax),%dl
  800a4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a51:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a53:	8b 45 10             	mov    0x10(%ebp),%eax
  800a56:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a59:	89 55 10             	mov    %edx,0x10(%ebp)
  800a5c:	85 c0                	test   %eax,%eax
  800a5e:	75 e3                	jne    800a43 <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a60:	eb 23                	jmp    800a85 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800a62:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a65:	8d 50 01             	lea    0x1(%eax),%edx
  800a68:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800a6b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a6e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a71:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800a74:	8a 12                	mov    (%edx),%dl
  800a76:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800a78:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a7e:	89 55 10             	mov    %edx,0x10(%ebp)
  800a81:	85 c0                	test   %eax,%eax
  800a83:	75 dd                	jne    800a62 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a88:	c9                   	leave  
  800a89:	c3                   	ret    

00800a8a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
  800a8d:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800a90:	8b 45 08             	mov    0x8(%ebp),%eax
  800a93:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a99:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800a9c:	eb 2a                	jmp    800ac8 <memcmp+0x3e>
		if (*s1 != *s2)
  800a9e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aa1:	8a 10                	mov    (%eax),%dl
  800aa3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800aa6:	8a 00                	mov    (%eax),%al
  800aa8:	38 c2                	cmp    %al,%dl
  800aaa:	74 16                	je     800ac2 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800aac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aaf:	8a 00                	mov    (%eax),%al
  800ab1:	0f b6 d0             	movzbl %al,%edx
  800ab4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ab7:	8a 00                	mov    (%eax),%al
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	29 c2                	sub    %eax,%edx
  800abe:	89 d0                	mov    %edx,%eax
  800ac0:	eb 18                	jmp    800ada <memcmp+0x50>
		s1++, s2++;
  800ac2:	ff 45 fc             	incl   -0x4(%ebp)
  800ac5:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800ac8:	8b 45 10             	mov    0x10(%ebp),%eax
  800acb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ace:	89 55 10             	mov    %edx,0x10(%ebp)
  800ad1:	85 c0                	test   %eax,%eax
  800ad3:	75 c9                	jne    800a9e <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ada:	c9                   	leave  
  800adb:	c3                   	ret    

00800adc <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae8:	01 d0                	add    %edx,%eax
  800aea:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800aed:	eb 15                	jmp    800b04 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aef:	8b 45 08             	mov    0x8(%ebp),%eax
  800af2:	8a 00                	mov    (%eax),%al
  800af4:	0f b6 d0             	movzbl %al,%edx
  800af7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afa:	0f b6 c0             	movzbl %al,%eax
  800afd:	39 c2                	cmp    %eax,%edx
  800aff:	74 0d                	je     800b0e <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	ff 45 08             	incl   0x8(%ebp)
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800b0a:	72 e3                	jb     800aef <memfind+0x13>
  800b0c:	eb 01                	jmp    800b0f <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800b0e:	90                   	nop
	return (void *) s;
  800b0f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b12:	c9                   	leave  
  800b13:	c3                   	ret    

00800b14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800b1a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800b21:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	eb 03                	jmp    800b2d <strtol+0x19>
		s++;
  800b2a:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b30:	8a 00                	mov    (%eax),%al
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	74 f4                	je     800b2a <strtol+0x16>
  800b36:	8b 45 08             	mov    0x8(%ebp),%eax
  800b39:	8a 00                	mov    (%eax),%al
  800b3b:	3c 09                	cmp    $0x9,%al
  800b3d:	74 eb                	je     800b2a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b42:	8a 00                	mov    (%eax),%al
  800b44:	3c 2b                	cmp    $0x2b,%al
  800b46:	75 05                	jne    800b4d <strtol+0x39>
		s++;
  800b48:	ff 45 08             	incl   0x8(%ebp)
  800b4b:	eb 13                	jmp    800b60 <strtol+0x4c>
	else if (*s == '-')
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8a 00                	mov    (%eax),%al
  800b52:	3c 2d                	cmp    $0x2d,%al
  800b54:	75 0a                	jne    800b60 <strtol+0x4c>
		s++, neg = 1;
  800b56:	ff 45 08             	incl   0x8(%ebp)
  800b59:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b64:	74 06                	je     800b6c <strtol+0x58>
  800b66:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800b6a:	75 20                	jne    800b8c <strtol+0x78>
  800b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6f:	8a 00                	mov    (%eax),%al
  800b71:	3c 30                	cmp    $0x30,%al
  800b73:	75 17                	jne    800b8c <strtol+0x78>
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	40                   	inc    %eax
  800b79:	8a 00                	mov    (%eax),%al
  800b7b:	3c 78                	cmp    $0x78,%al
  800b7d:	75 0d                	jne    800b8c <strtol+0x78>
		s += 2, base = 16;
  800b7f:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800b83:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800b8a:	eb 28                	jmp    800bb4 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800b8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800b90:	75 15                	jne    800ba7 <strtol+0x93>
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8a 00                	mov    (%eax),%al
  800b97:	3c 30                	cmp    $0x30,%al
  800b99:	75 0c                	jne    800ba7 <strtol+0x93>
		s++, base = 8;
  800b9b:	ff 45 08             	incl   0x8(%ebp)
  800b9e:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800ba5:	eb 0d                	jmp    800bb4 <strtol+0xa0>
	else if (base == 0)
  800ba7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bab:	75 07                	jne    800bb4 <strtol+0xa0>
		base = 10;
  800bad:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb7:	8a 00                	mov    (%eax),%al
  800bb9:	3c 2f                	cmp    $0x2f,%al
  800bbb:	7e 19                	jle    800bd6 <strtol+0xc2>
  800bbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc0:	8a 00                	mov    (%eax),%al
  800bc2:	3c 39                	cmp    $0x39,%al
  800bc4:	7f 10                	jg     800bd6 <strtol+0xc2>
			dig = *s - '0';
  800bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc9:	8a 00                	mov    (%eax),%al
  800bcb:	0f be c0             	movsbl %al,%eax
  800bce:	83 e8 30             	sub    $0x30,%eax
  800bd1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800bd4:	eb 42                	jmp    800c18 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd9:	8a 00                	mov    (%eax),%al
  800bdb:	3c 60                	cmp    $0x60,%al
  800bdd:	7e 19                	jle    800bf8 <strtol+0xe4>
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	8a 00                	mov    (%eax),%al
  800be4:	3c 7a                	cmp    $0x7a,%al
  800be6:	7f 10                	jg     800bf8 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	8a 00                	mov    (%eax),%al
  800bed:	0f be c0             	movsbl %al,%eax
  800bf0:	83 e8 57             	sub    $0x57,%eax
  800bf3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800bf6:	eb 20                	jmp    800c18 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfb:	8a 00                	mov    (%eax),%al
  800bfd:	3c 40                	cmp    $0x40,%al
  800bff:	7e 39                	jle    800c3a <strtol+0x126>
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8a 00                	mov    (%eax),%al
  800c06:	3c 5a                	cmp    $0x5a,%al
  800c08:	7f 30                	jg     800c3a <strtol+0x126>
			dig = *s - 'A' + 10;
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	8a 00                	mov    (%eax),%al
  800c0f:	0f be c0             	movsbl %al,%eax
  800c12:	83 e8 37             	sub    $0x37,%eax
  800c15:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c1b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c1e:	7d 19                	jge    800c39 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800c20:	ff 45 08             	incl   0x8(%ebp)
  800c23:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c2a:	89 c2                	mov    %eax,%edx
  800c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2f:	01 d0                	add    %edx,%eax
  800c31:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800c34:	e9 7b ff ff ff       	jmp    800bb4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800c39:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 08                	je     800c48 <strtol+0x134>
		*endptr = (char *) s;
  800c40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c48:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800c4c:	74 07                	je     800c55 <strtol+0x141>
  800c4e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c51:	f7 d8                	neg    %eax
  800c53:	eb 03                	jmp    800c58 <strtol+0x144>
  800c55:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800c58:	c9                   	leave  
  800c59:	c3                   	ret    

00800c5a <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800c5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800c60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800c66:	8b 45 14             	mov    0x14(%ebp),%eax
  800c69:	8b 00                	mov    (%eax),%eax
  800c6b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800c72:	8b 45 10             	mov    0x10(%ebp),%eax
  800c75:	01 d0                	add    %edx,%eax
  800c77:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800c7d:	eb 0c                	jmp    800c8b <strsplit+0x31>
			*string++ = 0;
  800c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c82:	8d 50 01             	lea    0x1(%eax),%edx
  800c85:	89 55 08             	mov    %edx,0x8(%ebp)
  800c88:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	8a 00                	mov    (%eax),%al
  800c90:	84 c0                	test   %al,%al
  800c92:	74 18                	je     800cac <strsplit+0x52>
  800c94:	8b 45 08             	mov    0x8(%ebp),%eax
  800c97:	8a 00                	mov    (%eax),%al
  800c99:	0f be c0             	movsbl %al,%eax
  800c9c:	50                   	push   %eax
  800c9d:	ff 75 0c             	pushl  0xc(%ebp)
  800ca0:	e8 a1 fc ff ff       	call   800946 <strchr>
  800ca5:	83 c4 08             	add    $0x8,%esp
  800ca8:	85 c0                	test   %eax,%eax
  800caa:	75 d3                	jne    800c7f <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	8a 00                	mov    (%eax),%al
  800cb1:	84 c0                	test   %al,%al
  800cb3:	74 5a                	je     800d0f <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800cb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800cb8:	8b 00                	mov    (%eax),%eax
  800cba:	83 f8 0f             	cmp    $0xf,%eax
  800cbd:	75 07                	jne    800cc6 <strsplit+0x6c>
		{
			return 0;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc4:	eb 66                	jmp    800d2c <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800cc6:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc9:	8b 00                	mov    (%eax),%eax
  800ccb:	8d 48 01             	lea    0x1(%eax),%ecx
  800cce:	8b 55 14             	mov    0x14(%ebp),%edx
  800cd1:	89 0a                	mov    %ecx,(%edx)
  800cd3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800cda:	8b 45 10             	mov    0x10(%ebp),%eax
  800cdd:	01 c2                	add    %eax,%edx
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce2:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800ce4:	eb 03                	jmp    800ce9 <strsplit+0x8f>
			string++;
  800ce6:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8a 00                	mov    (%eax),%al
  800cee:	84 c0                	test   %al,%al
  800cf0:	74 8b                	je     800c7d <strsplit+0x23>
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8a 00                	mov    (%eax),%al
  800cf7:	0f be c0             	movsbl %al,%eax
  800cfa:	50                   	push   %eax
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	e8 43 fc ff ff       	call   800946 <strchr>
  800d03:	83 c4 08             	add    $0x8,%esp
  800d06:	85 c0                	test   %eax,%eax
  800d08:	74 dc                	je     800ce6 <strsplit+0x8c>
			string++;
	}
  800d0a:	e9 6e ff ff ff       	jmp    800c7d <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800d0f:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800d10:	8b 45 14             	mov    0x14(%ebp),%eax
  800d13:	8b 00                	mov    (%eax),%eax
  800d15:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1f:	01 d0                	add    %edx,%eax
  800d21:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800d27:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	57                   	push   %edi
  800d32:	56                   	push   %esi
  800d33:	53                   	push   %ebx
  800d34:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d40:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800d43:	8b 7d 18             	mov    0x18(%ebp),%edi
  800d46:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800d49:	cd 30                	int    $0x30
  800d4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800d4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800d51:	83 c4 10             	add    $0x10,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	6a 00                	push   $0x0
  800d61:	6a 00                	push   $0x0
  800d63:	6a 00                	push   $0x0
  800d65:	ff 75 0c             	pushl  0xc(%ebp)
  800d68:	50                   	push   %eax
  800d69:	6a 00                	push   $0x0
  800d6b:	e8 be ff ff ff       	call   800d2e <syscall>
  800d70:	83 c4 18             	add    $0x18,%esp
}
  800d73:	90                   	nop
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800d79:	6a 00                	push   $0x0
  800d7b:	6a 00                	push   $0x0
  800d7d:	6a 00                	push   $0x0
  800d7f:	6a 00                	push   $0x0
  800d81:	6a 00                	push   $0x0
  800d83:	6a 01                	push   $0x1
  800d85:	e8 a4 ff ff ff       	call   800d2e <syscall>
  800d8a:	83 c4 18             	add    $0x18,%esp
}
  800d8d:	c9                   	leave  
  800d8e:	c3                   	ret    

00800d8f <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800d92:	8b 45 08             	mov    0x8(%ebp),%eax
  800d95:	6a 00                	push   $0x0
  800d97:	6a 00                	push   $0x0
  800d99:	6a 00                	push   $0x0
  800d9b:	6a 00                	push   $0x0
  800d9d:	50                   	push   %eax
  800d9e:	6a 03                	push   $0x3
  800da0:	e8 89 ff ff ff       	call   800d2e <syscall>
  800da5:	83 c4 18             	add    $0x18,%esp
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <sys_getenvid>:

int32 sys_getenvid(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800dad:	6a 00                	push   $0x0
  800daf:	6a 00                	push   $0x0
  800db1:	6a 00                	push   $0x0
  800db3:	6a 00                	push   $0x0
  800db5:	6a 00                	push   $0x0
  800db7:	6a 02                	push   $0x2
  800db9:	e8 70 ff ff ff       	call   800d2e <syscall>
  800dbe:	83 c4 18             	add    $0x18,%esp
}
  800dc1:	c9                   	leave  
  800dc2:	c3                   	ret    

00800dc3 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800dc3:	55                   	push   %ebp
  800dc4:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800dc6:	6a 00                	push   $0x0
  800dc8:	6a 00                	push   $0x0
  800dca:	6a 00                	push   $0x0
  800dcc:	6a 00                	push   $0x0
  800dce:	6a 00                	push   $0x0
  800dd0:	6a 04                	push   $0x4
  800dd2:	e8 57 ff ff ff       	call   800d2e <syscall>
  800dd7:	83 c4 18             	add    $0x18,%esp
}
  800dda:	90                   	nop
  800ddb:	c9                   	leave  
  800ddc:	c3                   	ret    

00800ddd <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800de0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de3:	8b 45 08             	mov    0x8(%ebp),%eax
  800de6:	6a 00                	push   $0x0
  800de8:	6a 00                	push   $0x0
  800dea:	6a 00                	push   $0x0
  800dec:	52                   	push   %edx
  800ded:	50                   	push   %eax
  800dee:	6a 05                	push   $0x5
  800df0:	e8 39 ff ff ff       	call   800d2e <syscall>
  800df5:	83 c4 18             	add    $0x18,%esp
}
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800dfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	52                   	push   %edx
  800e0a:	50                   	push   %eax
  800e0b:	6a 06                	push   $0x6
  800e0d:	e8 1c ff ff ff       	call   800d2e <syscall>
  800e12:	83 c4 18             	add    $0x18,%esp
}
  800e15:	c9                   	leave  
  800e16:	c3                   	ret    

00800e17 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800e1c:	8b 75 18             	mov    0x18(%ebp),%esi
  800e1f:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e22:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	51                   	push   %ecx
  800e2e:	52                   	push   %edx
  800e2f:	50                   	push   %eax
  800e30:	6a 07                	push   $0x7
  800e32:	e8 f7 fe ff ff       	call   800d2e <syscall>
  800e37:	83 c4 18             	add    $0x18,%esp
}
  800e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  800e44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	6a 00                	push   $0x0
  800e4c:	6a 00                	push   $0x0
  800e4e:	6a 00                	push   $0x0
  800e50:	52                   	push   %edx
  800e51:	50                   	push   %eax
  800e52:	6a 08                	push   $0x8
  800e54:	e8 d5 fe ff ff       	call   800d2e <syscall>
  800e59:	83 c4 18             	add    $0x18,%esp
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  800e61:	6a 00                	push   $0x0
  800e63:	6a 00                	push   $0x0
  800e65:	6a 00                	push   $0x0
  800e67:	ff 75 0c             	pushl  0xc(%ebp)
  800e6a:	ff 75 08             	pushl  0x8(%ebp)
  800e6d:	6a 09                	push   $0x9
  800e6f:	e8 ba fe ff ff       	call   800d2e <syscall>
  800e74:	83 c4 18             	add    $0x18,%esp
}
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  800e7c:	6a 00                	push   $0x0
  800e7e:	6a 00                	push   $0x0
  800e80:	6a 00                	push   $0x0
  800e82:	6a 00                	push   $0x0
  800e84:	6a 00                	push   $0x0
  800e86:	6a 0a                	push   $0xa
  800e88:	e8 a1 fe ff ff       	call   800d2e <syscall>
  800e8d:	83 c4 18             	add    $0x18,%esp
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	6a 00                	push   $0x0
  800e9a:	6a 00                	push   $0x0
  800e9c:	6a 00                	push   $0x0
  800e9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ea1:	50                   	push   %eax
  800ea2:	6a 0b                	push   $0xb
  800ea4:	e8 85 fe ff ff       	call   800d2e <syscall>
  800ea9:	83 c4 18             	add    $0x18,%esp
	return;
  800eac:	90                   	nop
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    
  800eaf:	90                   	nop

00800eb0 <__udivdi3>:
  800eb0:	55                   	push   %ebp
  800eb1:	57                   	push   %edi
  800eb2:	56                   	push   %esi
  800eb3:	53                   	push   %ebx
  800eb4:	83 ec 1c             	sub    $0x1c,%esp
  800eb7:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800ebb:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800ebf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ec3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ec7:	89 ca                	mov    %ecx,%edx
  800ec9:	89 f8                	mov    %edi,%eax
  800ecb:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800ecf:	85 f6                	test   %esi,%esi
  800ed1:	75 2d                	jne    800f00 <__udivdi3+0x50>
  800ed3:	39 cf                	cmp    %ecx,%edi
  800ed5:	77 65                	ja     800f3c <__udivdi3+0x8c>
  800ed7:	89 fd                	mov    %edi,%ebp
  800ed9:	85 ff                	test   %edi,%edi
  800edb:	75 0b                	jne    800ee8 <__udivdi3+0x38>
  800edd:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee2:	31 d2                	xor    %edx,%edx
  800ee4:	f7 f7                	div    %edi
  800ee6:	89 c5                	mov    %eax,%ebp
  800ee8:	31 d2                	xor    %edx,%edx
  800eea:	89 c8                	mov    %ecx,%eax
  800eec:	f7 f5                	div    %ebp
  800eee:	89 c1                	mov    %eax,%ecx
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	f7 f5                	div    %ebp
  800ef4:	89 cf                	mov    %ecx,%edi
  800ef6:	89 fa                	mov    %edi,%edx
  800ef8:	83 c4 1c             	add    $0x1c,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5f                   	pop    %edi
  800efe:	5d                   	pop    %ebp
  800eff:	c3                   	ret    
  800f00:	39 ce                	cmp    %ecx,%esi
  800f02:	77 28                	ja     800f2c <__udivdi3+0x7c>
  800f04:	0f bd fe             	bsr    %esi,%edi
  800f07:	83 f7 1f             	xor    $0x1f,%edi
  800f0a:	75 40                	jne    800f4c <__udivdi3+0x9c>
  800f0c:	39 ce                	cmp    %ecx,%esi
  800f0e:	72 0a                	jb     800f1a <__udivdi3+0x6a>
  800f10:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f14:	0f 87 9e 00 00 00    	ja     800fb8 <__udivdi3+0x108>
  800f1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d 76 00             	lea    0x0(%esi),%esi
  800f2c:	31 ff                	xor    %edi,%edi
  800f2e:	31 c0                	xor    %eax,%eax
  800f30:	89 fa                	mov    %edi,%edx
  800f32:	83 c4 1c             	add    $0x1c,%esp
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	89 d8                	mov    %ebx,%eax
  800f3e:	f7 f7                	div    %edi
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	89 fa                	mov    %edi,%edx
  800f44:	83 c4 1c             	add    $0x1c,%esp
  800f47:	5b                   	pop    %ebx
  800f48:	5e                   	pop    %esi
  800f49:	5f                   	pop    %edi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    
  800f4c:	bd 20 00 00 00       	mov    $0x20,%ebp
  800f51:	89 eb                	mov    %ebp,%ebx
  800f53:	29 fb                	sub    %edi,%ebx
  800f55:	89 f9                	mov    %edi,%ecx
  800f57:	d3 e6                	shl    %cl,%esi
  800f59:	89 c5                	mov    %eax,%ebp
  800f5b:	88 d9                	mov    %bl,%cl
  800f5d:	d3 ed                	shr    %cl,%ebp
  800f5f:	89 e9                	mov    %ebp,%ecx
  800f61:	09 f1                	or     %esi,%ecx
  800f63:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f67:	89 f9                	mov    %edi,%ecx
  800f69:	d3 e0                	shl    %cl,%eax
  800f6b:	89 c5                	mov    %eax,%ebp
  800f6d:	89 d6                	mov    %edx,%esi
  800f6f:	88 d9                	mov    %bl,%cl
  800f71:	d3 ee                	shr    %cl,%esi
  800f73:	89 f9                	mov    %edi,%ecx
  800f75:	d3 e2                	shl    %cl,%edx
  800f77:	8b 44 24 08          	mov    0x8(%esp),%eax
  800f7b:	88 d9                	mov    %bl,%cl
  800f7d:	d3 e8                	shr    %cl,%eax
  800f7f:	09 c2                	or     %eax,%edx
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	89 f2                	mov    %esi,%edx
  800f85:	f7 74 24 0c          	divl   0xc(%esp)
  800f89:	89 d6                	mov    %edx,%esi
  800f8b:	89 c3                	mov    %eax,%ebx
  800f8d:	f7 e5                	mul    %ebp
  800f8f:	39 d6                	cmp    %edx,%esi
  800f91:	72 19                	jb     800fac <__udivdi3+0xfc>
  800f93:	74 0b                	je     800fa0 <__udivdi3+0xf0>
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	31 ff                	xor    %edi,%edi
  800f99:	e9 58 ff ff ff       	jmp    800ef6 <__udivdi3+0x46>
  800f9e:	66 90                	xchg   %ax,%ax
  800fa0:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fa4:	89 f9                	mov    %edi,%ecx
  800fa6:	d3 e2                	shl    %cl,%edx
  800fa8:	39 c2                	cmp    %eax,%edx
  800faa:	73 e9                	jae    800f95 <__udivdi3+0xe5>
  800fac:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800faf:	31 ff                	xor    %edi,%edi
  800fb1:	e9 40 ff ff ff       	jmp    800ef6 <__udivdi3+0x46>
  800fb6:	66 90                	xchg   %ax,%ax
  800fb8:	31 c0                	xor    %eax,%eax
  800fba:	e9 37 ff ff ff       	jmp    800ef6 <__udivdi3+0x46>
  800fbf:	90                   	nop

00800fc0 <__umoddi3>:
  800fc0:	55                   	push   %ebp
  800fc1:	57                   	push   %edi
  800fc2:	56                   	push   %esi
  800fc3:	53                   	push   %ebx
  800fc4:	83 ec 1c             	sub    $0x1c,%esp
  800fc7:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800fcb:	8b 74 24 34          	mov    0x34(%esp),%esi
  800fcf:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800fd3:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800fd7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fdf:	89 f3                	mov    %esi,%ebx
  800fe1:	89 fa                	mov    %edi,%edx
  800fe3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fe7:	89 34 24             	mov    %esi,(%esp)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	75 1a                	jne    801008 <__umoddi3+0x48>
  800fee:	39 f7                	cmp    %esi,%edi
  800ff0:	0f 86 a2 00 00 00    	jbe    801098 <__umoddi3+0xd8>
  800ff6:	89 c8                	mov    %ecx,%eax
  800ff8:	89 f2                	mov    %esi,%edx
  800ffa:	f7 f7                	div    %edi
  800ffc:	89 d0                	mov    %edx,%eax
  800ffe:	31 d2                	xor    %edx,%edx
  801000:	83 c4 1c             	add    $0x1c,%esp
  801003:	5b                   	pop    %ebx
  801004:	5e                   	pop    %esi
  801005:	5f                   	pop    %edi
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    
  801008:	39 f0                	cmp    %esi,%eax
  80100a:	0f 87 ac 00 00 00    	ja     8010bc <__umoddi3+0xfc>
  801010:	0f bd e8             	bsr    %eax,%ebp
  801013:	83 f5 1f             	xor    $0x1f,%ebp
  801016:	0f 84 ac 00 00 00    	je     8010c8 <__umoddi3+0x108>
  80101c:	bf 20 00 00 00       	mov    $0x20,%edi
  801021:	29 ef                	sub    %ebp,%edi
  801023:	89 fe                	mov    %edi,%esi
  801025:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	d3 e0                	shl    %cl,%eax
  80102d:	89 d7                	mov    %edx,%edi
  80102f:	89 f1                	mov    %esi,%ecx
  801031:	d3 ef                	shr    %cl,%edi
  801033:	09 c7                	or     %eax,%edi
  801035:	89 e9                	mov    %ebp,%ecx
  801037:	d3 e2                	shl    %cl,%edx
  801039:	89 14 24             	mov    %edx,(%esp)
  80103c:	89 d8                	mov    %ebx,%eax
  80103e:	d3 e0                	shl    %cl,%eax
  801040:	89 c2                	mov    %eax,%edx
  801042:	8b 44 24 08          	mov    0x8(%esp),%eax
  801046:	d3 e0                	shl    %cl,%eax
  801048:	89 44 24 04          	mov    %eax,0x4(%esp)
  80104c:	8b 44 24 08          	mov    0x8(%esp),%eax
  801050:	89 f1                	mov    %esi,%ecx
  801052:	d3 e8                	shr    %cl,%eax
  801054:	09 d0                	or     %edx,%eax
  801056:	d3 eb                	shr    %cl,%ebx
  801058:	89 da                	mov    %ebx,%edx
  80105a:	f7 f7                	div    %edi
  80105c:	89 d3                	mov    %edx,%ebx
  80105e:	f7 24 24             	mull   (%esp)
  801061:	89 c6                	mov    %eax,%esi
  801063:	89 d1                	mov    %edx,%ecx
  801065:	39 d3                	cmp    %edx,%ebx
  801067:	0f 82 87 00 00 00    	jb     8010f4 <__umoddi3+0x134>
  80106d:	0f 84 91 00 00 00    	je     801104 <__umoddi3+0x144>
  801073:	8b 54 24 04          	mov    0x4(%esp),%edx
  801077:	29 f2                	sub    %esi,%edx
  801079:	19 cb                	sbb    %ecx,%ebx
  80107b:	89 d8                	mov    %ebx,%eax
  80107d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801081:	d3 e0                	shl    %cl,%eax
  801083:	89 e9                	mov    %ebp,%ecx
  801085:	d3 ea                	shr    %cl,%edx
  801087:	09 d0                	or     %edx,%eax
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 eb                	shr    %cl,%ebx
  80108d:	89 da                	mov    %ebx,%edx
  80108f:	83 c4 1c             	add    $0x1c,%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    
  801097:	90                   	nop
  801098:	89 fd                	mov    %edi,%ebp
  80109a:	85 ff                	test   %edi,%edi
  80109c:	75 0b                	jne    8010a9 <__umoddi3+0xe9>
  80109e:	b8 01 00 00 00       	mov    $0x1,%eax
  8010a3:	31 d2                	xor    %edx,%edx
  8010a5:	f7 f7                	div    %edi
  8010a7:	89 c5                	mov    %eax,%ebp
  8010a9:	89 f0                	mov    %esi,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f5                	div    %ebp
  8010af:	89 c8                	mov    %ecx,%eax
  8010b1:	f7 f5                	div    %ebp
  8010b3:	89 d0                	mov    %edx,%eax
  8010b5:	e9 44 ff ff ff       	jmp    800ffe <__umoddi3+0x3e>
  8010ba:	66 90                	xchg   %ax,%ax
  8010bc:	89 c8                	mov    %ecx,%eax
  8010be:	89 f2                	mov    %esi,%edx
  8010c0:	83 c4 1c             	add    $0x1c,%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    
  8010c8:	3b 04 24             	cmp    (%esp),%eax
  8010cb:	72 06                	jb     8010d3 <__umoddi3+0x113>
  8010cd:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  8010d1:	77 0f                	ja     8010e2 <__umoddi3+0x122>
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	29 f9                	sub    %edi,%ecx
  8010d7:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  8010db:	89 14 24             	mov    %edx,(%esp)
  8010de:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8010e2:	8b 44 24 04          	mov    0x4(%esp),%eax
  8010e6:	8b 14 24             	mov    (%esp),%edx
  8010e9:	83 c4 1c             	add    $0x1c,%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5f                   	pop    %edi
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    
  8010f1:	8d 76 00             	lea    0x0(%esi),%esi
  8010f4:	2b 04 24             	sub    (%esp),%eax
  8010f7:	19 fa                	sbb    %edi,%edx
  8010f9:	89 d1                	mov    %edx,%ecx
  8010fb:	89 c6                	mov    %eax,%esi
  8010fd:	e9 71 ff ff ff       	jmp    801073 <__umoddi3+0xb3>
  801102:	66 90                	xchg   %ax,%ax
  801104:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801108:	72 ea                	jb     8010f4 <__umoddi3+0x134>
  80110a:	89 d9                	mov    %ebx,%ecx
  80110c:	e9 62 ff ff ff       	jmp    801073 <__umoddi3+0xb3>
