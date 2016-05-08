
obj/user/fos_add:     file format elf32-i386


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
  800031:	e8 60 00 00 00       	call   800096 <libmain>
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
  80003b:	83 ec 18             	sub    $0x18,%esp
	int i1=0;
  80003e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i2=0;
  800045:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

	i1 = strtol("1", NULL, 10);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 0a                	push   $0xa
  800051:	6a 00                	push   $0x0
  800053:	68 60 11 80 00       	push   $0x801160
  800058:	e8 fc 0a 00 00       	call   800b59 <strtol>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	89 45 f4             	mov    %eax,-0xc(%ebp)
	i2 = strtol("2", NULL, 10);
  800063:	83 ec 04             	sub    $0x4,%esp
  800066:	6a 0a                	push   $0xa
  800068:	6a 00                	push   $0x0
  80006a:	68 62 11 80 00       	push   $0x801162
  80006f:	e8 e5 0a 00 00       	call   800b59 <strtol>
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	89 45 f0             	mov    %eax,-0x10(%ebp)

	cprintf("number 1 + number 2 = %d\n",i1+i2);
  80007a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80007d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800080:	01 d0                	add    %edx,%eax
  800082:	83 ec 08             	sub    $0x8,%esp
  800085:	50                   	push   %eax
  800086:	68 64 11 80 00       	push   $0x801164
  80008b:	e8 1e 01 00 00       	call   8001ae <cprintf>
  800090:	83 c4 10             	add    $0x10,%esp
	return;	
  800093:	90                   	nop
}
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  80009c:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000a3:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000aa:	7e 0a                	jle    8000b6 <libmain+0x20>
		binaryname = argv[0];
  8000ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000af:	8b 00                	mov    (%eax),%eax
  8000b1:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000b6:	83 ec 08             	sub    $0x8,%esp
  8000b9:	ff 75 0c             	pushl  0xc(%ebp)
  8000bc:	ff 75 08             	pushl  0x8(%ebp)
  8000bf:	e8 74 ff ff ff       	call   800038 <_main>
  8000c4:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  8000c7:	e8 19 00 00 00       	call   8000e5 <sleep>
}
  8000cc:	90                   	nop
  8000cd:	c9                   	leave  
  8000ce:	c3                   	ret    

008000cf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 f5 0c 00 00       	call   800dd4 <sys_env_destroy>
  8000df:	83 c4 10             	add    $0x10,%esp
}
  8000e2:	90                   	nop
  8000e3:	c9                   	leave  
  8000e4:	c3                   	ret    

008000e5 <sleep>:

void
sleep(void)
{	
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  8000eb:	e8 18 0d 00 00       	call   800e08 <sys_env_sleep>
}
  8000f0:	90                   	nop
  8000f1:	c9                   	leave  
  8000f2:	c3                   	ret    

008000f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  8000f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000fc:	8b 00                	mov    (%eax),%eax
  8000fe:	8d 48 01             	lea    0x1(%eax),%ecx
  800101:	8b 55 0c             	mov    0xc(%ebp),%edx
  800104:	89 0a                	mov    %ecx,(%edx)
  800106:	8b 55 08             	mov    0x8(%ebp),%edx
  800109:	88 d1                	mov    %dl,%cl
  80010b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80010e:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800112:	8b 45 0c             	mov    0xc(%ebp),%eax
  800115:	8b 00                	mov    (%eax),%eax
  800117:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011c:	75 23                	jne    800141 <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  80011e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800121:	8b 00                	mov    (%eax),%eax
  800123:	89 c2                	mov    %eax,%edx
  800125:	8b 45 0c             	mov    0xc(%ebp),%eax
  800128:	83 c0 08             	add    $0x8,%eax
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	52                   	push   %edx
  80012f:	50                   	push   %eax
  800130:	e8 69 0c 00 00       	call   800d9e <sys_cputs>
  800135:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  800138:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800141:	8b 45 0c             	mov    0xc(%ebp),%eax
  800144:	8b 40 04             	mov    0x4(%eax),%eax
  800147:	8d 50 01             	lea    0x1(%eax),%edx
  80014a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014d:	89 50 04             	mov    %edx,0x4(%eax)
}
  800150:	90                   	nop
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800163:	00 00 00 
	b.cnt = 0;
  800166:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800170:	ff 75 0c             	pushl  0xc(%ebp)
  800173:	ff 75 08             	pushl  0x8(%ebp)
  800176:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017c:	50                   	push   %eax
  80017d:	68 f3 00 80 00       	push   $0x8000f3
  800182:	e8 ca 01 00 00       	call   800351 <vprintfmt>
  800187:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  80018a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	50                   	push   %eax
  800194:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019a:	83 c0 08             	add    $0x8,%eax
  80019d:	50                   	push   %eax
  80019e:	e8 fb 0b 00 00       	call   800d9e <sys_cputs>
  8001a3:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  8001a6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    

008001ae <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ae:	55                   	push   %ebp
  8001af:	89 e5                	mov    %esp,%ebp
  8001b1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b4:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8001ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8001c3:	50                   	push   %eax
  8001c4:	e8 8a ff ff ff       	call   800153 <vcprintf>
  8001c9:	83 c4 10             	add    $0x10,%esp
  8001cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  8001cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 14             	sub    $0x14,%esp
  8001db:	8b 45 10             	mov    0x10(%ebp),%eax
  8001de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8001e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e7:	8b 45 18             	mov    0x18(%ebp),%eax
  8001ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ef:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001f2:	77 55                	ja     800249 <printnum+0x75>
  8001f4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8001f7:	72 05                	jb     8001fe <printnum+0x2a>
  8001f9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001fc:	77 4b                	ja     800249 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001fe:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	8b 45 18             	mov    0x18(%ebp),%eax
  800207:	ba 00 00 00 00       	mov    $0x0,%edx
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	ff 75 f4             	pushl  -0xc(%ebp)
  800211:	ff 75 f0             	pushl  -0x10(%ebp)
  800214:	e8 db 0c 00 00       	call   800ef4 <__udivdi3>
  800219:	83 c4 10             	add    $0x10,%esp
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	ff 75 20             	pushl  0x20(%ebp)
  800222:	53                   	push   %ebx
  800223:	ff 75 18             	pushl  0x18(%ebp)
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	e8 a1 ff ff ff       	call   8001d4 <printnum>
  800233:	83 c4 20             	add    $0x20,%esp
  800236:	eb 1a                	jmp    800252 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800238:	83 ec 08             	sub    $0x8,%esp
  80023b:	ff 75 0c             	pushl  0xc(%ebp)
  80023e:	ff 75 20             	pushl  0x20(%ebp)
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	ff d0                	call   *%eax
  800246:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800249:	ff 4d 1c             	decl   0x1c(%ebp)
  80024c:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800250:	7f e6                	jg     800238 <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800252:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800255:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80025d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800260:	53                   	push   %ebx
  800261:	51                   	push   %ecx
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	e8 9b 0d 00 00       	call   801004 <__umoddi3>
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	05 40 12 80 00       	add    $0x801240,%eax
  800271:	8a 00                	mov    (%eax),%al
  800273:	0f be c0             	movsbl %al,%eax
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	ff 75 0c             	pushl  0xc(%ebp)
  80027c:	50                   	push   %eax
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	ff d0                	call   *%eax
  800282:	83 c4 10             	add    $0x10,%esp
}
  800285:	90                   	nop
  800286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80028e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800292:	7e 1c                	jle    8002b0 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	8b 00                	mov    (%eax),%eax
  800299:	8d 50 08             	lea    0x8(%eax),%edx
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	89 10                	mov    %edx,(%eax)
  8002a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a4:	8b 00                	mov    (%eax),%eax
  8002a6:	83 e8 08             	sub    $0x8,%eax
  8002a9:	8b 50 04             	mov    0x4(%eax),%edx
  8002ac:	8b 00                	mov    (%eax),%eax
  8002ae:	eb 40                	jmp    8002f0 <getuint+0x65>
	else if (lflag)
  8002b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002b4:	74 1e                	je     8002d4 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8002b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b9:	8b 00                	mov    (%eax),%eax
  8002bb:	8d 50 04             	lea    0x4(%eax),%edx
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 10                	mov    %edx,(%eax)
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	8b 00                	mov    (%eax),%eax
  8002c8:	83 e8 04             	sub    $0x4,%eax
  8002cb:	8b 00                	mov    (%eax),%eax
  8002cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d2:	eb 1c                	jmp    8002f0 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  8002d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d7:	8b 00                	mov    (%eax),%eax
  8002d9:	8d 50 04             	lea    0x4(%eax),%edx
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	89 10                	mov    %edx,(%eax)
  8002e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e4:	8b 00                	mov    (%eax),%eax
  8002e6:	83 e8 04             	sub    $0x4,%eax
  8002e9:	8b 00                	mov    (%eax),%eax
  8002eb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002f0:	5d                   	pop    %ebp
  8002f1:	c3                   	ret    

