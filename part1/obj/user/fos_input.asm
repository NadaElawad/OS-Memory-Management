
obj/user/fos_input:     file format elf32-i386


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
  800031:	e8 95 00 00 00       	call   8000cb <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:

#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	81 ec 18 02 00 00    	sub    $0x218,%esp
	int i1=0;
  800041:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int i2=0;
  800048:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	char buff1[256];
	char buff2[256];	
	
	readline("Please enter first number :", buff1);	
  80004f:	83 ec 08             	sub    $0x8,%esp
  800052:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800058:	50                   	push   %eax
  800059:	68 e0 12 80 00       	push   $0x8012e0
  80005e:	e8 cb 07 00 00       	call   80082e <readline>
  800063:	83 c4 10             	add    $0x10,%esp
	i1 = strtol(buff1, NULL, 10);
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	6a 0a                	push   $0xa
  80006b:	6a 00                	push   $0x0
  80006d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800073:	50                   	push   %eax
  800074:	e8 13 0c 00 00       	call   800c8c <strtol>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	readline("Please enter second number :", buff2);
  80007f:	83 ec 08             	sub    $0x8,%esp
  800082:	8d 85 f0 fd ff ff    	lea    -0x210(%ebp),%eax
  800088:	50                   	push   %eax
  800089:	68 fc 12 80 00       	push   $0x8012fc
  80008e:	e8 9b 07 00 00       	call   80082e <readline>
  800093:	83 c4 10             	add    $0x10,%esp
	
	i2 = strtol(buff2, NULL, 10);
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	6a 0a                	push   $0xa
  80009b:	6a 00                	push   $0x0
  80009d:	8d 85 f0 fd ff ff    	lea    -0x210(%ebp),%eax
  8000a3:	50                   	push   %eax
  8000a4:	e8 e3 0b 00 00       	call   800c8c <strtol>
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	89 45 f0             	mov    %eax,-0x10(%ebp)

	cprintf("number 1 + number 2 = %d\n",i1+i2);
  8000af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8000b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8000b5:	01 d0                	add    %edx,%eax
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	50                   	push   %eax
  8000bb:	68 19 13 80 00       	push   $0x801319
  8000c0:	e8 1e 01 00 00       	call   8001e3 <cprintf>
  8000c5:	83 c4 10             	add    $0x10,%esp
	return;	
  8000c8:	90                   	nop
}
  8000c9:	c9                   	leave  
  8000ca:	c3                   	ret    

008000cb <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8000d1:	c7 05 04 20 80 00 00 	movl   $0xeec00000,0x802004
  8000d8:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8000df:	7e 0a                	jle    8000eb <libmain+0x20>
		binaryname = argv[0];
  8000e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e4:	8b 00                	mov    (%eax),%eax
  8000e6:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	ff 75 0c             	pushl  0xc(%ebp)
  8000f1:	ff 75 08             	pushl  0x8(%ebp)
  8000f4:	e8 3f ff ff ff       	call   800038 <_main>
  8000f9:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  8000fc:	e8 19 00 00 00       	call   80011a <sleep>
}
  800101:	90                   	nop
  800102:	c9                   	leave  
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  80010a:	83 ec 0c             	sub    $0xc,%esp
  80010d:	6a 00                	push   $0x0
  80010f:	e8 f3 0d 00 00       	call   800f07 <sys_env_destroy>
  800114:	83 c4 10             	add    $0x10,%esp
}
  800117:	90                   	nop
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <sleep>:

void
sleep(void)
{	
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  800120:	e8 16 0e 00 00       	call   800f3b <sys_env_sleep>
}
  800125:	90                   	nop
  800126:	c9                   	leave  
  800127:	c3                   	ret    

00800128 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80012e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800131:	8b 00                	mov    (%eax),%eax
  800133:	8d 48 01             	lea    0x1(%eax),%ecx
  800136:	8b 55 0c             	mov    0xc(%ebp),%edx
  800139:	89 0a                	mov    %ecx,(%edx)
  80013b:	8b 55 08             	mov    0x8(%ebp),%edx
  80013e:	88 d1                	mov    %dl,%cl
  800140:	8b 55 0c             	mov    0xc(%ebp),%edx
  800143:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800147:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014a:	8b 00                	mov    (%eax),%eax
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	75 23                	jne    800176 <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  800153:	8b 45 0c             	mov    0xc(%ebp),%eax
  800156:	8b 00                	mov    (%eax),%eax
  800158:	89 c2                	mov    %eax,%edx
  80015a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015d:	83 c0 08             	add    $0x8,%eax
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	e8 67 0d 00 00       	call   800ed1 <sys_cputs>
  80016a:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  80016d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800170:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800176:	8b 45 0c             	mov    0xc(%ebp),%eax
  800179:	8b 40 04             	mov    0x4(%eax),%eax
  80017c:	8d 50 01             	lea    0x1(%eax),%edx
  80017f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800182:	89 50 04             	mov    %edx,0x4(%eax)
}
  800185:	90                   	nop
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800191:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800198:	00 00 00 
	b.cnt = 0;
  80019b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a5:	ff 75 0c             	pushl  0xc(%ebp)
  8001a8:	ff 75 08             	pushl  0x8(%ebp)
  8001ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b1:	50                   	push   %eax
  8001b2:	68 28 01 80 00       	push   $0x800128
  8001b7:	e8 ca 01 00 00       	call   800386 <vprintfmt>
  8001bc:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  8001bf:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001c5:	83 ec 08             	sub    $0x8,%esp
  8001c8:	50                   	push   %eax
  8001c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001cf:	83 c0 08             	add    $0x8,%eax
  8001d2:	50                   	push   %eax
  8001d3:	e8 f9 0c 00 00       	call   800ed1 <sys_cputs>
  8001d8:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  8001db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8001e1:	c9                   	leave  
  8001e2:	c3                   	ret    

008001e3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e9:	8d 45 0c             	lea    0xc(%ebp),%eax
  8001ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  8001ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f2:	83 ec 08             	sub    $0x8,%esp
  8001f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8001f8:	50                   	push   %eax
  8001f9:	e8 8a ff ff ff       	call   800188 <vcprintf>
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800204:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	53                   	push   %ebx
  80020d:	83 ec 14             	sub    $0x14,%esp
  800210:	8b 45 10             	mov    0x10(%ebp),%eax
  800213:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800216:	8b 45 14             	mov    0x14(%ebp),%eax
  800219:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021c:	8b 45 18             	mov    0x18(%ebp),%eax
  80021f:	ba 00 00 00 00       	mov    $0x0,%edx
  800224:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800227:	77 55                	ja     80027e <printnum+0x75>
  800229:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80022c:	72 05                	jb     800233 <printnum+0x2a>
  80022e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800231:	77 4b                	ja     80027e <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800233:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800236:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800239:	8b 45 18             	mov    0x18(%ebp),%eax
  80023c:	ba 00 00 00 00       	mov    $0x0,%edx
  800241:	52                   	push   %edx
  800242:	50                   	push   %eax
  800243:	ff 75 f4             	pushl  -0xc(%ebp)
  800246:	ff 75 f0             	pushl  -0x10(%ebp)
  800249:	e8 12 0e 00 00       	call   801060 <__udivdi3>
  80024e:	83 c4 10             	add    $0x10,%esp
  800251:	83 ec 04             	sub    $0x4,%esp
  800254:	ff 75 20             	pushl  0x20(%ebp)
  800257:	53                   	push   %ebx
  800258:	ff 75 18             	pushl  0x18(%ebp)
  80025b:	52                   	push   %edx
  80025c:	50                   	push   %eax
  80025d:	ff 75 0c             	pushl  0xc(%ebp)
  800260:	ff 75 08             	pushl  0x8(%ebp)
  800263:	e8 a1 ff ff ff       	call   800209 <printnum>
  800268:	83 c4 20             	add    $0x20,%esp
  80026b:	eb 1a                	jmp    800287 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026d:	83 ec 08             	sub    $0x8,%esp
  800270:	ff 75 0c             	pushl  0xc(%ebp)
  800273:	ff 75 20             	pushl  0x20(%ebp)
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	ff d0                	call   *%eax
  80027b:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027e:	ff 4d 1c             	decl   0x1c(%ebp)
  800281:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800285:	7f e6                	jg     80026d <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800287:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80028a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800295:	53                   	push   %ebx
  800296:	51                   	push   %ecx
  800297:	52                   	push   %edx
  800298:	50                   	push   %eax
  800299:	e8 d2 0e 00 00       	call   801170 <__umoddi3>
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	05 00 14 80 00       	add    $0x801400,%eax
  8002a6:	8a 00                	mov    (%eax),%al
  8002a8:	0f be c0             	movsbl %al,%eax
  8002ab:	83 ec 08             	sub    $0x8,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	50                   	push   %eax
  8002b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b5:	ff d0                	call   *%eax
  8002b7:	83 c4 10             	add    $0x10,%esp
}
  8002ba:	90                   	nop
  8002bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c3:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8002c7:	7e 1c                	jle    8002e5 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	8b 00                	mov    (%eax),%eax
  8002ce:	8d 50 08             	lea    0x8(%eax),%edx
  8002d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d4:	89 10                	mov    %edx,(%eax)
  8002d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d9:	8b 00                	mov    (%eax),%eax
  8002db:	83 e8 08             	sub    $0x8,%eax
  8002de:	8b 50 04             	mov    0x4(%eax),%edx
  8002e1:	8b 00                	mov    (%eax),%eax
  8002e3:	eb 40                	jmp    800325 <getuint+0x65>
	else if (lflag)
  8002e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8002e9:	74 1e                	je     800309 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  8002eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ee:	8b 00                	mov    (%eax),%eax
  8002f0:	8d 50 04             	lea    0x4(%eax),%edx
  8002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f6:	89 10                	mov    %edx,(%eax)
  8002f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fb:	8b 00                	mov    (%eax),%eax
  8002fd:	83 e8 04             	sub    $0x4,%eax
  800300:	8b 00                	mov    (%eax),%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	eb 1c                	jmp    800325 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800309:	8b 45 08             	mov    0x8(%ebp),%eax
  80030c:	8b 00                	mov    (%eax),%eax
  80030e:	8d 50 04             	lea    0x4(%eax),%edx
  800311:	8b 45 08             	mov    0x8(%ebp),%eax
  800314:	89 10                	mov    %edx,(%eax)
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	8b 00                	mov    (%eax),%eax
  80031b:	83 e8 04             	sub    $0x4,%eax
  80031e:	8b 00                	mov    (%eax),%eax
  800320:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800325:	5d                   	pop    %ebp
  800326:	c3                   	ret    

