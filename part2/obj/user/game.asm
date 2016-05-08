
obj/user/game:     file format elf32-i386


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
  800031:	e8 79 00 00 00       	call   8000af <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:
#include <inc/lib.h>
	
void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	83 ec 18             	sub    $0x18,%esp
	int i=28;
  80003e:	c7 45 f4 1c 00 00 00 	movl   $0x1c,-0xc(%ebp)
	for(;i<128; i++)
  800045:	eb 5f                	jmp    8000a6 <_main+0x6e>
	{
		int c=0;
  800047:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		for(;c<10; c++)
  80004e:	eb 16                	jmp    800066 <_main+0x2e>
		{
			cprintf("%c",i);
  800050:	83 ec 08             	sub    $0x8,%esp
  800053:	ff 75 f4             	pushl  -0xc(%ebp)
  800056:	68 80 11 80 00       	push   $0x801180
  80005b:	e8 67 01 00 00       	call   8001c7 <cprintf>
  800060:	83 c4 10             	add    $0x10,%esp
{	
	int i=28;
	for(;i<128; i++)
	{
		int c=0;
		for(;c<10; c++)
  800063:	ff 45 f0             	incl   -0x10(%ebp)
  800066:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  80006a:	7e e4                	jle    800050 <_main+0x18>
		{
			cprintf("%c",i);
		}
		int d=0;
  80006c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		for(; d< 500000; d++);	
  800073:	eb 03                	jmp    800078 <_main+0x40>
  800075:	ff 45 ec             	incl   -0x14(%ebp)
  800078:	81 7d ec 1f a1 07 00 	cmpl   $0x7a11f,-0x14(%ebp)
  80007f:	7e f4                	jle    800075 <_main+0x3d>
		c=0;
  800081:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		for(;c<10; c++)
  800088:	eb 13                	jmp    80009d <_main+0x65>
		{
			cprintf("\b");
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	68 83 11 80 00       	push   $0x801183
  800092:	e8 30 01 00 00       	call   8001c7 <cprintf>
  800097:	83 c4 10             	add    $0x10,%esp
			cprintf("%c",i);
		}
		int d=0;
		for(; d< 500000; d++);	
		c=0;
		for(;c<10; c++)
  80009a:	ff 45 f0             	incl   -0x10(%ebp)
  80009d:	83 7d f0 09          	cmpl   $0x9,-0x10(%ebp)
  8000a1:	7e e7                	jle    80008a <_main+0x52>
	
void
_main(void)
{	
	int i=28;
	for(;i<128; i++)
  8000a3:	ff 45 f4             	incl   -0xc(%ebp)
  8000a6:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
  8000aa:	7e 9b                	jle    800047 <_main+0xf>
		{
			cprintf("\b");
		}		
	}
	
	return;	
  8000ac:	90                   	nop
}
  8000ad:	c9                   	leave  
  8000ae:	c3                   	ret    

008000af <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000b5:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000bc:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bf:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000c3:	7e 0a                	jle    8000cf <libmain+0x20>
		binaryname = argv[0];
  8000c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000c8:	8b 00                	mov    (%eax),%eax
  8000ca:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000cf:	83 ec 08             	sub    $0x8,%esp
  8000d2:	ff 75 0c             	pushl  0xc(%ebp)
  8000d5:	ff 75 08             	pushl  0x8(%ebp)
  8000d8:	e8 5b ff ff ff       	call   800038 <_main>
  8000dd:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  8000e0:	e8 19 00 00 00       	call   8000fe <sleep>
}
  8000e5:	90                   	nop
  8000e6:	c9                   	leave  
  8000e7:	c3                   	ret    

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	6a 00                	push   $0x0
  8000f3:	e8 f5 0c 00 00       	call   800ded <sys_env_destroy>
  8000f8:	83 c4 10             	add    $0x10,%esp
}
  8000fb:	90                   	nop
  8000fc:	c9                   	leave  
  8000fd:	c3                   	ret    

008000fe <sleep>:

void
sleep(void)
{	
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800104:	e8 18 0d 00 00       	call   800e21 <sys_env_sleep>
}
  800109:	90                   	nop
  80010a:	c9                   	leave  
  80010b:	c3                   	ret    

0080010c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  800112:	8b 45 0c             	mov    0xc(%ebp),%eax
  800115:	8b 00                	mov    (%eax),%eax
  800117:	8d 48 01             	lea    0x1(%eax),%ecx
  80011a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011d:	89 0a                	mov    %ecx,(%edx)
  80011f:	8b 55 08             	mov    0x8(%ebp),%edx
  800122:	88 d1                	mov    %dl,%cl
  800124:	8b 55 0c             	mov    0xc(%ebp),%edx
  800127:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80012b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012e:	8b 00                	mov    (%eax),%eax
  800130:	3d ff 00 00 00       	cmp    $0xff,%eax
  800135:	75 23                	jne    80015a <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  800137:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013a:	8b 00                	mov    (%eax),%eax
  80013c:	89 c2                	mov    %eax,%edx
  80013e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800141:	83 c0 08             	add    $0x8,%eax
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	52                   	push   %edx
  800148:	50                   	push   %eax
  800149:	e8 69 0c 00 00       	call   800db7 <sys_cputs>
  80014e:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800151:	8b 45 0c             	mov    0xc(%ebp),%eax
  800154:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	8b 40 04             	mov    0x4(%eax),%eax
  800160:	8d 50 01             	lea    0x1(%eax),%edx
  800163:	8b 45 0c             	mov    0xc(%ebp),%eax
  800166:	89 50 04             	mov    %edx,0x4(%eax)
}
  800169:	90                   	nop
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800175:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017c:	00 00 00 
	b.cnt = 0;
  80017f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800186:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800189:	ff 75 0c             	pushl  0xc(%ebp)
  80018c:	ff 75 08             	pushl  0x8(%ebp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	50                   	push   %eax
  800196:	68 0c 01 80 00       	push   $0x80010c
  80019b:	e8 ca 01 00 00       	call   80036a <vprintfmt>
  8001a0:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  8001a3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	50                   	push   %eax
  8001ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b3:	83 c0 08             	add    $0x8,%eax
  8001b6:	50                   	push   %eax
  8001b7:	e8 fb 0b 00 00       	call   800db7 <sys_cputs>
  8001bc:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  8001bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001c5:	c9                   	leave  
  8001c6:	c3                   	ret    

008001c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001cd:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8001d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d6:	83 ec 08             	sub    $0x8,%esp
  8001d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8001dc:	50                   	push   %eax
  8001dd:	e8 8a ff ff ff       	call   80016c <vcprintf>
  8001e2:	83 c4 10             	add    $0x10,%esp
  8001e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8001e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8001eb:	c9                   	leave  
  8001ec:	c3                   	ret    

008001ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 14             	sub    $0x14,%esp
  8001f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800200:	8b 45 18             	mov    0x18(%ebp),%eax
  800203:	ba 00 00 00 00       	mov    $0x0,%edx
  800208:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80020b:	77 55                	ja     800262 <printnum+0x75>
  80020d:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800210:	72 05                	jb     800217 <printnum+0x2a>
  800212:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800215:	77 4b                	ja     800262 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800217:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80021a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80021d:	8b 45 18             	mov    0x18(%ebp),%eax
  800220:	ba 00 00 00 00       	mov    $0x0,%edx
  800225:	52                   	push   %edx
  800226:	50                   	push   %eax
  800227:	ff 75 f4             	pushl  -0xc(%ebp)
  80022a:	ff 75 f0             	pushl  -0x10(%ebp)
  80022d:	e8 de 0c 00 00       	call   800f10 <__udivdi3>
  800232:	83 c4 10             	add    $0x10,%esp
  800235:	83 ec 04             	sub    $0x4,%esp
  800238:	ff 75 20             	pushl  0x20(%ebp)
  80023b:	53                   	push   %ebx
  80023c:	ff 75 18             	pushl  0x18(%ebp)
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	ff 75 0c             	pushl  0xc(%ebp)
  800244:	ff 75 08             	pushl  0x8(%ebp)
  800247:	e8 a1 ff ff ff       	call   8001ed <printnum>
  80024c:	83 c4 20             	add    $0x20,%esp
  80024f:	eb 1a                	jmp    80026b <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 20             	pushl  0x20(%ebp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	ff d0                	call   *%eax
  80025f:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800262:	ff 4d 1c             	decl   0x1c(%ebp)
  800265:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800269:	7f e6                	jg     800251 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80026b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800279:	53                   	push   %ebx
  80027a:	51                   	push   %ecx
  80027b:	52                   	push   %edx
  80027c:	50                   	push   %eax
  80027d:	e8 9e 0d 00 00       	call   801020 <__umoddi3>
  800282:	83 c4 10             	add    $0x10,%esp
  800285:	05 40 12 80 00       	add    $0x801240,%eax
  80028a:	8a 00                	mov    (%eax),%al
  80028c:	0f be c0             	movsbl %al,%eax
  80028f:	83 ec 08             	sub    $0x8,%esp
  800292:	ff 75 0c             	pushl  0xc(%ebp)
  800295:	50                   	push   %eax
  800296:	8b 45 08             	mov    0x8(%ebp),%eax
  800299:	ff d0                	call   *%eax
  80029b:	83 c4 10             	add    $0x10,%esp
}
  80029e:	90                   	nop
  80029f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002a2:	c9                   	leave  
  8002a3:	c3                   	ret    

008002a4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002a7:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002ab:	7e 1c                	jle    8002c9 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 00                	mov    (%eax),%eax
  8002b2:	8d 50 08             	lea    0x8(%eax),%edx
  8002b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b8:	89 10                	mov    %edx,(%eax)
  8002ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bd:	8b 00                	mov    (%eax),%eax
  8002bf:	83 e8 08             	sub    $0x8,%eax
  8002c2:	8b 50 04             	mov    0x4(%eax),%edx
  8002c5:	8b 00                	mov    (%eax),%eax
  8002c7:	eb 40                	jmp    800309 <getuint+0x65>
	else if (lflag)
  8002c9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002cd:	74 1e                	je     8002ed <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8002cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d2:	8b 00                	mov    (%eax),%eax
  8002d4:	8d 50 04             	lea    0x4(%eax),%edx
  8002d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002da:	89 10                	mov    %edx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	8b 00                	mov    (%eax),%eax
  8002e1:	83 e8 04             	sub    $0x4,%eax
  8002e4:	8b 00                	mov    (%eax),%eax
  8002e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8002eb:	eb 1c                	jmp    800309 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8002ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f0:	8b 00                	mov    (%eax),%eax
  8002f2:	8d 50 04             	lea    0x4(%eax),%edx
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 10                	mov    %edx,(%eax)
  8002fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fd:	8b 00                	mov    (%eax),%eax
  8002ff:	83 e8 04             	sub    $0x4,%eax
  800302:	8b 00                	mov    (%eax),%eax
  800304:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80030e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800312:	7e 1c                	jle    800330 <getint+0x25>
		return va_arg(*ap, long long);
  800314:	8b 45 08             	mov    0x8(%ebp),%eax
  800317:	8b 00                	mov    (%eax),%eax
  800319:	8d 50 08             	lea    0x8(%eax),%edx
  80031c:	8b 45 08             	mov    0x8(%ebp),%eax
  80031f:	89 10                	mov    %edx,(%eax)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	8b 00                	mov    (%eax),%eax
  800326:	83 e8 08             	sub    $0x8,%eax
  800329:	8b 50 04             	mov    0x4(%eax),%edx
  80032c:	8b 00                	mov    (%eax),%eax
  80032e:	eb 38                	jmp    800368 <getint+0x5d>
	else if (lflag)
  800330:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800334:	74 1a                	je     800350 <getint+0x45>
		return va_arg(*ap, long);
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	8d 50 04             	lea    0x4(%eax),%edx
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	89 10                	mov    %edx,(%eax)
  800343:	8b 45 08             	mov    0x8(%ebp),%eax
  800346:	8b 00                	mov    (%eax),%eax
  800348:	83 e8 04             	sub    $0x4,%eax
  80034b:	8b 00                	mov    (%eax),%eax
  80034d:	99                   	cltd   
  80034e:	eb 18                	jmp    800368 <getint+0x5d>
	else
		return va_arg(*ap, int);
  800350:	8b 45 08             	mov    0x8(%ebp),%eax
  800353:	8b 00                	mov    (%eax),%eax
  800355:	8d 50 04             	lea    0x4(%eax),%edx
  800358:	8b 45 08             	mov    0x8(%ebp),%eax
  80035b:	89 10                	mov    %edx,(%eax)
  80035d:	8b 45 08             	mov    0x8(%ebp),%eax
  800360:	8b 00                	mov    (%eax),%eax
  800362:	83 e8 04             	sub    $0x4,%eax
  800365:	8b 00                	mov    (%eax),%eax
  800367:	99                   	cltd   
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
  80036f:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	eb 17                	jmp    80038b <vprintfmt+0x21>
			if (ch == '\0')
  800374:	85 db                	test   %ebx,%ebx
  800376:	0f 84 af 03 00 00    	je     80072b <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  80037c:	83 ec 08             	sub    $0x8,%esp
  80037f:	ff 75 0c             	pushl  0xc(%ebp)
  800382:	53                   	push   %ebx
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
  800386:	ff d0                	call   *%eax
  800388:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	8b 45 10             	mov    0x10(%ebp),%eax
  80038e:	8d 50 01             	lea    0x1(%eax),%edx
  800391:	89 55 10             	mov    %edx,0x10(%ebp)
  800394:	8a 00                	mov    (%eax),%al
  800396:	0f b6 d8             	movzbl %al,%ebx
  800399:	83 fb 25             	cmp    $0x25,%ebx
  80039c:	75 d6                	jne    800374 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80039e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003a2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003b0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003b7:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c1:	8d 50 01             	lea    0x1(%eax),%edx
  8003c4:	89 55 10             	mov    %edx,0x10(%ebp)
  8003c7:	8a 00                	mov    (%eax),%al
  8003c9:	0f b6 d8             	movzbl %al,%ebx
  8003cc:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003cf:	83 f8 55             	cmp    $0x55,%eax
  8003d2:	0f 87 2b 03 00 00    	ja     800703 <vprintfmt+0x399>
  8003d8:	8b 04 85 64 12 80 00 	mov    0x801264(,%eax,4),%eax
  8003df:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e1:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003e5:	eb d7                	jmp    8003be <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e7:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003eb:	eb d1                	jmp    8003be <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003f4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f7:	89 d0                	mov    %edx,%eax
  8003f9:	c1 e0 02             	shl    $0x2,%eax
  8003fc:	01 d0                	add    %edx,%eax
  8003fe:	01 c0                	add    %eax,%eax
  800400:	01 d8                	add    %ebx,%eax
  800402:	83 e8 30             	sub    $0x30,%eax
  800405:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800408:	8b 45 10             	mov    0x10(%ebp),%eax
  80040b:	8a 00                	mov    (%eax),%al
  80040d:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800410:	83 fb 2f             	cmp    $0x2f,%ebx
  800413:	7e 3e                	jle    800453 <vprintfmt+0xe9>
  800415:	83 fb 39             	cmp    $0x39,%ebx
  800418:	7f 39                	jg     800453 <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041a:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80041d:	eb d5                	jmp    8003f4 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	83 c0 04             	add    $0x4,%eax
  800425:	89 45 14             	mov    %eax,0x14(%ebp)
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	83 e8 04             	sub    $0x4,%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  800433:	eb 1f                	jmp    800454 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800435:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800439:	79 83                	jns    8003be <vprintfmt+0x54>
				width = 0;
  80043b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800442:	e9 77 ff ff ff       	jmp    8003be <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800447:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80044e:	e9 6b ff ff ff       	jmp    8003be <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  800453:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800454:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800458:	0f 89 60 ff ff ff    	jns    8003be <vprintfmt+0x54>
				width = precision, precision = -1;
  80045e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800461:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800464:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80046b:	e9 4e ff ff ff       	jmp    8003be <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800470:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  800473:	e9 46 ff ff ff       	jmp    8003be <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800478:	8b 45 14             	mov    0x14(%ebp),%eax
  80047b:	83 c0 04             	add    $0x4,%eax
  80047e:	89 45 14             	mov    %eax,0x14(%ebp)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	83 e8 04             	sub    $0x4,%eax
  800487:	8b 00                	mov    (%eax),%eax
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	ff 75 0c             	pushl  0xc(%ebp)
  80048f:	50                   	push   %eax
  800490:	8b 45 08             	mov    0x8(%ebp),%eax
  800493:	ff d0                	call   *%eax
  800495:	83 c4 10             	add    $0x10,%esp
			break;
  800498:	e9 89 02 00 00       	jmp    800726 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	83 c0 04             	add    $0x4,%eax
  8004a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	83 e8 04             	sub    $0x4,%eax
  8004ac:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004ae:	85 db                	test   %ebx,%ebx
  8004b0:	79 02                	jns    8004b4 <vprintfmt+0x14a>
				err = -err;
  8004b2:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004b4:	83 fb 07             	cmp    $0x7,%ebx
  8004b7:	7f 0b                	jg     8004c4 <vprintfmt+0x15a>
  8004b9:	8b 34 9d 20 12 80 00 	mov    0x801220(,%ebx,4),%esi
  8004c0:	85 f6                	test   %esi,%esi
  8004c2:	75 19                	jne    8004dd <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8004c4:	53                   	push   %ebx
  8004c5:	68 51 12 80 00       	push   $0x801251
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	ff 75 08             	pushl  0x8(%ebp)
  8004d0:	e8 5e 02 00 00       	call   800733 <printfmt>
  8004d5:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004d8:	e9 49 02 00 00       	jmp    800726 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004dd:	56                   	push   %esi
  8004de:	68 5a 12 80 00       	push   $0x80125a
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	ff 75 08             	pushl  0x8(%ebp)
  8004e9:	e8 45 02 00 00       	call   800733 <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
			break;
  8004f1:	e9 30 02 00 00       	jmp    800726 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	83 c0 04             	add    $0x4,%eax
  8004fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	83 e8 04             	sub    $0x4,%eax
  800505:	8b 30                	mov    (%eax),%esi
  800507:	85 f6                	test   %esi,%esi
  800509:	75 05                	jne    800510 <vprintfmt+0x1a6>
				p = "(null)";
  80050b:	be 5d 12 80 00       	mov    $0x80125d,%esi
			if (width > 0 && padc != '-')
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	7e 6d                	jle    800583 <vprintfmt+0x219>
  800516:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80051a:	74 67                	je     800583 <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	50                   	push   %eax
  800523:	56                   	push   %esi
  800524:	e8 0c 03 00 00       	call   800835 <strnlen>
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80052f:	eb 16                	jmp    800547 <vprintfmt+0x1dd>
					putch(padc, putdat);
  800531:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	ff 75 0c             	pushl  0xc(%ebp)
  80053b:	50                   	push   %eax
  80053c:	8b 45 08             	mov    0x8(%ebp),%eax
  80053f:	ff d0                	call   *%eax
  800541:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	ff 4d e4             	decl   -0x1c(%ebp)
  800547:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80054b:	7f e4                	jg     800531 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054d:	eb 34                	jmp    800583 <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80054f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800553:	74 1c                	je     800571 <vprintfmt+0x207>
  800555:	83 fb 1f             	cmp    $0x1f,%ebx
  800558:	7e 05                	jle    80055f <vprintfmt+0x1f5>
  80055a:	83 fb 7e             	cmp    $0x7e,%ebx
  80055d:	7e 12                	jle    800571 <vprintfmt+0x207>
					putch('?', putdat);
  80055f:	83 ec 08             	sub    $0x8,%esp
  800562:	ff 75 0c             	pushl  0xc(%ebp)
  800565:	6a 3f                	push   $0x3f
  800567:	8b 45 08             	mov    0x8(%ebp),%eax
  80056a:	ff d0                	call   *%eax
  80056c:	83 c4 10             	add    $0x10,%esp
  80056f:	eb 0f                	jmp    800580 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 0c             	pushl  0xc(%ebp)
  800577:	53                   	push   %ebx
  800578:	8b 45 08             	mov    0x8(%ebp),%eax
  80057b:	ff d0                	call   *%eax
  80057d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800580:	ff 4d e4             	decl   -0x1c(%ebp)
  800583:	89 f0                	mov    %esi,%eax
  800585:	8d 70 01             	lea    0x1(%eax),%esi
  800588:	8a 00                	mov    (%eax),%al
  80058a:	0f be d8             	movsbl %al,%ebx
  80058d:	85 db                	test   %ebx,%ebx
  80058f:	74 24                	je     8005b5 <vprintfmt+0x24b>
  800591:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800595:	78 b8                	js     80054f <vprintfmt+0x1e5>
  800597:	ff 4d e0             	decl   -0x20(%ebp)
  80059a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059e:	79 af                	jns    80054f <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a0:	eb 13                	jmp    8005b5 <vprintfmt+0x24b>
				putch(' ', putdat);
  8005a2:	83 ec 08             	sub    $0x8,%esp
  8005a5:	ff 75 0c             	pushl  0xc(%ebp)
  8005a8:	6a 20                	push   $0x20
  8005aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ad:	ff d0                	call   *%eax
  8005af:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005b2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005b9:	7f e7                	jg     8005a2 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8005bb:	e9 66 01 00 00       	jmp    800726 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	ff 75 e8             	pushl  -0x18(%ebp)
  8005c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c9:	50                   	push   %eax
  8005ca:	e8 3c fd ff ff       	call   80030b <getint>
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005db:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	79 23                	jns    800605 <vprintfmt+0x29b>
				putch('-', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	ff 75 0c             	pushl  0xc(%ebp)
  8005e8:	6a 2d                	push   $0x2d
  8005ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ed:	ff d0                	call   *%eax
  8005ef:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8005f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005f8:	f7 d8                	neg    %eax
  8005fa:	83 d2 00             	adc    $0x0,%edx
  8005fd:	f7 da                	neg    %edx
  8005ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800602:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800605:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80060c:	e9 bc 00 00 00       	jmp    8006cd <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 e8             	pushl  -0x18(%ebp)
  800617:	8d 45 14             	lea    0x14(%ebp),%eax
  80061a:	50                   	push   %eax
  80061b:	e8 84 fc ff ff       	call   8002a4 <getuint>
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800626:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800629:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800630:	e9 98 00 00 00       	jmp    8006cd <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	ff 75 0c             	pushl  0xc(%ebp)
  80063b:	6a 58                	push   $0x58
  80063d:	8b 45 08             	mov    0x8(%ebp),%eax
  800640:	ff d0                	call   *%eax
  800642:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	ff 75 0c             	pushl  0xc(%ebp)
  80064b:	6a 58                	push   $0x58
  80064d:	8b 45 08             	mov    0x8(%ebp),%eax
  800650:	ff d0                	call   *%eax
  800652:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	6a 58                	push   $0x58
  80065d:	8b 45 08             	mov    0x8(%ebp),%eax
  800660:	ff d0                	call   *%eax
  800662:	83 c4 10             	add    $0x10,%esp
			break;
  800665:	e9 bc 00 00 00       	jmp    800726 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	ff 75 0c             	pushl  0xc(%ebp)
  800670:	6a 30                	push   $0x30
  800672:	8b 45 08             	mov    0x8(%ebp),%eax
  800675:	ff d0                	call   *%eax
  800677:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	ff 75 0c             	pushl  0xc(%ebp)
  800680:	6a 78                	push   $0x78
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	ff d0                	call   *%eax
  800687:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	83 c0 04             	add    $0x4,%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	83 e8 04             	sub    $0x4,%eax
  800699:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80069e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8006a5:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006ac:	eb 1f                	jmp    8006cd <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	ff 75 e8             	pushl  -0x18(%ebp)
  8006b4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b7:	50                   	push   %eax
  8006b8:	e8 e7 fb ff ff       	call   8002a4 <getuint>
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006c3:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006c6:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006cd:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006d4:	83 ec 04             	sub    $0x4,%esp
  8006d7:	52                   	push   %edx
  8006d8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006db:	50                   	push   %eax
  8006dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8006df:	ff 75 f0             	pushl  -0x10(%ebp)
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	ff 75 08             	pushl  0x8(%ebp)
  8006e8:	e8 00 fb ff ff       	call   8001ed <printnum>
  8006ed:	83 c4 20             	add    $0x20,%esp
			break;
  8006f0:	eb 34                	jmp    800726 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	ff 75 0c             	pushl  0xc(%ebp)
  8006f8:	53                   	push   %ebx
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	ff d0                	call   *%eax
  8006fe:	83 c4 10             	add    $0x10,%esp
			break;
  800701:	eb 23                	jmp    800726 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800703:	83 ec 08             	sub    $0x8,%esp
  800706:	ff 75 0c             	pushl  0xc(%ebp)
  800709:	6a 25                	push   $0x25
  80070b:	8b 45 08             	mov    0x8(%ebp),%eax
  80070e:	ff d0                	call   *%eax
  800710:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  800713:	ff 4d 10             	decl   0x10(%ebp)
  800716:	eb 03                	jmp    80071b <vprintfmt+0x3b1>
  800718:	ff 4d 10             	decl   0x10(%ebp)
  80071b:	8b 45 10             	mov    0x10(%ebp),%eax
  80071e:	48                   	dec    %eax
  80071f:	8a 00                	mov    (%eax),%al
  800721:	3c 25                	cmp    $0x25,%al
  800723:	75 f3                	jne    800718 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800725:	90                   	nop
		}
	}
  800726:	e9 47 fc ff ff       	jmp    800372 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  80072b:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  80072c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80072f:	5b                   	pop    %ebx
  800730:	5e                   	pop    %esi
  800731:	5d                   	pop    %ebp
  800732:	c3                   	ret    

