:userdoc.
:title.OS&slash.2 LIBPATH Extension Functions
:docprof toc=12.
:h1.Copyright and Notices
:p.IBM and OS&slash.2 are registered trademarks of International Business Machines Corp&per.
:h2.OS&slash.2 LIBPATH Extension Manipulation Functions
:h3.COPYRIGHT AND LICENSING INFORMATION
:p.This suite of subroutines is freeware, distributed as is, without any warranty
of its usefulness for any purpose&per. You may use it freely&per. You may also redistribute it,
provided no charge is levied beyond the price of its distribution medium&per.
:p.However, the author retains all intellectual property rights&per.
.br
.ce Copyright &lpar.C&rpar. David W. Noon, 2001&per.
:h3.OBTAINING TECHNICAL SUPPORT
:p.You can obtain technical support via Internet e&hyphen.mail, Compuserve, or FidoNet Netmail&per.
My addresses are as follows&per.
:font facename='System Monospaced' size=16x12.
:parml compact tsize=15 break=none.
:pt.Internet&colon.
:pd.dwnoon&atsign.os2bbs&per.com
:pt.
:pd.dwnoon&atsign.ntlworld&per.com
:pt.
:pd.dwnoon&atsign.compuserve&per.com
:pt.
:pd.dnoon&atsign.acm&per.org
:pt.Compuserve&colon.
:pd.72172,431
:pt.FidoNet&colon.
:pd.David Noon 2&colon.257&slash.609
:pt.
:pd.David Noon 1&colon.109&slash.347
:eparml.
:font facename=default size=0x0.
:p.The first FidoNet mailbox and the Internet mailboxes I check almost every day&per. The second
FidoNet mailbox and the Compuserve mailbox are checked once or twice a week&per.
:p.Turn&hyphen.around time on problems might not be spectacular, especially if I have other issues
to handle&per. This is freeware and you should expect no more than you pay for&per.
:h1.Preparing these Functions for your Development Environment
:p.The subroutines and functions supplied here are offered as complete source code&per. I have also
included compiled libraries prepared using the EMX&plus.GCC compiler, release 0&per.96d fixpack
&numsign.4&per. Unless you are using this same set&hyphen.up, you will need to compile these
functions with your chosen C&slash.C&plus.&plus. compiler&per. This detail I must leave to you&per.
:p.:hp5.I am assuming that you are familiar with your chosen compiler&apos.s usage of environment
variables to handle its header file and static link library resolution&per.:ehp5.
:p.Once you have suitable libraries built, copy the :hp4.lpathext&per.h:ehp4. file to a directory
that is in your compiler&apos.s INCLUDE directory list&per. For the Watcom compiler,
this will be the OS2&us.INCLUDE directory list&per. For EMX&plus.GCC this will be the
C&us.INCLUDE&us.PATH and CPLUS&us.INCLUDE&us.PATH directory lists&semi. a directory that occurs
in both would be the ideal location&per.
:p.You should also copy the :hp4.lpathext&per.lib:ehp4. file to a directory that is in
your linker&apos.s LIB directory list&per. If you are using EMX&plus.GCC you will need also to copy
:hp4.lpathext&per.a:ehp4. to a directory in the LIBRARY&us.PATH list&per.
:p.You might also care to copy this file, :hp4.lpathext&per.inf:ehp4., to a directory that is in
your BOOKSHELF directory list&per.
:h1.The Two Extensions to LIBPATH for DLL Loading
:p.There are two buffer areas, each 1024 bytes in size, that are provided in each OS&slash.2
address space for directory lists that can be searched to resolve requests to load DLLs&per. One
directory list is searched before the main LIBPATH list is searched&semi. this is the
:hp4.pre&hyphen.system:ehp4. extension&per. The other list is searched after the LIBPATH list
has failed to yield a matching DLL name&semi. this is the :hp4.post&hyphen.system:ehp4.
extension&per.
:p.The purposes of these two extensions are quite straightforward&colon.
:p.The pre&hyphen.system extension is used when you definitely want to override any default
system library with an application&hyphen.specific library&per.
:p.The post&hyphen.system extension is used when you want to proved some :hp1.lowest common
denominator:ehp1. library as a last resort, but expect the user to have installed some
like&hyphen.named library with more specific functionality, typically as some form of
customization, into a LIBPATH directory&per.
:p.You should also be aware that the OS/2 loader performs a lookaside of already&hyphen.loaded
modules for a matching basename before scanning LIBPATH or either of its extensions&per. This means
that if some other application has already loaded a DLL with matching basename, all your attempts
to direct the loading process will be for nought&per. There is only one way to overcome this
problem&colon. :hp5.You must specify a fully qualified path&slash.filename, complete with extension,
to the DosLoadModule&lpar.&rpar. API instead of supplying just the basename&per.:ehp5. While this
is not the idiomatic way to load a library, it is the only way around the basename lookaside
issue&per. If you choose obscure basenames for your dynamic libraries then you will usually
avoid the problem&per. A quick scan through the x&colon.&bsl.OS2&bsl.DLL directory will give
you a hint on what basenames to avoid&semi. a look through x&colon.&bsl.MMOS2&bsl.DLL will provide
you with more basenames to avoid&per.
:p.The purpose of these library routines is to remove the constraint of changing your current
working directory during execution and thereby losing the ability to load DLLs through the
&odq.dot&cdq. entry in the LIBPATH list, as well providing the override and fallback features
of the basic extensions&per.
:note text='Constraint:'.These extensions only take effect after the API or library call has
been made&per. If you use linker fix&hyphen.ups from an import library, the DLL&lpar.s&rpar.
required for those must be present in the LIBPATH &lpar.or the shell&apos.s LIBPATH extensions&rpar.
before the program starts&semi. so these routines will provide you with no help there&per. The
intent of these routines is for those who use DLL technology in the fullest sense of the
adjective &odq.dynamic&cdq., using the DosLoadModule&lpar.&rpar. API or some wrapper function&per.
:h1.The Subroutines
:p.These subroutines are fairly thin wrappers on the :hp4.DosQueryExtLIBPATH&lpar.&rpar.:ehp4. and
:hp4.DosSetExtLIBPATH&lpar.&rpar.:ehp4. API calls&per. You need to be aware that these API calls
were not added to OS&slash.2 until version 2&per.11, so any code that uses these routines will not
run under OS&slash.2 2&per.1 or earlier&per.
:p.You should also be aware that calling these routines will not affect in any way the values
of the surrounding shell&apos.s BEGINLIBPATH and ENDLIBPATH environment variables&per. In fact,
once you start using these routines you should forget all about those environment variables,
as they were always just an ugly kludge&per. &lbrk.That is not to say that this library is not a
kludge too&per. It just isn&apos.t as ugly as the environment variable approach&per.&rbrk.
:h2 res=1 x=0% y=0% height=100% width=30%.set_beginlibpath
:p.This subroutine sets the pre&hyphen.system LIBPATH extension to the directory in which the
executable that started the address space resides&per.
:link reftype=hd res=101 auto.
:sl.
:li.:link reftype=hd res=101.Syntax:elink.
:li.:link reftype=hd res=102.Parameters:elink.
:li.:link reftype=hd res=103.Returned results:elink.
:li.:link reftype=hd res=104.Remarks:elink.
:esl.
:h2 res=101 x=30% y=0% height=100% width=70% viewport hide.set_beginlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long set_beginlibpath&lpar.void&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of set_beginlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
&slash.&asterisk. Add program directory to LIBPATH &asterisk.&slash.
if &lpar.set_beginlibpath&lpar.&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to set LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=102 x=30% y=0% height=100% width=70% viewport hide.set_beginlibpath Parameters
:p.This function takes no parameters&per.
:h2 res=103 x=30% y=0% height=100% width=70% viewport hide.set_beginlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=104 x=30% y=0% height=100% width=70% viewport hide.set_beginlibpath Remarks
:p.If the directory path in which the main executable resides ends with a final node of BIN
&lpar.case&hyphen.insensitive&rpar. then a check is made to see if there exists an otherwise
identical directory path that ends in DLL instead&per. If so, then this DLL directory path
is used instead for the pre&hyphen.system LIBPATH extension&per.
:p.For example, if your program is
:hp8.H&colon.&bsl.Site&us.software&bsl.bin&bsl.Program&us.1&per.exe:ehp8. then the directory path is
:hp8.H&colon.&bsl.Site&us.software&bsl.bin:ehp8.&per. If the directory path
:hp8.H&colon.&bsl.Site&us.software&bsl.dll:ehp8. exists then that is used to set the LIBPATH
extension, otherwise the :hp8.H&colon.&bsl.Site&us.software&bsl.bin:ehp8. path is used&per.
:h2 res=2 x=0% y=0% height=100% width=30%.set_endlibpath
:p.This subroutine sets the post&hyphen.system LIBPATH extension to the directory in which the
executable that started the address space resides&per.
:link reftype=hd res=201 auto.
:sl.
:li.:link reftype=hd res=201.Syntax:elink.
:li.:link reftype=hd res=202.Parameters:elink.
:li.:link reftype=hd res=203.Returned results:elink.
:li.:link reftype=hd res=204.Remarks:elink.
:esl.
:h2 res=201 x=30% y=0% height=100% width=70% viewport hide.set_endlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long set_endlibpath&lpar.void&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of set_endlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
&slash.&asterisk. Add program directory to LIBPATH &asterisk.&slash.
if &lpar.set_endlibpath&lpar.&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to set LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=202 x=30% y=0% height=100% width=70% viewport hide.set_endlibpath Parameters
:p.This function takes no parameters&per.
:h2 res=203 x=30% y=0% height=100% width=70% viewport hide.set_endlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=204 x=30% y=0% height=100% width=70% viewport hide.set_endlibpath Remarks
:p.If the directory path in which the main executable resides ends with a final node of BIN
&lpar.case&hyphen.insensitive&rpar. then a check is made to see if there exists an otherwise
identical directory path that ends in DLL instead&per. If so, then this DLL directory path
is used instead for the post&hyphen.system LIBPATH extension&per.
:p.For example, if your program is
:hp8.H&colon.&bsl.Site&us.software&bsl.bin&bsl.Program&us.1&per.exe:ehp8. then the directory path is
:hp8.H&colon.&bsl.Site&us.software&bsl.bin:ehp8.&per. If the directory path
:hp8.H&colon.&bsl.Site&us.software&bsl.dll:ehp8. exists then that is used to set the LIBPATH
extension, otherwise the :hp8.H&colon.&bsl.Site&us.software&bsl.bin:ehp8. path is used&per.
:h2 res=3 x=0% y=0% height=100% width=30%.query_beginlibpath
:p.This subroutine queries the pre&hyphen.system LIBPATH extension into a buffer supplied by
the caller&per.
:link reftype=hd res=301 auto.
:sl.
:li.:link reftype=hd res=301.Syntax:elink.
:li.:link reftype=hd res=302.Parameters:elink.
:li.:link reftype=hd res=303.Returned results:elink.
:li.:link reftype=hd res=304.Remarks:elink.
:esl.
:h2 res=301 x=30% y=0% height=100% width=70% viewport hide.query_beginlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long query_beginlibpath&lpar.char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of query_beginlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
&slash.&asterisk. Retrieve current LIBPATH extension &asterisk.&slash.
if &lpar.query_beginlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to query LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
puts&lpar.buffer&us.area&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=302 x=30% y=0% height=100% width=70% viewport hide.query_beginlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.char &lbrk.&rbrk.&rpar.
:pd.Needs to be as large as the current pre&hyphen.system LIBPATH extension string, including
a trailing semi&hyphen.colon and a trailing NUL&per. A length of 1024 will always be safe&per.
:eparml.
:h2 res=303 x=30% y=0% height=100% width=70% viewport hide.query_beginlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosQueryExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=304 x=30% y=0% height=100% width=70% viewport hide.query_beginlibpath Remarks
:p.For some stupid reason, the API always adds a trailing semi&hyphen.colon even though it is
totally redundant&per.
:h2 res=4 x=0% y=0% height=100% width=30%.query_endlibpath
:p.This subroutine queries the post&hyphen.system LIBPATH extension into a buffer supplied by
the caller&per.
:link reftype=hd res=401 auto.
:sl.
:li.:link reftype=hd res=401.Syntax:elink.
:li.:link reftype=hd res=402.Parameters:elink.
:li.:link reftype=hd res=403.Returned results:elink.
:li.:link reftype=hd res=404.Remarks:elink.
:esl.
:h2 res=401 x=30% y=0% height=100% width=70% viewport hide.query_endlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long query_endlibpath&lpar.char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of query_endlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
&slash.&asterisk. Retrieve current LIBPATH extension &asterisk.&slash.
if &lpar.query_endlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to query LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
puts&lpar.buffer&us.area&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=402 x=30% y=0% height=100% width=70% viewport hide.query_endlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.char &lbrk.&rbrk.&rpar.
:pd.Needs to be as large as the current post&hyphen.system LIBPATH extension string, including
a trailing semi&hyphen.colon and a trailing NUL&per. A length of 1024 will always be safe&per.
:eparml.
:h2 res=403 x=30% y=0% height=100% width=70% viewport hide.query_endlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosQueryExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=404 x=30% y=0% height=100% width=70% viewport hide.query_endlibpath Remarks
:p.For some stupid reason, the API always adds a trailing semi&hyphen.colon even though it is
totally redundant&per.
:h2 res=5 x=0% y=0% height=100% width=30%.clear_beginlibpath
:p.This subroutine sets the pre&hyphen.system LIBPATH extension to an empty string.
:link reftype=hd res=501 auto.
:sl.
:li.:link reftype=hd res=501.Syntax:elink.
:li.:link reftype=hd res=502.Parameters:elink.
:li.:link reftype=hd res=503.Returned results:elink.
:li.:link reftype=hd res=504.Remarks:elink.
:esl.
:h2 res=501 x=30% y=0% height=100% width=70% viewport hide.clear_beginlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long clear_beginlibpath&lpar.void&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of clear_beginlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
&slash.&asterisk. Remove LIBPATH extension &asterisk.&slash.
if &lpar.clear_beginlibpath&lpar.&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to clear LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=502 x=30% y=0% height=100% width=70% viewport hide.clear_beginlibpath Parameters
:p.This function takes no parameters&per.
:h2 res=503 x=30% y=0% height=100% width=70% viewport hide.clear_beginlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=504 x=30% y=0% height=100% width=70% viewport hide.clear_beginlibpath Remarks
:p.This function removes all entries from the pre&hyphen.system LIBPATH directory list&per.
This includes any that might have been put there by the shell from its BEGINLIBPATH environment
variable&per.
:h2 res=6 x=0% y=0% height=100% width=30%.clear_endlibpath
:p.This subroutine sets the post&hyphen.system LIBPATH extension to an empty string.
:link reftype=hd res=601 auto.
:sl.
:li.:link reftype=hd res=601.Syntax:elink.
:li.:link reftype=hd res=602.Parameters:elink.
:li.:link reftype=hd res=603.Returned results:elink.
:li.:link reftype=hd res=604.Remarks:elink.
:esl.
:h2 res=601 x=30% y=0% height=100% width=70% viewport hide.clear_endlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long clear_endlibpath&lpar.void&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of clear_endlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
&slash.&asterisk. Remove LIBPATH extension &asterisk.&slash.
if &lpar.clear_endlibpath&lpar.&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to clear LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=602 x=30% y=0% height=100% width=70% viewport hide.clear_endlibpath Parameters
:p.This function takes no parameters&per.
:h2 res=603 x=30% y=0% height=100% width=70% viewport hide.clear_endlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API, but these should never occur&per.
:h2 res=604 x=30% y=0% height=100% width=70% viewport hide.clear_endlibpath Remarks
:p.This function removes all entries from the post&hyphen.system LIBPATH directory list&per.
This includes any that might have been put there by the shell from its ENDLIBPATH environment
variable&per.
:h2 res=7 x=0% y=0% height=100% width=30%.append_beginlibpath
:p.This concatenates the supplied list of directories to end of the pre&hyphen.system LIBPATH
extension&per.
:link reftype=hd res=701 auto.
:sl.
:li.:link reftype=hd res=701.Syntax:elink.
:li.:link reftype=hd res=702.Parameters:elink.
:li.:link reftype=hd res=703.Returned results:elink.
:li.:link reftype=hd res=704.Remarks:elink.
:esl.
:h2 res=701 x=30% y=0% height=100% width=70% viewport hide.append_beginlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long append_beginlibpath&lpar.const char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of append_beginlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
APIRET rc&semi.
HMODULE lib&us.handle&semi.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
strcpy&lpar.buffer&us.area, &odq.X&colon.&bsl.&bsl.ThisApp&bsl.&bsl.DLL&cdq.&rpar.&semi.
&slash.&asterisk. Extend further the current LIBPATH extension &asterisk.&slash.
if &lpar.append_beginlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to extend LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
rc &eq. DosLoadModule&lpar.buffer&us.area, sizeof buffer&us.area, &odq.DYNALIB&cdq., &amp.lib&us.handle&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=702 x=30% y=0% height=100% width=70% viewport hide.append_beginlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.const char &lbrk.&rbrk.&rpar.
:pd.The list of directories to be concatenated onto the end of the current pre&hyphen.system
LIBPATH extension&per.
:eparml.
:h2 res=703 x=30% y=0% height=100% width=70% viewport hide.append_beginlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API&per. The most likely error values to be returned are
8 &lpar.:hp4.ERROR&us.NOT&us.ENOUGH&us.MEMORY:ehp4.&rpar. and 161
&lpar.:hp4.ERROR&us.BAD&us.PATHNAME:ehp4.&rpar.&per.
:h2 res=704 x=30% y=0% height=100% width=70% viewport hide.append_beginlibpath Remarks
:p.The directory names should be fully qualified and built into a string, separated by
semi&hyphen.colons, just one would when coding the LIBPATH list in CONFIG&per.SYS&per. You
do not need a trailing semi&hyphen.colon&per.
:p.See also the :link reftype=hd res=9.prepend_beginlibpath:elink.&lpar.&rpar. function&per.
:h2 res=8 x=0% y=0% height=100% width=30%.append_endlibpath
:p.This concatenates the supplied list of directories to end of the post&hyphen.system LIBPATH
extension&per.
:link reftype=hd res=801 auto.
:sl.
:li.:link reftype=hd res=801.Syntax:elink.
:li.:link reftype=hd res=802.Parameters:elink.
:li.:link reftype=hd res=803.Returned results:elink.
:li.:link reftype=hd res=804.Remarks:elink.
:esl.
:h2 res=801 x=30% y=0% height=100% width=70% viewport hide.append_endlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long append_endlibpath&lpar.const char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of append_endlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
APIRET rc&semi.
HMODULE lib&us.handle&semi.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
strcpy&lpar.buffer&us.area, &odq.X&colon.&bsl.&bsl.ThisApp&bsl.&bsl.DLL&cdq.&rpar.&semi.
&slash.&asterisk. Extend further the current LIBPATH extension &asterisk.&slash.
if &lpar.append_endlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to extend LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
rc &eq. DosLoadModule&lpar.buffer&us.area, sizeof buffer&us.area, &odq.DYNALIB&cdq., &amp.lib&us.handle&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=802 x=30% y=0% height=100% width=70% viewport hide.append_endlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.const char &lbrk.&rbrk.&rpar.
:pd.The list of directories to be concatenated onto the end of the current post&hyphen.system
LIBPATH extension&per.
:eparml.
:h2 res=803 x=30% y=0% height=100% width=70% viewport hide.append_endlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API&per. The most likely error values to be returned are
8 &lpar.:hp4.ERROR&us.NOT&us.ENOUGH&us.MEMORY:ehp4.&rpar. and 161
&lpar.:hp4.ERROR&us.BAD&us.PATHNAME:ehp4.&rpar.&per.
:h2 res=804 x=30% y=0% height=100% width=70% viewport hide.append_endlibpath Remarks
:p.The directory names should be fully qualified and built into a string, separated by
semi&hyphen.colons, just one would when coding the LIBPATH list in CONFIG&per.SYS&per. You
do not need a trailing semi&hyphen.colon&per.
:p.See also the :link reftype=hd res=10.prepend_endlibpath:elink.&lpar.&rpar. function&per.
:h2 res=9 x=0% y=0% height=100% width=30%.prepend_beginlibpath
:p.This concatenates the supplied list of directories to start of the pre&hyphen.system LIBPATH
extension&per.
:link reftype=hd res=901 auto.
:sl.
:li.:link reftype=hd res=901.Syntax:elink.
:li.:link reftype=hd res=902.Parameters:elink.
:li.:link reftype=hd res=903.Returned results:elink.
:li.:link reftype=hd res=904.Remarks:elink.
:esl.
:h2 res=901 x=30% y=0% height=100% width=70% viewport hide.prepend_beginlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long prepend_beginlibpath&lpar.const char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of prepend_beginlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
APIRET rc&semi.
HMODULE lib&us.handle&semi.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
strcpy&lpar.buffer&us.area, &odq.X&colon.&bsl.&bsl.ThisApp&bsl.&bsl.DLL&cdq.&rpar.&semi.
&slash.&asterisk. Extend further the current LIBPATH extension &asterisk.&slash.
if &lpar.prepend_beginlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to extend LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
rc &eq. DosLoadModule&lpar.buffer&us.area, sizeof buffer&us.area, &odq.DYNALIB&cdq., &amp.lib&us.handle&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=902 x=30% y=0% height=100% width=70% viewport hide.prepend_beginlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.const char &lbrk.&rbrk.&rpar.
:pd.The list of directories to be concatenated onto the start of the current pre&hyphen.system
LIBPATH extension&per.
:eparml.
:h2 res=903 x=30% y=0% height=100% width=70% viewport hide.prepend_beginlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API&per. The most likely error values to be returned are
8 &lpar.:hp4.ERROR&us.NOT&us.ENOUGH&us.MEMORY:ehp4.&rpar. and 161
&lpar.:hp4.ERROR&us.BAD&us.PATHNAME:ehp4.&rpar.&per.
:h2 res=904 x=30% y=0% height=100% width=70% viewport hide.prepend_beginlibpath Remarks
:p.The directory names should be fully qualified and built into a string, separated by
semi&hyphen.colons, just one would when coding the LIBPATH list in CONFIG&per.SYS&per. You
do not need a trailing semi&hyphen.colon&per.
:p.See also the :link reftype=hd res=7.apppend_beginlibpath:elink.&lpar.&rpar. function&per.
:h2 res=10 x=0% y=0% height=100% width=30%.prepend_endlibpath
:p.This concatenates the supplied list of directories to start of the post&hyphen.system LIBPATH
extension&per.
:link reftype=hd res=1001 auto.
:sl.
:li.:link reftype=hd res=1001.Syntax:elink.
:li.:link reftype=hd res=1002.Parameters:elink.
:li.:link reftype=hd res=1003.Returned results:elink.
:li.:link reftype=hd res=1004.Remarks:elink.
:esl.
:h2 res=1001 x=30% y=0% height=100% width=70% viewport hide.prepend_endlibpath Syntax
:color fc=blue bc=default.
:font facename='System Monospaced' size=22x16.
:p.unsigned long prepend_endlibpath&lpar.const char &asterisk. buffer&us.area&rpar.&semi.
:font facename=default size=0x0.
:color fc=default bc=default.
.br
:h3.Example of prepend_endlibpath
:xmp.
&numsign.include &odq.lpathext&per.h&cdq.
.br
int main&lpar.int argc, char &asterisk.&asterisk. argv&rpar.
&lbrc.
:lm margin=4.
APIRET rc&semi.
HMODULE lib&us.handle&semi.
char buffer&us.area&lbrk.1024&rbrk.&semi.
.br
strcpy&lpar.buffer&us.area, &odq.X&colon.&bsl.&bsl.ThisApp&bsl.&bsl.DLL&cdq.&rpar.&semi.
&slash.&asterisk. Extend further the current LIBPATH extension &asterisk.&slash.
if &lpar.prepend_endlibpath&lpar.buffer&us.area&rpar. &xclm.&eq. 0&rpar.
&lbrc.
:lm margin=7.
fputs&lpar.&odq.Unable to extend LIBPATH extension&per.&cdq., stderr&rpar.&semi.
:lm margin=4.
return EXIT&us.FAILURE&semi.
&rbrc.
.br
:hp9.&slash.&asterisk. Rest of program &asterisk.&slash.:ehp9.
rc &eq. DosLoadModule&lpar.buffer&us.area, sizeof buffer&us.area, &odq.DYNALIB&cdq., &amp.lib&us.handle&rpar.&semi.
&per.
&per.
&per.
:lm margin=1.
.br
&rbrc.
:exmp.
:h2 res=1002 x=30% y=0% height=100% width=70% viewport hide.prepend_endlibpath Parameters
:p.There is only one parameter for this function&per.
:parml tsize=20 break=all.
:pt.buffer&us.area &lpar.const char &lbrk.&rbrk.&rpar.
:pd.The list of directories to be concatenated onto the start of the current post&hyphen.system
LIBPATH extension&per.
:eparml.
:h2 res=1003 x=30% y=0% height=100% width=70% viewport hide.prepend_endlibpath Returned results
:p.This function normally returns zero&per. Any other value indicates an error returned by
the DosSetExtLIBPATH&lpar.&rpar. API&per. The most likely error values to be returned are
8 &lpar.:hp4.ERROR&us.NOT&us.ENOUGH&us.MEMORY:ehp4.&rpar. and 161
&lpar.:hp4.ERROR&us.BAD&us.PATHNAME:ehp4.&rpar.&per.
:h2 res=1004 x=30% y=0% height=100% width=70% viewport hide.prepend_endlibpath Remarks
:p.The directory names should be fully qualified and built into a string, separated by
semi&hyphen.colons, just one would when coding the LIBPATH list in CONFIG&per.SYS&per. You
do not need a trailing semi&hyphen.colon&per.
:p.See also the :link reftype=hd res=8.append_endlibpath:elink.&lpar.&rpar. function&per.
:euserdoc.
