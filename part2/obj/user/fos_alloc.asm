
obj/user/fos_alloc:     file format elf32-i386


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
  800031:	e8 c3 01 00 00       	call   8001f9 <libmain>
1:      jmp 1b
  800036:	eb fe                	jmp    800036 <args_exist+0x5>

00800038 <_main>:

#include <inc/lib.h>

void
_main(void)
{	
  800038:	55                   	push   %ebp
  800039:	89 e5                	mov    %esp,%ebp
  80003b:	53                   	push   %ebx
  80003c:	83 ec 24             	sub    $0x24,%esp
	int size = 10 ;
  80003f:	c7 45 f0 0a 00 00 00 	movl   $0xa,-0x10(%ebp)
	int *x = malloc(sizeof(int)*size) ;
  800046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800049:	c1 e0 02             	shl    $0x2,%eax
  80004c:	83 ec 0c             	sub    $0xc,%esp
  80004f:	50                   	push   %eax
  800050:	e8 81 0e 00 00       	call   800ed6 <malloc>
  800055:	83 c4 10             	add    $0x10,%esp
  800058:	89 45 ec             	mov    %eax,-0x14(%ebp)
	int *y = malloc(sizeof(int)*size) ;
  80005b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80005e:	c1 e0 02             	shl    $0x2,%eax
  800061:	83 ec 0c             	sub    $0xc,%esp
  800064:	50                   	push   %eax
  800065:	e8 6c 0e 00 00       	call   800ed6 <malloc>
  80006a:	83 c4 10             	add    $0x10,%esp
  80006d:	89 45 e8             	mov    %eax,-0x18(%ebp)
	int *z = malloc(sizeof(int)*size) ;
  800070:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800073:	c1 e0 02             	shl    $0x2,%eax
  800076:	83 ec 0c             	sub    $0xc,%esp
  800079:	50                   	push   %eax
  80007a:	e8 57 0e 00 00       	call   800ed6 <malloc>
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	int i ;
	for (i = 0 ; i < size ; i++)
  800085:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  80008c:	eb 62                	jmp    8000f0 <_main+0xb8>
	{
		x[i] = i ;
  80008e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800091:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800098:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80009b:	01 c2                	add    %eax,%edx
  80009d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a0:	89 02                	mov    %eax,(%edx)
		y[i] = 10 ;
  8000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000ac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000af:	01 d0                	add    %edx,%eax
  8000b1:	c7 00 0a 00 00 00    	movl   $0xa,(%eax)
		z[i] = (int)x[i]  * y[i]  ;
  8000b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000c4:	01 c2                	add    %eax,%edx
  8000c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000c9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8000d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8000d3:	01 c8                	add    %ecx,%eax
  8000d5:	8b 08                	mov    (%eax),%ecx
  8000d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000da:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  8000e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8000e4:	01 d8                	add    %ebx,%eax
  8000e6:	8b 00                	mov    (%eax),%eax
  8000e8:	0f af c1             	imul   %ecx,%eax
  8000eb:	89 02                	mov    %eax,(%edx)
	int *x = malloc(sizeof(int)*size) ;
	int *y = malloc(sizeof(int)*size) ;
	int *z = malloc(sizeof(int)*size) ;

	int i ;
	for (i = 0 ; i < size ; i++)
  8000ed:	ff 45 f4             	incl   -0xc(%ebp)
  8000f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8000f6:	7c 96                	jl     80008e <_main+0x56>
		x[i] = i ;
		y[i] = 10 ;
		z[i] = (int)x[i]  * y[i]  ;
	}
	
	for (i = 0 ; i < size ; i++)
  8000f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  8000ff:	eb 46                	jmp    800147 <_main+0x10f>
		cprintf("%d * %d = %d\n",x[i], y[i], z[i]);
  800101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800104:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80010b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80010e:	01 d0                	add    %edx,%eax
  800110:	8b 08                	mov    (%eax),%ecx
  800112:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80011c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80011f:	01 d0                	add    %edx,%eax
  800121:	8b 10                	mov    (%eax),%edx
  800123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800126:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
  80012d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800130:	01 d8                	add    %ebx,%eax
  800132:	8b 00                	mov    (%eax),%eax
  800134:	51                   	push   %ecx
  800135:	52                   	push   %edx
  800136:	50                   	push   %eax
  800137:	68 60 13 80 00       	push   $0x801360
  80013c:	e8 d0 01 00 00       	call   800311 <cprintf>
  800141:	83 c4 10             	add    $0x10,%esp
		x[i] = i ;
		y[i] = 10 ;
		z[i] = (int)x[i]  * y[i]  ;
	}
	
	for (i = 0 ; i < size ; i++)
  800144:	ff 45 f4             	incl   -0xc(%ebp)
  800147:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80014a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80014d:	7c b2                	jl     800101 <_main+0xc9>
		cprintf("%d * %d = %d\n",x[i], y[i], z[i]);
	
	freeHeap();
  80014f:	e8 9c 0d 00 00       	call   800ef0 <freeHeap>
	cprintf("the heap is freed successfully\n");
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	68 70 13 80 00       	push   $0x801370
  80015c:	e8 b0 01 00 00       	call   800311 <cprintf>
  800161:	83 c4 10             	add    $0x10,%esp
	z = malloc(sizeof(int)*size) ;
  800164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800167:	c1 e0 02             	shl    $0x2,%eax
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	50                   	push   %eax
  80016e:	e8 63 0d 00 00       	call   800ed6 <malloc>
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0 ; i < size ; i++)
  800179:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  800180:	eb 69                	jmp    8001eb <_main+0x1b3>
	{
		cprintf("x[i] = %d\t",x[i]);
  800182:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800185:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80018c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80018f:	01 d0                	add    %edx,%eax
  800191:	8b 00                	mov    (%eax),%eax
  800193:	83 ec 08             	sub    $0x8,%esp
  800196:	50                   	push   %eax
  800197:	68 90 13 80 00       	push   $0x801390
  80019c:	e8 70 01 00 00       	call   800311 <cprintf>
  8001a1:	83 c4 10             	add    $0x10,%esp
		cprintf("y[i] = %d\t",y[i]);
  8001a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ae:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8001b1:	01 d0                	add    %edx,%eax
  8001b3:	8b 00                	mov    (%eax),%eax
  8001b5:	83 ec 08             	sub    $0x8,%esp
  8001b8:	50                   	push   %eax
  8001b9:	68 9b 13 80 00       	push   $0x80139b
  8001be:	e8 4e 01 00 00       	call   800311 <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
		cprintf("z[i] = %d\n",z[i]);
  8001c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001c9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8001d3:	01 d0                	add    %edx,%eax
  8001d5:	8b 00                	mov    (%eax),%eax
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	50                   	push   %eax
  8001db:	68 a6 13 80 00       	push   $0x8013a6
  8001e0:	e8 2c 01 00 00       	call   800311 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp
		cprintf("%d * %d = %d\n",x[i], y[i], z[i]);
	
	freeHeap();
	cprintf("the heap is freed successfully\n");
	z = malloc(sizeof(int)*size) ;
	for (i = 0 ; i < size ; i++)
  8001e8:	ff 45 f4             	incl   -0xc(%ebp)
  8001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001ee:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8001f1:	7c 8f                	jl     800182 <_main+0x14a>
		cprintf("y[i] = %d\t",y[i]);
		cprintf("z[i] = %d\n",z[i]);
	
	}

	return;	
  8001f3:	90                   	nop
}
  8001f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <libmain>:
volatile struct Env *env;
char *binaryname = "(PROGRAM NAME UNKNOWN)";

void
libmain(int argc, char **argv)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	83 ec 08             	sub    $0x8,%esp
	// set env to point at our env structure in envs[].
	// LAB 3: Your code here.
	env = envs;
  8001ff:	c7 05 08 20 80 00 00 	movl   $0xeec00000,0x802008
  800206:	00 c0 ee 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800209:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80020d:	7e 0a                	jle    800219 <libmain+0x20>
		binaryname = argv[0];
  80020f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800212:	8b 00                	mov    (%eax),%eax
  800214:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	_main(argc, argv);
  800219:	83 ec 08             	sub    $0x8,%esp
  80021c:	ff 75 0c             	pushl  0xc(%ebp)
  80021f:	ff 75 08             	pushl  0x8(%ebp)
  800222:	e8 11 fe ff ff       	call   800038 <_main>
  800227:	83 c4 10             	add    $0x10,%esp

	// exit gracefully
	//exit();
	sleep();
  80022a:	e8 19 00 00 00       	call   800248 <sleep>
}
  80022f:	90                   	nop
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	83 ec 08             	sub    $0x8,%esp
	sys_env_destroy(0);	
  800238:	83 ec 0c             	sub    $0xc,%esp
  80023b:	6a 00                	push   $0x0
  80023d:	e8 29 0d 00 00       	call   800f6b <sys_env_destroy>
  800242:	83 c4 10             	add    $0x10,%esp
}
  800245:	90                   	nop
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <sleep>:

void
sleep(void)
{	
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	sys_env_sleep();
  80024e:	e8 4c 0d 00 00       	call   800f9f <sys_env_sleep>
}
  800253:	90                   	nop
  800254:	c9                   	leave  
  800255:	c3                   	ret    

00800256 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	83 ec 08             	sub    $0x8,%esp
	b->buf[b->idx++] = ch;
  80025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025f:	8b 00                	mov    (%eax),%eax
  800261:	8d 48 01             	lea    0x1(%eax),%ecx
  800264:	8b 55 0c             	mov    0xc(%ebp),%edx
  800267:	89 0a                	mov    %ecx,(%edx)
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	88 d1                	mov    %dl,%cl
  80026e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800271:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
  800278:	8b 00                	mov    (%eax),%eax
  80027a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027f:	75 23                	jne    8002a4 <putch+0x4e>
		sys_cputs(b->buf, b->idx);
  800281:	8b 45 0c             	mov    0xc(%ebp),%eax
  800284:	8b 00                	mov    (%eax),%eax
  800286:	89 c2                	mov    %eax,%edx
  800288:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028b:	83 c0 08             	add    $0x8,%eax
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	e8 9d 0c 00 00       	call   800f35 <sys_cputs>
  800298:	83 c4 10             	add    $0x10,%esp
		b->idx = 0;
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	8b 40 04             	mov    0x4(%eax),%eax
  8002aa:	8d 50 01             	lea    0x1(%eax),%edx
  8002ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b0:	89 50 04             	mov    %edx,0x4(%eax)
}
  8002b3:	90                   	nop
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c6:	00 00 00 
	b.cnt = 0;
  8002c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d3:	ff 75 0c             	pushl  0xc(%ebp)
  8002d6:	ff 75 08             	pushl  0x8(%ebp)
  8002d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002df:	50                   	push   %eax
  8002e0:	68 56 02 80 00       	push   $0x800256
  8002e5:	e8 ca 01 00 00       	call   8004b4 <vprintfmt>
  8002ea:	83 c4 10             	add    $0x10,%esp
	sys_cputs(b.buf, b.idx);
  8002ed:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002f3:	83 ec 08             	sub    $0x8,%esp
  8002f6:	50                   	push   %eax
  8002f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002fd:	83 c0 08             	add    $0x8,%eax
  800300:	50                   	push   %eax
  800301:	e8 2f 0c 00 00       	call   800f35 <sys_cputs>
  800306:	83 c4 10             	add    $0x10,%esp

	return b.cnt;
  800309:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80030f:	c9                   	leave  
  800310:	c3                   	ret    