00800733 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800739:	8d 45 10             	lea    0x10(%ebp),%eax
  80073c:	83 c0 04             	add    $0x4,%eax
  80073f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800742:	8b 45 10             	mov    0x10(%ebp),%eax
  800745:	ff 75 f4             	pushl  -0xc(%ebp)
  800748:	50                   	push   %eax
  800749:	ff 75 0c             	pushl  0xc(%ebp)
  80074c:	ff 75 08             	pushl  0x8(%ebp)
  80074f:	e8 16 fc ff ff       	call   80036a <vprintfmt>
  800754:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800757:	90                   	nop
  800758:	c9                   	leave  
  800759:	c3                   	ret    

0080075a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  80075d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800760:	8b 40 08             	mov    0x8(%eax),%eax
  800763:	8d 50 01             	lea    0x1(%eax),%edx
  800766:	8b 45 0c             	mov    0xc(%ebp),%eax
  800769:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  80076c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	8b 40 04             	mov    0x4(%eax),%eax
  800777:	39 c2                	cmp    %eax,%edx
  800779:	73 12                	jae    80078d <sprintputch+0x33>
		*b->buf++ = ch;
  80077b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	8d 48 01             	lea    0x1(%eax),%ecx
  800783:	8b 55 0c             	mov    0xc(%ebp),%edx
  800786:	89 0a                	mov    %ecx,(%edx)
  800788:	8b 55 08             	mov    0x8(%ebp),%edx
  80078b:	88 10                	mov    %dl,(%eax)
}
  80078d:	90                   	nop
  80078e:	5d                   	pop    %ebp
  80078f:	c3                   	ret    