00800327 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80032a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80032e:	7e 1c                	jle    80034c <getint+0x25>
		return va_arg(*ap, long long);
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 00                	mov    (%eax),%eax
  800335:	8d 50 08             	lea    0x8(%eax),%edx
  800338:	8b 45 08             	mov    0x8(%ebp),%eax
  80033b:	89 10                	mov    %edx,(%eax)
  80033d:	8b 45 08             	mov    0x8(%ebp),%eax
  800340:	8b 00                	mov    (%eax),%eax
  800342:	83 e8 08             	sub    $0x8,%eax
  800345:	8b 50 04             	mov    0x4(%eax),%edx
  800348:	8b 00                	mov    (%eax),%eax
  80034a:	eb 38                	jmp    800384 <getint+0x5d>
	else if (lflag)
  80034c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800350:	74 1a                	je     80036c <getint+0x45>
		return va_arg(*ap, long);
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	8b 00                	mov    (%eax),%eax
  800357:	8d 50 04             	lea    0x4(%eax),%edx
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	89 10                	mov    %edx,(%eax)
  80035f:	8b 45 08             	mov    0x8(%ebp),%eax
  800362:	8b 00                	mov    (%eax),%eax
  800364:	83 e8 04             	sub    $0x4,%eax
  800367:	8b 00                	mov    (%eax),%eax
  800369:	99                   	cltd   
  80036a:	eb 18                	jmp    800384 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	8b 00                	mov    (%eax),%eax
  800371:	8d 50 04             	lea    0x4(%eax),%edx
  800374:	8b 45 08             	mov    0x8(%ebp),%eax
  800377:	89 10                	mov    %edx,(%eax)
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	83 e8 04             	sub    $0x4,%eax
  800381:	8b 00                	mov    (%eax),%eax
  800383:	99                   	cltd   
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038e:	eb 17                	jmp    8003a7 <vprintfmt+0x21>
			if (ch == '\0')
  800390:	85 db                	test   %ebx,%ebx
  800392:	0f 84 af 03 00 00    	je     800747 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	ff 75 0c             	pushl  0xc(%ebp)
  80039e:	53                   	push   %ebx
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a2:	ff d0                	call   *%eax
  8003a4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8003aa:	8d 50 01             	lea    0x1(%eax),%edx
  8003ad:	89 55 10             	mov    %edx,0x10(%ebp)
  8003b0:	8a 00                	mov    (%eax),%al
  8003b2:	0f b6 d8             	movzbl %al,%ebx
  8003b5:	83 fb 25             	cmp    $0x25,%ebx
  8003b8:	75 d6                	jne    800390 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8003ba:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8003be:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8003c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003cc:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  8003d3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	8b 45 10             	mov    0x10(%ebp),%eax
  8003dd:	8d 50 01             	lea    0x1(%eax),%edx
  8003e0:	89 55 10             	mov    %edx,0x10(%ebp)
  8003e3:	8a 00                	mov    (%eax),%al
  8003e5:	0f b6 d8             	movzbl %al,%ebx
  8003e8:	8d 43 dd             	lea    -0x23(%ebx),%eax
  8003eb:	83 f8 55             	cmp    $0x55,%eax
  8003ee:	0f 87 2b 03 00 00    	ja     80071f <vprintfmt+0x399>
  8003f4:	8b 04 85 24 14 80 00 	mov    0x801424(,%eax,4),%eax
  8003fb:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fd:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800401:	eb d7                	jmp    8003da <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800403:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800407:	eb d1                	jmp    8003da <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800409:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800410:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800413:	89 d0                	mov    %edx,%eax
  800415:	c1 e0 02             	shl    $0x2,%eax
  800418:	01 d0                	add    %edx,%eax
  80041a:	01 c0                	add    %eax,%eax
  80041c:	01 d8                	add    %ebx,%eax
  80041e:	83 e8 30             	sub    $0x30,%eax
  800421:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800424:	8b 45 10             	mov    0x10(%ebp),%eax
  800427:	8a 00                	mov    (%eax),%al
  800429:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80042c:	83 fb 2f             	cmp    $0x2f,%ebx
  80042f:	7e 3e                	jle    80046f <vprintfmt+0xe9>
  800431:	83 fb 39             	cmp    $0x39,%ebx
  800434:	7f 39                	jg     80046f <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800436:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800439:	eb d5                	jmp    800410 <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80043b:	8b 45 14             	mov    0x14(%ebp),%eax
  80043e:	83 c0 04             	add    $0x4,%eax
  800441:	89 45 14             	mov    %eax,0x14(%ebp)
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	83 e8 04             	sub    $0x4,%eax
  80044a:	8b 00                	mov    (%eax),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80044f:	eb 1f                	jmp    800470 <vprintfmt+0xea>

		case '.':
			if (width < 0)
  800451:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800455:	79 83                	jns    8003da <vprintfmt+0x54>
				width = 0;
  800457:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80045e:	e9 77 ff ff ff       	jmp    8003da <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800463:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046a:	e9 6b ff ff ff       	jmp    8003da <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80046f:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800470:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800474:	0f 89 60 ff ff ff    	jns    8003da <vprintfmt+0x54>
				width = precision, precision = -1;
  80047a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80047d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800480:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  800487:	e9 4e ff ff ff       	jmp    8003da <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048c:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  80048f:	e9 46 ff ff ff       	jmp    8003da <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800494:	8b 45 14             	mov    0x14(%ebp),%eax
  800497:	83 c0 04             	add    $0x4,%eax
  80049a:	89 45 14             	mov    %eax,0x14(%ebp)
  80049d:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a0:	83 e8 04             	sub    $0x4,%eax
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 0c             	pushl  0xc(%ebp)
  8004ab:	50                   	push   %eax
  8004ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8004af:	ff d0                	call   *%eax
  8004b1:	83 c4 10             	add    $0x10,%esp
			break;
  8004b4:	e9 89 02 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	83 c0 04             	add    $0x4,%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	83 e8 04             	sub    $0x4,%eax
  8004c8:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8004ca:	85 db                	test   %ebx,%ebx
  8004cc:	79 02                	jns    8004d0 <vprintfmt+0x14a>
				err = -err;
  8004ce:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8004d0:	83 fb 07             	cmp    $0x7,%ebx
  8004d3:	7f 0b                	jg     8004e0 <vprintfmt+0x15a>
  8004d5:	8b 34 9d e0 13 80 00 	mov    0x8013e0(,%ebx,4),%esi
  8004dc:	85 f6                	test   %esi,%esi
  8004de:	75 19                	jne    8004f9 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  8004e0:	53                   	push   %ebx
  8004e1:	68 11 14 80 00       	push   $0x801411
  8004e6:	ff 75 0c             	pushl  0xc(%ebp)
  8004e9:	ff 75 08             	pushl  0x8(%ebp)
  8004ec:	e8 5e 02 00 00       	call   80074f <printfmt>
  8004f1:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  8004f4:	e9 49 02 00 00       	jmp    800742 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f9:	56                   	push   %esi
  8004fa:	68 1a 14 80 00       	push   $0x80141a
  8004ff:	ff 75 0c             	pushl  0xc(%ebp)
  800502:	ff 75 08             	pushl  0x8(%ebp)
  800505:	e8 45 02 00 00       	call   80074f <printfmt>
  80050a:	83 c4 10             	add    $0x10,%esp
			break;
  80050d:	e9 30 02 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	83 c0 04             	add    $0x4,%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	83 e8 04             	sub    $0x4,%eax
  800521:	8b 30                	mov    (%eax),%esi
  800523:	85 f6                	test   %esi,%esi
  800525:	75 05                	jne    80052c <vprintfmt+0x1a6>
				p = "(null)";
  800527:	be 1d 14 80 00       	mov    $0x80141d,%esi
			if (width > 0 && padc != '-')
  80052c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800530:	7e 6d                	jle    80059f <vprintfmt+0x219>
  800532:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800536:	74 67                	je     80059f <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800538:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	50                   	push   %eax
  80053f:	56                   	push   %esi
  800540:	e8 0a 04 00 00       	call   80094f <strnlen>
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80054b:	eb 16                	jmp    800563 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80054d:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	50                   	push   %eax
  800558:	8b 45 08             	mov    0x8(%ebp),%eax
  80055b:	ff d0                	call   *%eax
  80055d:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800560:	ff 4d e4             	decl   -0x1c(%ebp)
  800563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800567:	7f e4                	jg     80054d <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	eb 34                	jmp    80059f <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  80056b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056f:	74 1c                	je     80058d <vprintfmt+0x207>
  800571:	83 fb 1f             	cmp    $0x1f,%ebx
  800574:	7e 05                	jle    80057b <vprintfmt+0x1f5>
  800576:	83 fb 7e             	cmp    $0x7e,%ebx
  800579:	7e 12                	jle    80058d <vprintfmt+0x207>
					putch('?', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	ff 75 0c             	pushl  0xc(%ebp)
  800581:	6a 3f                	push   $0x3f
  800583:	8b 45 08             	mov    0x8(%ebp),%eax
  800586:	ff d0                	call   *%eax
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb 0f                	jmp    80059c <vprintfmt+0x216>
				else
					putch(ch, putdat);
  80058d:	83 ec 08             	sub    $0x8,%esp
  800590:	ff 75 0c             	pushl  0xc(%ebp)
  800593:	53                   	push   %ebx
  800594:	8b 45 08             	mov    0x8(%ebp),%eax
  800597:	ff d0                	call   *%eax
  800599:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80059c:	ff 4d e4             	decl   -0x1c(%ebp)
  80059f:	89 f0                	mov    %esi,%eax
  8005a1:	8d 70 01             	lea    0x1(%eax),%esi
  8005a4:	8a 00                	mov    (%eax),%al
  8005a6:	0f be d8             	movsbl %al,%ebx
  8005a9:	85 db                	test   %ebx,%ebx
  8005ab:	74 24                	je     8005d1 <vprintfmt+0x24b>
  8005ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b1:	78 b8                	js     80056b <vprintfmt+0x1e5>
  8005b3:	ff 4d e0             	decl   -0x20(%ebp)
  8005b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ba:	79 af                	jns    80056b <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bc:	eb 13                	jmp    8005d1 <vprintfmt+0x24b>
				putch(' ', putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	ff 75 0c             	pushl  0xc(%ebp)
  8005c4:	6a 20                	push   $0x20
  8005c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c9:	ff d0                	call   *%eax
  8005cb:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d5:	7f e7                	jg     8005be <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  8005d7:	e9 66 01 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	ff 75 e8             	pushl  -0x18(%ebp)
  8005e2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e5:	50                   	push   %eax
  8005e6:	e8 3c fd ff ff       	call   800327 <getint>
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005f1:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  8005f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005fa:	85 d2                	test   %edx,%edx
  8005fc:	79 23                	jns    800621 <vprintfmt+0x29b>
				putch('-', putdat);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	ff 75 0c             	pushl  0xc(%ebp)
  800604:	6a 2d                	push   $0x2d
  800606:	8b 45 08             	mov    0x8(%ebp),%eax
  800609:	ff d0                	call   *%eax
  80060b:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  80060e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800611:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800614:	f7 d8                	neg    %eax
  800616:	83 d2 00             	adc    $0x0,%edx
  800619:	f7 da                	neg    %edx
  80061b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80061e:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800621:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800628:	e9 bc 00 00 00       	jmp    8006e9 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	ff 75 e8             	pushl  -0x18(%ebp)
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	50                   	push   %eax
  800637:	e8 84 fc ff ff       	call   8002c0 <getuint>
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800642:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800645:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80064c:	e9 98 00 00 00       	jmp    8006e9 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	ff 75 0c             	pushl  0xc(%ebp)
  800657:	6a 58                	push   $0x58
  800659:	8b 45 08             	mov    0x8(%ebp),%eax
  80065c:	ff d0                	call   *%eax
  80065e:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	ff 75 0c             	pushl  0xc(%ebp)
  800667:	6a 58                	push   $0x58
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	ff d0                	call   *%eax
  80066e:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	ff 75 0c             	pushl  0xc(%ebp)
  800677:	6a 58                	push   $0x58
  800679:	8b 45 08             	mov    0x8(%ebp),%eax
  80067c:	ff d0                	call   *%eax
  80067e:	83 c4 10             	add    $0x10,%esp
			break;
  800681:	e9 bc 00 00 00       	jmp    800742 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	ff 75 0c             	pushl  0xc(%ebp)
  80068c:	6a 30                	push   $0x30
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	ff d0                	call   *%eax
  800693:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	ff 75 0c             	pushl  0xc(%ebp)
  80069c:	6a 78                	push   $0x78
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	ff d0                	call   *%eax
  8006a3:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	83 c0 04             	add    $0x4,%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	83 e8 04             	sub    $0x4,%eax
  8006b5:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8006c1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8006c8:	eb 1f                	jmp    8006e9 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ca:	83 ec 08             	sub    $0x8,%esp
  8006cd:	ff 75 e8             	pushl  -0x18(%ebp)
  8006d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	e8 e7 fb ff ff       	call   8002c0 <getuint>
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8006df:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  8006e2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8006ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	52                   	push   %edx
  8006f4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006f7:	50                   	push   %eax
  8006f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8006fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	ff 75 08             	pushl  0x8(%ebp)
  800704:	e8 00 fb ff ff       	call   800209 <printnum>
  800709:	83 c4 20             	add    $0x20,%esp
			break;
  80070c:	eb 34                	jmp    800742 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80070e:	83 ec 08             	sub    $0x8,%esp
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	53                   	push   %ebx
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	ff d0                	call   *%eax
  80071a:	83 c4 10             	add    $0x10,%esp
			break;
  80071d:	eb 23                	jmp    800742 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	ff 75 0c             	pushl  0xc(%ebp)
  800725:	6a 25                	push   $0x25
  800727:	8b 45 08             	mov    0x8(%ebp),%eax
  80072a:	ff d0                	call   *%eax
  80072c:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072f:	ff 4d 10             	decl   0x10(%ebp)
  800732:	eb 03                	jmp    800737 <vprintfmt+0x3b1>
  800734:	ff 4d 10             	decl   0x10(%ebp)
  800737:	8b 45 10             	mov    0x10(%ebp),%eax
  80073a:	48                   	dec    %eax
  80073b:	8a 00                	mov    (%eax),%al
  80073d:	3c 25                	cmp    $0x25,%al
  80073f:	75 f3                	jne    800734 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  800741:	90                   	nop
		}
	}
  800742:	e9 47 fc ff ff       	jmp    80038e <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800747:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800748:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5d                   	pop    %ebp
  80074e:	c3                   	ret    