00800311 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800317:	8d 45 0c             	lea    0xc(%ebp),%eax
  80031a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	cnt = vcprintf(fmt, ap);
  80031d:	8b 45 08             	mov    0x8(%ebp),%eax
  800320:	83 ec 08             	sub    $0x8,%esp
  800323:	ff 75 f4             	pushl  -0xc(%ebp)
  800326:	50                   	push   %eax
  800327:	e8 8a ff ff ff       	call   8002b6 <vcprintf>
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return cnt;
  800332:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	53                   	push   %ebx
  80033b:	83 ec 14             	sub    $0x14,%esp
  80033e:	8b 45 10             	mov    0x10(%ebp),%eax
  800341:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800344:	8b 45 14             	mov    0x14(%ebp),%eax
  800347:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 45 18             	mov    0x18(%ebp),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800355:	77 55                	ja     8003ac <printnum+0x75>
  800357:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80035a:	72 05                	jb     800361 <printnum+0x2a>
  80035c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80035f:	77 4b                	ja     8003ac <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800364:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800367:	8b 45 18             	mov    0x18(%ebp),%eax
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	52                   	push   %edx
  800370:	50                   	push   %eax
  800371:	ff 75 f4             	pushl  -0xc(%ebp)
  800374:	ff 75 f0             	pushl  -0x10(%ebp)
  800377:	e8 7c 0d 00 00       	call   8010f8 <__udivdi3>
  80037c:	83 c4 10             	add    $0x10,%esp
  80037f:	83 ec 04             	sub    $0x4,%esp
  800382:	ff 75 20             	pushl  0x20(%ebp)
  800385:	53                   	push   %ebx
  800386:	ff 75 18             	pushl  0x18(%ebp)
  800389:	52                   	push   %edx
  80038a:	50                   	push   %eax
  80038b:	ff 75 0c             	pushl  0xc(%ebp)
  80038e:	ff 75 08             	pushl  0x8(%ebp)
  800391:	e8 a1 ff ff ff       	call   800337 <printnum>
  800396:	83 c4 20             	add    $0x20,%esp
  800399:	eb 1a                	jmp    8003b5 <printnum+0x7e>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 20             	pushl  0x20(%ebp)
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	ff d0                	call   *%eax
  8003a9:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ac:	ff 4d 1c             	decl   0x1c(%ebp)
  8003af:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8003b3:	7f e6                	jg     80039b <printnum+0x64>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b5:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8003b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8003c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8003c3:	53                   	push   %ebx
  8003c4:	51                   	push   %ecx
  8003c5:	52                   	push   %edx
  8003c6:	50                   	push   %eax
  8003c7:	e8 3c 0e 00 00       	call   801208 <__umoddi3>
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	05 80 14 80 00       	add    $0x801480,%eax
  8003d4:	8a 00                	mov    (%eax),%al
  8003d6:	0f be c0             	movsbl %al,%eax
  8003d9:	83 ec 08             	sub    $0x8,%esp
  8003dc:	ff 75 0c             	pushl  0xc(%ebp)
  8003df:	50                   	push   %eax
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	ff d0                	call   *%eax
  8003e5:	83 c4 10             	add    $0x10,%esp
}
  8003e8:	90                   	nop
  8003e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003f1:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8003f5:	7e 1c                	jle    800413 <getuint+0x25>
		return va_arg(*ap, unsigned long long);
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	8b 00                	mov    (%eax),%eax
  8003fc:	8d 50 08             	lea    0x8(%eax),%edx
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800402:	89 10                	mov    %edx,(%eax)
  800404:	8b 45 08             	mov    0x8(%ebp),%eax
  800407:	8b 00                	mov    (%eax),%eax
  800409:	83 e8 08             	sub    $0x8,%eax
  80040c:	8b 50 04             	mov    0x4(%eax),%edx
  80040f:	8b 00                	mov    (%eax),%eax
  800411:	eb 40                	jmp    800453 <getuint+0x65>
	else if (lflag)
  800413:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800417:	74 1e                	je     800437 <getuint+0x49>
		return va_arg(*ap, unsigned long);
  800419:	8b 45 08             	mov    0x8(%ebp),%eax
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	8d 50 04             	lea    0x4(%eax),%edx
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
  800424:	89 10                	mov    %edx,(%eax)
  800426:	8b 45 08             	mov    0x8(%ebp),%eax
  800429:	8b 00                	mov    (%eax),%eax
  80042b:	83 e8 04             	sub    $0x4,%eax
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	ba 00 00 00 00       	mov    $0x0,%edx
  800435:	eb 1c                	jmp    800453 <getuint+0x65>
	else
		return va_arg(*ap, unsigned int);
  800437:	8b 45 08             	mov    0x8(%ebp),%eax
  80043a:	8b 00                	mov    (%eax),%eax
  80043c:	8d 50 04             	lea    0x4(%eax),%edx
  80043f:	8b 45 08             	mov    0x8(%ebp),%eax
  800442:	89 10                	mov    %edx,(%eax)
  800444:	8b 45 08             	mov    0x8(%ebp),%eax
  800447:	8b 00                	mov    (%eax),%eax
  800449:	83 e8 04             	sub    $0x4,%eax
  80044c:	8b 00                	mov    (%eax),%eax
  80044e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    

00800455 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800455:	55                   	push   %ebp
  800456:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800458:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80045c:	7e 1c                	jle    80047a <getint+0x25>
		return va_arg(*ap, long long);
  80045e:	8b 45 08             	mov    0x8(%ebp),%eax
  800461:	8b 00                	mov    (%eax),%eax
  800463:	8d 50 08             	lea    0x8(%eax),%edx
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 10                	mov    %edx,(%eax)
  80046b:	8b 45 08             	mov    0x8(%ebp),%eax
  80046e:	8b 00                	mov    (%eax),%eax
  800470:	83 e8 08             	sub    $0x8,%eax
  800473:	8b 50 04             	mov    0x4(%eax),%edx
  800476:	8b 00                	mov    (%eax),%eax
  800478:	eb 38                	jmp    8004b2 <getint+0x5d>
	else if (lflag)
  80047a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80047e:	74 1a                	je     80049a <getint+0x45>
		return va_arg(*ap, long);
  800480:	8b 45 08             	mov    0x8(%ebp),%eax
  800483:	8b 00                	mov    (%eax),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	8b 45 08             	mov    0x8(%ebp),%eax
  80048b:	89 10                	mov    %edx,(%eax)
  80048d:	8b 45 08             	mov    0x8(%ebp),%eax
  800490:	8b 00                	mov    (%eax),%eax
  800492:	83 e8 04             	sub    $0x4,%eax
  800495:	8b 00                	mov    (%eax),%eax
  800497:	99                   	cltd   
  800498:	eb 18                	jmp    8004b2 <getint+0x5d>
	else
		return va_arg(*ap, int);
  80049a:	8b 45 08             	mov    0x8(%ebp),%eax
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	8d 50 04             	lea    0x4(%eax),%edx
  8004a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a5:	89 10                	mov    %edx,(%eax)
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	83 e8 04             	sub    $0x4,%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	99                   	cltd   
}
  8004b2:	5d                   	pop    %ebp
  8004b3:	c3                   	ret    