00800790 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800796:	8b 45 08             	mov    0x8(%ebp),%eax
  800799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079f:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a5:	01 d0                	add    %edx,%eax
  8007a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007b5:	74 06                	je     8007bd <vsnprintf+0x2d>
  8007b7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007bb:	7f 07                	jg     8007c4 <vsnprintf+0x34>
		return -E_INVAL;
  8007bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8007c2:	eb 20                	jmp    8007e4 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c4:	ff 75 14             	pushl  0x14(%ebp)
  8007c7:	ff 75 10             	pushl  0x10(%ebp)
  8007ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007cd:	50                   	push   %eax
  8007ce:	68 5a 07 80 00       	push   $0x80075a
  8007d3:	e8 92 fb ff ff       	call   80036a <vprintfmt>
  8007d8:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8007db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007de:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007e4:	c9                   	leave  
  8007e5:	c3                   	ret    

008007e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ec:	8d 45 10             	lea    0x10(%ebp),%eax
  8007ef:	83 c0 04             	add    $0x4,%eax
  8007f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 0c             	pushl  0xc(%ebp)
  8007ff:	ff 75 08             	pushl  0x8(%ebp)
  800802:	e8 89 ff ff ff       	call   800790 <vsnprintf>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800818:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80081f:	eb 06                	jmp    800827 <strlen+0x15>
		n++;
  800821:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800824:	ff 45 08             	incl   0x8(%ebp)
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8a 00                	mov    (%eax),%al
  80082c:	84 c0                	test   %al,%al
  80082e:	75 f1                	jne    800821 <strlen+0xf>
		n++;
	return n;
  800830:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800833:	c9                   	leave  
  800834:	c3                   	ret    