008002f2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002f9:	7e 1c                	jle    800317 <getint+0x25>
		return va_arg(*ap, long long);
  8002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fe:	8b 00                	mov    (%eax),%eax
  800300:	8d 50 08             	lea    0x8(%eax),%edx
  800303:	8b 45 08             	mov    0x8(%ebp),%eax
  800306:	89 10                	mov    %edx,(%eax)
  800308:	8b 45 08             	mov    0x8(%ebp),%eax
  80030b:	8b 00                	mov    (%eax),%eax
  80030d:	83 e8 08             	sub    $0x8,%eax
  800310:	8b 50 04             	mov    0x4(%eax),%edx
  800313:	8b 00                	mov    (%eax),%eax
  800315:	eb 38                	jmp    80034f <getint+0x5d>
	else if (lflag)
  800317:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80031b:	74 1a                	je     800337 <getint+0x45>
		return va_arg(*ap, long);
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	8b 00                	mov    (%eax),%eax
  800322:	8d 50 04             	lea    0x4(%eax),%edx
  800325:	8b 45 08             	mov    0x8(%ebp),%eax
  800328:	89 10                	mov    %edx,(%eax)
  80032a:	8b 45 08             	mov    0x8(%ebp),%eax
  80032d:	8b 00                	mov    (%eax),%eax
  80032f:	83 e8 04             	sub    $0x4,%eax
  800332:	8b 00                	mov    (%eax),%eax
  800334:	99                   	cltd   
  800335:	eb 18                	jmp    80034f <getint+0x5d>
	else
		return va_arg(*ap, int);
  800337:	8b 45 08             	mov    0x8(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	8d 50 04             	lea    0x4(%eax),%edx
  80033f:	8b 45 08             	mov    0x8(%ebp),%eax
  800342:	89 10                	mov    %edx,(%eax)
  800344:	8b 45 08             	mov    0x8(%ebp),%eax
  800347:	8b 00                	mov    (%eax),%eax
  800349:	83 e8 04             	sub    $0x4,%eax
  80034c:	8b 00                	mov    (%eax),%eax
  80034e:	99                   	cltd   
}
  80034f:	5d                   	pop    %ebp
  800350:	c3                   	ret    