008004b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004b4:	55                   	push   %ebp
  8004b5:	89 e5                	mov    %esp,%ebp
  8004b7:	56                   	push   %esi
  8004b8:	53                   	push   %ebx
  8004b9:	83 ec 20             	sub    $0x20,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004bc:	eb 17                	jmp    8004d5 <vprintfmt+0x21>
			if (ch == '\0')
  8004be:	85 db                	test   %ebx,%ebx
  8004c0:	0f 84 af 03 00 00    	je     800875 <vprintfmt+0x3c1>
				return;
			putch(ch, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	53                   	push   %ebx
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	ff d0                	call   *%eax
  8004d2:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004d8:	8d 50 01             	lea    0x1(%eax),%edx
  8004db:	89 55 10             	mov    %edx,0x10(%ebp)
  8004de:	8a 00                	mov    (%eax),%al
  8004e0:	0f b6 d8             	movzbl %al,%ebx
  8004e3:	83 fb 25             	cmp    $0x25,%ebx
  8004e6:	75 d6                	jne    8004be <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  8004e8:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  8004ec:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  8004f3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004fa:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800501:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800508:	8b 45 10             	mov    0x10(%ebp),%eax
  80050b:	8d 50 01             	lea    0x1(%eax),%edx
  80050e:	89 55 10             	mov    %edx,0x10(%ebp)
  800511:	8a 00                	mov    (%eax),%al
  800513:	0f b6 d8             	movzbl %al,%ebx
  800516:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800519:	83 f8 55             	cmp    $0x55,%eax
  80051c:	0f 87 2b 03 00 00    	ja     80084d <vprintfmt+0x399>
  800522:	8b 04 85 a4 14 80 00 	mov    0x8014a4(,%eax,4),%eax
  800529:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80052b:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80052f:	eb d7                	jmp    800508 <vprintfmt+0x54>
			
		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800531:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800535:	eb d1                	jmp    800508 <vprintfmt+0x54>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800537:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80053e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800541:	89 d0                	mov    %edx,%eax
  800543:	c1 e0 02             	shl    $0x2,%eax
  800546:	01 d0                	add    %edx,%eax
  800548:	01 c0                	add    %eax,%eax
  80054a:	01 d8                	add    %ebx,%eax
  80054c:	83 e8 30             	sub    $0x30,%eax
  80054f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800552:	8b 45 10             	mov    0x10(%ebp),%eax
  800555:	8a 00                	mov    (%eax),%al
  800557:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80055a:	83 fb 2f             	cmp    $0x2f,%ebx
  80055d:	7e 3e                	jle    80059d <vprintfmt+0xe9>
  80055f:	83 fb 39             	cmp    $0x39,%ebx
  800562:	7f 39                	jg     80059d <vprintfmt+0xe9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800564:	ff 45 10             	incl   0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800567:	eb d5                	jmp    80053e <vprintfmt+0x8a>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	83 e8 04             	sub    $0x4,%eax
  800578:	8b 00                	mov    (%eax),%eax
  80057a:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80057d:	eb 1f                	jmp    80059e <vprintfmt+0xea>

		case '.':
			if (width < 0)
  80057f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800583:	79 83                	jns    800508 <vprintfmt+0x54>
				width = 0;
  800585:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  80058c:	e9 77 ff ff ff       	jmp    800508 <vprintfmt+0x54>

		case '#':
			altflag = 1;
  800591:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800598:	e9 6b ff ff ff       	jmp    800508 <vprintfmt+0x54>
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
			goto process_precision;
  80059d:	90                   	nop
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80059e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a2:	0f 89 60 ff ff ff    	jns    800508 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8005b5:	e9 4e ff ff ff       	jmp    800508 <vprintfmt+0x54>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ba:	ff 45 e8             	incl   -0x18(%ebp)
			goto reswitch;
  8005bd:	e9 46 ff ff ff       	jmp    800508 <vprintfmt+0x54>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	83 c0 04             	add    $0x4,%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	83 e8 04             	sub    $0x4,%eax
  8005d1:	8b 00                	mov    (%eax),%eax
  8005d3:	83 ec 08             	sub    $0x8,%esp
  8005d6:	ff 75 0c             	pushl  0xc(%ebp)
  8005d9:	50                   	push   %eax
  8005da:	8b 45 08             	mov    0x8(%ebp),%eax
  8005dd:	ff d0                	call   *%eax
  8005df:	83 c4 10             	add    $0x10,%esp
			break;
  8005e2:	e9 89 02 00 00       	jmp    800870 <vprintfmt+0x3bc>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ea:	83 c0 04             	add    $0x4,%eax
  8005ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	83 e8 04             	sub    $0x4,%eax
  8005f6:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	79 02                	jns    8005fe <vprintfmt+0x14a>
				err = -err;
  8005fc:	f7 db                	neg    %ebx
			if (err > MAXERROR || (p = error_string[err]) == NULL)
  8005fe:	83 fb 07             	cmp    $0x7,%ebx
  800601:	7f 0b                	jg     80060e <vprintfmt+0x15a>
  800603:	8b 34 9d 60 14 80 00 	mov    0x801460(,%ebx,4),%esi
  80060a:	85 f6                	test   %esi,%esi
  80060c:	75 19                	jne    800627 <vprintfmt+0x173>
				printfmt(putch, putdat, "error %d", err);
  80060e:	53                   	push   %ebx
  80060f:	68 91 14 80 00       	push   $0x801491
  800614:	ff 75 0c             	pushl  0xc(%ebp)
  800617:	ff 75 08             	pushl  0x8(%ebp)
  80061a:	e8 5e 02 00 00       	call   80087d <printfmt>
  80061f:	83 c4 10             	add    $0x10,%esp
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800622:	e9 49 02 00 00       	jmp    800870 <vprintfmt+0x3bc>
			if (err < 0)
				err = -err;
			if (err > MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800627:	56                   	push   %esi
  800628:	68 9a 14 80 00       	push   $0x80149a
  80062d:	ff 75 0c             	pushl  0xc(%ebp)
  800630:	ff 75 08             	pushl  0x8(%ebp)
  800633:	e8 45 02 00 00       	call   80087d <printfmt>
  800638:	83 c4 10             	add    $0x10,%esp
			break;
  80063b:	e9 30 02 00 00       	jmp    800870 <vprintfmt+0x3bc>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	83 c0 04             	add    $0x4,%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	83 e8 04             	sub    $0x4,%eax
  80064f:	8b 30                	mov    (%eax),%esi
  800651:	85 f6                	test   %esi,%esi
  800653:	75 05                	jne    80065a <vprintfmt+0x1a6>
				p = "(null)";
  800655:	be 9d 14 80 00       	mov    $0x80149d,%esi
			if (width > 0 && padc != '-')
  80065a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80065e:	7e 6d                	jle    8006cd <vprintfmt+0x219>
  800660:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800664:	74 67                	je     8006cd <vprintfmt+0x219>
				for (width -= strnlen(p, precision); width > 0; width--)
  800666:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	50                   	push   %eax
  80066d:	56                   	push   %esi
  80066e:	e8 0c 03 00 00       	call   80097f <strnlen>
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  800679:	eb 16                	jmp    800691 <vprintfmt+0x1dd>
					putch(padc, putdat);
  80067b:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	ff 75 0c             	pushl  0xc(%ebp)
  800685:	50                   	push   %eax
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	ff d0                	call   *%eax
  80068b:	83 c4 10             	add    $0x10,%esp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80068e:	ff 4d e4             	decl   -0x1c(%ebp)
  800691:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800695:	7f e4                	jg     80067b <vprintfmt+0x1c7>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800697:	eb 34                	jmp    8006cd <vprintfmt+0x219>
				if (altflag && (ch < ' ' || ch > '~'))
  800699:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80069d:	74 1c                	je     8006bb <vprintfmt+0x207>
  80069f:	83 fb 1f             	cmp    $0x1f,%ebx
  8006a2:	7e 05                	jle    8006a9 <vprintfmt+0x1f5>
  8006a4:	83 fb 7e             	cmp    $0x7e,%ebx
  8006a7:	7e 12                	jle    8006bb <vprintfmt+0x207>
					putch('?', putdat);
  8006a9:	83 ec 08             	sub    $0x8,%esp
  8006ac:	ff 75 0c             	pushl  0xc(%ebp)
  8006af:	6a 3f                	push   $0x3f
  8006b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b4:	ff d0                	call   *%eax
  8006b6:	83 c4 10             	add    $0x10,%esp
  8006b9:	eb 0f                	jmp    8006ca <vprintfmt+0x216>
				else
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	53                   	push   %ebx
  8006c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c5:	ff d0                	call   *%eax
  8006c7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ca:	ff 4d e4             	decl   -0x1c(%ebp)
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	8d 70 01             	lea    0x1(%eax),%esi
  8006d2:	8a 00                	mov    (%eax),%al
  8006d4:	0f be d8             	movsbl %al,%ebx
  8006d7:	85 db                	test   %ebx,%ebx
  8006d9:	74 24                	je     8006ff <vprintfmt+0x24b>
  8006db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006df:	78 b8                	js     800699 <vprintfmt+0x1e5>
  8006e1:	ff 4d e0             	decl   -0x20(%ebp)
  8006e4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006e8:	79 af                	jns    800699 <vprintfmt+0x1e5>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ea:	eb 13                	jmp    8006ff <vprintfmt+0x24b>
				putch(' ', putdat);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	ff 75 0c             	pushl  0xc(%ebp)
  8006f2:	6a 20                	push   $0x20
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	ff d0                	call   *%eax
  8006f9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fc:	ff 4d e4             	decl   -0x1c(%ebp)
  8006ff:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800703:	7f e7                	jg     8006ec <vprintfmt+0x238>
				putch(' ', putdat);
			break;
  800705:	e9 66 01 00 00       	jmp    800870 <vprintfmt+0x3bc>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	ff 75 e8             	pushl  -0x18(%ebp)
  800710:	8d 45 14             	lea    0x14(%ebp),%eax
  800713:	50                   	push   %eax
  800714:	e8 3c fd ff ff       	call   800455 <getint>
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80071f:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800725:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800728:	85 d2                	test   %edx,%edx
  80072a:	79 23                	jns    80074f <vprintfmt+0x29b>
				putch('-', putdat);
  80072c:	83 ec 08             	sub    $0x8,%esp
  80072f:	ff 75 0c             	pushl  0xc(%ebp)
  800732:	6a 2d                	push   $0x2d
  800734:	8b 45 08             	mov    0x8(%ebp),%eax
  800737:	ff d0                	call   *%eax
  800739:	83 c4 10             	add    $0x10,%esp
				num = -(long long) num;
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800742:	f7 d8                	neg    %eax
  800744:	83 d2 00             	adc    $0x0,%edx
  800747:	f7 da                	neg    %edx
  800749:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80074c:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80074f:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800756:	e9 bc 00 00 00       	jmp    800817 <vprintfmt+0x363>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075b:	83 ec 08             	sub    $0x8,%esp
  80075e:	ff 75 e8             	pushl  -0x18(%ebp)
  800761:	8d 45 14             	lea    0x14(%ebp),%eax
  800764:	50                   	push   %eax
  800765:	e8 84 fc ff ff       	call   8003ee <getuint>
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800770:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  800773:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80077a:	e9 98 00 00 00       	jmp    800817 <vprintfmt+0x363>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80077f:	83 ec 08             	sub    $0x8,%esp
  800782:	ff 75 0c             	pushl  0xc(%ebp)
  800785:	6a 58                	push   $0x58
  800787:	8b 45 08             	mov    0x8(%ebp),%eax
  80078a:	ff d0                	call   *%eax
  80078c:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80078f:	83 ec 08             	sub    $0x8,%esp
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	6a 58                	push   $0x58
  800797:	8b 45 08             	mov    0x8(%ebp),%eax
  80079a:	ff d0                	call   *%eax
  80079c:	83 c4 10             	add    $0x10,%esp
			putch('X', putdat);
  80079f:	83 ec 08             	sub    $0x8,%esp
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	6a 58                	push   $0x58
  8007a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007aa:	ff d0                	call   *%eax
  8007ac:	83 c4 10             	add    $0x10,%esp
			break;
  8007af:	e9 bc 00 00 00       	jmp    800870 <vprintfmt+0x3bc>

		// pointer
		case 'p':
			putch('0', putdat);
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	6a 30                	push   $0x30
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	ff d0                	call   *%eax
  8007c1:	83 c4 10             	add    $0x10,%esp
			putch('x', putdat);
  8007c4:	83 ec 08             	sub    $0x8,%esp
  8007c7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ca:	6a 78                	push   $0x78
  8007cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007cf:	ff d0                	call   *%eax
  8007d1:	83 c4 10             	add    $0x10,%esp
			num = (unsigned long long)
				(uint32) va_arg(ap, void *);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	83 c0 04             	add    $0x4,%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
  8007dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e0:	83 e8 04             	sub    $0x4,%eax
  8007e3:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8007e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uint32) va_arg(ap, void *);
			base = 16;
  8007ef:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  8007f6:	eb 1f                	jmp    800817 <vprintfmt+0x363>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007f8:	83 ec 08             	sub    $0x8,%esp
  8007fb:	ff 75 e8             	pushl  -0x18(%ebp)
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
  800801:	50                   	push   %eax
  800802:	e8 e7 fb ff ff       	call   8003ee <getuint>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80080d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800810:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800817:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  80081b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80081e:	83 ec 04             	sub    $0x4,%esp
  800821:	52                   	push   %edx
  800822:	ff 75 e4             	pushl  -0x1c(%ebp)
  800825:	50                   	push   %eax
  800826:	ff 75 f4             	pushl  -0xc(%ebp)
  800829:	ff 75 f0             	pushl  -0x10(%ebp)
  80082c:	ff 75 0c             	pushl  0xc(%ebp)
  80082f:	ff 75 08             	pushl  0x8(%ebp)
  800832:	e8 00 fb ff ff       	call   800337 <printnum>
  800837:	83 c4 20             	add    $0x20,%esp
			break;
  80083a:	eb 34                	jmp    800870 <vprintfmt+0x3bc>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083c:	83 ec 08             	sub    $0x8,%esp
  80083f:	ff 75 0c             	pushl  0xc(%ebp)
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	ff d0                	call   *%eax
  800848:	83 c4 10             	add    $0x10,%esp
			break;
  80084b:	eb 23                	jmp    800870 <vprintfmt+0x3bc>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	6a 25                	push   $0x25
  800855:	8b 45 08             	mov    0x8(%ebp),%eax
  800858:	ff d0                	call   *%eax
  80085a:	83 c4 10             	add    $0x10,%esp
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085d:	ff 4d 10             	decl   0x10(%ebp)
  800860:	eb 03                	jmp    800865 <vprintfmt+0x3b1>
  800862:	ff 4d 10             	decl   0x10(%ebp)
  800865:	8b 45 10             	mov    0x10(%ebp),%eax
  800868:	48                   	dec    %eax
  800869:	8a 00                	mov    (%eax),%al
  80086b:	3c 25                	cmp    $0x25,%al
  80086d:	75 f3                	jne    800862 <vprintfmt+0x3ae>
				/* do nothing */;
			break;
  80086f:	90                   	nop
		}
	}
  800870:	e9 47 fc ff ff       	jmp    8004bc <vprintfmt+0x8>
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
				return;
  800875:	90                   	nop
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800876:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800879:	5b                   	pop    %ebx
  80087a:	5e                   	pop    %esi
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800883:	8d 45 10             	lea    0x10(%ebp),%eax
  800886:	83 c0 04             	add    $0x4,%eax
  800889:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  80088c:	8b 45 10             	mov    0x10(%ebp),%eax
  80088f:	ff 75 f4             	pushl  -0xc(%ebp)
  800892:	50                   	push   %eax
  800893:	ff 75 0c             	pushl  0xc(%ebp)
  800896:	ff 75 08             	pushl  0x8(%ebp)
  800899:	e8 16 fc ff ff       	call   8004b4 <vprintfmt>
  80089e:	83 c4 10             	add    $0x10,%esp
	va_end(ap);
}
  8008a1:	90                   	nop
  8008a2:	c9                   	leave  
  8008a3:	c3                   	ret    