0080074f <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800755:	8d 45 10             	lea    0x10(%ebp),%eax
  800758:	83 c0 04             	add    $0x4,%eax
  80075b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80075e:	8b 45 10             	mov    0x10(%ebp),%eax
  800761:	ff 75 f4             	pushl  -0xc(%ebp)
  800764:	50                   	push   %eax
  800765:	ff 75 0c             	pushl  0xc(%ebp)
  800768:	ff 75 08             	pushl  0x8(%ebp)
  80076b:	e8 16 fc ff ff       	call   800386 <vprintfmt>
  800770:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  800773:	90                   	nop
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800779:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077c:	8b 40 08             	mov    0x8(%eax),%eax
  80077f:	8d 50 01             	lea    0x1(%eax),%edx
  800782:	8b 45 0c             	mov    0xc(%ebp),%eax
  800785:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078b:	8b 10                	mov    (%eax),%edx
  80078d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800790:	8b 40 04             	mov    0x4(%eax),%eax
  800793:	39 c2                	cmp    %eax,%edx
  800795:	73 12                	jae    8007a9 <sprintputch+0x33>
		*b->buf++ = ch;
  800797:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079a:	8b 00                	mov    (%eax),%eax
  80079c:	8d 48 01             	lea    0x1(%eax),%ecx
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	89 0a                	mov    %ecx,(%edx)
  8007a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8007a7:	88 10                	mov    %dl,(%eax)
}
  8007a9:	90                   	nop
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bb:	8d 50 ff             	lea    -0x1(%eax),%edx
  8007be:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c1:	01 d0                	add    %edx,%eax
  8007c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007cd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8007d1:	74 06                	je     8007d9 <vsnprintf+0x2d>
  8007d3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8007d7:	7f 07                	jg     8007e0 <vsnprintf+0x34>
		return -E_INVAL;
  8007d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8007de:	eb 20                	jmp    800800 <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007e0:	ff 75 14             	pushl  0x14(%ebp)
  8007e3:	ff 75 10             	pushl  0x10(%ebp)
  8007e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	68 76 07 80 00       	push   $0x800776
  8007ef:	e8 92 fb ff ff       	call   800386 <vprintfmt>
  8007f4:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  8007f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007fa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800800:	c9                   	leave  
  800801:	c3                   	ret    