00800835 <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80083b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800842:	eb 09                	jmp    80084d <strnlen+0x18>
		n++;
  800844:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800847:	ff 45 08             	incl   0x8(%ebp)
  80084a:	ff 4d 0c             	decl   0xc(%ebp)
  80084d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800851:	74 09                	je     80085c <strnlen+0x27>
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	8a 00                	mov    (%eax),%al
  800858:	84 c0                	test   %al,%al
  80085a:	75 e8                	jne    800844 <strnlen+0xf>
		n++;
	return n;
  80085c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  80086d:	90                   	nop
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8d 50 01             	lea    0x1(%eax),%edx
  800874:	89 55 08             	mov    %edx,0x8(%ebp)
  800877:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80087d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800880:	8a 12                	mov    (%edx),%dl
  800882:	88 10                	mov    %dl,(%eax)
  800884:	8a 00                	mov    (%eax),%al
  800886:	84 c0                	test   %al,%al
  800888:	75 e4                	jne    80086e <strcpy+0xd>
		/* do nothing */;
	return ret;
  80088a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80088d:	c9                   	leave  
  80088e:	c3                   	ret    

0080088f <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  80089b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8008a2:	eb 1f                	jmp    8008c3 <strncpy+0x34>
		*dst++ = *src;
  8008a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a7:	8d 50 01             	lea    0x1(%eax),%edx
  8008aa:	89 55 08             	mov    %edx,0x8(%ebp)
  8008ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b0:	8a 12                	mov    (%edx),%dl
  8008b2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8008b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b7:	8a 00                	mov    (%eax),%al
  8008b9:	84 c0                	test   %al,%al
  8008bb:	74 03                	je     8008c0 <strncpy+0x31>
			src++;
  8008bd:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c0:	ff 45 fc             	incl   -0x4(%ebp)
  8008c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008c6:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008c9:	72 d9                	jb     8008a4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008dc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008e0:	74 30                	je     800912 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8008e2:	eb 16                	jmp    8008fa <strlcpy+0x2a>
			*dst++ = *src++;
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	8d 50 01             	lea    0x1(%eax),%edx
  8008ea:	89 55 08             	mov    %edx,0x8(%ebp)
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008f3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008f6:	8a 12                	mov    (%edx),%dl
  8008f8:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008fa:	ff 4d 10             	decl   0x10(%ebp)
  8008fd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800901:	74 09                	je     80090c <strlcpy+0x3c>
  800903:	8b 45 0c             	mov    0xc(%ebp),%eax
  800906:	8a 00                	mov    (%eax),%al
  800908:	84 c0                	test   %al,%al
  80090a:	75 d8                	jne    8008e4 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800912:	8b 55 08             	mov    0x8(%ebp),%edx
  800915:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800918:	29 c2                	sub    %eax,%edx
  80091a:	89 d0                	mov    %edx,%eax
}
  80091c:	c9                   	leave  
  80091d:	c3                   	ret    