008008a4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  8008a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008aa:	8b 40 08             	mov    0x8(%eax),%eax
  8008ad:	8d 50 01             	lea    0x1(%eax),%edx
  8008b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b3:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  8008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008b9:	8b 10                	mov    (%eax),%edx
  8008bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008be:	8b 40 04             	mov    0x4(%eax),%eax
  8008c1:	39 c2                	cmp    %eax,%edx
  8008c3:	73 12                	jae    8008d7 <sprintputch+0x33>
		*b->buf++ = ch;
  8008c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c8:	8b 00                	mov    (%eax),%eax
  8008ca:	8d 48 01             	lea    0x1(%eax),%ecx
  8008cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d0:	89 0a                	mov    %ecx,(%edx)
  8008d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8008d5:	88 10                	mov    %dl,(%eax)
}
  8008d7:	90                   	nop
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	83 ec 18             	sub    $0x18,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e9:	8d 50 ff             	lea    -0x1(%eax),%edx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	01 d0                	add    %edx,%eax
  8008f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8008ff:	74 06                	je     800907 <vsnprintf+0x2d>
  800901:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800905:	7f 07                	jg     80090e <vsnprintf+0x34>
		return -E_INVAL;
  800907:	b8 03 00 00 00       	mov    $0x3,%eax
  80090c:	eb 20                	jmp    80092e <vsnprintf+0x54>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80090e:	ff 75 14             	pushl  0x14(%ebp)
  800911:	ff 75 10             	pushl  0x10(%ebp)
  800914:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800917:	50                   	push   %eax
  800918:	68 a4 08 80 00       	push   $0x8008a4
  80091d:	e8 92 fb ff ff       	call   8004b4 <vprintfmt>
  800922:	83 c4 10             	add    $0x10,%esp

	// null terminate the buffer
	*b.buf = '\0';
  800925:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800928:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80092b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800936:	8d 45 10             	lea    0x10(%ebp),%eax
  800939:	83 c0 04             	add    $0x4,%eax
  80093c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  80093f:	8b 45 10             	mov    0x10(%ebp),%eax
  800942:	ff 75 f4             	pushl  -0xc(%ebp)
  800945:	50                   	push   %eax
  800946:	ff 75 0c             	pushl  0xc(%ebp)
  800949:	ff 75 08             	pushl  0x8(%ebp)
  80094c:	e8 89 ff ff ff       	call   8008da <vsnprintf>
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	89 45 f0             	mov    %eax,-0x10(%ebp)
	va_end(ap);

	return rc;
  800957:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  80095a:	c9                   	leave  
  80095b:	c3                   	ret    

0080095c <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800962:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800969:	eb 06                	jmp    800971 <strlen+0x15>
		n++;
  80096b:	ff 45 fc             	incl   -0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80096e:	ff 45 08             	incl   0x8(%ebp)
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8a 00                	mov    (%eax),%al
  800976:	84 c0                	test   %al,%al
  800978:	75 f1                	jne    80096b <strlen+0xf>
		n++;
	return n;
  80097a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <strnlen>:

int
strnlen(const char *s, uint32 size)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800985:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  80098c:	eb 09                	jmp    800997 <strnlen+0x18>
		n++;
  80098e:	ff 45 fc             	incl   -0x4(%ebp)