00800351 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	56                   	push   %esi
  800355:	53                   	push   %ebx
  800356:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800359:	eb 17                	jmp    800372 <vprintfmt+0x21>
			if (ch == '\0')
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	0f 84 af 03 00 00    	je     800712 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 0c             	pushl  0xc(%ebp)
  800369:	53                   	push   %ebx
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	ff d0                	call   *%eax
  80036f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800372:	8b 45 10             	mov    0x10(%ebp),%eax
  800375:	8d 50 01             	lea    0x1(%eax),%edx
  800378:	89 55 10             	mov    %edx,0x10(%ebp)
  80037b:	8a 00                	mov    (%eax),%al
  80037d:	0f b6 d8             	movzbl %al,%ebx
  800380:	83 fb 25             	cmp    $0x25,%ebx
  800383:	75 d6                	jne    80035b <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800385:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800389:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800390:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800397:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80039e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a8:	8d 50 01             	lea    0x1(%eax),%edx
  8003ab:	89 55 10             	mov    %edx,0x10(%ebp)
  8003ae:	8a 00                	mov    (%eax),%al
  8003b0:	0f b6 d8             	movzbl %al,%ebx
  8003b3:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003b6:	83 f8 55             	cmp    $0x55,%eax
  8003b9:	0f 87 2b 03 00 00    	ja     8006ea <vprintfmt+0x399>
  8003bf:	8b 04 85 64 12 80 00 	mov    0x801264(,%eax,4),%eax
  8003c6:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003c8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  8003cc:	eb d7                	jmp    8003a5 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ce:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  8003d2:	eb d1                	jmp    8003a5 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d4:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8003db:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003de:	89 d0                	mov    %edx,%eax
  8003e0:	c1 e0 02             	shl    $0x2,%eax
  8003e3:	01 d0                	add    %edx,%eax
  8003e5:	01 c0                	add    %eax,%eax
  8003e7:	01 d8                	add    %ebx,%eax
  8003e9:	83 e8 30             	sub    $0x30,%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8003ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8003f2:	8a 00                	mov    (%eax),%al
  8003f4:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8003f7:	83 fb 2f             	cmp    $0x2f,%ebx
  8003fa:	7e 3e                	jle    80043a <vprintfmt+0xe9>
  8003fc:	83 fb 39             	cmp    $0x39,%ebx
  8003ff:	7f 39                	jg     80043a <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800401:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800404:	eb d5                	jmp    8003db <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800406:	8b 45 14             	mov    0x14(%ebp),%eax
  800409:	83 c0 04             	add    $0x4,%eax
  80040c:	89 45 14             	mov    %eax,0x14(%ebp)
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	83 e8 04             	sub    $0x4,%eax
  800415:	8b 00                	mov    (%eax),%eax
  800417:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80041a:	eb 1f                	jmp    80043b <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80041c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800420:	79 83                	jns    8003a5 <vprintfmt+0x54>
				width = 0;
  800422:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  800429:	e9 77 ff ff ff       	jmp    8003a5 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  80042e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800435:	e9 6b ff ff ff       	jmp    8003a5 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80043a:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80043b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80043f:	0f 89 60 ff ff ff    	jns    8003a5 <vprintfmt+0x54>
				width = precision, precision = -1;
  800445:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800452:	e9 4e ff ff ff       	jmp    8003a5 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800457:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80045a:	e9 46 ff ff ff       	jmp    8003a5 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 14             	mov    %eax,0x14(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	83 e8 04             	sub    $0x4,%eax
  80046e:	8b 00                	mov    (%eax),%eax
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	ff 75 0c             	pushl  0xc(%ebp)
  800476:	50                   	push   %eax
  800477:	8b 45 08             	mov    0x8(%ebp),%eax
  80047a:	ff d0                	call   *%eax
  80047c:	83 c4 10             	add    $0x10,%esp
			break;
  80047f:	e9 89 02 00 00       	jmp    80070d <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	83 c0 04             	add    $0x4,%eax
  80048a:	89 45 14             	mov    %eax,0x14(%ebp)
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	83 e8 04             	sub    $0x4,%eax
  800493:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800495:	85 db                	test   %ebx,%ebx
  800497:	79 02                	jns    80049b <vprintfmt+0x14a>
				err = -err;
  800499:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  80049b:	83 fb 07             	cmp    $0x7,%ebx
  80049e:	7f 0b                	jg     8004ab <vprintfmt+0x15a>
  8004a0:	8b 34 9d 20 12 80 00 	mov    0x801220(,%ebx,4),%esi
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	75 19                	jne    8004c4 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8004ab:	53                   	push   %ebx
  8004ac:	68 51 12 80 00       	push   $0x801251
  8004b1:	ff 75 0c             	pushl  0xc(%ebp)
  8004b4:	ff 75 08             	pushl  0x8(%ebp)
  8004b7:	e8 5e 02 00 00       	call   80071a <printfmt>
  8004bc:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004bf:	e9 49 02 00 00       	jmp    80070d <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004c4:	56                   	push   %esi
  8004c5:	68 5a 12 80 00       	push   $0x80125a
  8004ca:	ff 75 0c             	pushl  0xc(%ebp)
  8004cd:	ff 75 08             	pushl  0x8(%ebp)
  8004d0:	e8 45 02 00 00       	call   80071a <printfmt>
  8004d5:	83 c4 10             	add    $0x10,%esp
			break;
  8004d8:	e9 30 02 00 00       	jmp    80070d <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	83 c0 04             	add    $0x4,%eax
  8004e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e9:	83 e8 04             	sub    $0x4,%eax
  8004ec:	8b 30                	mov    (%eax),%esi
  8004ee:	85 f6                	test   %esi,%esi
  8004f0:	75 05                	jne    8004f7 <vprintfmt+0x1a6>
				p = "(null)";
  8004f2:	be 5d 12 80 00       	mov    $0x80125d,%esi
			if (width > 0 && padc != '-')
  8004f7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004fb:	7e 6d                	jle    80056a <vprintfmt+0x219>
  8004fd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800501:	74 67                	je     80056a <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	50                   	push   %eax
  80050a:	56                   	push   %esi
  80050b:	e8 0c 03 00 00       	call   80081c <strnlen>
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800516:	eb 16                	jmp    80052e <vprintfmt+0x1dd>
					putch(padc, putdat);
  800518:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	50                   	push   %eax
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	ff d0                	call   *%eax
  800528:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	ff 4d e4             	decl   -0x1c(%ebp)
  80052e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800532:	7f e4                	jg     800518 <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800534:	eb 34                	jmp    80056a <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80053a:	74 1c                	je     800558 <vprintfmt+0x207>
  80053c:	83 fb 1f             	cmp    $0x1f,%ebx
  80053f:	7e 05                	jle    800546 <vprintfmt+0x1f5>
  800541:	83 fb 7e             	cmp    $0x7e,%ebx
  800544:	7e 12                	jle    800558 <vprintfmt+0x207>
					putch('?', putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	ff 75 0c             	pushl  0xc(%ebp)
  80054c:	6a 3f                	push   $0x3f
  80054e:	8b 45 08             	mov    0x8(%ebp),%eax
  800551:	ff d0                	call   *%eax
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	eb 0f                	jmp    800567 <vprintfmt+0x216>
				else
					putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	ff 75 0c             	pushl  0xc(%ebp)
  80055e:	53                   	push   %ebx
  80055f:	8b 45 08             	mov    0x8(%ebp),%eax
  800562:	ff d0                	call   *%eax
  800564:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800567:	ff 4d e4             	decl   -0x1c(%ebp)
  80056a:	89 f0                	mov    %esi,%eax
  80056c:	8d 70 01             	lea    0x1(%eax),%esi
  80056f:	8a 00                	mov    (%eax),%al
  800571:	0f be d8             	movsbl %al,%ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	74 24                	je     80059c <vprintfmt+0x24b>
  800578:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057c:	78 b8                	js     800536 <vprintfmt+0x1e5>
  80057e:	ff 4d e0             	decl   -0x20(%ebp)
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	79 af                	jns    800536 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800587:	eb 13                	jmp    80059c <vprintfmt+0x24b>
				putch(' ', putdat);
  800589:	83 ec 08             	sub    $0x8,%esp
  80058c:	ff 75 0c             	pushl  0xc(%ebp)
  80058f:	6a 20                	push   $0x20
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	ff d0                	call   *%eax
  800596:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800599:	ff 4d e4             	decl   -0x1c(%ebp)
  80059c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a0:	7f e7                	jg     800589 <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8005a2:	e9 66 01 00 00       	jmp    80070d <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	ff 75 e8             	pushl  -0x18(%ebp)
  8005ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8005b0:	50                   	push   %eax
  8005b1:	e8 3c fd ff ff       	call   8002f2 <getint>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005bc:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005c5:	85 d2                	test   %edx,%edx
  8005c7:	79 23                	jns    8005ec <vprintfmt+0x29b>
				putch('-', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	ff 75 0c             	pushl  0xc(%ebp)
  8005cf:	6a 2d                	push   $0x2d
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	ff d0                	call   *%eax
  8005d6:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  8005d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005df:	f7 d8                	neg    %eax
  8005e1:	83 d2 00             	adc    $0x0,%edx
  8005e4:	f7 da                	neg    %edx
  8005e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8005ec:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8005f3:	e9 bc 00 00 00       	jmp    8006b4 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	ff 75 e8             	pushl  -0x18(%ebp)
  8005fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800601:	50                   	push   %eax
  800602:	e8 84 fc ff ff       	call   80028b <getuint>
  800607:	83 c4 10             	add    $0x10,%esp
  80060a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80060d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800610:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800617:	e9 98 00 00 00       	jmp    8006b4 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	ff 75 0c             	pushl  0xc(%ebp)
  800622:	6a 58                	push   $0x58
  800624:	8b 45 08             	mov    0x8(%ebp),%eax
  800627:	ff d0                	call   *%eax
  800629:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	ff 75 0c             	pushl  0xc(%ebp)
  800632:	6a 58                	push   $0x58
  800634:	8b 45 08             	mov    0x8(%ebp),%eax
  800637:	ff d0                	call   *%eax
  800639:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	ff 75 0c             	pushl  0xc(%ebp)
  800642:	6a 58                	push   $0x58
  800644:	8b 45 08             	mov    0x8(%ebp),%eax
  800647:	ff d0                	call   *%eax
  800649:	83 c4 10             	add    $0x10,%esp
			break;
  80064c:	e9 bc 00 00 00       	jmp    80070d <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 0c             	pushl  0xc(%ebp)
  800657:	6a 30                	push   $0x30
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	ff d0                	call   *%eax
  80065e:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	6a 78                	push   $0x78
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	ff d0                	call   *%eax
  80066e:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	83 c0 04             	add    $0x4,%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	83 e8 04             	sub    $0x4,%eax
  800680:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800682:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800685:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  80068c:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800693:	eb 1f                	jmp    8006b4 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	ff 75 e8             	pushl  -0x18(%ebp)
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	e8 e7 fb ff ff       	call   80028b <getuint>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006ad:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006bb:	83 ec 04             	sub    $0x4,%esp
  8006be:	52                   	push   %edx
  8006bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006c2:	50                   	push   %eax
  8006c3:	ff 75 f4             	pushl  -0xc(%ebp)
  8006c6:	ff 75 f0             	pushl  -0x10(%ebp)
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	ff 75 08             	pushl  0x8(%ebp)
  8006cf:	e8 00 fb ff ff       	call   8001d4 <printnum>
  8006d4:	83 c4 20             	add    $0x20,%esp
			break;
  8006d7:	eb 34                	jmp    80070d <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	ff 75 0c             	pushl  0xc(%ebp)
  8006df:	53                   	push   %ebx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	ff d0                	call   *%eax
  8006e5:	83 c4 10             	add    $0x10,%esp
			break;
  8006e8:	eb 23                	jmp    80070d <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	ff 75 0c             	pushl  0xc(%ebp)
  8006f0:	6a 25                	push   $0x25
  8006f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f5:	ff d0                	call   *%eax
  8006f7:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	ff 4d 10             	decl   0x10(%ebp)
  8006fd:	eb 03                	jmp    800702 <vprintfmt+0x3b1>
  8006ff:	ff 4d 10             	decl   0x10(%ebp)
  800702:	8b 45 10             	mov    0x10(%ebp),%eax
  800705:	48                   	dec    %eax
  800706:	8a 00                	mov    (%eax),%al
  800708:	3c 25                	cmp    $0x25,%al
  80070a:	75 f3                	jne    8006ff <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  80070c:	90                   	nop
		}
	}
  80070d:	e9 47 fc ff ff       	jmp    800359 <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800712:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800713:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800720:	8d 45 10             	lea    0x10(%ebp),%eax
  800723:	83 c0 04             	add    $0x4,%eax
  800726:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800729:	8b 45 10             	mov    0x10(%ebp),%eax
  80072c:	ff 75 f4             	pushl  -0xc(%ebp)
  80072f:	50                   	push   %eax
  800730:	ff 75 0c             	pushl  0xc(%ebp)
  800733:	ff 75 08             	pushl  0x8(%ebp)
  800736:	e8 16 fc ff ff       	call   800351 <vprintfmt>
  80073b:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  80073e:	90                   	nop
  80073f:	c9                   	leave  
  800740:	c3                   	ret    

00800741 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800741:	55                   	push   %ebp
  800742:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800744:	8b 45 0c             	mov    0xc(%ebp),%eax
  800747:	8b 40 08             	mov    0x8(%eax),%eax
  80074a:	8d 50 01             	lea    0x1(%eax),%edx
  80074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800750:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800753:	8b 45 0c             	mov    0xc(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075b:	8b 40 04             	mov    0x4(%eax),%eax
  80075e:	39 c2                	cmp    %eax,%edx
  800760:	73 12                	jae    800774 <sprintputch+0x33>
		*b->buf++ = ch;
  800762:	8b 45 0c             	mov    0xc(%ebp),%eax
  800765:	8b 00                	mov    (%eax),%eax
  800767:	8d 48 01             	lea    0x1(%eax),%ecx
  80076a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80076d:	89 0a                	mov    %ecx,(%edx)
  80076f:	8b 55 08             	mov    0x8(%ebp),%edx
  800772:	88 10                	mov    %dl,(%eax)
}
  800774:	90                   	nop
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077d:	8b 45 08             	mov    0x8(%ebp),%eax
  800780:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800783:	8b 45 0c             	mov    0xc(%ebp),%eax
  800786:	8d 50 ff             	lea    -0x1(%eax),%edx
  800789:	8b 45 08             	mov    0x8(%ebp),%eax
  80078c:	01 d0                	add    %edx,%eax
  80078e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800791:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800798:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80079c:	74 06                	je     8007a4 <vsnprintf+0x2d>
  80079e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007a2:	7f 07                	jg     8007ab <vsnprintf+0x34>
		return -E_INVAL;
  8007a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8007a9:	eb 20                	jmp    8007cb <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ab:	ff 75 14             	pushl  0x14(%ebp)
  8007ae:	ff 75 10             	pushl  0x10(%ebp)
  8007b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 41 07 80 00       	push   $0x800741
  8007ba:	e8 92 fb ff ff       	call   800351 <vprintfmt>
  8007bf:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8007c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d3:	8d 45 10             	lea    0x10(%ebp),%eax
  8007d6:	83 c0 04             	add    $0x4,%eax
  8007d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  8007dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8007df:	ff 75 f4             	pushl  -0xc(%ebp)
  8007e2:	50                   	push   %eax
  8007e3:	ff 75 0c             	pushl  0xc(%ebp)
  8007e6:	ff 75 08             	pushl  0x8(%ebp)
  8007e9:	e8 89 ff ff ff       	call   800777 <vsnprintf>
  8007ee:	83 c4 10             	add    $0x10,%esp
  8007f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800806:	eb 06                	jmp    80080e <strlen+0x15>
		n++;
  800808:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080b:	ff 45 08             	incl   0x8(%ebp)
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8a 00                	mov    (%eax),%al
  800813:	84 c0                	test   %al,%al
  800815:	75 f1                	jne    800808 <strlen+0xf>
		n++;
	return n;
  800817:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800822:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800829:	eb 09                	jmp    800834 <strnlen+0x18>
		n++;
  80082b:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082e:	ff 45 08             	incl   0x8(%ebp)
  800831:	ff 4d 0c             	decl   0xc(%ebp)
  800834:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800838:	74 09                	je     800843 <strnlen+0x27>
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8a 00                	mov    (%eax),%al
  80083f:	84 c0                	test   %al,%al
  800841:	75 e8                	jne    80082b <strnlen+0xf>
		n++;
	return n;
  800843:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800854:	90                   	nop
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	8d 50 01             	lea    0x1(%eax),%edx
  80085b:	89 55 08             	mov    %edx,0x8(%ebp)
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8d 4a 01             	lea    0x1(%edx),%ecx
  800864:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800867:	8a 12                	mov    (%edx),%dl
  800869:	88 10                	mov    %dl,(%eax)
  80086b:	8a 00                	mov    (%eax),%al
  80086d:	84 c0                	test   %al,%al
  80086f:	75 e4                	jne    800855 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800871:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  80087c:	8b 45 08             	mov    0x8(%ebp),%eax
  80087f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800882:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800889:	eb 1f                	jmp    8008aa <strncpy+0x34>
		*dst++ = *src;
  80088b:	8b 45 08             	mov    0x8(%ebp),%eax
  80088e:	8d 50 01             	lea    0x1(%eax),%edx
  800891:	89 55 08             	mov    %edx,0x8(%ebp)
  800894:	8b 55 0c             	mov    0xc(%ebp),%edx
  800897:	8a 12                	mov    (%edx),%dl
  800899:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  80089b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089e:	8a 00                	mov    (%eax),%al
  8008a0:	84 c0                	test   %al,%al
  8008a2:	74 03                	je     8008a7 <strncpy+0x31>
			src++;
  8008a4:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a7:	ff 45 fc             	incl   -0x4(%ebp)
  8008aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ad:	3b 45 10             	cmp    0x10(%ebp),%eax
  8008b0:	72 d9                	jb     80088b <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8008b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8008b5:	c9                   	leave  
  8008b6:	c3                   	ret    

008008b7 <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8008c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008c7:	74 30                	je     8008f9 <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8008c9:	eb 16                	jmp    8008e1 <strlcpy+0x2a>
			*dst++ = *src++;
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8d 50 01             	lea    0x1(%eax),%edx
  8008d1:	89 55 08             	mov    %edx,0x8(%ebp)
  8008d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8008da:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8008dd:	8a 12                	mov    (%edx),%dl
  8008df:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e1:	ff 4d 10             	decl   0x10(%ebp)
  8008e4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008e8:	74 09                	je     8008f3 <strlcpy+0x3c>
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	8a 00                	mov    (%eax),%al
  8008ef:	84 c0                	test   %al,%al
  8008f1:	75 d8                	jne    8008cb <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8008ff:	29 c2                	sub    %eax,%edx
  800901:	89 d0                	mov    %edx,%eax
}
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800908:	eb 06                	jmp    800910 <strcmp+0xb>
		p++, q++;
  80090a:	ff 45 08             	incl   0x8(%ebp)
  80090d:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8a 00                	mov    (%eax),%al
  800915:	84 c0                	test   %al,%al
  800917:	74 0e                	je     800927 <strcmp+0x22>
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8a 10                	mov    (%eax),%dl
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	8a 00                	mov    (%eax),%al
  800923:	38 c2                	cmp    %al,%dl
  800925:	74 e3                	je     80090a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	8a 00                	mov    (%eax),%al
  80092c:	0f b6 d0             	movzbl %al,%edx
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	8a 00                	mov    (%eax),%al
  800934:	0f b6 c0             	movzbl %al,%eax
  800937:	29 c2                	sub    %eax,%edx
  800939:	89 d0                	mov    %edx,%eax
}
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800940:	eb 09                	jmp    80094b <strncmp+0xe>
		n--, p++, q++;
  800942:	ff 4d 10             	decl   0x10(%ebp)
  800945:	ff 45 08             	incl   0x8(%ebp)
  800948:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  80094b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80094f:	74 17                	je     800968 <strncmp+0x2b>
  800951:	8b 45 08             	mov    0x8(%ebp),%eax
  800954:	8a 00                	mov    (%eax),%al
  800956:	84 c0                	test   %al,%al
  800958:	74 0e                	je     800968 <strncmp+0x2b>
  80095a:	8b 45 08             	mov    0x8(%ebp),%eax
  80095d:	8a 10                	mov    (%eax),%dl
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	8a 00                	mov    (%eax),%al
  800964:	38 c2                	cmp    %al,%dl
  800966:	74 da                	je     800942 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800968:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80096c:	75 07                	jne    800975 <strncmp+0x38>
		return 0;
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
  800973:	eb 14                	jmp    800989 <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8a 00                	mov    (%eax),%al
  80097a:	0f b6 d0             	movzbl %al,%edx
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	8a 00                	mov    (%eax),%al
  800982:	0f b6 c0             	movzbl %al,%eax
  800985:	29 c2                	sub    %eax,%edx
  800987:	89 d0                	mov    %edx,%eax
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 04             	sub    $0x4,%esp
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800997:	eb 12                	jmp    8009ab <strchr+0x20>
		if (*s == c)
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	8a 00                	mov    (%eax),%al
  80099e:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009a1:	75 05                	jne    8009a8 <strchr+0x1d>
			return (char *) s;
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	eb 11                	jmp    8009b9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	ff 45 08             	incl   0x8(%ebp)
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8a 00                	mov    (%eax),%al
  8009b0:	84 c0                	test   %al,%al
  8009b2:	75 e5                	jne    800999 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 04             	sub    $0x4,%esp
  8009c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c4:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  8009c7:	eb 0d                	jmp    8009d6 <strfind+0x1b>
		if (*s == c)
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8a 00                	mov    (%eax),%al
  8009ce:	3a 45 fc             	cmp    -0x4(%ebp),%al
  8009d1:	74 0e                	je     8009e1 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009d3:	ff 45 08             	incl   0x8(%ebp)
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8a 00                	mov    (%eax),%al
  8009db:	84 c0                	test   %al,%al
  8009dd:	75 ea                	jne    8009c9 <strfind+0xe>
  8009df:	eb 01                	jmp    8009e2 <strfind+0x27>
		if (*s == c)
			break;
  8009e1:	90                   	nop
	return (char *) s;
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memset>:


void *
memset(void *v, int c, uint32 n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  8009ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  8009f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f6:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  8009f9:	eb 0e                	jmp    800a09 <memset+0x22>
		*p++ = c;
  8009fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009fe:	8d 50 01             	lea    0x1(%eax),%edx
  800a01:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800a04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a07:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800a09:	ff 4d f8             	decl   -0x8(%ebp)
  800a0c:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800a10:	79 e9                	jns    8009fb <memset+0x14>
		*p++ = c;

	return v;
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a20:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800a29:	eb 16                	jmp    800a41 <memcpy+0x2a>
		*d++ = *s++;
  800a2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a2e:	8d 50 01             	lea    0x1(%eax),%edx
  800a31:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800a34:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a37:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a3a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800a3d:	8a 12                	mov    (%edx),%dl
  800a3f:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800a41:	8b 45 10             	mov    0x10(%ebp),%eax
  800a44:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a47:	89 55 10             	mov    %edx,0x10(%ebp)
  800a4a:	85 c0                	test   %eax,%eax
  800a4c:	75 dd                	jne    800a2b <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    

00800a53 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800a59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800a65:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a68:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a6b:	73 50                	jae    800abd <memmove+0x6a>
  800a6d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800a70:	8b 45 10             	mov    0x10(%ebp),%eax
  800a73:	01 d0                	add    %edx,%eax
  800a75:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800a78:	76 43                	jbe    800abd <memmove+0x6a>
		s += n;
  800a7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7d:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800a80:	8b 45 10             	mov    0x10(%ebp),%eax
  800a83:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800a86:	eb 10                	jmp    800a98 <memmove+0x45>
			*--d = *--s;
  800a88:	ff 4d f8             	decl   -0x8(%ebp)
  800a8b:	ff 4d fc             	decl   -0x4(%ebp)
  800a8e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a91:	8a 10                	mov    (%eax),%dl
  800a93:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800a96:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800a98:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800a9e:	89 55 10             	mov    %edx,0x10(%ebp)
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	75 e3                	jne    800a88 <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa5:	eb 23                	jmp    800aca <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800aa7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800aaa:	8d 50 01             	lea    0x1(%eax),%edx
  800aad:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800ab0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ab3:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ab6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800ab9:	8a 12                	mov    (%edx),%dl
  800abb:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800abd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ac0:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ac3:	89 55 10             	mov    %edx,0x10(%ebp)
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	75 dd                	jne    800aa7 <memmove+0x54>
			*d++ = *s++;

	return dst;
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800acd:	c9                   	leave  
  800ace:	c3                   	ret    

00800acf <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ade:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800ae1:	eb 2a                	jmp    800b0d <memcmp+0x3e>
		if (*s1 != *s2)
  800ae3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ae6:	8a 10                	mov    (%eax),%dl
  800ae8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800aeb:	8a 00                	mov    (%eax),%al
  800aed:	38 c2                	cmp    %al,%dl
  800aef:	74 16                	je     800b07 <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800af1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800af4:	8a 00                	mov    (%eax),%al
  800af6:	0f b6 d0             	movzbl %al,%edx
  800af9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800afc:	8a 00                	mov    (%eax),%al
  800afe:	0f b6 c0             	movzbl %al,%eax
  800b01:	29 c2                	sub    %eax,%edx
  800b03:	89 d0                	mov    %edx,%eax
  800b05:	eb 18                	jmp    800b1f <memcmp+0x50>
		s1++, s2++;
  800b07:	ff 45 fc             	incl   -0x4(%ebp)
  800b0a:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800b0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b10:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b13:	89 55 10             	mov    %edx,0x10(%ebp)
  800b16:	85 c0                	test   %eax,%eax
  800b18:	75 c9                	jne    800ae3 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800b27:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2d:	01 d0                	add    %edx,%eax
  800b2f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800b32:	eb 15                	jmp    800b49 <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	8b 45 08             	mov    0x8(%ebp),%eax
  800b37:	8a 00                	mov    (%eax),%al
  800b39:	0f b6 d0             	movzbl %al,%edx
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	0f b6 c0             	movzbl %al,%eax
  800b42:	39 c2                	cmp    %eax,%edx
  800b44:	74 0d                	je     800b53 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b46:	ff 45 08             	incl   0x8(%ebp)
  800b49:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800b4f:	72 e3                	jb     800b34 <memfind+0x13>
  800b51:	eb 01                	jmp    800b54 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800b53:	90                   	nop
	return (void *) s;
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b57:	c9                   	leave  
  800b58:	c3                   	ret    

00800b59 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800b5f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800b66:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6d:	eb 03                	jmp    800b72 <strtol+0x19>
		s++;
  800b6f:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	8a 00                	mov    (%eax),%al
  800b77:	3c 20                	cmp    $0x20,%al
  800b79:	74 f4                	je     800b6f <strtol+0x16>
  800b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7e:	8a 00                	mov    (%eax),%al
  800b80:	3c 09                	cmp    $0x9,%al
  800b82:	74 eb                	je     800b6f <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b84:	8b 45 08             	mov    0x8(%ebp),%eax
  800b87:	8a 00                	mov    (%eax),%al
  800b89:	3c 2b                	cmp    $0x2b,%al
  800b8b:	75 05                	jne    800b92 <strtol+0x39>
		s++;
  800b8d:	ff 45 08             	incl   0x8(%ebp)
  800b90:	eb 13                	jmp    800ba5 <strtol+0x4c>
	else if (*s == '-')
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8a 00                	mov    (%eax),%al
  800b97:	3c 2d                	cmp    $0x2d,%al
  800b99:	75 0a                	jne    800ba5 <strtol+0x4c>
		s++, neg = 1;
  800b9b:	ff 45 08             	incl   0x8(%ebp)
  800b9e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ba9:	74 06                	je     800bb1 <strtol+0x58>
  800bab:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800baf:	75 20                	jne    800bd1 <strtol+0x78>
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb4:	8a 00                	mov    (%eax),%al
  800bb6:	3c 30                	cmp    $0x30,%al
  800bb8:	75 17                	jne    800bd1 <strtol+0x78>
  800bba:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbd:	40                   	inc    %eax
  800bbe:	8a 00                	mov    (%eax),%al
  800bc0:	3c 78                	cmp    $0x78,%al
  800bc2:	75 0d                	jne    800bd1 <strtol+0x78>
		s += 2, base = 16;
  800bc4:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800bc8:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800bcf:	eb 28                	jmp    800bf9 <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800bd1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bd5:	75 15                	jne    800bec <strtol+0x93>
  800bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bda:	8a 00                	mov    (%eax),%al
  800bdc:	3c 30                	cmp    $0x30,%al
  800bde:	75 0c                	jne    800bec <strtol+0x93>
		s++, base = 8;
  800be0:	ff 45 08             	incl   0x8(%ebp)
  800be3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800bea:	eb 0d                	jmp    800bf9 <strtol+0xa0>
	else if (base == 0)
  800bec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800bf0:	75 07                	jne    800bf9 <strtol+0xa0>
		base = 10;
  800bf2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfc:	8a 00                	mov    (%eax),%al
  800bfe:	3c 2f                	cmp    $0x2f,%al
  800c00:	7e 19                	jle    800c1b <strtol+0xc2>
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8a 00                	mov    (%eax),%al
  800c07:	3c 39                	cmp    $0x39,%al
  800c09:	7f 10                	jg     800c1b <strtol+0xc2>
			dig = *s - '0';
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	8a 00                	mov    (%eax),%al
  800c10:	0f be c0             	movsbl %al,%eax
  800c13:	83 e8 30             	sub    $0x30,%eax
  800c16:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c19:	eb 42                	jmp    800c5d <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	8a 00                	mov    (%eax),%al
  800c20:	3c 60                	cmp    $0x60,%al
  800c22:	7e 19                	jle    800c3d <strtol+0xe4>
  800c24:	8b 45 08             	mov    0x8(%ebp),%eax
  800c27:	8a 00                	mov    (%eax),%al
  800c29:	3c 7a                	cmp    $0x7a,%al
  800c2b:	7f 10                	jg     800c3d <strtol+0xe4>
			dig = *s - 'a' + 10;
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c30:	8a 00                	mov    (%eax),%al
  800c32:	0f be c0             	movsbl %al,%eax
  800c35:	83 e8 57             	sub    $0x57,%eax
  800c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800c3b:	eb 20                	jmp    800c5d <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800c40:	8a 00                	mov    (%eax),%al
  800c42:	3c 40                	cmp    $0x40,%al
  800c44:	7e 39                	jle    800c7f <strtol+0x126>
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	8a 00                	mov    (%eax),%al
  800c4b:	3c 5a                	cmp    $0x5a,%al
  800c4d:	7f 30                	jg     800c7f <strtol+0x126>
			dig = *s - 'A' + 10;
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8a 00                	mov    (%eax),%al
  800c54:	0f be c0             	movsbl %al,%eax
  800c57:	83 e8 37             	sub    $0x37,%eax
  800c5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c60:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c63:	7d 19                	jge    800c7e <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800c65:	ff 45 08             	incl   0x8(%ebp)
  800c68:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c6b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c6f:	89 c2                	mov    %eax,%edx
  800c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c74:	01 d0                	add    %edx,%eax
  800c76:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800c79:	e9 7b ff ff ff       	jmp    800bf9 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800c7e:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c7f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c83:	74 08                	je     800c8d <strtol+0x134>
		*endptr = (char *) s;
  800c85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c88:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c8d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800c91:	74 07                	je     800c9a <strtol+0x141>
  800c93:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c96:	f7 d8                	neg    %eax
  800c98:	eb 03                	jmp    800c9d <strtol+0x144>
  800c9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800c9d:	c9                   	leave  
  800c9e:	c3                   	ret    

00800c9f <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800ca2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ca5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800cab:	8b 45 14             	mov    0x14(%ebp),%eax
  800cae:	8b 00                	mov    (%eax),%eax
  800cb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800cb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cba:	01 d0                	add    %edx,%eax
  800cbc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800cc2:	eb 0c                	jmp    800cd0 <strsplit+0x31>
			*string++ = 0;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8d 50 01             	lea    0x1(%eax),%edx
  800cca:	89 55 08             	mov    %edx,0x8(%ebp)
  800ccd:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd3:	8a 00                	mov    (%eax),%al
  800cd5:	84 c0                	test   %al,%al
  800cd7:	74 18                	je     800cf1 <strsplit+0x52>
  800cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdc:	8a 00                	mov    (%eax),%al
  800cde:	0f be c0             	movsbl %al,%eax
  800ce1:	50                   	push   %eax
  800ce2:	ff 75 0c             	pushl  0xc(%ebp)
  800ce5:	e8 a1 fc ff ff       	call   80098b <strchr>
  800cea:	83 c4 08             	add    $0x8,%esp
  800ced:	85 c0                	test   %eax,%eax
  800cef:	75 d3                	jne    800cc4 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf4:	8a 00                	mov    (%eax),%al
  800cf6:	84 c0                	test   %al,%al
  800cf8:	74 5a                	je     800d54 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800cfa:	8b 45 14             	mov    0x14(%ebp),%eax
  800cfd:	8b 00                	mov    (%eax),%eax
  800cff:	83 f8 0f             	cmp    $0xf,%eax
  800d02:	75 07                	jne    800d0b <strsplit+0x6c>
		{
			return 0;
  800d04:	b8 00 00 00 00       	mov    $0x0,%eax
  800d09:	eb 66                	jmp    800d71 <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800d0b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0e:	8b 00                	mov    (%eax),%eax
  800d10:	8d 48 01             	lea    0x1(%eax),%ecx
  800d13:	8b 55 14             	mov    0x14(%ebp),%edx
  800d16:	89 0a                	mov    %ecx,(%edx)
  800d18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d22:	01 c2                	add    %eax,%edx
  800d24:	8b 45 08             	mov    0x8(%ebp),%eax
  800d27:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800d29:	eb 03                	jmp    800d2e <strsplit+0x8f>
			string++;
  800d2b:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	8a 00                	mov    (%eax),%al
  800d33:	84 c0                	test   %al,%al
  800d35:	74 8b                	je     800cc2 <strsplit+0x23>
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8a 00                	mov    (%eax),%al
  800d3c:	0f be c0             	movsbl %al,%eax
  800d3f:	50                   	push   %eax
  800d40:	ff 75 0c             	pushl  0xc(%ebp)
  800d43:	e8 43 fc ff ff       	call   80098b <strchr>
  800d48:	83 c4 08             	add    $0x8,%esp
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	74 dc                	je     800d2b <strsplit+0x8c>
			string++;
	}
  800d4f:	e9 6e ff ff ff       	jmp    800cc2 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800d54:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800d55:	8b 45 14             	mov    0x14(%ebp),%eax
  800d58:	8b 00                	mov    (%eax),%eax
  800d5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800d61:	8b 45 10             	mov    0x10(%ebp),%eax
  800d64:	01 d0                	add    %edx,%eax
  800d66:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800d6c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800d85:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800d88:	8b 7d 18             	mov    0x18(%ebp),%edi
  800d8b:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800d8e:	cd 30                	int    $0x30
  800d90:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800d93:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	6a 00                	push   $0x0
  800da6:	6a 00                	push   $0x0
  800da8:	6a 00                	push   $0x0
  800daa:	ff 75 0c             	pushl  0xc(%ebp)
  800dad:	50                   	push   %eax
  800dae:	6a 00                	push   $0x0
  800db0:	e8 be ff ff ff       	call   800d73 <syscall>
  800db5:	83 c4 18             	add    $0x18,%esp
}
  800db8:	90                   	nop
  800db9:	c9                   	leave  
  800dba:	c3                   	ret    