0080091e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800921:	eb 06                	jmp    800929 <strcmp+0xb>
		p++, q++;
  800923:	ff 45 08             	incl   0x8(%ebp)
  800926:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8a 00                	mov    (%eax),%al
  80092e:	84 c0                	test   %al,%al
  800930:	74 0e                	je     800940 <strcmp+0x22>
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8a 10                	mov    (%eax),%dl
  800937:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093a:	8a 00                	mov    (%eax),%al
  80093c:	38 c2                	cmp    %al,%dl
  80093e:	74 e3                	je     800923 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8a 00                	mov    (%eax),%al
  800945:	0f b6 d0             	movzbl %al,%edx
  800948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80094b:	8a 00                	mov    (%eax),%al
  80094d:	0f b6 c0             	movzbl %al,%eax
  800950:	29 c2                	sub    %eax,%edx
  800952:	89 d0                	mov    %edx,%eax
}
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800959:	eb 09                	jmp    800964 <strncmp+0xe>
		n--, p++, q++;
  80095b:	ff 4d 10             	decl   0x10(%ebp)
  80095e:	ff 45 08             	incl   0x8(%ebp)
  800961:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800964:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800968:	74 17                	je     800981 <strncmp+0x2b>
  80096a:	8b 45 08             	mov    0x8(%ebp),%eax
  80096d:	8a 00                	mov    (%eax),%al
  80096f:	84 c0                	test   %al,%al
  800971:	74 0e                	je     800981 <strncmp+0x2b>
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	8a 10                	mov    (%eax),%dl
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	8a 00                	mov    (%eax),%al
  80097d:	38 c2                	cmp    %al,%dl
  80097f:	74 da                	je     80095b <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800981:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800985:	75 07                	jne    80098e <strncmp+0x38>
		return 0;
  800987:	b8 00 00 00 00       	mov    $0x0,%eax
  80098c:	eb 14                	jmp    8009a2 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8a 00                	mov    (%eax),%al
  800993:	0f b6 d0             	movzbl %al,%edx
  800996:	8b 45 0c             	mov    0xc(%ebp),%eax
  800999:	8a 00                	mov    (%eax),%al
  80099b:	0f b6 c0             	movzbl %al,%eax
  80099e:	29 c2                	sub    %eax,%edx
  8009a0:	89 d0                	mov    %edx,%eax
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	83 ec 04             	sub    $0x4,%esp
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009b0:	eb 12                	jmp    8009c4 <strchr+0x20>
		if (*s == c)
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8a 00                	mov    (%eax),%al
  8009b7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009ba:	75 05                	jne    8009c1 <strchr+0x1d>
			return (char *) s;
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	eb 11                	jmp    8009d2 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c1:	ff 45 08             	incl   0x8(%ebp)
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8a 00                	mov    (%eax),%al
  8009c9:	84 c0                	test   %al,%al
  8009cb:	75 e5                	jne    8009b2 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 04             	sub    $0x4,%esp
  8009da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dd:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009e0:	eb 0d                	jmp    8009ef <strfind+0x1b>
		if (*s == c)
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e5:	8a 00                	mov    (%eax),%al
  8009e7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009ea:	74 0e                	je     8009fa <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ec:	ff 45 08             	incl   0x8(%ebp)
  8009ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f2:	8a 00                	mov    (%eax),%al
  8009f4:	84 c0                	test   %al,%al
  8009f6:	75 ea                	jne    8009e2 <strfind+0xe>
  8009f8:	eb 01                	jmp    8009fb <strfind+0x27>
		if (*s == c)
			break;
  8009fa:	90                   	nop
	return (char *) s;
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a0f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800a12:	eb 0e                	jmp    800a22 <memset+0x22>
		*p++ = c;
  800a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a17:	8d 50 01             	lea    0x1(%eax),%edx
  800a1a:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800a1d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a20:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a22:	ff 4d f8             	decl   -0x8(%ebp)
  800a25:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800a29:	79 e9                	jns    800a14 <memset+0x14>
		*p++ = c;

	return v;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a39:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800a42:	eb 16                	jmp    800a5a <memcpy+0x2a>
		*d++ = *s++;
  800a44:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a47:	8d 50 01             	lea    0x1(%eax),%edx
  800a4a:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800a4d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a50:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a53:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800a56:	8a 12                	mov    (%edx),%dl
  800a58:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a60:	89 55 10             	mov    %edx,0x10(%ebp)
  800a63:	85 c0                	test   %eax,%eax
  800a65:	75 dd                	jne    800a44 <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800a67:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800a7e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a81:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a84:	73 50                	jae    800ad6 <memmove+0x6a>
  800a86:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a89:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8c:	01 d0                	add    %edx,%eax
  800a8e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a91:	76 43                	jbe    800ad6 <memmove+0x6a>
		s += n;
  800a93:	8b 45 10             	mov    0x10(%ebp),%eax
  800a96:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800a99:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9c:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800a9f:	eb 10                	jmp    800ab1 <memmove+0x45>
			*--d = *--s;
  800aa1:	ff 4d f8             	decl   -0x8(%ebp)
  800aa4:	ff 4d fc             	decl   -0x4(%ebp)
  800aa7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aaa:	8a 10                	mov    (%eax),%dl
  800aac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800aaf:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800ab1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ab4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ab7:	89 55 10             	mov    %edx,0x10(%ebp)
  800aba:	85 c0                	test   %eax,%eax
  800abc:	75 e3                	jne    800aa1 <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800abe:	eb 23                	jmp    800ae3 <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800ac0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ac3:	8d 50 01             	lea    0x1(%eax),%edx
  800ac6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800ac9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800acc:	8d 4a 01             	lea    0x1(%edx),%ecx
  800acf:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800ad2:	8a 12                	mov    (%edx),%dl
  800ad4:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800adc:	89 55 10             	mov    %edx,0x10(%ebp)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	75 dd                	jne    800ac0 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800ae3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ae6:	c9                   	leave  
  800ae7:	c3                   	ret    