00800802 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800808:	8d 45 10             	lea    0x10(%ebp),%eax
  80080b:	83 c0 04             	add    $0x4,%eax
  80080e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	ff 75 f4             	pushl  -0xc(%ebp)
  800817:	50                   	push   %eax
  800818:	ff 75 0c             	pushl  0xc(%ebp)
  80081b:	ff 75 08             	pushl  0x8(%ebp)
  80081e:	e8 89 ff ff ff       	call   8007ac <vsnprintf>
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80082c:	c9                   	leave  
  80082d:	c3                   	ret    

0080082e <readline>:

#define BUFLEN 1024
//static char buf[BUFLEN];

void readline(const char *prompt, char* buf)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	83 ec 18             	sub    $0x18,%esp
	int i, c, echoing;
	
	if (prompt != NULL)
  800834:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800838:	74 13                	je     80084d <readline+0x1f>
		cprintf("%s", prompt);
  80083a:	83 ec 08             	sub    $0x8,%esp
  80083d:	ff 75 08             	pushl  0x8(%ebp)
  800840:	68 7c 15 80 00       	push   $0x80157c
  800845:	e8 99 f9 ff ff       	call   8001e3 <cprintf>
  80084a:	83 c4 10             	add    $0x10,%esp

	
	i = 0;
  80084d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	echoing = iscons(0);	
  800854:	83 ec 0c             	sub    $0xc,%esp
  800857:	6a 00                	push   $0x0
  800859:	e8 f6 07 00 00       	call   801054 <iscons>
  80085e:	83 c4 10             	add    $0x10,%esp
  800861:	89 45 f0             	mov    %eax,-0x10(%ebp)
	while (1) {
		c = getchar();
  800864:	e8 de 07 00 00       	call   801047 <getchar>
  800869:	89 45 ec             	mov    %eax,-0x14(%ebp)
		if (c < 0) {
  80086c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  800870:	79 22                	jns    800894 <readline+0x66>
			if (c != -E_EOF)
  800872:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
  800876:	0f 84 ad 00 00 00    	je     800929 <readline+0xfb>
				cprintf("read error: %e\n", c);			
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	ff 75 ec             	pushl  -0x14(%ebp)
  800882:	68 7f 15 80 00       	push   $0x80157f
  800887:	e8 57 f9 ff ff       	call   8001e3 <cprintf>
  80088c:	83 c4 10             	add    $0x10,%esp
			return;
  80088f:	e9 95 00 00 00       	jmp    800929 <readline+0xfb>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800894:	83 7d ec 1f          	cmpl   $0x1f,-0x14(%ebp)
  800898:	7e 34                	jle    8008ce <readline+0xa0>
  80089a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  8008a1:	7f 2b                	jg     8008ce <readline+0xa0>
			if (echoing)
  8008a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008a7:	74 0e                	je     8008b7 <readline+0x89>
				cputchar(c);
  8008a9:	83 ec 0c             	sub    $0xc,%esp
  8008ac:	ff 75 ec             	pushl  -0x14(%ebp)
  8008af:	e8 73 07 00 00       	call   801027 <cputchar>
  8008b4:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  8008b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ba:	8d 50 01             	lea    0x1(%eax),%edx
  8008bd:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	01 d0                	add    %edx,%eax
  8008c7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8008ca:	88 10                	mov    %dl,(%eax)
  8008cc:	eb 56                	jmp    800924 <readline+0xf6>
		} else if (c == '\b' && i > 0) {
  8008ce:	83 7d ec 08          	cmpl   $0x8,-0x14(%ebp)
  8008d2:	75 1f                	jne    8008f3 <readline+0xc5>
  8008d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8008d8:	7e 19                	jle    8008f3 <readline+0xc5>
			if (echoing)
  8008da:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8008de:	74 0e                	je     8008ee <readline+0xc0>
				cputchar(c);
  8008e0:	83 ec 0c             	sub    $0xc,%esp
  8008e3:	ff 75 ec             	pushl  -0x14(%ebp)
  8008e6:	e8 3c 07 00 00       	call   801027 <cputchar>
  8008eb:	83 c4 10             	add    $0x10,%esp
			i--;
  8008ee:	ff 4d f4             	decl   -0xc(%ebp)
  8008f1:	eb 31                	jmp    800924 <readline+0xf6>
		} else if (c == '\n' || c == '\r') {
  8008f3:	83 7d ec 0a          	cmpl   $0xa,-0x14(%ebp)
  8008f7:	74 0a                	je     800903 <readline+0xd5>
  8008f9:	83 7d ec 0d          	cmpl   $0xd,-0x14(%ebp)
  8008fd:	0f 85 61 ff ff ff    	jne    800864 <readline+0x36>
			if (echoing)
  800903:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800907:	74 0e                	je     800917 <readline+0xe9>
				cputchar(c);
  800909:	83 ec 0c             	sub    $0xc,%esp
  80090c:	ff 75 ec             	pushl  -0x14(%ebp)
  80090f:	e8 13 07 00 00       	call   801027 <cputchar>
  800914:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;	
  800917:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80091a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091d:	01 d0                	add    %edx,%eax
  80091f:	c6 00 00             	movb   $0x0,(%eax)
			return;		
  800922:	eb 06                	jmp    80092a <readline+0xfc>
		}
	}
  800924:	e9 3b ff ff ff       	jmp    800864 <readline+0x36>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);			
			return;
  800929:	90                   	nop
				cputchar(c);
			buf[i] = 0;	
			return;		
		}
	}
}
  80092a:	c9                   	leave  
  80092b:	c3                   	ret    

0080092c <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800932:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800939:	eb 06                	jmp    800941 <strlen+0x15>
		n++;
  80093b:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80093e:	ff 45 08             	incl   0x8(%ebp)
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	8a 00                	mov    (%eax),%al
  800946:	84 c0                	test   %al,%al
  800948:	75 f1                	jne    80093b <strlen+0xf>
		n++;
	return n;
  80094a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80094d:	c9                   	leave  
  80094e:	c3                   	ret    