00800dbb <sys_cgetc>:

int
sys_cgetc(void)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800dbe:	6a 00                	push   $0x0
  800dc0:	6a 00                	push   $0x0
  800dc2:	6a 00                	push   $0x0
  800dc4:	6a 00                	push   $0x0
  800dc6:	6a 00                	push   $0x0
  800dc8:	6a 01                	push   $0x1
  800dca:	e8 a4 ff ff ff       	call   800d73 <syscall>
  800dcf:	83 c4 18             	add    $0x18,%esp
}
  800dd2:	c9                   	leave  
  800dd3:	c3                   	ret    

00800dd4 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	6a 00                	push   $0x0
  800de2:	50                   	push   %eax
  800de3:	6a 03                	push   $0x3
  800de5:	e8 89 ff ff ff       	call   800d73 <syscall>
  800dea:	83 c4 18             	add    $0x18,%esp
}
  800ded:	c9                   	leave  
  800dee:	c3                   	ret    

00800def <sys_getenvid>:

int32 sys_getenvid(void)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800df2:	6a 00                	push   $0x0
  800df4:	6a 00                	push   $0x0
  800df6:	6a 00                	push   $0x0
  800df8:	6a 00                	push   $0x0
  800dfa:	6a 00                	push   $0x0
  800dfc:	6a 02                	push   $0x2
  800dfe:	e8 70 ff ff ff       	call   800d73 <syscall>
  800e03:	83 c4 18             	add    $0x18,%esp
}
  800e06:	c9                   	leave  
  800e07:	c3                   	ret    