int
strnlen(const char *s, uint32 size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	ff 45 08             	incl   0x8(%ebp)
  800994:	ff 4d 0c             	decl   0xc(%ebp)
  800997:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80099b:	74 09                	je     8009a6 <strnlen+0x27>
  80099d:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a0:	8a 00                	mov    (%eax),%al
  8009a2:	84 c0                	test   %al,%al
  8009a4:	75 e8                	jne    80098e <strnlen+0xf>
		n++;
	return n;
  8009a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  8009b7:	90                   	nop
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8d 50 01             	lea    0x1(%eax),%edx
  8009be:	89 55 08             	mov    %edx,0x8(%ebp)
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8009c7:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  8009ca:	8a 12                	mov    (%edx),%dl
  8009cc:	88 10                	mov    %dl,(%eax)
  8009ce:	8a 00                	mov    (%eax),%al
  8009d0:	84 c0                	test   %al,%al
  8009d2:	75 e4                	jne    8009b8 <strcpy+0xd>
		/* do nothing */;
	return ret;
  8009d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <strncpy>:

char *
strncpy(char *dst, const char *src, uint32 size) {
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 10             	sub    $0x10,%esp
	uint32 i;
	char *ret;

	ret = dst;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  8009e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  8009ec:	eb 1f                	jmp    800a0d <strncpy+0x34>
		*dst++ = *src;
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8d 50 01             	lea    0x1(%eax),%edx
  8009f4:	89 55 08             	mov    %edx,0x8(%ebp)
  8009f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fa:	8a 12                	mov    (%edx),%dl
  8009fc:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  8009fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a01:	8a 00                	mov    (%eax),%al
  800a03:	84 c0                	test   %al,%al
  800a05:	74 03                	je     800a0a <strncpy+0x31>
			src++;
  800a07:	ff 45 0c             	incl   0xc(%ebp)
strncpy(char *dst, const char *src, uint32 size) {
	uint32 i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0a:	ff 45 fc             	incl   -0x4(%ebp)
  800a0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a10:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a13:	72 d9                	jb     8009ee <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800a15:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <strlcpy>:

uint32
strlcpy(char *dst, const char *src, uint32 size)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800a26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a2a:	74 30                	je     800a5c <strlcpy+0x42>
		while (--size > 0 && *src != '\0')
  800a2c:	eb 16                	jmp    800a44 <strlcpy+0x2a>
			*dst++ = *src++;
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	8d 50 01             	lea    0x1(%eax),%edx
  800a34:	89 55 08             	mov    %edx,0x8(%ebp)
  800a37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800a3d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800a40:	8a 12                	mov    (%edx),%dl
  800a42:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a44:	ff 4d 10             	decl   0x10(%ebp)
  800a47:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800a4b:	74 09                	je     800a56 <strlcpy+0x3c>
  800a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a50:	8a 00                	mov    (%eax),%al
  800a52:	84 c0                	test   %al,%al
  800a54:	75 d8                	jne    800a2e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800a62:	29 c2                	sub    %eax,%edx
  800a64:	89 d0                	mov    %edx,%eax
}
  800a66:	c9                   	leave  
  800a67:	c3                   	ret    

00800a68 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800a6b:	eb 06                	jmp    800a73 <strcmp+0xb>
		p++, q++;
  800a6d:	ff 45 08             	incl   0x8(%ebp)
  800a70:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8a 00                	mov    (%eax),%al
  800a78:	84 c0                	test   %al,%al
  800a7a:	74 0e                	je     800a8a <strcmp+0x22>
  800a7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7f:	8a 10                	mov    (%eax),%dl
  800a81:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a84:	8a 00                	mov    (%eax),%al
  800a86:	38 c2                	cmp    %al,%dl
  800a88:	74 e3                	je     800a6d <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8d:	8a 00                	mov    (%eax),%al
  800a8f:	0f b6 d0             	movzbl %al,%edx
  800a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a95:	8a 00                	mov    (%eax),%al
  800a97:	0f b6 c0             	movzbl %al,%eax
  800a9a:	29 c2                	sub    %eax,%edx
  800a9c:	89 d0                	mov    %edx,%eax
}
  800a9e:	5d                   	pop    %ebp
  800a9f:	c3                   	ret    

00800aa0 <strncmp>:

int
strncmp(const char *p, const char *q, uint32 n)
{
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800aa3:	eb 09                	jmp    800aae <strncmp+0xe>
		n--, p++, q++;
  800aa5:	ff 4d 10             	decl   0x10(%ebp)
  800aa8:	ff 45 08             	incl   0x8(%ebp)
  800aab:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint32 n)
{
	while (n > 0 && *p && *p == *q)
  800aae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ab2:	74 17                	je     800acb <strncmp+0x2b>
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8a 00                	mov    (%eax),%al
  800ab9:	84 c0                	test   %al,%al
  800abb:	74 0e                	je     800acb <strncmp+0x2b>
  800abd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac0:	8a 10                	mov    (%eax),%dl
  800ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac5:	8a 00                	mov    (%eax),%al
  800ac7:	38 c2                	cmp    %al,%dl
  800ac9:	74 da                	je     800aa5 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800acb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800acf:	75 07                	jne    800ad8 <strncmp+0x38>
		return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	eb 14                	jmp    800aec <strncmp+0x4c>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8a 00                	mov    (%eax),%al
  800add:	0f b6 d0             	movzbl %al,%edx
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	8a 00                	mov    (%eax),%al
  800ae5:	0f b6 c0             	movzbl %al,%eax
  800ae8:	29 c2                	sub    %eax,%edx
  800aea:	89 d0                	mov    %edx,%eax
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 04             	sub    $0x4,%esp
  800af4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800afa:	eb 12                	jmp    800b0e <strchr+0x20>
		if (*s == c)
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8a 00                	mov    (%eax),%al
  800b01:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b04:	75 05                	jne    800b0b <strchr+0x1d>
			return (char *) s;
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	eb 11                	jmp    800b1c <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0b:	ff 45 08             	incl   0x8(%ebp)
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	8a 00                	mov    (%eax),%al
  800b13:	84 c0                	test   %al,%al
  800b15:	75 e5                	jne    800afc <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 04             	sub    $0x4,%esp
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800b2a:	eb 0d                	jmp    800b39 <strfind+0x1b>
		if (*s == c)
  800b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2f:	8a 00                	mov    (%eax),%al
  800b31:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800b34:	74 0e                	je     800b44 <strfind+0x26>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b36:	ff 45 08             	incl   0x8(%ebp)
  800b39:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3c:	8a 00                	mov    (%eax),%al
  800b3e:	84 c0                	test   %al,%al
  800b40:	75 ea                	jne    800b2c <strfind+0xe>
  800b42:	eb 01                	jmp    800b45 <strfind+0x27>
		if (*s == c)
			break;
  800b44:	90                   	nop
	return (char *) s;
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b48:	c9                   	leave  
  800b49:	c3                   	ret    

00800b4a <memset>:


void *
memset(void *v, int c, uint32 n)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 10             	sub    $0x10,%esp
	char *p;
	int m;

	p = v;
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	89 45 fc             	mov    %eax,-0x4(%ebp)
	m = n;
  800b56:	8b 45 10             	mov    0x10(%ebp),%eax
  800b59:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (--m >= 0)
  800b5c:	eb 0e                	jmp    800b6c <memset+0x22>
		*p++ = c;
  800b5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800b61:	8d 50 01             	lea    0x1(%eax),%edx
  800b64:	89 55 fc             	mov    %edx,-0x4(%ebp)
  800b67:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b6a:	88 10                	mov    %dl,(%eax)
	char *p;
	int m;

	p = v;
	m = n;
	while (--m >= 0)
  800b6c:	ff 4d f8             	decl   -0x8(%ebp)
  800b6f:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  800b73:	79 e9                	jns    800b5e <memset+0x14>
		*p++ = c;

	return v;
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <memcpy>:

void *
memcpy(void *dst, const void *src, uint32 n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800b80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b83:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	89 45 f8             	mov    %eax,-0x8(%ebp)
	while (n-- > 0)
  800b8c:	eb 16                	jmp    800ba4 <memcpy+0x2a>
		*d++ = *s++;
  800b8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800b91:	8d 50 01             	lea    0x1(%eax),%edx
  800b94:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800b97:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800b9a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800b9d:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800ba0:	8a 12                	mov    (%edx),%dl
  800ba2:	88 10                	mov    %dl,(%eax)
	const char *s;
	char *d;

	s = src;
	d = dst;
	while (n-- > 0)
  800ba4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba7:	8d 50 ff             	lea    -0x1(%eax),%edx
  800baa:	89 55 10             	mov    %edx,0x10(%ebp)
  800bad:	85 c0                	test   %eax,%eax
  800baf:	75 dd                	jne    800b8e <memcpy+0x14>
		*d++ = *s++;

	return dst;
  800bb1:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <memmove>:

void *
memmove(void *dst, const void *src, uint32 n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;
	
	s = src;
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	89 45 fc             	mov    %eax,-0x4(%ebp)
	d = dst;
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	89 45 f8             	mov    %eax,-0x8(%ebp)
	if (s < d && s + n > d) {
  800bc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bcb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bce:	73 50                	jae    800c20 <memmove+0x6a>
  800bd0:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800bd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd6:	01 d0                	add    %edx,%eax
  800bd8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  800bdb:	76 43                	jbe    800c20 <memmove+0x6a>
		s += n;
  800bdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800be0:	01 45 fc             	add    %eax,-0x4(%ebp)
		d += n;
  800be3:	8b 45 10             	mov    0x10(%ebp),%eax
  800be6:	01 45 f8             	add    %eax,-0x8(%ebp)
		while (n-- > 0)
  800be9:	eb 10                	jmp    800bfb <memmove+0x45>
			*--d = *--s;
  800beb:	ff 4d f8             	decl   -0x8(%ebp)
  800bee:	ff 4d fc             	decl   -0x4(%ebp)
  800bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bf4:	8a 10                	mov    (%eax),%dl
  800bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bf9:	88 10                	mov    %dl,(%eax)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
  800bfb:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfe:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c01:	89 55 10             	mov    %edx,0x10(%ebp)
  800c04:	85 c0                	test   %eax,%eax
  800c06:	75 e3                	jne    800beb <memmove+0x35>
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c08:	eb 23                	jmp    800c2d <memmove+0x77>
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
  800c0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c0d:	8d 50 01             	lea    0x1(%eax),%edx
  800c10:	89 55 f8             	mov    %edx,-0x8(%ebp)
  800c13:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c16:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c19:	89 4d fc             	mov    %ecx,-0x4(%ebp)
  800c1c:	8a 12                	mov    (%edx),%dl
  800c1e:	88 10                	mov    %dl,(%eax)
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
  800c20:	8b 45 10             	mov    0x10(%ebp),%eax
  800c23:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c26:	89 55 10             	mov    %edx,0x10(%ebp)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	75 dd                	jne    800c0a <memmove+0x54>
			*d++ = *s++;

	return dst;
  800c2d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c30:	c9                   	leave  
  800c31:	c3                   	ret    

00800c32 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint32 n)
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	83 ec 10             	sub    $0x10,%esp
	const uint8 *s1 = (const uint8 *) v1;
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3b:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8 *s2 = (const uint8 *) v2;
  800c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c41:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800c44:	eb 2a                	jmp    800c70 <memcmp+0x3e>
		if (*s1 != *s2)
  800c46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c49:	8a 10                	mov    (%eax),%dl
  800c4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c4e:	8a 00                	mov    (%eax),%al
  800c50:	38 c2                	cmp    %al,%dl
  800c52:	74 16                	je     800c6a <memcmp+0x38>
			return (int) *s1 - (int) *s2;
  800c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800c57:	8a 00                	mov    (%eax),%al
  800c59:	0f b6 d0             	movzbl %al,%edx
  800c5c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800c5f:	8a 00                	mov    (%eax),%al
  800c61:	0f b6 c0             	movzbl %al,%eax
  800c64:	29 c2                	sub    %eax,%edx
  800c66:	89 d0                	mov    %edx,%eax
  800c68:	eb 18                	jmp    800c82 <memcmp+0x50>
		s1++, s2++;
  800c6a:	ff 45 fc             	incl   -0x4(%ebp)
  800c6d:	ff 45 f8             	incl   -0x8(%ebp)
memcmp(const void *v1, const void *v2, uint32 n)
{
	const uint8 *s1 = (const uint8 *) v1;
	const uint8 *s2 = (const uint8 *) v2;

	while (n-- > 0) {
  800c70:	8b 45 10             	mov    0x10(%ebp),%eax
  800c73:	8d 50 ff             	lea    -0x1(%eax),%edx
  800c76:	89 55 10             	mov    %edx,0x10(%ebp)
  800c79:	85 c0                	test   %eax,%eax
  800c7b:	75 c9                	jne    800c46 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <memfind>:

void *
memfind(const void *s, int c, uint32 n)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c90:	01 d0                	add    %edx,%eax
  800c92:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800c95:	eb 15                	jmp    800cac <memfind+0x28>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8a 00                	mov    (%eax),%al
  800c9c:	0f b6 d0             	movzbl %al,%edx
  800c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca2:	0f b6 c0             	movzbl %al,%eax
  800ca5:	39 c2                	cmp    %eax,%edx
  800ca7:	74 0d                	je     800cb6 <memfind+0x32>

void *
memfind(const void *s, int c, uint32 n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ca9:	ff 45 08             	incl   0x8(%ebp)
  800cac:	8b 45 08             	mov    0x8(%ebp),%eax
  800caf:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  800cb2:	72 e3                	jb     800c97 <memfind+0x13>
  800cb4:	eb 01                	jmp    800cb7 <memfind+0x33>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
  800cb6:	90                   	nop
	return (void *) s;
  800cb7:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cba:	c9                   	leave  
  800cbb:	c3                   	ret    

00800cbc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  800cc2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  800cc9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd0:	eb 03                	jmp    800cd5 <strtol+0x19>
		s++;
  800cd2:	ff 45 08             	incl   0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	8a 00                	mov    (%eax),%al
  800cda:	3c 20                	cmp    $0x20,%al
  800cdc:	74 f4                	je     800cd2 <strtol+0x16>
  800cde:	8b 45 08             	mov    0x8(%ebp),%eax
  800ce1:	8a 00                	mov    (%eax),%al
  800ce3:	3c 09                	cmp    $0x9,%al
  800ce5:	74 eb                	je     800cd2 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cea:	8a 00                	mov    (%eax),%al
  800cec:	3c 2b                	cmp    $0x2b,%al
  800cee:	75 05                	jne    800cf5 <strtol+0x39>
		s++;
  800cf0:	ff 45 08             	incl   0x8(%ebp)
  800cf3:	eb 13                	jmp    800d08 <strtol+0x4c>
	else if (*s == '-')
  800cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf8:	8a 00                	mov    (%eax),%al
  800cfa:	3c 2d                	cmp    $0x2d,%al
  800cfc:	75 0a                	jne    800d08 <strtol+0x4c>
		s++, neg = 1;
  800cfe:	ff 45 08             	incl   0x8(%ebp)
  800d01:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0c:	74 06                	je     800d14 <strtol+0x58>
  800d0e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  800d12:	75 20                	jne    800d34 <strtol+0x78>
  800d14:	8b 45 08             	mov    0x8(%ebp),%eax
  800d17:	8a 00                	mov    (%eax),%al
  800d19:	3c 30                	cmp    $0x30,%al
  800d1b:	75 17                	jne    800d34 <strtol+0x78>
  800d1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d20:	40                   	inc    %eax
  800d21:	8a 00                	mov    (%eax),%al
  800d23:	3c 78                	cmp    $0x78,%al
  800d25:	75 0d                	jne    800d34 <strtol+0x78>
		s += 2, base = 16;
  800d27:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  800d2b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  800d32:	eb 28                	jmp    800d5c <strtol+0xa0>
	else if (base == 0 && s[0] == '0')
  800d34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d38:	75 15                	jne    800d4f <strtol+0x93>
  800d3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3d:	8a 00                	mov    (%eax),%al
  800d3f:	3c 30                	cmp    $0x30,%al
  800d41:	75 0c                	jne    800d4f <strtol+0x93>
		s++, base = 8;
  800d43:	ff 45 08             	incl   0x8(%ebp)
  800d46:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  800d4d:	eb 0d                	jmp    800d5c <strtol+0xa0>
	else if (base == 0)
  800d4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d53:	75 07                	jne    800d5c <strtol+0xa0>
		base = 10;
  800d55:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	8a 00                	mov    (%eax),%al
  800d61:	3c 2f                	cmp    $0x2f,%al
  800d63:	7e 19                	jle    800d7e <strtol+0xc2>
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	8a 00                	mov    (%eax),%al
  800d6a:	3c 39                	cmp    $0x39,%al
  800d6c:	7f 10                	jg     800d7e <strtol+0xc2>
			dig = *s - '0';
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	8a 00                	mov    (%eax),%al
  800d73:	0f be c0             	movsbl %al,%eax
  800d76:	83 e8 30             	sub    $0x30,%eax
  800d79:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d7c:	eb 42                	jmp    800dc0 <strtol+0x104>
		else if (*s >= 'a' && *s <= 'z')
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	8a 00                	mov    (%eax),%al
  800d83:	3c 60                	cmp    $0x60,%al
  800d85:	7e 19                	jle    800da0 <strtol+0xe4>
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	8a 00                	mov    (%eax),%al
  800d8c:	3c 7a                	cmp    $0x7a,%al
  800d8e:	7f 10                	jg     800da0 <strtol+0xe4>
			dig = *s - 'a' + 10;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8a 00                	mov    (%eax),%al
  800d95:	0f be c0             	movsbl %al,%eax
  800d98:	83 e8 57             	sub    $0x57,%eax
  800d9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800d9e:	eb 20                	jmp    800dc0 <strtol+0x104>
		else if (*s >= 'A' && *s <= 'Z')
  800da0:	8b 45 08             	mov    0x8(%ebp),%eax
  800da3:	8a 00                	mov    (%eax),%al
  800da5:	3c 40                	cmp    $0x40,%al
  800da7:	7e 39                	jle    800de2 <strtol+0x126>
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dac:	8a 00                	mov    (%eax),%al
  800dae:	3c 5a                	cmp    $0x5a,%al
  800db0:	7f 30                	jg     800de2 <strtol+0x126>
			dig = *s - 'A' + 10;
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8a 00                	mov    (%eax),%al
  800db7:	0f be c0             	movsbl %al,%eax
  800dba:	83 e8 37             	sub    $0x37,%eax
  800dbd:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  800dc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dc3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800dc6:	7d 19                	jge    800de1 <strtol+0x125>
			break;
		s++, val = (val * base) + dig;
  800dc8:	ff 45 08             	incl   0x8(%ebp)
  800dcb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800dce:	0f af 45 10          	imul   0x10(%ebp),%eax
  800dd2:	89 c2                	mov    %eax,%edx
  800dd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd7:	01 d0                	add    %edx,%eax
  800dd9:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  800ddc:	e9 7b ff ff ff       	jmp    800d5c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
			break;
  800de1:	90                   	nop
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800de2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800de6:	74 08                	je     800df0 <strtol+0x134>
		*endptr = (char *) s;
  800de8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800df0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  800df4:	74 07                	je     800dfd <strtol+0x141>
  800df6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800df9:	f7 d8                	neg    %eax
  800dfb:	eb 03                	jmp    800e00 <strtol+0x144>
  800dfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800e00:	c9                   	leave  
  800e01:	c3                   	ret    

00800e02 <strsplit>:

int strsplit(char *string, char *SPLIT_CHARS, char **argv, int * argc)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
	// Parse the command string into splitchars-separated arguments
	*argc = 0;
  800e05:	8b 45 14             	mov    0x14(%ebp),%eax
  800e08:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	(argv)[*argc] = 0;
  800e0e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e11:	8b 00                	mov    (%eax),%eax
  800e13:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e1a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e1d:	01 d0                	add    %edx,%eax
  800e1f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800e25:	eb 0c                	jmp    800e33 <strsplit+0x31>
			*string++ = 0;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	8d 50 01             	lea    0x1(%eax),%edx
  800e2d:	89 55 08             	mov    %edx,0x8(%ebp)
  800e30:	c6 00 00             	movb   $0x0,(%eax)
	*argc = 0;
	(argv)[*argc] = 0;
	while (1) 
	{
		// trim splitchars
		while (*string && strchr(SPLIT_CHARS, *string))
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	8a 00                	mov    (%eax),%al
  800e38:	84 c0                	test   %al,%al
  800e3a:	74 18                	je     800e54 <strsplit+0x52>
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3f:	8a 00                	mov    (%eax),%al
  800e41:	0f be c0             	movsbl %al,%eax
  800e44:	50                   	push   %eax
  800e45:	ff 75 0c             	pushl  0xc(%ebp)
  800e48:	e8 a1 fc ff ff       	call   800aee <strchr>
  800e4d:	83 c4 08             	add    $0x8,%esp
  800e50:	85 c0                	test   %eax,%eax
  800e52:	75 d3                	jne    800e27 <strsplit+0x25>
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	8a 00                	mov    (%eax),%al
  800e59:	84 c0                	test   %al,%al
  800e5b:	74 5a                	je     800eb7 <strsplit+0xb5>
			break;

		//check current number of arguments
		if (*argc == MAX_ARGUMENTS-1) 
  800e5d:	8b 45 14             	mov    0x14(%ebp),%eax
  800e60:	8b 00                	mov    (%eax),%eax
  800e62:	83 f8 0f             	cmp    $0xf,%eax
  800e65:	75 07                	jne    800e6e <strsplit+0x6c>
		{
			return 0;
  800e67:	b8 00 00 00 00       	mov    $0x0,%eax
  800e6c:	eb 66                	jmp    800ed4 <strsplit+0xd2>
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
  800e6e:	8b 45 14             	mov    0x14(%ebp),%eax
  800e71:	8b 00                	mov    (%eax),%eax
  800e73:	8d 48 01             	lea    0x1(%eax),%ecx
  800e76:	8b 55 14             	mov    0x14(%ebp),%edx
  800e79:	89 0a                	mov    %ecx,(%edx)
  800e7b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800e82:	8b 45 10             	mov    0x10(%ebp),%eax
  800e85:	01 c2                	add    %eax,%edx
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	89 02                	mov    %eax,(%edx)
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e8c:	eb 03                	jmp    800e91 <strsplit+0x8f>
			string++;
  800e8e:	ff 45 08             	incl   0x8(%ebp)
			return 0;
		}
		
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	8a 00                	mov    (%eax),%al
  800e96:	84 c0                	test   %al,%al
  800e98:	74 8b                	je     800e25 <strsplit+0x23>
  800e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9d:	8a 00                	mov    (%eax),%al
  800e9f:	0f be c0             	movsbl %al,%eax
  800ea2:	50                   	push   %eax
  800ea3:	ff 75 0c             	pushl  0xc(%ebp)
  800ea6:	e8 43 fc ff ff       	call   800aee <strchr>
  800eab:	83 c4 08             	add    $0x8,%esp
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	74 dc                	je     800e8e <strsplit+0x8c>
			string++;
	}
  800eb2:	e9 6e ff ff ff       	jmp    800e25 <strsplit+0x23>
		while (*string && strchr(SPLIT_CHARS, *string))
			*string++ = 0;
		
		//if the command string is finished, then break the loop
		if (*string == 0)
			break;
  800eb7:	90                   	nop
		// save the previous argument and scan past next arg
		(argv)[(*argc)++] = string;
		while (*string && !strchr(SPLIT_CHARS, *string))
			string++;
	}
	(argv)[*argc] = 0;
  800eb8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebb:	8b 00                	mov    (%eax),%eax
  800ebd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800ec4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec7:	01 d0                	add    %edx,%eax
  800ec9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return 1 ;
  800ecf:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    

00800ed6 <malloc>:

 
static uint8 *ptr_user_free_mem  = (uint8*) USER_HEAP_START;

void* malloc(uint32 size)
{	
  800ed6:	55                   	push   %ebp
  800ed7:	89 e5                	mov    %esp,%ebp
  800ed9:	83 ec 08             	sub    $0x8,%esp
	//PROJECT 2008: your code here
	//	

	panic("malloc is not implemented yet");
  800edc:	83 ec 04             	sub    $0x4,%esp
  800edf:	68 fc 15 80 00       	push   $0x8015fc
  800ee4:	6a 2b                	push   $0x2b
  800ee6:	68 1a 16 80 00       	push   $0x80161a
  800eeb:	e8 9b 01 00 00       	call   80108b <_panic>

00800ef0 <freeHeap>:
//	freeMem(uint32* ptr_page_directory, void* start_virtual_address, uint32 size) in 
//	"memory_manager.c" then switch back to user mode, the later function is empty, 
//	please go fill it.

void freeHeap()
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 08             	sub    $0x8,%esp
	//PROJECT 2008: your code here
	//	

	panic("freeHeap is not implemented yet");
  800ef6:	83 ec 04             	sub    $0x4,%esp
  800ef9:	68 28 16 80 00       	push   $0x801628
  800efe:	6a 6a                	push   $0x6a
  800f00:	68 1a 16 80 00       	push   $0x80161a
  800f05:	e8 81 01 00 00       	call   80108b <_panic>

00800f0a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline uint32
syscall(int num, uint32 a1, uint32 a2, uint32 a3, uint32 a4, uint32 a5)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	57                   	push   %edi
  800f0e:	56                   	push   %esi
  800f0f:	53                   	push   %ebx
  800f10:	83 ec 10             	sub    $0x10,%esp
	// 
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f19:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f1c:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f1f:	8b 7d 18             	mov    0x18(%ebp),%edi
  800f22:	8b 75 1c             	mov    0x1c(%ebp),%esi
  800f25:	cd 30                	int    $0x30
  800f27:	89 45 f0             	mov    %eax,-0x10(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");
	
	return ret;
  800f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  800f2d:	83 c4 10             	add    $0x10,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_cputs>:

void
sys_cputs(const char *s, uint32 len)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
	syscall(SYS_cputs, (uint32) s, len, 0, 0, 0);
  800f38:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3b:	6a 00                	push   $0x0
  800f3d:	6a 00                	push   $0x0
  800f3f:	6a 00                	push   $0x0
  800f41:	ff 75 0c             	pushl  0xc(%ebp)
  800f44:	50                   	push   %eax
  800f45:	6a 00                	push   $0x0
  800f47:	e8 be ff ff ff       	call   800f0a <syscall>
  800f4c:	83 c4 18             	add    $0x18,%esp
}
  800f4f:	90                   	nop
  800f50:	c9                   	leave  
  800f51:	c3                   	ret    

00800f52 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0);
  800f55:	6a 00                	push   $0x0
  800f57:	6a 00                	push   $0x0
  800f59:	6a 00                	push   $0x0
  800f5b:	6a 00                	push   $0x0
  800f5d:	6a 00                	push   $0x0
  800f5f:	6a 01                	push   $0x1
  800f61:	e8 a4 ff ff ff       	call   800f0a <syscall>
  800f66:	83 c4 18             	add    $0x18,%esp
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <sys_env_destroy>:

int	sys_env_destroy(int32  envid)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_env_destroy, envid, 0, 0, 0, 0);
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	6a 00                	push   $0x0
  800f73:	6a 00                	push   $0x0
  800f75:	6a 00                	push   $0x0
  800f77:	6a 00                	push   $0x0
  800f79:	50                   	push   %eax
  800f7a:	6a 03                	push   $0x3
  800f7c:	e8 89 ff ff ff       	call   800f0a <syscall>
  800f81:	83 c4 18             	add    $0x18,%esp
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <sys_getenvid>:

int32 sys_getenvid(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0);
  800f89:	6a 00                	push   $0x0
  800f8b:	6a 00                	push   $0x0
  800f8d:	6a 00                	push   $0x0
  800f8f:	6a 00                	push   $0x0
  800f91:	6a 00                	push   $0x0
  800f93:	6a 02                	push   $0x2
  800f95:	e8 70 ff ff ff       	call   800f0a <syscall>
  800f9a:	83 c4 18             	add    $0x18,%esp
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <sys_env_sleep>:

void sys_env_sleep(void)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
	syscall(SYS_env_sleep, 0, 0, 0, 0, 0);
  800fa2:	6a 00                	push   $0x0
  800fa4:	6a 00                	push   $0x0
  800fa6:	6a 00                	push   $0x0
  800fa8:	6a 00                	push   $0x0
  800faa:	6a 00                	push   $0x0
  800fac:	6a 04                	push   $0x4
  800fae:	e8 57 ff ff ff       	call   800f0a <syscall>
  800fb3:	83 c4 18             	add    $0x18,%esp
}
  800fb6:	90                   	nop
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <sys_allocate_page>:


int sys_allocate_page(void *va, int perm)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_allocate_page, (uint32) va, perm, 0 , 0, 0);
  800fbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc2:	6a 00                	push   $0x0
  800fc4:	6a 00                	push   $0x0
  800fc6:	6a 00                	push   $0x0
  800fc8:	52                   	push   %edx
  800fc9:	50                   	push   %eax
  800fca:	6a 05                	push   $0x5
  800fcc:	e8 39 ff ff ff       	call   800f0a <syscall>
  800fd1:	83 c4 18             	add    $0x18,%esp
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <sys_get_page>:

int sys_get_page(void *va, int perm)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_get_page, (uint32) va, perm, 0 , 0, 0);
  800fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	6a 00                	push   $0x0
  800fe1:	6a 00                	push   $0x0
  800fe3:	6a 00                	push   $0x0
  800fe5:	52                   	push   %edx
  800fe6:	50                   	push   %eax
  800fe7:	6a 06                	push   $0x6
  800fe9:	e8 1c ff ff ff       	call   800f0a <syscall>
  800fee:	83 c4 18             	add    $0x18,%esp
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <sys_map_frame>:
		
int sys_map_frame(int32 srcenv, void *srcva, int32 dstenv, void *dstva, int perm)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
	return syscall(SYS_map_frame, srcenv, (uint32) srcva, dstenv, (uint32) dstva, perm);
  800ff8:	8b 75 18             	mov    0x18(%ebp),%esi
  800ffb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800ffe:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801001:	8b 55 0c             	mov    0xc(%ebp),%edx
  801004:	8b 45 08             	mov    0x8(%ebp),%eax
  801007:	56                   	push   %esi
  801008:	53                   	push   %ebx
  801009:	51                   	push   %ecx
  80100a:	52                   	push   %edx
  80100b:	50                   	push   %eax
  80100c:	6a 07                	push   $0x7
  80100e:	e8 f7 fe ff ff       	call   800f0a <syscall>
  801013:	83 c4 18             	add    $0x18,%esp
}
  801016:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801019:	5b                   	pop    %ebx
  80101a:	5e                   	pop    %esi
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <sys_unmap_frame>:

int sys_unmap_frame(int32 envid, void *va)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_unmap_frame, envid, (uint32) va, 0, 0, 0);
  801020:	8b 55 0c             	mov    0xc(%ebp),%edx
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	6a 00                	push   $0x0
  801028:	6a 00                	push   $0x0
  80102a:	6a 00                	push   $0x0
  80102c:	52                   	push   %edx
  80102d:	50                   	push   %eax
  80102e:	6a 08                	push   $0x8
  801030:	e8 d5 fe ff ff       	call   800f0a <syscall>
  801035:	83 c4 18             	add    $0x18,%esp
}
  801038:	c9                   	leave  
  801039:	c3                   	ret    