0080094f <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800955:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80095c:	eb 09                	jmp    800967 <strnlen+0x18>
		n++;
  80095e:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800961:	ff 45 08             	incl   0x8(%ebp)
  800964:	ff 4d 0c             	decl   0xc(%ebp)
  800967:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80096b:	74 09                	je     800976 <strnlen+0x27>
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8a 00                	mov    (%eax),%al
  800972:	84 c0                	test   %al,%al
  800974:	75 e8                	jne    80095e <strnlen+0xf>
		n++;
	return n;
  800976:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800987:	90                   	nop
  800988:	8b 45 08             	mov    0x8(%ebp),%eax
  80098b:	8d 50 01             	lea    0x1(%eax),%edx
  80098e:	89 55 08             	mov    %edx,0x8(%ebp)
  800991:	8b 55 0c             	mov    0xc(%ebp),%edx
  800994:	8d 4a 01             	lea    0x1(%edx),%ecx
  800997:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  80099a:	8a 12                	mov    (%edx),%dl
  80099c:	88 10                	mov    %dl,(%eax)
  80099e:	8a 00                	mov    (%eax),%al
  8009a0:	84 c0                	test   %al,%al
  8009a2:	75 e4                	jne    800988 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009b5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009bc:	eb 1f                	jmp    8009dd <strncpy+0x34>
		*dst++ = *src;
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8d 50 01             	lea    0x1(%eax),%edx
  8009c4:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	8a 12                	mov    (%edx),%dl
  8009cc:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d1:	8a 00                	mov    (%eax),%al
  8009d3:	84 c0                	test   %al,%al
  8009d5:	74 03                	je     8009da <strncpy+0x31>
			src++;
  8009d7:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009da:	ff 45 fc             	incl   -0x4(%ebp)
  8009dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8009e0:	3b 45 10             	cmp    0x10(%ebp),%eax
  8009e3:	72 d9                	jb     8009be <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  8009e5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  8009f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  8009f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8009fa:	74 30                	je     800a2c <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  8009fc:	eb 16                	jmp    800a14 <strlcpy+0x2a>
			*dst++ = *src++;
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8d 50 01             	lea    0x1(%eax),%edx
  800a04:	89 55 08             	mov    %edx,0x8(%ebp)
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a0d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a10:	8a 12                	mov    (%edx),%dl
  800a12:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a14:	ff 4d 10             	decl   0x10(%ebp)
  800a17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a1b:	74 09                	je     800a26 <strlcpy+0x3c>
  800a1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a20:	8a 00                	mov    (%eax),%al
  800a22:	84 c0                	test   %al,%al
  800a24:	75 d8                	jne    8009fe <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a32:	29 c2                	sub    %eax,%edx
  800a34:	89 d0                	mov    %edx,%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a3b:	eb 06                	jmp    800a43 <strcmp+0xb>
		p++, q++;
  800a3d:	ff 45 08             	incl   0x8(%ebp)
  800a40:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	8a 00                	mov    (%eax),%al
  800a48:	84 c0                	test   %al,%al
  800a4a:	74 0e                	je     800a5a <strcmp+0x22>
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8a 10                	mov    (%eax),%dl
  800a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a54:	8a 00                	mov    (%eax),%al
  800a56:	38 c2                	cmp    %al,%dl
  800a58:	74 e3                	je     800a3d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8a 00                	mov    (%eax),%al
  800a5f:	0f b6 d0             	movzbl %al,%edx
  800a62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a65:	8a 00                	mov    (%eax),%al
  800a67:	0f b6 c0             	movzbl %al,%eax
  800a6a:	29 c2                	sub    %eax,%edx
  800a6c:	89 d0                	mov    %edx,%eax
}
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800a73:	eb 09                	jmp    800a7e <strncmp+0xe>
		n--, p++, q++;
  800a75:	ff 4d 10             	decl   0x10(%ebp)
  800a78:	ff 45 08             	incl   0x8(%ebp)
  800a7b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800a7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a82:	74 17                	je     800a9b <strncmp+0x2b>
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8a 00                	mov    (%eax),%al
  800a89:	84 c0                	test   %al,%al
  800a8b:	74 0e                	je     800a9b <strncmp+0x2b>
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8a 10                	mov    (%eax),%dl
  800a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a95:	8a 00                	mov    (%eax),%al
  800a97:	38 c2                	cmp    %al,%dl
  800a99:	74 da                	je     800a75 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800a9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a9f:	75 07                	jne    800aa8 <strncmp+0x38>
		return 0;
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	eb 14                	jmp    800abc <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800aab:	8a 00                	mov    (%eax),%al
  800aad:	0f b6 d0             	movzbl %al,%edx
  800ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab3:	8a 00                	mov    (%eax),%al
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	29 c2                	sub    %eax,%edx
  800aba:	89 d0                	mov    %edx,%eax
}
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	83 ec 04             	sub    $0x4,%esp
  800ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800aca:	eb 12                	jmp    800ade <strchr+0x20>
		if (*s == c)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	8a 00                	mov    (%eax),%al
  800ad1:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800ad4:	75 05                	jne    800adb <strchr+0x1d>
			return (char *) s;
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	eb 11                	jmp    800aec <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800adb:	ff 45 08             	incl   0x8(%ebp)
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8a 00                	mov    (%eax),%al
  800ae3:	84 c0                	test   %al,%al
  800ae5:	75 e5                	jne    800acc <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 04             	sub    $0x4,%esp
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800afa:	eb 0d                	jmp    800b09 <strfind+0x1b>
		if (*s == c)
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8a 00                	mov    (%eax),%al
  800b01:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b04:	74 0e                	je     800b14 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b06:	ff 45 08             	incl   0x8(%ebp)
  800b09:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0c:	8a 00                	mov    (%eax),%al
  800b0e:	84 c0                	test   %al,%al
  800b10:	75 ea                	jne    800afc <strfind+0xe>
  800b12:	eb 01                	jmp    800b15 <strfind+0x27>
		if (*s == c)
			break;
  800b14:	90                   	nop
	return (char *) s;
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800b26:	8b 45 10             	mov    0x10(%ebp),%eax
  800b29:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b2c:	eb 0e                	jmp    800b3c <memset+0x22>
		*p++ = c;
  800b2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b31:	8d 50 01             	lea    0x1(%eax),%edx
  800b34:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3a:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b3c:	ff 4d f8             	decl   -0x8(%ebp)
  800b3f:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b43:	79 e9                	jns    800b2e <memset+0x14>
		*p++ = c;

	return v;
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b53:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b5c:	eb 16                	jmp    800b74 <memcpy+0x2a>
		*d++ = *s++;
  800b5e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b61:	8d 50 01             	lea    0x1(%eax),%edx
  800b64:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b67:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b6a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b6d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800b70:	8a 12                	mov    (%edx),%dl
  800b72:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800b74:	8b 45 10             	mov    0x10(%ebp),%eax
  800b77:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b7a:	89 55 10             	mov    %edx,0x10(%ebp)
  800b7d:	85 c0                	test   %eax,%eax
  800b7f:	75 dd                	jne    800b5e <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b84:	c9                   	leave  
  800b85:	c3                   	ret    

00800b86 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800b8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800b98:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b9b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800b9e:	73 50                	jae    800bf0 <memmove+0x6a>
  800ba0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ba3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba6:	01 d0                	add    %edx,%eax
  800ba8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bab:	76 43                	jbe    800bf0 <memmove+0x6a>
		s += n;
  800bad:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb0:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800bb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bb6:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800bb9:	eb 10                	jmp    800bcb <memmove+0x45>
			*--d = *--s;
  800bbb:	ff 4d f8             	decl   -0x8(%ebp)
  800bbe:	ff 4d fc             	decl   -0x4(%ebp)
  800bc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bc4:	8a 10                	mov    (%eax),%dl
  800bc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bc9:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800bcb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bce:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bd1:	89 55 10             	mov    %edx,0x10(%ebp)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	75 e3                	jne    800bbb <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd8:	eb 23                	jmp    800bfd <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800bda:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bdd:	8d 50 01             	lea    0x1(%eax),%edx
  800be0:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800be3:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800be6:	8d 4a 01             	lea    0x1(%edx),%ecx
  800be9:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800bec:	8a 12                	mov    (%edx),%dl
  800bee:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800bf0:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf3:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bf6:	89 55 10             	mov    %edx,0x10(%ebp)
  800bf9:	85 c0                	test   %eax,%eax
  800bfb:	75 dd                	jne    800bda <memmove+0x54>
			*d++ = *s++;

	return dst;
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c11:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c14:	eb 2a                	jmp    800c40 <memcmp+0x3e>
		if (*s1 != *s2)
  800c16:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c19:	8a 10                	mov    (%eax),%dl
  800c1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c1e:	8a 00                	mov    (%eax),%al
  800c20:	38 c2                	cmp    %al,%dl
  800c22:	74 16                	je     800c3a <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c27:	8a 00                	mov    (%eax),%al
  800c29:	0f b6 d0             	movzbl %al,%edx
  800c2c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c2f:	8a 00                	mov    (%eax),%al
  800c31:	0f b6 c0             	movzbl %al,%eax
  800c34:	29 c2                	sub    %eax,%edx
  800c36:	89 d0                	mov    %edx,%eax
  800c38:	eb 18                	jmp    800c52 <memcmp+0x50>
		s1++, s2++;
  800c3a:	ff 45 fc             	incl   -0x4(%ebp)
  800c3d:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c40:	8b 45 10             	mov    0x10(%ebp),%eax
  800c43:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c46:	89 55 10             	mov    %edx,0x10(%ebp)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	75 c9                	jne    800c16 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c4d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c60:	01 d0                	add    %edx,%eax
  800c62:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c65:	eb 15                	jmp    800c7c <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8a 00                	mov    (%eax),%al
  800c6c:	0f b6 d0             	movzbl %al,%edx
  800c6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c72:	0f b6 c0             	movzbl %al,%eax
  800c75:	39 c2                	cmp    %eax,%edx
  800c77:	74 0d                	je     800c86 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c79:	ff 45 08             	incl   0x8(%ebp)
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800c82:	72 e3                	jb     800c67 <memfind+0x13>
  800c84:	eb 01                	jmp    800c87 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800c86:	90                   	nop
	return (void *) s;
  800c87:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c8a:	c9                   	leave  
  800c8b:	c3                   	ret    