00800ae8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800afa:	eb 2a                	jmp    800b26 <memcmp+0x3e>
		if (*s1 != *s2)
  800afc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800aff:	8a 10                	mov    (%eax),%dl
  800b01:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b04:	8a 00                	mov    (%eax),%al
  800b06:	38 c2                	cmp    %al,%dl
  800b08:	74 16                	je     800b20 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800b0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b0d:	8a 00                	mov    (%eax),%al
  800b0f:	0f b6 d0             	movzbl %al,%edx
  800b12:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b15:	8a 00                	mov    (%eax),%al
  800b17:	0f b6 c0             	movzbl %al,%eax
  800b1a:	29 c2                	sub    %eax,%edx
  800b1c:	89 d0                	mov    %edx,%eax
  800b1e:	eb 18                	jmp    800b38 <memcmp+0x50>
		s1++, s2++;
  800b20:	ff 45 fc             	incl   -0x4(%ebp)
  800b23:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b2c:	89 55 10             	mov    %edx,0x10(%ebp)
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	75 c9                	jne    800afc <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	8b 45 10             	mov    0x10(%ebp),%eax
  800b46:	01 d0                	add    %edx,%eax
  800b48:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800b4b:	eb 15                	jmp    800b62 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8a 00                	mov    (%eax),%al
  800b52:	0f b6 d0             	movzbl %al,%edx
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	0f b6 c0             	movzbl %al,%eax
  800b5b:	39 c2                	cmp    %eax,%edx
  800b5d:	74 0d                	je     800b6c <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b5f:	ff 45 08             	incl   0x8(%ebp)
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
  800b65:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800b68:	72 e3                	jb     800b4d <memfind+0x13>
  800b6a:	eb 01                	jmp    800b6d <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800b6c:	90                   	nop
	return (void *) s;
  800b6d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800b78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800b7f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b86:	eb 03                	jmp    800b8b <strtol+0x19>
		s++;
  800b88:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8a 00                	mov    (%eax),%al
  800b90:	3c 20                	cmp    $0x20,%al
  800b92:	74 f4                	je     800b88 <strtol+0x16>
  800b94:	8b 45 08             	mov    0x8(%ebp),%eax
  800b97:	8a 00                	mov    (%eax),%al
  800b99:	3c 09                	cmp    $0x9,%al
  800b9b:	74 eb                	je     800b88 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8a 00                	mov    (%eax),%al
  800ba2:	3c 2b                	cmp    $0x2b,%al
  800ba4:	75 05                	jne    800bab <strtol+0x39>
		s++;
  800ba6:	ff 45 08             	incl   0x8(%ebp)
  800ba9:	eb 13                	jmp    800bbe <strtol+0x4c>
	else if (*s == '-')
  800bab:	8b 45 08             	mov    0x8(%ebp),%eax
  800bae:	8a 00                	mov    (%eax),%al
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	75 0a                	jne    800bbe <strtol+0x4c>
		s++, neg = 1;
  800bb4:	ff 45 08             	incl   0x8(%ebp)
  800bb7:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bc2:	74 06                	je     800bca <strtol+0x58>
  800bc4:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800bc8:	75 20                	jne    800bea <strtol+0x78>
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8a 00                	mov    (%eax),%al
  800bcf:	3c 30                	cmp    $0x30,%al
  800bd1:	75 17                	jne    800bea <strtol+0x78>
  800bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd6:	40                   	inc    %eax
  800bd7:	8a 00                	mov    (%eax),%al
  800bd9:	3c 78                	cmp    $0x78,%al
  800bdb:	75 0d                	jne    800bea <strtol+0x78>
		s += 2, base = 16;
  800bdd:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800be1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800be8:	eb 28                	jmp    800c12 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800bea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bee:	75 15                	jne    800c05 <strtol+0x93>
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8a 00                	mov    (%eax),%al
  800bf5:	3c 30                	cmp    $0x30,%al
  800bf7:	75 0c                	jne    800c05 <strtol+0x93>
		s++, base = 8;
  800bf9:	ff 45 08             	incl   0x8(%ebp)
  800bfc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800c03:	eb 0d                	jmp    800c12 <strtol+0xa0>
	else if (base == 0)
  800c05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800c09:	75 07                	jne    800c12 <strtol+0xa0>
		base = 10;
  800c0b:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8a 00                	mov    (%eax),%al
  800c17:	3c 2f                	cmp    $0x2f,%al
  800c19:	7e 19                	jle    800c34 <strtol+0xc2>
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8a 00                	mov    (%eax),%al
  800c20:	3c 39                	cmp    $0x39,%al
  800c22:	7f 10                	jg     800c34 <strtol+0xc2>
			dig = *s - '0';
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	8a 00                	mov    (%eax),%al
  800c29:	0f be c0             	movsbl %al,%eax
  800c2c:	83 e8 30             	sub    $0x30,%eax
  800c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c32:	eb 42                	jmp    800c76 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8a 00                	mov    (%eax),%al
  800c39:	3c 60                	cmp    $0x60,%al
  800c3b:	7e 19                	jle    800c56 <strtol+0xe4>
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	8a 00                	mov    (%eax),%al
  800c42:	3c 7a                	cmp    $0x7a,%al
  800c44:	7f 10                	jg     800c56 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	8a 00                	mov    (%eax),%al
  800c4b:	0f be c0             	movsbl %al,%eax
  800c4e:	83 e8 57             	sub    $0x57,%eax
  800c51:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c54:	eb 20                	jmp    800c76 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800c56:	8b 45 08             	mov    0x8(%ebp),%eax
  800c59:	8a 00                	mov    (%eax),%al
  800c5b:	3c 40                	cmp    $0x40,%al
  800c5d:	7e 39                	jle    800c98 <strtol+0x126>
  800c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c62:	8a 00                	mov    (%eax),%al
  800c64:	3c 5a                	cmp    $0x5a,%al
  800c66:	7f 30                	jg     800c98 <strtol+0x126>
			dig = *s - 'A' + 10;
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6b:	8a 00                	mov    (%eax),%al
  800c6d:	0f be c0             	movsbl %al,%eax
  800c70:	83 e8 37             	sub    $0x37,%eax
  800c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c79:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c7c:	7d 19                	jge    800c97 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800c7e:	ff 45 08             	incl   0x8(%ebp)
  800c81:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c84:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c88:	89 c2                	mov    %eax,%edx
  800c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8d:	01 d0                	add    %edx,%eax
  800c8f:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800c92:	e9 7b ff ff ff       	jmp    800c12 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800c97:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c98:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9c:	74 08                	je     800ca6 <strtol+0x134>
		*endptr = (char *) s;
  800c9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ca6:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800caa:	74 07                	je     800cb3 <strtol+0x141>
  800cac:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800caf:	f7 d8                	neg    %eax
  800cb1:	eb 03                	jmp    800cb6 <strtol+0x144>
  800cb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cb6:	c9                   	leave  
  800cb7:	c3                   	ret    

00800cb8 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800cbb:	8b 45 14             	mov    0x14(%ebp),%eax
  800cbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800cc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800cc7:	8b 00                	mov    (%eax),%eax
  800cc9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd3:	01 d0                	add    %edx,%eax
  800cd5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800cdb:	eb 0c                	jmp    800ce9 <strsplit+0x31>
			*string++ = 0;
  800cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce0:	8d 50 01             	lea    0x1(%eax),%edx
  800ce3:	89 55 08             	mov    %edx,0x8(%ebp)
  800ce6:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	8a 00                	mov    (%eax),%al
  800cee:	84 c0                	test   %al,%al
  800cf0:	74 18                	je     800d0a <strsplit+0x52>
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8a 00                	mov    (%eax),%al
  800cf7:	0f be c0             	movsbl %al,%eax
  800cfa:	50                   	push   %eax
  800cfb:	ff 75 0c             	pushl  0xc(%ebp)
  800cfe:	e8 a1 fc ff ff       	call   8009a4 <strchr>
  800d03:	83 c4 08             	add    $0x8,%esp
  800d06:	85 c0                	test   %eax,%eax
  800d08:	75 d3                	jne    800cdd <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8a 00                	mov    (%eax),%al
  800d0f:	84 c0                	test   %al,%al
  800d11:	74 5a                	je     800d6d <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800d13:	8b 45 14             	mov    0x14(%ebp),%eax
  800d16:	8b 00                	mov    (%eax),%eax
  800d18:	83 f8 0f             	cmp    $0xf,%eax
  800d1b:	75 07                	jne    800d24 <strsplit+0x6c>
		{
			return 0;
  800d1d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d22:	eb 66                	jmp    800d8a <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800d24:	8b 45 14             	mov    0x14(%ebp),%eax
  800d27:	8b 00                	mov    (%eax),%eax
  800d29:	8d 48 01             	lea    0x1(%eax),%ecx
  800d2c:	8b 55 14             	mov    0x14(%ebp),%edx
  800d2f:	89 0a                	mov    %ecx,(%edx)
  800d31:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d38:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3b:	01 c2                	add    %eax,%edx
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800d42:	eb 03                	jmp    800d47 <strsplit+0x8f>
			string++;
  800d44:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800d47:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4a:	8a 00                	mov    (%eax),%al
  800d4c:	84 c0                	test   %al,%al
  800d4e:	74 8b                	je     800cdb <strsplit+0x23>
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	8a 00                	mov    (%eax),%al
  800d55:	0f be c0             	movsbl %al,%eax
  800d58:	50                   	push   %eax
  800d59:	ff 75 0c             	pushl  0xc(%ebp)
  800d5c:	e8 43 fc ff ff       	call   8009a4 <strchr>
  800d61:	83 c4 08             	add    $0x8,%esp
  800d64:	85 c0                	test   %eax,%eax
  800d66:	74 dc                	je     800d44 <strsplit+0x8c>
			string++;
	}
  800d68:	e9 6e ff ff ff       	jmp    800cdb <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800d6d:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800d6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800d71:	8b 00                	mov    (%eax),%eax
  800d73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7d:	01 d0                	add    %edx,%eax
  800d7f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800d85:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800d8a:	c9                   	leave  
  800d8b:	c3                   	ret    

00800d8c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d95:	8b 45 08             	mov    0x8(%ebp),%eax
  800d98:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d9e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800da1:	8b 7d 18             	mov    0x18(%ebp),%edi
  800da4:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800da7:	cd 30                	int    $0x30
  800da9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800daf:	83 c4 10             	add    $0x10,%esp
  800db2:	5b                   	pop    %ebx
  800db3:	5e                   	pop    %esi
  800db4:	5f                   	pop    %edi
  800db5:	5d                   	pop    %ebp
  800db6:	c3                   	ret    