0080103a <sys_calculate_required_frames>:

uint32 sys_calculate_required_frames(uint32 start_virtual_address, uint32 size)
{
  80103a:	55                   	push   %ebp
  80103b:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_req_frames, start_virtual_address, (uint32) size, 0, 0, 0);
  80103d:	6a 00                	push   $0x0
  80103f:	6a 00                	push   $0x0
  801041:	6a 00                	push   $0x0
  801043:	ff 75 0c             	pushl  0xc(%ebp)
  801046:	ff 75 08             	pushl  0x8(%ebp)
  801049:	6a 09                	push   $0x9
  80104b:	e8 ba fe ff ff       	call   800f0a <syscall>
  801050:	83 c4 18             	add    $0x18,%esp
}
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <sys_calculate_free_frames>:

uint32 sys_calculate_free_frames()
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
	return syscall(SYS_calc_free_frames, 0, 0, 0, 0, 0);
  801058:	6a 00                	push   $0x0
  80105a:	6a 00                	push   $0x0
  80105c:	6a 00                	push   $0x0
  80105e:	6a 00                	push   $0x0
  801060:	6a 00                	push   $0x0
  801062:	6a 0a                	push   $0xa
  801064:	e8 a1 fe ff ff       	call   800f0a <syscall>
  801069:	83 c4 18             	add    $0x18,%esp
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <sys_freeMem>:

void sys_freeMem(void* start_virtual_address, uint32 size)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
	syscall(SYS_freeMem, (uint32) start_virtual_address, size, 0, 0, 0);
  801071:	8b 45 08             	mov    0x8(%ebp),%eax
  801074:	6a 00                	push   $0x0
  801076:	6a 00                	push   $0x0
  801078:	6a 00                	push   $0x0
  80107a:	ff 75 0c             	pushl  0xc(%ebp)
  80107d:	50                   	push   %eax
  80107e:	6a 0b                	push   $0xb
  801080:	e8 85 fe ff ff       	call   800f0a <syscall>
  801085:	83 c4 18             	add    $0x18,%esp
	return;
  801088:	90                   	nop
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes FOS to enter the FOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801091:	8d 45 10             	lea    0x10(%ebp),%eax
  801094:	83 c0 04             	add    $0x4,%eax
  801097:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	if (argv0)
  80109a:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	74 16                	je     8010b9 <_panic+0x2e>
		cprintf("%s: ", argv0);
  8010a3:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	50                   	push   %eax
  8010ac:	68 48 16 80 00       	push   $0x801648
  8010b1:	e8 5b f2 ff ff       	call   800311 <cprintf>
  8010b6:	83 c4 10             	add    $0x10,%esp
	cprintf("user panic in %s at %s:%d: ", binaryname, file, line);
  8010b9:	a1 00 20 80 00       	mov    0x802000,%eax
  8010be:	ff 75 0c             	pushl  0xc(%ebp)
  8010c1:	ff 75 08             	pushl  0x8(%ebp)
  8010c4:	50                   	push   %eax
  8010c5:	68 4d 16 80 00       	push   $0x80164d
  8010ca:	e8 42 f2 ff ff       	call   800311 <cprintf>
  8010cf:	83 c4 10             	add    $0x10,%esp
	vcprintf(fmt, ap);
  8010d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8010db:	50                   	push   %eax
  8010dc:	e8 d5 f1 ff ff       	call   8002b6 <vcprintf>
  8010e1:	83 c4 10             	add    $0x10,%esp
	cprintf("\n");
  8010e4:	83 ec 0c             	sub    $0xc,%esp
  8010e7:	68 69 16 80 00       	push   $0x801669
  8010ec:	e8 20 f2 ff ff       	call   800311 <cprintf>
  8010f1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010f4:	cc                   	int3   
  8010f5:	eb fd                	jmp    8010f4 <_panic+0x69>
  8010f7:	90                   	nop