00800e08 <sys_env_sleep>:

void sys_env_sleep(void)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800e0b:	6a 00                	push   $0x0
  800e0d:	6a 00                	push   $0x0
  800e0f:	6a 00                	push   $0x0
  800e11:	6a 00                	push   $0x0
  800e13:	6a 00                	push   $0x0
  800e15:	6a 04                	push   $0x4
  800e17:	e8 57 ff ff ff       	call   800d73 <syscall>
  800e1c:	83 c4 18             	add    $0x18,%esp
}
  800e1f:	90                   	nop
  800e20:	c9                   	leave  
  800e21:	c3                   	ret    

00800e22 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800e25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	6a 00                	push   $0x0
  800e2d:	6a 00                	push   $0x0
  800e2f:	6a 00                	push   $0x0
  800e31:	52                   	push   %edx
  800e32:	50                   	push   %eax
  800e33:	6a 05                	push   $0x5
  800e35:	e8 39 ff ff ff       	call   800d73 <syscall>
  800e3a:	83 c4 18             	add    $0x18,%esp
}
  800e3d:	c9                   	leave  
  800e3e:	c3                   	ret    

00800e3f <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	6a 00                	push   $0x0
  800e4a:	6a 00                	push   $0x0
  800e4c:	6a 00                	push   $0x0
  800e4e:	52                   	push   %edx
  800e4f:	50                   	push   %eax
  800e50:	6a 06                	push   $0x6
  800e52:	e8 1c ff ff ff       	call   800d73 <syscall>
  800e57:	83 c4 18             	add    $0x18,%esp
}
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800e61:	8b 75 18             	mov    0x18(%ebp),%esi
  800e64:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e67:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e70:	56                   	push   %esi
  800e71:	53                   	push   %ebx
  800e72:	51                   	push   %ecx
  800e73:	52                   	push   %edx
  800e74:	50                   	push   %eax
  800e75:	6a 07                	push   $0x7
  800e77:	e8 f7 fe ff ff       	call   800d73 <syscall>
  800e7c:	83 c4 18             	add    $0x18,%esp
}
  800e7f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5e                   	pop    %esi
  800e84:	5d                   	pop    %ebp
  800e85:	c3                   	ret    