00800c8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800c92:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800c99:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca0:	eb 03                	jmp    800ca5 <strtol+0x19>
		s++;
  800ca2:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	8a 00                	mov    (%eax),%al
  800caa:	3c 20                	cmp    $0x20,%al
  800cac:	74 f4                	je     800ca2 <strtol+0x16>
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	8a 00                	mov    (%eax),%al
  800cb3:	3c 09                	cmp    $0x9,%al
  800cb5:	74 eb                	je     800ca2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cba:	8a 00                	mov    (%eax),%al
  800cbc:	3c 2b                	cmp    $0x2b,%al
  800cbe:	75 05                	jne    800cc5 <strtol+0x39>
		s++;
  800cc0:	ff 45 08             	incl   0x8(%ebp)
  800cc3:	eb 13                	jmp    800cd8 <strtol+0x4c>
	else if (*s == '-')
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	8a 00                	mov    (%eax),%al
  800cca:	3c 2d                	cmp    $0x2d,%al
  800ccc:	75 0a                	jne    800cd8 <strtol+0x4c>
		s++, neg = 1;
  800cce:	ff 45 08             	incl   0x8(%ebp)
  800cd1:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cdc:	74 06                	je     800ce4 <strtol+0x58>
  800cde:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800ce2:	75 20                	jne    800d04 <strtol+0x78>
  800ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce7:	8a 00                	mov    (%eax),%al
  800ce9:	3c 30                	cmp    $0x30,%al
  800ceb:	75 17                	jne    800d04 <strtol+0x78>
  800ced:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf0:	40                   	inc    %eax
  800cf1:	8a 00                	mov    (%eax),%al
  800cf3:	3c 78                	cmp    $0x78,%al
  800cf5:	75 0d                	jne    800d04 <strtol+0x78>
		s += 2, base = 16;
  800cf7:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800cfb:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d02:	eb 28                	jmp    800d2c <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800d04:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d08:	75 15                	jne    800d1f <strtol+0x93>
  800d0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0d:	8a 00                	mov    (%eax),%al
  800d0f:	3c 30                	cmp    $0x30,%al
  800d11:	75 0c                	jne    800d1f <strtol+0x93>
		s++, base = 8;
  800d13:	ff 45 08             	incl   0x8(%ebp)
  800d16:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d1d:	eb 0d                	jmp    800d2c <strtol+0xa0>
	else if (base == 0)
  800d1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d23:	75 07                	jne    800d2c <strtol+0xa0>
		base = 10;
  800d25:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	8a 00                	mov    (%eax),%al
  800d31:	3c 2f                	cmp    $0x2f,%al
  800d33:	7e 19                	jle    800d4e <strtol+0xc2>
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	8a 00                	mov    (%eax),%al
  800d3a:	3c 39                	cmp    $0x39,%al
  800d3c:	7f 10                	jg     800d4e <strtol+0xc2>
			dig = *s - '0';
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	8a 00                	mov    (%eax),%al
  800d43:	0f be c0             	movsbl %al,%eax
  800d46:	83 e8 30             	sub    $0x30,%eax
  800d49:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d4c:	eb 42                	jmp    800d90 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	8a 00                	mov    (%eax),%al
  800d53:	3c 60                	cmp    $0x60,%al
  800d55:	7e 19                	jle    800d70 <strtol+0xe4>
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	8a 00                	mov    (%eax),%al
  800d5c:	3c 7a                	cmp    $0x7a,%al
  800d5e:	7f 10                	jg     800d70 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	8a 00                	mov    (%eax),%al
  800d65:	0f be c0             	movsbl %al,%eax
  800d68:	83 e8 57             	sub    $0x57,%eax
  800d6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d6e:	eb 20                	jmp    800d90 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	8a 00                	mov    (%eax),%al
  800d75:	3c 40                	cmp    $0x40,%al
  800d77:	7e 39                	jle    800db2 <strtol+0x126>
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	8a 00                	mov    (%eax),%al
  800d7e:	3c 5a                	cmp    $0x5a,%al
  800d80:	7f 30                	jg     800db2 <strtol+0x126>
			dig = *s - 'A' + 10;
  800d82:	8b 45 08             	mov    0x8(%ebp),%eax
  800d85:	8a 00                	mov    (%eax),%al
  800d87:	0f be c0             	movsbl %al,%eax
  800d8a:	83 e8 37             	sub    $0x37,%eax
  800d8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d93:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d96:	7d 19                	jge    800db1 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800d98:	ff 45 08             	incl   0x8(%ebp)
  800d9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800d9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da2:	89 c2                	mov    %eax,%edx
  800da4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da7:	01 d0                	add    %edx,%eax
  800da9:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800dac:	e9 7b ff ff ff       	jmp    800d2c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800db1:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800db2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800db6:	74 08                	je     800dc0 <strtol+0x134>
		*endptr = (char *) s;
  800db8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800dc0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800dc4:	74 07                	je     800dcd <strtol+0x141>
  800dc6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dc9:	f7 d8                	neg    %eax
  800dcb:	eb 03                	jmp    800dd0 <strtol+0x144>
  800dcd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800dd0:	c9                   	leave  
  800dd1:	c3                   	ret    

00800dd2 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800dde:	8b 45 14             	mov    0x14(%ebp),%eax
  800de1:	8b 00                	mov    (%eax),%eax
  800de3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800dea:	8b 45 10             	mov    0x10(%ebp),%eax
  800ded:	01 d0                	add    %edx,%eax
  800def:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800df5:	eb 0c                	jmp    800e03 <strsplit+0x31>
			*string++ = 0;
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	8d 50 01             	lea    0x1(%eax),%edx
  800dfd:	89 55 08             	mov    %edx,0x8(%ebp)
  800e00:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	8a 00                	mov    (%eax),%al
  800e08:	84 c0                	test   %al,%al
  800e0a:	74 18                	je     800e24 <strsplit+0x52>
  800e0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0f:	8a 00                	mov    (%eax),%al
  800e11:	0f be c0             	movsbl %al,%eax
  800e14:	50                   	push   %eax
  800e15:	ff 75 0c             	pushl  0xc(%ebp)
  800e18:	e8 a1 fc ff ff       	call   800abe <strchr>
  800e1d:	83 c4 08             	add    $0x8,%esp
  800e20:	85 c0                	test   %eax,%eax
  800e22:	75 d3                	jne    800df7 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	8a 00                	mov    (%eax),%al
  800e29:	84 c0                	test   %al,%al
  800e2b:	74 5a                	je     800e87 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800e2d:	8b 45 14             	mov    0x14(%ebp),%eax
  800e30:	8b 00                	mov    (%eax),%eax
  800e32:	83 f8 0f             	cmp    $0xf,%eax
  800e35:	75 07                	jne    800e3e <strsplit+0x6c>
		{
			return 0;
  800e37:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3c:	eb 66                	jmp    800ea4 <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800e3e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e41:	8b 00                	mov    (%eax),%eax
  800e43:	8d 48 01             	lea    0x1(%eax),%ecx
  800e46:	8b 55 14             	mov    0x14(%ebp),%edx
  800e49:	89 0a                	mov    %ecx,(%edx)
  800e4b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e52:	8b 45 10             	mov    0x10(%ebp),%eax
  800e55:	01 c2                	add    %eax,%edx
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e5c:	eb 03                	jmp    800e61 <strsplit+0x8f>
			string++;
  800e5e:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	8a 00                	mov    (%eax),%al
  800e66:	84 c0                	test   %al,%al
  800e68:	74 8b                	je     800df5 <strsplit+0x23>
  800e6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6d:	8a 00                	mov    (%eax),%al
  800e6f:	0f be c0             	movsbl %al,%eax
  800e72:	50                   	push   %eax
  800e73:	ff 75 0c             	pushl  0xc(%ebp)
  800e76:	e8 43 fc ff ff       	call   800abe <strchr>
  800e7b:	83 c4 08             	add    $0x8,%esp
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	74 dc                	je     800e5e <strsplit+0x8c>
			string++;
	}
  800e82:	e9 6e ff ff ff       	jmp    800df5 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800e87:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800e88:	8b 45 14             	mov    0x14(%ebp),%eax
  800e8b:	8b 00                	mov    (%eax),%eax
  800e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e94:	8b 45 10             	mov    0x10(%ebp),%eax
  800e97:	01 d0                	add    %edx,%eax
  800e99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800e9f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	57                   	push   %edi
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800eb8:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800ebb:	8b 7d 18             	mov    0x18(%ebp),%edi
  800ebe:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800ec1:	cd 30                	int    $0x30
  800ec3:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800ec9:	83 c4 10             	add    $0x10,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5e                   	pop    %esi
  800ece:	5f                   	pop    %edi
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800ed4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed7:	6a 00                	push   $0x0
  800ed9:	6a 00                	push   $0x0
  800edb:	6a 00                	push   $0x0
  800edd:	ff 75 0c             	pushl  0xc(%ebp)
  800ee0:	50                   	push   %eax
  800ee1:	6a 00                	push   $0x0
  800ee3:	e8 be ff ff ff       	call   800ea6 <syscall>
  800ee8:	83 c4 18             	add    $0x18,%esp
}
  800eeb:	90                   	nop
  800eec:	c9                   	leave  
  800eed:	c3                   	ret    

00800eee <sys_cgetc>:

int
sys_cgetc(void)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800ef1:	6a 00                	push   $0x0
  800ef3:	6a 00                	push   $0x0
  800ef5:	6a 00                	push   $0x0
  800ef7:	6a 00                	push   $0x0
  800ef9:	6a 00                	push   $0x0
  800efb:	6a 01                	push   $0x1
  800efd:	e8 a4 ff ff ff       	call   800ea6 <syscall>
  800f02:	83 c4 18             	add    $0x18,%esp
}
  800f05:	c9                   	leave  
  800f06:	c3                   	ret    

00800f07 <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800f0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0d:	6a 00                	push   $0x0
  800f0f:	6a 00                	push   $0x0
  800f11:	6a 00                	push   $0x0
  800f13:	6a 00                	push   $0x0
  800f15:	50                   	push   %eax
  800f16:	6a 03                	push   $0x3
  800f18:	e8 89 ff ff ff       	call   800ea6 <syscall>
  800f1d:	83 c4 18             	add    $0x18,%esp
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800f25:	6a 00                	push   $0x0
  800f27:	6a 00                	push   $0x0
  800f29:	6a 00                	push   $0x0
  800f2b:	6a 00                	push   $0x0
  800f2d:	6a 00                	push   $0x0
  800f2f:	6a 02                	push   $0x2
  800f31:	e8 70 ff ff ff       	call   800ea6 <syscall>
  800f36:	83 c4 18             	add    $0x18,%esp
}
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <sys_env_sleep>:

void sys_env_sleep(void)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800f3e:	6a 00                	push   $0x0
  800f40:	6a 00                	push   $0x0
  800f42:	6a 00                	push   $0x0
  800f44:	6a 00                	push   $0x0
  800f46:	6a 00                	push   $0x0
  800f48:	6a 04                	push   $0x4
  800f4a:	e8 57 ff ff ff       	call   800ea6 <syscall>
  800f4f:	83 c4 18             	add    $0x18,%esp
}
  800f52:	90                   	nop
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800f58:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f5e:	6a 00                	push   $0x0
  800f60:	6a 00                	push   $0x0
  800f62:	6a 00                	push   $0x0
  800f64:	52                   	push   %edx
  800f65:	50                   	push   %eax
  800f66:	6a 05                	push   $0x5
  800f68:	e8 39 ff ff ff       	call   800ea6 <syscall>
  800f6d:	83 c4 18             	add    $0x18,%esp
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800f75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	6a 00                	push   $0x0
  800f7d:	6a 00                	push   $0x0
  800f7f:	6a 00                	push   $0x0
  800f81:	52                   	push   %edx
  800f82:	50                   	push   %eax
  800f83:	6a 06                	push   $0x6
  800f85:	e8 1c ff ff ff       	call   800ea6 <syscall>
  800f8a:	83 c4 18             	add    $0x18,%esp
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800f94:	8b 75 18             	mov    0x18(%ebp),%esi
  800f97:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f9a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa3:	56                   	push   %esi
  800fa4:	53                   	push   %ebx
  800fa5:	51                   	push   %ecx
  800fa6:	52                   	push   %edx
  800fa7:	50                   	push   %eax
  800fa8:	6a 07                	push   $0x7
  800faa:	e8 f7 fe ff ff       	call   800ea6 <syscall>
  800faf:	83 c4 18             	add    $0x18,%esp
}
  800fb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    

00800fb9 <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	6a 00                	push   $0x0
  800fc4:	6a 00                	push   $0x0
  800fc6:	6a 00                	push   $0x0
  800fc8:	52                   	push   %edx
  800fc9:	50                   	push   %eax
  800fca:	6a 08                	push   $0x8
  800fcc:	e8 d5 fe ff ff       	call   800ea6 <syscall>
  800fd1:	83 c4 18             	add    $0x18,%esp
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  800fd9:	6a 00                	push   $0x0
  800fdb:	6a 00                	push   $0x0
  800fdd:	6a 00                	push   $0x0
  800fdf:	ff 75 0c             	pushl  0xc(%ebp)
  800fe2:	ff 75 08             	pushl  0x8(%ebp)
  800fe5:	6a 09                	push   $0x9
  800fe7:	e8 ba fe ff ff       	call   800ea6 <syscall>
  800fec:	83 c4 18             	add    $0x18,%esp
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  800ff4:	6a 00                	push   $0x0
  800ff6:	6a 00                	push   $0x0
  800ff8:	6a 00                	push   $0x0
  800ffa:	6a 00                	push   $0x0
  800ffc:	6a 00                	push   $0x0
  800ffe:	6a 0a                	push   $0xa
  801000:	e8 a1 fe ff ff       	call   800ea6 <syscall>
  801005:	83 c4 18             	add    $0x18,%esp
}
  801008:	c9                   	leave  
  801009:	c3                   	ret    

0080100a <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  80100d:	8b 45 08             	mov    0x8(%ebp),%eax
  801010:	6a 00                	push   $0x0
  801012:	6a 00                	push   $0x0
  801014:	6a 00                	push   $0x0
  801016:	ff 75 0c             	pushl  0xc(%ebp)
  801019:	50                   	push   %eax
  80101a:	6a 0b                	push   $0xb
  80101c:	e8 85 fe ff ff       	call   800ea6 <syscall>
  801021:	83 c4 18             	add    $0x18,%esp
	return;
  801024:	90                   	nop
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	83 ec 18             	sub    $0x18,%esp
	char c = ch;
  80102d:	8b 45 08             	mov    0x8(%ebp),%eax
  801030:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	6a 01                	push   $0x1
  801038:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80103b:	50                   	push   %eax
  80103c:	e8 90 fe ff ff       	call   800ed1 <sys_cputs>
  801041:	83 c4 10             	add    $0x10,%esp
}
  801044:	90                   	nop
  801045:	c9                   	leave  
  801046:	c3                   	ret    

00801047 <getchar>:

int
getchar(void)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	83 ec 08             	sub    $0x8,%esp
	return sys_cgetc();
  80104d:	e8 9c fe ff ff       	call   800eee <sys_cgetc>
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <iscons>:


int iscons(int fdnum)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
  801057:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    
  80105e:	66 90                	xchg   %ax,%ax

00801060 <__udivdi3>:
  801060:	55                   	push   %ebp
  801061:	57                   	push   %edi
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
  801064:	83 ec 1c             	sub    $0x1c,%esp
  801067:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80106b:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  80106f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801073:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801077:	89 ca                	mov    %ecx,%edx
  801079:	89 f8                	mov    %edi,%eax
  80107b:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80107f:	85 f6                	test   %esi,%esi
  801081:	75 2d                	jne    8010b0 <__udivdi3+0x50>
  801083:	39 cf                	cmp    %ecx,%edi
  801085:	77 65                	ja     8010ec <__udivdi3+0x8c>
  801087:	89 fd                	mov    %edi,%ebp
  801089:	85 ff                	test   %edi,%edi
  80108b:	75 0b                	jne    801098 <__udivdi3+0x38>
  80108d:	b8 01 00 00 00       	mov    $0x1,%eax
  801092:	31 d2                	xor    %edx,%edx
  801094:	f7 f7                	div    %edi
  801096:	89 c5                	mov    %eax,%ebp
  801098:	31 d2                	xor    %edx,%edx
  80109a:	89 c8                	mov    %ecx,%eax
  80109c:	f7 f5                	div    %ebp
  80109e:	89 c1                	mov    %eax,%ecx
  8010a0:	89 d8                	mov    %ebx,%eax
  8010a2:	f7 f5                	div    %ebp
  8010a4:	89 cf                	mov    %ecx,%edi
  8010a6:	89 fa                	mov    %edi,%edx
  8010a8:	83 c4 1c             	add    $0x1c,%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    
  8010b0:	39 ce                	cmp    %ecx,%esi
  8010b2:	77 28                	ja     8010dc <__udivdi3+0x7c>
  8010b4:	0f bd fe             	bsr    %esi,%edi
  8010b7:	83 f7 1f             	xor    $0x1f,%edi
  8010ba:	75 40                	jne    8010fc <__udivdi3+0x9c>
  8010bc:	39 ce                	cmp    %ecx,%esi
  8010be:	72 0a                	jb     8010ca <__udivdi3+0x6a>
  8010c0:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8010c4:	0f 87 9e 00 00 00    	ja     801168 <__udivdi3+0x108>
  8010ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cf:	89 fa                	mov    %edi,%edx
  8010d1:	83 c4 1c             	add    $0x1c,%esp
  8010d4:	5b                   	pop    %ebx
  8010d5:	5e                   	pop    %esi
  8010d6:	5f                   	pop    %edi
  8010d7:	5d                   	pop    %ebp
  8010d8:	c3                   	ret    
  8010d9:	8d 76 00             	lea    0x0(%esi),%esi
  8010dc:	31 ff                	xor    %edi,%edi
  8010de:	31 c0                	xor    %eax,%eax
  8010e0:	89 fa                	mov    %edi,%edx
  8010e2:	83 c4 1c             	add    $0x1c,%esp
  8010e5:	5b                   	pop    %ebx
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    
  8010ea:	66 90                	xchg   %ax,%ax
  8010ec:	89 d8                	mov    %ebx,%eax
  8010ee:	f7 f7                	div    %edi
  8010f0:	31 ff                	xor    %edi,%edi
  8010f2:	89 fa                	mov    %edi,%edx
  8010f4:	83 c4 1c             	add    $0x1c,%esp
  8010f7:	5b                   	pop    %ebx
  8010f8:	5e                   	pop    %esi
  8010f9:	5f                   	pop    %edi
  8010fa:	5d                   	pop    %ebp
  8010fb:	c3                   	ret    
  8010fc:	bd 20 00 00 00       	mov    $0x20,%ebp
  801101:	89 eb                	mov    %ebp,%ebx
  801103:	29 fb                	sub    %edi,%ebx
  801105:	89 f9                	mov    %edi,%ecx
  801107:	d3 e6                	shl    %cl,%esi
  801109:	89 c5                	mov    %eax,%ebp
  80110b:	88 d9                	mov    %bl,%cl
  80110d:	d3 ed                	shr    %cl,%ebp
  80110f:	89 e9                	mov    %ebp,%ecx
  801111:	09 f1                	or     %esi,%ecx
  801113:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801117:	89 f9                	mov    %edi,%ecx
  801119:	d3 e0                	shl    %cl,%eax
  80111b:	89 c5                	mov    %eax,%ebp
  80111d:	89 d6                	mov    %edx,%esi
  80111f:	88 d9                	mov    %bl,%cl
  801121:	d3 ee                	shr    %cl,%esi
  801123:	89 f9                	mov    %edi,%ecx
  801125:	d3 e2                	shl    %cl,%edx
  801127:	8b 44 24 08          	mov    0x8(%esp),%eax
  80112b:	88 d9                	mov    %bl,%cl
  80112d:	d3 e8                	shr    %cl,%eax
  80112f:	09 c2                	or     %eax,%edx
  801131:	89 d0                	mov    %edx,%eax
  801133:	89 f2                	mov    %esi,%edx
  801135:	f7 74 24 0c          	divl   0xc(%esp)
  801139:	89 d6                	mov    %edx,%esi
  80113b:	89 c3                	mov    %eax,%ebx
  80113d:	f7 e5                	mul    %ebp
  80113f:	39 d6                	cmp    %edx,%esi
  801141:	72 19                	jb     80115c <__udivdi3+0xfc>
  801143:	74 0b                	je     801150 <__udivdi3+0xf0>
  801145:	89 d8                	mov    %ebx,%eax
  801147:	31 ff                	xor    %edi,%edi
  801149:	e9 58 ff ff ff       	jmp    8010a6 <__udivdi3+0x46>
  80114e:	66 90                	xchg   %ax,%ax
  801150:	8b 54 24 08          	mov    0x8(%esp),%edx
  801154:	89 f9                	mov    %edi,%ecx
  801156:	d3 e2                	shl    %cl,%edx
  801158:	39 c2                	cmp    %eax,%edx
  80115a:	73 e9                	jae    801145 <__udivdi3+0xe5>
  80115c:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80115f:	31 ff                	xor    %edi,%edi
  801161:	e9 40 ff ff ff       	jmp    8010a6 <__udivdi3+0x46>
  801166:	66 90                	xchg   %ax,%ax
  801168:	31 c0                	xor    %eax,%eax
  80116a:	e9 37 ff ff ff       	jmp    8010a6 <__udivdi3+0x46>
  80116f:	90                   	nop