00800db7 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800db7:	55                   	push   %ebp
  800db8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	6a 00                	push   $0x0
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	ff 75 0c             	pushl  0xc(%ebp)
  800dc6:	50                   	push   %eax
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 be ff ff ff       	call   800d8c <syscall>
  800dce:	83 c4 18             	add    $0x18,%esp
}
  800dd1:	90                   	nop
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800dd7:	6a 00                	push   $0x0
  800dd9:	6a 00                	push   $0x0
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	6a 01                	push   $0x1
  800de3:	e8 a4 ff ff ff       	call   800d8c <syscall>
  800de8:	83 c4 18             	add    $0x18,%esp
}
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800ded:	55                   	push   %ebp
  800dee:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	6a 00                	push   $0x0
  800df5:	6a 00                	push   $0x0
  800df7:	6a 00                	push   $0x0
  800df9:	6a 00                	push   $0x0
  800dfb:	50                   	push   %eax
  800dfc:	6a 03                	push   $0x3
  800dfe:	e8 89 ff ff ff       	call   800d8c <syscall>
  800e03:	83 c4 18             	add    $0x18,%esp
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800e0b:	6a 00                	push   $0x0
  800e0d:	6a 00                	push   $0x0
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	6a 00                	push   $0x0
  800e15:	6a 02                	push   $0x2
  800e17:	e8 70 ff ff ff       	call   800d8c <syscall>
  800e1c:	83 c4 18             	add    $0x18,%esp
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800e24:	6a 00                	push   $0x0
  800e26:	6a 00                	push   $0x0
  800e28:	6a 00                	push   $0x0
  800e2a:	6a 00                	push   $0x0
  800e2c:	6a 00                	push   $0x0
  800e2e:	6a 04                	push   $0x4
  800e30:	e8 57 ff ff ff       	call   800d8c <syscall>
  800e35:	83 c4 18             	add    $0x18,%esp
}
  800e38:	90                   	nop
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	6a 00                	push   $0x0
  800e46:	6a 00                	push   $0x0
  800e48:	6a 00                	push   $0x0
  800e4a:	52                   	push   %edx
  800e4b:	50                   	push   %eax
  800e4c:	6a 05                	push   $0x5
  800e4e:	e8 39 ff ff ff       	call   800d8c <syscall>
  800e53:	83 c4 18             	add    $0x18,%esp
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800e5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	6a 00                	push   $0x0
  800e63:	6a 00                	push   $0x0
  800e65:	6a 00                	push   $0x0
  800e67:	52                   	push   %edx
  800e68:	50                   	push   %eax
  800e69:	6a 06                	push   $0x6
  800e6b:	e8 1c ff ff ff       	call   800d8c <syscall>
  800e70:	83 c4 18             	add    $0x18,%esp
}
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	56                   	push   %esi
  800e79:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800e7a:	8b 75 18             	mov    0x18(%ebp),%esi
  800e7d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e80:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e83:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
  800e8b:	51                   	push   %ecx
  800e8c:	52                   	push   %edx
  800e8d:	50                   	push   %eax
  800e8e:	6a 07                	push   $0x7
  800e90:	e8 f7 fe ff ff       	call   800d8c <syscall>
  800e95:	83 c4 18             	add    $0x18,%esp
}
  800e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  800ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea8:	6a 00                	push   $0x0
  800eaa:	6a 00                	push   $0x0
  800eac:	6a 00                	push   $0x0
  800eae:	52                   	push   %edx
  800eaf:	50                   	push   %eax
  800eb0:	6a 08                	push   $0x8
  800eb2:	e8 d5 fe ff ff       	call   800d8c <syscall>
  800eb7:	83 c4 18             	add    $0x18,%esp
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  800ebf:	6a 00                	push   $0x0
  800ec1:	6a 00                	push   $0x0
  800ec3:	6a 00                	push   $0x0
  800ec5:	ff 75 0c             	pushl  0xc(%ebp)
  800ec8:	ff 75 08             	pushl  0x8(%ebp)
  800ecb:	6a 09                	push   $0x9
  800ecd:	e8 ba fe ff ff       	call   800d8c <syscall>
  800ed2:	83 c4 18             	add    $0x18,%esp
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  800eda:	6a 00                	push   $0x0
  800edc:	6a 00                	push   $0x0
  800ede:	6a 00                	push   $0x0
  800ee0:	6a 00                	push   $0x0
  800ee2:	6a 00                	push   $0x0
  800ee4:	6a 0a                	push   $0xa
  800ee6:	e8 a1 fe ff ff       	call   800d8c <syscall>
  800eeb:	83 c4 18             	add    $0x18,%esp
}
  800eee:	c9                   	leave  
  800eef:	c3                   	ret    

00800ef0 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  800ef3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef6:	6a 00                	push   $0x0
  800ef8:	6a 00                	push   $0x0
  800efa:	6a 00                	push   $0x0
  800efc:	ff 75 0c             	pushl  0xc(%ebp)
  800eff:	50                   	push   %eax
  800f00:	6a 0b                	push   $0xb
  800f02:	e8 85 fe ff ff       	call   800d8c <syscall>
  800f07:	83 c4 18             	add    $0x18,%esp
	return;
  800f0a:	90                   	nop
}
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    
  800f0d:	66 90                	xchg   %ax,%ax
  800f0f:	90                   	nop

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800f1b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f1f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f27:	89 ca                	mov    %ecx,%edx
  800f29:	89 f8                	mov    %edi,%eax
  800f2b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f2f:	85 f6                	test   %esi,%esi
  800f31:	75 2d                	jne    800f60 <__udivdi3+0x50>
  800f33:	39 cf                	cmp    %ecx,%edi
  800f35:	77 65                	ja     800f9c <__udivdi3+0x8c>
  800f37:	89 fd                	mov    %edi,%ebp
  800f39:	85 ff                	test   %edi,%edi
  800f3b:	75 0b                	jne    800f48 <__udivdi3+0x38>
  800f3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f42:	31 d2                	xor    %edx,%edx
  800f44:	f7 f7                	div    %edi
  800f46:	89 c5                	mov    %eax,%ebp
  800f48:	31 d2                	xor    %edx,%edx
  800f4a:	89 c8                	mov    %ecx,%eax
  800f4c:	f7 f5                	div    %ebp
  800f4e:	89 c1                	mov    %eax,%ecx
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	f7 f5                	div    %ebp
  800f54:	89 cf                	mov    %ecx,%edi
  800f56:	89 fa                	mov    %edi,%edx
  800f58:	83 c4 1c             	add    $0x1c,%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    
  800f60:	39 ce                	cmp    %ecx,%esi
  800f62:	77 28                	ja     800f8c <__udivdi3+0x7c>
  800f64:	0f bd fe             	bsr    %esi,%edi
  800f67:	83 f7 1f             	xor    $0x1f,%edi
  800f6a:	75 40                	jne    800fac <__udivdi3+0x9c>
  800f6c:	39 ce                	cmp    %ecx,%esi
  800f6e:	72 0a                	jb     800f7a <__udivdi3+0x6a>
  800f70:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f74:	0f 87 9e 00 00 00    	ja     801018 <__udivdi3+0x108>
  800f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7f:	89 fa                	mov    %edi,%edx
  800f81:	83 c4 1c             	add    $0x1c,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    
  800f89:	8d 76 00             	lea    0x0(%esi),%esi
  800f8c:	31 ff                	xor    %edi,%edi
  800f8e:	31 c0                	xor    %eax,%eax
  800f90:	89 fa                	mov    %edi,%edx
  800f92:	83 c4 1c             	add    $0x1c,%esp
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
  800f9a:	66 90                	xchg   %ax,%ax
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	f7 f7                	div    %edi
  800fa0:	31 ff                	xor    %edi,%edi
  800fa2:	89 fa                	mov    %edi,%edx
  800fa4:	83 c4 1c             	add    $0x1c,%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    
  800fac:	bd 20 00 00 00       	mov    $0x20,%ebp
  800fb1:	89 eb                	mov    %ebp,%ebx
  800fb3:	29 fb                	sub    %edi,%ebx
  800fb5:	89 f9                	mov    %edi,%ecx
  800fb7:	d3 e6                	shl    %cl,%esi
  800fb9:	89 c5                	mov    %eax,%ebp
  800fbb:	88 d9                	mov    %bl,%cl
  800fbd:	d3 ed                	shr    %cl,%ebp
  800fbf:	89 e9                	mov    %ebp,%ecx
  800fc1:	09 f1                	or     %esi,%ecx
  800fc3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fc7:	89 f9                	mov    %edi,%ecx
  800fc9:	d3 e0                	shl    %cl,%eax
  800fcb:	89 c5                	mov    %eax,%ebp
  800fcd:	89 d6                	mov    %edx,%esi
  800fcf:	88 d9                	mov    %bl,%cl
  800fd1:	d3 ee                	shr    %cl,%esi
  800fd3:	89 f9                	mov    %edi,%ecx
  800fd5:	d3 e2                	shl    %cl,%edx
  800fd7:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fdb:	88 d9                	mov    %bl,%cl
  800fdd:	d3 e8                	shr    %cl,%eax
  800fdf:	09 c2                	or     %eax,%edx
  800fe1:	89 d0                	mov    %edx,%eax
  800fe3:	89 f2                	mov    %esi,%edx
  800fe5:	f7 74 24 0c          	divl   0xc(%esp)
  800fe9:	89 d6                	mov    %edx,%esi
  800feb:	89 c3                	mov    %eax,%ebx
  800fed:	f7 e5                	mul    %ebp
  800fef:	39 d6                	cmp    %edx,%esi
  800ff1:	72 19                	jb     80100c <__udivdi3+0xfc>
  800ff3:	74 0b                	je     801000 <__udivdi3+0xf0>
  800ff5:	89 d8                	mov    %ebx,%eax
  800ff7:	31 ff                	xor    %edi,%edi
  800ff9:	e9 58 ff ff ff       	jmp    800f56 <__udivdi3+0x46>
  800ffe:	66 90                	xchg   %ax,%ax
  801000:	8b 54 24 08          	mov    0x8(%esp),%edx
  801004:	89 f9                	mov    %edi,%ecx
  801006:	d3 e2                	shl    %cl,%edx
  801008:	39 c2                	cmp    %eax,%edx
  80100a:	73 e9                	jae    800ff5 <__udivdi3+0xe5>
  80100c:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80100f:	31 ff                	xor    %edi,%edi
  801011:	e9 40 ff ff ff       	jmp    800f56 <__udivdi3+0x46>
  801016:	66 90                	xchg   %ax,%ax
  801018:	31 c0                	xor    %eax,%eax
  80101a:	e9 37 ff ff ff       	jmp    800f56 <__udivdi3+0x46>
  80101f:	90                   	nop