00800e86 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800e86:	55                   	push   %ebp
  800e87:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  800e89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	6a 00                	push   $0x0
  800e91:	6a 00                	push   $0x0
  800e93:	6a 00                	push   $0x0
  800e95:	52                   	push   %edx
  800e96:	50                   	push   %eax
  800e97:	6a 08                	push   $0x8
  800e99:	e8 d5 fe ff ff       	call   800d73 <syscall>
  800e9e:	83 c4 18             	add    $0x18,%esp
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  800ea6:	6a 00                	push   $0x0
  800ea8:	6a 00                	push   $0x0
  800eaa:	6a 00                	push   $0x0
  800eac:	ff 75 0c             	pushl  0xc(%ebp)
  800eaf:	ff 75 08             	pushl  0x8(%ebp)
  800eb2:	6a 09                	push   $0x9
  800eb4:	e8 ba fe ff ff       	call   800d73 <syscall>
  800eb9:	83 c4 18             	add    $0x18,%esp
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  800ec1:	6a 00                	push   $0x0
  800ec3:	6a 00                	push   $0x0
  800ec5:	6a 00                	push   $0x0
  800ec7:	6a 00                	push   $0x0
  800ec9:	6a 00                	push   $0x0
  800ecb:	6a 0a                	push   $0xa
  800ecd:	e8 a1 fe ff ff       	call   800d73 <syscall>
  800ed2:	83 c4 18             	add    $0x18,%esp
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  800eda:	8b 45 08             	mov    0x8(%ebp),%eax
  800edd:	6a 00                	push   $0x0
  800edf:	6a 00                	push   $0x0
  800ee1:	6a 00                	push   $0x0
  800ee3:	ff 75 0c             	pushl  0xc(%ebp)
  800ee6:	50                   	push   %eax
  800ee7:	6a 0b                	push   $0xb
  800ee9:	e8 85 fe ff ff       	call   800d73 <syscall>
  800eee:	83 c4 18             	add    $0x18,%esp
	return;
  800ef1:	90                   	nop
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <__udivdi3>:
  800ef4:	55                   	push   %ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 1c             	sub    $0x1c,%esp
  800efb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800eff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800f03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f07:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f0b:	89 ca                	mov    %ecx,%edx
  800f0d:	89 f8                	mov    %edi,%eax
  800f0f:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800f13:	85 f6                	test   %esi,%esi
  800f15:	75 2d                	jne    800f44 <__udivdi3+0x50>
  800f17:	39 cf                	cmp    %ecx,%edi
  800f19:	77 65                	ja     800f80 <__udivdi3+0x8c>
  800f1b:	89 fd                	mov    %edi,%ebp
  800f1d:	85 ff                	test   %edi,%edi
  800f1f:	75 0b                	jne    800f2c <__udivdi3+0x38>
  800f21:	b8 01 00 00 00       	mov    $0x1,%eax
  800f26:	31 d2                	xor    %edx,%edx
  800f28:	f7 f7                	div    %edi
  800f2a:	89 c5                	mov    %eax,%ebp
  800f2c:	31 d2                	xor    %edx,%edx
  800f2e:	89 c8                	mov    %ecx,%eax
  800f30:	f7 f5                	div    %ebp
  800f32:	89 c1                	mov    %eax,%ecx
  800f34:	89 d8                	mov    %ebx,%eax
  800f36:	f7 f5                	div    %ebp
  800f38:	89 cf                	mov    %ecx,%edi
  800f3a:	89 fa                	mov    %edi,%edx
  800f3c:	83 c4 1c             	add    $0x1c,%esp
  800f3f:	5b                   	pop    %ebx
  800f40:	5e                   	pop    %esi
  800f41:	5f                   	pop    %edi
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    
  800f44:	39 ce                	cmp    %ecx,%esi
  800f46:	77 28                	ja     800f70 <__udivdi3+0x7c>
  800f48:	0f bd fe             	bsr    %esi,%edi
  800f4b:	83 f7 1f             	xor    $0x1f,%edi
  800f4e:	75 40                	jne    800f90 <__udivdi3+0x9c>
  800f50:	39 ce                	cmp    %ecx,%esi
  800f52:	72 0a                	jb     800f5e <__udivdi3+0x6a>
  800f54:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f58:	0f 87 9e 00 00 00    	ja     800ffc <__udivdi3+0x108>
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	89 fa                	mov    %edi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	31 ff                	xor    %edi,%edi
  800f72:	31 c0                	xor    %eax,%eax
  800f74:	89 fa                	mov    %edi,%edx
  800f76:	83 c4 1c             	add    $0x1c,%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5f                   	pop    %edi
  800f7c:	5d                   	pop    %ebp
  800f7d:	c3                   	ret    
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	f7 f7                	div    %edi
  800f84:	31 ff                	xor    %edi,%edi
  800f86:	89 fa                	mov    %edi,%edx
  800f88:	83 c4 1c             	add    $0x1c,%esp
  800f8b:	5b                   	pop    %ebx
  800f8c:	5e                   	pop    %esi
  800f8d:	5f                   	pop    %edi
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    
  800f90:	bd 20 00 00 00       	mov    $0x20,%ebp
  800f95:	89 eb                	mov    %ebp,%ebx
  800f97:	29 fb                	sub    %edi,%ebx
  800f99:	89 f9                	mov    %edi,%ecx
  800f9b:	d3 e6                	shl    %cl,%esi
  800f9d:	89 c5                	mov    %eax,%ebp
  800f9f:	88 d9                	mov    %bl,%cl
  800fa1:	d3 ed                	shr    %cl,%ebp
  800fa3:	89 e9                	mov    %ebp,%ecx
  800fa5:	09 f1                	or     %esi,%ecx
  800fa7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800fab:	89 f9                	mov    %edi,%ecx
  800fad:	d3 e0                	shl    %cl,%eax
  800faf:	89 c5                	mov    %eax,%ebp
  800fb1:	89 d6                	mov    %edx,%esi
  800fb3:	88 d9                	mov    %bl,%cl
  800fb5:	d3 ee                	shr    %cl,%esi
  800fb7:	89 f9                	mov    %edi,%ecx
  800fb9:	d3 e2                	shl    %cl,%edx
  800fbb:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fbf:	88 d9                	mov    %bl,%cl
  800fc1:	d3 e8                	shr    %cl,%eax
  800fc3:	09 c2                	or     %eax,%edx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	89 f2                	mov    %esi,%edx
  800fc9:	f7 74 24 0c          	divl   0xc(%esp)
  800fcd:	89 d6                	mov    %edx,%esi
  800fcf:	89 c3                	mov    %eax,%ebx
  800fd1:	f7 e5                	mul    %ebp
  800fd3:	39 d6                	cmp    %edx,%esi
  800fd5:	72 19                	jb     800ff0 <__udivdi3+0xfc>
  800fd7:	74 0b                	je     800fe4 <__udivdi3+0xf0>
  800fd9:	89 d8                	mov    %ebx,%eax
  800fdb:	31 ff                	xor    %edi,%edi
  800fdd:	e9 58 ff ff ff       	jmp    800f3a <__udivdi3+0x46>
  800fe2:	66 90                	xchg   %ax,%ax
  800fe4:	8b 54 24 08          	mov    0x8(%esp),%edx
  800fe8:	89 f9                	mov    %edi,%ecx
  800fea:	d3 e2                	shl    %cl,%edx
  800fec:	39 c2                	cmp    %eax,%edx
  800fee:	73 e9                	jae    800fd9 <__udivdi3+0xe5>
  800ff0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ff3:	31 ff                	xor    %edi,%edi
  800ff5:	e9 40 ff ff ff       	jmp    800f3a <__udivdi3+0x46>
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	31 c0                	xor    %eax,%eax
  800ffe:	e9 37 ff ff ff       	jmp    800f3a <__udivdi3+0x46>
  801003:	90                   	nop