00801170 <__umoddi3>:
  801170:	55                   	push   %ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80117b:	8b 74 24 34          	mov    0x34(%esp),%esi
  80117f:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801183:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801187:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80118b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118f:	89 f3                	mov    %esi,%ebx
  801191:	89 fa                	mov    %edi,%edx
  801193:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801197:	89 34 24             	mov    %esi,(%esp)
  80119a:	85 c0                	test   %eax,%eax
  80119c:	75 1a                	jne    8011b8 <__umoddi3+0x48>
  80119e:	39 f7                	cmp    %esi,%edi
  8011a0:	0f 86 a2 00 00 00    	jbe    801248 <__umoddi3+0xd8>
  8011a6:	89 c8                	mov    %ecx,%eax
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	f7 f7                	div    %edi
  8011ac:	89 d0                	mov    %edx,%eax
  8011ae:	31 d2                	xor    %edx,%edx
  8011b0:	83 c4 1c             	add    $0x1c,%esp
  8011b3:	5b                   	pop    %ebx
  8011b4:	5e                   	pop    %esi
  8011b5:	5f                   	pop    %edi
  8011b6:	5d                   	pop    %ebp
  8011b7:	c3                   	ret    
  8011b8:	39 f0                	cmp    %esi,%eax
  8011ba:	0f 87 ac 00 00 00    	ja     80126c <__umoddi3+0xfc>
  8011c0:	0f bd e8             	bsr    %eax,%ebp
  8011c3:	83 f5 1f             	xor    $0x1f,%ebp
  8011c6:	0f 84 ac 00 00 00    	je     801278 <__umoddi3+0x108>
  8011cc:	bf 20 00 00 00       	mov    $0x20,%edi
  8011d1:	29 ef                	sub    %ebp,%edi
  8011d3:	89 fe                	mov    %edi,%esi
  8011d5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011d9:	89 e9                	mov    %ebp,%ecx
  8011db:	d3 e0                	shl    %cl,%eax
  8011dd:	89 d7                	mov    %edx,%edi
  8011df:	89 f1                	mov    %esi,%ecx
  8011e1:	d3 ef                	shr    %cl,%edi
  8011e3:	09 c7                	or     %eax,%edi
  8011e5:	89 e9                	mov    %ebp,%ecx
  8011e7:	d3 e2                	shl    %cl,%edx
  8011e9:	89 14 24             	mov    %edx,(%esp)
  8011ec:	89 d8                	mov    %ebx,%eax
  8011ee:	d3 e0                	shl    %cl,%eax
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011f6:	d3 e0                	shl    %cl,%eax
  8011f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fc:	8b 44 24 08          	mov    0x8(%esp),%eax
  801200:	89 f1                	mov    %esi,%ecx
  801202:	d3 e8                	shr    %cl,%eax
  801204:	09 d0                	or     %edx,%eax
  801206:	d3 eb                	shr    %cl,%ebx
  801208:	89 da                	mov    %ebx,%edx
  80120a:	f7 f7                	div    %edi
  80120c:	89 d3                	mov    %edx,%ebx
  80120e:	f7 24 24             	mull   (%esp)
  801211:	89 c6                	mov    %eax,%esi
  801213:	89 d1                	mov    %edx,%ecx
  801215:	39 d3                	cmp    %edx,%ebx
  801217:	0f 82 87 00 00 00    	jb     8012a4 <__umoddi3+0x134>
  80121d:	0f 84 91 00 00 00    	je     8012b4 <__umoddi3+0x144>
  801223:	8b 54 24 04          	mov    0x4(%esp),%edx
  801227:	29 f2                	sub    %esi,%edx
  801229:	19 cb                	sbb    %ecx,%ebx
  80122b:	89 d8                	mov    %ebx,%eax
  80122d:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  801231:	d3 e0                	shl    %cl,%eax
  801233:	89 e9                	mov    %ebp,%ecx
  801235:	d3 ea                	shr    %cl,%edx
  801237:	09 d0                	or     %edx,%eax
  801239:	89 e9                	mov    %ebp,%ecx
  80123b:	d3 eb                	shr    %cl,%ebx
  80123d:	89 da                	mov    %ebx,%edx
  80123f:	83 c4 1c             	add    $0x1c,%esp
  801242:	5b                   	pop    %ebx
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    
  801247:	90                   	nop
  801248:	89 fd                	mov    %edi,%ebp
  80124a:	85 ff                	test   %edi,%edi
  80124c:	75 0b                	jne    801259 <__umoddi3+0xe9>
  80124e:	b8 01 00 00 00       	mov    $0x1,%eax
  801253:	31 d2                	xor    %edx,%edx
  801255:	f7 f7                	div    %edi
  801257:	89 c5                	mov    %eax,%ebp
  801259:	89 f0                	mov    %esi,%eax
  80125b:	31 d2                	xor    %edx,%edx
  80125d:	f7 f5                	div    %ebp
  80125f:	89 c8                	mov    %ecx,%eax
  801261:	f7 f5                	div    %ebp
  801263:	89 d0                	mov    %edx,%eax
  801265:	e9 44 ff ff ff       	jmp    8011ae <__umoddi3+0x3e>
  80126a:	66 90                	xchg   %ax,%ax
  80126c:	89 c8                	mov    %ecx,%eax
  80126e:	89 f2                	mov    %esi,%edx
  801270:	83 c4 1c             	add    $0x1c,%esp
  801273:	5b                   	pop    %ebx
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	3b 04 24             	cmp    (%esp),%eax
  80127b:	72 06                	jb     801283 <__umoddi3+0x113>
  80127d:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801281:	77 0f                	ja     801292 <__umoddi3+0x122>
  801283:	89 f2                	mov    %esi,%edx
  801285:	29 f9                	sub    %edi,%ecx
  801287:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  80128b:	89 14 24             	mov    %edx,(%esp)
  80128e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801292:	8b 44 24 04          	mov    0x4(%esp),%eax
  801296:	8b 14 24             	mov    (%esp),%edx
  801299:	83 c4 1c             	add    $0x1c,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    
  8012a1:	8d 76 00             	lea    0x0(%esi),%esi
  8012a4:	2b 04 24             	sub    (%esp),%eax
  8012a7:	19 fa                	sbb    %edi,%edx
  8012a9:	89 d1                	mov    %edx,%ecx
  8012ab:	89 c6                	mov    %eax,%esi
  8012ad:	e9 71 ff ff ff       	jmp    801223 <__umoddi3+0xb3>
  8012b2:	66 90                	xchg   %ax,%ax
  8012b4:	39 44 24 04          	cmp    %eax,0x4(%esp)
  8012b8:	72 ea                	jb     8012a4 <__umoddi3+0x134>
  8012ba:	89 d9                	mov    %ebx,%ecx
  8012bc:	e9 62 ff ff ff       	jmp    801223 <__umoddi3+0xb3>