00801020 <__umoddi3>:
  801020:	55                   	push   %ebp
  801021:	57                   	push   %edi
  801022:	56                   	push   %esi
  801023:	53                   	push   %ebx
  801024:	83 ec 1c             	sub    $0x1c,%esp
  801027:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80102b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80102f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801033:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801037:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80103b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80103f:	89 f3                	mov    %esi,%ebx
  801041:	89 fa                	mov    %edi,%edx
  801043:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801047:	89 34 24             	mov    %esi,(%esp)
  80104a:	85 c0                	test   %eax,%eax
  80104c:	75 1a                	jne    801068 <__umoddi3+0x48>
  80104e:	39 f7                	cmp    %esi,%edi
  801050:	0f 86 a2 00 00 00    	jbe    8010f8 <__umoddi3+0xd8>
  801056:	89 c8                	mov    %ecx,%eax
  801058:	89 f2                	mov    %esi,%edx
  80105a:	f7 f7                	div    %edi
  80105c:	89 d0                	mov    %edx,%eax
  80105e:	31 d2                	xor    %edx,%edx
  801060:	83 c4 1c             	add    $0x1c,%esp
  801063:	5b                   	pop    %ebx
  801064:	5e                   	pop    %esi
  801065:	5f                   	pop    %edi
  801066:	5d                   	pop    %ebp
  801067:	c3                   	ret    
  801068:	39 f0                	cmp    %esi,%eax
  80106a:	0f 87 ac 00 00 00    	ja     80111c <__umoddi3+0xfc>
  801070:	0f bd e8             	bsr    %eax,%ebp
  801073:	83 f5 1f             	xor    $0x1f,%ebp
  801076:	0f 84 ac 00 00 00    	je     801128 <__umoddi3+0x108>
  80107c:	bf 20 00 00 00       	mov    $0x20,%edi
  801081:	29 ef                	sub    %ebp,%edi
  801083:	89 fe                	mov    %edi,%esi
  801085:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801089:	89 e9                	mov    %ebp,%ecx
  80108b:	d3 e0                	shl    %cl,%eax
  80108d:	89 d7                	mov    %edx,%edi
  80108f:	89 f1                	mov    %esi,%ecx
  801091:	d3 ef                	shr    %cl,%edi
  801093:	09 c7                	or     %eax,%edi
  801095:	89 e9                	mov    %ebp,%ecx
  801097:	d3 e2                	shl    %cl,%edx
  801099:	89 14 24             	mov    %edx,(%esp)
  80109c:	89 d8                	mov    %ebx,%eax
  80109e:	d3 e0                	shl    %cl,%eax
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010a6:	d3 e0                	shl    %cl,%eax
  8010a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ac:	8b 44 24 08          	mov    0x8(%esp),%eax
  8010b0:	89 f1                	mov    %esi,%ecx
  8010b2:	d3 e8                	shr    %cl,%eax
  8010b4:	09 d0                	or     %edx,%eax
  8010b6:	d3 eb                	shr    %cl,%ebx
  8010b8:	89 da                	mov    %ebx,%edx
  8010ba:	f7 f7                	div    %edi
  8010bc:	89 d3                	mov    %edx,%ebx
  8010be:	f7 24 24             	mull   (%esp)
  8010c1:	89 c6                	mov    %eax,%esi
  8010c3:	89 d1                	mov    %edx,%ecx
  8010c5:	39 d3                	cmp    %edx,%ebx
  8010c7:	0f 82 87 00 00 00    	jb     801154 <__umoddi3+0x134>
  8010cd:	0f 84 91 00 00 00    	je     801164 <__umoddi3+0x144>
  8010d3:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010d7:	29 f2                	sub    %esi,%edx
  8010d9:	19 cb                	sbb    %ecx,%ebx
  8010db:	89 d8                	mov    %ebx,%eax
  8010dd:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8010e1:	d3 e0                	shl    %cl,%eax
  8010e3:	89 e9                	mov    %ebp,%ecx
  8010e5:	d3 ea                	shr    %cl,%edx
  8010e7:	09 d0                	or     %edx,%eax
  8010e9:	89 e9                	mov    %ebp,%ecx
  8010eb:	d3 eb                	shr    %cl,%ebx
  8010ed:	89 da                	mov    %ebx,%edx
  8010ef:	83 c4 1c             	add    $0x1c,%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    
  8010f7:	90                   	nop
  8010f8:	89 fd                	mov    %edi,%ebp
  8010fa:	85 ff                	test   %edi,%edi
  8010fc:	75 0b                	jne    801109 <__umoddi3+0xe9>
  8010fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801103:	31 d2                	xor    %edx,%edx
  801105:	f7 f7                	div    %edi
  801107:	89 c5                	mov    %eax,%ebp
  801109:	89 f0                	mov    %esi,%eax
  80110b:	31 d2                	xor    %edx,%edx
  80110d:	f7 f5                	div    %ebp
  80110f:	89 c8                	mov    %ecx,%eax
  801111:	f7 f5                	div    %ebp
  801113:	89 d0                	mov    %edx,%eax
  801115:	e9 44 ff ff ff       	jmp    80105e <__umoddi3+0x3e>
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	89 c8                	mov    %ecx,%eax
  80111e:	89 f2                	mov    %esi,%edx
  801120:	83 c4 1c             	add    $0x1c,%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    
  801128:	3b 04 24             	cmp    (%esp),%eax
  80112b:	72 06                	jb     801133 <__umoddi3+0x113>
  80112d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801131:	77 0f                	ja     801142 <__umoddi3+0x122>
  801133:	89 f2                	mov    %esi,%edx
  801135:	29 f9                	sub    %edi,%ecx
  801137:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80113b:	89 14 24             	mov    %edx,(%esp)
  80113e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801142:	8b 44 24 04          	mov    0x4(%esp),%eax
  801146:	8b 14 24             	mov    (%esp),%edx
  801149:	83 c4 1c             	add    $0x1c,%esp
  80114c:	5b                   	pop    %ebx
  80114d:	5e                   	pop    %esi
  80114e:	5f                   	pop    %edi
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    
  801151:	8d 76 00             	lea    0x0(%esi),%esi
  801154:	2b 04 24             	sub    (%esp),%eax
  801157:	19 fa                	sbb    %edi,%edx
  801159:	89 d1                	mov    %edx,%ecx
  80115b:	89 c6                	mov    %eax,%esi
  80115d:	e9 71 ff ff ff       	jmp    8010d3 <__umoddi3+0xb3>
  801162:	66 90                	xchg   %ax,%ax
  801164:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801168:	72 ea                	jb     801154 <__umoddi3+0x134>
  80116a:	89 d9                	mov    %ebx,%ecx
  80116c:	e9 62 ff ff ff       	jmp    8010d3 <__umoddi3+0xb3>