00801004 <__umoddi3>:
  801004:	55                   	push   %ebp
  801005:	57                   	push   %edi
  801006:	56                   	push   %esi
  801007:	53                   	push   %ebx
  801008:	83 ec 1c             	sub    $0x1c,%esp
  80100b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80100f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801017:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80101b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80101f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801023:	89 f3                	mov    %esi,%ebx
  801025:	89 fa                	mov    %edi,%edx
  801027:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80102b:	89 34 24             	mov    %esi,(%esp)
  80102e:	85 c0                	test   %eax,%eax
  801030:	75 1a                	jne    80104c <__umoddi3+0x48>
  801032:	39 f7                	cmp    %esi,%edi
  801034:	0f 86 a2 00 00 00    	jbe    8010dc <__umoddi3+0xd8>
  80103a:	89 c8                	mov    %ecx,%eax
  80103c:	89 f2                	mov    %esi,%edx
  80103e:	f7 f7                	div    %edi
  801040:	89 d0                	mov    %edx,%eax
  801042:	31 d2                	xor    %edx,%edx
  801044:	83 c4 1c             	add    $0x1c,%esp
  801047:	5b                   	pop    %ebx
  801048:	5e                   	pop    %esi
  801049:	5f                   	pop    %edi
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    
  80104c:	39 f0                	cmp    %esi,%eax
  80104e:	0f 87 ac 00 00 00    	ja     801100 <__umoddi3+0xfc>
  801054:	0f bd e8             	bsr    %eax,%ebp
  801057:	83 f5 1f             	xor    $0x1f,%ebp
  80105a:	0f 84 ac 00 00 00    	je     80110c <__umoddi3+0x108>
  801060:	bf 20 00 00 00       	mov    $0x20,%edi
  801065:	29 ef                	sub    %ebp,%edi
  801067:	89 fe                	mov    %edi,%esi
  801069:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80106d:	89 e9                	mov    %ebp,%ecx
  80106f:	d3 e0                	shl    %cl,%eax
  801071:	89 d7                	mov    %edx,%edi
  801073:	89 f1                	mov    %esi,%ecx
  801075:	d3 ef                	shr    %cl,%edi
  801077:	09 c7                	or     %eax,%edi
  801079:	89 e9                	mov    %ebp,%ecx
  80107b:	d3 e2                	shl    %cl,%edx
  80107d:	89 14 24             	mov    %edx,(%esp)
  801080:	89 d8                	mov    %ebx,%eax
  801082:	d3 e0                	shl    %cl,%eax
  801084:	89 c2                	mov    %eax,%edx
  801086:	8b 44 24 08          	mov    0x8(%esp),%eax
  80108a:	d3 e0                	shl    %cl,%eax
  80108c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801090:	8b 44 24 08          	mov    0x8(%esp),%eax
  801094:	89 f1                	mov    %esi,%ecx
  801096:	d3 e8                	shr    %cl,%eax
  801098:	09 d0                	or     %edx,%eax
  80109a:	d3 eb                	shr    %cl,%ebx
  80109c:	89 da                	mov    %ebx,%edx
  80109e:	f7 f7                	div    %edi
  8010a0:	89 d3                	mov    %edx,%ebx
  8010a2:	f7 24 24             	mull   (%esp)
  8010a5:	89 c6                	mov    %eax,%esi
  8010a7:	89 d1                	mov    %edx,%ecx
  8010a9:	39 d3                	cmp    %edx,%ebx
  8010ab:	0f 82 87 00 00 00    	jb     801138 <__umoddi3+0x134>
  8010b1:	0f 84 91 00 00 00    	je     801148 <__umoddi3+0x144>
  8010b7:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010bb:	29 f2                	sub    %esi,%edx
  8010bd:	19 cb                	sbb    %ecx,%ebx
  8010bf:	89 d8                	mov    %ebx,%eax
  8010c1:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8010c5:	d3 e0                	shl    %cl,%eax
  8010c7:	89 e9                	mov    %ebp,%ecx
  8010c9:	d3 ea                	shr    %cl,%edx
  8010cb:	09 d0                	or     %edx,%eax
  8010cd:	89 e9                	mov    %ebp,%ecx
  8010cf:	d3 eb                	shr    %cl,%ebx
  8010d1:	89 da                	mov    %ebx,%edx
  8010d3:	83 c4 1c             	add    $0x1c,%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    
  8010db:	90                   	nop
  8010dc:	89 fd                	mov    %edi,%ebp
  8010de:	85 ff                	test   %edi,%edi
  8010e0:	75 0b                	jne    8010ed <__umoddi3+0xe9>
  8010e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e7:	31 d2                	xor    %edx,%edx
  8010e9:	f7 f7                	div    %edi
  8010eb:	89 c5                	mov    %eax,%ebp
  8010ed:	89 f0                	mov    %esi,%eax
  8010ef:	31 d2                	xor    %edx,%edx
  8010f1:	f7 f5                	div    %ebp
  8010f3:	89 c8                	mov    %ecx,%eax
  8010f5:	f7 f5                	div    %ebp
  8010f7:	89 d0                	mov    %edx,%eax
  8010f9:	e9 44 ff ff ff       	jmp    801042 <__umoddi3+0x3e>
  8010fe:	66 90                	xchg   %ax,%ax
  801100:	89 c8                	mov    %ecx,%eax
  801102:	89 f2                	mov    %esi,%edx
  801104:	83 c4 1c             	add    $0x1c,%esp
  801107:	5b                   	pop    %ebx
  801108:	5e                   	pop    %esi
  801109:	5f                   	pop    %edi
  80110a:	5d                   	pop    %ebp
  80110b:	c3                   	ret    
  80110c:	3b 04 24             	cmp    (%esp),%eax
  80110f:	72 06                	jb     801117 <__umoddi3+0x113>
  801111:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801115:	77 0f                	ja     801126 <__umoddi3+0x122>
  801117:	89 f2                	mov    %esi,%edx
  801119:	29 f9                	sub    %edi,%ecx
  80111b:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80111f:	89 14 24             	mov    %edx,(%esp)
  801122:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801126:	8b 44 24 04          	mov    0x4(%esp),%eax
  80112a:	8b 14 24             	mov    (%esp),%edx
  80112d:	83 c4 1c             	add    $0x1c,%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    
  801135:	8d 76 00             	lea    0x0(%esi),%esi
  801138:	2b 04 24             	sub    (%esp),%eax
  80113b:	19 fa                	sbb    %edi,%edx
  80113d:	89 d1                	mov    %edx,%ecx
  80113f:	89 c6                	mov    %eax,%esi
  801141:	e9 71 ff ff ff       	jmp    8010b7 <__umoddi3+0xb3>
  801146:	66 90                	xchg   %ax,%ax
  801148:	39 44 24 04          	cmp    %eax,0x4(%esp)
  80114c:	72 ea                	jb     801138 <__umoddi3+0x134>
  80114e:	89 d9                	mov    %ebx,%ecx
  801150:	e9 62 ff ff ff       	jmp    8010b7 <__umoddi3+0xb3>