008010f8 <__udivdi3>:
  8010f8:	55                   	push   %ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 1c             	sub    $0x1c,%esp
  8010ff:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801103:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801107:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80110b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80110f:	89 ca                	mov    %ecx,%edx
  801111:	89 f8                	mov    %edi,%eax
  801113:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801117:	85 f6                	test   %esi,%esi
  801119:	75 2d                	jne    801148 <__udivdi3+0x50>
  80111b:	39 cf                	cmp    %ecx,%edi
  80111d:	77 65                	ja     801184 <__udivdi3+0x8c>
  80111f:	89 fd                	mov    %edi,%ebp
  801121:	85 ff                	test   %edi,%edi
  801123:	75 0b                	jne    801130 <__udivdi3+0x38>
  801125:	b8 01 00 00 00       	mov    $0x1,%eax
  80112a:	31 d2                	xor    %edx,%edx
  80112c:	f7 f7                	div    %edi
  80112e:	89 c5                	mov    %eax,%ebp
  801130:	31 d2                	xor    %edx,%edx
  801132:	89 c8                	mov    %ecx,%eax
  801134:	f7 f5                	div    %ebp
  801136:	89 c1                	mov    %eax,%ecx
  801138:	89 d8                	mov    %ebx,%eax
  80113a:	f7 f5                	div    %ebp
  80113c:	89 cf                	mov    %ecx,%edi
  80113e:	89 fa                	mov    %edi,%edx
  801140:	83 c4 1c             	add    $0x1c,%esp
  801143:	5b                   	pop    %ebx
  801144:	5e                   	pop    %esi
  801145:	5f                   	pop    %edi
  801146:	5d                   	pop    %ebp
  801147:	c3                   	ret    
  801148:	39 ce                	cmp    %ecx,%esi
  80114a:	77 28                	ja     801174 <__udivdi3+0x7c>
  80114c:	0f bd fe             	bsr    %esi,%edi
  80114f:	83 f7 1f             	xor    $0x1f,%edi
  801152:	75 40                	jne    801194 <__udivdi3+0x9c>
  801154:	39 ce                	cmp    %ecx,%esi
  801156:	72 0a                	jb     801162 <__udivdi3+0x6a>
  801158:	3b 44 24 08          	cmp    0x8(%esp),%eax
  80115c:	0f 87 9e 00 00 00    	ja     801200 <__udivdi3+0x108>
  801162:	b8 01 00 00 00       	mov    $0x1,%eax
  801167:	89 fa                	mov    %edi,%edx
  801169:	83 c4 1c             	add    $0x1c,%esp
  80116c:	5b                   	pop    %ebx
  80116d:	5e                   	pop    %esi
  80116e:	5f                   	pop    %edi
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    
  801171:	8d 76 00             	lea    0x0(%esi),%esi
  801174:	31 ff                	xor    %edi,%edi
  801176:	31 c0                	xor    %eax,%eax
  801178:	89 fa                	mov    %edi,%edx
  80117a:	83 c4 1c             	add    $0x1c,%esp
  80117d:	5b                   	pop    %ebx
  80117e:	5e                   	pop    %esi
  80117f:	5f                   	pop    %edi
  801180:	5d                   	pop    %ebp
  801181:	c3                   	ret    
  801182:	66 90                	xchg   %ax,%ax
  801184:	89 d8                	mov    %ebx,%eax
  801186:	f7 f7                	div    %edi
  801188:	31 ff                	xor    %edi,%edi
  80118a:	89 fa                	mov    %edi,%edx
  80118c:	83 c4 1c             	add    $0x1c,%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    
  801194:	bd 20 00 00 00       	mov    $0x20,%ebp
  801199:	89 eb                	mov    %ebp,%ebx
  80119b:	29 fb                	sub    %edi,%ebx
  80119d:	89 f9                	mov    %edi,%ecx
  80119f:	d3 e6                	shl    %cl,%esi
  8011a1:	89 c5                	mov    %eax,%ebp
  8011a3:	88 d9                	mov    %bl,%cl
  8011a5:	d3 ed                	shr    %cl,%ebp
  8011a7:	89 e9                	mov    %ebp,%ecx
  8011a9:	09 f1                	or     %esi,%ecx
  8011ab:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8011af:	89 f9                	mov    %edi,%ecx
  8011b1:	d3 e0                	shl    %cl,%eax
  8011b3:	89 c5                	mov    %eax,%ebp
  8011b5:	89 d6                	mov    %edx,%esi
  8011b7:	88 d9                	mov    %bl,%cl
  8011b9:	d3 ee                	shr    %cl,%esi
  8011bb:	89 f9                	mov    %edi,%ecx
  8011bd:	d3 e2                	shl    %cl,%edx
  8011bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8011c3:	88 d9                	mov    %bl,%cl
  8011c5:	d3 e8                	shr    %cl,%eax
  8011c7:	09 c2                	or     %eax,%edx
  8011c9:	89 d0                	mov    %edx,%eax
  8011cb:	89 f2                	mov    %esi,%edx
  8011cd:	f7 74 24 0c          	divl   0xc(%esp)
  8011d1:	89 d6                	mov    %edx,%esi
  8011d3:	89 c3                	mov    %eax,%ebx
  8011d5:	f7 e5                	mul    %ebp
  8011d7:	39 d6                	cmp    %edx,%esi
  8011d9:	72 19                	jb     8011f4 <__udivdi3+0xfc>
  8011db:	74 0b                	je     8011e8 <__udivdi3+0xf0>
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	31 ff                	xor    %edi,%edi
  8011e1:	e9 58 ff ff ff       	jmp    80113e <__udivdi3+0x46>
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	8b 54 24 08          	mov    0x8(%esp),%edx
  8011ec:	89 f9                	mov    %edi,%ecx
  8011ee:	d3 e2                	shl    %cl,%edx
  8011f0:	39 c2                	cmp    %eax,%edx
  8011f2:	73 e9                	jae    8011dd <__udivdi3+0xe5>
  8011f4:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011f7:	31 ff                	xor    %edi,%edi
  8011f9:	e9 40 ff ff ff       	jmp    80113e <__udivdi3+0x46>
  8011fe:	66 90                	xchg   %ax,%ax
  801200:	31 c0                	xor    %eax,%eax
  801202:	e9 37 ff ff ff       	jmp    80113e <__udivdi3+0x46>
  801207:	90                   	nop

00801208 <__umoddi3>:
  801208:	55                   	push   %ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	53                   	push   %ebx
  80120c:	83 ec 1c             	sub    $0x1c,%esp
  80120f:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801213:	8b 74 24 34          	mov    0x34(%esp),%esi
  801217:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80121b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80121f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801223:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801227:	89 f3                	mov    %esi,%ebx
  801229:	89 fa                	mov    %edi,%edx
  80122b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80122f:	89 34 24             	mov    %esi,(%esp)
  801232:	85 c0                	test   %eax,%eax
  801234:	75 1a                	jne    801250 <__umoddi3+0x48>
  801236:	39 f7                	cmp    %esi,%edi
  801238:	0f 86 a2 00 00 00    	jbe    8012e0 <__umoddi3+0xd8>
  80123e:	89 c8                	mov    %ecx,%eax
  801240:	89 f2                	mov    %esi,%edx
  801242:	f7 f7                	div    %edi
  801244:	89 d0                	mov    %edx,%eax
  801246:	31 d2                	xor    %edx,%edx
  801248:	83 c4 1c             	add    $0x1c,%esp
  80124b:	5b                   	pop    %ebx
  80124c:	5e                   	pop    %esi
  80124d:	5f                   	pop    %edi
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    
  801250:	39 f0                	cmp    %esi,%eax
  801252:	0f 87 ac 00 00 00    	ja     801304 <__umoddi3+0xfc>
  801258:	0f bd e8             	bsr    %eax,%ebp
  80125b:	83 f5 1f             	xor    $0x1f,%ebp
  80125e:	0f 84 ac 00 00 00    	je     801310 <__umoddi3+0x108>
  801264:	bf 20 00 00 00       	mov    $0x20,%edi
  801269:	29 ef                	sub    %ebp,%edi
  80126b:	89 fe                	mov    %edi,%esi
  80126d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801271:	89 e9                	mov    %ebp,%ecx
  801273:	d3 e0                	shl    %cl,%eax
  801275:	89 d7                	mov    %edx,%edi
  801277:	89 f1                	mov    %esi,%ecx
  801279:	d3 ef                	shr    %cl,%edi
  80127b:	09 c7                	or     %eax,%edi
  80127d:	89 e9                	mov    %ebp,%ecx
  80127f:	d3 e2                	shl    %cl,%edx
  801281:	89 14 24             	mov    %edx,(%esp)
  801284:	89 d8                	mov    %ebx,%eax
  801286:	d3 e0                	shl    %cl,%eax
  801288:	89 c2                	mov    %eax,%edx
  80128a:	8b 44 24 08          	mov    0x8(%esp),%eax
  80128e:	d3 e0                	shl    %cl,%eax
  801290:	89 44 24 04          	mov    %eax,0x4(%esp)
  801294:	8b 44 24 08          	mov    0x8(%esp),%eax
  801298:	89 f1                	mov    %esi,%ecx
  80129a:	d3 e8                	shr    %cl,%eax
  80129c:	09 d0                	or     %edx,%eax
  80129e:	d3 eb                	shr    %cl,%ebx
  8012a0:	89 da                	mov    %ebx,%edx
  8012a2:	f7 f7                	div    %edi
  8012a4:	89 d3                	mov    %edx,%ebx
  8012a6:	f7 24 24             	mull   (%esp)
  8012a9:	89 c6                	mov    %eax,%esi
  8012ab:	89 d1                	mov    %edx,%ecx
  8012ad:	39 d3                	cmp    %edx,%ebx
  8012af:	0f 82 87 00 00 00    	jb     80133c <__umoddi3+0x134>
  8012b5:	0f 84 91 00 00 00    	je     80134c <__umoddi3+0x144>
  8012bb:	8b 54 24 04          	mov    0x4(%esp),%edx
  8012bf:	29 f2                	sub    %esi,%edx
  8012c1:	19 cb                	sbb    %ecx,%ebx
  8012c3:	89 d8                	mov    %ebx,%eax
  8012c5:	8a 4c 24 0c          	mov    0xc(%esp),%cl
  8012c9:	d3 e0                	shl    %cl,%eax
  8012cb:	89 e9                	mov    %ebp,%ecx
  8012cd:	d3 ea                	shr    %cl,%edx
  8012cf:	09 d0                	or     %edx,%eax
  8012d1:	89 e9                	mov    %ebp,%ecx
  8012d3:	d3 eb                	shr    %cl,%ebx
  8012d5:	89 da                	mov    %ebx,%edx
  8012d7:	83 c4 1c             	add    $0x1c,%esp
  8012da:	5b                   	pop    %ebx
  8012db:	5e                   	pop    %esi
  8012dc:	5f                   	pop    %edi
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    
  8012df:	90                   	nop
  8012e0:	89 fd                	mov    %edi,%ebp
  8012e2:	85 ff                	test   %edi,%edi
  8012e4:	75 0b                	jne    8012f1 <__umoddi3+0xe9>
  8012e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8012eb:	31 d2                	xor    %edx,%edx
  8012ed:	f7 f7                	div    %edi
  8012ef:	89 c5                	mov    %eax,%ebp
  8012f1:	89 f0                	mov    %esi,%eax
  8012f3:	31 d2                	xor    %edx,%edx
  8012f5:	f7 f5                	div    %ebp
  8012f7:	89 c8                	mov    %ecx,%eax
  8012f9:	f7 f5                	div    %ebp
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	e9 44 ff ff ff       	jmp    801246 <__umoddi3+0x3e>
  801302:	66 90                	xchg   %ax,%ax
  801304:	89 c8                	mov    %ecx,%eax
  801306:	89 f2                	mov    %esi,%edx
  801308:	83 c4 1c             	add    $0x1c,%esp
  80130b:	5b                   	pop    %ebx
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    
  801310:	3b 04 24             	cmp    (%esp),%eax
  801313:	72 06                	jb     80131b <__umoddi3+0x113>
  801315:	3b 7c 24 04          	cmp    0x4(%esp),%edi
  801319:	77 0f                	ja     80132a <__umoddi3+0x122>
  80131b:	89 f2                	mov    %esi,%edx
  80131d:	29 f9                	sub    %edi,%ecx
  80131f:	1b 54 24 0c          	sbb    0xc(%esp),%edx
  801323:	89 14 24             	mov    %edx,(%esp)
  801326:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80132a:	8b 44 24 04          	mov    0x4(%esp),%eax
  80132e:	8b 14 24             	mov    (%esp),%edx
  801331:	83 c4 1c             	add    $0x1c,%esp
  801334:	5b                   	pop    %ebx
  801335:	5e                   	pop    %esi
  801336:	5f                   	pop    %edi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    
  801339:	8d 76 00             	lea    0x0(%esi),%esi
  80133c:	2b 04 24             	sub    (%esp),%eax
  80133f:	19 fa                	sbb    %edi,%edx
  801341:	89 d1                	mov    %edx,%ecx
  801343:	89 c6                	mov    %eax,%esi
  801345:	e9 71 ff ff ff       	jmp    8012bb <__umoddi3+0xb3>
  80134a:	66 90                	xchg   %ax,%ax
  80134c:	39 44 24 04          	cmp    %eax,0x4(%esp)
  801350:	72 ea                	jb     80133c <__umoddi3+0x134>
  801352:	89 d9                	mov    %ebx,%ecx
  801354:	e9 62 ff ff ff       	jmp    8012bb <__umoddi3+0xb3>
